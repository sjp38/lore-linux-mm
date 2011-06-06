Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5D3056B0122
	for <linux-mm@kvack.org>; Mon,  6 Jun 2011 00:27:36 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p564RYvZ010197
	for <linux-mm@kvack.org>; Sun, 5 Jun 2011 21:27:34 -0700
Received: from pzk1 (pzk1.prod.google.com [10.243.19.129])
	by wpaz5.hot.corp.google.com with ESMTP id p564RWn1012584
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 5 Jun 2011 21:27:33 -0700
Received: by pzk1 with SMTP id 1so2028775pzk.2
        for <linux-mm@kvack.org>; Sun, 05 Jun 2011 21:27:32 -0700 (PDT)
Date: Sun, 5 Jun 2011 21:27:35 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 4/14] tmpfs: add shmem_read_mapping_page_gfp
In-Reply-To: <alpine.LSU.2.00.1106052116350.17116@sister.anvils>
Message-ID: <alpine.LSU.2.00.1106052126170.17116@sister.anvils>
References: <alpine.LSU.2.00.1106052116350.17116@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Although it is used (by i915) on nothing but tmpfs, read_cache_page_gfp()
is unsuited to tmpfs, because it inserts a page into pagecache before
calling the filesystem's ->readpage: tmpfs may have pages in swapcache
which only it knows how to locate and switch to filecache.

At present tmpfs provides a ->readpage method, and copes with this by
copying pages; but soon we can simplify it by removing its ->readpage.
Provide shmem_read_mapping_page_gfp() now, ready for that transition,

Export shmem_read_mapping_page_gfp() and add it to list in shmem_fs.h,
with shmem_read_mapping_page() inline for the common mapping_gfp case.

(shmem_read_mapping_page_gfp or shmem_read_cache_page_gfp?  Generally
the read_mapping_page functions use the mapping's ->readpage, and the
read_cache_page functions use the supplied filler, so I think
read_cache_page_gfp was slightly misnamed.)

Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: Christoph Hellwig <hch@infradead.org>
---
 include/linux/shmem_fs.h |   17 ++++++++++-------
 mm/shmem.c               |   23 +++++++++++++++++++++++
 2 files changed, 33 insertions(+), 7 deletions(-)

--- linux.orig/mm/shmem.c	2011-06-05 17:44:02.293916853 -0700
+++ linux/mm/shmem.c	2011-06-05 17:53:42.948796800 -0700
@@ -3035,3 +3035,26 @@ int shmem_zero_setup(struct vm_area_stru
 	vma->vm_flags |= VM_CAN_NONLINEAR;
 	return 0;
 }
+
+/**
+ * shmem_read_mapping_page_gfp - read into page cache, using specified page allocation flags.
+ * @mapping:	the page's address_space
+ * @index:	the page index
+ * @gfp:	the page allocator flags to use if allocating
+ *
+ * This behaves as a tmpfs "read_cache_page_gfp(mapping, index, gfp)",
+ * with any new page allocations done using the specified allocation flags.
+ * But read_cache_page_gfp() uses the ->readpage() method: which does not
+ * suit tmpfs, since it may have pages in swapcache, and needs to find those
+ * for itself; although drivers/gpu/drm i915 and ttm rely upon this support.
+ *
+ * Provide a stub for those callers to start using now, then later
+ * flesh it out to call shmem_getpage() with additional gfp mask, when
+ * shmem_file_splice_read() is added and shmem_readpage() is removed.
+ */
+struct page *shmem_read_mapping_page_gfp(struct address_space *mapping,
+					 pgoff_t index, gfp_t gfp)
+{
+	return read_cache_page_gfp(mapping, index, gfp);
+}
+EXPORT_SYMBOL_GPL(shmem_read_mapping_page_gfp);
--- linux.orig/include/linux/shmem_fs.h	2011-06-05 17:50:02.000000000 -0700
+++ linux/include/linux/shmem_fs.h	2011-06-05 18:11:16.426020691 -0700
@@ -3,15 +3,9 @@
 
 #include <linux/swap.h>
 #include <linux/mempolicy.h>
+#include <linux/pagemap.h>
 #include <linux/percpu_counter.h>
 
-struct page;
-struct file;
-struct inode;
-struct super_block;
-struct user_struct;
-struct vm_area_struct;
-
 /* inode in-kernel data */
 
 #define SHMEM_NR_DIRECT 16
@@ -61,9 +55,18 @@ extern struct file *shmem_file_setup(con
 					loff_t size, unsigned long flags);
 extern int shmem_zero_setup(struct vm_area_struct *);
 extern int shmem_lock(struct file *file, int lock, struct user_struct *user);
+extern struct page *shmem_read_mapping_page_gfp(struct address_space *mapping,
+					pgoff_t index, gfp_t gfp_mask);
 extern void shmem_truncate_range(struct inode *inode, loff_t start, loff_t end);
 extern int shmem_unuse(swp_entry_t entry, struct page *page);
 extern void mem_cgroup_get_shmem_target(struct inode *inode, pgoff_t pgoff,
 					struct page **pagep, swp_entry_t *ent);
 
+static inline struct page *shmem_read_mapping_page(
+				struct address_space *mapping, pgoff_t index)
+{
+	return shmem_read_mapping_page_gfp(mapping, index,
+					mapping_gfp_mask(mapping));
+}
+
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
