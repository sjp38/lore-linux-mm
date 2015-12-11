Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id ED0556B025B
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 22:21:58 -0500 (EST)
Received: by pacwq6 with SMTP id wq6so57763126pac.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 19:21:58 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id q5si157539pfq.13.2015.12.10.19.21.58
        for <linux-mm@kvack.org>;
        Thu, 10 Dec 2015 19:21:58 -0800 (PST)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH 5/6] x86,vdso: Use .fault instead of remap_pfn_range for the vvar mapping
Date: Thu, 10 Dec 2015 19:21:46 -0800
Message-Id: <1312c2af60551278d65e7e410b1cf845fefd7769.1449803537.git.luto@kernel.org>
In-Reply-To: <cover.1449803537.git.luto@kernel.org>
References: <cover.1449803537.git.luto@kernel.org>
In-Reply-To: <cover.1449803537.git.luto@kernel.org>
References: <cover.1449803537.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>

This is IMO much less ugly, and it also opens the door to
disallowing unprivileged userspace HPET access on systems with
usable TSCs.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/entry/vdso/vma.c | 97 ++++++++++++++++++++++++++++-------------------
 1 file changed, 57 insertions(+), 40 deletions(-)

diff --git a/arch/x86/entry/vdso/vma.c b/arch/x86/entry/vdso/vma.c
index eb50d7c1f161..02221e98b83f 100644
--- a/arch/x86/entry/vdso/vma.c
+++ b/arch/x86/entry/vdso/vma.c
@@ -102,18 +102,69 @@ static const struct vm_special_mapping text_mapping = {
 	.fault = vdso_fault,
 };
 
+static int vvar_fault(const struct vm_special_mapping *sm,
+		      struct vm_area_struct *vma, struct vm_fault *vmf)
+{
+	const struct vdso_image *image = vma->vm_mm->context.vdso_image;
+	long sym_offset;
+	int ret = -EFAULT;
+
+	if (!image)
+		return VM_FAULT_SIGBUS;
+
+	sym_offset = (long)(vmf->pgoff << PAGE_SHIFT) +
+		image->sym_vvar_start;
+
+	/*
+	 * Sanity check: a symbol offset of zero means that the page
+	 * does not exist for this vdso image, not that the page is at
+	 * offset zero relative to the text mapping.  This should be
+	 * impossible here, because sym_offset should only be zero for
+	 * the page past the end of the vvar mapping.
+	 */
+	if (sym_offset == 0)
+		return VM_FAULT_SIGBUS;
+
+	if (sym_offset == image->sym_vvar_page) {
+		ret = vm_insert_pfn(vma, (unsigned long)vmf->virtual_address,
+				    __pa_symbol(&__vvar_page) >> PAGE_SHIFT);
+	} else if (sym_offset == image->sym_hpet_page) {
+#ifdef CONFIG_HPET_TIMER
+		if (hpet_address) {
+			ret = vm_insert_pfn_prot(
+				vma,
+				(unsigned long)vmf->virtual_address,
+				hpet_address >> PAGE_SHIFT,
+				pgprot_noncached(PAGE_READONLY));
+		}
+#endif
+	} else if (sym_offset == image->sym_pvclock_page) {
+		struct pvclock_vsyscall_time_info *pvti =
+			pvclock_pvti_cpu0_va();
+		if (pvti) {
+			ret = vm_insert_pfn(
+				vma,
+				(unsigned long)vmf->virtual_address,
+				__pa(pvti) >> PAGE_SHIFT);
+		}
+	}
+
+	if (ret == 0)
+		return VM_FAULT_NOPAGE;
+
+	return VM_FAULT_SIGBUS;
+}
+
 static int map_vdso(const struct vdso_image *image, bool calculate_addr)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 	unsigned long addr, text_start;
 	int ret = 0;
-	static struct page *no_pages[] = {NULL};
-	static struct vm_special_mapping vvar_mapping = {
+	static const struct vm_special_mapping vvar_mapping = {
 		.name = "[vvar]",
-		.pages = no_pages,
+		.fault = vvar_fault,
 	};
-	struct pvclock_vsyscall_time_info *pvti;
 
 	if (calculate_addr) {
 		addr = vdso_addr(current->mm->start_stack,
@@ -153,7 +204,8 @@ static int map_vdso(const struct vdso_image *image, bool calculate_addr)
 	vma = _install_special_mapping(mm,
 				       addr,
 				       -image->sym_vvar_start,
-				       VM_READ|VM_MAYREAD,
+				       VM_READ|VM_MAYREAD|VM_IO|VM_DONTDUMP|
+				       VM_PFNMAP,
 				       &vvar_mapping);
 
 	if (IS_ERR(vma)) {
@@ -161,41 +213,6 @@ static int map_vdso(const struct vdso_image *image, bool calculate_addr)
 		goto up_fail;
 	}
 
-	if (image->sym_vvar_page)
-		ret = remap_pfn_range(vma,
-				      text_start + image->sym_vvar_page,
-				      __pa_symbol(&__vvar_page) >> PAGE_SHIFT,
-				      PAGE_SIZE,
-				      PAGE_READONLY);
-
-	if (ret)
-		goto up_fail;
-
-#ifdef CONFIG_HPET_TIMER
-	if (hpet_address && image->sym_hpet_page) {
-		ret = io_remap_pfn_range(vma,
-			text_start + image->sym_hpet_page,
-			hpet_address >> PAGE_SHIFT,
-			PAGE_SIZE,
-			pgprot_noncached(PAGE_READONLY));
-
-		if (ret)
-			goto up_fail;
-	}
-#endif
-
-	pvti = pvclock_pvti_cpu0_va();
-	if (pvti && image->sym_pvclock_page) {
-		ret = remap_pfn_range(vma,
-				      text_start + image->sym_pvclock_page,
-				      __pa(pvti) >> PAGE_SHIFT,
-				      PAGE_SIZE,
-				      PAGE_READONLY);
-
-		if (ret)
-			goto up_fail;
-	}
-
 up_fail:
 	if (ret)
 		current->mm->context.vdso = NULL;
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
