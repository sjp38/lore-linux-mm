Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id AE6FA6B02BE
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:10:11 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id s11so17282421pgc.13
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:10:11 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 92si14578575plw.30.2017.11.22.13.08.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:08:20 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 56/62] drm: Remove drm_minor_lock and idr_preload
Date: Wed, 22 Nov 2017 13:07:33 -0800
Message-Id: <20171122210739.29916-57-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

The IDR now has its own lock; use it to protect the lookup too.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c      |  8 ++++----
 drivers/gpu/drm/drm_drv.c                    | 25 +++----------------------
 drivers/gpu/drm/drm_gem.c                    | 27 ++++-----------------------
 drivers/gpu/drm/etnaviv/etnaviv_gem_submit.c |  6 +++---
 drivers/gpu/drm/i915/i915_debugfs.c          |  4 ++--
 drivers/gpu/drm/msm/msm_gem_submit.c         | 10 +++++-----
 drivers/gpu/drm/vc4/vc4_gem.c                |  4 ++--
 include/drm/drm_file.h                       |  5 +----
 8 files changed, 24 insertions(+), 65 deletions(-)

diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c
index a418df1b9422..25ee4eef3279 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c
@@ -89,13 +89,13 @@ void amdgpu_gem_force_release(struct amdgpu_device *adev)
 		int handle;
 
 		WARN_ONCE(1, "Still active user space clients!\n");
-		spin_lock(&file->table_lock);
+		idr_lock(&file->object_idr);
 		idr_for_each_entry(&file->object_idr, gobj, handle) {
 			WARN_ONCE(1, "And also active allocations!\n");
 			drm_gem_object_put_unlocked(gobj);
 		}
+		idr_unlock(&file->object_idr);
 		idr_destroy(&file->object_idr);
-		spin_unlock(&file->table_lock);
 	}
 
 	mutex_unlock(&ddev->filelist_mutex);
@@ -824,9 +824,9 @@ static int amdgpu_debugfs_gem_info(struct seq_file *m, void *data)
 			   task ? task->comm : "<unknown>");
 		rcu_read_unlock();
 
-		spin_lock(&file->table_lock);
+		idr_lock(&file->object_idr);
 		idr_for_each(&file->object_idr, amdgpu_debugfs_gem_bo_info, m);
-		spin_unlock(&file->table_lock);
+		idr_unlock(&file->object_idr);
 	}
 
 	mutex_unlock(&dev->filelist_mutex);
diff --git a/drivers/gpu/drm/drm_drv.c b/drivers/gpu/drm/drm_drv.c
index a934fd5e7e55..df51db70ea39 100644
--- a/drivers/gpu/drm/drm_drv.c
+++ b/drivers/gpu/drm/drm_drv.c
@@ -61,7 +61,6 @@ MODULE_PARM_DESC(debug, "Enable debug output, where each bit enables a debug cat
 "\t\tBit 7 (0x80) will enable LEASE messages (leasing code)");
 module_param_named(debug, drm_debug, int, 0600);
 
-static DEFINE_SPINLOCK(drm_minor_lock);
 static struct idr drm_minors_idr;
 
 /*
@@ -153,7 +152,6 @@ static struct drm_minor **drm_minor_get_slot(struct drm_device *dev,
 static int drm_minor_alloc(struct drm_device *dev, unsigned int type)
 {
 	struct drm_minor *minor;
-	unsigned long flags;
 	int r;
 
 	minor = kzalloc(sizeof(*minor), GFP_KERNEL);
@@ -163,15 +161,11 @@ static int drm_minor_alloc(struct drm_device *dev, unsigned int type)
 	minor->type = type;
 	minor->dev = dev;
 
-	idr_preload(GFP_KERNEL);
-	spin_lock_irqsave(&drm_minor_lock, flags);
 	r = idr_alloc(&drm_minors_idr,
 		      NULL,
 		      64 * type,
 		      64 * (type + 1),
-		      GFP_NOWAIT);
-	spin_unlock_irqrestore(&drm_minor_lock, flags);
-	idr_preload_end();
+		      GFP_KERNEL);
 
 	if (r < 0)
 		goto err_free;
@@ -188,9 +182,7 @@ static int drm_minor_alloc(struct drm_device *dev, unsigned int type)
 	return 0;
 
 err_index:
-	spin_lock_irqsave(&drm_minor_lock, flags);
 	idr_remove(&drm_minors_idr, minor->index);
-	spin_unlock_irqrestore(&drm_minor_lock, flags);
 err_free:
 	kfree(minor);
 	return r;
@@ -199,7 +191,6 @@ static int drm_minor_alloc(struct drm_device *dev, unsigned int type)
 static void drm_minor_free(struct drm_device *dev, unsigned int type)
 {
 	struct drm_minor **slot, *minor;
-	unsigned long flags;
 
 	slot = drm_minor_get_slot(dev, type);
 	minor = *slot;
@@ -207,11 +198,7 @@ static void drm_minor_free(struct drm_device *dev, unsigned int type)
 		return;
 
 	put_device(minor->kdev);
-
-	spin_lock_irqsave(&drm_minor_lock, flags);
 	idr_remove(&drm_minors_idr, minor->index);
-	spin_unlock_irqrestore(&drm_minor_lock, flags);
-
 	kfree(minor);
 	*slot = NULL;
 }
@@ -219,7 +206,6 @@ static void drm_minor_free(struct drm_device *dev, unsigned int type)
 static int drm_minor_register(struct drm_device *dev, unsigned int type)
 {
 	struct drm_minor *minor;
-	unsigned long flags;
 	int ret;
 
 	DRM_DEBUG("\n");
@@ -239,9 +225,7 @@ static int drm_minor_register(struct drm_device *dev, unsigned int type)
 		goto err_debugfs;
 
 	/* replace NULL with @minor so lookups will succeed from now on */
-	spin_lock_irqsave(&drm_minor_lock, flags);
 	idr_replace(&drm_minors_idr, minor, minor->index);
-	spin_unlock_irqrestore(&drm_minor_lock, flags);
 
 	DRM_DEBUG("new minor registered %d\n", minor->index);
 	return 0;
@@ -254,16 +238,13 @@ static int drm_minor_register(struct drm_device *dev, unsigned int type)
 static void drm_minor_unregister(struct drm_device *dev, unsigned int type)
 {
 	struct drm_minor *minor;
-	unsigned long flags;
 
 	minor = *drm_minor_get_slot(dev, type);
 	if (!minor || !device_is_registered(minor->kdev))
 		return;
 
 	/* replace @minor with NULL so lookups will fail from now on */
-	spin_lock_irqsave(&drm_minor_lock, flags);
 	idr_replace(&drm_minors_idr, NULL, minor->index);
-	spin_unlock_irqrestore(&drm_minor_lock, flags);
 
 	device_del(minor->kdev);
 	dev_set_drvdata(minor->kdev, NULL); /* safety belt */
@@ -284,11 +265,11 @@ struct drm_minor *drm_minor_acquire(unsigned int minor_id)
 	struct drm_minor *minor;
 	unsigned long flags;
 
-	spin_lock_irqsave(&drm_minor_lock, flags);
+	idr_lock_irqsave(&drm_minors_idr, flags);
 	minor = idr_find(&drm_minors_idr, minor_id);
 	if (minor)
 		drm_dev_get(minor->dev);
-	spin_unlock_irqrestore(&drm_minor_lock, flags);
+	idr_unlock_irqrestore(&drm_minors_idr, flags);
 
 	if (!minor) {
 		return ERR_PTR(-ENODEV);
diff --git a/drivers/gpu/drm/drm_gem.c b/drivers/gpu/drm/drm_gem.c
index 55d6182555c7..7d45b3ef4dd6 100644
--- a/drivers/gpu/drm/drm_gem.c
+++ b/drivers/gpu/drm/drm_gem.c
@@ -282,11 +282,8 @@ drm_gem_handle_delete(struct drm_file *filp, u32 handle)
 {
 	struct drm_gem_object *obj;
 
-	spin_lock(&filp->table_lock);
-
 	/* Check if we currently have a reference on the object */
 	obj = idr_replace(&filp->object_idr, NULL, handle);
-	spin_unlock(&filp->table_lock);
 	if (IS_ERR_OR_NULL(obj))
 		return -EINVAL;
 
@@ -294,9 +291,7 @@ drm_gem_handle_delete(struct drm_file *filp, u32 handle)
 	drm_gem_object_release_handle(handle, obj, filp);
 
 	/* And finally make the handle available for future allocations. */
-	spin_lock(&filp->table_lock);
 	idr_remove(&filp->object_idr, handle);
-	spin_unlock(&filp->table_lock);
 
 	return 0;
 }
@@ -387,17 +382,8 @@ drm_gem_handle_create_tail(struct drm_file *file_priv,
 	if (obj->handle_count++ == 0)
 		drm_gem_object_get(obj);
 
-	/*
-	 * Get the user-visible handle using idr.  Preload and perform
-	 * allocation under our spinlock.
-	 */
-	idr_preload(GFP_KERNEL);
-	spin_lock(&file_priv->table_lock);
-
-	ret = idr_alloc(&file_priv->object_idr, obj, 1, 0, GFP_NOWAIT);
-
-	spin_unlock(&file_priv->table_lock);
-	idr_preload_end();
+	/* Get the user-visible handle using idr. */
+	ret = idr_alloc(&file_priv->object_idr, obj, 1, 0, GFP_KERNEL);
 
 	mutex_unlock(&dev->object_name_lock);
 	if (ret < 0)
@@ -421,9 +407,7 @@ drm_gem_handle_create_tail(struct drm_file *file_priv,
 err_revoke:
 	drm_vma_node_revoke(&obj->vma_node, file_priv);
 err_remove:
-	spin_lock(&file_priv->table_lock);
 	idr_remove(&file_priv->object_idr, handle);
-	spin_unlock(&file_priv->table_lock);
 err_unref:
 	drm_gem_object_handle_put_unlocked(obj);
 	return ret;
@@ -634,14 +618,12 @@ drm_gem_object_lookup(struct drm_file *filp, u32 handle)
 {
 	struct drm_gem_object *obj;
 
-	spin_lock(&filp->table_lock);
-
 	/* Check if we currently have a reference on the object */
+	idr_lock(&filp->object_idr);
 	obj = idr_find(&filp->object_idr, handle);
 	if (obj)
 		drm_gem_object_get(obj);
-
-	spin_unlock(&filp->table_lock);
+	idr_unlock(&filp->object_idr);
 
 	return obj;
 }
@@ -776,7 +758,6 @@ void
 drm_gem_open(struct drm_device *dev, struct drm_file *file_private)
 {
 	idr_init(&file_private->object_idr);
-	spin_lock_init(&file_private->table_lock);
 }
 
 /**
diff --git a/drivers/gpu/drm/etnaviv/etnaviv_gem_submit.c b/drivers/gpu/drm/etnaviv/etnaviv_gem_submit.c
index ff911541a190..5298d9e78523 100644
--- a/drivers/gpu/drm/etnaviv/etnaviv_gem_submit.c
+++ b/drivers/gpu/drm/etnaviv/etnaviv_gem_submit.c
@@ -61,7 +61,7 @@ static int submit_lookup_objects(struct etnaviv_gem_submit *submit,
 	unsigned i;
 	int ret = 0;
 
-	spin_lock(&file->table_lock);
+	idr_lock(&file->object_idr);
 
 	for (i = 0, bo = submit_bos; i < nr_bos; i++, bo++) {
 		struct drm_gem_object *obj;
@@ -75,7 +75,7 @@ static int submit_lookup_objects(struct etnaviv_gem_submit *submit,
 		submit->bos[i].flags = bo->flags;
 
 		/* normally use drm_gem_object_lookup(), but for bulk lookup
-		 * all under single table_lock just hit object_idr directly:
+		 * all under single lock just hit object_idr directly:
 		 */
 		obj = idr_find(&file->object_idr, bo->handle);
 		if (!obj) {
@@ -96,7 +96,7 @@ static int submit_lookup_objects(struct etnaviv_gem_submit *submit,
 
 out_unlock:
 	submit->nr_bos = i;
-	spin_unlock(&file->table_lock);
+	idr_unlock(&file->object_idr);
 
 	return ret;
 }
diff --git a/drivers/gpu/drm/i915/i915_debugfs.c b/drivers/gpu/drm/i915/i915_debugfs.c
index c65e381b85f3..1d88bd0852c3 100644
--- a/drivers/gpu/drm/i915/i915_debugfs.c
+++ b/drivers/gpu/drm/i915/i915_debugfs.c
@@ -544,9 +544,9 @@ static int i915_gem_object_info(struct seq_file *m, void *data)
 
 		memset(&stats, 0, sizeof(stats));
 		stats.file_priv = file->driver_priv;
-		spin_lock(&file->table_lock);
+		idr_lock(&file->object_idr);
 		idr_for_each(&file->object_idr, per_file_stats, &stats);
-		spin_unlock(&file->table_lock);
+		idr_unlock(&file->object_idr);
 		/*
 		 * Although we have a valid reference on file->pid, that does
 		 * not guarantee that the task_struct who called get_pid() is
diff --git a/drivers/gpu/drm/msm/msm_gem_submit.c b/drivers/gpu/drm/msm/msm_gem_submit.c
index b8dc8f96caf2..aa8d0d6e40cc 100644
--- a/drivers/gpu/drm/msm/msm_gem_submit.c
+++ b/drivers/gpu/drm/msm/msm_gem_submit.c
@@ -88,7 +88,7 @@ static int submit_lookup_objects(struct msm_gem_submit *submit,
 	unsigned i;
 	int ret = 0;
 
-	spin_lock(&file->table_lock);
+	idr_lock(&file->object_idr);
 	pagefault_disable();
 
 	for (i = 0; i < args->nr_bos; i++) {
@@ -105,12 +105,12 @@ static int submit_lookup_objects(struct msm_gem_submit *submit,
 
 		if (copy_from_user_inatomic(&submit_bo, userptr, sizeof(submit_bo))) {
 			pagefault_enable();
-			spin_unlock(&file->table_lock);
+			idr_unlock(&file->object_idr);
 			if (copy_from_user(&submit_bo, userptr, sizeof(submit_bo))) {
 				ret = -EFAULT;
 				goto out;
 			}
-			spin_lock(&file->table_lock);
+			idr_lock(&file->object_idr);
 			pagefault_disable();
 		}
 
@@ -126,7 +126,7 @@ static int submit_lookup_objects(struct msm_gem_submit *submit,
 		submit->bos[i].iova  = submit_bo.presumed;
 
 		/* normally use drm_gem_object_lookup(), but for bulk lookup
-		 * all under single table_lock just hit object_idr directly:
+		 * all under single lock just hit object_idr directly:
 		 */
 		obj = idr_find(&file->object_idr, submit_bo.handle);
 		if (!obj) {
@@ -153,7 +153,7 @@ static int submit_lookup_objects(struct msm_gem_submit *submit,
 
 out_unlock:
 	pagefault_enable();
-	spin_unlock(&file->table_lock);
+	idr_unlock(&file->object_idr);
 
 out:
 	submit->nr_bos = i;
diff --git a/drivers/gpu/drm/vc4/vc4_gem.c b/drivers/gpu/drm/vc4/vc4_gem.c
index e00ac2f3a264..3dfd4fa103c3 100644
--- a/drivers/gpu/drm/vc4/vc4_gem.c
+++ b/drivers/gpu/drm/vc4/vc4_gem.c
@@ -713,7 +713,7 @@ vc4_cl_lookup_bos(struct drm_device *dev,
 		goto fail;
 	}
 
-	spin_lock(&file_priv->table_lock);
+	idr_lock(&file_priv->object_idr);
 	for (i = 0; i < exec->bo_count; i++) {
 		struct drm_gem_object *bo = idr_find(&file_priv->object_idr,
 						     handles[i]);
@@ -727,7 +727,7 @@ vc4_cl_lookup_bos(struct drm_device *dev,
 		drm_gem_object_get(bo);
 		exec->bo[i] = (struct drm_gem_cma_object *)bo;
 	}
-	spin_unlock(&file_priv->table_lock);
+	idr_unlock(&file_priv->object_idr);
 
 	if (ret)
 		goto fail_put_bo;
diff --git a/include/drm/drm_file.h b/include/drm/drm_file.h
index 0e0c868451a5..dd3520d8ce60 100644
--- a/include/drm/drm_file.h
+++ b/include/drm/drm_file.h
@@ -225,13 +225,10 @@ struct drm_file {
 	 * @object_idr:
 	 *
 	 * Mapping of mm object handles to object pointers. Used by the GEM
-	 * subsystem. Protected by @table_lock.
+	 * subsystem.
 	 */
 	struct idr object_idr;
 
-	/** @table_lock: Protects @object_idr. */
-	spinlock_t table_lock;
-
 	/** @syncobj_idr: Mapping of sync object handles to object pointers. */
 	struct idr syncobj_idr;
 	/** @syncobj_table_lock: Protects @syncobj_idr. */
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
