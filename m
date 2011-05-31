Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 30C666B0012
	for <linux-mm@kvack.org>; Mon, 30 May 2011 20:40:56 -0400 (EDT)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id p4V0eqkZ014594
	for <linux-mm@kvack.org>; Mon, 30 May 2011 17:40:53 -0700
Received: from pwi15 (pwi15.prod.google.com [10.241.219.15])
	by kpbe11.cbf.corp.google.com with ESMTP id p4V0eotR018357
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 30 May 2011 17:40:51 -0700
Received: by pwi15 with SMTP id 15so2458977pwi.33
        for <linux-mm@kvack.org>; Mon, 30 May 2011 17:40:50 -0700 (PDT)
Date: Mon, 30 May 2011 17:40:51 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 4/14] tmpfs: add shmem_read_mapping_page_gfp
In-Reply-To: <alpine.LSU.2.00.1105301726180.5482@sister.anvils>
Message-ID: <alpine.LSU.2.00.1105301739080.5482@sister.anvils>
References: <alpine.LSU.2.00.1105301726180.5482@sister.anvils>
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
Provide now a shmem_read_mapping_page_gfp() ready for that transition,
and a shmem_read_mapping_page() inline for its common mapping_gfp case.

(shmem_read_mapping_page_gfp or shmem_read_cache_page_gfp?  Generally
the read_mapping_page functions use the mapping's ->readpage, and the
read_cache_page functions use the supplied filler, so I think
read_cache_page_gfp was slightly misnamed.)

Tidy up the nearby declarations in pagemap.h.

Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: Christoph Hellwig <hch@infradead.org>
---
 include/linux/pagemap.h |   22 +++++++++++++++-------
 mm/shmem.c              |   23 +++++++++++++++++++++++
 2 files changed, 38 insertions(+), 7 deletions(-)

--- linux.orig/include/linux/pagemap.h	2011-05-30 13:56:10.212797101 -0700
+++ linux/include/linux/pagemap.h	2011-05-30 14:25:32.665536626 -0700
@@ -255,31 +255,39 @@ static inline struct page *grab_cache_pa
 extern struct page * grab_cache_page_nowait(struct address_space *mapping,
 				pgoff_t index);
 extern struct page * read_cache_page_async(struct address_space *mapping,
-				pgoff_t index, filler_t *filler,
-				void *data);
+				pgoff_t index, filler_t *filler, void *data);
 extern struct page * read_cache_page(struct address_space *mapping,
-				pgoff_t index, filler_t *filler,
-				void *data);
+				pgoff_t index, filler_t *filler, void *data);
 extern struct page * read_cache_page_gfp(struct address_space *mapping,
 				pgoff_t index, gfp_t gfp_mask);
 extern int read_cache_pages(struct address_space *mapping,
 		struct list_head *pages, filler_t *filler, void *data);
 
 static inline struct page *read_mapping_page_async(
-						struct address_space *mapping,
-						     pgoff_t index, void *data)
+				struct address_space *mapping,
+				pgoff_t index, void *data)
 {
 	filler_t *filler = (filler_t *)mapping->a_ops->readpage;
 	return read_cache_page_async(mapping, index, filler, data);
 }
 
 static inline struct page *read_mapping_page(struct address_space *mapping,
-					     pgoff_t index, void *data)
+				pgoff_t index, void *data)
 {
 	filler_t *filler = (filler_t *)mapping->a_ops->readpage;
 	return read_cache_page(mapping, index, filler, data);
 }
 
+extern struct page *shmem_read_mapping_page_gfp(struct address_space *mapping,
+				pgoff_t index, gfp_t gfp_mask);
+
+static inline struct page *shmem_read_mapping_page(
+				struct address_space *mapping, pgoff_t index)
+{
+	return shmem_read_mapping_page_gfp(mapping, index,
+				mapping_gfp_mask(mapping));
+}
+
 /*
  * Return byte-offset into filesystem object for page.
  */
--- linux.orig/mm/shmem.c	2011-05-30 14:13:03.569821995 -0700
+++ linux/mm/shmem.c	2011-05-30 14:25:32.665536626 -0700
@@ -3028,3 +3028,26 @@ int shmem_zero_setup(struct vm_area_stru
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
