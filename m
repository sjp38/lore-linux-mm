Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8BE2C6B0071
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 14:52:16 -0500 (EST)
Received: by pabkx10 with SMTP id kx10so30037546pab.0
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 11:52:16 -0800 (PST)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id lo7si9447948pab.120.2015.02.23.11.52.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Feb 2015 11:52:15 -0800 (PST)
Received: by padfa1 with SMTP id fa1so30058792pad.2
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 11:52:15 -0800 (PST)
From: SeongJae Park <sj38.park@gmail.com>
Subject: [RFC v2 4/5] gcma: export statistical data on debugfs
Date: Tue, 24 Feb 2015 04:54:22 +0900
Message-Id: <1424721263-25314-5-git-send-email-sj38.park@gmail.com>
In-Reply-To: <1424721263-25314-1-git-send-email-sj38.park@gmail.com>
References: <1424721263-25314-1-git-send-email-sj38.park@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: lauraa@codeaurora.org, minchan@kernel.org, sergey.senozhatsky@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, SeongJae Park <sj38.park@gmail.com>

Export statistical data of second-class clients of gcma on debugfs to
let users know how gcma is working internally.

Signed-off-by: SeongJae Park <sj38.park@gmail.com>
---
 mm/gcma.c | 127 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 119 insertions(+), 8 deletions(-)

diff --git a/mm/gcma.c b/mm/gcma.c
index 924e3f6..57203b4 100644
--- a/mm/gcma.c
+++ b/mm/gcma.c
@@ -130,6 +130,26 @@ module_param_named(fs_disabled, fs_disabled, bool, 0444);
 static bool cc_disabled __read_mostly;
 module_param_named(cc_disabled, cc_disabled, bool, 0444);
 
+/* For statistics */
+static atomic_t gcma_fs_inits = ATOMIC_INIT(0);
+static atomic_t gcma_fs_stored_pages = ATOMIC_INIT(0);
+static atomic_t gcma_fs_loaded_pages = ATOMIC_INIT(0);
+static atomic_t gcma_fs_evicted_pages = ATOMIC_INIT(0);
+static atomic_t gcma_fs_reclaimed_pages = ATOMIC_INIT(0);
+static atomic_t gcma_fs_invalidated_pages = ATOMIC_INIT(0);
+static atomic_t gcma_fs_invalidated_areas = ATOMIC_INIT(0);
+
+static atomic_t gcma_cc_inits = ATOMIC_INIT(0);
+static atomic_t gcma_cc_stored_pages = ATOMIC_INIT(0);
+static atomic_t gcma_cc_loaded_pages = ATOMIC_INIT(0);
+static atomic_t gcma_cc_load_failed_pages = ATOMIC_INIT(0);
+static atomic_t gcma_cc_evicted_pages = ATOMIC_INIT(0);
+static atomic_t gcma_cc_reclaimed_pages = ATOMIC_INIT(0);
+static atomic_t gcma_cc_invalidated_pages = ATOMIC_INIT(0);
+static atomic_t gcma_cc_invalidated_inodes = ATOMIC_INIT(0);
+static atomic_t gcma_cc_invalidated_fses = ATOMIC_INIT(0);
+static atomic_t gcma_cc_invalidate_failed_fses = ATOMIC_INIT(0);
+
 static unsigned long dmem_evict_lru(struct dmem *dmem, unsigned long nr_pages);
 
 static struct dmem_hashbucket *dmem_hashbuck(struct page *page)
@@ -475,6 +495,10 @@ static unsigned long dmem_evict_lru(struct dmem *dmem, unsigned long nr_pages)
 		spin_unlock(&buck->lock);
 	}
 
+	if (dmem == &fs_dmem)
+		atomic_add(evicted, &gcma_fs_evicted_pages);
+	else
+		atomic_add(evicted, &gcma_cc_evicted_pages);
 	return evicted;
 }
 
@@ -791,12 +815,18 @@ static unsigned frontswap_hash_key(void *key)
 void gcma_frontswap_init(unsigned type)
 {
 	dmem_init_pool(&fs_dmem, type);
+	atomic_inc(&gcma_fs_inits);
 }
 
 int gcma_frontswap_store(unsigned type, pgoff_t offset,
 				struct page *page)
 {
-	return dmem_store_page(&fs_dmem, type, (void *)&offset, page);
+	int ret;
+
+	ret = dmem_store_page(&fs_dmem, type, (void *)&offset, page);
+	if (ret == 0)
+		atomic_inc(&gcma_fs_stored_pages);
+	return ret;
 }
 
 /*
@@ -806,17 +836,24 @@ int gcma_frontswap_store(unsigned type, pgoff_t offset,
 int gcma_frontswap_load(unsigned type, pgoff_t offset,
 			       struct page *page)
 {
-	return dmem_load_page(&fs_dmem, type, (void *)&offset, page);
+	int ret;
+
+	ret = dmem_load_page(&fs_dmem, type, (void *)&offset, page);
+	if (ret == 0)
+		atomic_inc(&gcma_fs_loaded_pages);
+	return ret;
 }
 
 void gcma_frontswap_invalidate_page(unsigned type, pgoff_t offset)
 {
-	dmem_invalidate_entry(&fs_dmem, type, (void *)&offset);
+	if (dmem_invalidate_entry(&fs_dmem, type, (void *)&offset) == 0)
+		atomic_inc(&gcma_fs_invalidated_pages);
 }
 
 void gcma_frontswap_invalidate_area(unsigned type)
 {
-	dmem_invalidate_pool(&fs_dmem, type);
+	if (dmem_invalidate_pool(&fs_dmem, type) == 0)
+		atomic_inc(&gcma_fs_invalidated_areas);
 }
 
 static struct frontswap_ops gcma_frontswap_ops = {
@@ -865,6 +902,8 @@ int gcma_cleancache_init_fs(size_t pagesize)
 	err = dmem_init_pool(&cc_dmem, pool_id);
 	if (err != 0)
 		return err;
+
+	atomic_inc(&gcma_cc_inits);
 	return pool_id;
 }
 
@@ -885,6 +924,10 @@ int gcma_cleancache_get_page(int pool_id, struct cleancache_filekey fkey,
 	local_irq_save(flags);
 	ret = dmem_load_page(&cc_dmem, pool_id, &key, page);
 	local_irq_restore(flags);
+	if (ret == 0)
+		atomic_inc(&gcma_cc_loaded_pages);
+	else
+		atomic_inc(&gcma_cc_load_failed_pages);
 	return ret;
 }
 
@@ -897,7 +940,8 @@ void gcma_cleancache_put_page(int pool_id, struct cleancache_filekey fkey,
 	cleancache_set_key(&fkey, &offset, &key);
 
 	local_irq_save(flags);
-	dmem_store_page(&cc_dmem, pool_id, &key, page);
+	if (dmem_store_page(&cc_dmem, pool_id, &key, page) == 0)
+		atomic_inc(&gcma_cc_stored_pages);
 	local_irq_restore(flags);
 }
 
@@ -911,7 +955,8 @@ void gcma_cleancache_invalidate_page(int pool_id,
 	cleancache_set_key(&fkey, &offset, &key);
 
 	local_irq_save(flags);
-	dmem_invalidate_entry(&cc_dmem, pool_id, &key);
+	if (dmem_invalidate_entry(&cc_dmem, pool_id, &key) == 0)
+		atomic_inc(&gcma_cc_invalidated_pages);
 	local_irq_restore(flags);
 }
 
@@ -933,10 +978,12 @@ void gcma_cleancache_invalidate_fs(int pool_id)
 	if (pool_id < 0 || pool_id >= atomic_read(&nr_cleancache_fses)) {
 		pr_warn("%s received wrong pool id %d\n",
 				__func__, pool_id);
+		atomic_inc(&gcma_cc_invalidate_failed_fses);
 		return;
 	}
 	local_irq_save(flags);
-	dmem_invalidate_pool(&cc_dmem, pool_id);
+	if (dmem_invalidate_pool(&cc_dmem, pool_id) == 0)
+		atomic_inc(&gcma_cc_invalidated_fses);
 	local_irq_restore(flags);
 }
 
@@ -1102,8 +1149,12 @@ next_page:
 			dmem_put(buck, entry);
 		spin_unlock(lru_lock);
 		spin_unlock(&buck->lock);
-		if (lru_lock == &cc_dmem.lru_lock)
+		if (lru_lock == &cc_dmem.lru_lock) {
 			local_irq_restore(flags);
+			atomic_inc(&gcma_cc_reclaimed_pages);
+		} else {
+			atomic_inc(&gcma_fs_reclaimed_pages);
+		}
 	}
 
 	start_pfn = isolate_interrupted(gcma, orig_start, orig_start + size);
@@ -1133,6 +1184,66 @@ void gcma_free_contig(struct gcma *gcma,
 	local_irq_restore(flags);
 }
 
+#ifdef CONFIG_DEBUG_FS
+#include <linux/debugfs.h>
+
+static struct dentry *gcma_debugfs_root;
+
+static int __init gcma_debugfs_init(void)
+{
+	if (!debugfs_initialized())
+		return -ENODEV;
+
+	gcma_debugfs_root = debugfs_create_dir("gcma", NULL);
+	if (!gcma_debugfs_root)
+		return -ENOMEM;
+
+	debugfs_create_atomic_t("fs_inits", S_IRUGO,
+			gcma_debugfs_root, &gcma_fs_inits);
+	debugfs_create_atomic_t("fs_stored_pages", S_IRUGO,
+			gcma_debugfs_root, &gcma_fs_stored_pages);
+	debugfs_create_atomic_t("fs_loaded_pages", S_IRUGO,
+			gcma_debugfs_root, &gcma_fs_loaded_pages);
+	debugfs_create_atomic_t("fs_evicted_pages", S_IRUGO,
+			gcma_debugfs_root, &gcma_fs_evicted_pages);
+	debugfs_create_atomic_t("fs_reclaimed_pages", S_IRUGO,
+			gcma_debugfs_root, &gcma_fs_reclaimed_pages);
+	debugfs_create_atomic_t("fs_invalidated_pages", S_IRUGO,
+			gcma_debugfs_root, &gcma_fs_invalidated_pages);
+	debugfs_create_atomic_t("fs_invalidated_areas", S_IRUGO,
+			gcma_debugfs_root, &gcma_fs_invalidated_areas);
+
+	debugfs_create_atomic_t("cc_inits", S_IRUGO,
+			gcma_debugfs_root, &gcma_cc_inits);
+	debugfs_create_atomic_t("cc_stored_pages", S_IRUGO,
+			gcma_debugfs_root, &gcma_cc_stored_pages);
+	debugfs_create_atomic_t("cc_loaded_pages", S_IRUGO,
+			gcma_debugfs_root, &gcma_cc_loaded_pages);
+	debugfs_create_atomic_t("cc_load_failed_pages", S_IRUGO,
+			gcma_debugfs_root, &gcma_cc_load_failed_pages);
+	debugfs_create_atomic_t("cc_evicted_pages", S_IRUGO,
+			gcma_debugfs_root, &gcma_cc_evicted_pages);
+	debugfs_create_atomic_t("cc_reclaimed_pages", S_IRUGO,
+			gcma_debugfs_root, &gcma_cc_reclaimed_pages);
+	debugfs_create_atomic_t("cc_invalidated_pages", S_IRUGO,
+			gcma_debugfs_root, &gcma_cc_invalidated_pages);
+	debugfs_create_atomic_t("cc_invalidated_inodes", S_IRUGO,
+			gcma_debugfs_root, &gcma_cc_invalidated_inodes);
+	debugfs_create_atomic_t("cc_invalidated_fses", S_IRUGO,
+			gcma_debugfs_root, &gcma_cc_invalidated_fses);
+	debugfs_create_atomic_t("cc_invalidate_failed_fses", S_IRUGO,
+			gcma_debugfs_root, &gcma_cc_invalidate_failed_fses);
+
+	pr_info("gcma debufs init\n");
+	return 0;
+}
+#else
+static int __init gcma_debugfs_init(void)
+{
+	return 0;
+}
+#endif
+
 static int __init init_gcma(void)
 {
 	pr_info("loading gcma\n");
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
