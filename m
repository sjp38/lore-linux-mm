Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 453FB90008B
	for <linux-mm@kvack.org>; Wed, 29 Oct 2014 20:42:42 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id rd3so4226854pab.41
        for <linux-mm@kvack.org>; Wed, 29 Oct 2014 17:42:41 -0700 (PDT)
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com. [209.85.192.176])
        by mx.google.com with ESMTPS id w6si5166917pdp.190.2014.10.29.17.42.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 29 Oct 2014 17:42:41 -0700 (PDT)
Received: by mail-pd0-f176.google.com with SMTP id ft15so4003912pdb.7
        for <linux-mm@kvack.org>; Wed, 29 Oct 2014 17:42:38 -0700 (PDT)
From: Andy Lutomirski <luto@amacapital.net>
Subject: [RFC 5/6] x86,vdso: Use .fault instead of remap_pfn_range for the vvar mapping
Date: Wed, 29 Oct 2014 17:42:15 -0700
Message-Id: <d095edc4f5ec0eea526c34b672f1725f7edaf969.1414629045.git.luto@amacapital.net>
In-Reply-To: <cover.1414629045.git.luto@amacapital.net>
References: <cover.1414629045.git.luto@amacapital.net>
In-Reply-To: <cover.1414629045.git.luto@amacapital.net>
References: <cover.1414629045.git.luto@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org, x86@kernel.org
Cc: linux-kernel@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>

This is IMO much less ugly, and it also opens the door to
disallowing unprivileged userspace HPET access on systems with
usable TSCs.

Signed-off-by: Andy Lutomirski <luto@amacapital.net>
---
 arch/x86/vdso/vma.c | 68 +++++++++++++++++++++++++++++++++--------------------
 1 file changed, 42 insertions(+), 26 deletions(-)

diff --git a/arch/x86/vdso/vma.c b/arch/x86/vdso/vma.c
index 7f99c2ed1a3e..5cde3b82d1e9 100644
--- a/arch/x86/vdso/vma.c
+++ b/arch/x86/vdso/vma.c
@@ -121,16 +121,54 @@ static void vvar_start_set(struct vm_special_mapping *sm,
 
 }
 
+static int vvar_fault(struct vm_special_mapping *sm,
+		      struct vm_area_struct *vma, struct vm_fault *vmf)
+{
+	const struct vdso_image *image = vma->vm_mm->context.vdso_image;
+	long sym_offset;
+	int ret = -EFAULT;
+
+	if (!image)
+		return VM_FAULT_SIGBUS;
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
+	if (sym_offset == image->sym_vvar_page)
+		ret = vm_insert_pfn(vma, (unsigned long)vmf->virtual_address,
+				    __pa_symbol(&__vvar_page) >> PAGE_SHIFT);
+#ifdef CONFIG_HPET_TIMER
+	else if (hpet_address && sym_offset == image->sym_hpet_page)
+		ret = vm_insert_pfn_prot(vma,
+					 (unsigned long)vmf->virtual_address,
+					 hpet_address >> PAGE_SHIFT,
+					 pgprot_noncached(PAGE_READONLY));
+#endif
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
 	static struct vm_special_mapping vvar_mapping = {
 		.name = "[vvar]",
-		.pages = no_pages,
+		.fault = vvar_fault,
 
 		/*
 		 * Tracking the vdso is roughly equivalent to tracking the
@@ -176,7 +214,8 @@ static int map_vdso(const struct vdso_image *image, bool calculate_addr)
 	vma = _install_special_mapping(mm,
 				       addr,
 				       -image->sym_vvar_start,
-				       VM_READ|VM_MAYREAD,
+				       VM_READ|VM_MAYREAD|VM_IO|VM_DONTDUMP|
+				       VM_PFNMAP,
 				       &vvar_mapping);
 
 	if (IS_ERR(vma)) {
@@ -184,29 +223,6 @@ static int map_vdso(const struct vdso_image *image, bool calculate_addr)
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
 up_fail:
 	if (ret)
 		current->mm->context.vdso_image = NULL;
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
