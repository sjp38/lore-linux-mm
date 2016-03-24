Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id E095F6B0005
	for <linux-mm@kvack.org>; Thu, 24 Mar 2016 14:10:22 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id tt10so28506224pab.3
        for <linux-mm@kvack.org>; Thu, 24 Mar 2016 11:10:22 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id b74si13700972pfd.69.2016.03.24.11.10.20
        for <linux-mm@kvack.org>;
        Thu, 24 Mar 2016 11:10:21 -0700 (PDT)
From: akash.goel@intel.com
Subject: [PATCH v2 2/2] drm/i915: Make pages of GFX allocations movable
Date: Thu, 24 Mar 2016 23:52:59 +0530
Message-Id: <1458843779-27904-1-git-send-email-akash.goel@intel.com>
In-Reply-To: <20160324081308.GA26929@nuc-i3427.alporthouse.com>
References: <20160324081308.GA26929@nuc-i3427.alporthouse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: intel-gfx@lists.freedesktop.org
Cc: Chris Wilson <chris@chris-wilson.co.uk>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Sourab Gupta <sourab.gupta@intel.com>, Akash Goel <akash.goel@intel.com>

From: Chris Wilson <chris@chris-wilson.co.uk>

On a long run of more than 2-3 days, physical memory tends to get fragmented
severely, which considerably slows down the system. In such a scenario,
Shrinker is also unable to help as lack of memory is not the actual problem,
since it has been observed that there are enough free pages of 0 order.

To address the issue of external fragementation, kernel does a compaction
(which involves migration of pages) but it's efficacy depends upon how many
pages are marked as MOVABLE, as only those pages can be migrated.

Currently the backing pages for GFX buffers are allocated from shmemfs
with GFP_RECLAIMABLE flag, in units of 4KB pages.
In the case of limited Swap space, it may not be possible always to reclaim
or swap-out pages of all the inactive objects, to make way for free space
allowing formation of higher order groups of physically-contiguous pages
on compaction.

Just marking the GFX pages as MOVABLE will not suffice, as i915 Driver
has to pin the pages if they are in use by GPU, which will prevent their
migration. So the migratepage callback in shmem is also hooked up to get a
notification when kernel initiates the page migration. On the notification,
i915 Driver appropriately unpin the pages.
With this Driver can effectively mark the GFX pages as MOVABLE and hence
mitigate the fragmentation problem.

v2:
 - Rename the migration routine to gem_shrink_migratepage, move it to the
   shrinker file, and use the existing constructs (Chris)
 - To cleanup, add a new helper function to encapsulate all page migration
   skip conditions (Chris)
 - Add a new local helper function in shrinker file, for dropping the
   backing pages, and call the same from gem_shrink() also (Chris)

Cc: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org
Signed-off-by: Sourab Gupta <sourab.gupta@intel.com>
Signed-off-by: Akash Goel <akash.goel@intel.com>
---
 drivers/gpu/drm/i915/i915_drv.h          |   3 +
 drivers/gpu/drm/i915/i915_gem.c          |  16 ++-
 drivers/gpu/drm/i915/i915_gem_shrinker.c | 173 ++++++++++++++++++++++++++++---
 3 files changed, 177 insertions(+), 15 deletions(-)

diff --git a/drivers/gpu/drm/i915/i915_drv.h b/drivers/gpu/drm/i915/i915_drv.h
index f330a53..28e50c7 100644
--- a/drivers/gpu/drm/i915/i915_drv.h
+++ b/drivers/gpu/drm/i915/i915_drv.h
@@ -52,6 +52,7 @@
 #include <linux/intel-iommu.h>
 #include <linux/kref.h>
 #include <linux/pm_qos.h>
+#include <linux/shmem_fs.h>
 #include "intel_guc.h"
 #include "intel_dpll_mgr.h"
 
@@ -1966,6 +1967,8 @@ struct drm_i915_private {
 
 	struct intel_encoder *dig_port_map[I915_MAX_PORTS];
 
+	struct shmem_dev_info  migrate_info;
+
 	/*
 	 * NOTE: This is the dri1/ums dungeon, don't add stuff here. Your patch
 	 * will be rejected. Instead look for a better place.
diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index 8588c83..59ab58a 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -2204,6 +2204,7 @@ i915_gem_object_put_pages_gtt(struct drm_i915_gem_object *obj)
 		if (obj->madv == I915_MADV_WILLNEED)
 			mark_page_accessed(page);
 
+		set_page_private(page, 0);
 		page_cache_release(page);
 	}
 	obj->dirty = 0;
@@ -2318,6 +2319,7 @@ i915_gem_object_get_pages_gtt(struct drm_i915_gem_object *obj)
 			sg->length += PAGE_SIZE;
 		}
 		last_pfn = page_to_pfn(page);
+		set_page_private(page, (unsigned long)obj);
 
 		/* Check that the i965g/gm workaround works. */
 		WARN_ON((gfp & __GFP_DMA32) && (last_pfn >= 0x00100000UL));
@@ -2343,8 +2345,11 @@ i915_gem_object_get_pages_gtt(struct drm_i915_gem_object *obj)
 
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
+	struct drm_i915_private *dev_priv = dev->dev_private;
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
@@ -4491,6 +4497,10 @@ struct drm_i915_gem_object *i915_gem_alloc_object(struct drm_device *dev,
 	mapping = file_inode(obj->base.filp)->i_mapping;
 	mapping_set_gfp_mask(mapping, mask);
 
+#ifdef CONFIG_MIGRATION
+	shmem_set_device_ops(mapping, &dev_priv->migrate_info);
+#endif
+
 	i915_gem_object_init(obj, &i915_gem_object_ops);
 
 	obj->base.write_domain = I915_GEM_DOMAIN_CPU;
diff --git a/drivers/gpu/drm/i915/i915_gem_shrinker.c b/drivers/gpu/drm/i915/i915_gem_shrinker.c
index d3c473f..f6c2c20 100644
--- a/drivers/gpu/drm/i915/i915_gem_shrinker.c
+++ b/drivers/gpu/drm/i915/i915_gem_shrinker.c
@@ -24,6 +24,7 @@
 
 #include <linux/oom.h>
 #include <linux/shmem_fs.h>
+#include <linux/migrate.h>
 #include <linux/slab.h>
 #include <linux/swap.h>
 #include <linux/pci.h>
@@ -87,6 +88,71 @@ static bool can_release_pages(struct drm_i915_gem_object *obj)
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
+	struct drm_i915_private *dev_priv = obj->base.dev->dev_private;
+	int ret = 0;
+
+	if (!can_migrate_page(obj))
+		return -EBUSY;
+
+	/* HW access would be required for a bound object for which
+	 * device has to be kept runtime active. But a deadlock scenario
+	 * can arise if the attempt is made to resume the device, when
+	 * either a suspend or a resume operation is already happening
+	 * concurrently from some other path and that only actually
+	 * triggered the compaction. So only unbind if the device is
+	 * currently runtime active.
+	 */
+	if (!intel_runtime_pm_get_if_in_use(dev_priv))
+		return -EBUSY;
+
+	if (!unsafe_drop_pages(obj))
+		ret = -EBUSY;
+
+	intel_runtime_pm_put(dev_priv);
+	return ret;
+}
+
 /**
  * i915_gem_shrink - Shrink buffer object caches
  * @dev_priv: i915 device
@@ -156,7 +222,6 @@ i915_gem_shrink(struct drm_i915_private *dev_priv,
 		INIT_LIST_HEAD(&still_in_list);
 		while (count < target && !list_empty(phase->list)) {
 			struct drm_i915_gem_object *obj;
-			struct i915_vma *vma, *v;
 
 			obj = list_first_entry(phase->list,
 					       typeof(*obj), global_list);
@@ -172,18 +237,8 @@ i915_gem_shrink(struct drm_i915_private *dev_priv,
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
@@ -356,6 +411,95 @@ i915_gem_shrinker_oom(struct notifier_block *nb, unsigned long event, void *ptr)
 	return NOTIFY_DONE;
 }
 
+#ifdef CONFIG_MIGRATION
+static int i915_gem_shrink_migratepage(struct address_space *mapping,
+			    struct page *newpage, struct page *page,
+			    enum migrate_mode mode, void *dev_priv_data)
+{
+	struct drm_i915_private *dev_priv = dev_priv_data;
+	struct drm_device *dev = dev_priv->dev;
+	struct drm_i915_gem_object *obj;
+	unsigned long timeout = msecs_to_jiffies(10) + 1;
+	bool unlock;
+	int ret = 0;
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
+	obj = (struct drm_i915_gem_object *)page_private(page);
+
+	if (!PageSwapCache(page) && obj) {
+		ret = do_migrate_page(obj);
+		BUG_ON(!ret && page_private(page));
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
@@ -371,6 +515,11 @@ void i915_gem_shrinker_init(struct drm_i915_private *dev_priv)
 
 	dev_priv->mm.oom_notifier.notifier_call = i915_gem_shrinker_oom;
 	WARN_ON(register_oom_notifier(&dev_priv->mm.oom_notifier));
+
+#ifdef CONFIG_MIGRATION
+	dev_priv->migrate_info.dev_private_data = dev_priv;
+	dev_priv->migrate_info.dev_migratepage = i915_gem_shrink_migratepage;
+#endif
 }
 
 /**
-- 
1.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
