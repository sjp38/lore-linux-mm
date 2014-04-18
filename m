Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8CE766B0062
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 10:50:52 -0400 (EDT)
Received: by mail-ee0-f44.google.com with SMTP id e49so1718920eek.3
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 07:50:52 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p8si40591802eew.156.2014.04.18.07.50.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 07:50:51 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 15/16] mm: Non-atomically mark page accessed in write_begin where possible
Date: Fri, 18 Apr 2014 15:50:42 +0100
Message-Id: <1397832643-14275-16-git-send-email-mgorman@suse.de>
In-Reply-To: <1397832643-14275-1-git-send-email-mgorman@suse.de>
References: <1397832643-14275-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Linux-FSDevel <linux-fsdevel@vger.kernel.org>

aops->write_begin may allocate a new page and make it visible just to
have mark_page_accessed called almost immediately after. Once it's visible
atomic operations are necessary which is noticable overhead when writing
to an in-memory filesystem like tmpfs but should also be noticable with
fast storage.

The bulk of filesystems directly or indirectly use
grab_cache_page_write_begin or find_or_create_page for the initial allocation
of a page cache page. This patch adds an init_page_accessed() helper which
behaves like the first call to mark_page_accessed() but may called before
the page is visible and can be done non-atomically.

In this patch, new allocations in grab_cache_page_write_begin() or
find_or_create_page() use init_page_accessed() and existing pages use
mark_page_accessed().

This places a burden because filesystems need to ensure they either use these
helpers or update the helpers they do use to call init_page_accessed()
or mark_page_accessed() as appropriate. There is also a snag in that
the timing of the mark_page_accessed() has now changed so in rare cases
it's possible a page gets to the end of the LRU as PageReferenced where
as previously it might have been repromoted. This is expected to be rare
but it's worth the filesystem people thinking about it in case they see
a problem with the timing change.

In a profiled run measuring dd to tmpfs the overhead of mark_page_accessed was

25142     0.7055  vmlinux-3.15.0-rc1-vanilla vmlinux-3.15.0-rc1-vanilla shmem_write_end
107830    3.0256  vmlinux-3.15.0-rc1-vanilla vmlinux-3.15.0-rc1-vanilla mark_page_accessed

3.73% overall. With the patch applied, it becomes

118185    3.1712  vmlinux-3.15.0-rc1-microopt-v1r11 vmlinux-3.15.0-rc1-microopt-v1r11 shmem_write_end
2395      0.0643  vmlinux-3.15.0-rc1-microopt-v1r11 vmlinux-3.15.0-rc1-microopt-v1r11 init_page_accessed
159       0.0043  vmlinux-3.15.0-rc1-microopt-v1r11 vmlinux-3.15.0-rc1-microopt-v1r11 mark_page_accessed

3.23% overall. shmem_write_end increases in apparent cost because the
SetPageUptodate is now to a cache line that mark_page_accessed had not
dirtied for it. Even with that taken into account, it's still fewer
atomic operations overall.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/page-flags.h |  1 +
 include/linux/swap.h       |  1 +
 mm/filemap.c               | 55 +++++++++++++++++++++++++++-------------------
 mm/shmem.c                 |  6 ++++-
 mm/swap.c                  | 11 ++++++++++
 5 files changed, 51 insertions(+), 23 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 4d4b39a..2093eb7 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -198,6 +198,7 @@ struct page;	/* forward declaration */
 TESTPAGEFLAG(Locked, locked)
 PAGEFLAG(Error, error) TESTCLEARFLAG(Error, error)
 PAGEFLAG(Referenced, referenced) TESTCLEARFLAG(Referenced, referenced)
+	__SETPAGEFLAG(Referenced, referenced)
 PAGEFLAG(Dirty, dirty) TESTSCFLAG(Dirty, dirty) __CLEARPAGEFLAG(Dirty, dirty)
 PAGEFLAG(LRU, lru) __CLEARPAGEFLAG(LRU, lru)
 PAGEFLAG(Active, active) __CLEARPAGEFLAG(Active, active)
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 4a9ac85..e54312d 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -314,6 +314,7 @@ extern void lru_add_page_tail(struct page *page, struct page *page_tail,
 			 struct lruvec *lruvec, struct list_head *head);
 extern void activate_page(struct page *);
 extern void mark_page_accessed(struct page *);
+extern void init_page_accessed(struct page *page);
 extern void lru_add_drain(void);
 extern void lru_add_drain_cpu(int cpu);
 extern void lru_add_drain_all(void);
diff --git a/mm/filemap.c b/mm/filemap.c
index a82fbe4..c28f69c 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1059,24 +1059,31 @@ struct page *find_or_create_page(struct address_space *mapping,
 	int err;
 repeat:
 	page = find_lock_page(mapping, index);
-	if (!page) {
-		page = __page_cache_alloc(gfp_mask);
-		if (!page)
-			return NULL;
-		/*
-		 * We want a regular kernel memory (not highmem or DMA etc)
-		 * allocation for the radix tree nodes, but we need to honour
-		 * the context-specific requirements the caller has asked for.
-		 * GFP_RECLAIM_MASK collects those requirements.
-		 */
-		err = add_to_page_cache_lru(page, mapping, index,
-			(gfp_mask & GFP_RECLAIM_MASK));
-		if (unlikely(err)) {
-			page_cache_release(page);
-			page = NULL;
-			if (err == -EEXIST)
-				goto repeat;
-		}
+	if (page) {
+		mark_page_accessed(page);
+		return page;
+	}
+
+	page = __page_cache_alloc(gfp_mask);
+	if (!page)
+		return NULL;
+
+	/* Init accessed so avoit atomic mark_page_accessed later */
+	init_page_accessed(page);
+
+	/*
+	 * We want a regular kernel memory (not highmem or DMA etc)
+	 * allocation for the radix tree nodes, but we need to honour
+	 * the context-specific requirements the caller has asked for.
+	 * GFP_RECLAIM_MASK collects those requirements.
+	 */
+	err = add_to_page_cache_lru(page, mapping, index,
+		(gfp_mask & GFP_RECLAIM_MASK));
+	if (unlikely(err)) {
+		page_cache_release(page);
+		page = NULL;
+		if (err == -EEXIST)
+			goto repeat;
 	}
 	return page;
 }
@@ -2372,7 +2379,6 @@ int pagecache_write_end(struct file *file, struct address_space *mapping,
 {
 	const struct address_space_operations *aops = mapping->a_ops;
 
-	mark_page_accessed(page);
 	return aops->write_end(file, mapping, pos, len, copied, page, fsdata);
 }
 EXPORT_SYMBOL(pagecache_write_end);
@@ -2466,12 +2472,18 @@ struct page *grab_cache_page_write_begin(struct address_space *mapping,
 		gfp_notmask = __GFP_FS;
 repeat:
 	page = find_lock_page(mapping, index);
-	if (page)
+	if (page) {
+		mark_page_accessed(page);
 		goto found;
+	}
 
 	page = __page_cache_alloc(gfp_mask & ~gfp_notmask);
 	if (!page)
 		return NULL;
+
+	/* Init accessed so avoit atomic mark_page_accessed later */
+	init_page_accessed(page);
+
 	status = add_to_page_cache_lru(page, mapping, index,
 						GFP_KERNEL & ~gfp_notmask);
 	if (unlikely(status)) {
@@ -2530,7 +2542,7 @@ again:
 
 		status = a_ops->write_begin(file, mapping, pos, bytes, flags,
 						&page, &fsdata);
-		if (unlikely(status))
+		if (unlikely(status < 0))
 			break;
 
 		if (mapping_writably_mapped(mapping))
@@ -2539,7 +2551,6 @@ again:
 		copied = iov_iter_copy_from_user_atomic(page, i, offset, bytes);
 		flush_dcache_page(page);
 
-		mark_page_accessed(page);
 		status = a_ops->write_end(file, mapping, pos, bytes, copied,
 						page, fsdata);
 		if (unlikely(status < 0))
diff --git a/mm/shmem.c b/mm/shmem.c
index f47fb38..700a4ad 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1372,9 +1372,13 @@ shmem_write_begin(struct file *file, struct address_space *mapping,
 			loff_t pos, unsigned len, unsigned flags,
 			struct page **pagep, void **fsdata)
 {
+	int ret;
 	struct inode *inode = mapping->host;
 	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
-	return shmem_getpage(inode, index, pagep, SGP_WRITE, NULL);
+	ret = shmem_getpage(inode, index, pagep, SGP_WRITE, NULL);
+	if (*pagep)
+		init_page_accessed(*pagep);
+	return ret;
 }
 
 static int
diff --git a/mm/swap.c b/mm/swap.c
index fed4caf..2490dfe 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -583,6 +583,17 @@ void mark_page_accessed(struct page *page)
 EXPORT_SYMBOL(mark_page_accessed);
 
 /*
+ * Used to mark_page_accessed(page) that is not visible yet and when it is
+ * still safe to use non-atomic ops
+ */
+void init_page_accessed(struct page *page)
+{
+	if (!PageReferenced(page))
+		__SetPageReferenced(page);
+}
+EXPORT_SYMBOL(init_page_accessed);
+
+/*
  * Queue the page for addition to the LRU via pagevec. The decision on whether
  * to add the page to the [in]active [file|anon] list is deferred until the
  * pagevec is drained. This gives a chance for the caller of __lru_cache_add()
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
