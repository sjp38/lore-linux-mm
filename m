Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id AE1616B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 13:37:07 -0500 (EST)
Received: by wmww144 with SMTP id w144so191694399wmw.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 10:37:07 -0800 (PST)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [87.106.93.118])
        by mx.google.com with ESMTP id eu16si36290917wjc.107.2015.11.25.10.37.05
        for <linux-mm@kvack.org>;
        Wed, 25 Nov 2015 10:37:06 -0800 (PST)
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: [PATCH v2] drm/i915: Disable shrinker for non-swapped backed objects
Date: Wed, 25 Nov 2015 18:36:56 +0000
Message-Id: <1448476616-5257-1-git-send-email-chris@chris-wilson.co.uk>
In-Reply-To: <20151124231738.GA15770@nuc-i3427.alporthouse.com>
References: <20151124231738.GA15770@nuc-i3427.alporthouse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: intel-gfx@lists.freedesktop.org
Cc: Chris Wilson <chris@chris-wilson.co.uk>, linux-mm@kvack.org, Akash Goel <akash.goel@intel.com>, sourab.gupta@intel.com

If the system has no available swap pages, we cannot make forward
progress in the shrinker by releasing active pages, only by releasing
purgeable pages which are immediately reaped. Take total_swap_pages into
account when counting up available objects to be shrunk and subsequently
shrinking them. By doing so, we avoid unbinding objects that cannot be
shrunk and so wasting CPU cycles flushing those objects from the GPU to
the system and then immediately back again (as they will more than
likely be reused shortly after).

Based on a patch by Akash Goel.

v2: Check for frontswap without physical swap (or dedicated swap space).
If frontswap is available, we may be able to compress the GPU pages
instead of swapping out to disk. In this case, we do want to shrink GPU
objects and so make them available for compressing.

Reported-by: Akash Goel <akash.goel@intel.com>
Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
Cc: linux-mm@kvack.org
Cc: Akash Goel <akash.goel@intel.com>
Cc: sourab.gupta@intel.com
---
 drivers/gpu/drm/i915/i915_gem_shrinker.c | 61 +++++++++++++++++++++++---------
 1 file changed, 45 insertions(+), 16 deletions(-)

diff --git a/drivers/gpu/drm/i915/i915_gem_shrinker.c b/drivers/gpu/drm/i915/i915_gem_shrinker.c
index f7df54a8ee2b..451a75a056da 100644
--- a/drivers/gpu/drm/i915/i915_gem_shrinker.c
+++ b/drivers/gpu/drm/i915/i915_gem_shrinker.c
@@ -22,6 +22,7 @@
  *
  */
 
+#include <linux/frontswap.h>
 #include <linux/oom.h>
 #include <linux/shmem_fs.h>
 #include <linux/slab.h>
@@ -47,6 +48,46 @@ static bool mutex_is_locked_by(struct mutex *mutex, struct task_struct *task)
 #endif
 }
 
+static int num_vma_bound(struct drm_i915_gem_object *obj)
+{
+	struct i915_vma *vma;
+	int count = 0;
+
+	list_for_each_entry(vma, &obj->vma_list, vma_link) {
+		if (drm_mm_node_allocated(&vma->node))
+			count++;
+		if (vma->pin_count)
+			count++;
+	}
+
+	return count;
+}
+
+static bool swap_available(void)
+{
+	return total_swap_pages || frontswap_enabled;
+}
+
+static bool can_release_pages(struct drm_i915_gem_object *obj)
+{
+	/* Only report true if by unbinding the object and putting its pages
+	 * we can actually make forward progress towards freeing physical
+	 * pages.
+	 *
+	 * If the pages are pinned for any other reason than being bound
+	 * to the GPU, simply unbinding from the GPU is not going to succeed
+	 * in release our pin count on the pages themselves.
+	 */
+	if (obj->pages_pin_count != num_vma_bound(obj))
+		return false;
+
+	/* We can only return physical pages if we either discard them
+	 * (because the user has marked them as being purgeable) or if
+	 * we can move their contents out to swap.
+	 */
+	return swap_available() || obj->madv == I915_MADV_DONTNEED;
+}
+
 /**
  * i915_gem_shrink - Shrink buffer object caches
  * @dev_priv: i915 device
@@ -129,6 +170,9 @@ i915_gem_shrink(struct drm_i915_private *dev_priv,
 			if ((flags & I915_SHRINK_ACTIVE) == 0 && obj->active)
 				continue;
 
+			if (!can_release_pages(obj))
+				continue;
+
 			drm_gem_object_reference(&obj->base);
 
 			/* For the unbound phase, this should be a no-op! */
@@ -188,21 +232,6 @@ static bool i915_gem_shrinker_lock(struct drm_device *dev, bool *unlock)
 	return true;
 }
 
-static int num_vma_bound(struct drm_i915_gem_object *obj)
-{
-	struct i915_vma *vma;
-	int count = 0;
-
-	list_for_each_entry(vma, &obj->vma_list, vma_link) {
-		if (drm_mm_node_allocated(&vma->node))
-			count++;
-		if (vma->pin_count)
-			count++;
-	}
-
-	return count;
-}
-
 static unsigned long
 i915_gem_shrinker_count(struct shrinker *shrinker, struct shrink_control *sc)
 {
@@ -222,7 +251,7 @@ i915_gem_shrinker_count(struct shrinker *shrinker, struct shrink_control *sc)
 			count += obj->base.size >> PAGE_SHIFT;
 
 	list_for_each_entry(obj, &dev_priv->mm.bound_list, global_list) {
-		if (!obj->active && obj->pages_pin_count == num_vma_bound(obj))
+		if (!obj->active && can_release_pages(obj))
 			count += obj->base.size >> PAGE_SHIFT;
 	}
 
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
