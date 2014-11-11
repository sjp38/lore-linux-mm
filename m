Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 04DA6900014
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 09:59:47 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so10764338pab.12
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 06:59:46 -0800 (PST)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id id5si20176149pad.187.2014.11.11.06.59.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 11 Nov 2014 06:59:45 -0800 (PST)
Received: by mail-pa0-f51.google.com with SMTP id kq14so10834607pab.10
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 06:59:45 -0800 (PST)
From: SeongJae Park <sj38.park@gmail.com>
Subject: [RFC v1 5/6] gcma: export statistical data on debugfs
Date: Wed, 12 Nov 2014 00:00:09 +0900
Message-Id: <1415718010-18663-6-git-send-email-sj38.park@gmail.com>
In-Reply-To: <1415718010-18663-1-git-send-email-sj38.park@gmail.com>
References: <1415718010-18663-1-git-send-email-sj38.park@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: lauraa@codeaurora.org, minchan@kernel.org, sergey.senozhatsky@gmail.com, linux-mm@kvack.org, SeongJae Park <sj38.park@gmail.com>

Export saved / loaded / evicted / reclaimed pages from gcma's frontswap
backend on debugfs to let users know how gcma is working internally.

Signed-off-by: SeongJae Park <sj38.park@gmail.com>
---
 mm/gcma.c | 46 ++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 46 insertions(+)

diff --git a/mm/gcma.c b/mm/gcma.c
index 9c07128..65395ec 100644
--- a/mm/gcma.c
+++ b/mm/gcma.c
@@ -57,6 +57,12 @@ static spinlock_t slru_lock;	/* protect slru_list */
 static struct frontswap_tree *gcma_swap_trees[MAX_SWAPFILES];
 static struct kmem_cache *swap_slot_entry_cache;
 
+/* For statistics */
+static atomic_t gcma_stored_pages = ATOMIC_INIT(0);
+static atomic_t gcma_loaded_pages = ATOMIC_INIT(0);
+static atomic_t gcma_evicted_pages = ATOMIC_INIT(0);
+static atomic_t gcma_reclaimed_pages = ATOMIC_INIT(0);
+
 static unsigned long evict_frontswap_pages(unsigned long nr_pages);
 
 static struct frontswap_tree *swap_tree(struct page *page)
@@ -380,6 +386,7 @@ static unsigned long evict_frontswap_pages(unsigned long nr_pages)
 		spin_unlock(&tree->lock);
 	}
 
+	atomic_add(evicted, &gcma_evicted_pages);
 	return evicted;
 }
 
@@ -480,6 +487,7 @@ int gcma_frontswap_store(unsigned type, pgoff_t offset,
 	spin_unlock(&slru_lock);
 	spin_unlock(&tree->lock);
 
+	atomic_inc(&gcma_stored_pages);
 	return ret;
 }
 
@@ -521,6 +529,7 @@ int gcma_frontswap_load(unsigned type, pgoff_t offset,
 	spin_unlock(&slru_lock);
 	spin_unlock(&tree->lock);
 
+	atomic_inc(&gcma_loaded_pages);
 	return 0;
 }
 
@@ -659,6 +668,7 @@ retry:
 			if (atomic_inc_not_zero(&entry->refcount)) {
 				clear_gpage_flag(page, GF_SWAP_LRU);
 				set_gpage_flag(page, GF_RECLAIMING);
+				atomic_inc(&gcma_reclaimed_pages);
 				list_move(&page->lru, &free_pages);
 				spin_unlock(&slru_lock);
 				continue;
@@ -679,6 +689,7 @@ retry:
 			set_gpage_flag(page, GF_ISOLATED);
 		} else {
 			set_gpage_flag(page, GF_RECLAIMING);
+			atomic_inc(&gcma_reclaimed_pages);
 		}
 		spin_unlock(&gcma->lock);
 		spin_unlock(&slru_lock);
@@ -727,6 +738,40 @@ void gcma_free_contig(struct gcma *gcma,
 	spin_unlock(&gcma->lock);
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
+	debugfs_create_atomic_t("stored_pages", S_IRUGO,
+			gcma_debugfs_root, &gcma_stored_pages);
+	debugfs_create_atomic_t("loaded_pages", S_IRUGO,
+			gcma_debugfs_root, &gcma_loaded_pages);
+	debugfs_create_atomic_t("evicted_pages", S_IRUGO,
+			gcma_debugfs_root, &gcma_evicted_pages);
+	debugfs_create_atomic_t("reclaimed_pages", S_IRUGO,
+			gcma_debugfs_root, &gcma_reclaimed_pages);
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
+
 static int __init init_gcma(void)
 {
 	pr_info("loading gcma\n");
@@ -743,6 +788,7 @@ static int __init init_gcma(void)
 	frontswap_writethrough(true);
 	frontswap_register_ops(&gcma_frontswap_ops);
 
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
