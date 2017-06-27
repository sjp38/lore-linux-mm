Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 35E1B6B03AD
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 11:01:31 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id n2so17791542oig.12
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 08:01:31 -0700 (PDT)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0072.outbound.protection.outlook.com. [104.47.37.72])
        by mx.google.com with ESMTPS id e11si1118325oig.250.2017.06.27.08.01.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 27 Jun 2017 08:01:29 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v8 29/38] x86, drm,
 fbdev: Do not specify encrypted memory for video mappings
Date: Tue, 27 Jun 2017 10:01:20 -0500
Message-ID: <20170627150120.15908.89995.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170627145607.15908.26571.stgit@tlendack-t1.amdoffice.net>
References: <20170627145607.15908.26571.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

Since video memory needs to be accessed decrypted, be sure that the
memory encryption mask is not set for the video ranges.

Reviewed-by: Borislav Petkov <bp@suse.de>
Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/vga.h       |   14 +++++++++++++-
 arch/x86/mm/pageattr.c           |    2 ++
 drivers/gpu/drm/drm_gem.c        |    2 ++
 drivers/gpu/drm/drm_vm.c         |    4 ++++
 drivers/gpu/drm/ttm/ttm_bo_vm.c  |    7 +++++--
 drivers/gpu/drm/udl/udl_fb.c     |    4 ++++
 drivers/video/fbdev/core/fbmem.c |   12 ++++++++++++
 7 files changed, 42 insertions(+), 3 deletions(-)

diff --git a/arch/x86/include/asm/vga.h b/arch/x86/include/asm/vga.h
index c4b9dc2..9f42bee 100644
--- a/arch/x86/include/asm/vga.h
+++ b/arch/x86/include/asm/vga.h
@@ -7,12 +7,24 @@
 #ifndef _ASM_X86_VGA_H
 #define _ASM_X86_VGA_H
 
+#include <asm/set_memory.h>
+
 /*
  *	On the PC, we can just recalculate addresses and then
  *	access the videoram directly without any black magic.
+ *	To support memory encryption however, we need to access
+ *	the videoram as decrypted memory.
  */
 
-#define VGA_MAP_MEM(x, s) (unsigned long)phys_to_virt(x)
+#define VGA_MAP_MEM(x, s)					\
+({								\
+	unsigned long start = (unsigned long)phys_to_virt(x);	\
+								\
+	if (IS_ENABLED(CONFIG_AMD_MEM_ENCRYPT))			\
+		set_memory_decrypted(start, (s) >> PAGE_SHIFT);	\
+								\
+	start;							\
+})
 
 #define vga_readb(x) (*(x))
 #define vga_writeb(x, y) (*(y) = (x))
diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index d9e09fb..13fc5db 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -1825,11 +1825,13 @@ int set_memory_encrypted(unsigned long addr, int numpages)
 {
 	return __set_memory_enc_dec(addr, numpages, true);
 }
+EXPORT_SYMBOL_GPL(set_memory_encrypted);
 
 int set_memory_decrypted(unsigned long addr, int numpages)
 {
 	return __set_memory_enc_dec(addr, numpages, false);
 }
+EXPORT_SYMBOL_GPL(set_memory_decrypted);
 
 int set_pages_uc(struct page *page, int numpages)
 {
diff --git a/drivers/gpu/drm/drm_gem.c b/drivers/gpu/drm/drm_gem.c
index b1e28c9..019f48c 100644
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
+	vma->vm_page_prot = pgprot_decrypted(vma->vm_page_prot);
 
 	/* Take a ref for this mapping of the object, so that the fault
 	 * handler can dereference the mmap offset's pointer to the object.
diff --git a/drivers/gpu/drm/drm_vm.c b/drivers/gpu/drm/drm_vm.c
index 1170b32..ed4bcbf 100644
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
+	tmp = pgprot_decrypted(tmp);
+
 #if defined(__i386__) || defined(__x86_64__) || defined(__powerpc__)
 	if (map->type == _DRM_REGISTERS && !(map->flags & _DRM_WRITE_COMBINING))
 		tmp = pgprot_noncached(tmp);
diff --git a/drivers/gpu/drm/ttm/ttm_bo_vm.c b/drivers/gpu/drm/ttm/ttm_bo_vm.c
index 9f53df9..622dab6 100644
--- a/drivers/gpu/drm/ttm/ttm_bo_vm.c
+++ b/drivers/gpu/drm/ttm/ttm_bo_vm.c
@@ -39,6 +39,7 @@
 #include <linux/rbtree.h>
 #include <linux/module.h>
 #include <linux/uaccess.h>
+#include <linux/mem_encrypt.h>
 
 #define TTM_BO_VM_NUM_PREFAULT 16
 
@@ -230,9 +231,11 @@ static int ttm_bo_vm_fault(struct vm_fault *vmf)
 	 * first page.
 	 */
 	for (i = 0; i < TTM_BO_VM_NUM_PREFAULT; ++i) {
-		if (bo->mem.bus.is_iomem)
+		if (bo->mem.bus.is_iomem) {
+			/* Iomem should not be marked encrypted */
+			cvma.vm_page_prot = pgprot_decrypted(cvma.vm_page_prot);
 			pfn = bdev->driver->io_mem_pfn(bo, page_offset);
-		else {
+		} else {
 			page = ttm->pages[page_offset];
 			if (unlikely(!page && i == 0)) {
 				retval = VM_FAULT_OOM;
diff --git a/drivers/gpu/drm/udl/udl_fb.c b/drivers/gpu/drm/udl/udl_fb.c
index 4a65003..92e1690 100644
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
+	vma->vm_page_prot = pgprot_decrypted(vma->vm_page_prot);
+
 	while (size > 0) {
 		page = vmalloc_to_pfn((void *)pos);
 		if (remap_pfn_range(vma, start, page, PAGE_SIZE, PAGE_SHARED))
diff --git a/drivers/video/fbdev/core/fbmem.c b/drivers/video/fbdev/core/fbmem.c
index 069fe79..b5e7c33 100644
--- a/drivers/video/fbdev/core/fbmem.c
+++ b/drivers/video/fbdev/core/fbmem.c
@@ -32,6 +32,7 @@
 #include <linux/device.h>
 #include <linux/efi.h>
 #include <linux/fb.h>
+#include <linux/mem_encrypt.h>
 
 #include <asm/fb.h>
 
@@ -1405,6 +1406,12 @@ static long fb_compat_ioctl(struct file *file, unsigned int cmd,
 	mutex_lock(&info->mm_lock);
 	if (fb->fb_mmap) {
 		int res;
+
+		/*
+		 * The framebuffer needs to be accessed decrypted, be sure
+		 * SME protection is removed ahead of the call
+		 */
+		vma->vm_page_prot = pgprot_decrypted(vma->vm_page_prot);
 		res = fb->fb_mmap(info, vma);
 		mutex_unlock(&info->mm_lock);
 		return res;
@@ -1430,6 +1437,11 @@ static long fb_compat_ioctl(struct file *file, unsigned int cmd,
 	mutex_unlock(&info->mm_lock);
 
 	vma->vm_page_prot = vm_get_page_prot(vma->vm_flags);
+	/*
+	 * The framebuffer needs to be accessed decrypted, be sure
+	 * SME protection is removed
+	 */
+	vma->vm_page_prot = pgprot_decrypted(vma->vm_page_prot);
 	fb_pgprotect(file, vma, start);
 
 	return vm_iomap_memory(vma, start, len);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
