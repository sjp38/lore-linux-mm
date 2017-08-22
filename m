Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 72F792806D2
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 09:54:07 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id y44so33925868wrd.13
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 06:54:07 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id 45si11584859wrk.131.2017.08.22.06.54.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Aug 2017 06:54:06 -0700 (PDT)
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: [PATCH 2/2] drm/i915: Wire up shrinkctl->nr_scanned
Date: Tue, 22 Aug 2017 14:53:25 +0100
Message-Id: <20170822135325.9191-2-chris@chris-wilson.co.uk>
In-Reply-To: <20170822135325.9191-1-chris@chris-wilson.co.uk>
References: <20170815153010.e3cfc177af0b2c0dc421b84c@linux-foundation.org>
 <20170822135325.9191-1-chris@chris-wilson.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: intel-gfx@lists.freedesktop.org, Chris Wilson <chris@chris-wilson.co.uk>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Shaohua Li <shli@fb.com>

shrink_slab() allows us to report back the number of objects we
successfully scanned (out of the target shrinkctl->nr_to_scan). As
report the number of pages owned by each GEM object as a separate item
to the shrinker, we cannot precisely control the number of shrinker
objects we scan on each pass; and indeed may free more than requested.
If we fail to tell the shrinker about the number of objects we process,
it will continue to hold a grudge against us as any objects left
unscanned are added to the next reclaim -- and so we will keep on
"unfairly" shrinking our own slab in comparison to other slabs.

Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org
---
 drivers/gpu/drm/i915/i915_debugfs.c      |  4 ++--
 drivers/gpu/drm/i915/i915_drv.h          |  1 +
 drivers/gpu/drm/i915/i915_gem.c          |  4 ++--
 drivers/gpu/drm/i915/i915_gem_gtt.c      |  2 +-
 drivers/gpu/drm/i915/i915_gem_shrinker.c | 24 ++++++++++++++++++------
 5 files changed, 24 insertions(+), 11 deletions(-)

diff --git a/drivers/gpu/drm/i915/i915_debugfs.c b/drivers/gpu/drm/i915/i915_debugfs.c
index 6bad53f89738..ed979cc6fb5d 100644
--- a/drivers/gpu/drm/i915/i915_debugfs.c
+++ b/drivers/gpu/drm/i915/i915_debugfs.c
@@ -4338,10 +4338,10 @@ i915_drop_caches_set(void *data, u64 val)
 
 	lockdep_set_current_reclaim_state(GFP_KERNEL);
 	if (val & DROP_BOUND)
-		i915_gem_shrink(dev_priv, LONG_MAX, I915_SHRINK_BOUND);
+		i915_gem_shrink(dev_priv, LONG_MAX, NULL, I915_SHRINK_BOUND);
 
 	if (val & DROP_UNBOUND)
-		i915_gem_shrink(dev_priv, LONG_MAX, I915_SHRINK_UNBOUND);
+		i915_gem_shrink(dev_priv, LONG_MAX, NULL, I915_SHRINK_UNBOUND);
 
 	if (val & DROP_SHRINK_ALL)
 		i915_gem_shrink_all(dev_priv);
diff --git a/drivers/gpu/drm/i915/i915_drv.h b/drivers/gpu/drm/i915/i915_drv.h
index b78605a9f1b5..c3299eaac1af 100644
--- a/drivers/gpu/drm/i915/i915_drv.h
+++ b/drivers/gpu/drm/i915/i915_drv.h
@@ -3752,6 +3752,7 @@ i915_gem_object_create_internal(struct drm_i915_private *dev_priv,
 /* i915_gem_shrinker.c */
 unsigned long i915_gem_shrink(struct drm_i915_private *dev_priv,
 			      unsigned long target,
+			      unsigned long *nr_scanned,
 			      unsigned flags);
 #define I915_SHRINK_PURGEABLE 0x1
 #define I915_SHRINK_UNBOUND 0x2
diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index a2714898ff01..c06091718bb4 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -2339,7 +2339,7 @@ i915_gem_object_get_pages_gtt(struct drm_i915_gem_object *obj)
 				goto err_sg;
 			}
 
-			i915_gem_shrink(dev_priv, 2 * page_count, *s++);
+			i915_gem_shrink(dev_priv, 2 * page_count, NULL, *s++);
 			cond_resched();
 
 			/* We've tried hard to allocate the memory by reaping
@@ -5037,7 +5037,7 @@ int i915_gem_freeze_late(struct drm_i915_private *dev_priv)
 	 * the objects as well, see i915_gem_freeze()
 	 */
 
-	i915_gem_shrink(dev_priv, -1UL, I915_SHRINK_UNBOUND);
+	i915_gem_shrink(dev_priv, -1UL, NULL, I915_SHRINK_UNBOUND);
 	i915_gem_drain_freed_objects(dev_priv);
 
 	spin_lock(&dev_priv->mm.obj_lock);
diff --git a/drivers/gpu/drm/i915/i915_gem_gtt.c b/drivers/gpu/drm/i915/i915_gem_gtt.c
index b6d5f1c6ef5e..8394fc2a21eb 100644
--- a/drivers/gpu/drm/i915/i915_gem_gtt.c
+++ b/drivers/gpu/drm/i915/i915_gem_gtt.c
@@ -2062,7 +2062,7 @@ int i915_gem_gtt_prepare_pages(struct drm_i915_gem_object *obj,
 		 */
 		GEM_BUG_ON(obj->mm.pages == pages);
 	} while (i915_gem_shrink(to_i915(obj->base.dev),
-				 obj->base.size >> PAGE_SHIFT,
+				 obj->base.size >> PAGE_SHIFT, NULL,
 				 I915_SHRINK_BOUND |
 				 I915_SHRINK_UNBOUND |
 				 I915_SHRINK_ACTIVE));
diff --git a/drivers/gpu/drm/i915/i915_gem_shrinker.c b/drivers/gpu/drm/i915/i915_gem_shrinker.c
index ee4df98f009d..c178a1c9ae47 100644
--- a/drivers/gpu/drm/i915/i915_gem_shrinker.c
+++ b/drivers/gpu/drm/i915/i915_gem_shrinker.c
@@ -198,6 +198,7 @@ static void __start_writeback(struct drm_i915_gem_object *obj)
  * i915_gem_shrink - Shrink buffer object caches
  * @dev_priv: i915 device
  * @target: amount of memory to make available, in pages
+ * @nr_scanned: optional output for number of pages scanned (incremental)
  * @flags: control flags for selecting cache types
  *
  * This function is the main interface to the shrinker. It will try to release
@@ -220,7 +221,9 @@ static void __start_writeback(struct drm_i915_gem_object *obj)
  */
 unsigned long
 i915_gem_shrink(struct drm_i915_private *dev_priv,
-		unsigned long target, unsigned flags)
+		unsigned long target,
+		unsigned long *nr_scanned,
+		unsigned flags)
 {
 	const struct {
 		struct list_head *list;
@@ -231,6 +234,7 @@ i915_gem_shrink(struct drm_i915_private *dev_priv,
 		{ NULL, 0 },
 	}, *phase;
 	unsigned long count = 0;
+	unsigned long scanned = 0;
 	bool unlock;
 
 	if (!shrinker_lock(dev_priv, &unlock))
@@ -318,6 +322,7 @@ i915_gem_shrink(struct drm_i915_private *dev_priv,
 				}
 				mutex_unlock(&obj->mm.lock);
 			}
+			scanned += obj->base.size >> PAGE_SHIFT;
 
 			spin_lock(&dev_priv->mm.obj_lock);
 		}
@@ -332,6 +337,8 @@ i915_gem_shrink(struct drm_i915_private *dev_priv,
 
 	shrinker_unlock(dev_priv, unlock);
 
+	if (nr_scanned)
+		*nr_scanned += scanned;
 	return count;
 }
 
@@ -354,7 +361,7 @@ unsigned long i915_gem_shrink_all(struct drm_i915_private *dev_priv)
 	unsigned long freed;
 
 	intel_runtime_pm_get(dev_priv);
-	freed = i915_gem_shrink(dev_priv, -1UL,
+	freed = i915_gem_shrink(dev_priv, -1UL, NULL,
 				I915_SHRINK_BOUND |
 				I915_SHRINK_UNBOUND |
 				I915_SHRINK_ACTIVE);
@@ -411,23 +418,28 @@ i915_gem_shrinker_scan(struct shrinker *shrinker, struct shrink_control *sc)
 	unsigned long freed;
 	bool unlock;
 
+	sc->nr_scanned = 0;
+
 	if (!shrinker_lock(dev_priv, &unlock))
 		return SHRINK_STOP;
 
 	freed = i915_gem_shrink(dev_priv,
 				sc->nr_to_scan,
+				&sc->nr_scanned,
 				I915_SHRINK_BOUND |
 				I915_SHRINK_UNBOUND |
 				I915_SHRINK_PURGEABLE);
 	if (freed < sc->nr_to_scan)
 		freed += i915_gem_shrink(dev_priv,
-					 sc->nr_to_scan - freed,
+					 sc->nr_to_scan - sc->nr_scanned,
+					 &sc->nr_scanned,
 					 I915_SHRINK_BOUND |
 					 I915_SHRINK_UNBOUND);
 	if (freed < sc->nr_to_scan && current_is_kswapd()) {
 		intel_runtime_pm_get(dev_priv);
 		freed += i915_gem_shrink(dev_priv,
-					 sc->nr_to_scan - freed,
+					 sc->nr_to_scan - sc->nr_scanned,
+					 &sc->nr_scanned,
 					 I915_SHRINK_ACTIVE |
 					 I915_SHRINK_BOUND |
 					 I915_SHRINK_UNBOUND);
@@ -436,7 +448,7 @@ i915_gem_shrinker_scan(struct shrinker *shrinker, struct shrink_control *sc)
 
 	shrinker_unlock(dev_priv, unlock);
 
-	return freed;
+	return sc->nr_scanned ? freed : SHRINK_STOP;
 }
 
 static bool
@@ -525,7 +537,7 @@ i915_gem_shrinker_vmap(struct notifier_block *nb, unsigned long event, void *ptr
 		goto out;
 
 	intel_runtime_pm_get(dev_priv);
-	freed_pages += i915_gem_shrink(dev_priv, -1UL,
+	freed_pages += i915_gem_shrink(dev_priv, -1UL, NULL,
 				       I915_SHRINK_BOUND |
 				       I915_SHRINK_UNBOUND |
 				       I915_SHRINK_ACTIVE |
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
