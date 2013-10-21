Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id ED4EE6B02F2
	for <linux-mm@kvack.org>; Sun, 20 Oct 2013 23:26:29 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so6393013pbb.33
        for <linux-mm@kvack.org>; Sun, 20 Oct 2013 20:26:29 -0700 (PDT)
Received: from psmtp.com ([74.125.245.167])
        by mx.google.com with SMTP id fk10si7894295pab.174.2013.10.20.20.26.27
        for <linux-mm@kvack.org>;
        Sun, 20 Oct 2013 20:26:28 -0700 (PDT)
Message-ID: <1382325975.2402.3.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH 3/3] vdso: preallocate new vmas
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Sun, 20 Oct 2013 20:26:15 -0700
In-Reply-To: <1382057438-3306-4-git-send-email-davidlohr@hp.com>
References: <1382057438-3306-1-git-send-email-davidlohr@hp.com>
	 <1382057438-3306-4-git-send-email-davidlohr@hp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Michel Lespinasse <walken@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Tim Chen <tim.c.chen@linux.intel.com>, aswin@hp.com, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Richard Kuo <rkuo@codeaurora.org>, Ralf Baechle <ralf@linux-mips.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Paul Mundt <lethal@linux-sh.org>, Chris Metcalf <cmetcalf@tilera.com>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

From: Davidlohr Bueso <davidlohr@hp.com>
Subject: [PATCH v2 3/3] vdso: preallocate new vmas

With the exception of um and tile, architectures that use
the install_special_mapping() function, when setting up a
new vma at program startup, do so with the mmap_sem lock
held for writing. Unless there's an error, this process
ends up allocating a new vma through kmem_cache_zalloc,
and inserting it in the task's address space.

This patch moves the vma's space allocation outside of
install_special_mapping(), and leaves the callers to do so
explicitly, without depending on mmap_sem. The same goes for
freeing: if the new vma isn't used (and thus the process fails
at some point), it's caller's responsibility to free it -
currently this is done inside install_special_mapping.

Furthermore, uprobes behaves exactly the same and thus now the
xol_add_vma() function also preallocates the new vma.

While the changes to x86 vdso handling have been tested on both
large and small 64-bit systems, the rest of the architectures
are totally *untested*. Note that all changes are quite similar
from architecture to architecture.

Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
Cc: Russell King <linux@arm.linux.org.uk>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Richard Kuo <rkuo@codeaurora.org>
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Paul Mundt <lethal@linux-sh.org>
Cc: Chris Metcalf <cmetcalf@tilera.com>
Cc: Jeff Dike <jdike@addtoit.com>
Cc: Richard Weinberger <richard@nod.at>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
v2:
- Simplify install_special_mapping interface (Linus Torvalds)
- Fix return for uml_setup_stubs when mem allocation fails (Richard Weinberger)

 arch/arm/kernel/process.c          | 22 ++++++++++++++++------
 arch/arm64/kernel/vdso.c           | 21 +++++++++++++++++----
 arch/hexagon/kernel/vdso.c         | 16 ++++++++++++----
 arch/mips/kernel/vdso.c            | 10 +++++++++-
 arch/powerpc/kernel/vdso.c         | 11 ++++++++---
 arch/s390/kernel/vdso.c            | 19 +++++++++++++++----
 arch/sh/kernel/vsyscall/vsyscall.c | 11 ++++++++++-
 arch/tile/kernel/vdso.c            | 13 ++++++++++---
 arch/um/kernel/skas/mmu.c          | 16 +++++++++++-----
 arch/unicore32/kernel/process.c    | 17 ++++++++++++-----
 arch/x86/um/vdso/vma.c             | 18 ++++++++++++++----
 arch/x86/vdso/vdso32-setup.c       | 16 +++++++++++++++-
 arch/x86/vdso/vma.c                | 10 +++++++++-
 include/linux/mm.h                 |  3 ++-
 kernel/events/uprobes.c            | 14 ++++++++++++--
 mm/mmap.c                          | 17 ++++++-----------
 16 files changed, 178 insertions(+), 56 deletions(-)

diff --git a/arch/arm/kernel/process.c b/arch/arm/kernel/process.c
index 94f6b05..d1eb115 100644
--- a/arch/arm/kernel/process.c
+++ b/arch/arm/kernel/process.c
@@ -13,6 +13,7 @@
 #include <linux/export.h>
 #include <linux/sched.h>
 #include <linux/kernel.h>
+#include <linux/slab.h>
 #include <linux/mm.h>
 #include <linux/stddef.h>
 #include <linux/unistd.h>
@@ -480,6 +481,7 @@ extern struct page *get_signal_page(void);
 int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 {
 	struct mm_struct *mm = current->mm;
+	struct vm_area_struct *vma;
 	unsigned long addr;
 	int ret;
 
@@ -488,6 +490,10 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	if (!signal_page)
 		return -ENOMEM;
 
+	vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
+	if (unlikely(!vma))
+		return -ENOMEM;
+
 	down_write(&mm->mmap_sem);
 	addr = get_unmapped_area(NULL, 0, PAGE_SIZE, 0, 0);
 	if (IS_ERR_VALUE(addr)) {
@@ -496,14 +502,18 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	}
 
 	ret = install_special_mapping(mm, addr, PAGE_SIZE,
-		VM_READ | VM_EXEC | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC,
-		&signal_page);
-
-	if (ret == 0)
-		mm->context.sigpage = addr;
+				      VM_READ | VM_EXEC | VM_MAYREAD |
+				      VM_MAYWRITE | VM_MAYEXEC,
+				      &signal_page, vma);
+	if (ret)
+		goto up_fail;
 
- up_fail:
+	mm->context.sigpage = addr;
+	up_write(&mm->mmap_sem);
+	return 0;
+up_fail:
 	up_write(&mm->mmap_sem);
+	kmem_cache_free(vm_area_cachep, vma);
 	return ret;
 }
 #endif
diff --git a/arch/arm64/kernel/vdso.c b/arch/arm64/kernel/vdso.c
index 6a389dc..06a01ea 100644
--- a/arch/arm64/kernel/vdso.c
+++ b/arch/arm64/kernel/vdso.c
@@ -83,20 +83,26 @@ arch_initcall(alloc_vectors_page);
 
 int aarch32_setup_vectors_page(struct linux_binprm *bprm, int uses_interp)
 {
+	struct vm_area_struct *vma;
 	struct mm_struct *mm = current->mm;
 	unsigned long addr = AARCH32_VECTORS_BASE;
 	int ret;
 
+	vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
+	if (unlikely(!vma))
+		return -ENOMEM;
+
 	down_write(&mm->mmap_sem);
 	current->mm->context.vdso = (void *)addr;
 
 	/* Map vectors page at the high address. */
 	ret = install_special_mapping(mm, addr, PAGE_SIZE,
 				      VM_READ|VM_EXEC|VM_MAYREAD|VM_MAYEXEC,
-				      vectors_page);
+				      vectors_page, vma);
 
 	up_write(&mm->mmap_sem);
-
+	if (ret)
+		kmem_cache_free(vm_area_cachep, vma);
 	return ret;
 }
 #endif /* CONFIG_COMPAT */
@@ -152,10 +158,15 @@ arch_initcall(vdso_init);
 int arch_setup_additional_pages(struct linux_binprm *bprm,
 				int uses_interp)
 {
+	struct vm_area_struct *vma;
 	struct mm_struct *mm = current->mm;
 	unsigned long vdso_base, vdso_mapping_len;
 	int ret;
 
+	vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
+	if (unlikely(!vma))
+		return -ENOMEM;
+
 	/* Be sure to map the data page */
 	vdso_mapping_len = (vdso_pages + 1) << PAGE_SHIFT;
 
@@ -170,15 +181,17 @@ int arch_setup_additional_pages(struct linux_binprm *bprm,
 	ret = install_special_mapping(mm, vdso_base, vdso_mapping_len,
 				      VM_READ|VM_EXEC|
 				      VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC,
-				      vdso_pagelist);
+				      vdso_pagelist, vma);
 	if (ret) {
 		mm->context.vdso = NULL;
 		goto up_fail;
 	}
 
+	up_write(&mm->mmap_sem);
+	return ret;
 up_fail:
 	up_write(&mm->mmap_sem);
-
+	kmem_cache_free(vm_area_cachep, vma);
 	return ret;
 }
 
diff --git a/arch/hexagon/kernel/vdso.c b/arch/hexagon/kernel/vdso.c
index 0bf5a87..418a896 100644
--- a/arch/hexagon/kernel/vdso.c
+++ b/arch/hexagon/kernel/vdso.c
@@ -19,6 +19,7 @@
  */
 
 #include <linux/err.h>
+#include <linux/slab.h>
 #include <linux/mm.h>
 #include <linux/vmalloc.h>
 #include <linux/binfmts.h>
@@ -63,8 +64,13 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 {
 	int ret;
 	unsigned long vdso_base;
+	struct vm_area_struct *vma;
 	struct mm_struct *mm = current->mm;
 
+	vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
+	if (unlikely(!vma))
+		return -ENOMEM;
+
 	down_write(&mm->mmap_sem);
 
 	/* Try to get it loaded right near ld.so/glibc. */
@@ -78,17 +84,19 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 
 	/* MAYWRITE to allow gdb to COW and set breakpoints. */
 	ret = install_special_mapping(mm, vdso_base, PAGE_SIZE,
-				      VM_READ|VM_EXEC|
-				      VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC,
-				      &vdso_page);
-
+					      VM_READ|VM_EXEC|
+					      VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC,
+					      &vdso_page, vma);
 	if (ret)
 		goto up_fail;
 
 	mm->context.vdso = (void *)vdso_base;
 
+	up_write(&mm->mmap_sem);
+	return 0;
 up_fail:
 	up_write(&mm->mmap_sem);
+	kmem_cache_free(vm_area_cachep, vma);
 	return ret;
 }
 
diff --git a/arch/mips/kernel/vdso.c b/arch/mips/kernel/vdso.c
index 0f1af58..fb44fc9 100644
--- a/arch/mips/kernel/vdso.c
+++ b/arch/mips/kernel/vdso.c
@@ -74,8 +74,13 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 {
 	int ret;
 	unsigned long addr;
+	struct vm_area_struct *vma;
 	struct mm_struct *mm = current->mm;
 
+	vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
+	if (unlikely(!vma))
+		return -ENOMEM;
+
 	down_write(&mm->mmap_sem);
 
 	addr = vdso_addr(mm->start_stack);
@@ -89,15 +94,18 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	ret = install_special_mapping(mm, addr, PAGE_SIZE,
 				      VM_READ|VM_EXEC|
 				      VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC,
-				      &vdso_page);
+				      &vdso_page, vma);
 
 	if (ret)
 		goto up_fail;
 
 	mm->context.vdso = (void *)addr;
 
+	up_write(&mm->mmap_sem);
+	return 0;
 up_fail:
 	up_write(&mm->mmap_sem);
+	kmem_cache_free(vm_area_cachep, vma);
 	return ret;
 }
 
diff --git a/arch/powerpc/kernel/vdso.c b/arch/powerpc/kernel/vdso.c
index 1d9c926..ed339de 100644
--- a/arch/powerpc/kernel/vdso.c
+++ b/arch/powerpc/kernel/vdso.c
@@ -193,6 +193,7 @@ static void dump_vdso_pages(struct vm_area_struct * vma)
 int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 {
 	struct mm_struct *mm = current->mm;
+	struct vm_area_struct *vma;
 	struct page **vdso_pagelist;
 	unsigned long vdso_pages;
 	unsigned long vdso_base;
@@ -232,6 +233,10 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	/* Add a page to the vdso size for the data page */
 	vdso_pages ++;
 
+	vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
+	if (unlikely(!vma))
+		return -ENOMEM;
+
 	/*
 	 * pick a base address for the vDSO in process space. We try to put it
 	 * at vdso_base which is the "natural" base for it, but we might fail
@@ -271,7 +276,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	rc = install_special_mapping(mm, vdso_base, vdso_pages << PAGE_SHIFT,
 				     VM_READ|VM_EXEC|
 				     VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC,
-				     vdso_pagelist);
+				     vdso_pagelist, vma);
 	if (rc) {
 		current->mm->context.vdso_base = 0;
 		goto fail_mmapsem;
@@ -279,9 +284,9 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 
 	up_write(&mm->mmap_sem);
 	return 0;
-
- fail_mmapsem:
+fail_mmapsem:
 	up_write(&mm->mmap_sem);
+	kmem_cache_free(vm_area_cachep, vma);
 	return rc;
 }
 
diff --git a/arch/s390/kernel/vdso.c b/arch/s390/kernel/vdso.c
index 05d75c4..e2a707d 100644
--- a/arch/s390/kernel/vdso.c
+++ b/arch/s390/kernel/vdso.c
@@ -180,6 +180,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 {
 	struct mm_struct *mm = current->mm;
 	struct page **vdso_pagelist;
+	struct vm_area_struct *vma;
 	unsigned long vdso_pages;
 	unsigned long vdso_base;
 	int rc;
@@ -213,6 +214,10 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	if (vdso_pages == 0)
 		return 0;
 
+	vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
+	if (unlikely(!vma))
+		return -ENOMEM;
+
 	current->mm->context.vdso_base = 0;
 
 	/*
@@ -224,7 +229,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	vdso_base = get_unmapped_area(NULL, 0, vdso_pages << PAGE_SHIFT, 0, 0);
 	if (IS_ERR_VALUE(vdso_base)) {
 		rc = vdso_base;
-		goto out_up;
+		goto out_err;
 	}
 
 	/*
@@ -247,11 +252,17 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	rc = install_special_mapping(mm, vdso_base, vdso_pages << PAGE_SHIFT,
 				     VM_READ|VM_EXEC|
 				     VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC,
-				     vdso_pagelist);
-	if (rc)
+				     vdso_pagelist, vma);
+	if (rc) {
 		current->mm->context.vdso_base = 0;
-out_up:
+		goto out_err;
+	}
+
+	up_write(&mm->mmap_sem);
+	return 0;
+out_err:
 	up_write(&mm->mmap_sem);
+	kmem_cache_free(vm_area_cachep, vma);
 	return rc;
 }
 
diff --git a/arch/sh/kernel/vsyscall/vsyscall.c b/arch/sh/kernel/vsyscall/vsyscall.c
index 5ca5797..f2431da 100644
--- a/arch/sh/kernel/vsyscall/vsyscall.c
+++ b/arch/sh/kernel/vsyscall/vsyscall.c
@@ -10,6 +10,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  */
+#include <linux/slab.h>
 #include <linux/mm.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
@@ -61,9 +62,14 @@ int __init vsyscall_init(void)
 int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 {
 	struct mm_struct *mm = current->mm;
+	struct vm_area_struct *vma;
 	unsigned long addr;
 	int ret;
 
+	vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
+	if (unlikely(!vma))
+		return -ENOMEM;
+
 	down_write(&mm->mmap_sem);
 	addr = get_unmapped_area(NULL, 0, PAGE_SIZE, 0, 0);
 	if (IS_ERR_VALUE(addr)) {
@@ -74,14 +80,17 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	ret = install_special_mapping(mm, addr, PAGE_SIZE,
 				      VM_READ | VM_EXEC |
 				      VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC,
-				      syscall_pages);
+				      syscall_pages, vma);
 	if (unlikely(ret))
 		goto up_fail;
 
 	current->mm->context.vdso = (void *)addr;
 
+	up_write(&mm->mmap_sem);
+	return 0;
 up_fail:
 	up_write(&mm->mmap_sem);
+	kmem_cache_free(vm_area_cachep, vma);
 	return ret;
 }
 
diff --git a/arch/tile/kernel/vdso.c b/arch/tile/kernel/vdso.c
index 1533af2..e691c0b 100644
--- a/arch/tile/kernel/vdso.c
+++ b/arch/tile/kernel/vdso.c
@@ -15,6 +15,7 @@
 #include <linux/binfmts.h>
 #include <linux/compat.h>
 #include <linux/elf.h>
+#include <linux/slab.h>
 #include <linux/mm.h>
 #include <linux/pagemap.h>
 
@@ -140,6 +141,7 @@ int setup_vdso_pages(void)
 {
 	struct page **pagelist;
 	unsigned long pages;
+	struct vm_area_struct *vma;
 	struct mm_struct *mm = current->mm;
 	unsigned long vdso_base = 0;
 	int retval = 0;
@@ -147,6 +149,10 @@ int setup_vdso_pages(void)
 	if (!vdso_ready)
 		return 0;
 
+	vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
+	if (unlikely(!vma))
+		return -ENOMEM;
+
 	mm->context.vdso_base = 0;
 
 	pagelist = vdso_pagelist;
@@ -198,10 +204,11 @@ int setup_vdso_pages(void)
 					 pages << PAGE_SHIFT,
 					 VM_READ|VM_EXEC |
 					 VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC,
-					 pagelist);
-	if (retval)
+					 pagelist, vma);
+	if (retval) {
 		mm->context.vdso_base = 0;
-
+		kmem_cache_free(vm_area_cachep, vma);
+	}
 	return retval;
 }
 
diff --git a/arch/um/kernel/skas/mmu.c b/arch/um/kernel/skas/mmu.c
index 007d550..f08cd6c 100644
--- a/arch/um/kernel/skas/mmu.c
+++ b/arch/um/kernel/skas/mmu.c
@@ -104,18 +104,23 @@ int init_new_context(struct task_struct *task, struct mm_struct *mm)
 void uml_setup_stubs(struct mm_struct *mm)
 {
 	int err, ret;
+	struct vm_area_struct *vma;
 
 	if (!skas_needs_stub)
 		return;
 
+	vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
+	if (unlikely(!vma))
+		return;
+
 	ret = init_stub_pte(mm, STUB_CODE,
 			    (unsigned long) &__syscall_stub_start);
 	if (ret)
-		goto out;
+		goto err;
 
 	ret = init_stub_pte(mm, STUB_DATA, mm->context.id.stack);
 	if (ret)
-		goto out;
+		goto err;
 
 	mm->context.stub_pages[0] = virt_to_page(&__syscall_stub_start);
 	mm->context.stub_pages[1] = virt_to_page(mm->context.id.stack);
@@ -124,14 +129,15 @@ void uml_setup_stubs(struct mm_struct *mm)
 	err = install_special_mapping(mm, STUB_START, STUB_END - STUB_START,
 				      VM_READ | VM_MAYREAD | VM_EXEC |
 				      VM_MAYEXEC | VM_DONTCOPY | VM_PFNMAP,
-				      mm->context.stub_pages);
+				      mm->context.stub_pages, vma);
 	if (err) {
 		printk(KERN_ERR "install_special_mapping returned %d\n", err);
-		goto out;
+		goto err;
 	}
 	return;
 
-out:
+err:
+	kmem_cache_free(vm_area_cachep, vma);
 	force_sigsegv(SIGSEGV, current);
 }
 
diff --git a/arch/unicore32/kernel/process.c b/arch/unicore32/kernel/process.c
index 778ebba..d23adef 100644
--- a/arch/unicore32/kernel/process.c
+++ b/arch/unicore32/kernel/process.c
@@ -14,6 +14,7 @@
 #include <linux/module.h>
 #include <linux/sched.h>
 #include <linux/kernel.h>
+#include <linux/slab.h>
 #include <linux/mm.h>
 #include <linux/stddef.h>
 #include <linux/unistd.h>
@@ -313,12 +314,18 @@ unsigned long arch_randomize_brk(struct mm_struct *mm)
 
 int vectors_user_mapping(void)
 {
+	int ret = 0;
+	struct vm_area_struct *vma;
 	struct mm_struct *mm = current->mm;
-	return install_special_mapping(mm, 0xffff0000, PAGE_SIZE,
-				       VM_READ | VM_EXEC |
-				       VM_MAYREAD | VM_MAYEXEC |
-				       VM_DONTEXPAND | VM_DONTDUMP,
-				       NULL);
+
+	ret = install_special_mapping(mm, 0xffff0000, PAGE_SIZE,
+				      VM_READ | VM_EXEC |
+				      VM_MAYREAD | VM_MAYEXEC |
+				      VM_DONTEXPAND | VM_DONTDUMP,
+				      NULL, vma);
+	if (ret)
+		kmem_cache_free(vm_area_cachep, vma);
+	return ret;
 }
 
 const char *arch_vma_name(struct vm_area_struct *vma)
diff --git a/arch/x86/um/vdso/vma.c b/arch/x86/um/vdso/vma.c
index af91901..a380b13 100644
--- a/arch/x86/um/vdso/vma.c
+++ b/arch/x86/um/vdso/vma.c
@@ -55,19 +55,29 @@ subsys_initcall(init_vdso);
 int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 {
 	int err;
+	struct vm_area_struct *vma;
 	struct mm_struct *mm = current->mm;
 
 	if (!vdso_enabled)
 		return 0;
 
+	vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
+	if (unlikely(!vma))
+		return -ENOMEM;
+
 	down_write(&mm->mmap_sem);
 
 	err = install_special_mapping(mm, um_vdso_addr, PAGE_SIZE,
-		VM_READ|VM_EXEC|
-		VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC,
-		vdsop);
+				      VM_READ|VM_EXEC|
+				      VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC,
+				      vdsop, vma);
+	if (err)
+		goto out_err;
 
 	up_write(&mm->mmap_sem);
-
+	return err;
+out_err:
+	up_write(&mm->mmap_sem);
+	kmem_cache_free(vm_area_cachep, vma);
 	return err;
 }
diff --git a/arch/x86/vdso/vdso32-setup.c b/arch/x86/vdso/vdso32-setup.c
index d6bfb87..efa791a 100644
--- a/arch/x86/vdso/vdso32-setup.c
+++ b/arch/x86/vdso/vdso32-setup.c
@@ -13,6 +13,7 @@
 #include <linux/gfp.h>
 #include <linux/string.h>
 #include <linux/elf.h>
+#include <linux/slab.h>
 #include <linux/mm.h>
 #include <linux/err.h>
 #include <linux/module.h>
@@ -307,6 +308,7 @@ int __init sysenter_setup(void)
 int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 {
 	struct mm_struct *mm = current->mm;
+	struct vm_area_struct *vma;
 	unsigned long addr;
 	int ret = 0;
 	bool compat;
@@ -319,6 +321,12 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	if (vdso_enabled == VDSO_DISABLED)
 		return 0;
 
+	if (compat_uses_vma || !compat) {
+		vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
+		if (unlikely(!vma))
+			return -ENOMEM;
+	}
+
 	down_write(&mm->mmap_sem);
 
 	/* Test compat mode once here, in case someone
@@ -346,7 +354,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 		ret = install_special_mapping(mm, addr, PAGE_SIZE,
 					      VM_READ|VM_EXEC|
 					      VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC,
-					      vdso32_pages);
+					      vdso32_pages, vma);
 
 		if (ret)
 			goto up_fail;
@@ -355,12 +363,18 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 	current_thread_info()->sysenter_return =
 		VDSO32_SYMBOL(addr, SYSENTER_RETURN);
 
+	up_write(&mm->mmap_sem);
+
+	return ret;
+
   up_fail:
 	if (ret)
 		current->mm->context.vdso = NULL;
 
 	up_write(&mm->mmap_sem);
 
+	if (ret && (compat_uses_vma || !compat))
+		kmem_cache_free(vm_area_cachep, vma);
 	return ret;
 }
 
diff --git a/arch/x86/vdso/vma.c b/arch/x86/vdso/vma.c
index 431e875..fc189de 100644
--- a/arch/x86/vdso/vma.c
+++ b/arch/x86/vdso/vma.c
@@ -154,12 +154,17 @@ static int setup_additional_pages(struct linux_binprm *bprm,
 				  unsigned size)
 {
 	struct mm_struct *mm = current->mm;
+	struct vm_area_struct *vma;
 	unsigned long addr;
 	int ret;
 
 	if (!vdso_enabled)
 		return 0;
 
+	vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
+	if (unlikely(!vma))
+		return -ENOMEM;
+
 	down_write(&mm->mmap_sem);
 	addr = vdso_addr(mm->start_stack, size);
 	addr = get_unmapped_area(NULL, addr, size, 0, 0);
@@ -173,14 +178,17 @@ static int setup_additional_pages(struct linux_binprm *bprm,
 	ret = install_special_mapping(mm, addr, size,
 				      VM_READ|VM_EXEC|
 				      VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC,
-				      pages);
+				      pages, vma);
 	if (ret) {
 		current->mm->context.vdso = NULL;
 		goto up_fail;
 	}
 
+	up_write(&mm->mmap_sem);
+	return ret;
 up_fail:
 	up_write(&mm->mmap_sem);
+	kmem_cache_free(vm_area_cachep, vma);
 	return ret;
 }
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 8b6e55e..ade2bd1 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1515,7 +1515,8 @@ extern struct file *get_mm_exe_file(struct mm_struct *mm);
 extern int may_expand_vm(struct mm_struct *mm, unsigned long npages);
 extern int install_special_mapping(struct mm_struct *mm,
 				   unsigned long addr, unsigned long len,
-				   unsigned long flags, struct page **pages);
+				   unsigned long flags, struct page **pages,
+				   struct vm_area_struct *vma);
 
 extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
 
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index ad8e1bd..3a99f4b 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -1099,8 +1099,14 @@ void uprobe_munmap(struct vm_area_struct *vma, unsigned long start, unsigned lon
 static int xol_add_vma(struct xol_area *area)
 {
 	struct mm_struct *mm = current->mm;
+	struct vm_area_struct *vma;
+
 	int ret = -EALREADY;
 
+	vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
+	if (unlikely(!vma))
+		return -ENOMEM;
+
 	down_write(&mm->mmap_sem);
 	if (mm->uprobes_state.xol_area)
 		goto fail;
@@ -1114,16 +1120,20 @@ static int xol_add_vma(struct xol_area *area)
 	}
 
 	ret = install_special_mapping(mm, area->vaddr, PAGE_SIZE,
-				VM_EXEC|VM_MAYEXEC|VM_DONTCOPY|VM_IO, &area->page);
+				      VM_EXEC|VM_MAYEXEC|VM_DONTCOPY|VM_IO,
+				      &area->page, vma);
 	if (ret)
 		goto fail;
 
 	smp_wmb();	/* pairs with get_xol_area() */
 	mm->uprobes_state.xol_area = area;
 	ret = 0;
+
+	up_write(&mm->mmap_sem);
+	return 0;
  fail:
 	up_write(&mm->mmap_sem);
-
+	kmem_cache_free(vm_area_cachep, vma);
 	return ret;
 }
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 6a7824d..6a6ef0a 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2909,17 +2909,16 @@ static const struct vm_operations_struct special_mapping_vmops = {
  * The region past the last page supplied will always produce SIGBUS.
  * The array pointer and the pages it points to are assumed to stay alive
  * for as long as this mapping might exist.
+ *
+ * The caller has the responsibility of allocating the new vma, and freeing
+ * it if it was unused (when insert_vm_struct() fails).
  */
 int install_special_mapping(struct mm_struct *mm,
 			    unsigned long addr, unsigned long len,
-			    unsigned long vm_flags, struct page **pages)
+			    unsigned long vm_flags, struct page **pages,
+			    struct vm_area_struct *vma)
 {
-	int ret;
-	struct vm_area_struct *vma;
-
-	vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
-	if (unlikely(vma == NULL))
-		return -ENOMEM;
+	int ret = 0;
 
 	INIT_LIST_HEAD(&vma->anon_vma_chain);
 	vma->vm_mm = mm;
@@ -2939,11 +2938,7 @@ int install_special_mapping(struct mm_struct *mm,
 	mm->total_vm += len >> PAGE_SHIFT;
 
 	perf_event_mmap(vma);
-
-	return 0;
-
 out:
-	kmem_cache_free(vm_area_cachep, vma);
 	return ret;
 }
 
-- 
1.8.1.4



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
