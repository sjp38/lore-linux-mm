Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 981116B025A
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 22:21:57 -0500 (EST)
Received: by pfbg73 with SMTP id g73so59629132pfb.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 19:21:57 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id lo5si289877pab.188.2015.12.10.19.21.56
        for <linux-mm@kvack.org>;
        Thu, 10 Dec 2015 19:21:56 -0800 (PST)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH 4/6] x86,vdso: Use .fault for the vdso text mapping
Date: Thu, 10 Dec 2015 19:21:45 -0800
Message-Id: <6057b142a12a9d08a1980d4e3be9d65319a20a59.1449803537.git.luto@kernel.org>
In-Reply-To: <cover.1449803537.git.luto@kernel.org>
References: <cover.1449803537.git.luto@kernel.org>
In-Reply-To: <cover.1449803537.git.luto@kernel.org>
References: <cover.1449803537.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>

The old scheme for mapping the vdso text is rather complicated.  vdso2c
generates a struct vm_special_mapping and a blank .pages array of the
correct size for each vdso image.  Init code in vdso/vma.c populates
the .pages array for each vdso image, and the mapping code selects
the appropriate struct vm_special_mapping.

With .fault, we can use a less roundabout approach: vdso_fault
just returns the appropriate page for the selected vdso image.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/entry/vdso/vdso2c.h |  7 -------
 arch/x86/entry/vdso/vma.c    | 26 +++++++++++++++++++-------
 arch/x86/include/asm/vdso.h  |  3 ---
 3 files changed, 19 insertions(+), 17 deletions(-)

diff --git a/arch/x86/entry/vdso/vdso2c.h b/arch/x86/entry/vdso/vdso2c.h
index 0224987556ce..abe961c7c71c 100644
--- a/arch/x86/entry/vdso/vdso2c.h
+++ b/arch/x86/entry/vdso/vdso2c.h
@@ -150,16 +150,9 @@ static void BITSFUNC(go)(void *raw_addr, size_t raw_len,
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
diff --git a/arch/x86/entry/vdso/vma.c b/arch/x86/entry/vdso/vma.c
index 80b021067bd6..eb50d7c1f161 100644
--- a/arch/x86/entry/vdso/vma.c
+++ b/arch/x86/entry/vdso/vma.c
@@ -27,13 +27,7 @@ unsigned int __read_mostly vdso64_enabled = 1;
 
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
@@ -90,6 +84,24 @@ static unsigned long vdso_addr(unsigned long start, unsigned len)
 #endif
 }
 
+static int vdso_fault(const struct vm_special_mapping *sm,
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
+static const struct vm_special_mapping text_mapping = {
+	.name = "[vdso]",
+	.fault = vdso_fault,
+};
+
 static int map_vdso(const struct vdso_image *image, bool calculate_addr)
 {
 	struct mm_struct *mm = current->mm;
@@ -131,7 +143,7 @@ static int map_vdso(const struct vdso_image *image, bool calculate_addr)
 				       image->size,
 				       VM_READ|VM_EXEC|
 				       VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC,
-				       &image->text_mapping);
+				       &text_mapping);
 
 	if (IS_ERR(vma)) {
 		ret = PTR_ERR(vma);
diff --git a/arch/x86/include/asm/vdso.h b/arch/x86/include/asm/vdso.h
index deabaf9759b6..43dc55be524e 100644
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
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
