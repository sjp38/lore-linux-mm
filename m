Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id EBE176B0303
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 04:20:02 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id n5-v6so11764613plp.16
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 01:20:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 193-v6sor26396848pgb.32.2018.10.31.01.20.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Oct 2018 01:20:01 -0700 (PDT)
From: Kuo-Hsin Yang <vovoy@chromium.org>
Subject: [PATCH v3] mm, drm/i915: mark pinned shmemfs pages as unevictable
Date: Wed, 31 Oct 2018 16:19:45 +0800
Message-Id: <20181031081945.207709-1-vovoy@chromium.org>
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

Add check_move_lru_page() to move page to appropriate lru list.

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
The previous mapping_set_unevictable patch is worse on gem_syslatency
because it defers to vmscan to move these pages to the unevictable list
and the test measures latency to allocate 2MiB pages. This performance
impact can be solved by explicit moving pages to the unevictable list in
the i915 function.

Chris, can you help to run the "igt/benchmarks/gem_syslatency -t 120 -b -m"
test with this patch on your testing machine? I tried to run the test on
a Celeron N4000, 4GB Ram machine. The mean value with this patch is
similar to that with the mlock patch.

x tip-mean.txt # current stock i915
+ lock_vma-mean.txt # the old mlock patch
* mapping-mean.txt # this patch

   N        Min        Max     Median        Avg     Stddev
x 60    548.898   2563.653   2149.573   1999.273    480.837
+ 60    479.049   2119.902   1964.399   1893.226    314.736
* 60    455.358   3212.368   1991.308   1903.686    411.448

Changes for v3:
 Use check_move_lru_page instead of shmem_unlock_mapping to move pages
 to appropriate lru lists.

Changes for v2:
 Squashed the two patches.

 Documentation/vm/unevictable-lru.rst |  4 +++-
 drivers/gpu/drm/i915/i915_gem.c      | 20 +++++++++++++++++++-
 include/linux/swap.h                 |  1 +
 mm/vmscan.c                          | 20 +++++++++++++++++---
 4 files changed, 40 insertions(+), 5 deletions(-)

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
index 0c8aa57ce83b..6dc3ecef67e4 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -2387,6 +2387,7 @@ i915_gem_object_put_pages_gtt(struct drm_i915_gem_object *obj,
 {
 	struct sgt_iter sgt_iter;
 	struct page *page;
+	struct address_space *mapping;
 
 	__i915_gem_object_release_shmem(obj, pages, true);
 
@@ -2395,6 +2396,9 @@ i915_gem_object_put_pages_gtt(struct drm_i915_gem_object *obj,
 	if (i915_gem_object_needs_bit17_swizzle(obj))
 		i915_gem_object_save_bit_17_swizzle(obj, pages);
 
+	mapping = file_inode(obj->base.filp)->i_mapping;
+	mapping_clear_unevictable(mapping);
+
 	for_each_sgt_page(page, sgt_iter, pages) {
 		if (obj->mm.dirty)
 			set_page_dirty(page);
@@ -2402,6 +2406,10 @@ i915_gem_object_put_pages_gtt(struct drm_i915_gem_object *obj,
 		if (obj->mm.madv == I915_MADV_WILLNEED)
 			mark_page_accessed(page);
 
+		lock_page(page);
+		check_move_lru_page(page);
+		unlock_page(page);
+
 		put_page(page);
 	}
 	obj->mm.dirty = false;
@@ -2559,6 +2567,7 @@ static int i915_gem_object_get_pages_gtt(struct drm_i915_gem_object *obj)
 	 * Fail silently without starting the shrinker
 	 */
 	mapping = obj->base.filp->f_mapping;
+	mapping_set_unevictable(mapping);
 	noreclaim = mapping_gfp_constraint(mapping, ~__GFP_RECLAIM);
 	noreclaim |= __GFP_NORETRY | __GFP_NOWARN;
 
@@ -2630,6 +2639,10 @@ static int i915_gem_object_get_pages_gtt(struct drm_i915_gem_object *obj)
 		}
 		last_pfn = page_to_pfn(page);
 
+		lock_page(page);
+		check_move_lru_page(page);
+		unlock_page(page);
+
 		/* Check that the i965g/gm workaround works. */
 		WARN_ON((gfp & __GFP_DMA32) && (last_pfn >= 0x00100000UL));
 	}
@@ -2673,8 +2686,13 @@ static int i915_gem_object_get_pages_gtt(struct drm_i915_gem_object *obj)
 err_sg:
 	sg_mark_end(sg);
 err_pages:
-	for_each_sgt_page(page, sgt_iter, st)
+	mapping_clear_unevictable(mapping);
+	for_each_sgt_page(page, sgt_iter, st) {
+		lock_page(page);
+		check_move_lru_page(page);
+		unlock_page(page);
 		put_page(page);
+	}
 	sg_free_table(st);
 	kfree(st);
 
diff --git a/include/linux/swap.h b/include/linux/swap.h
index d8a07a4f171d..a812f24d69f2 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -370,6 +370,7 @@ static inline int node_reclaim(struct pglist_data *pgdat, gfp_t mask,
 
 extern int page_evictable(struct page *page);
 extern void check_move_unevictable_pages(struct page **, int nr_pages);
+extern void check_move_lru_page(struct page *page);
 
 extern int kswapd_run(int nid);
 extern void kswapd_stop(int nid);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 62ac0c488624..2399ccaa15e7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -4184,12 +4184,11 @@ int page_evictable(struct page *page)
 
 #ifdef CONFIG_SHMEM
 /**
- * check_move_unevictable_pages - check pages for evictability and move to appropriate zone lru list
+ * check_move_unevictable_pages - move evictable pages to appropriate evictable
+ * lru lists
  * @pages:	array of pages to check
  * @nr_pages:	number of pages to check
  *
- * Checks pages for evictability and moves them to the appropriate lru list.
- *
  * This function is only used for SysV IPC SHM_UNLOCK.
  */
 void check_move_unevictable_pages(struct page **pages, int nr_pages)
@@ -4234,3 +4233,18 @@ void check_move_unevictable_pages(struct page **pages, int nr_pages)
 	}
 }
 #endif /* CONFIG_SHMEM */
+
+/**
+ * check_move_lru_page - check page for evictability and move it to
+ * appropriate zone lru list
+ * @page: page to be move to appropriate lru list
+ *
+ * If this function fails to isolate an unevictable page, vmscan will handle it
+ * when it attempts to reclaim the page.
+ */
+void check_move_lru_page(struct page *page)
+{
+	if (!isolate_lru_page(page))
+		putback_lru_page(page);
+}
+EXPORT_SYMBOL(check_move_lru_page);
-- 
2.19.1.568.g152ad8e336-goog
