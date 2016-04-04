Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f47.google.com (mail-lf0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id E1BDE6B0277
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 09:18:22 -0400 (EDT)
Received: by mail-lf0-f47.google.com with SMTP id g184so95874026lfb.3
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 06:18:22 -0700 (PDT)
Received: from mail-lb0-x243.google.com (mail-lb0-x243.google.com. [2a00:1450:4010:c04::243])
        by mx.google.com with ESMTPS id pp9si15961043lbb.18.2016.04.04.06.18.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Apr 2016 06:18:21 -0700 (PDT)
Received: by mail-lb0-x243.google.com with SMTP id bc4so22223467lbc.0
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 06:18:21 -0700 (PDT)
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: [PATCH v4 2/2] drm/i915: Make GPU pages movable
Date: Mon,  4 Apr 2016 14:18:11 +0100
Message-Id: <1459775891-32442-2-git-send-email-chris@chris-wilson.co.uk>
In-Reply-To: <1459775891-32442-1-git-send-email-chris@chris-wilson.co.uk>
References: <1459775891-32442-1-git-send-email-chris@chris-wilson.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: intel-gfx@lists.freedesktop.org
Cc: Akash Goel <akash.goel@intel.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Sourab Gupta <sourab.gupta@intel.com>

From: Akash Goel <akash.goel@intel.com>

On a long run of more than 2-3 days, physical memory tends to get
fragmented severely, which considerably slows down the system. In such a
scenario, the shrinker is also unable to help as lack of memory is not
the actual problem, since it has been observed that there are enough free
pages of 0 order. This also manifests itself when an indiviual zone in
the mm runs out of pages and if we cannot migrate pages between zones,
the kernel hits an out-of-memory even though there are free pages (and
often all of swap) available.

To address the issue of external fragementation, kernel does a compaction
(which involves migration of pages) but it's efficacy depends upon how
many pages are marked as MOVABLE, as only those pages can be migrated.

Currently the backing pages for GFX buffers are allocated from shmemfs
with GFP_RECLAIMABLE flag, in units of 4KB pages.  In the case of limited
swap space, it may not be possible always to reclaim or swap-out pages of
all the inactive objects, to make way for free space allowing formation
of higher order groups of physically-contiguous pages on compaction.

Just marking the GPU pages as MOVABLE will not suffice, as i915.ko has to
pin the pages if they are in use by GPU, which will prevent their
migration. So the migratepage callback in shmem is also hooked up to get
a notification when kernel initiates the page migration. On the
notification, i915.ko appropriately unpin the pages.  With this we can
effectively mark the GPU pages as MOVABLE and hence mitigate the
fragmentation problem.

v2:
 - Rename the migration routine to gem_shrink_migratepage, move it to the
   shrinker file, and use the existing constructs (Chris)
 - To cleanup, add a new helper function to encapsulate all page migration
   skip conditions (Chris)
 - Add a new local helper function in shrinker file, for dropping the
   backing pages, and call the same from gem_shrink() also (Chris)

v3:
 - Fix/invert the check on the return value of unsafe_drop_pages (Chris)

v4:
 - Minor tidy

Testcase: igt/gem_shrink
Bugzilla: (e.g.) https://bugs.freedesktop.org/show_bug.cgi?id=90254
Cc: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org
Signed-off-by: Sourab Gupta <sourab.gupta@intel.com>
Signed-off-by: Akash Goel <akash.goel@intel.com>
Reviewed-by: Chris Wilson <chris@chris-wilson.co.uk>
---
 drivers/gpu/drm/i915/i915_drv.h          |   3 +
 drivers/gpu/drm/i915/i915_gem.c          |  13 ++-
 drivers/gpu/drm/i915/i915_gem_shrinker.c | 174 ++++++++++++++++++++++++++++---
 3 files changed, 175 insertions(+), 15 deletions(-)

diff --git a/drivers/gpu/drm/i915/i915_drv.h b/drivers/gpu/drm/i915/i915_drv.h
index dd187727c813..2c1d5c3af780 100644
--- a/drivers/gpu/drm/i915/i915_drv.h
+++ b/drivers/gpu/drm/i915/i915_drv.h
@@ -52,6 +52,7 @@
 #include <linux/intel-iommu.h>
 #include <linux/kref.h>
 #include <linux/pm_qos.h>
+#include <linux/shmem_fs.h>
 #include "intel_guc.h"
 #include "intel_dpll_mgr.h"
 
@@ -1234,6 +1235,8 @@ struct intel_l3_parity {
 };
 
 struct i915_gem_mm {
+	struct shmem_dev_info shmem_info;
+
 	/** Memory allocator for GTT stolen memory */
 	struct drm_mm stolen;
 	/** Protects the usage of the GTT stolen memory allocator. This is
diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index ca96fc12cdf4..7cef03efb539 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -2206,6 +2206,7 @@ i915_gem_object_put_pages_gtt(struct drm_i915_gem_object *obj)
 		if (obj->madv == I915_MADV_WILLNEED)
 			mark_page_accessed(page);
 
+		set_page_private(page, 0);
 		page_cache_release(page);
 	}
 	obj->dirty = 0;
@@ -2320,6 +2321,7 @@ i915_gem_object_get_pages_gtt(struct drm_i915_gem_object *obj)
 			sg->length += PAGE_SIZE;
 		}
 		last_pfn = page_to_pfn(page);
+		set_page_private(page, (unsigned long)obj);
 
 		/* Check that the i965g/gm workaround works. */
 		WARN_ON((gfp & __GFP_DMA32) && (last_pfn >= 0x00100000UL));
@@ -2345,8 +2347,11 @@ i915_gem_object_get_pages_gtt(struct drm_i915_gem_object *obj)
 
 err_pages:
 	sg_mark_end(sg);
-	for_each_sg_page(st->sgl, &sg_iter, st->nents, 0)
-		page_cache_release(sg_page_iter_page(&sg_iter));
+	for_each_sg_page(st->sgl, &sg_iter, st->nents, 0) {
+		page = sg_page_iter_page(&sg_iter);
+		set_page_private(page, 0);
+		page_cache_release(page);
+	}
 	sg_free_table(st);
 	kfree(st);
 
@@ -4468,6 +4473,7 @@ static const struct drm_i915_gem_object_ops i915_gem_object_ops = {
 struct drm_i915_gem_object *i915_gem_alloc_object(struct drm_device *dev,
 						  size_t size)
 {
+	struct drm_i915_private *dev_priv = to_i915(dev);
 	struct drm_i915_gem_object *obj;
 	struct address_space *mapping;
 	gfp_t mask;
@@ -4481,7 +4487,7 @@ struct drm_i915_gem_object *i915_gem_alloc_object(struct drm_device *dev,
 		return NULL;
 	}
 
-	mask = GFP_HIGHUSER | __GFP_RECLAIMABLE;
+	mask = GFP_HIGHUSER_MOVABLE;
 	if (IS_CRESTLINE(dev) || IS_BROADWATER(dev)) {
 		/* 965gm cannot relocate objects above 4GiB. */
 		mask &= ~__GFP_HIGHMEM;
@@ -4490,6 +4496,7 @@ struct drm_i915_gem_object *i915_gem_alloc_object(struct drm_device *dev,
 
 	mapping = file_inode(obj->base.filp)->i_mapping;
 	mapping_set_gfp_mask(mapping, mask);
+	shmem_set_device_ops(mapping, &dev_priv->mm.shmem_info);
 
 	i915_gem_object_init(obj, &i915_gem_object_ops);
 
diff --git a/drivers/gpu/drm/i915/i915_gem_shrinker.c b/drivers/gpu/drm/i915/i915_gem_shrinker.c
index d3c473ffb90a..b29584149bdf 100644
--- a/drivers/gpu/drm/i915/i915_gem_shrinker.c
+++ b/drivers/gpu/drm/i915/i915_gem_shrinker.c
@@ -24,6 +24,7 @@
 
 #include <linux/oom.h>
 #include <linux/shmem_fs.h>
+#include <linux/migrate.h>
 #include <linux/slab.h>
 #include <linux/swap.h>
 #include <linux/pci.h>
@@ -87,6 +88,70 @@ static bool can_release_pages(struct drm_i915_gem_object *obj)
 	return swap_available() || obj->madv == I915_MADV_DONTNEED;
 }
 
+static bool can_migrate_page(struct drm_i915_gem_object *obj)
+{
+	/* Avoid the migration of page if being actively used by GPU */
+	if (obj->active)
+		return false;
+
+	/* Skip the migration for purgeable objects otherwise there
+	 * will be a deadlock when shmem will try to lock the page for
+	 * truncation, which is already locked by the caller before
+	 * migration.
+	 */
+	if (obj->madv == I915_MADV_DONTNEED)
+		return false;
+
+	/* Skip the migration for a pinned object */
+	if (obj->pages_pin_count != num_vma_bound(obj))
+		return false;
+
+	return true;
+}
+
+static int
+unsafe_drop_pages(struct drm_i915_gem_object *obj)
+{
+	struct i915_vma *vma, *next;
+	int ret;
+
+	drm_gem_object_reference(&obj->base);
+	list_for_each_entry_safe(vma, next, &obj->vma_list, obj_link)
+		if (i915_vma_unbind(vma))
+			break;
+
+	ret = i915_gem_object_put_pages(obj);
+	drm_gem_object_unreference(&obj->base);
+
+	return ret;
+}
+
+static int
+do_migrate_page(struct drm_i915_gem_object *obj)
+{
+	struct drm_i915_private *dev_priv = to_i915(obj->base.dev);
+	int ret = 0;
+
+	if (!can_migrate_page(obj))
+		return -EBUSY;
+
+	/* HW access would be required for a GGTT bound object, for which
+	 * device has to be kept awake. But a deadlock scenario can arise if
+	 * the attempt is made to resume the device, when either a suspend
+	 * or a resume operation is already happening concurrently from some
+	 * other path and that only also triggers compaction. So only unbind
+	 * if the device is currently awake.
+	 */
+	if (!intel_runtime_pm_get_if_in_use(dev_priv))
+		return -EBUSY;
+
+	if (unsafe_drop_pages(obj))
+		ret = -EBUSY;
+
+	intel_runtime_pm_put(dev_priv);
+	return ret;
+}
+
 /**
  * i915_gem_shrink - Shrink buffer object caches
  * @dev_priv: i915 device
@@ -156,7 +221,6 @@ i915_gem_shrink(struct drm_i915_private *dev_priv,
 		INIT_LIST_HEAD(&still_in_list);
 		while (count < target && !list_empty(phase->list)) {
 			struct drm_i915_gem_object *obj;
-			struct i915_vma *vma, *v;
 
 			obj = list_first_entry(phase->list,
 					       typeof(*obj), global_list);
@@ -172,18 +236,8 @@ i915_gem_shrink(struct drm_i915_private *dev_priv,
 			if (!can_release_pages(obj))
 				continue;
 
-			drm_gem_object_reference(&obj->base);
-
-			/* For the unbound phase, this should be a no-op! */
-			list_for_each_entry_safe(vma, v,
-						 &obj->vma_list, obj_link)
-				if (i915_vma_unbind(vma))
-					break;
-
-			if (i915_gem_object_put_pages(obj) == 0)
+			if (unsafe_drop_pages(obj) == 0)
 				count += obj->base.size >> PAGE_SHIFT;
-
-			drm_gem_object_unreference(&obj->base);
 		}
 		list_splice(&still_in_list, phase->list);
 	}
@@ -356,6 +410,97 @@ i915_gem_shrinker_oom(struct notifier_block *nb, unsigned long event, void *ptr)
 	return NOTIFY_DONE;
 }
 
+#ifdef CONFIG_MIGRATION
+static int i915_gem_shrinker_migratepage(struct address_space *mapping,
+					 struct page *newpage,
+					 struct page *page,
+					 enum migrate_mode mode,
+					 void *dev_priv_data)
+{
+	struct drm_i915_private *dev_priv = dev_priv_data;
+	struct drm_device *dev = dev_priv->dev;
+	unsigned long timeout = msecs_to_jiffies(10) + 1;
+	bool unlock;
+	int ret;
+
+	WARN((page_count(newpage) != 1), "Unexpected ref count for newpage\n");
+
+	/*
+	 * Clear the private field of the new target page as it could have a
+	 * stale value in the private field. Otherwise later on if this page
+	 * itself gets migrated, without getting referred by the Driver
+	 * in between, the stale value would cause the i915_migratepage
+	 * function to go for a toss as object pointer is derived from it.
+	 * This should be safe since at the time of migration, private field
+	 * of the new page (which is actually an independent free 4KB page now)
+	 * should be like a don't care for the kernel.
+	 */
+	set_page_private(newpage, 0);
+
+	if (!page_private(page))
+		goto migrate;
+
+	/*
+	 * Check the page count, if Driver also has a reference then it should
+	 * be more than 2, as shmem will have one reference and one reference
+	 * would have been taken by the migration path itself. So if reference
+	 * is <=2, we can directly invoke the migration function.
+	 */
+	if (page_count(page) <= 2)
+		goto migrate;
+
+	/*
+	 * Use trylock here, with a timeout, for struct_mutex as
+	 * otherwise there is a possibility of deadlock due to lock
+	 * inversion. This path, which tries to migrate a particular
+	 * page after locking that page, can race with a path which
+	 * truncate/purge pages of the corresponding object (after
+	 * acquiring struct_mutex). Since page truncation will also
+	 * try to lock the page, a scenario of deadlock can arise.
+	 */
+	while (!i915_gem_shrinker_lock(dev, &unlock) && --timeout)
+		schedule_timeout_killable(1);
+	if (timeout == 0) {
+		DRM_DEBUG_DRIVER("Unable to acquire device mutex.\n");
+		return -EBUSY;
+	}
+
+	ret = 0;
+	if (!PageSwapCache(page) && page_private(page)) {
+		struct drm_i915_gem_object *obj =
+			(struct drm_i915_gem_object *)page_private(page);
+
+		ret = do_migrate_page(obj);
+	}
+
+	if (unlock)
+		mutex_unlock(&dev->struct_mutex);
+
+	if (ret)
+		return ret;
+
+	/*
+	 * Ideally here we don't expect the page count to be > 2, as driver
+	 * would have dropped its reference, but occasionally it has been seen
+	 * coming as 3 & 4. This leads to a situation of unexpected page count,
+	 * causing migration failure, with -EGAIN error. This then leads to
+	 * multiple attempts by the kernel to migrate the same set of pages.
+	 * And sometimes the repeated attempts proves detrimental for stability.
+	 * Also since we don't know who is the other owner, and for how long its
+	 * gonna keep the reference, its better to return -EBUSY.
+	 */
+	if (page_count(page) > 2)
+		return -EBUSY;
+
+migrate:
+	ret = migrate_page(mapping, newpage, page, mode);
+	if (ret)
+		DRM_DEBUG_DRIVER("page=%p migration returned %d\n", page, ret);
+
+	return ret;
+}
+#endif
+
 /**
  * i915_gem_shrinker_init - Initialize i915 shrinker
  * @dev_priv: i915 device
@@ -371,6 +516,11 @@ void i915_gem_shrinker_init(struct drm_i915_private *dev_priv)
 
 	dev_priv->mm.oom_notifier.notifier_call = i915_gem_shrinker_oom;
 	WARN_ON(register_oom_notifier(&dev_priv->mm.oom_notifier));
+
+	dev_priv->mm.shmem_info.dev_private_data = dev_priv;
+#ifdef CONFIG_MIGRATION
+	dev_priv->mm.shmem_info.dev_migratepage = i915_gem_shrinker_migratepage;
+#endif
 }
 
 /**
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
