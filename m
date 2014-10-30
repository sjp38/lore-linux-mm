Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id F2A5A90008B
	for <linux-mm@kvack.org>; Wed, 29 Oct 2014 20:42:42 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id r10so4014489pdi.30
        for <linux-mm@kvack.org>; Wed, 29 Oct 2014 17:42:42 -0700 (PDT)
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com. [209.85.220.42])
        by mx.google.com with ESMTPS id xk2si5252109pbc.66.2014.10.29.17.42.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 29 Oct 2014 17:42:41 -0700 (PDT)
Received: by mail-pa0-f42.google.com with SMTP id bj1so4303824pad.1
        for <linux-mm@kvack.org>; Wed, 29 Oct 2014 17:42:41 -0700 (PDT)
From: Andy Lutomirski <luto@amacapital.net>
Subject: [RFC 6/6] x86,vdso: Use .fault for the vdso text mapping
Date: Wed, 29 Oct 2014 17:42:16 -0700
Message-Id: <a465d74dc8d7e9af51f8b942d62fdd66ddca3b32.1414629045.git.luto@amacapital.net>
In-Reply-To: <cover.1414629045.git.luto@amacapital.net>
References: <cover.1414629045.git.luto@amacapital.net>
In-Reply-To: <cover.1414629045.git.luto@amacapital.net>
References: <cover.1414629045.git.luto@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org, x86@kernel.org
Cc: linux-kernel@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>

The old scheme for mapping the vdso text is rather complicated.  vdso2c
generates a struct vm_special_mapping and a blank .pages array of the
correct size for each vdso image.  Init code in vdso/vma.c populates
the .pages array for each vdso image, and the mapping code selects
the appropriate struct vm_special_mapping.

With .fault, we can use a less roundabout approach: vdso_fault
just returns the appropriate page for the selected vdso image.

Signed-off-by: Andy Lutomirski <luto@amacapital.net>
---
 arch/x86/include/asm/vdso.h |  3 ---
 arch/x86/vdso/vdso2c.h      |  7 -------
 arch/x86/vdso/vma.c         | 26 +++++++++++++++++++-------
 3 files changed, 19 insertions(+), 17 deletions(-)

diff --git a/arch/x86/include/asm/vdso.h b/arch/x86/include/asm/vdso.h
index 3aa1f830c551..b730e7a74323 100644
--- a/arch/x86/include/asm/vdso.h
+++ b/arch/x86/include/asm/vdso.h
@@ -13,9 +13,6 @@ struct vdso_image {
 	void *data;
 	unsigned long size;   /* Always a multiple of PAGE_SIZE */
 
-	/* text_mapping.pages is big enough for data/size page pointers */
-	struct vm_special_mapping text_mapping;
-
 	unsigned long alt, alt_len;
 
 	long sym_vvar_start;  /* Negative offset to the vvar area */
diff --git a/arch/x86/vdso/vdso2c.h b/arch/x86/vdso/vdso2c.h
index fd57829b30d8..279f7af7cf5e 100644
--- a/arch/x86/vdso/vdso2c.h
+++ b/arch/x86/vdso/vdso2c.h
@@ -148,16 +148,9 @@ static void BITSFUNC(go)(void *raw_addr, size_t raw_len,
 	}
 	fprintf(outfile, "\n};\n\n");
 
-	fprintf(outfile, "static struct page *pages[%lu];\n\n",
-		mapping_size / 4096);
-
 	fprintf(outfile, "const struct vdso_image %s = {\n", name);
 	fprintf(outfile, "\t.data = raw_data,\n");
 	fprintf(outfile, "\t.size = %lu,\n", mapping_size);
-	fprintf(outfile, "\t.text_mapping = {\n");
-	fprintf(outfile, "\t\t.name = \"[vdso]\",\n");
-	fprintf(outfile, "\t\t.pages = pages,\n");
-	fprintf(outfile, "\t},\n");
 	if (alt_sec) {
 		fprintf(outfile, "\t.alt = %lu,\n",
 			(unsigned long)GET_LE(&alt_sec->sh_offset));
diff --git a/arch/x86/vdso/vma.c b/arch/x86/vdso/vma.c
index 5cde3b82d1e9..0ae947eb7433 100644
--- a/arch/x86/vdso/vma.c
+++ b/arch/x86/vdso/vma.c
@@ -25,13 +25,7 @@ extern unsigned short vdso_sync_cpuid;
 
 void __init init_vdso_image(const struct vdso_image *image)
 {
-	int i;
-	int npages = (image->size) / PAGE_SIZE;
-
 	BUG_ON(image->size % PAGE_SIZE != 0);
-	for (i = 0; i < npages; i++)
-		image->text_mapping.pages[i] =
-			virt_to_page(image->data + i*PAGE_SIZE);
 
 	apply_alternatives((struct alt_instr *)(image->data + image->alt),
 			   (struct alt_instr *)(image->data + image->alt +
@@ -160,6 +154,24 @@ static int vvar_fault(struct vm_special_mapping *sm,
 	return VM_FAULT_SIGBUS;
 }
 
+static int vdso_fault(struct vm_special_mapping *sm,
+		      struct vm_area_struct *vma, struct vm_fault *vmf)
+{
+	const struct vdso_image *image = vma->vm_mm->context.vdso_image;
+
+	if (!image || (vmf->pgoff << PAGE_SHIFT) >= image->size)
+		return VM_FAULT_SIGBUS;
+
+	vmf->page = virt_to_page(image->data + (vmf->pgoff << PAGE_SHIFT));
+	get_page(vmf->page);
+	return 0;
+}
+
+static struct vm_special_mapping text_mapping = {
+	.name = "[vdso]",
+	.fault = vdso_fault,
+};
+
 static int map_vdso(const struct vdso_image *image, bool calculate_addr)
 {
 	struct mm_struct *mm = current->mm;
@@ -204,7 +216,7 @@ static int map_vdso(const struct vdso_image *image, bool calculate_addr)
 				       image->size,
 				       VM_READ|VM_EXEC|
 				       VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC,
-				       &image->text_mapping);
+				       &text_mapping);
 
 	if (IS_ERR(vma)) {
 		ret = PTR_ERR(vma);
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
