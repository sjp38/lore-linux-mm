Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3FEA16B0322
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 08:24:07 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id e11-v6so11678303wrr.14
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 05:24:07 -0800 (PST)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id a11-v6si32282317wrs.287.2018.11.06.05.24.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 05:24:05 -0800 (PST)
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: [PATCH v7] mm, drm/i915: mark pinned shmemfs pages as unevictable
Date: Tue,  6 Nov 2018 13:23:24 +0000
Message-Id: <20181106132324.17390-1-chris@chris-wilson.co.uk>
In-Reply-To: <20181106093100.71829-1-vovoy@chromium.org>
References: <20181106093100.71829-1-vovoy@chromium.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: intel-gfx@lists.freedesktop.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kuo-Hsin Yang <vovoy@chromium.org>, Chris Wilson <chris@chris-wilson.co.uk>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>

From: Kuo-Hsin Yang <vovoy@chromium.org>

The i915 driver uses shmemfs to allocate backing storage for gem
objects. These shmemfs pages can be pinned (increased ref count) by
shmem_read_mapping_page_gfp(). When a lot of pages are pinned, vmscan
wastes a lot of time scanning these pinned pages. In some extreme case,
all pages in the inactive anon lru are pinned, and only the inactive
anon lru is scanned due to inactive_ratio, the system cannot swap and
invokes the oom-killer. Mark these pinned pages as unevictable to speed
up vmscan.

Export pagevec API check_move_unevictable_pages().

This patch was inspired by Chris Wilson's change [1].

[1]: https://patchwork.kernel.org/patch/9768741/

Cc: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>
Signed-off-by: Kuo-Hsin Yang <vovoy@chromium.org>
Acked-by: Michal Hocko <mhocko@suse.com> # mm part
Reviewed-by: Chris Wilson <chris@chris-wilson.co.uk>
---
Rebased on drm-intel-next-queued to pick up a cond_resched()
-Chris
---
 Documentation/vm/unevictable-lru.rst |  6 +++++-
 drivers/gpu/drm/i915/i915_gem.c      | 30 +++++++++++++++++++++++++---
 include/linux/swap.h                 |  4 +++-
 mm/shmem.c                           |  2 +-
 mm/vmscan.c                          | 22 ++++++++++----------
 5 files changed, 47 insertions(+), 17 deletions(-)

diff --git a/Documentation/vm/unevictable-lru.rst b/Documentation/vm/unevictable-lru.rst
index fdd84cb8d511..b8e29f977f2d 100644
--- a/Documentation/vm/unevictable-lru.rst
+++ b/Documentation/vm/unevictable-lru.rst
@@ -143,7 +143,7 @@ using a number of wrapper functions:
 	Query the address space, and return true if it is completely
 	unevictable.
 
-These are currently used in two places in the kernel:
+These are currently used in three places in the kernel:
 
  (1) By ramfs to mark the address spaces of its inodes when they are created,
      and this mark remains for the life of the inode.
@@ -154,6 +154,10 @@ These are currently used in two places in the kernel:
      swapped out; the application must touch the pages manually if it wants to
      ensure they're in memory.
 
+ (3) By the i915 driver to mark pinned address space until it's unpinned. The
+     amount of unevictable memory marked by i915 driver is roughly the bounded
+     object size in debugfs/dri/0/i915_gem_objects.
+
 
 Detecting Unevictable Pages
 ---------------------------
diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index 347b3836c809..1c09d3e93c21 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -2382,12 +2382,26 @@ void __i915_gem_object_invalidate(struct drm_i915_gem_object *obj)
 	invalidate_mapping_pages(mapping, 0, (loff_t)-1);
 }
 
+/**
+ * Move pages to appropriate lru and release the pagevec. Decrement the ref
+ * count of these pages.
+ */
+static inline void check_release_pagevec(struct pagevec *pvec)
+{
+	if (pagevec_count(pvec)) {
+		check_move_unevictable_pages(pvec);
+		__pagevec_release(pvec);
+		cond_resched();
+	}
+}
+
 static void
 i915_gem_object_put_pages_gtt(struct drm_i915_gem_object *obj,
 			      struct sg_table *pages)
 {
 	struct sgt_iter sgt_iter;
 	struct page *page;
+	struct pagevec pvec;
 
 	__i915_gem_object_release_shmem(obj, pages, true);
 
@@ -2396,6 +2410,9 @@ i915_gem_object_put_pages_gtt(struct drm_i915_gem_object *obj,
 	if (i915_gem_object_needs_bit17_swizzle(obj))
 		i915_gem_object_save_bit_17_swizzle(obj, pages);
 
+	mapping_clear_unevictable(file_inode(obj->base.filp)->i_mapping);
+
+	pagevec_init(&pvec);
 	for_each_sgt_page(page, sgt_iter, pages) {
 		if (obj->mm.dirty)
 			set_page_dirty(page);
@@ -2403,9 +2420,10 @@ i915_gem_object_put_pages_gtt(struct drm_i915_gem_object *obj,
 		if (obj->mm.madv == I915_MADV_WILLNEED)
 			mark_page_accessed(page);
 
-		put_page(page);
-		cond_resched();
+		if (!pagevec_add(&pvec, page))
+			check_release_pagevec(&pvec);
 	}
+	check_release_pagevec(&pvec);
 	obj->mm.dirty = false;
 
 	sg_free_table(pages);
@@ -2528,6 +2546,7 @@ static int i915_gem_object_get_pages_gtt(struct drm_i915_gem_object *obj)
 	unsigned int sg_page_sizes;
 	gfp_t noreclaim;
 	int ret;
+	struct pagevec pvec;
 
 	/*
 	 * Assert that the object is not currently in any GPU domain. As it
@@ -2561,6 +2580,7 @@ static int i915_gem_object_get_pages_gtt(struct drm_i915_gem_object *obj)
 	 * Fail silently without starting the shrinker
 	 */
 	mapping = obj->base.filp->f_mapping;
+	mapping_set_unevictable(mapping);
 	noreclaim = mapping_gfp_constraint(mapping, ~__GFP_RECLAIM);
 	noreclaim |= __GFP_NORETRY | __GFP_NOWARN;
 
@@ -2675,8 +2695,12 @@ static int i915_gem_object_get_pages_gtt(struct drm_i915_gem_object *obj)
 err_sg:
 	sg_mark_end(sg);
 err_pages:
+	mapping_clear_unevictable(mapping);
+	pagevec_init(&pvec);
 	for_each_sgt_page(page, sgt_iter, st)
-		put_page(page);
+		if (!pagevec_add(&pvec, page))
+			check_release_pagevec(&pvec);
+	check_release_pagevec(&pvec);
 	sg_free_table(st);
 	kfree(st);
 
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 8e2c11e692ba..6c95df96c9aa 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -18,6 +18,8 @@ struct notifier_block;
 
 struct bio;
 
+struct pagevec;
+
 #define SWAP_FLAG_PREFER	0x8000	/* set if swap priority specified */
 #define SWAP_FLAG_PRIO_MASK	0x7fff
 #define SWAP_FLAG_PRIO_SHIFT	0
@@ -373,7 +375,7 @@ static inline int node_reclaim(struct pglist_data *pgdat, gfp_t mask,
 #endif
 
 extern int page_evictable(struct page *page);
-extern void check_move_unevictable_pages(struct page **, int nr_pages);
+extern void check_move_unevictable_pages(struct pagevec *pvec);
 
 extern int kswapd_run(int nid);
 extern void kswapd_stop(int nid);
diff --git a/mm/shmem.c b/mm/shmem.c
index 446942677cd4..0c3b005a59eb 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -781,7 +781,7 @@ void shmem_unlock_mapping(struct address_space *mapping)
 			break;
 		index = indices[pvec.nr - 1] + 1;
 		pagevec_remove_exceptionals(&pvec);
-		check_move_unevictable_pages(pvec.pages, pvec.nr);
+		check_move_unevictable_pages(&pvec);
 		pagevec_release(&pvec);
 		cond_resched();
 	}
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c7ce2c161225..0dbc493026a2 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -46,6 +46,7 @@
 #include <linux/delayacct.h>
 #include <linux/sysctl.h>
 #include <linux/oom.h>
+#include <linux/pagevec.h>
 #include <linux/prefetch.h>
 #include <linux/printk.h>
 #include <linux/dax.h>
@@ -4162,17 +4163,16 @@ int page_evictable(struct page *page)
 	return ret;
 }
 
-#ifdef CONFIG_SHMEM
 /**
- * check_move_unevictable_pages - check pages for evictability and move to appropriate zone lru list
- * @pages:	array of pages to check
- * @nr_pages:	number of pages to check
+ * check_move_unevictable_pages - check pages for evictability and move to
+ * appropriate zone lru list
+ * @pvec: pagevec with lru pages to check
  *
- * Checks pages for evictability and moves them to the appropriate lru list.
- *
- * This function is only used for SysV IPC SHM_UNLOCK.
+ * Checks pages for evictability, if an evictable page is in the unevictable
+ * lru list, moves it to the appropriate evictable lru list. This function
+ * should be only used for lru pages.
  */
-void check_move_unevictable_pages(struct page **pages, int nr_pages)
+void check_move_unevictable_pages(struct pagevec *pvec)
 {
 	struct lruvec *lruvec;
 	struct pglist_data *pgdat = NULL;
@@ -4180,8 +4180,8 @@ void check_move_unevictable_pages(struct page **pages, int nr_pages)
 	int pgrescued = 0;
 	int i;
 
-	for (i = 0; i < nr_pages; i++) {
-		struct page *page = pages[i];
+	for (i = 0; i < pvec->nr; i++) {
+		struct page *page = pvec->pages[i];
 		struct pglist_data *pagepgdat = page_pgdat(page);
 
 		pgscanned++;
@@ -4213,4 +4213,4 @@ void check_move_unevictable_pages(struct page **pages, int nr_pages)
 		spin_unlock_irq(&pgdat->lru_lock);
 	}
 }
-#endif /* CONFIG_SHMEM */
+EXPORT_SYMBOL_GPL(check_move_unevictable_pages);
-- 
2.19.1
