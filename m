Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id EE89C6B003D
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 04:43:32 -0400 (EDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MSC00FVQ5K8X990@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 30 Aug 2013 09:43:31 +0100 (BST)
From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Subject: [RFC PATCH 4/4] mm: migrate zbud pages
Date: Fri, 30 Aug 2013 10:42:56 +0200
Message-id: <1377852176-30970-5-git-send-email-k.kozlowski@samsung.com>
In-reply-to: <1377852176-30970-1-git-send-email-k.kozlowski@samsung.com>
References: <1377852176-30970-1-git-send-email-k.kozlowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Bob Liu <bob.liu@oracle.com>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Dave Hansen <dave.hansen@intel.com>, Minchan Kim <minchan@kernel.org>, Krzysztof Kozlowski <k.kozlowski@samsung.com>

Add migration support for zbud. This allows adding __GFP_MOVABLE flag
when allocating zbud pages and effectively CMA pool can be used for
zswap.

zbud pages are not movable and are not stored under any LRU (except
zbud's LRU). PageZbud flag is used in isolate_migratepages_range() to
grab zbud pages and pass them later for migration.

page->private field is used for storing pointer to zbud_pool.
The zbud_pool is needed during migration for locking the pool and
accessing radix tree.

The zbud migration code utilizes mapping so many exceptions to migrate
code was added. It can be replaced for example with pin page control
subsystem:
http://article.gmane.org/gmane.linux.kernel.mm/105308
In such case the zbud migration code (zbud_migrate_page()) can be safely
re-used.

Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>
---
 include/linux/zbud.h |    1 +
 mm/compaction.c      |    7 +++
 mm/migrate.c         |   17 +++++-
 mm/zbud.c            |  164 +++++++++++++++++++++++++++++++++++++++++++++++---
 mm/zswap.c           |    4 +-
 5 files changed, 179 insertions(+), 14 deletions(-)

diff --git a/include/linux/zbud.h b/include/linux/zbud.h
index 12d72df..3bc2e38 100644
--- a/include/linux/zbud.h
+++ b/include/linux/zbud.h
@@ -11,6 +11,7 @@ struct zbud_ops {
 
 struct zbud_pool *zbud_create_pool(gfp_t gfp, struct zbud_ops *ops);
 void zbud_destroy_pool(struct zbud_pool *pool);
+int zbud_put_page(struct page *page);
 int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
 	unsigned long *handle);
 void zbud_free(struct zbud_pool *pool, unsigned long handle);
diff --git a/mm/compaction.c b/mm/compaction.c
index 05ccb4c..8acd198 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -534,6 +534,12 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 			goto next_pageblock;
 		}
 
+		if (PageZbud(page)) {
+			BUG_ON(PageLRU(page));
+			get_page(page);
+			goto isolated;
+		}
+
 		/*
 		 * Check may be lockless but that's ok as we recheck later.
 		 * It's possible to migrate LRU pages and balloon pages
@@ -601,6 +607,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 		/* Successfully isolated */
 		cc->finished_update_migrate = true;
 		del_page_from_lru_list(page, lruvec, page_lru(page));
+isolated:
 		list_add(&page->lru, migratelist);
 		cc->nr_migratepages++;
 		nr_isolated++;
diff --git a/mm/migrate.c b/mm/migrate.c
index 6f0c244..5254eb2 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -36,6 +36,7 @@
 #include <linux/hugetlb_cgroup.h>
 #include <linux/gfp.h>
 #include <linux/balloon_compaction.h>
+#include <linux/zbud.h>
 
 #include <asm/tlbflush.h>
 
@@ -105,6 +106,8 @@ void putback_movable_pages(struct list_head *l)
 				page_is_file_cache(page));
 		if (unlikely(balloon_page_movable(page)))
 			balloon_page_putback(page);
+		else if (unlikely(PageZbud(page)))
+			zbud_put_page(page);
 		else
 			putback_lru_page(page);
 	}
@@ -832,6 +835,10 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 		goto skip_unmap;
 	}
 
+	if (unlikely(PageZbud(page))) {
+		remap_swapcache = 0;
+		goto skip_unmap;
+	}
 	/* Establish migration ptes or remove ptes */
 	try_to_unmap(page, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
 
@@ -902,13 +909,19 @@ out:
 		list_del(&page->lru);
 		dec_zone_page_state(page, NR_ISOLATED_ANON +
 				page_is_file_cache(page));
-		putback_lru_page(page);
+		if (unlikely(PageZbud(page)))
+			zbud_put_page(page);
+		else
+			putback_lru_page(page);
 	}
 	/*
 	 * Move the new page to the LRU. If migration was not successful
 	 * then this will free the page.
 	 */
-	putback_lru_page(newpage);
+	if (unlikely(PageZbud(newpage)))
+		zbud_put_page(newpage);
+	else
+		putback_lru_page(newpage);
 	if (result) {
 		if (rc)
 			*result = rc;
diff --git a/mm/zbud.c b/mm/zbud.c
index 5ff4ffa..63f0a91 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -51,6 +51,8 @@
 #include <linux/slab.h>
 #include <linux/spinlock.h>
 #include <linux/radix-tree.h>
+#include <linux/fs.h>
+#include <linux/pagemap.h>
 #include <linux/zbud.h>
 
 /*****************
@@ -211,17 +213,9 @@ static void get_zbud_page(struct zbud_header *zhdr)
  *
  * Returns 1 if page was freed and 0 otherwise.
  */
-static int put_zbud_page(struct zbud_header *zhdr)
+static inline int put_zbud_page(struct zbud_header *zhdr)
 {
-	struct page *page = virt_to_page(zhdr);
-	VM_BUG_ON(!PageZbud(page));
-
-	if (put_page_testzero(page)) {
-		ClearPageZbud(page);
-		free_hot_cold_page(page, 0);
-		return 1;
-	}
-	return 0;
+	return zbud_put_page(virt_to_page(zhdr));
 }
 
 /*
@@ -261,6 +255,27 @@ static int put_map_count(struct zbud_header *zhdr, unsigned long handle)
 }
 
 /*
+ * Replaces item expected in radix tree by a new item, while holding pool lock.
+ */
+static int tree_replace(struct zbud_pool *pool,
+			unsigned long handle, void *expected, void *replacement)
+{
+	void **pslot;
+	void *item = NULL;
+
+	VM_BUG_ON(!expected);
+	VM_BUG_ON(!replacement);
+	pslot = radix_tree_lookup_slot(&pool->page_tree, handle);
+	if (pslot)
+		item = radix_tree_deref_slot_protected(pslot,
+							&pool->lock);
+	if (item != expected)
+		return -ENOENT;
+	radix_tree_replace_slot(pslot, replacement);
+	return 0;
+}
+
+/*
  * Searches for zbud header in radix tree.
  * Returns NULL if handle could not be found.
  *
@@ -328,6 +343,110 @@ static int tree_insert_zbud_header(struct zbud_pool *pool,
 	return radix_tree_insert(&pool->page_tree, *handle, zhdr);
 }
 
+/*
+ * Copy page during migration.
+ *
+ * Must be called under pool->lock.
+ */
+static void copy_zbud_page(struct page *newpage, struct page *page)
+{
+	void *to, *from;
+	SetPageZbud(newpage);
+	newpage->mapping = page->mapping;
+	set_page_private(newpage, page_private(page));
+	/* copy data */
+	to = kmap_atomic(newpage);
+	from = kmap_atomic(page);
+	memcpy(to, from, PAGE_SIZE);
+	kunmap_atomic(from);
+	kunmap_atomic(to);
+}
+
+/*
+ * Replaces old zbud header in radix tree with new, updates page
+ * count (puts old, gets new) and puts map_count for old page.
+ *
+ * The map_count for new page is not increased because it was already
+ * copied by copy_zbud_page().
+ *
+ * Must be called under pool->lock.
+ */
+static void replace_page_handles(struct zbud_pool *pool,
+		struct zbud_header *zhdr, struct zbud_header *newzhdr)
+{
+	if (zhdr->first_handle) {
+		int ret = tree_replace(pool, zhdr->first_handle, zhdr,
+				newzhdr);
+		VM_BUG_ON(ret);
+		get_zbud_page(newzhdr);
+		/* get_map_count() skipped, already copied */
+		put_map_count(zhdr, zhdr->first_handle);
+		put_zbud_page(zhdr);
+	}
+	if (zhdr->last_handle) {
+		int ret = tree_replace(pool, zhdr->last_handle, zhdr,
+				newzhdr);
+		VM_BUG_ON(ret);
+		get_zbud_page(newzhdr);
+		/* get_map_count() skipped, already copied */
+		put_map_count(zhdr, zhdr->last_handle);
+		put_zbud_page(zhdr);
+	}
+}
+
+
+/*
+ * Migrates zbud page.
+ * Returns 0 on success or -EAGAIN if page was dirtied by zbud_map during
+ * migration.
+ */
+static int zbud_migrate_page(struct address_space *mapping,
+		struct page *newpage, struct page *page,
+		enum migrate_mode mode)
+{
+	int rc = 0;
+	struct zbud_header *zhdr, *newzhdr;
+	struct zbud_pool *pool;
+	int expected_cnt = 1; /* one page reference from isolate */
+
+	VM_BUG_ON(!PageLocked(page));
+	zhdr = page_address(page);
+	newzhdr = page_address(newpage);
+	pool = (struct zbud_pool *)page_private(page);
+	VM_BUG_ON(!pool);
+
+	spin_lock(&pool->lock);
+	if (zhdr->first_handle)
+		expected_cnt++;
+	if (zhdr->last_handle)
+		expected_cnt++;
+
+	if (page_count(page) != expected_cnt) {
+		/* Still used by someone (paraller compaction) or dirtied
+		 * by zbud_map() before we acquired spin_lock. */
+		rc = -EAGAIN;
+		goto out;
+	}
+	copy_zbud_page(newpage, page);
+	replace_page_handles(pool, zhdr, newzhdr);
+	/* Update lists */
+	list_replace(&zhdr->lru, &newzhdr->lru);
+	list_replace(&zhdr->buddy, &newzhdr->buddy);
+	memset(zhdr, 0, sizeof(struct zbud_header));
+
+out:
+	spin_unlock(&pool->lock);
+	return rc;
+}
+
+static const struct address_space_operations zbud_aops = {
+	.migratepage	= zbud_migrate_page,
+};
+const struct address_space zbud_space = {
+	.a_ops		= &zbud_aops,
+};
+EXPORT_SYMBOL_GPL(zbud_space);
+
 /*****************
  * API Functions
 *****************/
@@ -370,6 +489,29 @@ void zbud_destroy_pool(struct zbud_pool *pool)
 	kfree(pool);
 }
 
+/*
+ * zbud_put_page() - decreases ref count for zbud page
+ * @page:	zbud page to put
+ *
+ * Page is freed if reference count reaches 0.
+ *
+ * Returns 1 if page was freed and 0 otherwise.
+ */
+int zbud_put_page(struct page *page)
+{
+	VM_BUG_ON(!PageZbud(page));
+
+	if (put_page_testzero(page)) {
+		VM_BUG_ON(PageLocked(page));
+		page->mapping = NULL;
+		set_page_private(page, 0);
+		ClearPageZbud(page);
+		free_hot_cold_page(page, 0);
+		return 1;
+	}
+	return 0;
+}
+
 /**
  * zbud_alloc() - allocates a region of a given size
  * @pool:	zbud pool from which to allocate
@@ -439,6 +581,8 @@ int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
 	 */
 	zhdr = init_zbud_page(page);
 	SetPageZbud(page);
+	page->mapping = (struct address_space *)&zbud_space;
+	set_page_private(page, (unsigned long)pool);
 	bud = FIRST;
 
 	err = tree_insert_zbud_header(pool, zhdr, &next_handle);
diff --git a/mm/zswap.c b/mm/zswap.c
index 706046a..ac8b768 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -665,8 +665,8 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 
 	/* store */
 	len = dlen + sizeof(struct zswap_header);
-	ret = zbud_alloc(tree->pool, len, __GFP_NORETRY | __GFP_NOWARN,
-		&handle);
+	ret = zbud_alloc(tree->pool, len,
+			__GFP_NORETRY | __GFP_NOWARN | __GFP_MOVABLE, &handle);
 	if (ret == -ENOSPC) {
 		zswap_reject_compress_poor++;
 		goto freepage;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
