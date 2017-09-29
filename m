Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7F0346B025E
	for <linux-mm@kvack.org>; Fri, 29 Sep 2017 12:10:40 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id x78so103456pff.7
        for <linux-mm@kvack.org>; Fri, 29 Sep 2017 09:10:40 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id l23si401477pff.472.2017.09.29.09.10.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Sep 2017 09:10:39 -0700 (PDT)
From: Matthew Auld <matthew.auld@intel.com>
Subject: [PATCH 02/21] drm/i915: introduce simple gemfs
Date: Fri, 29 Sep 2017 17:10:13 +0100
Message-Id: <20170929161032.24394-3-matthew.auld@intel.com>
In-Reply-To: <20170929161032.24394-1-matthew.auld@intel.com>
References: <20170929161032.24394-1-matthew.auld@intel.com>
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

v4: fallback to tmpfs shm_mnt upon failure to setup gemfs

v5: make tmpfs fallback kinder

Signed-off-by: Matthew Auld <matthew.auld@intel.com>
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Cc: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Kirill A. Shutemov <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org
---
 drivers/gpu/drm/i915/Makefile                    |  1 +
 drivers/gpu/drm/i915/i915_drv.h                  |  5 +++
 drivers/gpu/drm/i915/i915_gem.c                  | 31 +++++++++++++-
 drivers/gpu/drm/i915/i915_gemfs.c                | 52 ++++++++++++++++++++++++
 drivers/gpu/drm/i915/i915_gemfs.h                | 34 ++++++++++++++++
 drivers/gpu/drm/i915/selftests/mock_gem_device.c |  4 ++
 6 files changed, 126 insertions(+), 1 deletion(-)
 create mode 100644 drivers/gpu/drm/i915/i915_gemfs.c
 create mode 100644 drivers/gpu/drm/i915/i915_gemfs.h

diff --git a/drivers/gpu/drm/i915/Makefile b/drivers/gpu/drm/i915/Makefile
index 5182e3d5557d..980c41568f46 100644
--- a/drivers/gpu/drm/i915/Makefile
+++ b/drivers/gpu/drm/i915/Makefile
@@ -47,6 +47,7 @@ i915-y += i915_cmd_parser.o \
 	  i915_gem_tiling.o \
 	  i915_gem_timeline.o \
 	  i915_gem_userptr.o \
+	  i915_gemfs.o \
 	  i915_trace_points.o \
 	  i915_vma.o \
 	  intel_breadcrumbs.o \
diff --git a/drivers/gpu/drm/i915/i915_drv.h b/drivers/gpu/drm/i915/i915_drv.h
index 7ca11318ac69..b50fe24454ed 100644
--- a/drivers/gpu/drm/i915/i915_drv.h
+++ b/drivers/gpu/drm/i915/i915_drv.h
@@ -1508,6 +1508,11 @@ struct i915_gem_mm {
 	/** Usable portion of the GTT for GEM */
 	dma_addr_t stolen_base; /* limited to low memory (32-bit) */
 
+	/**
+	 * tmpfs instance used for shmem backed objects
+	 */
+	struct vfsmount *gemfs;
+
 	/** PPGTT used for aliasing the PPGTT with the GTT */
 	struct i915_hw_ppgtt *aliasing_ppgtt;
 
diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index ab8c6946fea4..a6a0a7ee2df8 100644
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
@@ -4251,6 +4252,29 @@ static const struct drm_i915_gem_object_ops i915_gem_object_ops = {
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
+	if (i915->mm.gemfs)
+		filp = shmem_file_setup_with_mnt(i915->mm.gemfs, "i915", size,
+						 VM_NORESERVE);
+	else
+		filp = shmem_file_setup("i915", size, VM_NORESERVE);
+
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
@@ -4275,7 +4299,7 @@ i915_gem_object_create(struct drm_i915_private *dev_priv, u64 size)
 	if (obj == NULL)
 		return ERR_PTR(-ENOMEM);
 
-	ret = drm_gem_object_init(&dev_priv->drm, &obj->base, size);
+	ret = i915_gem_object_create_shmem(&dev_priv->drm, &obj->base, size);
 	if (ret)
 		goto fail;
 
@@ -4915,6 +4939,9 @@ i915_gem_load_init(struct drm_i915_private *dev_priv)
 
 	spin_lock_init(&dev_priv->fb_tracking.lock);
 
+	if (i915_gemfs_init(dev_priv))
+		DRM_NOTE("Unable to create a private tmpfs mountpoint, hugepage support will be disabled.\n");
+
 	return 0;
 
 err_priorities:
@@ -4953,6 +4980,8 @@ void i915_gem_load_cleanup(struct drm_i915_private *dev_priv)
 
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
index 2388424a14da..ed3407b078e7 100644
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
@@ -239,6 +241,8 @@ struct drm_i915_private *mock_gem_device(void)
 	if (!i915->kernel_context)
 		goto err_engine;
 
+	WARN_ON(i915_gemfs_init(i915));
+
 	return i915;
 
 err_engine:
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
