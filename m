Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4B635280250
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 13:11:56 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id i85so11035109pfa.5
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 10:11:56 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0134.outbound.protection.outlook.com. [104.47.1.134])
        by mx.google.com with ESMTPS id b190si8872791pfa.34.2016.10.27.10.11.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 27 Oct 2016 10:11:55 -0700 (PDT)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv3 3/8] powerpc/vdso: separate common code in vdso_common
Date: Thu, 27 Oct 2016 20:09:43 +0300
Message-ID: <20161027170948.8279-4-dsafonov@virtuozzo.com>
In-Reply-To: <20161027170948.8279-1-dsafonov@virtuozzo.com>
References: <20161027170948.8279-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dmitry Safonov <dsafonov@virtuozzo.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Andy Lutomirski <luto@amacapital.net>, Oleg Nesterov <oleg@redhat.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Impact: cleanup

There are common functions for handeling 32-bit and 64-bit vDSO ELF
files: find_section{32,64}, find_symbol{32,64}, find_function{32,64},
vdso_do_func_patch{32,64}, vdso_do_find_sections{32,64},
vdso_fixup_datapag{32,64}, vdso_fixup_features{32,64}, vdso_setup{32,64}
which all do the same work with the only difference is using structures
for 32 or 64 bit ELF. Let's combine them into common code, reducing
copy'n'paste code.

Small changes:
I also switched usage of printk(KERNEL_<LEVEL>,...) on pr_<level>(...)
and used pr_fmt() macro for "vDSO{32,64}: " prefix.

Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-mm@kvack.org
Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
---
 arch/powerpc/kernel/vdso.c        | 352 ++------------------------------------
 arch/powerpc/kernel/vdso_common.c | 221 ++++++++++++++++++++++++
 2 files changed, 234 insertions(+), 339 deletions(-)
 create mode 100644 arch/powerpc/kernel/vdso_common.c

diff --git a/arch/powerpc/kernel/vdso.c b/arch/powerpc/kernel/vdso.c
index 278b9aa25a1c..8010a0d82049 100644
--- a/arch/powerpc/kernel/vdso.c
+++ b/arch/powerpc/kernel/vdso.c
@@ -51,13 +51,13 @@
 #define VDSO_ALIGNMENT	(1 << 16)
 
 static unsigned int vdso32_pages;
-static void *vdso32_kbase;
 static struct page **vdso32_pagelist;
 unsigned long vdso32_sigtramp;
 unsigned long vdso32_rt_sigtramp;
 
 #ifdef CONFIG_VDSO32
 extern char vdso32_start, vdso32_end;
+static void *vdso32_kbase;
 #endif
 
 #ifdef CONFIG_PPC64
@@ -246,250 +246,16 @@ const char *arch_vma_name(struct vm_area_struct *vma)
 	return NULL;
 }
 
-
-
 #ifdef CONFIG_VDSO32
-static void * __init find_section32(Elf32_Ehdr *ehdr, const char *secname,
-				  unsigned long *size)
-{
-	Elf32_Shdr *sechdrs;
-	unsigned int i;
-	char *secnames;
-
-	/* Grab section headers and strings so we can tell who is who */
-	sechdrs = (void *)ehdr + ehdr->e_shoff;
-	secnames = (void *)ehdr + sechdrs[ehdr->e_shstrndx].sh_offset;
-
-	/* Find the section they want */
-	for (i = 1; i < ehdr->e_shnum; i++) {
-		if (strcmp(secnames+sechdrs[i].sh_name, secname) == 0) {
-			if (size)
-				*size = sechdrs[i].sh_size;
-			return (void *)ehdr + sechdrs[i].sh_offset;
-		}
-	}
-	*size = 0;
-	return NULL;
-}
-
-static Elf32_Sym * __init find_symbol32(struct lib32_elfinfo *lib,
-					const char *symname)
-{
-	unsigned int i;
-	char name[MAX_SYMNAME], *c;
-
-	for (i = 0; i < (lib->dynsymsize / sizeof(Elf32_Sym)); i++) {
-		if (lib->dynsym[i].st_name == 0)
-			continue;
-		strlcpy(name, lib->dynstr + lib->dynsym[i].st_name,
-			MAX_SYMNAME);
-		c = strchr(name, '@');
-		if (c)
-			*c = 0;
-		if (strcmp(symname, name) == 0)
-			return &lib->dynsym[i];
-	}
-	return NULL;
-}
-
-/* Note that we assume the section is .text and the symbol is relative to
- * the library base
- */
-static unsigned long __init find_function32(struct lib32_elfinfo *lib,
-					    const char *symname)
-{
-	Elf32_Sym *sym = find_symbol32(lib, symname);
-
-	if (sym == NULL) {
-		printk(KERN_WARNING "vDSO32: function %s not found !\n",
-		       symname);
-		return 0;
-	}
-	return sym->st_value - VDSO32_LBASE;
-}
-
-static int __init vdso_do_func_patch32(struct lib32_elfinfo *v32,
-				       const char *orig, const char *fix)
-{
-	Elf32_Sym *sym32_gen, *sym32_fix;
-
-	sym32_gen = find_symbol32(v32, orig);
-	if (sym32_gen == NULL) {
-		printk(KERN_ERR "vDSO32: Can't find symbol %s !\n", orig);
-		return -1;
-	}
-	if (fix == NULL) {
-		sym32_gen->st_name = 0;
-		return 0;
-	}
-	sym32_fix = find_symbol32(v32, fix);
-	if (sym32_fix == NULL) {
-		printk(KERN_ERR "vDSO32: Can't find symbol %s !\n", fix);
-		return -1;
-	}
-	sym32_gen->st_value = sym32_fix->st_value;
-	sym32_gen->st_size = sym32_fix->st_size;
-	sym32_gen->st_info = sym32_fix->st_info;
-	sym32_gen->st_other = sym32_fix->st_other;
-	sym32_gen->st_shndx = sym32_fix->st_shndx;
-
-	return 0;
-}
-#else /* !CONFIG_VDSO32 */
-static unsigned long __init find_function32(struct lib32_elfinfo *lib,
-					    const char *symname)
-{
-	return 0;
-}
-
-static int __init vdso_do_func_patch32(struct lib32_elfinfo *v32,
-				       const char *orig, const char *fix)
-{
-	return 0;
-}
+#include "vdso_common.c"
 #endif /* CONFIG_VDSO32 */
 
-
 #ifdef CONFIG_PPC64
-
-static void * __init find_section64(Elf64_Ehdr *ehdr, const char *secname,
-				  unsigned long *size)
-{
-	Elf64_Shdr *sechdrs;
-	unsigned int i;
-	char *secnames;
-
-	/* Grab section headers and strings so we can tell who is who */
-	sechdrs = (void *)ehdr + ehdr->e_shoff;
-	secnames = (void *)ehdr + sechdrs[ehdr->e_shstrndx].sh_offset;
-
-	/* Find the section they want */
-	for (i = 1; i < ehdr->e_shnum; i++) {
-		if (strcmp(secnames+sechdrs[i].sh_name, secname) == 0) {
-			if (size)
-				*size = sechdrs[i].sh_size;
-			return (void *)ehdr + sechdrs[i].sh_offset;
-		}
-	}
-	if (size)
-		*size = 0;
-	return NULL;
-}
-
-static Elf64_Sym * __init find_symbol64(struct lib64_elfinfo *lib,
-					const char *symname)
-{
-	unsigned int i;
-	char name[MAX_SYMNAME], *c;
-
-	for (i = 0; i < (lib->dynsymsize / sizeof(Elf64_Sym)); i++) {
-		if (lib->dynsym[i].st_name == 0)
-			continue;
-		strlcpy(name, lib->dynstr + lib->dynsym[i].st_name,
-			MAX_SYMNAME);
-		c = strchr(name, '@');
-		if (c)
-			*c = 0;
-		if (strcmp(symname, name) == 0)
-			return &lib->dynsym[i];
-	}
-	return NULL;
-}
-
-/* Note that we assume the section is .text and the symbol is relative to
- * the library base
- */
-static unsigned long __init find_function64(struct lib64_elfinfo *lib,
-					    const char *symname)
-{
-	Elf64_Sym *sym = find_symbol64(lib, symname);
-
-	if (sym == NULL) {
-		printk(KERN_WARNING "vDSO64: function %s not found !\n",
-		       symname);
-		return 0;
-	}
-#ifdef VDS64_HAS_DESCRIPTORS
-	return *((u64 *)(vdso64_kbase + sym->st_value - VDSO64_LBASE)) -
-		VDSO64_LBASE;
-#else
-	return sym->st_value - VDSO64_LBASE;
-#endif
-}
-
-static int __init vdso_do_func_patch64(struct lib64_elfinfo *v64,
-				       const char *orig, const char *fix)
-{
-	Elf64_Sym *sym64_gen, *sym64_fix;
-
-	sym64_gen = find_symbol64(v64, orig);
-	if (sym64_gen == NULL) {
-		printk(KERN_ERR "vDSO64: Can't find symbol %s !\n", orig);
-		return -1;
-	}
-	if (fix == NULL) {
-		sym64_gen->st_name = 0;
-		return 0;
-	}
-	sym64_fix = find_symbol64(v64, fix);
-	if (sym64_fix == NULL) {
-		printk(KERN_ERR "vDSO64: Can't find symbol %s !\n", fix);
-		return -1;
-	}
-	sym64_gen->st_value = sym64_fix->st_value;
-	sym64_gen->st_size = sym64_fix->st_size;
-	sym64_gen->st_info = sym64_fix->st_info;
-	sym64_gen->st_other = sym64_fix->st_other;
-	sym64_gen->st_shndx = sym64_fix->st_shndx;
-
-	return 0;
-}
-
+#define BITS 64
+#include "vdso_common.c"
 #endif /* CONFIG_PPC64 */
 
 
-static __init int vdso_do_find_sections(struct lib32_elfinfo *v32,
-					struct lib64_elfinfo *v64)
-{
-	void *sect;
-
-	/*
-	 * Locate symbol tables & text section
-	 */
-
-#ifdef CONFIG_VDSO32
-	v32->dynsym = find_section32(v32->hdr, ".dynsym", &v32->dynsymsize);
-	v32->dynstr = find_section32(v32->hdr, ".dynstr", NULL);
-	if (v32->dynsym == NULL || v32->dynstr == NULL) {
-		printk(KERN_ERR "vDSO32: required symbol section not found\n");
-		return -1;
-	}
-	sect = find_section32(v32->hdr, ".text", NULL);
-	if (sect == NULL) {
-		printk(KERN_ERR "vDSO32: the .text section was not found\n");
-		return -1;
-	}
-	v32->text = sect - vdso32_kbase;
-#endif
-
-#ifdef CONFIG_PPC64
-	v64->dynsym = find_section64(v64->hdr, ".dynsym", &v64->dynsymsize);
-	v64->dynstr = find_section64(v64->hdr, ".dynstr", NULL);
-	if (v64->dynsym == NULL || v64->dynstr == NULL) {
-		printk(KERN_ERR "vDSO64: required symbol section not found\n");
-		return -1;
-	}
-	sect = find_section64(v64->hdr, ".text", NULL);
-	if (sect == NULL) {
-		printk(KERN_ERR "vDSO64: the .text section was not found\n");
-		return -1;
-	}
-	v64->text = sect - vdso64_kbase;
-#endif /* CONFIG_PPC64 */
-
-	return 0;
-}
-
 static __init void vdso_setup_trampolines(struct lib32_elfinfo *v32,
 					  struct lib64_elfinfo *v64)
 {
@@ -500,99 +266,10 @@ static __init void vdso_setup_trampolines(struct lib32_elfinfo *v32,
 #ifdef CONFIG_PPC64
 	vdso64_rt_sigtramp = find_function64(v64, "__kernel_sigtramp_rt64");
 #endif
+#ifdef CONFIG_VDSO32
 	vdso32_sigtramp	   = find_function32(v32, "__kernel_sigtramp32");
 	vdso32_rt_sigtramp = find_function32(v32, "__kernel_sigtramp_rt32");
-}
-
-static __init int vdso_fixup_datapage(struct lib32_elfinfo *v32,
-				       struct lib64_elfinfo *v64)
-{
-#ifdef CONFIG_VDSO32
-	Elf32_Sym *sym32;
-#endif
-#ifdef CONFIG_PPC64
-	Elf64_Sym *sym64;
-
-       	sym64 = find_symbol64(v64, "__kernel_datapage_offset");
-	if (sym64 == NULL) {
-		printk(KERN_ERR "vDSO64: Can't find symbol "
-		       "__kernel_datapage_offset !\n");
-		return -1;
-	}
-	*((int *)(vdso64_kbase + sym64->st_value - VDSO64_LBASE)) =
-		(vdso64_pages << PAGE_SHIFT) -
-		(sym64->st_value - VDSO64_LBASE);
-#endif /* CONFIG_PPC64 */
-
-#ifdef CONFIG_VDSO32
-	sym32 = find_symbol32(v32, "__kernel_datapage_offset");
-	if (sym32 == NULL) {
-		printk(KERN_ERR "vDSO32: Can't find symbol "
-		       "__kernel_datapage_offset !\n");
-		return -1;
-	}
-	*((int *)(vdso32_kbase + (sym32->st_value - VDSO32_LBASE))) =
-		(vdso32_pages << PAGE_SHIFT) -
-		(sym32->st_value - VDSO32_LBASE);
 #endif
-
-	return 0;
-}
-
-
-static __init int vdso_fixup_features(struct lib32_elfinfo *v32,
-				      struct lib64_elfinfo *v64)
-{
-	unsigned long size;
-	void *start;
-
-#ifdef CONFIG_PPC64
-	start = find_section64(v64->hdr, "__ftr_fixup", &size);
-	if (start)
-		do_feature_fixups(cur_cpu_spec->cpu_features,
-				  start, start + size);
-
-	start = find_section64(v64->hdr, "__mmu_ftr_fixup", &size);
-	if (start)
-		do_feature_fixups(cur_cpu_spec->mmu_features,
-				  start, start + size);
-
-	start = find_section64(v64->hdr, "__fw_ftr_fixup", &size);
-	if (start)
-		do_feature_fixups(powerpc_firmware_features,
-				  start, start + size);
-
-	start = find_section64(v64->hdr, "__lwsync_fixup", &size);
-	if (start)
-		do_lwsync_fixups(cur_cpu_spec->cpu_features,
-				 start, start + size);
-#endif /* CONFIG_PPC64 */
-
-#ifdef CONFIG_VDSO32
-	start = find_section32(v32->hdr, "__ftr_fixup", &size);
-	if (start)
-		do_feature_fixups(cur_cpu_spec->cpu_features,
-				  start, start + size);
-
-	start = find_section32(v32->hdr, "__mmu_ftr_fixup", &size);
-	if (start)
-		do_feature_fixups(cur_cpu_spec->mmu_features,
-				  start, start + size);
-
-#ifdef CONFIG_PPC64
-	start = find_section32(v32->hdr, "__fw_ftr_fixup", &size);
-	if (start)
-		do_feature_fixups(powerpc_firmware_features,
-				  start, start + size);
-#endif /* CONFIG_PPC64 */
-
-	start = find_section32(v32->hdr, "__lwsync_fixup", &size);
-	if (start)
-		do_lwsync_fixups(cur_cpu_spec->cpu_features,
-				 start, start + size);
-#endif
-
-	return 0;
 }
 
 static __init int vdso_fixup_alt_funcs(struct lib32_elfinfo *v32,
@@ -616,7 +293,9 @@ static __init int vdso_fixup_alt_funcs(struct lib32_elfinfo *v32,
 		 * It would be easy to do, but doesn't seem to be necessary,
 		 * patching the OPD symbol is enough.
 		 */
+#ifdef CONFIG_VDSO32
 		vdso_do_func_patch32(v32, patch->gen_name, patch->fix_name);
+#endif
 #ifdef CONFIG_PPC64
 		vdso_do_func_patch64(v64, patch->gen_name, patch->fix_name);
 #endif /* CONFIG_PPC64 */
@@ -625,24 +304,19 @@ static __init int vdso_fixup_alt_funcs(struct lib32_elfinfo *v32,
 	return 0;
 }
 
-
 static __init int vdso_setup(void)
 {
 	struct lib32_elfinfo	v32;
 	struct lib64_elfinfo	v64;
 
-	v32.hdr = vdso32_kbase;
-#ifdef CONFIG_PPC64
-	v64.hdr = vdso64_kbase;
-#endif
-	if (vdso_do_find_sections(&v32, &v64))
-		return -1;
-
-	if (vdso_fixup_datapage(&v32, &v64))
+#ifdef CONFIG_VDSO32
+	if (vdso_setup32(&v32))
 		return -1;
-
-	if (vdso_fixup_features(&v32, &v64))
+#endif
+#ifdef CONFIG_PPC64
+	if (vdso_setup64(&v64))
 		return -1;
+#endif
 
 	if (vdso_fixup_alt_funcs(&v32, &v64))
 		return -1;
diff --git a/arch/powerpc/kernel/vdso_common.c b/arch/powerpc/kernel/vdso_common.c
new file mode 100644
index 000000000000..ac25d66134fb
--- /dev/null
+++ b/arch/powerpc/kernel/vdso_common.c
@@ -0,0 +1,221 @@
+#ifndef BITS
+#define BITS 32
+#endif
+
+#undef Elf_Ehdr
+#undef Elf_Sym
+#undef Elf_Shdr
+
+#define _CONCAT3(a, b, c)	a ## b ## c
+#define CONCAT3(a, b, c)	_CONCAT3(a, b, c)
+#define Elf_Ehdr	CONCAT3(Elf,  BITS, _Ehdr)
+#define Elf_Sym		CONCAT3(Elf,  BITS, _Sym)
+#define Elf_Shdr	CONCAT3(Elf,  BITS, _Shdr)
+#define VDSO_LBASE	CONCAT3(VDSO, BITS, _LBASE)
+#define vdso_kbase	CONCAT3(vdso, BITS, _kbase)
+#define vdso_pages	CONCAT3(vdso, BITS, _pages)
+
+#undef pr_fmt
+#define pr_fmt(fmt)	"vDSO" __stringify(BITS) ": " fmt
+
+#define lib_elfinfo CONCAT3(lib, BITS, _elfinfo)
+
+#define find_section CONCAT3(find_section, BITS,)
+static void * __init find_section(Elf_Ehdr *ehdr, const char *secname,
+		unsigned long *size)
+{
+	Elf_Shdr *sechdrs;
+	unsigned int i;
+	char *secnames;
+
+	/* Grab section headers and strings so we can tell who is who */
+	sechdrs = (void *)ehdr + ehdr->e_shoff;
+	secnames = (void *)ehdr + sechdrs[ehdr->e_shstrndx].sh_offset;
+
+	/* Find the section they want */
+	for (i = 1; i < ehdr->e_shnum; i++) {
+		if (strcmp(secnames+sechdrs[i].sh_name, secname) == 0) {
+			if (size)
+				*size = sechdrs[i].sh_size;
+			return (void *)ehdr + sechdrs[i].sh_offset;
+		}
+	}
+	if (size)
+		*size = 0;
+	return NULL;
+}
+
+#define find_symbol CONCAT3(find_symbol, BITS,)
+static Elf_Sym * __init find_symbol(struct lib_elfinfo *lib,
+		const char *symname)
+{
+	unsigned int i;
+	char name[MAX_SYMNAME], *c;
+
+	for (i = 0; i < (lib->dynsymsize / sizeof(Elf_Sym)); i++) {
+		if (lib->dynsym[i].st_name == 0)
+			continue;
+		strlcpy(name, lib->dynstr + lib->dynsym[i].st_name,
+			MAX_SYMNAME);
+		c = strchr(name, '@');
+		if (c)
+			*c = 0;
+		if (strcmp(symname, name) == 0)
+			return &lib->dynsym[i];
+	}
+	return NULL;
+}
+
+/*
+ * Note that we assume the section is .text and the symbol is relative to
+ * the library base.
+ */
+#define find_function CONCAT3(find_function, BITS,)
+static unsigned long __init find_function(struct lib_elfinfo *lib,
+		const char *symname)
+{
+	Elf_Sym *sym = find_symbol(lib, symname);
+
+	if (sym == NULL) {
+		pr_warn("function %s not found !\n", symname);
+		return 0;
+	}
+#if defined(VDS64_HAS_DESCRIPTORS) && (BITS == 64)
+	return *((u64 *)(vdso64_kbase + sym->st_value - VDSO64_LBASE)) -
+		VDSO64_LBASE;
+#else
+	return sym->st_value - VDSO_LBASE;
+#endif
+}
+
+#define vdso_do_func_patch CONCAT3(vdso_do_func_patch, BITS,)
+static int __init vdso_do_func_patch(struct lib_elfinfo *v,
+		const char *orig, const char *fix)
+{
+	Elf_Sym *sym_gen, *sym_fix;
+
+	sym_gen = find_symbol(v, orig);
+	if (sym_gen == NULL) {
+		pr_err("Can't find symbol %s !\n", orig);
+		return -1;
+	}
+	if (fix == NULL) {
+		sym_gen->st_name = 0;
+		return 0;
+	}
+	sym_fix = find_symbol(v, fix);
+	if (sym_fix == NULL) {
+		pr_err("Can't find symbol %s !\n", fix);
+		return -1;
+	}
+	sym_gen->st_value = sym_fix->st_value;
+	sym_gen->st_size = sym_fix->st_size;
+	sym_gen->st_info = sym_fix->st_info;
+	sym_gen->st_other = sym_fix->st_other;
+	sym_gen->st_shndx = sym_fix->st_shndx;
+
+	return 0;
+}
+
+#define vdso_do_find_sections CONCAT3(vdso_do_find_sections, BITS,)
+static __init int vdso_do_find_sections(struct lib_elfinfo *v)
+{
+	void *sect;
+
+	/*
+	 * Locate symbol tables & text section
+	 */
+	v->dynsym = find_section(v->hdr, ".dynsym", &v->dynsymsize);
+	v->dynstr = find_section(v->hdr, ".dynstr", NULL);
+	if (v->dynsym == NULL || v->dynstr == NULL) {
+		pr_err("required symbol section not found\n");
+		return -1;
+	}
+
+	sect = find_section(v->hdr, ".text", NULL);
+	if (sect == NULL) {
+		pr_err("the .text section was not found\n");
+		return -1;
+	}
+	v->text = sect - vdso_kbase;
+
+	return 0;
+}
+
+#define vdso_fixup_datapage CONCAT3(vdso_fixup_datapage, BITS,)
+static __init int vdso_fixup_datapage(struct lib_elfinfo *v)
+{
+	Elf_Sym *sym = find_symbol(v, "__kernel_datapage_offset");
+
+	if (sym == NULL) {
+		pr_err("Can't find symbol __kernel_datapage_offset !\n");
+		return -1;
+	}
+	*((int *)(vdso_kbase + sym->st_value - VDSO_LBASE)) =
+		(vdso_pages << PAGE_SHIFT) - (sym->st_value - VDSO_LBASE);
+
+	return 0;
+}
+
+#define vdso_fixup_features CONCAT3(vdso_fixup_features, BITS,)
+static __init int vdso_fixup_features(struct lib_elfinfo *v)
+{
+	unsigned long size;
+	void *start;
+
+	start = find_section(v->hdr, "__ftr_fixup", &size);
+	if (start)
+		do_feature_fixups(cur_cpu_spec->cpu_features,
+				  start, start + size);
+
+	start = find_section(v->hdr, "__mmu_ftr_fixup", &size);
+	if (start)
+		do_feature_fixups(cur_cpu_spec->mmu_features,
+				  start, start + size);
+
+#ifdef CONFIG_PPC64
+	start = find_section(v->hdr, "__fw_ftr_fixup", &size);
+	if (start)
+		do_feature_fixups(powerpc_firmware_features,
+				  start, start + size);
+#endif /* CONFIG_PPC64 */
+
+	start = find_section(v->hdr, "__lwsync_fixup", &size);
+	if (start)
+		do_lwsync_fixups(cur_cpu_spec->cpu_features,
+				 start, start + size);
+
+	return 0;
+}
+
+#define vdso_setup CONCAT3(vdso_setup, BITS,)
+static __init int vdso_setup(struct lib_elfinfo *v)
+{
+	v->hdr = vdso_kbase;
+
+	if (vdso_do_find_sections(v))
+		return -1;
+	if (vdso_fixup_datapage(v))
+		return -1;
+	if (vdso_fixup_features(v))
+		return -1;
+	return 0;
+}
+
+
+#undef find_section
+#undef find_symbol
+#undef find_function
+#undef vdso_do_func_patch
+#undef vdso_do_find_sections
+#undef vdso_fixup_datapage
+#undef vdso_fixup_features
+#undef vdso_setup
+
+#undef VDSO_LBASE
+#undef vdso_kbase
+#undef vdso_pages
+#undef lib_elfinfo
+#undef BITS
+#undef _CONCAT3
+#undef CONCAT3
-- 
2.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
