Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id DFD4A6B0005
	for <linux-mm@kvack.org>; Mon, 15 Aug 2016 07:53:10 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id u13so119415978uau.2
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 04:53:10 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id u1si19582900wjx.280.2016.08.15.04.53.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Aug 2016 04:53:09 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id i5so10724797wmg.2
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 04:53:09 -0700 (PDT)
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: [PATCH 1/2] io-mapping: Always create a struct to hold metadata about the io-mapping
Date: Mon, 15 Aug 2016 12:53:03 +0100
Message-Id: <1471261984-15756-1-git-send-email-chris@chris-wilson.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: intel-gfx@lists.freedesktop.org
Cc: joonas.lahtinen@linux.intel.com, Chris Wilson <chris@chris-wilson.co.uk>, linux-mm@kvack.org

Currently, we only allocate a structure to hold metadata if we need to
allocate an ioremap for every access, such as on x86-32. However, it
would be useful to store basic information about the io-mapping, such as
its page protection, on all platforms.

Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
Cc: linux-mm@kvack.org
---
 drivers/gpu/drm/i915/i915_gem.c            |  6 +-
 drivers/gpu/drm/i915/i915_gem_execbuffer.c |  2 +-
 drivers/gpu/drm/i915/i915_gem_gtt.c        | 11 ++--
 drivers/gpu/drm/i915/i915_gem_gtt.h        |  2 +-
 drivers/gpu/drm/i915/i915_gpu_error.c      |  2 +-
 drivers/gpu/drm/i915/intel_overlay.c       |  4 +-
 include/linux/io-mapping.h                 | 92 ++++++++++++++++++------------
 7 files changed, 70 insertions(+), 49 deletions(-)

diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index f5a7c7ffb1a5..f12114a35ae3 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -888,7 +888,7 @@ i915_gem_gtt_pread(struct drm_device *dev,
 		 * and write to user memory which may result into page
 		 * faults, and so we cannot perform this under struct_mutex.
 		 */
-		if (slow_user_access(ggtt->mappable, page_base,
+		if (slow_user_access(&ggtt->mappable, page_base,
 				     page_offset, user_data,
 				     page_length, false)) {
 			ret = -EFAULT;
@@ -1181,11 +1181,11 @@ i915_gem_gtt_pwrite_fast(struct drm_i915_private *i915,
 		 * If the object is non-shmem backed, we retry again with the
 		 * path that handles page fault.
 		 */
-		if (fast_user_write(ggtt->mappable, page_base,
+		if (fast_user_write(&ggtt->mappable, page_base,
 				    page_offset, user_data, page_length)) {
 			hit_slow_path = true;
 			mutex_unlock(&dev->struct_mutex);
-			if (slow_user_access(ggtt->mappable,
+			if (slow_user_access(&ggtt->mappable,
 					     page_base,
 					     page_offset, user_data,
 					     page_length, true)) {
diff --git a/drivers/gpu/drm/i915/i915_gem_execbuffer.c b/drivers/gpu/drm/i915/i915_gem_execbuffer.c
index c012a0d94878..e6f88f3194d6 100644
--- a/drivers/gpu/drm/i915/i915_gem_execbuffer.c
+++ b/drivers/gpu/drm/i915/i915_gem_execbuffer.c
@@ -470,7 +470,7 @@ static void *reloc_iomap(struct drm_i915_gem_object *obj,
 		offset += page << PAGE_SHIFT;
 	}
 
-	vaddr = io_mapping_map_atomic_wc(cache->i915->ggtt.mappable, offset);
+	vaddr = io_mapping_map_atomic_wc(&cache->i915->ggtt.mappable, offset);
 	cache->page = page;
 	cache->vaddr = (unsigned long)vaddr;
 
diff --git a/drivers/gpu/drm/i915/i915_gem_gtt.c b/drivers/gpu/drm/i915/i915_gem_gtt.c
index d03f9180ce76..3a82c97d5d53 100644
--- a/drivers/gpu/drm/i915/i915_gem_gtt.c
+++ b/drivers/gpu/drm/i915/i915_gem_gtt.c
@@ -2808,7 +2808,6 @@ void i915_ggtt_cleanup_hw(struct drm_i915_private *dev_priv)
 
 	if (dev_priv->mm.aliasing_ppgtt) {
 		struct i915_hw_ppgtt *ppgtt = dev_priv->mm.aliasing_ppgtt;
-
 		ppgtt->base.cleanup(&ppgtt->base);
 		kfree(ppgtt);
 	}
@@ -2828,7 +2827,7 @@ void i915_ggtt_cleanup_hw(struct drm_i915_private *dev_priv)
 	ggtt->base.cleanup(&ggtt->base);
 
 	arch_phys_wc_del(ggtt->mtrr);
-	io_mapping_free(ggtt->mappable);
+	io_mapping_fini(&ggtt->mappable);
 }
 
 static unsigned int gen6_get_total_gtt_size(u16 snb_gmch_ctl)
@@ -3226,9 +3225,9 @@ int i915_ggtt_init_hw(struct drm_i915_private *dev_priv)
 	if (!HAS_LLC(dev_priv))
 		ggtt->base.mm.color_adjust = i915_gtt_color_adjust;
 
-	ggtt->mappable =
-		io_mapping_create_wc(ggtt->mappable_base, ggtt->mappable_end);
-	if (!ggtt->mappable) {
+	if (!io_mapping_init_wc(&dev_priv->ggtt.mappable,
+				dev_priv->ggtt.mappable_base,
+				dev_priv->ggtt.mappable_end)) {
 		ret = -EIO;
 		goto out_gtt_cleanup;
 	}
@@ -3698,7 +3697,7 @@ void __iomem *i915_vma_pin_iomap(struct i915_vma *vma)
 
 	ptr = vma->iomap;
 	if (ptr == NULL) {
-		ptr = io_mapping_map_wc(i915_vm_to_ggtt(vma->vm)->mappable,
+		ptr = io_mapping_map_wc(&i915_vm_to_ggtt(vma->vm)->mappable,
 					vma->node.start,
 					vma->node.size);
 		if (ptr == NULL)
diff --git a/drivers/gpu/drm/i915/i915_gem_gtt.h b/drivers/gpu/drm/i915/i915_gem_gtt.h
index d2f79a1fb75f..f8d68d775896 100644
--- a/drivers/gpu/drm/i915/i915_gem_gtt.h
+++ b/drivers/gpu/drm/i915/i915_gem_gtt.h
@@ -438,13 +438,13 @@ struct i915_address_space {
  */
 struct i915_ggtt {
 	struct i915_address_space base;
+	struct io_mapping mappable;	/* Mapping to our CPU mappable region */
 
 	size_t stolen_size;		/* Total size of stolen memory */
 	size_t stolen_usable_size;	/* Total size minus BIOS reserved */
 	size_t stolen_reserved_base;
 	size_t stolen_reserved_size;
 	u64 mappable_end;		/* End offset that we can CPU map */
-	struct io_mapping *mappable;	/* Mapping to our CPU mappable region */
 	phys_addr_t mappable_base;	/* PA of our GMADR */
 
 	/** "Graphics Stolen Memory" holds the global PTEs */
diff --git a/drivers/gpu/drm/i915/i915_gpu_error.c b/drivers/gpu/drm/i915/i915_gpu_error.c
index 0bed4ac63720..261d43a433bb 100644
--- a/drivers/gpu/drm/i915/i915_gpu_error.c
+++ b/drivers/gpu/drm/i915/i915_gpu_error.c
@@ -786,7 +786,7 @@ i915_error_object_create(struct drm_i915_private *i915,
 				       I915_CACHE_NONE, 0);
 
 		s = (void *__force)
-			io_mapping_map_atomic_wc(ggtt->mappable, slot);
+			io_mapping_map_atomic_wc(&ggtt->mappable, slot);
 		ret = compress_page(&zstream, s, dst);
 		io_mapping_unmap_atomic(s);
 
diff --git a/drivers/gpu/drm/i915/intel_overlay.c b/drivers/gpu/drm/i915/intel_overlay.c
index a480323446fe..7c392547711f 100644
--- a/drivers/gpu/drm/i915/intel_overlay.c
+++ b/drivers/gpu/drm/i915/intel_overlay.c
@@ -196,7 +196,7 @@ intel_overlay_map_regs(struct intel_overlay *overlay)
 	if (OVERLAY_NEEDS_PHYSICAL(dev_priv))
 		regs = (struct overlay_registers __iomem *)overlay->reg_bo->phys_handle->vaddr;
 	else
-		regs = io_mapping_map_wc(dev_priv->ggtt.mappable,
+		regs = io_mapping_map_wc(&dev_priv->ggtt.mappable,
 					 overlay->flip_addr,
 					 PAGE_SIZE);
 
@@ -1491,7 +1491,7 @@ intel_overlay_map_regs_atomic(struct intel_overlay *overlay)
 		regs = (struct overlay_registers __iomem *)
 			overlay->reg_bo->phys_handle->vaddr;
 	else
-		regs = io_mapping_map_atomic_wc(dev_priv->ggtt.mappable,
+		regs = io_mapping_map_atomic_wc(&dev_priv->ggtt.mappable,
 						overlay->flip_addr);
 
 	return regs;
diff --git a/include/linux/io-mapping.h b/include/linux/io-mapping.h
index 645ad06b5d52..b4c4b5c4216d 100644
--- a/include/linux/io-mapping.h
+++ b/include/linux/io-mapping.h
@@ -31,16 +31,16 @@
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
 
+#ifdef CONFIG_HAVE_ATOMIC_IOMAP
+
+#include <asm/iomap.h>
 /*
  * For small address space machines, mapping large objects
  * into the kernel virtual space isn't practical. Where
@@ -49,34 +49,25 @@ struct io_mapping {
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
@@ -121,21 +112,40 @@ io_mapping_unmap(void __iomem *vaddr)
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
+{
+	iomap->base = base;
+	iomap->size = size;
+	iomap->iomem = ioremap_wc(base, size);
+	iomap->prot = pgprot_writecombine(PAGE_KERNEL_IO);
+
+	return iomap;
+}
+
+static inline void
+io_mapping_fini(struct io_mapping *mapping)
+{
+	iounmap(mapping->iomem);
+}
+
+/* Non-atomic map/unmap */
+static inline void __iomem *
+io_mapping_map_wc(struct io_mapping *mapping,
+		  unsigned long offset,
+		  unsigned long size)
 {
-	return (struct io_mapping __force *) ioremap_wc(base, size);
+	return mapping->iomem + offset;
 }
 
 static inline void
-io_mapping_free(struct io_mapping *mapping)
+io_mapping_unmap(void __iomem *vaddr)
 {
-	iounmap((void __force __iomem *) mapping);
 }
 
 /* Atomic map/unmap */
@@ -145,30 +155,42 @@ io_mapping_map_atomic_wc(struct io_mapping *mapping,
 {
 	preempt_disable();
 	pagefault_disable();
-	return ((char __force __iomem *) mapping) + offset;
+	return io_mapping_map_wc(mapping, offset, PAGE_SIZE);
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
-io_mapping_map_wc(struct io_mapping *mapping,
-		  unsigned long offset,
-		  unsigned long size)
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
+	if (!iomap)
+		return NULL;
+
+	if (!io_mapping_init_wc(iomap, base, size)) {
+		kfree(iomap);
+		return NULL;
+	}
+
+	return iomap;
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
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
