Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id CEB686B0008
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 16:40:49 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Tue, 29 Jan 2013 16:40:48 -0500
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 3295638C8046
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 16:40:46 -0500 (EST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0TLej1j21233742
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 16:40:45 -0500
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0TLeZGR000695
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 14:40:35 -0700
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCHv4 6/7] zswap: add flushing support
Date: Tue, 29 Jan 2013 15:40:26 -0600
Message-Id: <1359495627-30285-7-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1359495627-30285-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1359495627-30285-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

This patchset adds support for flush pages out of the compressed
pool to the swap device

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 mm/zswap.c | 451 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 434 insertions(+), 17 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index a6c2928..b8e5673 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -34,6 +34,12 @@
 #include <linux/mempool.h>
 #include <linux/zsmalloc.h>
 
+#include <linux/mm_types.h>
+#include <linux/page-flags.h>
+#include <linux/swapops.h>
+#include <linux/writeback.h>
+#include <linux/pagemap.h>
+
 /*********************************
 * statistics
 **********************************/
@@ -41,6 +47,8 @@
 static atomic_t zswap_pool_pages = ATOMIC_INIT(0);
 /* The number of compressed pages currently stored in zswap */
 static atomic_t zswap_stored_pages = ATOMIC_INIT(0);
+/* The number of outstanding pages awaiting writeback */
+static atomic_t zswap_outstanding_flushes = ATOMIC_INIT(0);
 
 /*
  * The statistics below are not protected from concurrent access for
@@ -49,9 +57,14 @@ static atomic_t zswap_stored_pages = ATOMIC_INIT(0);
  * certain event is occurring.
 */
 static u64 zswap_pool_limit_hit;
+static u64 zswap_flushed_pages;
 static u64 zswap_reject_compress_poor;
+static u64 zswap_flush_attempted;
+static u64 zswap_reject_tmppage_fail;
+static u64 zswap_reject_flush_fail;
 static u64 zswap_reject_zsmalloc_fail;
 static u64 zswap_reject_kmemcache_fail;
+static u64 zswap_saved_by_flush;
 static u64 zswap_duplicate_entry;
 
 /*********************************
@@ -80,6 +93,14 @@ static unsigned int zswap_max_compression_ratio = 80;
 module_param_named(max_compression_ratio,
 			zswap_max_compression_ratio, uint, 0644);
 
+/*
+ * Maximum number of outstanding flushes allowed at any given time.
+ * This is to prevent decompressing an unbounded number of compressed
+ * pages into the swap cache all at once, and to help with writeback
+ * congestion.
+*/
+#define ZSWAP_MAX_OUTSTANDING_FLUSHES 64
+
 /*********************************
 * compression functions
 **********************************/
@@ -145,14 +166,23 @@ static void zswap_comp_exit(void)
 **********************************/
 struct zswap_entry {
 	struct rb_node rbnode;
+	struct list_head lru;
+	int refcount;
 	unsigned type;
 	pgoff_t offset;
 	unsigned long handle;
 	unsigned int length;
 };
 
+/*
+ * The tree lock in the zswap_tree struct protects a few things:
+ * - the rbtree
+ * - the lru list
+ * - the refcount field of each entry in the tree
+ */
 struct zswap_tree {
 	struct rb_root rbroot;
+	struct list_head lru;
 	spinlock_t lock;
 	struct zs_pool *pool;
 };
@@ -184,6 +214,8 @@ static inline struct zswap_entry *zswap_entry_cache_alloc(gfp_t gfp)
 	entry = kmem_cache_alloc(zswap_entry_cache, gfp);
 	if (!entry)
 		return NULL;
+	INIT_LIST_HEAD(&entry->lru);
+	entry->refcount = 1;
 	return entry;
 }
 
@@ -192,6 +224,17 @@ static inline void zswap_entry_cache_free(struct zswap_entry *entry)
 	kmem_cache_free(zswap_entry_cache, entry);
 }
 
+static inline void zswap_entry_get(struct zswap_entry *entry)
+{
+	entry->refcount++;
+}
+
+static inline int zswap_entry_put(struct zswap_entry *entry)
+{
+	entry->refcount--;
+	return entry->refcount;
+}
+
 /*********************************
 * rbtree functions
 **********************************/
@@ -367,6 +410,278 @@ static struct zs_ops zswap_zs_ops = {
 };
 
 /*********************************
+* flush code
+**********************************/
+static void zswap_end_swap_write(struct bio *bio, int err)
+{
+	end_swap_bio_write(bio, err);
+	atomic_dec(&zswap_outstanding_flushes);
+	zswap_flushed_pages++;
+}
+
+/*
+ * zswap_get_swap_cache_page
+ *
+ * This is an adaption of read_swap_cache_async()
+ *
+ * If success, page is returned in retpage
+ * Returns 0 if page was already in the swap cache, page is not locked
+ * Returns 1 if the new page needs to be populated, page is locked
+ */
+static int zswap_get_swap_cache_page(swp_entry_t entry,
+				struct page **retpage)
+{
+	struct page *found_page, *new_page = NULL;
+	int err;
+
+	*retpage = NULL;
+	do {
+		/*
+		 * First check the swap cache.  Since this is normally
+		 * called after lookup_swap_cache() failed, re-calling
+		 * that would confuse statistics.
+		 */
+		found_page = find_get_page(&swapper_space, entry.val);
+		if (found_page)
+			break;
+
+		/*
+		 * Get a new page to read into from swap.
+		 */
+		if (!new_page) {
+			new_page = alloc_page(GFP_KERNEL);
+			if (!new_page)
+				break; /* Out of memory */
+		}
+
+		/*
+		 * call radix_tree_preload() while we can wait.
+		 */
+		err = radix_tree_preload(GFP_KERNEL);
+		if (err)
+			break;
+
+		/*
+		 * Swap entry may have been freed since our caller observed it.
+		 */
+		err = swapcache_prepare(entry);
+		if (err == -EEXIST) { /* seems racy */
+			radix_tree_preload_end();
+			continue;
+		}
+		if (err) { /* swp entry is obsolete ? */
+			radix_tree_preload_end();
+			break;
+		}
+
+		/* May fail (-ENOMEM) if radix-tree node allocation failed. */
+		__set_page_locked(new_page);
+		SetPageSwapBacked(new_page);
+		err = __add_to_swap_cache(new_page, entry);
+		if (likely(!err)) {
+			radix_tree_preload_end();
+			lru_cache_add_anon(new_page);
+			*retpage = new_page;
+			return 1;
+		}
+		radix_tree_preload_end();
+		ClearPageSwapBacked(new_page);
+		__clear_page_locked(new_page);
+		/*
+		 * add_to_swap_cache() doesn't return -EEXIST, so we can safely
+		 * clear SWAP_HAS_CACHE flag.
+		 */
+		swapcache_free(entry, NULL);
+	} while (err != -ENOMEM);
+
+	if (new_page)
+		page_cache_release(new_page);
+	if (!found_page)
+		return -ENOMEM;
+	*retpage = found_page;
+	return 0;
+}
+
+static int zswap_flush_entry(struct zswap_entry *entry)
+{
+	unsigned long type = entry->type;
+	struct zswap_tree *tree = zswap_trees[type];
+	struct page *page;
+	swp_entry_t swpentry;
+	u8 *src, *dst;
+	unsigned int dlen;
+	int ret, refcount;
+	struct writeback_control wbc = {
+		.sync_mode = WB_SYNC_NONE,
+	};
+
+	/* get/allocate page in the swap cache */
+	swpentry = swp_entry(type, entry->offset);
+	ret = zswap_get_swap_cache_page(swpentry, &page);
+	if (ret < 0)
+		return ret;
+	else if (ret) {
+		/* decompress */
+		dlen = PAGE_SIZE;
+		src = zs_map_object(tree->pool, entry->handle, ZS_MM_RO);
+		dst = kmap_atomic(page);
+		ret = zswap_comp_op(ZSWAP_COMPOP_DECOMPRESS, src, entry->length,
+				dst, &dlen);
+		kunmap_atomic(dst);
+		zs_unmap_object(tree->pool, entry->handle);
+		BUG_ON(ret);
+		BUG_ON(dlen != PAGE_SIZE);
+		SetPageUptodate(page);
+	} else {
+		/* page is already in the swap cache, ignore for now */
+		spin_lock(&tree->lock);
+		refcount = zswap_entry_put(entry);
+		spin_unlock(&tree->lock);
+
+		if (likely(refcount))
+			return 0;
+
+		/* if the refcount is zero, invalidate must have come in */
+		/* free */
+		zs_free(tree->pool, entry->handle);
+		zswap_entry_cache_free(entry);
+		atomic_dec(&zswap_stored_pages);
+
+		return 0;
+	}
+
+	/* start writeback */
+	SetPageReclaim(page);
+	/*
+	 * Return value is ignored here because it doesn't change anything
+	 * for us.  Page is returned unlocked.
+	 */
+	(void)__swap_writepage(page, &wbc, zswap_end_swap_write);
+	page_cache_release(page);
+	atomic_inc(&zswap_outstanding_flushes);
+
+	/* remove */
+	spin_lock(&tree->lock);
+	refcount = zswap_entry_put(entry);
+	if (refcount > 1) {
+		/* load in progress, load will free */
+		spin_unlock(&tree->lock);
+		return 0;
+	}
+	if (refcount == 1)
+		/* no invalidate yet, remove from rbtree */
+		rb_erase(&entry->rbnode, &tree->rbroot);
+	spin_unlock(&tree->lock);
+
+	/* free */
+	zs_free(tree->pool, entry->handle);
+	zswap_entry_cache_free(entry);
+	atomic_dec(&zswap_stored_pages);
+
+	return 0;
+}
+
+static void zswap_flush_entries(unsigned type, int nr)
+{
+	struct zswap_tree *tree = zswap_trees[type];
+	struct zswap_entry *entry;
+	int i, ret;
+
+/*
+ * This limits is arbitrary for now until a better
+ * policy can be implemented. This is so we don't
+ * eat all of RAM decompressing pages for writeback.
+ */
+	if (atomic_read(&zswap_outstanding_flushes) >
+		ZSWAP_MAX_OUTSTANDING_FLUSHES)
+		return;
+
+	for (i = 0; i < nr; i++) {
+		/* dequeue from lru */
+		spin_lock(&tree->lock);
+		if (list_empty(&tree->lru)) {
+			spin_unlock(&tree->lock);
+			break;
+		}
+		entry = list_first_entry(&tree->lru,
+				struct zswap_entry, lru);
+		list_del(&entry->lru);
+		zswap_entry_get(entry);
+		spin_unlock(&tree->lock);
+		ret = zswap_flush_entry(entry);
+		if (ret) {
+			/* put back on the lru */
+			spin_lock(&tree->lock);
+			list_add(&entry->lru, &tree->lru);
+			spin_unlock(&tree->lock);
+		} else {
+			if (atomic_read(&zswap_outstanding_flushes) >
+				ZSWAP_MAX_OUTSTANDING_FLUSHES)
+				break;
+		}
+	}
+}
+
+/*******************************************
+* page pool for temporary compression result
+********************************************/
+#define ZSWAP_TMPPAGE_POOL_PAGES 16
+static LIST_HEAD(zswap_tmppage_list);
+static DEFINE_SPINLOCK(zswap_tmppage_lock);
+
+static void zswap_tmppage_pool_destroy(void)
+{
+	struct page *page, *tmppage;
+
+	spin_lock(&zswap_tmppage_lock);
+	list_for_each_entry_safe(page, tmppage, &zswap_tmppage_list, lru) {
+		list_del(&page->lru);
+		__free_pages(page, 1);
+	}
+	spin_unlock(&zswap_tmppage_lock);
+}
+
+static int zswap_tmppage_pool_create(void)
+{
+	int i;
+	struct page *page;
+
+	for (i = 0; i < ZSWAP_TMPPAGE_POOL_PAGES; i++) {
+		page = alloc_pages(GFP_KERNEL, 1);
+		if (!page) {
+			zswap_tmppage_pool_destroy();
+			return -ENOMEM;
+		}
+		spin_lock(&zswap_tmppage_lock);
+		list_add(&page->lru, &zswap_tmppage_list);
+		spin_unlock(&zswap_tmppage_lock);
+	}
+	return 0;
+}
+
+static inline struct page *zswap_tmppage_alloc(void)
+{
+	struct page *page;
+
+	spin_lock(&zswap_tmppage_lock);
+	if (list_empty(&zswap_tmppage_list)) {
+		spin_unlock(&zswap_tmppage_lock);
+		return NULL;
+	}
+	page = list_first_entry(&zswap_tmppage_list, struct page, lru);
+	list_del(&page->lru);
+	spin_unlock(&zswap_tmppage_lock);
+	return page;
+}
+
+static inline void zswap_tmppage_free(struct page *page)
+{
+	spin_lock(&zswap_tmppage_lock);
+	list_add(&page->lru, &zswap_tmppage_list);
+	spin_unlock(&zswap_tmppage_lock);
+}
+
+/*********************************
 * frontswap hooks
 **********************************/
 /* attempts to compress and store an single page */
@@ -378,7 +693,9 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset, struct page *pag
 	unsigned int dlen = PAGE_SIZE;
 	unsigned long handle;
 	char *buf;
-	u8 *src, *dst;
+	u8 *src, *dst, *tmpdst;
+	struct page *tmppage;
+	bool flush_attempted = 0;
 
 	if (!tree) {
 		ret = -ENODEV;
@@ -392,12 +709,12 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset, struct page *pag
 	kunmap_atomic(src);
 	if (ret) {
 		ret = -EINVAL;
-		goto putcpu;
+		goto freepage;
 	}
 	if ((dlen * 100 / PAGE_SIZE) > zswap_max_compression_ratio) {
 		zswap_reject_compress_poor++;
 		ret = -E2BIG;
-		goto putcpu;
+		goto freepage;
 	}
 
 	/* store */
@@ -405,15 +722,46 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset, struct page *pag
 		__GFP_NORETRY | __GFP_HIGHMEM | __GFP_NOMEMALLOC |
 			__GFP_NOWARN);
 	if (!handle) {
-		zswap_reject_zsmalloc_fail++;
-		ret = -ENOMEM;
-		goto putcpu;
+		zswap_flush_attempted++;
+		/*
+		 * Copy compressed buffer out of per-cpu storage so
+		 * we can re-enable preemption.
+		*/
+		tmppage = zswap_tmppage_alloc();
+		if (!tmppage) {
+			zswap_reject_tmppage_fail++;
+			ret = -ENOMEM;
+			goto freepage;
+		}
+		flush_attempted = 1;
+		tmpdst = page_address(tmppage);
+		memcpy(tmpdst, dst, dlen);
+		dst = tmpdst;
+		put_cpu_var(zswap_dstmem);
+
+		/* try to free up some space */
+		/* TODO: replace with more targeted policy */
+		zswap_flush_entries(type, 16);
+		/* try again, allowing wait */
+		handle = zs_malloc(tree->pool, dlen,
+			__GFP_NORETRY | __GFP_HIGHMEM | __GFP_NOMEMALLOC |
+				__GFP_NOWARN);
+		if (!handle) {
+			/* still no space, fail */
+			zswap_reject_zsmalloc_fail++;
+			ret = -ENOMEM;
+			goto freepage;
+		}
+		zswap_saved_by_flush++;
 	}
 
 	buf = zs_map_object(tree->pool, handle, ZS_MM_WO);
 	memcpy(buf, dst, dlen);
 	zs_unmap_object(tree->pool, handle);
-	put_cpu_var(zswap_dstmem);
+	if (flush_attempted)
+		zswap_tmppage_free(tmppage);
+	else
+		put_cpu_var(zswap_dstmem);
 
 	/* allocate entry */
 	entry = zswap_entry_cache_alloc(GFP_KERNEL);
@@ -436,16 +784,19 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset, struct page *pag
 		ret = zswap_rb_insert(&tree->rbroot, entry, &dupentry);
 		if (ret == -EEXIST) {
 			zswap_duplicate_entry++;
-
-			/* remove from rbtree */
+			/* remove from rbtree and lru */
 			rb_erase(&dupentry->rbnode, &tree->rbroot);
-			
-			/* free */
-			zs_free(tree->pool, dupentry->handle);
-			zswap_entry_cache_free(dupentry);
-			atomic_dec(&zswap_stored_pages);
+			if (dupentry->lru.next != LIST_POISON1)
+				list_del(&dupentry->lru);
+			if (!zswap_entry_put(dupentry)) {
+				/* free */
+				zs_free(tree->pool, dupentry->handle);
+				zswap_entry_cache_free(dupentry);
+				atomic_dec(&zswap_stored_pages);
+			}
 		}
 	} while (ret == -EEXIST);
+	list_add_tail(&entry->lru, &tree->lru);
 	spin_unlock(&tree->lock);
 
 	/* update stats */
@@ -453,8 +804,11 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset, struct page *pag
 
 	return 0;
 
-putcpu:
-	put_cpu_var(zswap_dstmem);
+freepage:
+	if (flush_attempted)
+		zswap_tmppage_free(tmppage);
+	else
+		put_cpu_var(zswap_dstmem);
 reject:
 	return ret;
 }
@@ -469,10 +823,21 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset, struct page *page
 	struct zswap_entry *entry;
 	u8 *src, *dst;
 	unsigned int dlen;
+	int refcount;
 
 	/* find */
 	spin_lock(&tree->lock);
 	entry = zswap_rb_search(&tree->rbroot, offset);
+	if (!entry) {
+		/* entry was flushed */
+		spin_unlock(&tree->lock);
+		return -1;
+	}
+	zswap_entry_get(entry);
+
+	/* remove from lru */
+	if (entry->lru.next != LIST_POISON1)
+		list_del(&entry->lru);
 	spin_unlock(&tree->lock);
 
 	/* decompress */
@@ -484,6 +849,25 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset, struct page *page
 	kunmap_atomic(dst);
 	zs_unmap_object(tree->pool, entry->handle);
 
+	spin_lock(&tree->lock);
+	refcount = zswap_entry_put(entry);
+	if (likely(refcount)) {
+		list_add_tail(&entry->lru, &tree->lru);
+		spin_unlock(&tree->lock);
+		return 0;
+	}
+	spin_unlock(&tree->lock);
+
+	/*
+	 * We don't have to unlink from the rbtree because zswap_flush_entry()
+	 * or zswap_frontswap_invalidate page() has already done this for us if we
+	 * are the last reference.
+	 */
+	/* free */
+	zs_free(tree->pool, entry->handle);
+	zswap_entry_cache_free(entry);
+	atomic_dec(&zswap_stored_pages);
+
 	return 0;
 }
 
@@ -492,14 +876,27 @@ static void zswap_frontswap_invalidate_page(unsigned type, pgoff_t offset)
 {
 	struct zswap_tree *tree = zswap_trees[type];
 	struct zswap_entry *entry;
+	int refcount;
 
 	/* find */
 	spin_lock(&tree->lock);
 	entry = zswap_rb_search(&tree->rbroot, offset);
+	if (!entry) {
+		/* entry was flushed */
+		spin_unlock(&tree->lock);
+		return;
+	}
 
-	/* remove from rbtree */
+	/* remove from rbtree and lru */
 	rb_erase(&entry->rbnode, &tree->rbroot);
+	if (entry->lru.next != LIST_POISON1)
+		list_del(&entry->lru);
+	refcount = zswap_entry_put(entry);
 	spin_unlock(&tree->lock);
+	if (refcount) {
+		/* must be flushing */
+		return;
+	}
 
 	/* free */
 	zs_free(tree->pool, entry->handle);
@@ -528,6 +925,7 @@ static void zswap_frontswap_invalidate_area(unsigned type)
 		node = next;
 	}
 	tree->rbroot = RB_ROOT;
+	INIT_LIST_HEAD(&tree->lru);
 	spin_unlock(&tree->lock);
 }
 
@@ -543,6 +941,7 @@ static void zswap_frontswap_init(unsigned type)
 	if (!tree->pool)
 		goto freetree;
 	tree->rbroot = RB_ROOT;
+	INIT_LIST_HEAD(&tree->lru);
 	spin_lock_init(&tree->lock);
 	zswap_trees[type] = tree;
 	return;
@@ -578,20 +977,32 @@ static int __init zswap_debugfs_init(void)
 	if (!zswap_debugfs_root)
 		return -ENOMEM;
 
+	debugfs_create_u64("saved_by_flush", S_IRUGO,
+			zswap_debugfs_root, &zswap_saved_by_flush);
 	debugfs_create_u64("pool_limit_hit", S_IRUGO,
 			zswap_debugfs_root, &zswap_pool_limit_hit);
+	debugfs_create_u64("reject_flush_attempted", S_IRUGO,
+			zswap_debugfs_root, &zswap_flush_attempted);
+	debugfs_create_u64("reject_tmppage_fail", S_IRUGO,
+			zswap_debugfs_root, &zswap_reject_tmppage_fail);
+	debugfs_create_u64("reject_flush_fail", S_IRUGO,
+			zswap_debugfs_root, &zswap_reject_flush_fail);
 	debugfs_create_u64("reject_zsmalloc_fail", S_IRUGO,
 			zswap_debugfs_root, &zswap_reject_zsmalloc_fail);
 	debugfs_create_u64("reject_kmemcache_fail", S_IRUGO,
 			zswap_debugfs_root, &zswap_reject_kmemcache_fail);
 	debugfs_create_u64("reject_compress_poor", S_IRUGO,
 			zswap_debugfs_root, &zswap_reject_compress_poor);
+	debugfs_create_u64("flushed_pages", S_IRUGO,
+			zswap_debugfs_root, &zswap_flushed_pages);
 	debugfs_create_u64("duplicate_entry", S_IRUGO,
 			zswap_debugfs_root, &zswap_duplicate_entry);
 	debugfs_create_atomic_t("pool_pages", S_IRUGO,
 			zswap_debugfs_root, &zswap_pool_pages);
 	debugfs_create_atomic_t("stored_pages", S_IRUGO,
 			zswap_debugfs_root, &zswap_stored_pages);
+	debugfs_create_atomic_t("outstanding_flushes", S_IRUGO,
+			zswap_debugfs_root, &zswap_outstanding_flushes);
 
 	return 0;
 }
@@ -627,6 +1038,10 @@ static int __init init_zswap(void)
 		pr_err("zswap: page pool initialization failed\n");
 		goto pagepoolfail;
 	}
+	if (zswap_tmppage_pool_create()) {
+		pr_err("zswap: workmem pool initialization failed\n");
+		goto tmppoolfail;
+	}
 	if (zswap_comp_init()) {
 		pr_err("zswap: compressor initialization failed\n");
 		goto compfail;
@@ -642,6 +1057,8 @@ static int __init init_zswap(void)
 pcpufail:
 	zswap_comp_exit();
 compfail:
+	zswap_tmppage_pool_destroy();
+tmppoolfail:
 	zswap_page_pool_destroy();
 pagepoolfail:
 	zswap_entry_cache_destory();
-- 
1.8.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
