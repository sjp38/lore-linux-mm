Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 753B86B049B
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 18:45:55 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 128so439681wmj.14
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 15:45:55 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l9si51944wra.460.2017.08.22.15.45.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Aug 2017 15:45:53 -0700 (PDT)
Date: Tue, 22 Aug 2017 15:45:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] drm/i915: Wire up shrinkctl->nr_scanned
Message-Id: <20170822154550.33c8cc61c21e5ccf72959dd1@linux-foundation.org>
In-Reply-To: <20170822135325.9191-2-chris@chris-wilson.co.uk>
References: <20170815153010.e3cfc177af0b2c0dc421b84c@linux-foundation.org>
	<20170822135325.9191-1-chris@chris-wilson.co.uk>
	<20170822135325.9191-2-chris@chris-wilson.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: linux-mm@kvack.org, intel-gfx@lists.freedesktop.org, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Shaohua Li <shli@fb.com>

On Tue, 22 Aug 2017 14:53:25 +0100 Chris Wilson <chris@chris-wilson.co.uk> wrote:

> shrink_slab() allows us to report back the number of objects we
> successfully scanned (out of the target shrinkctl->nr_to_scan). As
> report the number of pages owned by each GEM object as a separate item
> to the shrinker, we cannot precisely control the number of shrinker
> objects we scan on each pass; and indeed may free more than requested.
> If we fail to tell the shrinker about the number of objects we process,
> it will continue to hold a grudge against us as any objects left
> unscanned are added to the next reclaim -- and so we will keep on
> "unfairly" shrinking our own slab in comparison to other slabs.

It's unclear which tree this is against but I think I got it all fixed
up.  Please check the changes to i915_gem_shrink().

From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: drm/i915: wire up shrinkctl->nr_scanned

shrink_slab() allows us to report back the number of objects we
successfully scanned (out of the target shrinkctl->nr_to_scan).  As report
the number of pages owned by each GEM object as a separate item to the
shrinker, we cannot precisely control the number of shrinker objects we
scan on each pass; and indeed may free more than requested.  If we fail to
tell the shrinker about the number of objects we process, it will continue
to hold a grudge against us as any objects left unscanned are added to the
next reclaim -- and so we will keep on "unfairly" shrinking our own slab
in comparison to other slabs.

Link: http://lkml.kernel.org/r/20170822135325.9191-2-chris@chris-wilson.co.uk
Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Shaohua Li <shli@fb.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/gpu/drm/i915/i915_debugfs.c      |    4 +--
 drivers/gpu/drm/i915/i915_drv.h          |    1 
 drivers/gpu/drm/i915/i915_gem.c          |    4 +--
 drivers/gpu/drm/i915/i915_gem_gtt.c      |    2 -
 drivers/gpu/drm/i915/i915_gem_shrinker.c |   24 +++++++++++++++------
 5 files changed, 24 insertions(+), 11 deletions(-)

diff -puN drivers/gpu/drm/i915/i915_debugfs.c~drm-i915-wire-up-shrinkctl-nr_scanned drivers/gpu/drm/i915/i915_debugfs.c
--- a/drivers/gpu/drm/i915/i915_debugfs.c~drm-i915-wire-up-shrinkctl-nr_scanned
+++ a/drivers/gpu/drm/i915/i915_debugfs.c
@@ -4333,10 +4333,10 @@ i915_drop_caches_set(void *data, u64 val
 
 	lockdep_set_current_reclaim_state(GFP_KERNEL);
 	if (val & DROP_BOUND)
-		i915_gem_shrink(dev_priv, LONG_MAX, I915_SHRINK_BOUND);
+		i915_gem_shrink(dev_priv, LONG_MAX, NULL, I915_SHRINK_BOUND);
 
 	if (val & DROP_UNBOUND)
-		i915_gem_shrink(dev_priv, LONG_MAX, I915_SHRINK_UNBOUND);
+		i915_gem_shrink(dev_priv, LONG_MAX, NULL, I915_SHRINK_UNBOUND);
 
 	if (val & DROP_SHRINK_ALL)
 		i915_gem_shrink_all(dev_priv);
diff -puN drivers/gpu/drm/i915/i915_drv.h~drm-i915-wire-up-shrinkctl-nr_scanned drivers/gpu/drm/i915/i915_drv.h
--- a/drivers/gpu/drm/i915/i915_drv.h~drm-i915-wire-up-shrinkctl-nr_scanned
+++ a/drivers/gpu/drm/i915/i915_drv.h
@@ -3628,6 +3628,7 @@ i915_gem_object_create_internal(struct d
 /* i915_gem_shrinker.c */
 unsigned long i915_gem_shrink(struct drm_i915_private *dev_priv,
 			      unsigned long target,
+			      unsigned long *nr_scanned,
 			      unsigned flags);
 #define I915_SHRINK_PURGEABLE 0x1
 #define I915_SHRINK_UNBOUND 0x2
diff -puN drivers/gpu/drm/i915/i915_gem.c~drm-i915-wire-up-shrinkctl-nr_scanned drivers/gpu/drm/i915/i915_gem.c
--- a/drivers/gpu/drm/i915/i915_gem.c~drm-i915-wire-up-shrinkctl-nr_scanned
+++ a/drivers/gpu/drm/i915/i915_gem.c
@@ -2408,7 +2408,7 @@ rebuild_st:
 				goto err_sg;
 			}
 
-			i915_gem_shrink(dev_priv, 2 * page_count, *s++);
+			i915_gem_shrink(dev_priv, 2 * page_count, NULL, *s++);
 			cond_resched();
 
 			/* We've tried hard to allocate the memory by reaping
@@ -5012,7 +5012,7 @@ int i915_gem_freeze_late(struct drm_i915
 	 * the objects as well, see i915_gem_freeze()
 	 */
 
-	i915_gem_shrink(dev_priv, -1UL, I915_SHRINK_UNBOUND);
+	i915_gem_shrink(dev_priv, -1UL, NULL, I915_SHRINK_UNBOUND);
 	i915_gem_drain_freed_objects(dev_priv);
 
 	mutex_lock(&dev_priv->drm.struct_mutex);
diff -puN drivers/gpu/drm/i915/i915_gem_gtt.c~drm-i915-wire-up-shrinkctl-nr_scanned drivers/gpu/drm/i915/i915_gem_gtt.c
--- a/drivers/gpu/drm/i915/i915_gem_gtt.c~drm-i915-wire-up-shrinkctl-nr_scanned
+++ a/drivers/gpu/drm/i915/i915_gem_gtt.c
@@ -2061,7 +2061,7 @@ int i915_gem_gtt_prepare_pages(struct dr
 		 */
 		GEM_BUG_ON(obj->mm.pages == pages);
 	} while (i915_gem_shrink(to_i915(obj->base.dev),
-				 obj->base.size >> PAGE_SHIFT,
+				 obj->base.size >> PAGE_SHIFT, NULL,
 				 I915_SHRINK_BOUND |
 				 I915_SHRINK_UNBOUND |
 				 I915_SHRINK_ACTIVE));
diff -puN drivers/gpu/drm/i915/i915_gem_shrinker.c~drm-i915-wire-up-shrinkctl-nr_scanned drivers/gpu/drm/i915/i915_gem_shrinker.c
--- a/drivers/gpu/drm/i915/i915_gem_shrinker.c~drm-i915-wire-up-shrinkctl-nr_scanned
+++ a/drivers/gpu/drm/i915/i915_gem_shrinker.c
@@ -136,6 +136,7 @@ static bool unsafe_drop_pages(struct drm
  * i915_gem_shrink - Shrink buffer object caches
  * @dev_priv: i915 device
  * @target: amount of memory to make available, in pages
+ * @nr_scanned: optional output for number of pages scanned (incremental)
  * @flags: control flags for selecting cache types
  *
  * This function is the main interface to the shrinker. It will try to release
@@ -158,7 +159,9 @@ static bool unsafe_drop_pages(struct drm
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
@@ -169,6 +172,7 @@ i915_gem_shrink(struct drm_i915_private
 		{ NULL, 0 },
 	}, *phase;
 	unsigned long count = 0;
+	unsigned long scanned = 0;
 	bool unlock;
 
 	if (!shrinker_lock(dev_priv, &unlock))
@@ -249,6 +253,7 @@ i915_gem_shrink(struct drm_i915_private
 					count += obj->base.size >> PAGE_SHIFT;
 				}
 				mutex_unlock(&obj->mm.lock);
+				scanned += obj->base.size >> PAGE_SHIFT;
 			}
 		}
 		list_splice_tail(&still_in_list, phase->list);
@@ -261,6 +266,8 @@ i915_gem_shrink(struct drm_i915_private
 
 	shrinker_unlock(dev_priv, unlock);
 
+	if (nr_scanned)
+		*nr_scanned += scanned;
 	return count;
 }
 
@@ -283,7 +290,7 @@ unsigned long i915_gem_shrink_all(struct
 	unsigned long freed;
 
 	intel_runtime_pm_get(dev_priv);
-	freed = i915_gem_shrink(dev_priv, -1UL,
+	freed = i915_gem_shrink(dev_priv, -1UL, NULL,
 				I915_SHRINK_BOUND |
 				I915_SHRINK_UNBOUND |
 				I915_SHRINK_ACTIVE);
@@ -329,23 +336,28 @@ i915_gem_shrinker_scan(struct shrinker *
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
@@ -354,7 +366,7 @@ i915_gem_shrinker_scan(struct shrinker *
 
 	shrinker_unlock(dev_priv, unlock);
 
-	return freed;
+	return sc->nr_scanned ? freed : SHRINK_STOP;
 }
 
 static bool
@@ -453,7 +465,7 @@ i915_gem_shrinker_vmap(struct notifier_b
 		goto out;
 
 	intel_runtime_pm_get(dev_priv);
-	freed_pages += i915_gem_shrink(dev_priv, -1UL,
+	freed_pages += i915_gem_shrink(dev_priv, -1UL, NULL,
 				       I915_SHRINK_BOUND |
 				       I915_SHRINK_UNBOUND |
 				       I915_SHRINK_ACTIVE |
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
