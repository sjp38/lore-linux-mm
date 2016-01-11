Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id ABA71828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 06:01:46 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id f206so207806123wmf.0
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 03:01:46 -0800 (PST)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id b126si22060852wmh.108.2016.01.11.03.01.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jan 2016 03:01:45 -0800 (PST)
Received: by mail-wm0-x241.google.com with SMTP id u188so25683263wmu.0
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 03:01:45 -0800 (PST)
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: [PATCH 146/190] io-mapping: Always create a struct to hold metadata about the io-mapping
Date: Mon, 11 Jan 2016 11:00:47 +0000
Message-Id: <1452510091-6833-5-git-send-email-chris@chris-wilson.co.uk>
In-Reply-To: <1452510091-6833-1-git-send-email-chris@chris-wilson.co.uk>
References: <1452503961-14837-1-git-send-email-chris@chris-wilson.co.uk>
 <1452510091-6833-1-git-send-email-chris@chris-wilson.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: intel-gfx@lists.freedesktop.org
Cc: Chris Wilson <chris@chris-wilson.co.uk>, linux-mm@kvack.org

Currently, we only allocate a structure to hold metadata if we need to
allocate an ioremap for every access, such as on x86-32. However, it
would be useful to store basic information about the io-mapping, such as
its page protection, on all platforms.

Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
Cc: linux-mm@kvack.org
---
 drivers/gpu/drm/i915/i915_dma.c            | 11 ++--
 drivers/gpu/drm/i915/i915_gem.c            |  2 +-
 drivers/gpu/drm/i915/i915_gem_execbuffer.c |  2 +-
 drivers/gpu/drm/i915/i915_gem_gtt.h        |  3 +-
 drivers/gpu/drm/i915/i915_gpu_error.c      |  2 +-
 drivers/gpu/drm/i915/intel_overlay.c       |  4 +-
 include/linux/io-mapping.h                 | 84 ++++++++++++++++++------------
 7 files changed, 63 insertions(+), 45 deletions(-)

diff --git a/drivers/gpu/drm/i915/i915_dma.c b/drivers/gpu/drm/i915/i915_dma.c
index 4a24831a14fa..7d85c3bea02a 100644
--- a/drivers/gpu/drm/i915/i915_dma.c
+++ b/drivers/gpu/drm/i915/i915_dma.c
@@ -978,10 +978,9 @@ int i915_driver_load(struct drm_device *dev, unsigned long flags)
 
 	aperture_size = dev_priv->gtt.mappable_end;
 
-	dev_priv->gtt.mappable =
-		io_mapping_create_wc(dev_priv->gtt.mappable_base,
-				     aperture_size);
-	if (dev_priv->gtt.mappable == NULL) {
+	if (!io_mapping_init_wc(&dev_priv->gtt.mappable,
+				dev_priv->gtt.mappable_base,
+				aperture_size)) {
 		ret = -EIO;
 		goto out_gtt;
 	}
@@ -1104,7 +1103,7 @@ out_freewq:
 	destroy_workqueue(dev_priv->wq);
 out_mtrrfree:
 	arch_phys_wc_del(dev_priv->gtt.mtrr);
-	io_mapping_free(dev_priv->gtt.mappable);
+	io_mapping_fini(&dev_priv->gtt.mappable);
 out_gtt:
 	i915_global_gtt_cleanup(dev);
 out_freecsr:
@@ -1148,7 +1147,7 @@ int i915_driver_unload(struct drm_device *dev)
 	WARN_ON(unregister_oom_notifier(&dev_priv->mm.oom_notifier));
 	unregister_shrinker(&dev_priv->mm.shrinker);
 
-	io_mapping_free(dev_priv->gtt.mappable);
+	io_mapping_fini(&dev_priv->gtt.mappable);
 	arch_phys_wc_del(dev_priv->gtt.mtrr);
 
 	acpi_video_unregister();
diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index 08287d8857c9..7e321fdd90d2 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -895,7 +895,7 @@ i915_gem_gtt_pwrite_fast(struct drm_device *dev,
 		 * source page isn't available.  Return the error and we'll
 		 * retry in the slow path.
 		 */
-		if (fast_user_write(dev_priv->gtt.mappable, page_base,
+		if (fast_user_write(&dev_priv->gtt.mappable, page_base,
 				    page_offset, user_data, page_length)) {
 			ret = -EFAULT;
 			goto out_flush;
diff --git a/drivers/gpu/drm/i915/i915_gem_execbuffer.c b/drivers/gpu/drm/i915/i915_gem_execbuffer.c
index 691da0085ff4..6ccce848f3e2 100644
--- a/drivers/gpu/drm/i915/i915_gem_execbuffer.c
+++ b/drivers/gpu/drm/i915/i915_gem_execbuffer.c
@@ -420,7 +420,7 @@ static void *reloc_iomap(struct drm_i915_gem_object *obj,
 		cache->node.mm = (void *)vma;
 	}
 
-	vaddr = io_mapping_map_atomic_wc(cache->i915->gtt.mappable,
+	vaddr = io_mapping_map_atomic_wc(&cache->i915->gtt.mappable,
 					 cache->node.start + (page << PAGE_SHIFT));
 	cache->page = page;
 	cache->vaddr = (unsigned long)vaddr;
diff --git a/drivers/gpu/drm/i915/i915_gem_gtt.h b/drivers/gpu/drm/i915/i915_gem_gtt.h
index dd446b69921b..16319835df10 100644
--- a/drivers/gpu/drm/i915/i915_gem_gtt.h
+++ b/drivers/gpu/drm/i915/i915_gem_gtt.h
@@ -34,6 +34,7 @@
 #ifndef __I915_GEM_GTT_H__
 #define __I915_GEM_GTT_H__
 
+#include <linux/io-mapping.h>
 #include "i915_gem_request.h"
 
 #define I915_FENCE_REG_NONE -1
@@ -389,11 +390,11 @@ struct i915_address_space {
  */
 struct i915_gtt {
 	struct i915_address_space base;
+	struct io_mapping mappable;	/* Mapping to our CPU mappable region */
 
 	size_t stolen_size;		/* Total size of stolen memory */
 	size_t stolen_usable_size;	/* Total size minus BIOS reserved */
 	u64 mappable_end;		/* End offset that we can CPU map */
-	struct io_mapping *mappable;	/* Mapping to our CPU mappable region */
 	phys_addr_t mappable_base;	/* PA of our GMADR */
 
 	/** "Graphics Stolen Memory" holds the global PTEs */
diff --git a/drivers/gpu/drm/i915/i915_gpu_error.c b/drivers/gpu/drm/i915/i915_gpu_error.c
index e5907ac666ad..7c7e0e76260c 100644
--- a/drivers/gpu/drm/i915/i915_gpu_error.c
+++ b/drivers/gpu/drm/i915/i915_gpu_error.c
@@ -664,7 +664,7 @@ i915_error_object_create(struct drm_i915_private *dev_priv,
 			 * captures what the GPU read.
 			 */
 
-			s = io_mapping_map_atomic_wc(dev_priv->gtt.mappable,
+			s = io_mapping_map_atomic_wc(&dev_priv->gtt.mappable,
 						     reloc_offset);
 			memcpy_fromio(d, s, PAGE_SIZE);
 			io_mapping_unmap_atomic(s);
diff --git a/drivers/gpu/drm/i915/intel_overlay.c b/drivers/gpu/drm/i915/intel_overlay.c
index 97b75414263d..dd4d17e8c2cf 100644
--- a/drivers/gpu/drm/i915/intel_overlay.c
+++ b/drivers/gpu/drm/i915/intel_overlay.c
@@ -196,7 +196,7 @@ intel_overlay_map_regs(struct intel_overlay *overlay)
 	if (OVERLAY_NEEDS_PHYSICAL(overlay->dev))
 		regs = (struct overlay_registers __iomem *)overlay->reg_bo->phys_handle->vaddr;
 	else
-		regs = io_mapping_map_wc(dev_priv->gtt.mappable,
+		regs = io_mapping_map_wc(&dev_priv->gtt.mappable,
 					 overlay->flip_addr);
 
 	return regs;
@@ -1493,7 +1493,7 @@ intel_overlay_map_regs_atomic(struct intel_overlay *overlay)
 		regs = (struct overlay_registers __iomem *)
 			overlay->reg_bo->phys_handle->vaddr;
 	else
-		regs = io_mapping_map_atomic_wc(dev_priv->gtt.mappable,
+		regs = io_mapping_map_atomic_wc(&dev_priv->gtt.mappable,
 						overlay->flip_addr);
 
 	return regs;
diff --git a/include/linux/io-mapping.h b/include/linux/io-mapping.h
index e399029b68c5..34bb310c9a0e 100644
--- a/include/linux/io-mapping.h
+++ b/include/linux/io-mapping.h
@@ -31,16 +31,17 @@
  * See Documentation/io-mapping.txt
  */
 
-#ifdef CONFIG_HAVE_ATOMIC_IOMAP
-
-#include <asm/iomap.h>
-
 struct io_mapping {
 	resource_size_t base;
 	unsigned long size;
 	pgprot_t prot;
+	void __iomem *iomem;
 };
 
+
+#ifdef CONFIG_HAVE_ATOMIC_IOMAP
+
+#include <asm/iomap.h>
 /*
  * For small address space machines, mapping large objects
  * into the kernel virtual space isn't practical. Where
@@ -49,34 +50,25 @@ struct io_mapping {
  */
 
 static inline struct io_mapping *
-io_mapping_create_wc(resource_size_t base, unsigned long size)
+io_mapping_init_wc(struct io_mapping *iomap,
+		   resource_size_t base,
+		   unsigned long size)
 {
-	struct io_mapping *iomap;
 	pgprot_t prot;
 
-	iomap = kmalloc(sizeof(*iomap), GFP_KERNEL);
-	if (!iomap)
-		goto out_err;
-
 	if (iomap_create_wc(base, size, &prot))
-		goto out_free;
+		return NULL;
 
 	iomap->base = base;
 	iomap->size = size;
 	iomap->prot = prot;
 	return iomap;
-
-out_free:
-	kfree(iomap);
-out_err:
-	return NULL;
 }
 
 static inline void
-io_mapping_free(struct io_mapping *mapping)
+io_mapping_fini(struct io_mapping *mapping)
 {
 	iomap_free(mapping->base, mapping->size);
-	kfree(mapping);
 }
 
 /* Atomic map/unmap */
@@ -119,21 +111,38 @@ io_mapping_unmap(void __iomem *vaddr)
 #else
 
 #include <linux/uaccess.h>
-
-/* this struct isn't actually defined anywhere */
-struct io_mapping;
+#include <asm/pgtable_types.h>
 
 /* Create the io_mapping object*/
 static inline struct io_mapping *
-io_mapping_create_wc(resource_size_t base, unsigned long size)
+io_mapping_init_wc(struct io_mapping *iomap,
+		   resource_size_t base,
+		   unsigned long size)
 {
-	return (struct io_mapping __force *) ioremap_wc(base, size);
+	iomap->base = base;
+	iomap->size = size;
+	iomap->iomem = ioremap_wc(base, size);
+	iomap->prot = pgprot_writecombine(PAGE_KERNEL_IO);
+
+	return iomap;
 }
 
 static inline void
-io_mapping_free(struct io_mapping *mapping)
+io_mapping_fini(struct io_mapping *mapping)
+{
+	iounmap(mapping->iomem);
+}
+
+/* Non-atomic map/unmap */
+static inline void __iomem *
+io_mapping_map_wc(struct io_mapping *mapping, unsigned long offset)
+{
+	return mapping->iomem + offset;
+}
+
+static inline void
+io_mapping_unmap(void __iomem *vaddr)
 {
-	iounmap((void __force __iomem *) mapping);
 }
 
 /* Atomic map/unmap */
@@ -143,28 +152,37 @@ io_mapping_map_atomic_wc(struct io_mapping *mapping,
 {
 	preempt_disable();
 	pagefault_disable();
-	return ((char __force __iomem *) mapping) + offset;
+	return io_mapping_map_wc(mapping, offset);
 }
 
 static inline void
 io_mapping_unmap_atomic(void __iomem *vaddr)
 {
+	io_mapping_unmap(vaddr);
 	pagefault_enable();
 	preempt_enable();
 }
 
-/* Non-atomic map/unmap */
-static inline void __iomem *
-io_mapping_map_wc(struct io_mapping *mapping, unsigned long offset)
+#endif /* HAVE_ATOMIC_IOMAP */
+
+static inline struct io_mapping *
+io_mapping_create_wc(resource_size_t base,
+		     unsigned long size)
 {
-	return ((char __force __iomem *) mapping) + offset;
+	struct io_mapping *iomap;
+
+	iomap = kmalloc(sizeof(*iomap), GFP_KERNEL);
+	if (iomap == NULL)
+		return NULL;
+
+	return io_mapping_init_wc(iomap, base, size);
 }
 
 static inline void
-io_mapping_unmap(void __iomem *vaddr)
+io_mapping_free(struct io_mapping *iomap)
 {
+	io_mapping_fini(iomap);
+	kfree(iomap);
 }
 
-#endif /* HAVE_ATOMIC_IOMAP */
-
 #endif /* _LINUX_IO_MAPPING_H */
-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
