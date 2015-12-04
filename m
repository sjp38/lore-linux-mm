Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 953DD6B025B
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 10:59:10 -0500 (EST)
Received: by wmec201 with SMTP id c201so70899450wme.1
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 07:59:10 -0800 (PST)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [87.106.93.118])
        by mx.google.com with ESMTP id up7si19358527wjc.121.2015.12.04.07.59.09
        for <linux-mm@kvack.org>;
        Fri, 04 Dec 2015 07:59:09 -0800 (PST)
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: [PATCH v2 2/2] drm/i915: Disable shrinker for non-swapped backed objects
Date: Fri,  4 Dec 2015 15:58:54 +0000
Message-Id: <1449244734-25733-2-git-send-email-chris@chris-wilson.co.uk>
In-Reply-To: <1449244734-25733-1-git-send-email-chris@chris-wilson.co.uk>
References: <1449244734-25733-1-git-send-email-chris@chris-wilson.co.uk>
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

v2: frontswap registers extra swap pages available for the system, so it
is already include in the count of available swap pages.

v3: Use get_nr_swap_pages() to query the currently available amount of
swap space. This should also stop us from shrinking the GPU buffers if
we ever run out of swap space. Though at that point, we would expect the
oom-notifier to be running and failing miserably...

Reported-by: Akash Goel <akash.goel@intel.com>
Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
Cc: linux-mm@kvack.org
Cc: Akash Goel <akash.goel@intel.com>
Cc: sourab.gupta@intel.com
---
 drivers/gpu/drm/i915/i915_gem_shrinker.c | 60 +++++++++++++++++++++++---------
 1 file changed, 44 insertions(+), 16 deletions(-)

diff --git a/drivers/gpu/drm/i915/i915_gem_shrinker.c b/drivers/gpu/drm/i915/i915_gem_shrinker.c
index f7df54a8ee2b..16da9c1422cc 100644
--- a/drivers/gpu/drm/i915/i915_gem_shrinker.c
+++ b/drivers/gpu/drm/i915/i915_gem_shrinker.c
@@ -47,6 +47,46 @@ static bool mutex_is_locked_by(struct mutex *mutex, struct task_struct *task)
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
+	return get_nr_swap_pages() > 0;
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
+	 * in releasing our pin count on the pages themselves.
+	 */
+	if (obj->pages_pin_count != num_vma_bound(obj))
+		return false;
+
+	/* We can only return physical pages to the system if we can either
+	 * discard the contents (because the user has marked them as being
+	 * purgeable) or if we can move their contents out to swap.
+	 */
+	return swap_available() || obj->madv == I915_MADV_DONTNEED;
+}
+
 /**
  * i915_gem_shrink - Shrink buffer object caches
  * @dev_priv: i915 device
@@ -129,6 +169,9 @@ i915_gem_shrink(struct drm_i915_private *dev_priv,
 			if ((flags & I915_SHRINK_ACTIVE) == 0 && obj->active)
 				continue;
 
+			if (!can_release_pages(obj))
+				continue;
+
 			drm_gem_object_reference(&obj->base);
 
 			/* For the unbound phase, this should be a no-op! */
@@ -188,21 +231,6 @@ static bool i915_gem_shrinker_lock(struct drm_device *dev, bool *unlock)
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
@@ -222,7 +250,7 @@ i915_gem_shrinker_count(struct shrinker *shrinker, struct shrink_control *sc)
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
