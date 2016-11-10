Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 909426B0267
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 19:38:01 -0500 (EST)
Received: by mail-pa0-f69.google.com with SMTP id bi5so60284487pad.0
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 16:38:01 -0800 (PST)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0088.outbound.protection.outlook.com. [104.47.40.88])
        by mx.google.com with ESMTPS id o5si1535104paf.335.2016.11.09.16.38.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 09 Nov 2016 16:38:00 -0800 (PST)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v3 16/20] x86: Do not specify encrypted memory for video
 mappings
Date: Wed, 9 Nov 2016 18:37:53 -0600
Message-ID: <20161110003753.3280.36113.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo
 Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Ingo
 Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas
 Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

Since video memory needs to be accessed unencrypted be sure that the
memory encryption mask is not set for the video ranges.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/vga.h       |   13 +++++++++++++
 drivers/gpu/drm/drm_gem.c        |    2 ++
 drivers/gpu/drm/drm_vm.c         |    4 ++++
 drivers/gpu/drm/ttm/ttm_bo_vm.c  |    7 +++++--
 drivers/gpu/drm/udl/udl_fb.c     |    4 ++++
 drivers/video/fbdev/core/fbmem.c |   12 ++++++++++++
 6 files changed, 40 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/vga.h b/arch/x86/include/asm/vga.h
index c4b9dc2..7f944a4 100644
--- a/arch/x86/include/asm/vga.h
+++ b/arch/x86/include/asm/vga.h
@@ -7,12 +7,25 @@
 #ifndef _ASM_X86_VGA_H
 #define _ASM_X86_VGA_H
 
+#include <asm/mem_encrypt.h>
+
 /*
  *	On the PC, we can just recalculate addresses and then
  *	access the videoram directly without any black magic.
+ *	To support memory encryption however, we need to access
+ *	the videoram as un-encrypted memory.
  */
 
+#ifdef CONFIG_AMD_MEM_ENCRYPT
+#define VGA_MAP_MEM(x, s)					\
+({								\
+	unsigned long start = (unsigned long)phys_to_virt(x);	\
+	sme_set_mem_unenc((void *)start, s);			\
+	start;							\
+})
+#else
 #define VGA_MAP_MEM(x, s) (unsigned long)phys_to_virt(x)
+#endif
 
 #define vga_readb(x) (*(x))
 #define vga_writeb(x, y) (*(y) = (x))
diff --git a/drivers/gpu/drm/drm_gem.c b/drivers/gpu/drm/drm_gem.c
index 9134ae1..44f9563 100644
--- a/drivers/gpu/drm/drm_gem.c
+++ b/drivers/gpu/drm/drm_gem.c
@@ -36,6 +36,7 @@
 #include <linux/pagemap.h>
 #include <linux/shmem_fs.h>
 #include <linux/dma-buf.h>
+#include <linux/mem_encrypt.h>
 #include <drm/drmP.h>
 #include <drm/drm_vma_manager.h>
 #include <drm/drm_gem.h>
@@ -928,6 +929,7 @@ int drm_gem_mmap_obj(struct drm_gem_object *obj, unsigned long obj_size,
 	vma->vm_ops = dev->driver->gem_vm_ops;
 	vma->vm_private_data = obj;
 	vma->vm_page_prot = pgprot_writecombine(vm_get_page_prot(vma->vm_flags));
+	pgprot_val(vma->vm_page_prot) &= ~sme_me_mask;
 
 	/* Take a ref for this mapping of the object, so that the fault
 	 * handler can dereference the mmap offset's pointer to the object.
diff --git a/drivers/gpu/drm/drm_vm.c b/drivers/gpu/drm/drm_vm.c
index caa4e4c..d04752c 100644
--- a/drivers/gpu/drm/drm_vm.c
+++ b/drivers/gpu/drm/drm_vm.c
@@ -40,6 +40,7 @@
 #include <linux/efi.h>
 #include <linux/slab.h>
 #endif
+#include <linux/mem_encrypt.h>
 #include <asm/pgtable.h>
 #include "drm_internal.h"
 #include "drm_legacy.h"
@@ -58,6 +59,9 @@ static pgprot_t drm_io_prot(struct drm_local_map *map,
 {
 	pgprot_t tmp = vm_get_page_prot(vma->vm_flags);
 
+	/* We don't want graphics memory to be mapped encrypted */
+	pgprot_val(tmp) &= ~sme_me_mask;
+
 #if defined(__i386__) || defined(__x86_64__) || defined(__powerpc__)
 	if (map->type == _DRM_REGISTERS && !(map->flags & _DRM_WRITE_COMBINING))
 		tmp = pgprot_noncached(tmp);
diff --git a/drivers/gpu/drm/ttm/ttm_bo_vm.c b/drivers/gpu/drm/ttm/ttm_bo_vm.c
index a6ed9d5..f5fbd53 100644
--- a/drivers/gpu/drm/ttm/ttm_bo_vm.c
+++ b/drivers/gpu/drm/ttm/ttm_bo_vm.c
@@ -39,6 +39,7 @@
 #include <linux/rbtree.h>
 #include <linux/module.h>
 #include <linux/uaccess.h>
+#include <linux/mem_encrypt.h>
 
 #define TTM_BO_VM_NUM_PREFAULT 16
 
@@ -218,9 +219,11 @@ static int ttm_bo_vm_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	 * first page.
 	 */
 	for (i = 0; i < TTM_BO_VM_NUM_PREFAULT; ++i) {
-		if (bo->mem.bus.is_iomem)
+		if (bo->mem.bus.is_iomem) {
+			/* Iomem should not be marked encrypted */
+			pgprot_val(cvma.vm_page_prot) &= ~sme_me_mask;
 			pfn = ((bo->mem.bus.base + bo->mem.bus.offset) >> PAGE_SHIFT) + page_offset;
-		else {
+		} else {
 			page = ttm->pages[page_offset];
 			if (unlikely(!page && i == 0)) {
 				retval = VM_FAULT_OOM;
diff --git a/drivers/gpu/drm/udl/udl_fb.c b/drivers/gpu/drm/udl/udl_fb.c
index 611b6b9..64212ca 100644
--- a/drivers/gpu/drm/udl/udl_fb.c
+++ b/drivers/gpu/drm/udl/udl_fb.c
@@ -14,6 +14,7 @@
 #include <linux/slab.h>
 #include <linux/fb.h>
 #include <linux/dma-buf.h>
+#include <linux/mem_encrypt.h>
 
 #include <drm/drmP.h>
 #include <drm/drm_crtc.h>
@@ -169,6 +170,9 @@ static int udl_fb_mmap(struct fb_info *info, struct vm_area_struct *vma)
 	pr_notice("mmap() framebuffer addr:%lu size:%lu\n",
 		  pos, size);
 
+	/* We don't want the framebuffer to be mapped encrypted */
+	pgprot_val(vma->vm_page_prot) &= ~sme_me_mask;
+
 	while (size > 0) {
 		page = vmalloc_to_pfn((void *)pos);
 		if (remap_pfn_range(vma, start, page, PAGE_SIZE, PAGE_SHARED))
diff --git a/drivers/video/fbdev/core/fbmem.c b/drivers/video/fbdev/core/fbmem.c
index 76c1ad9..ac51a5e 100644
--- a/drivers/video/fbdev/core/fbmem.c
+++ b/drivers/video/fbdev/core/fbmem.c
@@ -32,6 +32,7 @@
 #include <linux/device.h>
 #include <linux/efi.h>
 #include <linux/fb.h>
+#include <linux/mem_encrypt.h>
 
 #include <asm/fb.h>
 
@@ -1405,6 +1406,12 @@ fb_mmap(struct file *file, struct vm_area_struct * vma)
 	mutex_lock(&info->mm_lock);
 	if (fb->fb_mmap) {
 		int res;
+
+		/*
+		 * The framebuffer needs to be accessed un-encrypted, be sure
+		 * SME protection is removed ahead of the call
+		 */
+		pgprot_val(vma->vm_page_prot) &= ~sme_me_mask;
 		res = fb->fb_mmap(info, vma);
 		mutex_unlock(&info->mm_lock);
 		return res;
@@ -1430,6 +1437,11 @@ fb_mmap(struct file *file, struct vm_area_struct * vma)
 	mutex_unlock(&info->mm_lock);
 
 	vma->vm_page_prot = vm_get_page_prot(vma->vm_flags);
+	/*
+	 * The framebuffer needs to be accessed un-encrypted, be sure
+	 * SME protection is removed
+	 */
+	pgprot_val(vma->vm_page_prot) &= ~sme_me_mask;
 	fb_pgprotect(file, vma, start);
 
 	return vm_iomap_memory(vma, start, len);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
