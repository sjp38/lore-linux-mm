Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id F03D86B0082
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 06:00:38 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [RFC v17][PATCH 01/60] c/r: extend arch_setup_additional_pages()
Date: Wed, 22 Jul 2009 05:59:23 -0400
Message-Id: <1248256822-23416-2-git-send-email-orenl@librato.com>
In-Reply-To: <1248256822-23416-1-git-send-email-orenl@librato.com>
References: <1248256822-23416-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

From: Alexey Dobriyan <adobriyan@gmail.com>

Add "start" argument, to request to map vDSO to a specific place,
and fail the operation if not.

This is useful for restart(2) to ensure that memory layout is restore
exactly as needed.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
---
 arch/powerpc/include/asm/elf.h     |    1 +
 arch/powerpc/kernel/vdso.c         |   13 ++++++++++++-
 arch/s390/include/asm/elf.h        |    2 +-
 arch/s390/kernel/vdso.c            |   13 ++++++++++++-
 arch/sh/include/asm/elf.h          |    1 +
 arch/sh/kernel/vsyscall/vsyscall.c |    2 +-
 arch/x86/include/asm/elf.h         |    3 ++-
 arch/x86/vdso/vdso32-setup.c       |    9 +++++++--
 arch/x86/vdso/vma.c                |    9 +++++++--
 fs/binfmt_elf.c                    |    2 +-
 10 files changed, 45 insertions(+), 10 deletions(-)

diff --git a/arch/powerpc/include/asm/elf.h b/arch/powerpc/include/asm/elf.h
index 014a624..3cef9cf 100644
--- a/arch/powerpc/include/asm/elf.h
+++ b/arch/powerpc/include/asm/elf.h
@@ -271,6 +271,7 @@ extern int ucache_bsize;
 #define ARCH_HAS_SETUP_ADDITIONAL_PAGES
 struct linux_binprm;
 extern int arch_setup_additional_pages(struct linux_binprm *bprm,
+				       unsigned long start,
 				       int uses_interp);
 #define VDSO_AUX_ENT(a,b) NEW_AUX_ENT(a,b);
 
diff --git a/arch/powerpc/kernel/vdso.c b/arch/powerpc/kernel/vdso.c
index ad06d5c..c25213b 100644
--- a/arch/powerpc/kernel/vdso.c
+++ b/arch/powerpc/kernel/vdso.c
@@ -184,7 +184,8 @@ static void dump_vdso_pages(struct vm_area_struct * vma)
  * This is called from binfmt_elf, we create the special vma for the
  * vDSO and insert it into the mm struct tree
  */
-int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
+int arch_setup_additional_pages(struct linux_binprm *bprm,
+				unsigned long start, int uses_interp)
 {
 	struct mm_struct *mm = current->mm;
 	struct page **vdso_pagelist;
@@ -211,6 +212,10 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	vdso_base = VDSO32_MBASE;
 #endif
 
+	/* in case restart(2) mandates a specific location */
+	if (start)
+		vdso_base = start;
+
 	current->mm->context.vdso_base = 0;
 
 	/* vDSO has a problem and was disabled, just don't "enable" it for the
@@ -234,6 +239,12 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 		goto fail_mmapsem;
 	}
 
+	/* for restart(2), double check that we got we asked for */
+	if (start && vdso_base != start) {
+		ret = -EBUSY;
+		goto fail_mmapsem;
+	}
+
 	/*
 	 * our vma flags don't have VM_WRITE so by default, the process isn't
 	 * allowed to write those pages.
diff --git a/arch/s390/include/asm/elf.h b/arch/s390/include/asm/elf.h
index 74d0bbb..54235bc 100644
--- a/arch/s390/include/asm/elf.h
+++ b/arch/s390/include/asm/elf.h
@@ -205,6 +205,6 @@ do {									    \
 struct linux_binprm;
 
 #define ARCH_HAS_SETUP_ADDITIONAL_PAGES 1
-int arch_setup_additional_pages(struct linux_binprm *, int);
+int arch_setup_additional_pages(struct linux_binprm *, unsigned long, int);
 
 #endif
diff --git a/arch/s390/kernel/vdso.c b/arch/s390/kernel/vdso.c
index 45e1708..c2ee689 100644
--- a/arch/s390/kernel/vdso.c
+++ b/arch/s390/kernel/vdso.c
@@ -193,7 +193,8 @@ static void vdso_init_cr5(void)
  * This is called from binfmt_elf, we create the special vma for the
  * vDSO and insert it into the mm struct tree
  */
-int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
+int arch_setup_additional_pages(struct linux_binprm *bprm,
+				unsigned long start, int uses_interp)
 {
 	struct mm_struct *mm = current->mm;
 	struct page **vdso_pagelist;
@@ -224,6 +225,10 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	vdso_pages = vdso32_pages;
 #endif
 
+	/* in case restart(2) mandates a specific location */
+	if (start)
+		vdso_base = start;
+
 	/*
 	 * vDSO has a problem and was disabled, just don't "enable" it for
 	 * the process
@@ -246,6 +251,12 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 		goto out_up;
 	}
 
+	/* for restart(2), double check that we got we asked for */
+	if (start && vdso_base != start) {
+		rc = -EINVAL;
+		goto out_up;
+	}
+
 	/*
 	 * our vma flags don't have VM_WRITE so by default, the process
 	 * isn't allowed to write those pages.
diff --git a/arch/sh/include/asm/elf.h b/arch/sh/include/asm/elf.h
index ccb1d93..6c27b1f 100644
--- a/arch/sh/include/asm/elf.h
+++ b/arch/sh/include/asm/elf.h
@@ -202,6 +202,7 @@ do {									\
 #define ARCH_HAS_SETUP_ADDITIONAL_PAGES
 struct linux_binprm;
 extern int arch_setup_additional_pages(struct linux_binprm *bprm,
+				       unsigned long start,
 				       int uses_interp);
 
 extern unsigned int vdso_enabled;
diff --git a/arch/sh/kernel/vsyscall/vsyscall.c b/arch/sh/kernel/vsyscall/vsyscall.c
index 3f7e415..64c70e5 100644
--- a/arch/sh/kernel/vsyscall/vsyscall.c
+++ b/arch/sh/kernel/vsyscall/vsyscall.c
@@ -59,7 +59,7 @@ int __init vsyscall_init(void)
 }
 
 /* Setup a VMA at program startup for the vsyscall page */
-int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
+int arch_setup_additional_pages(struct linux_binprm *bprm, unsigned long start, int uses_interp)
 {
 	struct mm_struct *mm = current->mm;
 	unsigned long addr;
diff --git a/arch/x86/include/asm/elf.h b/arch/x86/include/asm/elf.h
index 83c1bc8..a4398c8 100644
--- a/arch/x86/include/asm/elf.h
+++ b/arch/x86/include/asm/elf.h
@@ -336,9 +336,10 @@ struct linux_binprm;
 
 #define ARCH_HAS_SETUP_ADDITIONAL_PAGES 1
 extern int arch_setup_additional_pages(struct linux_binprm *bprm,
+				       unsigned long start,
 				       int uses_interp);
 
-extern int syscall32_setup_pages(struct linux_binprm *, int exstack);
+extern int syscall32_setup_pages(struct linux_binprm *, unsigned long start, int exstack);
 #define compat_arch_setup_additional_pages	syscall32_setup_pages
 
 extern unsigned long arch_randomize_brk(struct mm_struct *mm);
diff --git a/arch/x86/vdso/vdso32-setup.c b/arch/x86/vdso/vdso32-setup.c
index 58bc00f..5c914b0 100644
--- a/arch/x86/vdso/vdso32-setup.c
+++ b/arch/x86/vdso/vdso32-setup.c
@@ -310,7 +310,8 @@ int __init sysenter_setup(void)
 }
 
 /* Setup a VMA at program startup for the vsyscall page */
-int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
+int arch_setup_additional_pages(struct linux_binprm *bprm,
+				unsigned long start, int uses_interp)
 {
 	struct mm_struct *mm = current->mm;
 	unsigned long addr;
@@ -331,13 +332,17 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	if (compat)
 		addr = VDSO_HIGH_BASE;
 	else {
-		addr = get_unmapped_area(NULL, 0, PAGE_SIZE, 0, 0);
+		addr = get_unmapped_area(NULL, start, PAGE_SIZE, 0, 0);
 		if (IS_ERR_VALUE(addr)) {
 			ret = addr;
 			goto up_fail;
 		}
 	}
 
+	/* for restart(2), double check that we got we asked for */
+	if (start && addr != start)
+		goto up_fail;
+
 	current->mm->context.vdso = (void *)addr;
 
 	if (compat_uses_vma || !compat) {
diff --git a/arch/x86/vdso/vma.c b/arch/x86/vdso/vma.c
index 21e1aeb..393b22a 100644
--- a/arch/x86/vdso/vma.c
+++ b/arch/x86/vdso/vma.c
@@ -99,7 +99,8 @@ static unsigned long vdso_addr(unsigned long start, unsigned len)
 
 /* Setup a VMA at program startup for the vsyscall page.
    Not called for compat tasks */
-int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
+int arch_setup_additional_pages(struct linux_binprm *bprm,
+				unsigned long start, int uses_interp)
 {
 	struct mm_struct *mm = current->mm;
 	unsigned long addr;
@@ -109,13 +110,17 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 		return 0;
 
 	down_write(&mm->mmap_sem);
-	addr = vdso_addr(mm->start_stack, vdso_size);
+	addr = start ? : vdso_addr(mm->start_stack, vdso_size);
 	addr = get_unmapped_area(NULL, addr, vdso_size, 0, 0);
 	if (IS_ERR_VALUE(addr)) {
 		ret = addr;
 		goto up_fail;
 	}
 
+	/* for restart(2), double check that we got we asked for */
+	if (start && addr != start)
+		goto up_fail;
+
 	current->mm->context.vdso = (void *)addr;
 
 	ret = install_special_mapping(mm, addr, vdso_size,
diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index b7c1603..14a1b3c 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -945,7 +945,7 @@ static int load_elf_binary(struct linux_binprm *bprm, struct pt_regs *regs)
 	set_binfmt(&elf_format);
 
 #ifdef ARCH_HAS_SETUP_ADDITIONAL_PAGES
-	retval = arch_setup_additional_pages(bprm, !!elf_interpreter);
+	retval = arch_setup_additional_pages(bprm, 0, !!elf_interpreter);
 	if (retval < 0) {
 		send_sig(SIGKILL, current, 0);
 		goto out;
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
