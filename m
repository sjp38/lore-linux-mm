Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id DF0A16B0011
	for <linux-mm@kvack.org>; Sun, 22 May 2011 18:25:55 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id p4MMPsha003380
	for <linux-mm@kvack.org>; Sun, 22 May 2011 15:25:54 -0700
Received: from pwi12 (pwi12.prod.google.com [10.241.219.12])
	by wpaz13.hot.corp.google.com with ESMTP id p4MMPm8Y025598
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 22 May 2011 15:25:52 -0700
Received: by pwi12 with SMTP id 12so3150798pwi.14
        for <linux-mm@kvack.org>; Sun, 22 May 2011 15:25:48 -0700 (PDT)
Date: Sun, 22 May 2011 15:25:31 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Adding an ugliness in __read_cache_page()?
Message-ID: <alpine.LSU.2.00.1105221518180.17400@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Linus, Christoph,

Could you bear a patch something like the one below?

I have a series aimed at 2.6.41 to remove mm/shmem.c's peculiar radix
tree of swap entries, using slots in the file's standard radix_tree
instead - prompted in part by https://lkml.org/lkml/2011/1/22/110

In isolating the occurrence of swap entries in radix_trees, it becomes
convenient to remove shmem's ->readpage at last, giving it instead its
own ->splice_read.

But drivers/gpu/drm i915 and ttm are using read_cache_page_gfp() or
read_mapping_page() on tmpfs: on objects created by shmem_file_setup().

Nothing else uses read_cache_page_gfp().  I cannot find anything else
using read_mapping_page() on tmpfs, but wonder if something might be
out there.  Stacked filesystems appear not to go that way nowadays.

Would it be better to make i915 and ttm call shmem_read_cache_page()
directly?  Perhaps removing the then unused read_cache_page_gfp(), or
perhaps not: may still be needed for i915 and ttm on tiny !SHMEM ramfs.

I find both ways ugly, but no nice alternative: introducing a new method
when the known callers are already tied to tmpfs/ramfs seems over the top.

Thanks,
Hugh

---

 include/linux/mm.h |    1 +
 mm/filemap.c       |   13 +++++++++++++
 mm/shmem.c         |   26 +++++++++++++++-----------
 3 files changed, 29 insertions(+), 11 deletions(-)

--- 2.6.39/include/linux/mm.h	2011-05-18 21:06:34.000000000 -0700
+++ linux/include/linux/mm.h	2011-05-22 11:50:49.332431949 -0700
@@ -873,6 +873,7 @@ extern void __show_free_areas(unsigned i
 int shmem_lock(struct file *file, int lock, struct user_struct *user);
 struct file *shmem_file_setup(const char *name, loff_t size, unsigned long flags);
 int shmem_zero_setup(struct vm_area_struct *);
+struct page *shmem_read_cache_page(struct address_space *, pgoff_t, gfp_t);
 
 #ifndef CONFIG_MMU
 extern unsigned long shmem_get_unmapped_area(struct file *file,
--- 2.6.39/mm/filemap.c	2011-05-18 21:06:34.000000000 -0700
+++ linux/mm/filemap.c	2011-05-22 11:50:49.332431949 -0700
@@ -1762,6 +1762,19 @@ static struct page *__read_cache_page(st
 {
 	struct page *page;
 	int err;
+
+#ifdef CONFIG_TMPFS
+	/*
+	 * The ->readpage() interface does not suit tmpfs at all, since it
+	 * may have pages in swapcache, and needs to find those for itself;
+	 * but gpu/drm/i915 and gpu/drm/ttm need it to support this function.
+	 */
+	if (!filler) {
+		BUG_ON(!mapping_cap_swap_backed(mapping));
+		return shmem_read_cache_page(mapping, index, gfp);
+	}
+#endif
+
 repeat:
 	page = find_get_page(mapping, index);
 	if (!page) {
--- 2.6.39/mm/shmem.c	2011-05-18 21:06:34.000000000 -0700
+++ linux/mm/shmem.c	2011-05-22 11:50:49.332431949 -0700
@@ -1652,17 +1652,22 @@ static struct inode *shmem_get_inode(str
 static const struct inode_operations shmem_symlink_inode_operations;
 static const struct inode_operations shmem_symlink_inline_operations;
 
-/*
- * Normally tmpfs avoids the use of shmem_readpage and shmem_write_begin;
- * but providing them allows a tmpfs file to be used for splice, sendfile, and
- * below the loop driver, in the generic fashion that many filesystems support.
- */
-static int shmem_readpage(struct file *file, struct page *page)
+struct page *
+shmem_read_cache_page(struct address_space *mapping, pgoff_t index, gfp_t gfp)
 {
-	struct inode *inode = page->mapping->host;
-	int error = shmem_getpage(inode, page->index, &page, SGP_CACHE, NULL);
-	unlock_page(page);
-	return error;
+	struct page *page;
+	int error;
+
+	/*
+	 * Not shown: addition of gfp arg to shmem_getpage(), passed down here.
+	 * Not shown: addition of shmem_file_splice_read() avoiding ->readpage.
+	 */
+	error = shmem_getpage(mapping->host, index, &page, SGP_CACHE, NULL);
+	if (error)
+		page = ERR_PTR(error);
+	else
+		unlock_page(page);
+	return page;
 }
 
 static int
@@ -2475,7 +2480,6 @@ static const struct address_space_operat
 	.writepage	= shmem_writepage,
 	.set_page_dirty	= __set_page_dirty_no_writeback,
 #ifdef CONFIG_TMPFS
-	.readpage	= shmem_readpage,
 	.write_begin	= shmem_write_begin,
 	.write_end	= shmem_write_end,
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
