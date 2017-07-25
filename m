Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 34F3E6B02C3
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 15:21:51 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id j79so165268900pfj.9
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 12:21:51 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id m4si8614213pgn.86.2017.07.25.12.21.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 12:21:50 -0700 (PDT)
From: Matthew Auld <matthew.auld@intel.com>
Subject: [PATCH 02/21] drm/i915: introduce simple gemfs
Date: Tue, 25 Jul 2017 20:21:14 +0100
Message-Id: <20170725192133.2012-3-matthew.auld@intel.com>
In-Reply-To: <20170725192133.2012-1-matthew.auld@intel.com>
References: <20170725192133.2012-1-matthew.auld@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: intel-gfx@lists.freedesktop.org
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Chris Wilson <chris@chris-wilson.co.uk>, Dave Hansen <dave.hansen@intel.com>, "Kirill A . Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

Not a fully blown gemfs, just our very own tmpfs kernel mount. Doing so
moves us away from the shmemfs shm_mnt, and gives us the much needed
flexibility to do things like set our own mount options, namely huge=
which should allow us to enable the use of transparent-huge-pages for
our shmem backed objects.

v2: various improvements suggested by Joonas

v3: move gemfs instance to i915.mm and simplify now that we have
file_setup_with_mnt

Signed-off-by: Matthew Auld <matthew.auld@intel.com>
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Cc: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Kirill A. Shutemov <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org
---
 drivers/gpu/drm/i915/Makefile                    |  1 +
 drivers/gpu/drm/i915/i915_drv.h                  |  3 ++
 drivers/gpu/drm/i915/i915_gem.c                  | 34 +++++++++++++++-
 drivers/gpu/drm/i915/i915_gemfs.c                | 52 ++++++++++++++++++++++++
 drivers/gpu/drm/i915/i915_gemfs.h                | 34 ++++++++++++++++
 drivers/gpu/drm/i915/selftests/mock_gem_device.c | 10 ++++-
 6 files changed, 131 insertions(+), 3 deletions(-)
 create mode 100644 drivers/gpu/drm/i915/i915_gemfs.c
 create mode 100644 drivers/gpu/drm/i915/i915_gemfs.h

diff --git a/drivers/gpu/drm/i915/Makefile b/drivers/gpu/drm/i915/Makefile
index f8227318dcaf..29e3cfdf56ce 100644
--- a/drivers/gpu/drm/i915/Makefile
+++ b/drivers/gpu/drm/i915/Makefile
@@ -46,6 +46,7 @@ i915-y += i915_cmd_parser.o \
 	  i915_gem_tiling.o \
 	  i915_gem_timeline.o \
 	  i915_gem_userptr.o \
+	  i915_gemfs.o \
 	  i915_trace_points.o \
 	  i915_vma.o \
 	  intel_breadcrumbs.o \
diff --git a/drivers/gpu/drm/i915/i915_drv.h b/drivers/gpu/drm/i915/i915_drv.h
index 2c7456f4ed38..4a7ad8c1d015 100644
--- a/drivers/gpu/drm/i915/i915_drv.h
+++ b/drivers/gpu/drm/i915/i915_drv.h
@@ -1467,6 +1467,9 @@ struct i915_gem_mm {
 	/** Usable portion of the GTT for GEM */
 	dma_addr_t stolen_base; /* limited to low memory (32-bit) */
 
+	/** tmpfs instance used for shmem backed objects */
+	struct vfsmount *gemfs;
+
 	/** PPGTT used for aliasing the PPGTT with the GTT */
 	struct i915_hw_ppgtt *aliasing_ppgtt;
 
diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index 6faabf34f142..9335f487400e 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -35,6 +35,7 @@
 #include "intel_drv.h"
 #include "intel_frontbuffer.h"
 #include "intel_mocs.h"
+#include "i915_gemfs.h"
 #include <linux/dma-fence-array.h>
 #include <linux/kthread.h>
 #include <linux/reservation.h>
@@ -4314,6 +4315,25 @@ static const struct drm_i915_gem_object_ops i915_gem_object_ops = {
 	.pwrite = i915_gem_object_pwrite_gtt,
 };
 
+static int i915_gem_object_create_shmem(struct drm_device *dev,
+					struct drm_gem_object *obj,
+					size_t size)
+{
+	struct drm_i915_private *i915 = to_i915(dev);
+	struct file *filp;
+
+	drm_gem_private_object_init(dev, obj, size);
+
+	filp = shmem_file_setup_with_mnt(i915->mm.gemfs, "i915", size,
+					 VM_NORESERVE);
+	if (IS_ERR(filp))
+		return PTR_ERR(filp);
+
+	obj->filp = filp;
+
+	return 0;
+}
+
 struct drm_i915_gem_object *
 i915_gem_object_create(struct drm_i915_private *dev_priv, u64 size)
 {
@@ -4337,7 +4357,7 @@ i915_gem_object_create(struct drm_i915_private *dev_priv, u64 size)
 	if (obj == NULL)
 		return ERR_PTR(-ENOMEM);
 
-	ret = drm_gem_object_init(&dev_priv->drm, &obj->base, size);
+	ret = i915_gem_object_create_shmem(&dev_priv->drm, &obj->base, size);
 	if (ret)
 		goto fail;
 
@@ -4913,7 +4933,13 @@ i915_gem_load_init_fences(struct drm_i915_private *dev_priv)
 int
 i915_gem_load_init(struct drm_i915_private *dev_priv)
 {
-	int err = -ENOMEM;
+	int err;
+
+	err = i915_gemfs_init(dev_priv);
+	if (err)
+		return err;
+
+	err = -ENOMEM;
 
 	dev_priv->objects = KMEM_CACHE(drm_i915_gem_object, SLAB_HWCACHE_ALIGN);
 	if (!dev_priv->objects)
@@ -4977,6 +5003,8 @@ i915_gem_load_init(struct drm_i915_private *dev_priv)
 err_objects:
 	kmem_cache_destroy(dev_priv->objects);
 err_out:
+	i915_gemfs_fini(dev_priv);
+
 	return err;
 }
 
@@ -4999,6 +5027,8 @@ void i915_gem_load_cleanup(struct drm_i915_private *dev_priv)
 
 	/* And ensure that our DESTROY_BY_RCU slabs are truly destroyed */
 	rcu_barrier();
+
+	i915_gemfs_fini(dev_priv);
 }
 
 int i915_gem_freeze(struct drm_i915_private *dev_priv)
diff --git a/drivers/gpu/drm/i915/i915_gemfs.c b/drivers/gpu/drm/i915/i915_gemfs.c
new file mode 100644
index 000000000000..168d0bd98f60
--- /dev/null
+++ b/drivers/gpu/drm/i915/i915_gemfs.c
@@ -0,0 +1,52 @@
+/*
+ * Copyright A(C) 2017 Intel Corporation
+ *
+ * Permission is hereby granted, free of charge, to any person obtaining a
+ * copy of this software and associated documentation files (the "Software"),
+ * to deal in the Software without restriction, including without limitation
+ * the rights to use, copy, modify, merge, publish, distribute, sublicense,
+ * and/or sell copies of the Software, and to permit persons to whom the
+ * Software is furnished to do so, subject to the following conditions:
+ *
+ * The above copyright notice and this permission notice (including the next
+ * paragraph) shall be included in all copies or substantial portions of the
+ * Software.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
+ * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
+ * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
+ * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
+ * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
+ * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
+ * IN THE SOFTWARE.
+ *
+ */
+
+#include <linux/fs.h>
+#include <linux/mount.h>
+
+#include "i915_drv.h"
+#include "i915_gemfs.h"
+
+int i915_gemfs_init(struct drm_i915_private *i915)
+{
+	struct file_system_type *type;
+	struct vfsmount *gemfs;
+
+	type = get_fs_type("tmpfs");
+	if (!type)
+		return -ENODEV;
+
+	gemfs = kern_mount(type);
+	if (IS_ERR(gemfs))
+		return PTR_ERR(gemfs);
+
+	i915->mm.gemfs = gemfs;
+
+	return 0;
+}
+
+void i915_gemfs_fini(struct drm_i915_private *i915)
+{
+	kern_unmount(i915->mm.gemfs);
+}
diff --git a/drivers/gpu/drm/i915/i915_gemfs.h b/drivers/gpu/drm/i915/i915_gemfs.h
new file mode 100644
index 000000000000..cca8bdc5b93e
--- /dev/null
+++ b/drivers/gpu/drm/i915/i915_gemfs.h
@@ -0,0 +1,34 @@
+/*
+ * Copyright A(C) 2017 Intel Corporation
+ *
+ * Permission is hereby granted, free of charge, to any person obtaining a
+ * copy of this software and associated documentation files (the "Software"),
+ * to deal in the Software without restriction, including without limitation
+ * the rights to use, copy, modify, merge, publish, distribute, sublicense,
+ * and/or sell copies of the Software, and to permit persons to whom the
+ * Software is furnished to do so, subject to the following conditions:
+ *
+ * The above copyright notice and this permission notice (including the next
+ * paragraph) shall be included in all copies or substantial portions of the
+ * Software.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
+ * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
+ * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
+ * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
+ * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
+ * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
+ * IN THE SOFTWARE.
+ *
+ */
+
+#ifndef __I915_GEMFS_H__
+#define __I915_GEMFS_H__
+
+struct drm_i915_private;
+
+int i915_gemfs_init(struct drm_i915_private *i915);
+
+void i915_gemfs_fini(struct drm_i915_private *i915);
+
+#endif
diff --git a/drivers/gpu/drm/i915/selftests/mock_gem_device.c b/drivers/gpu/drm/i915/selftests/mock_gem_device.c
index ec92b6569b50..a56f3a29fa05 100644
--- a/drivers/gpu/drm/i915/selftests/mock_gem_device.c
+++ b/drivers/gpu/drm/i915/selftests/mock_gem_device.c
@@ -83,6 +83,8 @@ static void mock_device_release(struct drm_device *dev)
 	kmem_cache_destroy(i915->vmas);
 	kmem_cache_destroy(i915->objects);
 
+	i915_gemfs_fini(i915);
+
 	drm_dev_fini(&i915->drm);
 	put_device(&i915->drm.pdev->dev);
 }
@@ -189,9 +191,13 @@ struct drm_i915_private *mock_gem_device(void)
 
 	i915->gt.awake = true;
 
+	err = i915_gemfs_init(i915);
+	if (err)
+		goto err_wq;
+
 	i915->objects = KMEM_CACHE(mock_object, SLAB_HWCACHE_ALIGN);
 	if (!i915->objects)
-		goto err_wq;
+		goto err_gemfs;
 
 	i915->vmas = KMEM_CACHE(i915_vma, SLAB_HWCACHE_ALIGN);
 	if (!i915->vmas)
@@ -249,6 +255,8 @@ struct drm_i915_private *mock_gem_device(void)
 	kmem_cache_destroy(i915->vmas);
 err_objects:
 	kmem_cache_destroy(i915->objects);
+err_gemfs:
+	i915_gemfs_fini(i915);
 err_wq:
 	destroy_workqueue(i915->wq);
 put_device:
-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
