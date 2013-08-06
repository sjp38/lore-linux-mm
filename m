Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id D0FE56B0038
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 02:43:13 -0400 (EDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MR300EBZJZ5FG30@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 06 Aug 2013 07:43:11 +0100 (BST)
From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Subject: [RFC PATCH 4/4] mm: reclaim zbud pages on migration and compaction
Date: Tue, 06 Aug 2013 08:42:41 +0200
Message-id: <1375771361-8388-5-git-send-email-k.kozlowski@samsung.com>
In-reply-to: <1375771361-8388-1-git-send-email-k.kozlowski@samsung.com>
References: <1375771361-8388-1-git-send-email-k.kozlowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Krzysztof Kozlowski <k.kozlowski@samsung.com>

Reclaim zbud pages during migration and compaction by unusing stored
data. This allows adding__GFP_RECLAIMABLE flag when allocating zbud
pages and effectively CMA pool can be used for zswap.

zbud pages are not movable and are not stored under any LRU (except
zbud's LRU). PageZbud flag is used in isolate_migratepages_range() to
grab zbud pages and pass them later for reclaim.

This reclaim process is different than zbud_reclaim_page(). It acts more
like swapoff() by trying to unuse pages stored in zbud page and bring
them back to memory. The standard zbud_reclaim_page() on the other hand
tries to write them back.

Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>
---
 include/linux/zbud.h |   11 +++-
 mm/compaction.c      |   20 ++++++-
 mm/internal.h        |    1 +
 mm/page_alloc.c      |    6 ++
 mm/zbud.c            |  163 +++++++++++++++++++++++++++++++++++++++-----------
 mm/zswap.c           |   57 ++++++++++++++++--
 6 files changed, 215 insertions(+), 43 deletions(-)

diff --git a/include/linux/zbud.h b/include/linux/zbud.h
index 2571a5c..57ee85d 100644
--- a/include/linux/zbud.h
+++ b/include/linux/zbud.h
@@ -5,8 +5,14 @@
 
 struct zbud_pool;
 
+/**
+ * Template for functions called during reclaim.
+ */
+typedef int (*evict_page_t)(struct zbud_pool *pool, unsigned long handle);
+
 struct zbud_ops {
-	int (*evict)(struct zbud_pool *pool, unsigned long handle);
+	evict_page_t evict; /* callback for zbud_reclaim_lru_page() */
+	evict_page_t unuse; /* callback for zbud_reclaim_pages() */
 };
 
 struct zbud_pool *zbud_create_pool(gfp_t gfp, struct zbud_ops *ops);
@@ -14,7 +20,8 @@ void zbud_destroy_pool(struct zbud_pool *pool);
 int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
 	unsigned long *handle);
 void zbud_free(struct zbud_pool *pool, unsigned long handle);
-int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries);
+int zbud_reclaim_lru_page(struct zbud_pool *pool, unsigned int retries);
+void zbud_reclaim_pages(struct list_head *zbud_pages);
 void *zbud_map(struct zbud_pool *pool, unsigned long handle);
 void zbud_unmap(struct zbud_pool *pool, unsigned long handle);
 u64 zbud_get_pool_size(struct zbud_pool *pool);
diff --git a/mm/compaction.c b/mm/compaction.c
index 05ccb4c..9bbf412 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -16,6 +16,7 @@
 #include <linux/sysfs.h>
 #include <linux/balloon_compaction.h>
 #include <linux/page-isolation.h>
+#include <linux/zbud.h>
 #include "internal.h"
 
 #ifdef CONFIG_COMPACTION
@@ -534,6 +535,17 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 			goto next_pageblock;
 		}
 
+		if (PageZbud(page)) {
+			/*
+			 * Zbud pages do not exist in LRU so we must
+			 * check for Zbud flag before PageLRU() below.
+			 */
+			BUG_ON(PageLRU(page));
+			get_page(page);
+			list_add(&page->lru, &cc->zbudpages);
+			continue;
+		}
+
 		/*
 		 * Check may be lockless but that's ok as we recheck later.
 		 * It's possible to migrate LRU pages and balloon pages
@@ -810,7 +822,10 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	low_pfn = isolate_migratepages_range(zone, cc, low_pfn, end_pfn, false);
 	if (!low_pfn || cc->contended)
 		return ISOLATE_ABORT;
-
+#ifdef CONFIG_ZBUD
+	if (!list_empty(&cc->zbudpages))
+		zbud_reclaim_pages(&cc->zbudpages);
+#endif
 	cc->migrate_pfn = low_pfn;
 
 	return ISOLATE_SUCCESS;
@@ -1023,11 +1038,13 @@ static unsigned long compact_zone_order(struct zone *zone,
 	};
 	INIT_LIST_HEAD(&cc.freepages);
 	INIT_LIST_HEAD(&cc.migratepages);
+	INIT_LIST_HEAD(&cc.zbudpages);
 
 	ret = compact_zone(zone, &cc);
 
 	VM_BUG_ON(!list_empty(&cc.freepages));
 	VM_BUG_ON(!list_empty(&cc.migratepages));
+	VM_BUG_ON(!list_empty(&cc.zbudpages));
 
 	*contended = cc.contended;
 	return ret;
@@ -1105,6 +1122,7 @@ static void __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
 		cc->zone = zone;
 		INIT_LIST_HEAD(&cc->freepages);
 		INIT_LIST_HEAD(&cc->migratepages);
+		INIT_LIST_HEAD(&cc->zbudpages);
 
 		if (cc->order == -1 || !compaction_deferred(zone, cc->order))
 			compact_zone(zone, cc);
diff --git a/mm/internal.h b/mm/internal.h
index 4390ac6..eaf5c884 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -119,6 +119,7 @@ struct compact_control {
 	unsigned long nr_migratepages;	/* Number of pages to migrate */
 	unsigned long free_pfn;		/* isolate_freepages search base */
 	unsigned long migrate_pfn;	/* isolate_migratepages search base */
+	struct list_head zbudpages;	/* List of pages belonging to zbud */
 	bool sync;			/* Synchronous migration */
 	bool ignore_skip_hint;		/* Scan blocks even if marked skip */
 	bool finished_update_free;	/* True when the zone cached pfns are
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1a120fb..e482876 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -60,6 +60,7 @@
 #include <linux/page-debug-flags.h>
 #include <linux/hugetlb.h>
 #include <linux/sched/rt.h>
+#include <linux/zbud.h>
 
 #include <asm/sections.h>
 #include <asm/tlbflush.h>
@@ -6031,6 +6032,10 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
 				ret = -EINTR;
 				break;
 			}
+#ifdef CONFIG_ZBUD
+			if (!list_empty(&cc.zbudpages))
+				zbud_reclaim_pages(&cc.zbudpages);
+#endif
 			tries = 0;
 		} else if (++tries == 5) {
 			ret = ret < 0 ? ret : -EBUSY;
@@ -6085,6 +6090,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 		.ignore_skip_hint = true,
 	};
 	INIT_LIST_HEAD(&cc.migratepages);
+	INIT_LIST_HEAD(&cc.zbudpages);
 
 	/*
 	 * What we do here is we mark all pageblocks in range as
diff --git a/mm/zbud.c b/mm/zbud.c
index a452949..98a04c8 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -103,12 +103,14 @@ struct zbud_pool {
  * @lru:	links the zbud page into the lru list in the pool
  * @first_chunks:	the size of the first buddy in chunks, 0 if free
  * @last_chunks:	the size of the last buddy in chunks, 0 if free
+ * @pool:		pool to which this zbud page belongs to
  */
 struct zbud_header {
 	struct list_head buddy;
 	struct list_head lru;
 	unsigned int first_chunks;
 	unsigned int last_chunks;
+	struct zbud_pool *pool;
 };
 
 /*****************
@@ -137,6 +139,7 @@ static struct zbud_header *init_zbud_page(struct page *page)
 	zhdr->last_chunks = 0;
 	INIT_LIST_HEAD(&zhdr->buddy);
 	INIT_LIST_HEAD(&zhdr->lru);
+	zhdr->pool = NULL;
 	return zhdr;
 }
 
@@ -241,7 +244,6 @@ static int put_zbud_page(struct zbud_pool *pool, struct zbud_header *zhdr)
 	return 0;
 }
 
-
 /*****************
  * API Functions
 *****************/
@@ -345,6 +347,7 @@ int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
 	 */
 	zhdr = init_zbud_page(page);
 	SetPageZbud(page);
+	zhdr->pool = pool;
 	bud = FIRST;
 
 found:
@@ -394,8 +397,57 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle)
 #define list_tail_entry(ptr, type, member) \
 	list_entry((ptr)->prev, type, member)
 
+/*
+ * Pool lock must be held when calling this function and at least
+ * one handle must not free.
+ * On return the pool lock will be still held however during the
+ * execution it will be unlocked and locked for the time of calling
+ * the evict callback.
+ *
+ * Returns 1 if page was freed here, 0 otherwise (still in use)
+ */
+static int do_reclaim(struct zbud_pool *pool, struct zbud_header *zhdr,
+				evict_page_t evict_cb)
+{
+	int ret;
+	unsigned long first_handle = 0, last_handle = 0;
+
+	BUG_ON(zhdr->first_chunks == 0 && zhdr->last_chunks == 0);
+	/* Move this last element to beginning of LRU */
+	list_del(&zhdr->lru);
+	list_add(&zhdr->lru, &pool->lru);
+	/* Protect zbud page against free */
+	get_zbud_page(zhdr);
+	/*
+	 * We need encode the handles before unlocking, since we can
+	 * race with free that will set (first|last)_chunks to 0
+	 */
+	first_handle = 0;
+	last_handle = 0;
+	if (zhdr->first_chunks)
+		first_handle = encode_handle(zhdr, FIRST);
+	if (zhdr->last_chunks)
+		last_handle = encode_handle(zhdr, LAST);
+	spin_unlock(&pool->lock);
+
+	/* Issue the eviction callback(s) */
+	if (first_handle) {
+		ret = evict_cb(pool, first_handle);
+		if (ret)
+			goto next;
+	}
+	if (last_handle) {
+		ret = evict_cb(pool, last_handle);
+		if (ret)
+			goto next;
+	}
+next:
+	spin_lock(&pool->lock);
+	return put_zbud_page(pool, zhdr);
+}
+
 /**
- * zbud_reclaim_page() - evicts allocations from a pool page and frees it
+ * zbud_reclaim_lru_page() - evicts allocations from a pool page and frees it
  * @pool:	pool from which a page will attempt to be evicted
  * @retires:	number of pages on the LRU list for which eviction will
  *		be attempted before failing
@@ -429,11 +481,10 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle)
  * no pages to evict or an eviction handler is not registered, -EAGAIN if
  * the retry limit was hit.
  */
-int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
+int zbud_reclaim_lru_page(struct zbud_pool *pool, unsigned int retries)
 {
-	int i, ret;
+	int i;
 	struct zbud_header *zhdr;
-	unsigned long first_handle = 0, last_handle = 0;
 
 	spin_lock(&pool->lock);
 	if (!pool->ops || !pool->ops->evict || list_empty(&pool->lru) ||
@@ -454,44 +505,84 @@ int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
 			return 0;
 		}
 		zhdr = list_tail_entry(&pool->lru, struct zbud_header, lru);
-		BUG_ON(zhdr->first_chunks == 0 && zhdr->last_chunks == 0);
-		/* Move this last element to beginning of LRU */
-		list_del(&zhdr->lru);
-		list_add(&zhdr->lru, &pool->lru);
-		/* Protect zbud page against free */
-		get_zbud_page(zhdr);
-		/*
-		 * We need encode the handles before unlocking, since we can
-		 * race with free that will set (first|last)_chunks to 0
-		 */
-		first_handle = 0;
-		last_handle = 0;
-		if (zhdr->first_chunks)
-			first_handle = encode_handle(zhdr, FIRST);
-		if (zhdr->last_chunks)
-			last_handle = encode_handle(zhdr, LAST);
-		spin_unlock(&pool->lock);
-
-		/* Issue the eviction callback(s) */
-		if (first_handle) {
-			ret = pool->ops->evict(pool, first_handle);
-			if (ret)
-				goto next;
+		if (do_reclaim(pool, zhdr, pool->ops->evict)) {
+			spin_unlock(&pool->lock);
+			return 0;
 		}
-		if (last_handle) {
-			ret = pool->ops->evict(pool, last_handle);
-			if (ret)
-				goto next;
+	}
+	spin_unlock(&pool->lock);
+	return -EAGAIN;
+}
+
+
+/**
+ * zbud_reclaim_pages() - reclaims zbud pages by unusing stored pages
+ * @zbud_pages		list of zbud pages to reclaim
+ *
+ * zbud reclaim is different from normal system reclaim in that the reclaim is
+ * done from the bottom, up.  This is because only the bottom layer, zbud, has
+ * information on how the allocations are organized within each zbud page. This
+ * has the potential to create interesting locking situations between zbud and
+ * the user, however.
+ *
+ * To avoid these, this is how zbud_reclaim_pages() should be called:
+
+ * The user detects some pages should be reclaimed and calls
+ * zbud_reclaim_pages(). The zbud_reclaim_pages() will remove zbud
+ * pages from the pool LRU list and call the user-defined unuse handler with
+ * the pool and handle as arguments.
+ *
+ * If the handle can not be unused, the unuse handler should return
+ * non-zero. zbud_reclaim_pages() will add the zbud page back to the
+ * appropriate list and try the next zbud page on the list.
+ *
+ * If the handle is successfully unused, the unuse handler should
+ * return 0.
+ * The zbud page will be freed later by unuse code
+ * (e.g. frontswap_invalidate_page()).
+ *
+ * If all buddies in the zbud page are successfully unused, then the
+ * zbud page can be freed.
+ */
+void zbud_reclaim_pages(struct list_head *zbud_pages)
+{
+	struct page *page;
+	struct page *page2;
+
+	list_for_each_entry_safe(page, page2, zbud_pages, lru) {
+		struct zbud_header *zhdr;
+		struct zbud_pool *pool;
+
+		list_del(&page->lru);
+		if (!PageZbud(page)) {
+			/*
+			 * Drop page count from isolate_migratepages_range()
+			 */
+			put_page(page);
+			continue;
 		}
-next:
+		zhdr = page_address(page);
+		BUG_ON(!zhdr->pool);
+		pool = zhdr->pool;
+
 		spin_lock(&pool->lock);
+		/* Drop page count from isolate_migratepages_range() */
 		if (put_zbud_page(pool, zhdr)) {
+			/*
+			 * zbud_free() could free the handles before acquiring
+			 * pool lock above. No need to reclaim.
+			 */
 			spin_unlock(&pool->lock);
-			return 0;
+			continue;
+		}
+		if (!pool->ops || !pool->ops->unuse || list_empty(&pool->lru)) {
+			spin_unlock(&pool->lock);
+			continue;
 		}
+		BUG_ON(!PageZbud(page));
+		do_reclaim(pool, zhdr, pool->ops->unuse);
+		spin_unlock(&pool->lock);
 	}
-	spin_unlock(&pool->lock);
-	return -EAGAIN;
 }
 
 /**
diff --git a/mm/zswap.c b/mm/zswap.c
index deda2b6..846649b 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -35,6 +35,9 @@
 #include <linux/crypto.h>
 #include <linux/mempool.h>
 #include <linux/zbud.h>
+#include <linux/swapfile.h>
+#include <linux/mman.h>
+#include <linux/security.h>
 
 #include <linux/mm_types.h>
 #include <linux/page-flags.h>
@@ -61,6 +64,8 @@ static atomic_t zswap_stored_pages = ATOMIC_INIT(0);
 static u64 zswap_pool_limit_hit;
 /* Pages written back when pool limit was reached */
 static u64 zswap_written_back_pages;
+/* Pages unused due to reclaim */
+static u64 zswap_unused_pages;
 /* Store failed due to a reclaim failure after pool limit was reached */
 static u64 zswap_reject_reclaim_fail;
 /* Compressed page was too big for the allocator to (optimally) store */
@@ -596,6 +601,47 @@ fail:
 	return ret;
 }
 
+/**
+ * Tries to unuse swap entries by uncompressing them.
+ * Function is a stripped swapfile.c::try_to_unuse().
+ *
+ * Returns 0 on success or negative on error.
+ */
+static int zswap_unuse_entry(struct zbud_pool *pool, unsigned long handle)
+{
+	struct zswap_header *zhdr;
+	swp_entry_t swpentry;
+	struct zswap_tree *tree;
+	pgoff_t offset;
+	struct mm_struct *start_mm;
+	struct swap_info_struct *si;
+	int ret;
+
+	/* extract swpentry from data */
+	zhdr = zbud_map(pool, handle);
+	swpentry = zhdr->swpentry; /* here */
+	zbud_unmap(pool, handle);
+	tree = zswap_trees[swp_type(swpentry)];
+	offset = swp_offset(swpentry);
+	BUG_ON(pool != tree->pool);
+
+	/*
+	 * We cannot hold swap_lock here but swap_info may
+	 * change (e.g. by swapoff). In case of swapoff
+	 * check for SWP_WRITEOK.
+	 */
+	si = swap_info[swp_type(swpentry)];
+	if (!(si->flags & SWP_WRITEOK))
+		return -ECANCELED;
+
+	start_mm = &init_mm;
+	atomic_inc(&init_mm.mm_users);
+	ret = try_to_unuse_swp_entry(&start_mm, si, swpentry);
+	mmput(start_mm);
+	zswap_unused_pages++;
+	return ret;
+}
+
 /*********************************
 * frontswap hooks
 **********************************/
@@ -620,7 +666,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 	/* reclaim space if needed */
 	if (zswap_is_full()) {
 		zswap_pool_limit_hit++;
-		if (zbud_reclaim_page(tree->pool, 8)) {
+		if (zbud_reclaim_lru_page(tree->pool, 8)) {
 			zswap_reject_reclaim_fail++;
 			ret = -ENOMEM;
 			goto reject;
@@ -647,8 +693,8 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 
 	/* store */
 	len = dlen + sizeof(struct zswap_header);
-	ret = zbud_alloc(tree->pool, len, __GFP_NORETRY | __GFP_NOWARN,
-		&handle);
+	ret = zbud_alloc(tree->pool, len, __GFP_NORETRY | __GFP_NOWARN |
+						__GFP_RECLAIMABLE, &handle);
 	if (ret == -ENOSPC) {
 		zswap_reject_compress_poor++;
 		goto freepage;
@@ -819,7 +865,8 @@ static void zswap_frontswap_invalidate_area(unsigned type)
 }
 
 static struct zbud_ops zswap_zbud_ops = {
-	.evict = zswap_writeback_entry
+	.evict = zswap_writeback_entry,
+	.unuse = zswap_unuse_entry
 };
 
 static void zswap_frontswap_init(unsigned type)
@@ -880,6 +927,8 @@ static int __init zswap_debugfs_init(void)
 			zswap_debugfs_root, &zswap_reject_compress_poor);
 	debugfs_create_u64("written_back_pages", S_IRUGO,
 			zswap_debugfs_root, &zswap_written_back_pages);
+	debugfs_create_u64("unused_pages", S_IRUGO,
+			zswap_debugfs_root, &zswap_unused_pages);
 	debugfs_create_u64("duplicate_entry", S_IRUGO,
 			zswap_debugfs_root, &zswap_duplicate_entry);
 	debugfs_create_u64("pool_pages", S_IRUGO,
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
