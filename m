Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id CA6B36B0003
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 06:13:59 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id n5-v6so8232349pgv.6
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 03:13:59 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s17-v6sor43289423pfi.2.2018.11.05.03.13.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Nov 2018 03:13:58 -0800 (PST)
From: Kuo-Hsin Yang <vovoy@chromium.org>
Subject: [PATCH v4] mm, drm/i915: mark pinned shmemfs pages as unevictable
Date: Mon,  5 Nov 2018 19:13:48 +0800
Message-Id: <20181105111348.182492-1-vovoy@chromium.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, intel-gfx@lists.freedesktop.org, linux-mm@kvack.org
Cc: Kuo-Hsin Yang <vovoy@chromium.org>, Chris Wilson <chris@chris-wilson.co.uk>, Michal Hocko <mhocko@suse.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>

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
Cc: Michal Hocko <mhocko@suse.com>
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>
Signed-off-by: Kuo-Hsin Yang <vovoy@chromium.org>
---
Changes for v4:
 Export pagevec API check_move_unevictable_pages().

Changes for v3:
 Use check_move_lru_page instead of shmem_unlock_mapping to move pages
 to appropriate lru lists.

Changes for v2:
 Squashed the two patches.

 Documentation/vm/unevictable-lru.rst |  4 +++-
 drivers/gpu/drm/i915/i915_gem.c      | 25 +++++++++++++++++++++++--
 include/linux/swap.h                 |  4 +++-
 mm/shmem.c                           |  2 +-
 mm/vmscan.c                          | 18 +++++++++---------
 5 files changed, 39 insertions(+), 14 deletions(-)

diff --git a/Documentation/vm/unevictable-lru.rst b/Documentation/vm/unevictable-lru.rst
index fdd84cb8d511..a812fb55136d 100644
--- a/Documentation/vm/unevictable-lru.rst
+++ b/Documentation/vm/unevictable-lru.rst
@@ -143,7 +143,7 @@ using a number of wrapper functions:
 	Query the address space, and return true if it is completely
 	unevictable.
 
-These are currently used in two places in the kernel:
+These are currently used in three places in the kernel:
 
  (1) By ramfs to mark the address spaces of its inodes when they are created,
      and this mark remains for the life of the inode.
@@ -154,6 +154,8 @@ These are currently used in two places in the kernel:
      swapped out; the application must touch the pages manually if it wants to
      ensure they're in memory.
 
+ (3) By the i915 driver to mark pinned address space until it's unpinned.
+
 
 Detecting Unevictable Pages
 ---------------------------
diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index 0c8aa57ce83b..7972eeb2e921 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -2381,12 +2381,22 @@ void __i915_gem_object_invalidate(struct drm_i915_gem_object *obj)
 	invalidate_mapping_pages(mapping, 0, (loff_t)-1);
 }
 
+/* Move pages to appropriate lru and release the pagevec */
+static inline void check_release_pagevec(struct pagevec *pvec)
+{
+	if (pagevec_count(pvec)) {
+		check_move_unevictable_pages(pvec);
+		__pagevec_release(pvec);
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
 
@@ -2395,6 +2405,9 @@ i915_gem_object_put_pages_gtt(struct drm_i915_gem_object *obj,
 	if (i915_gem_object_needs_bit17_swizzle(obj))
 		i915_gem_object_save_bit_17_swizzle(obj, pages);
 
+	mapping_clear_unevictable(file_inode(obj->base.filp)->i_mapping);
+
+	pagevec_init(&pvec);
 	for_each_sgt_page(page, sgt_iter, pages) {
 		if (obj->mm.dirty)
 			set_page_dirty(page);
@@ -2402,8 +2415,10 @@ i915_gem_object_put_pages_gtt(struct drm_i915_gem_object *obj,
 		if (obj->mm.madv == I915_MADV_WILLNEED)
 			mark_page_accessed(page);
 
-		put_page(page);
+		if (!pagevec_add(&pvec, page))
+			check_release_pagevec(&pvec);
 	}
+	check_release_pagevec(&pvec);
 	obj->mm.dirty = false;
 
 	sg_free_table(pages);
@@ -2526,6 +2541,7 @@ static int i915_gem_object_get_pages_gtt(struct drm_i915_gem_object *obj)
 	unsigned int sg_page_sizes;
 	gfp_t noreclaim;
 	int ret;
+	struct pagevec pvec;
 
 	/*
 	 * Assert that the object is not currently in any GPU domain. As it
@@ -2559,6 +2575,7 @@ static int i915_gem_object_get_pages_gtt(struct drm_i915_gem_object *obj)
 	 * Fail silently without starting the shrinker
 	 */
 	mapping = obj->base.filp->f_mapping;
+	mapping_set_unevictable(mapping);
 	noreclaim = mapping_gfp_constraint(mapping, ~__GFP_RECLAIM);
 	noreclaim |= __GFP_NORETRY | __GFP_NOWARN;
 
@@ -2673,8 +2690,12 @@ static int i915_gem_object_get_pages_gtt(struct drm_i915_gem_object *obj)
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
index d8a07a4f171d..a8f6d5d89524 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -18,6 +18,8 @@ struct notifier_block;
 
 struct bio;
 
+struct pagevec;
+
 #define SWAP_FLAG_PREFER	0x8000	/* set if swap priority specified */
 #define SWAP_FLAG_PRIO_MASK	0x7fff
 #define SWAP_FLAG_PRIO_SHIFT	0
@@ -369,7 +371,7 @@ static inline int node_reclaim(struct pglist_data *pgdat, gfp_t mask,
 #endif
 
 extern int page_evictable(struct page *page);
-extern void check_move_unevictable_pages(struct page **, int nr_pages);
+extern void check_move_unevictable_pages(struct pagevec *pvec);
 
 extern int kswapd_run(int nid);
 extern void kswapd_stop(int nid);
diff --git a/mm/shmem.c b/mm/shmem.c
index 56bf122e0bb4..6ada7c97264d 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -756,7 +756,7 @@ void shmem_unlock_mapping(struct address_space *mapping)
 			break;
 		index = indices[pvec.nr - 1] + 1;
 		pagevec_remove_exceptionals(&pvec);
-		check_move_unevictable_pages(pvec.pages, pvec.nr);
+		check_move_unevictable_pages(&pvec);
 		pagevec_release(&pvec);
 		cond_resched();
 	}
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 62ac0c488624..6d0d08a33144 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -50,6 +50,7 @@
 #include <linux/printk.h>
 #include <linux/dax.h>
 #include <linux/psi.h>
+#include <linux/pagevec.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -4184,15 +4185,13 @@ int page_evictable(struct page *page)
 
 #ifdef CONFIG_SHMEM
 /**
- * check_move_unevictable_pages - check pages for evictability and move to appropriate zone lru list
- * @pages:	array of pages to check
- * @nr_pages:	number of pages to check
+ * check_move_unevictable_pages - move evictable pages to appropriate evictable
+ * lru lists
+ * @pvec: pagevec with pages to check
  *
- * Checks pages for evictability and moves them to the appropriate lru list.
- *
- * This function is only used for SysV IPC SHM_UNLOCK.
+ * This function is only used to move shmem pages.
  */
-void check_move_unevictable_pages(struct page **pages, int nr_pages)
+void check_move_unevictable_pages(struct pagevec *pvec)
 {
 	struct lruvec *lruvec;
 	struct pglist_data *pgdat = NULL;
@@ -4200,8 +4199,8 @@ void check_move_unevictable_pages(struct page **pages, int nr_pages)
 	int pgrescued = 0;
 	int i;
 
-	for (i = 0; i < nr_pages; i++) {
-		struct page *page = pages[i];
+	for (i = 0; i < pvec->nr; i++) {
+		struct page *page = pvec->pages[i];
 		struct pglist_data *pagepgdat = page_pgdat(page);
 
 		pgscanned++;
@@ -4233,4 +4232,5 @@ void check_move_unevictable_pages(struct page **pages, int nr_pages)
 		spin_unlock_irq(&pgdat->lru_lock);
 	}
 }
+EXPORT_SYMBOL(check_move_unevictable_pages);
 #endif /* CONFIG_SHMEM */
-- 
2.19.1.930.g4563a0d9d0-goog
