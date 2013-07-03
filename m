Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 92A266B0038
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 04:35:20 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC PATCH 5/5] readhead: support multiple pages allocation for readahead
Date: Wed,  3 Jul 2013 17:34:20 +0900
Message-Id: <1372840460-5571-6-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1372840460-5571-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1372840460-5571-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index e3dea75..eb1472c 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -217,28 +217,33 @@ static inline void page_unfreeze_refs(struct page *page, int count)
 }
 
 #ifdef CONFIG_NUMA
-extern struct page *__page_cache_alloc(gfp_t gfp);
+extern struct page *__page_cache_alloc(gfp_t gfp,
+			unsigned long *nr_pages, struct page **pages);
 #else
-static inline struct page *__page_cache_alloc(gfp_t gfp)
+static inline struct page *__page_cache_alloc(gfp_t gfp,
+			unsigned long *nr_pages, struct page **pages)
 {
-	return alloc_pages(gfp, 0);
+	return alloc_pages_exact_node_multiple(numa_node_id(),
+						gfp, nr_pages, pages);
 }
 #endif
 
 static inline struct page *page_cache_alloc(struct address_space *x)
 {
-	return __page_cache_alloc(mapping_gfp_mask(x));
+	return __page_cache_alloc(mapping_gfp_mask(x), NULL, NULL);
 }
 
 static inline struct page *page_cache_alloc_cold(struct address_space *x)
 {
-	return __page_cache_alloc(mapping_gfp_mask(x)|__GFP_COLD);
+	return __page_cache_alloc(mapping_gfp_mask(x)|__GFP_COLD, NULL, NULL);
 }
 
-static inline struct page *page_cache_alloc_readahead(struct address_space *x)
+static inline struct page *page_cache_alloc_readahead(struct address_space *x,
+				unsigned long *nr_pages, struct page **pages)
 {
 	return __page_cache_alloc(mapping_gfp_mask(x) |
-				  __GFP_COLD | __GFP_NORETRY | __GFP_NOWARN);
+				  __GFP_COLD | __GFP_NORETRY | __GFP_NOWARN,
+				  nr_pages, pages);
 }
 
 typedef int filler_t(void *, struct page *);
diff --git a/mm/filemap.c b/mm/filemap.c
index 7905fe7..0bbfda9 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -510,7 +510,8 @@ int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
 EXPORT_SYMBOL_GPL(add_to_page_cache_lru);
 
 #ifdef CONFIG_NUMA
-struct page *__page_cache_alloc(gfp_t gfp)
+struct page *__page_cache_alloc(gfp_t gfp,
+			unsigned long *nr_pages, struct page **pages)
 {
 	int n;
 	struct page *page;
@@ -520,12 +521,14 @@ struct page *__page_cache_alloc(gfp_t gfp)
 		do {
 			cpuset_mems_cookie = get_mems_allowed();
 			n = cpuset_mem_spread_node();
-			page = alloc_pages_exact_node(n, gfp, 0);
+			page = alloc_pages_exact_node_multiple(n,
+						gfp, nr_pages, pages);
 		} while (!put_mems_allowed(cpuset_mems_cookie) && !page);
 
 		return page;
 	}
-	return alloc_pages(gfp, 0);
+	return alloc_pages_exact_node_multiple(numa_node_id(), gfp,
+							nr_pages, pages);
 }
 EXPORT_SYMBOL(__page_cache_alloc);
 #endif
@@ -789,7 +792,7 @@ struct page *find_or_create_page(struct address_space *mapping,
 repeat:
 	page = find_lock_page(mapping, index);
 	if (!page) {
-		page = __page_cache_alloc(gfp_mask);
+		page = __page_cache_alloc(gfp_mask, NULL, NULL);
 		if (!page)
 			return NULL;
 		/*
@@ -1053,7 +1056,8 @@ grab_cache_page_nowait(struct address_space *mapping, pgoff_t index)
 		page_cache_release(page);
 		return NULL;
 	}
-	page = __page_cache_alloc(mapping_gfp_mask(mapping) & ~__GFP_FS);
+	page = __page_cache_alloc(mapping_gfp_mask(mapping) & ~__GFP_FS,
+								NULL, NULL);
 	if (page && add_to_page_cache_lru(page, mapping, index, GFP_NOFS)) {
 		page_cache_release(page);
 		page = NULL;
@@ -1806,7 +1810,7 @@ static struct page *__read_cache_page(struct address_space *mapping,
 repeat:
 	page = find_get_page(mapping, index);
 	if (!page) {
-		page = __page_cache_alloc(gfp | __GFP_COLD);
+		page = __page_cache_alloc(gfp | __GFP_COLD, NULL, NULL);
 		if (!page)
 			return ERR_PTR(-ENOMEM);
 		err = add_to_page_cache_lru(page, mapping, index, gfp);
@@ -2281,7 +2285,7 @@ repeat:
 	if (page)
 		goto found;
 
-	page = __page_cache_alloc(gfp_mask & ~gfp_notmask);
+	page = __page_cache_alloc(gfp_mask & ~gfp_notmask, NULL, NULL);
 	if (!page)
 		return NULL;
 	status = add_to_page_cache_lru(page, mapping, index,
diff --git a/mm/readahead.c b/mm/readahead.c
index 3932f28..3e2c377 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -157,40 +157,61 @@ __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 	struct inode *inode = mapping->host;
 	struct page *page;
 	unsigned long end_index;	/* The last page we want to read */
+	unsigned long end, i;
 	LIST_HEAD(page_pool);
 	int page_idx;
 	int ret = 0;
 	loff_t isize = i_size_read(inode);
+	struct page **pages;
 
 	if (isize == 0)
 		goto out;
 
 	end_index = ((isize - 1) >> PAGE_CACHE_SHIFT);
+	if (offset > end_index)
+		goto out;
+
 	if (offset + nr_to_read > end_index + 1)
 		nr_to_read = end_index - offset + 1;
 
+	pages = kmalloc(sizeof(struct page *) * nr_to_read, GFP_KERNEL);
+	if (!pages)
+		goto out;
+
 	/*
 	 * Preallocate as many pages as we will need.
 	 */
 	for (page_idx = 0; page_idx < nr_to_read; page_idx++) {
 		pgoff_t page_offset = offset + page_idx;
+		unsigned long nr_pages;
 
 		rcu_read_lock();
-		page = radix_tree_lookup(&mapping->page_tree, page_offset);
+		end = radix_tree_next_present(&mapping->page_tree,
+				page_offset, nr_to_read - page_idx);
 		rcu_read_unlock();
-		if (page)
+		nr_pages = end - page_offset;
+		if (!nr_pages)
 			continue;
 
-		page = page_cache_alloc_readahead(mapping);
-		if (!page)
-			break;
-		page->index = page_offset;
-		list_add(&page->lru, &page_pool);
-		if (page_idx == nr_to_read - lookahead_size)
-			SetPageReadahead(page);
-		ret++;
+		page_cache_alloc_readahead(mapping, &nr_pages, pages);
+		if (!nr_pages)
+			goto start_io;
+
+		for (i = 0; i < nr_pages; i++) {
+			page = pages[i];
+			page->index = page_offset + i;
+			list_add(&page->lru, &page_pool);
+			if (page_idx == nr_to_read - lookahead_size)
+				SetPageReadahead(page);
+			ret++;
+		}
+
+		/* Skip already checked page */
+		page_idx += nr_pages;
 	}
 
+start_io:
+	kfree(pages);
 	/*
 	 * Now start the IO.  We ignore I/O errors - if the page is not
 	 * uptodate then the caller will launch readpage again, and
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
