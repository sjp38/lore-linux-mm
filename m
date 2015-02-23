Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 2A0D96B0070
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 14:52:13 -0500 (EST)
Received: by pabkx10 with SMTP id kx10so30037178pab.0
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 11:52:12 -0800 (PST)
Received: from mail-pd0-x22f.google.com (mail-pd0-x22f.google.com. [2607:f8b0:400e:c02::22f])
        by mx.google.com with ESMTPS id kk7si45422003pab.77.2015.02.23.11.52.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Feb 2015 11:52:12 -0800 (PST)
Received: by pdbfp1 with SMTP id fp1so27724040pdb.9
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 11:52:11 -0800 (PST)
From: SeongJae Park <sj38.park@gmail.com>
Subject: [RFC v2 3/5] gcma: adopt cleancache and frontswap as second-class clients
Date: Tue, 24 Feb 2015 04:54:21 +0900
Message-Id: <1424721263-25314-4-git-send-email-sj38.park@gmail.com>
In-Reply-To: <1424721263-25314-1-git-send-email-sj38.park@gmail.com>
References: <1424721263-25314-1-git-send-email-sj38.park@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: lauraa@codeaurora.org, minchan@kernel.org, sergey.senozhatsky@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, SeongJae Park <sj38.park@gmail.com>

Because pages in cleancache is clean and out of kernel scope, they could
be free immediately whenever it required to be with no additional task.
Similarly, because frontswap pages are out of kernel scope, they could
be free easily after written back to backing swap device. Moreover, the
writing back task could be avoided if frontswap run as write-through
mode.  It means cleancache and write-through mode frontswap pages are
best candidates for second-class clients of gcma.

By the consequence, this commit implements cleancache and write-through
mode frontswap backend inside gcma area using discardable memory
interface.

Signed-off-by: SeongJae Park <sj38.park@gmail.com>
---
 include/linux/gcma.h |   3 +
 mm/gcma.c            | 312 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 314 insertions(+), 1 deletion(-)

diff --git a/include/linux/gcma.h b/include/linux/gcma.h
index 005bf77..12e4431 100644
--- a/include/linux/gcma.h
+++ b/include/linux/gcma.h
@@ -20,6 +20,9 @@
  * backend of discardable memory. Any candiates satisfying with discardable
  * memory could be second-class client of GCMA using the interface.
  *
+ * Currently, GCMA uses cleancache and write-through mode frontswap as
+ * second-class clients.
+ *
  * Copyright (C) 2014  LG Electronics Inc.,
  * Copyright (C) 2014  Minchan Kim <minchan@kernel.org>
  * Copyright (C) 2014-2015  SeongJae Park <sj38.park@gmail.com>
diff --git a/mm/gcma.c b/mm/gcma.c
index dc70fa8..924e3f6 100644
--- a/mm/gcma.c
+++ b/mm/gcma.c
@@ -20,6 +20,9 @@
  * backend of discardable memory. Any candiates satisfying with discardable
  * memory could be second-class client of GCMA using the interface.
  *
+ * Currently, GCMA uses cleancache and write-through mode frontswap as
+ * second-class clients.
+ *
  * Copyright (C) 2014  LG Electronics Inc.,
  * Copyright (C) 2014  Minchan Kim <minchan@kernel.org>
  * Copyright (C) 2014-2015  SeongJae Park <sj38.park@gmail.com>
@@ -27,11 +30,24 @@
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
+#include <linux/cleancache.h>
+#include <linux/frontswap.h>
 #include <linux/gcma.h>
+#include <linux/hash.h>
 #include <linux/highmem.h>
 #include <linux/module.h>
 #include <linux/slab.h>
 
+#define BITS_FS_DMEM_HASH	8
+#define NR_FS_DMEM_HASH_BUCKS	(1 << BITS_FS_DMEM_HASH)
+#define BYTES_FS_DMEM_KEY	(sizeof(struct frontswap_dmem_key))
+
+#define BITS_CC_DMEM_HASH	8
+#define NR_CC_DMEM_HASH_BUCKS	(1 << BITS_CC_DMEM_HASH)
+#define BYTES_CC_DMEM_KEY	(sizeof(struct cleancache_dmem_key))
+#define MAX_CLEANCACHE_FS	16
+
+
 /* XXX: What's the ideal? */
 #define NR_EVICT_BATCH	32
 
@@ -92,8 +108,28 @@ struct dmem {
 	int (*compare)(void *lkey, void *rkey);
 };
 
+struct frontswap_dmem_key {
+	pgoff_t key;
+};
+
+struct cleancache_dmem_key {
+	u8 key[sizeof(pgoff_t) + sizeof(struct cleancache_filekey)];
+};
+
 static struct kmem_cache *dmem_entry_cache;
 
+static struct dmem fs_dmem;	/* dmem for frontswap backend */
+
+static struct dmem cc_dmem;	/* dmem for cleancache backend */
+static atomic_t nr_cleancache_fses = ATOMIC_INIT(0);
+
+/* configs from kernel parameter */
+static bool fs_disabled __read_mostly;
+module_param_named(fs_disabled, fs_disabled, bool, 0444);
+
+static bool cc_disabled __read_mostly;
+module_param_named(cc_disabled, cc_disabled, bool, 0444);
+
 static unsigned long dmem_evict_lru(struct dmem *dmem, unsigned long nr_pages);
 
 static struct dmem_hashbucket *dmem_hashbuck(struct page *page)
@@ -174,6 +210,7 @@ int gcma_init(unsigned long start_pfn, unsigned long size,
 {
 	int bitmap_size = BITS_TO_LONGS(size) * sizeof(long);
 	struct gcma *gcma;
+	unsigned long flags;
 
 	gcma = kmalloc(sizeof(*gcma), GFP_KERNEL);
 	if (!gcma)
@@ -187,9 +224,11 @@ int gcma_init(unsigned long start_pfn, unsigned long size,
 	gcma->base_pfn = start_pfn;
 	spin_lock_init(&gcma->lock);
 
+	local_irq_save(flags);
 	spin_lock(&ginfo.lock);
 	list_add(&gcma->list, &ginfo.head);
 	spin_unlock(&ginfo.lock);
+	local_irq_restore(flags);
 
 	*res_gcma = gcma;
 	pr_info("initialized gcma area [%lu, %lu]\n",
@@ -207,7 +246,9 @@ static struct page *gcma_alloc_page(struct gcma *gcma)
 	unsigned long bit;
 	unsigned long *bitmap = gcma->bitmap;
 	struct page *page = NULL;
+	unsigned long flags;
 
+	local_irq_save(flags);
 	spin_lock(&gcma->lock);
 	bit = bitmap_find_next_zero_area(bitmap, gcma->size, 0, 1, 0);
 	if (bit >= gcma->size) {
@@ -221,6 +262,7 @@ static struct page *gcma_alloc_page(struct gcma *gcma)
 	clear_gpage_flagall(page);
 
 out:
+	local_irq_restore(flags);
 	return page;
 }
 
@@ -228,9 +270,11 @@ out:
 static void gcma_free_page(struct gcma *gcma, struct page *page)
 {
 	unsigned long pfn, offset;
+	unsigned long flags;
 
 	pfn = page_to_pfn(page);
 
+	local_irq_save(flags);
 	spin_lock(&gcma->lock);
 	offset = pfn - gcma->base_pfn;
 
@@ -247,6 +291,7 @@ static void gcma_free_page(struct gcma *gcma, struct page *page)
 		set_gpage_flag(page, GF_ISOLATED);
 	}
 	spin_unlock(&gcma->lock);
+	local_irq_restore(flags);
 }
 
 /*
@@ -313,7 +358,9 @@ static struct page *dmem_alloc_page(struct dmem *dmem, struct gcma **res_gcma)
 {
 	struct page *page;
 	struct gcma *gcma;
+	unsigned long flags;
 
+	local_irq_save(flags);
 retry:
 	spin_lock(&ginfo.lock);
 	gcma = list_first_entry(&ginfo.head, struct gcma, list);
@@ -336,6 +383,7 @@ retry:
 		goto retry;
 
 got:
+	local_irq_restore(flags);
 	*res_gcma = gcma;
 	return page;
 }
@@ -486,7 +534,20 @@ int dmem_init_pool(struct dmem *dmem, unsigned pool_id)
 		buck = &pool->hashbuckets[i];
 		buck->dmem = dmem;
 		buck->rbroot = RB_ROOT;
-		spin_lock_init(&buck->lock);
+
+		/*
+		 * Because lockdep recognizes lock class using lock
+		 * initialization point, bucket lock of dmem for cleancache and
+		 * frontswap be treated as same class.
+		 * Because cleancache have dependency with softirq safe lock
+		 * while frontswap doesn't, lockdep causes false irq lock
+		 * inversion dependency report.
+		 * Avoid the situation using this ugly, simple hack.
+		 */
+		if (dmem == &fs_dmem)
+			spin_lock_init(&buck->lock);
+		else
+			spin_lock_init(&buck->lock);
 	}
 
 	dmem->pools[pool_id] = pool;
@@ -716,6 +777,180 @@ int dmem_invalidate_pool(struct dmem *dmem, unsigned pool_id)
 	return 0;
 }
 
+
+static int frontswap_compare(void *lkey, void *rkey)
+{
+	return *(pgoff_t *)lkey - *(pgoff_t *)rkey;
+}
+
+static unsigned frontswap_hash_key(void *key)
+{
+	return *(pgoff_t *)key % fs_dmem.nr_hash;
+}
+
+void gcma_frontswap_init(unsigned type)
+{
+	dmem_init_pool(&fs_dmem, type);
+}
+
+int gcma_frontswap_store(unsigned type, pgoff_t offset,
+				struct page *page)
+{
+	return dmem_store_page(&fs_dmem, type, (void *)&offset, page);
+}
+
+/*
+ * Returns 0 if success,
+ * Returns non-zero if failed.
+ */
+int gcma_frontswap_load(unsigned type, pgoff_t offset,
+			       struct page *page)
+{
+	return dmem_load_page(&fs_dmem, type, (void *)&offset, page);
+}
+
+void gcma_frontswap_invalidate_page(unsigned type, pgoff_t offset)
+{
+	dmem_invalidate_entry(&fs_dmem, type, (void *)&offset);
+}
+
+void gcma_frontswap_invalidate_area(unsigned type)
+{
+	dmem_invalidate_pool(&fs_dmem, type);
+}
+
+static struct frontswap_ops gcma_frontswap_ops = {
+	.init = gcma_frontswap_init,
+	.store = gcma_frontswap_store,
+	.load = gcma_frontswap_load,
+	.invalidate_page = gcma_frontswap_invalidate_page,
+	.invalidate_area = gcma_frontswap_invalidate_area
+};
+
+
+static int cleancache_compare(void *lkey, void *rkey)
+{
+	/* Frontswap uses pgoff_t value as key */
+	return memcmp(lkey, rkey, BYTES_CC_DMEM_KEY);
+}
+
+static unsigned int cleancache_hash_key(void *key)
+{
+	unsigned long *k = (unsigned long *)key;
+
+	return hash_long(k[0] ^ k[1] ^ k[2], BITS_CC_DMEM_HASH);
+}
+
+static void cleancache_set_key(struct cleancache_filekey *fkey, pgoff_t *offset,
+				void *key)
+{
+	memcpy(key, offset, sizeof(pgoff_t));
+	memcpy(key + sizeof(pgoff_t), fkey, sizeof(struct cleancache_filekey));
+}
+
+
+/* Returns positive pool id or negative error code */
+int gcma_cleancache_init_fs(size_t pagesize)
+{
+	int pool_id;
+	int err;
+
+	pool_id = atomic_inc_return(&nr_cleancache_fses) - 1;
+	if (pool_id >= MAX_CLEANCACHE_FS) {
+		pr_warn("%s: too many cleancache fs %d / %d\n",
+				__func__, pool_id, MAX_CLEANCACHE_FS);
+		return -1;
+	}
+
+	err = dmem_init_pool(&cc_dmem, pool_id);
+	if (err != 0)
+		return err;
+	return pool_id;
+}
+
+int gcma_cleancache_init_shared_fs(char *uuid, size_t pagesize)
+{
+	return -1;
+}
+
+int gcma_cleancache_get_page(int pool_id, struct cleancache_filekey fkey,
+				pgoff_t offset, struct page *page)
+{
+	struct cleancache_dmem_key key;
+	int ret;
+	unsigned long flags;
+
+	cleancache_set_key(&fkey, &offset, &key);
+
+	local_irq_save(flags);
+	ret = dmem_load_page(&cc_dmem, pool_id, &key, page);
+	local_irq_restore(flags);
+	return ret;
+}
+
+void gcma_cleancache_put_page(int pool_id, struct cleancache_filekey fkey,
+				pgoff_t offset, struct page *page)
+{
+	struct cleancache_dmem_key key;
+	unsigned long flags;
+
+	cleancache_set_key(&fkey, &offset, &key);
+
+	local_irq_save(flags);
+	dmem_store_page(&cc_dmem, pool_id, &key, page);
+	local_irq_restore(flags);
+}
+
+void gcma_cleancache_invalidate_page(int pool_id,
+					struct cleancache_filekey fkey,
+					pgoff_t offset)
+{
+	struct cleancache_dmem_key key;
+	unsigned long flags;
+
+	cleancache_set_key(&fkey, &offset, &key);
+
+	local_irq_save(flags);
+	dmem_invalidate_entry(&cc_dmem, pool_id, &key);
+	local_irq_restore(flags);
+}
+
+/*
+ * Invalidating every entry of an filekey from a dmem pool requires iterating
+ * and comparing key of every entry in the pool; it could be too expensive. To
+ * alleviates the overhead, do nothing here. The entry will be evicted in LRU
+ * order anyway.
+ */
+void gcma_cleancache_invalidate_inode(int pool_id,
+					struct cleancache_filekey key)
+{
+}
+
+void gcma_cleancache_invalidate_fs(int pool_id)
+{
+	unsigned long flags;
+
+	if (pool_id < 0 || pool_id >= atomic_read(&nr_cleancache_fses)) {
+		pr_warn("%s received wrong pool id %d\n",
+				__func__, pool_id);
+		return;
+	}
+	local_irq_save(flags);
+	dmem_invalidate_pool(&cc_dmem, pool_id);
+	local_irq_restore(flags);
+}
+
+struct cleancache_ops gcma_cleancache_ops = {
+	.init_fs = gcma_cleancache_init_fs,
+	.init_shared_fs = gcma_cleancache_init_shared_fs,
+	.get_page = gcma_cleancache_get_page,
+	.put_page = gcma_cleancache_put_page,
+	.invalidate_page = gcma_cleancache_invalidate_page,
+	.invalidate_inode = gcma_cleancache_invalidate_inode,
+	.invalidate_fs = gcma_cleancache_invalidate_fs,
+};
+
+
 /*
  * Return 0 if [start_pfn, end_pfn] is isolated.
  * Otherwise, return first unisolated pfn from the start_pfn.
@@ -727,7 +962,9 @@ static unsigned long isolate_interrupted(struct gcma *gcma,
 	unsigned long *bitmap;
 	unsigned long pfn, ret = 0;
 	struct page *page;
+	unsigned long flags;
 
+	local_irq_save(flags);
 	spin_lock(&gcma->lock);
 
 	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
@@ -750,6 +987,7 @@ static unsigned long isolate_interrupted(struct gcma *gcma,
 
 	}
 	spin_unlock(&gcma->lock);
+	local_irq_restore(flags);
 	return ret;
 }
 
@@ -774,9 +1012,11 @@ int gcma_alloc_contig(struct gcma *gcma, unsigned long start_pfn,
 	unsigned long pfn;
 	unsigned long orig_start = start_pfn;
 	spinlock_t *lru_lock;
+	unsigned long flags = 0;
 
 retry:
 	for (pfn = start_pfn; pfn < start_pfn + size; pfn++) {
+		local_irq_save(flags);
 		spin_lock(&gcma->lock);
 
 		offset = pfn - gcma->base_pfn;
@@ -788,21 +1028,25 @@ retry:
 			bitmap_set(gcma->bitmap, offset, 1);
 			set_gpage_flag(page, GF_ISOLATED);
 			spin_unlock(&gcma->lock);
+			local_irq_restore(flags);
 			continue;
 		}
 		if (gpage_flag(page, GF_ISOLATED)) {
 			spin_unlock(&gcma->lock);
+			local_irq_restore(flags);
 			continue;
 		}
 
 		/* Someone is using the page so it's complicated :( */
 		spin_unlock(&gcma->lock);
+		local_irq_restore(flags);
 
 		/* During dmem_store, hashbuck could not be set in page, yet */
 		if (dmem_hashbuck(page) == NULL)
 			continue;
 
 		lru_lock = &dmem_hashbuck(page)->dmem->lru_lock;
+		local_irq_save(flags);
 		spin_lock(lru_lock);
 		spin_lock(&gcma->lock);
 
@@ -834,6 +1078,7 @@ retry:
 next_page:
 		spin_unlock(&gcma->lock);
 		spin_unlock(lru_lock);
+		local_irq_restore(flags);
 	}
 
 	/*
@@ -845,6 +1090,8 @@ next_page:
 		entry = dmem_entry(page);
 		lru_lock = &dmem_hashbuck(page)->dmem->lru_lock;
 
+		if (lru_lock == &cc_dmem.lru_lock)
+			local_irq_save(flags);
 		spin_lock(&buck->lock);
 		spin_lock(lru_lock);
 		/* drop refcount increased by above loop */
@@ -855,6 +1102,8 @@ next_page:
 			dmem_put(buck, entry);
 		spin_unlock(lru_lock);
 		spin_unlock(&buck->lock);
+		if (lru_lock == &cc_dmem.lru_lock)
+			local_irq_restore(flags);
 	}
 
 	start_pfn = isolate_interrupted(gcma, orig_start, orig_start + size);
@@ -874,11 +1123,14 @@ void gcma_free_contig(struct gcma *gcma,
 			unsigned long start_pfn, unsigned long size)
 {
 	unsigned long offset;
+	unsigned long flags;
 
+	local_irq_save(flags);
 	spin_lock(&gcma->lock);
 	offset = start_pfn - gcma->base_pfn;
 	bitmap_clear(gcma->bitmap, offset, size);
 	spin_unlock(&gcma->lock);
+	local_irq_restore(flags);
 }
 
 static int __init init_gcma(void)
@@ -889,6 +1141,64 @@ static int __init init_gcma(void)
 	if (dmem_entry_cache == NULL)
 		return -ENOMEM;
 
+	if (fs_disabled) {
+		pr_info("gcma frontswap is disabled. skip it\n");
+		goto init_cleancache;
+	}
+	fs_dmem.nr_pools = MAX_SWAPFILES;
+	fs_dmem.pools = kzalloc(sizeof(struct dmem_pool *) * fs_dmem.nr_pools,
+				GFP_KERNEL);
+	if (!fs_dmem.pools) {
+		pr_warn("failed to allocate frontswap dmem pools\n");
+		return -ENOMEM;
+	}
+
+	fs_dmem.nr_hash = NR_FS_DMEM_HASH_BUCKS;
+	fs_dmem.key_cache = KMEM_CACHE(frontswap_dmem_key, 0);
+	if (!fs_dmem.key_cache)
+		return -ENOMEM;
+	fs_dmem.bytes_key = BYTES_FS_DMEM_KEY;
+
+	INIT_LIST_HEAD(&fs_dmem.lru_list);
+	spin_lock_init(&fs_dmem.lru_lock);
+
+	fs_dmem.hash_key = frontswap_hash_key;
+	fs_dmem.compare = frontswap_compare;
+
+	/*
+	 * By writethough mode, GCMA could discard all of pages in an instant
+	 * instead of slow writing pages out to the swap device.
+	 */
+	frontswap_writethrough(true);
+	frontswap_register_ops(&gcma_frontswap_ops);
+
+init_cleancache:
+	if (cc_disabled) {
+		pr_info("gcma cleancache is disabled. skip it\n");
+		goto init_debugfs;
+	}
+	cc_dmem.nr_pools = MAX_CLEANCACHE_FS;
+	cc_dmem.pools = kzalloc(sizeof(struct dmem_pool *) * cc_dmem.nr_pools,
+				GFP_KERNEL);
+	if (!cc_dmem.pools) {
+		pr_warn("failed to allocate cleancache dmem pools\n");
+		return -ENOMEM;
+	}
+	cc_dmem.nr_hash = NR_CC_DMEM_HASH_BUCKS;
+	cc_dmem.key_cache = KMEM_CACHE(cleancache_dmem_key, 0);
+	if (!cc_dmem.key_cache)
+		return -ENOMEM;
+	cc_dmem.bytes_key = BYTES_CC_DMEM_KEY;
+
+	INIT_LIST_HEAD(&cc_dmem.lru_list);
+	spin_lock_init(&cc_dmem.lru_lock);
+
+	cc_dmem.hash_key = cleancache_hash_key;
+	cc_dmem.compare = cleancache_compare;
+	cleancache_register_ops(&gcma_cleancache_ops);
+
+init_debugfs:
+	gcma_debugfs_init();
 	return 0;
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
