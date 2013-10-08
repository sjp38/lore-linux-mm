Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id E08E36B0044
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 09:30:14 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id g10so8639521pdj.30
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 06:30:14 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MUC00EXPQT6AJ20@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 08 Oct 2013 14:30:08 +0100 (BST)
From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Subject: [PATCH v3 6/6] mm: migrate zbud pages
Date: Tue, 08 Oct 2013 15:29:40 +0200
Message-id: <1381238980-2491-7-git-send-email-k.kozlowski@samsung.com>
In-reply-to: <1381238980-2491-1-git-send-email-k.kozlowski@samsung.com>
References: <1381238980-2491-1-git-send-email-k.kozlowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Bob Liu <bob.liu@oracle.com>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Tomasz Stanislawski <t.stanislaws@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Dave Hansen <dave.hansen@intel.com>, Minchan Kim <minchan@kernel.org>, Krzysztof Kozlowski <k.kozlowski@samsung.com>

Add migration support for zbud. This allows adding __GFP_MOVABLE flag
when allocating zbud pages and effectively CMA pool can be used for
zswap.

zbud pages are not movable and are not stored under any LRU (except
zbud's LRU). PageZbud flag is used in isolate_migratepages_range() to
grab zbud pages and pass them later for migration.

page->private field is used for storing pointer to zbud_pool.
This pointer to zbud_pool is needed during migration for locking the
pool and accessing radix tree.

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
 mm/migrate.c         |   17 ++++-
 mm/zbud.c            |  168 +++++++++++++++++++++++++++++++++++++++++++++++---
 mm/zswap.c           |    4 +-
 5 files changed, 183 insertions(+), 14 deletions(-)

diff --git a/include/linux/zbud.h b/include/linux/zbud.h
index c4e091a..2ac00da 100644
--- a/include/linux/zbud.h
+++ b/include/linux/zbud.h
@@ -23,6 +23,7 @@ struct zbud_mapped_entry {
 
 struct zbud_pool *zbud_create_pool(gfp_t gfp, struct zbud_ops *ops);
 void zbud_destroy_pool(struct zbud_pool *pool);
+int zbud_put_page(struct page *page);
 int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
 	pgoff_t offset);
 int zbud_free(struct zbud_pool *pool, pgoff_t offset);
diff --git a/mm/compaction.c b/mm/compaction.c
index b5326b1..1806a0b 100644
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
index a26bccd..40e9ae4 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -36,6 +36,7 @@
 #include <linux/hugetlb_cgroup.h>
 #include <linux/gfp.h>
 #include <linux/balloon_compaction.h>
+#include <linux/zbud.h>
 
 #include <asm/tlbflush.h>
 
@@ -109,6 +110,8 @@ void putback_movable_pages(struct list_head *l)
 				page_is_file_cache(page));
 		if (unlikely(isolated_balloon_page(page)))
 			balloon_page_putback(page);
+		else if (unlikely(PageZbud(page)))
+			zbud_put_page(page);
 		else
 			putback_lru_page(page);
 	}
@@ -836,6 +839,10 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 		goto skip_unmap;
 	}
 
+	if (unlikely(PageZbud(page))) {
+		remap_swapcache = 0;
+		goto skip_unmap;
+	}
 	/* Establish migration ptes or remove ptes */
 	try_to_unmap(page, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
 
@@ -906,13 +913,19 @@ out:
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
index 1b2496e..7c07683 100644
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
@@ -202,17 +204,9 @@ static void get_zbud_page(struct zbud_header *zhdr)
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
@@ -252,6 +246,31 @@ static int put_map_count(struct zbud_header *zhdr, pgoff_t offset)
 }
 
 /*
+ * Replaces item expected in radix tree by a new item.
+ *
+ * Must be called under pool->lock.
+ *
+ * Returns 0 on success and -ENOENT if no item could be found.
+ */
+static int tree_replace(struct zbud_pool *pool,
+			pgoff_t offset, void *expected, void *replacement)
+{
+	void **pslot;
+	void *item = NULL;
+
+	VM_BUG_ON(!expected);
+	VM_BUG_ON(!replacement);
+	pslot = radix_tree_lookup_slot(&pool->tree, offset);
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
  * Returns NULL if offset could not be found.
  *
@@ -267,6 +286,110 @@ static inline struct zbud_header *offset_to_zbud_header(struct zbud_pool *pool,
 	return radix_tree_lookup(&pool->tree, offset);
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
+static void replace_page_in_tree(struct zbud_pool *pool,
+		struct zbud_header *zhdr, struct zbud_header *newzhdr)
+{
+	if (zhdr->first_offset) {
+		int ret = tree_replace(pool, zhdr->first_offset, zhdr,
+				newzhdr);
+		VM_BUG_ON(ret);
+		get_zbud_page(newzhdr);
+		/* get_map_count() skipped, already copied */
+		put_map_count(zhdr, zhdr->first_offset);
+		put_zbud_page(zhdr);
+	}
+	if (zhdr->last_offset) {
+		int ret = tree_replace(pool, zhdr->last_offset, zhdr,
+				newzhdr);
+		VM_BUG_ON(ret);
+		get_zbud_page(newzhdr);
+		/* get_map_count() skipped, already copied */
+		put_map_count(zhdr, zhdr->last_offset);
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
+	if (zhdr->first_offset)
+		expected_cnt++;
+	if (zhdr->last_offset)
+		expected_cnt++;
+
+	if (page_count(page) != expected_cnt) {
+		/* Still used by someone (paraller compaction) or dirtied
+		 * by zbud_map() before we acquired spin_lock. */
+		rc = -EAGAIN;
+		goto out;
+	}
+	copy_zbud_page(newpage, page);
+	replace_page_in_tree(pool, zhdr, newzhdr);
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
@@ -308,6 +431,29 @@ void zbud_destroy_pool(struct zbud_pool *pool)
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
@@ -377,6 +523,8 @@ int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
 	 */
 	zhdr = init_zbud_page(page);
 	SetPageZbud(page);
+	page->mapping = (struct address_space *)&zbud_space;
+	set_page_private(page, (unsigned long)pool);
 	bud = FIRST;
 
 	err = radix_tree_insert(&pool->tree, offset, zhdr);
diff --git a/mm/zswap.c b/mm/zswap.c
index abbe457..5db4bf7 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -460,8 +460,8 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 	}
 
 	/* store */
-	ret = zbud_alloc(pool, dlen, __GFP_NORETRY | __GFP_NOWARN,
-		offset);
+	ret = zbud_alloc(pool, dlen,
+		__GFP_NORETRY | __GFP_NOWARN | __GFP_MOVABLE, offset);
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
