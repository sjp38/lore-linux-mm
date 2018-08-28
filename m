Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 61AB46B46E4
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 10:57:41 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id u6-v6so1284880pgn.10
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 07:57:41 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p14-v6si1103573plo.357.2018.08.28.07.57.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 Aug 2018 07:57:40 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 04/10] x86: Convert vdso to use vm_fault_t
Date: Tue, 28 Aug 2018 07:57:22 -0700
Message-Id: <20180828145728.11873-5-willy@infradead.org>
In-Reply-To: <20180828145728.11873-1-willy@infradead.org>
References: <20180828145728.11873-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Souptick Joarder <jrdr.linux@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Return vm_fault_t codes directly from the appropriate mm routines instead
of converting from errnos ourselves.  Fixes a minor bug where we'd return
SIGBUS instead of the correct OOM code if we ran out of memory allocating
page tables.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/x86/entry/vdso/vma.c | 24 +++++++++---------------
 1 file changed, 9 insertions(+), 15 deletions(-)

diff --git a/arch/x86/entry/vdso/vma.c b/arch/x86/entry/vdso/vma.c
index 5b8b556dbb12..d1daa53215a4 100644
--- a/arch/x86/entry/vdso/vma.c
+++ b/arch/x86/entry/vdso/vma.c
@@ -39,7 +39,7 @@ void __init init_vdso_image(const struct vdso_image *image)
 
 struct linux_binprm;
 
-static int vdso_fault(const struct vm_special_mapping *sm,
+static vm_fault_t vdso_fault(const struct vm_special_mapping *sm,
 		      struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	const struct vdso_image *image = vma->vm_mm->context.vdso_image;
@@ -84,12 +84,11 @@ static int vdso_mremap(const struct vm_special_mapping *sm,
 	return 0;
 }
 
-static int vvar_fault(const struct vm_special_mapping *sm,
+static vm_fault_t vvar_fault(const struct vm_special_mapping *sm,
 		      struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	const struct vdso_image *image = vma->vm_mm->context.vdso_image;
 	long sym_offset;
-	int ret = -EFAULT;
 
 	if (!image)
 		return VM_FAULT_SIGBUS;
@@ -108,29 +107,24 @@ static int vvar_fault(const struct vm_special_mapping *sm,
 		return VM_FAULT_SIGBUS;
 
 	if (sym_offset == image->sym_vvar_page) {
-		ret = vm_insert_pfn(vma, vmf->address,
-				    __pa_symbol(&__vvar_page) >> PAGE_SHIFT);
+		return vmf_insert_pfn(vma, vmf->address,
+				__pa_symbol(&__vvar_page) >> PAGE_SHIFT);
 	} else if (sym_offset == image->sym_pvclock_page) {
 		struct pvclock_vsyscall_time_info *pvti =
 			pvclock_get_pvti_cpu0_va();
 		if (pvti && vclock_was_used(VCLOCK_PVCLOCK)) {
-			ret = vm_insert_pfn_prot(
-				vma,
-				vmf->address,
-				__pa(pvti) >> PAGE_SHIFT,
-				pgprot_decrypted(vma->vm_page_prot));
+			return vmf_insert_pfn_prot(vma, vmf->address,
+					__pa(pvti) >> PAGE_SHIFT,
+					pgprot_decrypted(vma->vm_page_prot));
 		}
 	} else if (sym_offset == image->sym_hvclock_page) {
 		struct ms_hyperv_tsc_page *tsc_pg = hv_get_tsc_page();
 
 		if (tsc_pg && vclock_was_used(VCLOCK_HVCLOCK))
-			ret = vm_insert_pfn(vma, vmf->address,
-					    vmalloc_to_pfn(tsc_pg));
+			return vmf_insert_pfn(vma, vmf->address,
+					vmalloc_to_pfn(tsc_pg));
 	}
 
-	if (ret == 0 || ret == -EBUSY)
-		return VM_FAULT_NOPAGE;
-
 	return VM_FAULT_SIGBUS;
 }
 
-- 
2.18.0
