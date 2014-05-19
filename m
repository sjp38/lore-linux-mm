Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id EFF906B003A
	for <linux-mm@kvack.org>; Mon, 19 May 2014 18:58:46 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fb1so6428513pad.37
        for <linux-mm@kvack.org>; Mon, 19 May 2014 15:58:46 -0700 (PDT)
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
        by mx.google.com with ESMTPS id ab2si21396927pad.96.2014.05.19.15.58.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 May 2014 15:58:46 -0700 (PDT)
Received: by mail-pa0-f51.google.com with SMTP id kq14so6445678pab.38
        for <linux-mm@kvack.org>; Mon, 19 May 2014 15:58:45 -0700 (PDT)
From: Andy Lutomirski <luto@amacapital.net>
Subject: [PATCH 3/4] x86,mm: Improve _install_special_mapping and fix x86 vdso naming
Date: Mon, 19 May 2014 15:58:33 -0700
Message-Id: <276b39b6b645fb11e345457b503f17b83c2c6fd0.1400538962.git.luto@amacapital.net>
In-Reply-To: <cover.1400538962.git.luto@amacapital.net>
References: <cover.1400538962.git.luto@amacapital.net>
In-Reply-To: <cover.1400538962.git.luto@amacapital.net>
References: <cover.1400538962.git.luto@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Cyrill Gorcunov <gorcunov@gmail.com>, Pavel Emelyanov <xemul@parallels.com>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>

Using arch_vma_name to give special mappings a name is awkward.  x86
currently implements it by comparing the start address of the vma to
the expected address of the vdso.  This requires tracking the start
address of special mappings and is probably buggy if a special vma
is split or moved.

Improve _install_special_mapping to just name the vma directly.  Use
it to give the x86 vvar area a name, which should make CRIU's life
easier.

As a side effect, the vvar area will show up in core dumps.  This
could be considered weird and is fixable.  Thoughts?

Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Pavel Emelyanov <xemul@parallels.com>
Signed-off-by: Andy Lutomirski <luto@amacapital.net>
---
 arch/x86/include/asm/vdso.h  |  6 ++-
 arch/x86/mm/init_64.c        |  3 --
 arch/x86/vdso/vdso2c.h       |  5 ++-
 arch/x86/vdso/vdso32-setup.c |  7 ----
 arch/x86/vdso/vma.c          | 25 ++++++++-----
 include/linux/mm.h           |  4 +-
 include/linux/mm_types.h     |  6 +++
 mm/mmap.c                    | 89 +++++++++++++++++++++++++++++---------------
 8 files changed, 94 insertions(+), 51 deletions(-)

diff --git a/arch/x86/include/asm/vdso.h b/arch/x86/include/asm/vdso.h
index d0a2c90..30be253 100644
--- a/arch/x86/include/asm/vdso.h
+++ b/arch/x86/include/asm/vdso.h
@@ -7,10 +7,14 @@
 
 #ifndef __ASSEMBLER__
 
+#include <linux/mm_types.h>
+
 struct vdso_image {
 	void *data;
 	unsigned long size;   /* Always a multiple of PAGE_SIZE */
-	struct page **pages;  /* Big enough for data/size page pointers */
+
+	/* text_mapping.pages is big enough for data/size page pointers */
+	struct vm_special_mapping text_mapping;
 
 	unsigned long alt, alt_len;
 
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 6f88184..9deb59b 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1223,9 +1223,6 @@ int in_gate_area_no_mm(unsigned long addr)
 
 const char *arch_vma_name(struct vm_area_struct *vma)
 {
-	if (vma->vm_mm && vma->vm_start ==
-	    (long __force)vma->vm_mm->context.vdso)
-		return "[vdso]";
 	if (vma == &gate_vma)
 		return "[vsyscall]";
 	return NULL;
diff --git a/arch/x86/vdso/vdso2c.h b/arch/x86/vdso/vdso2c.h
index ed2e894..3dcc61e 100644
--- a/arch/x86/vdso/vdso2c.h
+++ b/arch/x86/vdso/vdso2c.h
@@ -136,7 +136,10 @@ static int GOFUNC(void *addr, size_t len, FILE *outfile, const char *name)
 	fprintf(outfile, "const struct vdso_image %s = {\n", name);
 	fprintf(outfile, "\t.data = raw_data,\n");
 	fprintf(outfile, "\t.size = %lu,\n", data_size);
-	fprintf(outfile, "\t.pages = pages,\n");
+	fprintf(outfile, "\t.text_mapping = {\n");
+	fprintf(outfile, "\t\t.name = \"[vdso]\",\n");
+	fprintf(outfile, "\t\t.pages = pages,\n");
+	fprintf(outfile, "\t},\n");
 	if (alt_sec) {
 		fprintf(outfile, "\t.alt = %lu,\n",
 			(unsigned long)alt_sec->sh_offset);
diff --git a/arch/x86/vdso/vdso32-setup.c b/arch/x86/vdso/vdso32-setup.c
index c3ed708..e4f7781 100644
--- a/arch/x86/vdso/vdso32-setup.c
+++ b/arch/x86/vdso/vdso32-setup.c
@@ -119,13 +119,6 @@ __initcall(ia32_binfmt_init);
 
 #else  /* CONFIG_X86_32 */
 
-const char *arch_vma_name(struct vm_area_struct *vma)
-{
-	if (vma->vm_mm && vma->vm_start == (long)vma->vm_mm->context.vdso)
-		return "[vdso]";
-	return NULL;
-}
-
 struct vm_area_struct *get_gate_vma(struct mm_struct *mm)
 {
 	return NULL;
diff --git a/arch/x86/vdso/vma.c b/arch/x86/vdso/vma.c
index 8ad0081..e1513c4 100644
--- a/arch/x86/vdso/vma.c
+++ b/arch/x86/vdso/vma.c
@@ -30,7 +30,8 @@ void __init init_vdso_image(const struct vdso_image *image)
 
 	BUG_ON(image->size % PAGE_SIZE != 0);
 	for (i = 0; i < npages; i++)
-		image->pages[i] = virt_to_page(image->data + i*PAGE_SIZE);
+		image->text_mapping.pages[i] =
+			virt_to_page(image->data + i*PAGE_SIZE);
 
 	apply_alternatives((struct alt_instr *)(image->data + image->alt),
 			   (struct alt_instr *)(image->data + image->alt +
@@ -91,6 +92,10 @@ static int map_vdso(const struct vdso_image *image, bool calculate_addr)
 	unsigned long addr;
 	int ret = 0;
 	static struct page *no_pages[] = {NULL};
+	static struct vm_special_mapping vvar_mapping = {
+		.name = "[vvar]",
+		.pages = no_pages,
+	};
 
 	if (calculate_addr) {
 		addr = vdso_addr(current->mm->start_stack,
@@ -112,21 +117,23 @@ static int map_vdso(const struct vdso_image *image, bool calculate_addr)
 	/*
 	 * MAYWRITE to allow gdb to COW and set breakpoints
 	 */
-	ret = install_special_mapping(mm,
-				      addr,
-				      image->size,
-				      VM_READ|VM_EXEC|
-				      VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC,
-				      image->pages);
+	vma = _install_special_mapping(mm,
+				       addr,
+				       image->size,
+				       VM_READ|VM_EXEC|
+				       VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC,
+				       &image->text_mapping);
 
-	if (ret)
+	if (IS_ERR(vma)) {
+		ret = PTR_ERR(vma);
 		goto up_fail;
+	}
 
 	vma = _install_special_mapping(mm,
 				       addr + image->size,
 				       image->sym_end_mapping - image->size,
 				       VM_READ,
-				       no_pages);
+				       &vvar_mapping);
 
 	if (IS_ERR(vma)) {
 		ret = PTR_ERR(vma);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 63f8d4e..05aab09 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1782,7 +1782,9 @@ extern struct file *get_mm_exe_file(struct mm_struct *mm);
 extern int may_expand_vm(struct mm_struct *mm, unsigned long npages);
 extern struct vm_area_struct *_install_special_mapping(struct mm_struct *mm,
 				   unsigned long addr, unsigned long len,
-				   unsigned long flags, struct page **pages);
+				   unsigned long flags,
+				   const struct vm_special_mapping *spec);
+/* This is an obsolete alternative to _install_special_mapping. */
 extern int install_special_mapping(struct mm_struct *mm,
 				   unsigned long addr, unsigned long len,
 				   unsigned long flags, struct page **pages);
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 8967e20..22c6f4e 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -510,4 +510,10 @@ static inline void clear_tlb_flush_pending(struct mm_struct *mm)
 }
 #endif
 
+struct vm_special_mapping
+{
+	const char *name;
+	struct page **pages;
+};
+
 #endif /* _LINUX_MM_TYPES_H */
diff --git a/mm/mmap.c b/mm/mmap.c
index b1202cf..52bbc95 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2872,6 +2872,31 @@ int may_expand_vm(struct mm_struct *mm, unsigned long npages)
 	return 1;
 }
 
+static int special_mapping_fault(struct vm_area_struct *vma,
+				 struct vm_fault *vmf);
+
+/*
+ * Having a close hook prevents vma merging regardless of flags.
+ */
+static void special_mapping_close(struct vm_area_struct *vma)
+{
+}
+
+static const char *special_mapping_name(struct vm_area_struct *vma)
+{
+	return ((struct vm_special_mapping *)vma->vm_private_data)->name;
+}
+
+static const struct vm_operations_struct special_mapping_vmops = {
+	.close = special_mapping_close,
+	.fault = special_mapping_fault,
+	.name = special_mapping_name,
+};
+
+static const struct vm_operations_struct legacy_special_mapping_vmops = {
+	.close = special_mapping_close,
+	.fault = special_mapping_fault,
+};
 
 static int special_mapping_fault(struct vm_area_struct *vma,
 				struct vm_fault *vmf)
@@ -2887,7 +2912,13 @@ static int special_mapping_fault(struct vm_area_struct *vma,
 	 */
 	pgoff = vmf->pgoff - vma->vm_pgoff;
 
-	for (pages = vma->vm_private_data; pgoff && *pages; ++pages)
+	if (vma->vm_ops == &legacy_special_mapping_vmops)
+		pages = vma->vm_private_data;
+	else
+		pages = ((struct vm_special_mapping *)vma->vm_private_data)->
+			pages;
+
+	for (; pgoff && *pages; ++pages)
 		pgoff--;
 
 	if (*pages) {
@@ -2900,30 +2931,11 @@ static int special_mapping_fault(struct vm_area_struct *vma,
 	return VM_FAULT_SIGBUS;
 }
 
-/*
- * Having a close hook prevents vma merging regardless of flags.
- */
-static void special_mapping_close(struct vm_area_struct *vma)
-{
-}
-
-static const struct vm_operations_struct special_mapping_vmops = {
-	.close = special_mapping_close,
-	.fault = special_mapping_fault,
-};
-
-/*
- * Called with mm->mmap_sem held for writing.
- * Insert a new vma covering the given region, with the given flags.
- * Its pages are supplied by the given array of struct page *.
- * The array can be shorter than len >> PAGE_SHIFT if it's null-terminated.
- * The region past the last page supplied will always produce SIGBUS.
- * The array pointer and the pages it points to are assumed to stay alive
- * for as long as this mapping might exist.
- */
-struct vm_area_struct *_install_special_mapping(struct mm_struct *mm,
-			    unsigned long addr, unsigned long len,
-			    unsigned long vm_flags, struct page **pages)
+static struct vm_area_struct *__install_special_mapping(
+	struct mm_struct *mm,
+	unsigned long addr, unsigned long len,
+	unsigned long vm_flags, const struct vm_operations_struct *ops,
+	void *priv)
 {
 	int ret;
 	struct vm_area_struct *vma;
@@ -2940,8 +2952,8 @@ struct vm_area_struct *_install_special_mapping(struct mm_struct *mm,
 	vma->vm_flags = vm_flags | mm->def_flags | VM_DONTEXPAND | VM_SOFTDIRTY;
 	vma->vm_page_prot = vm_get_page_prot(vma->vm_flags);
 
-	vma->vm_ops = &special_mapping_vmops;
-	vma->vm_private_data = pages;
+	vma->vm_ops = ops;
+	vma->vm_private_data = priv;
 
 	ret = insert_vm_struct(mm, vma);
 	if (ret)
@@ -2958,12 +2970,31 @@ out:
 	return ERR_PTR(ret);
 }
 
+/*
+ * Called with mm->mmap_sem held for writing.
+ * Insert a new vma covering the given region, with the given flags.
+ * Its pages are supplied by the given array of struct page *.
+ * The array can be shorter than len >> PAGE_SHIFT if it's null-terminated.
+ * The region past the last page supplied will always produce SIGBUS.
+ * The array pointer and the pages it points to are assumed to stay alive
+ * for as long as this mapping might exist.
+ */
+struct vm_area_struct *_install_special_mapping(
+	struct mm_struct *mm,
+	unsigned long addr, unsigned long len,
+	unsigned long vm_flags, const struct vm_special_mapping *spec)
+{
+	return __install_special_mapping(mm, addr, len, vm_flags,
+					 &special_mapping_vmops, (void *)spec);
+}
+
 int install_special_mapping(struct mm_struct *mm,
 			    unsigned long addr, unsigned long len,
 			    unsigned long vm_flags, struct page **pages)
 {
-	struct vm_area_struct *vma = _install_special_mapping(mm,
-			    addr, len, vm_flags, pages);
+	struct vm_area_struct *vma = __install_special_mapping(
+		mm, addr, len, vm_flags, &legacy_special_mapping_vmops,
+		(void *)pages);
 
 	if (IS_ERR(vma))
 		return PTR_ERR(vma);
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
