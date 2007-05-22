Subject: RE: [patch] removes MAX_ARG_PAGES
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <617E1C2C70743745A92448908E030B2A01719390@scsmsx411.amr.corp.intel.com>
References: <617E1C2C70743745A92448908E030B2A01719390@scsmsx411.amr.corp.intel.com>
Content-Type: multipart/mixed; boundary="=-AD3gMpMUuQSfYMFUfxVH"
Date: Tue, 22 May 2007 14:24:05 +0200
Message-Id: <1179836645.7019.86.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Ollie Wild <aaw@google.com>, linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

--=-AD3gMpMUuQSfYMFUfxVH
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Mon, 2007-05-07 at 10:46 -0700, Luck, Tony wrote:
> > We've tested the following architectures: i386, x86_64, um/i386,
> > parisc, and frv.  These are representative of the various scenarios
> > which this patch addresses, but other architecture teams should try it
> > out to make sure there aren't any unexpected gotchas.
> 
> Doesn't build on ia64: complaints from arch/ia64/ia32/binfmt_elf.c
> (which #includes ../../../fs/binfmt_elf.c) ...
> 
> arch/ia64/ia32/binfmt_elf32.c: In function `ia32_setup_arg_pages':
> arch/ia64/ia32/binfmt_elf32.c:206: error: `MAX_ARG_PAGES' undeclared (first use in this function)
> arch/ia64/ia32/binfmt_elf32.c:206: error: (Each undeclared identifier is reported only once
> arch/ia64/ia32/binfmt_elf32.c:206: error: for each function it appears in.)
> arch/ia64/ia32/binfmt_elf32.c:240: error: structure has no member named `page'
> arch/ia64/ia32/binfmt_elf32.c:242: error: structure has no member named `page'
> arch/ia64/ia32/binfmt_elf32.c:243: warning: implicit declaration of function `install_arg_page'
> make[1]: *** [arch/ia64/ia32/binfmt_elf32.o] Error 1
> 
> Turning off CONFIG_IA32-SUPPORT, the kernel built, but oops'd during boot.
> My serial connection to my test machine is currently broken, so I didn't
> get a capture of the stack trace, sorry.


Ok, I found the problem. IA64 places constraints on virtual address
space. We initially place the stack at TASK_SIZE, and once the binfmt
tells us where it should have gone, we move it down to the new location.

However IA64 has v-space carved up in regions, and the top of the user
accessible address space is reserved for hugetlbfs.

So we should be using STACK_TOP, which provides the highest stack
address, however, some arches have conditions in the STACK_TOP macros
such that the result is not what is expected until the binfmt
personality is set.

In order to solve this, I added a STACK_TOP_MAX macro for each arch and
use that. This made IA64 boot properly.

The second patch makes the compat stuff compile, untested though, as I
have no idea how that works on ia64.



--=-AD3gMpMUuQSfYMFUfxVH
Content-Disposition: attachment; filename=stack_top_max.patch
Content-Type: text/x-patch; name=stack_top_max.patch; charset=utf-8
Content-Transfer-Encoding: 7bit


New arch macro STACK_TOP_MAX it gives the larges valid stack address for
the architecture in question.

It differs from STACK_TOP in that it will not distinguish between personalities
but will always return the largest possible address.

This is used to create the initial stack on execve, which we will move down
to the proper location once the binfmt code has figured out where that is.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 fs/exec.c                    |    2 +-
 include/asm-alpha/a.out.h    |    2 ++
 include/asm-arm/a.out.h      |    1 +
 include/asm-arm26/a.out.h    |    1 +
 include/asm-avr32/a.out.h    |    1 +
 include/asm-cris/a.out.h     |    1 +
 include/asm-frv/mem-layout.h |    1 +
 include/asm-h8300/a.out.h    |    1 +
 include/asm-i386/a.out.h     |    1 +
 include/asm-ia64/ustack.h    |    1 +
 include/asm-m32r/a.out.h     |    1 +
 include/asm-m68k/a.out.h     |    1 +
 include/asm-mips/a.out.h     |    1 +
 include/asm-parisc/a.out.h   |    1 +
 include/asm-powerpc/a.out.h  |    3 +++
 include/asm-s390/a.out.h     |    1 +
 include/asm-sh/a.out.h       |    1 +
 include/asm-sh64/a.out.h     |    1 +
 include/asm-sparc/a.out.h    |    1 +
 include/asm-sparc64/a.out.h  |    2 ++
 include/asm-um/a.out.h       |    2 ++
 include/asm-x86_64/a.out.h   |    3 ++-
 include/asm-xtensa/a.out.h   |    1 +
 23 files changed, 29 insertions(+), 2 deletions(-)

Index: linux-2.6-2/include/asm-alpha/a.out.h
===================================================================
--- linux-2.6-2.orig/include/asm-alpha/a.out.h	2007-05-22 12:31:13.000000000 +0200
+++ linux-2.6-2/include/asm-alpha/a.out.h	2007-05-22 12:39:27.000000000 +0200
@@ -101,6 +101,8 @@ struct exec
 #define STACK_TOP \
   (current->personality & ADDR_LIMIT_32BIT ? 0x80000000 : 0x00120000000UL)
 
+#define STACK_TOP_MAX	0x00120000000UL
+
 #endif
 
 #endif /* __A_OUT_GNU_H__ */
Index: linux-2.6-2/include/asm-arm/a.out.h
===================================================================
--- linux-2.6-2.orig/include/asm-arm/a.out.h	2007-05-22 12:31:13.000000000 +0200
+++ linux-2.6-2/include/asm-arm/a.out.h	2007-05-22 12:39:27.000000000 +0200
@@ -30,6 +30,7 @@ struct exec
 #ifdef __KERNEL__
 #define STACK_TOP	((current->personality == PER_LINUX_32BIT) ? \
 			 TASK_SIZE : TASK_SIZE_26)
+#define STACK_TOP_MAX	TASK_SIZE
 #endif
 
 #ifndef LIBRARY_START_TEXT
Index: linux-2.6-2/include/asm-arm26/a.out.h
===================================================================
--- linux-2.6-2.orig/include/asm-arm26/a.out.h	2007-05-22 12:31:13.000000000 +0200
+++ linux-2.6-2/include/asm-arm26/a.out.h	2007-05-22 12:39:27.000000000 +0200
@@ -29,6 +29,7 @@ struct exec
 
 #ifdef __KERNEL__
 #define STACK_TOP	TASK_SIZE
+#define STACK_TOP_MAX	STACK_TOP
 #endif
 
 #ifndef LIBRARY_START_TEXT
Index: linux-2.6-2/include/asm-avr32/a.out.h
===================================================================
--- linux-2.6-2.orig/include/asm-avr32/a.out.h	2007-05-22 12:31:13.000000000 +0200
+++ linux-2.6-2/include/asm-avr32/a.out.h	2007-05-22 12:39:27.000000000 +0200
@@ -20,6 +20,7 @@ struct exec
 #ifdef __KERNEL__
 
 #define STACK_TOP	TASK_SIZE
+#define STACK_TOP_MAX	STACK_TOP
 
 #endif
 
Index: linux-2.6-2/include/asm-cris/a.out.h
===================================================================
--- linux-2.6-2.orig/include/asm-cris/a.out.h	2007-05-22 12:31:13.000000000 +0200
+++ linux-2.6-2/include/asm-cris/a.out.h	2007-05-22 12:39:27.000000000 +0200
@@ -8,6 +8,7 @@
 
 /* grabbed from the intel stuff  */   
 #define STACK_TOP TASK_SIZE
+#define STACK_TOP_MAX	STACK_TOP
 
 
 struct exec
Index: linux-2.6-2/include/asm-frv/mem-layout.h
===================================================================
--- linux-2.6-2.orig/include/asm-frv/mem-layout.h	2007-05-22 12:31:13.000000000 +0200
+++ linux-2.6-2/include/asm-frv/mem-layout.h	2007-05-22 12:39:27.000000000 +0200
@@ -60,6 +60,7 @@
  */
 #define BRK_BASE			__UL(2 * 1024 * 1024 + PAGE_SIZE)
 #define STACK_TOP			__UL(2 * 1024 * 1024)
+#define STACK_TOP_MAX	STACK_TOP
 
 /* userspace process size */
 #ifdef CONFIG_MMU
Index: linux-2.6-2/include/asm-h8300/a.out.h
===================================================================
--- linux-2.6-2.orig/include/asm-h8300/a.out.h	2007-05-22 12:31:13.000000000 +0200
+++ linux-2.6-2/include/asm-h8300/a.out.h	2007-05-22 12:39:27.000000000 +0200
@@ -20,6 +20,7 @@ struct exec
 #ifdef __KERNEL__
 
 #define STACK_TOP	TASK_SIZE
+#define STACK_TOP_MAX	STACK_TOP
 
 #endif
 
Index: linux-2.6-2/include/asm-i386/a.out.h
===================================================================
--- linux-2.6-2.orig/include/asm-i386/a.out.h	2007-05-22 12:31:13.000000000 +0200
+++ linux-2.6-2/include/asm-i386/a.out.h	2007-05-22 12:39:27.000000000 +0200
@@ -20,6 +20,7 @@ struct exec
 #ifdef __KERNEL__
 
 #define STACK_TOP	TASK_SIZE
+#define STACK_TOP_MAX	STACK_TOP
 
 #endif
 
Index: linux-2.6-2/include/asm-ia64/ustack.h
===================================================================
--- linux-2.6-2.orig/include/asm-ia64/ustack.h	2007-05-22 12:31:15.000000000 +0200
+++ linux-2.6-2/include/asm-ia64/ustack.h	2007-05-22 12:39:45.000000000 +0200
@@ -11,6 +11,7 @@
 /* The absolute hard limit for stack size is 1/2 of the mappable space in the region */
 #define MAX_USER_STACK_SIZE	(RGN_MAP_LIMIT/2)
 #define STACK_TOP		(0x6000000000000000UL + RGN_MAP_LIMIT)
+#define STACK_TOP_MAX		STACK_TOP
 #endif
 
 /* Make a default stack size of 2GiB */
Index: linux-2.6-2/include/asm-m32r/a.out.h
===================================================================
--- linux-2.6-2.orig/include/asm-m32r/a.out.h	2007-05-22 12:31:13.000000000 +0200
+++ linux-2.6-2/include/asm-m32r/a.out.h	2007-05-22 12:39:27.000000000 +0200
@@ -20,6 +20,7 @@ struct exec
 #ifdef __KERNEL__
 
 #define STACK_TOP	TASK_SIZE
+#define STACK_TOP_MAX	STACK_TOP
 
 #endif
 
Index: linux-2.6-2/include/asm-m68k/a.out.h
===================================================================
--- linux-2.6-2.orig/include/asm-m68k/a.out.h	2007-05-22 12:31:13.000000000 +0200
+++ linux-2.6-2/include/asm-m68k/a.out.h	2007-05-22 12:39:27.000000000 +0200
@@ -20,6 +20,7 @@ struct exec
 #ifdef __KERNEL__
 
 #define STACK_TOP	TASK_SIZE
+#define STACK_TOP_MAX	STACK_TOP
 
 #endif
 
Index: linux-2.6-2/include/asm-mips/a.out.h
===================================================================
--- linux-2.6-2.orig/include/asm-mips/a.out.h	2007-05-22 12:31:13.000000000 +0200
+++ linux-2.6-2/include/asm-mips/a.out.h	2007-05-22 12:39:27.000000000 +0200
@@ -40,6 +40,7 @@ struct exec
 #ifdef CONFIG_64BIT
 #define STACK_TOP	(current->thread.mflags & MF_32BIT_ADDR ? TASK_SIZE32 : TASK_SIZE)
 #endif
+#define STACK_TOP_MAX	TASK_SIZE
 
 #endif
 
Index: linux-2.6-2/include/asm-parisc/a.out.h
===================================================================
--- linux-2.6-2.orig/include/asm-parisc/a.out.h	2007-05-22 12:31:13.000000000 +0200
+++ linux-2.6-2/include/asm-parisc/a.out.h	2007-05-22 13:13:07.000000000 +0200
@@ -23,6 +23,7 @@ struct exec
  * prumpf */
 
 #define STACK_TOP	TASK_SIZE
+#define STACK_TOP_MAX	DEFAULT_TASK_SIZE
 
 #endif
 
Index: linux-2.6-2/include/asm-powerpc/a.out.h
===================================================================
--- linux-2.6-2.orig/include/asm-powerpc/a.out.h	2007-05-22 12:31:13.000000000 +0200
+++ linux-2.6-2/include/asm-powerpc/a.out.h	2007-05-22 12:39:27.000000000 +0200
@@ -26,9 +26,12 @@ struct exec
 #define STACK_TOP (test_thread_flag(TIF_32BIT) ? \
 		   STACK_TOP_USER32 : STACK_TOP_USER64)
 
+#define STACK_TOP_MAX STACK_TOP_USER64
+
 #else /* __powerpc64__ */
 
 #define STACK_TOP TASK_SIZE
+#define STACK_TOP_MAX	STACK_TOP
 
 #endif /* __powerpc64__ */
 #endif /* __KERNEL__ */
Index: linux-2.6-2/include/asm-s390/a.out.h
===================================================================
--- linux-2.6-2.orig/include/asm-s390/a.out.h	2007-05-22 12:31:13.000000000 +0200
+++ linux-2.6-2/include/asm-s390/a.out.h	2007-05-22 13:15:00.000000000 +0200
@@ -32,6 +32,7 @@ struct exec
 #ifdef __KERNEL__
 
 #define STACK_TOP	TASK_SIZE
+#define STACK_TOP_MAX	DEFAULT_TASK_SIZE
 
 #endif
 
Index: linux-2.6-2/include/asm-sh/a.out.h
===================================================================
--- linux-2.6-2.orig/include/asm-sh/a.out.h	2007-05-22 12:31:13.000000000 +0200
+++ linux-2.6-2/include/asm-sh/a.out.h	2007-05-22 12:39:27.000000000 +0200
@@ -20,6 +20,7 @@ struct exec
 #ifdef __KERNEL__
 
 #define STACK_TOP	TASK_SIZE
+#define STACK_TOP_MAX	STACK_TOP
 
 #endif
 
Index: linux-2.6-2/include/asm-sh64/a.out.h
===================================================================
--- linux-2.6-2.orig/include/asm-sh64/a.out.h	2007-05-22 12:31:13.000000000 +0200
+++ linux-2.6-2/include/asm-sh64/a.out.h	2007-05-22 12:39:27.000000000 +0200
@@ -31,6 +31,7 @@ struct exec
 #ifdef __KERNEL__
 
 #define STACK_TOP	TASK_SIZE
+#define STACK_TOP_MAX	STACK_TOP
 
 #endif
 
Index: linux-2.6-2/include/asm-sparc/a.out.h
===================================================================
--- linux-2.6-2.orig/include/asm-sparc/a.out.h	2007-05-22 12:31:13.000000000 +0200
+++ linux-2.6-2/include/asm-sparc/a.out.h	2007-05-22 12:39:27.000000000 +0200
@@ -92,6 +92,7 @@ struct relocation_info /* used when head
 #include <asm/page.h>
 
 #define STACK_TOP	(PAGE_OFFSET - PAGE_SIZE)
+#define STACK_TOP_MAX	STACK_TOP
 
 #endif /* __KERNEL__ */
 
Index: linux-2.6-2/include/asm-sparc64/a.out.h
===================================================================
--- linux-2.6-2.orig/include/asm-sparc64/a.out.h	2007-05-22 12:31:13.000000000 +0200
+++ linux-2.6-2/include/asm-sparc64/a.out.h	2007-05-22 12:39:27.000000000 +0200
@@ -101,6 +101,8 @@ struct relocation_info /* used when head
 #define STACK_TOP (test_thread_flag(TIF_32BIT) ? \
 		   STACK_TOP32 : STACK_TOP64)
 
+#define STACK_TOP_MAX STACK_TOP64
+
 #endif
 
 #endif /* !(__ASSEMBLY__) */
Index: linux-2.6-2/include/asm-um/a.out.h
===================================================================
--- linux-2.6-2.orig/include/asm-um/a.out.h	2007-05-22 12:31:13.000000000 +0200
+++ linux-2.6-2/include/asm-um/a.out.h	2007-05-22 12:39:27.000000000 +0200
@@ -16,4 +16,6 @@ extern int honeypot;
 #define STACK_TOP \
 	CHOOSE_MODE((honeypot ? host_task_size : task_size), task_size)
 
+#define STACK_TOP_MAX	STACK_TOP
+
 #endif
Index: linux-2.6-2/include/asm-x86_64/a.out.h
===================================================================
--- linux-2.6-2.orig/include/asm-x86_64/a.out.h	2007-05-22 12:31:13.000000000 +0200
+++ linux-2.6-2/include/asm-x86_64/a.out.h	2007-05-22 12:54:41.000000000 +0200
@@ -21,7 +21,8 @@ struct exec
 
 #ifdef __KERNEL__
 #include <linux/thread_info.h>
-#define STACK_TOP TASK_SIZE
+#define STACK_TOP	TASK_SIZE
+#define STACK_TOP_MAX	TASK_SIZE64
 #endif
 
 #endif /* __A_OUT_GNU_H__ */
Index: linux-2.6-2/include/asm-xtensa/a.out.h
===================================================================
--- linux-2.6-2.orig/include/asm-xtensa/a.out.h	2007-05-22 12:31:13.000000000 +0200
+++ linux-2.6-2/include/asm-xtensa/a.out.h	2007-05-22 12:39:27.000000000 +0200
@@ -17,6 +17,7 @@
 /* Note: the kernel needs the a.out definitions, even if only ELF is used. */
 
 #define STACK_TOP	TASK_SIZE
+#define STACK_TOP_MAX	STACK_TOP
 
 struct exec
 {
Index: linux-2.6-2/fs/exec.c
===================================================================
--- linux-2.6-2.orig/fs/exec.c	2007-05-22 12:39:22.000000000 +0200
+++ linux-2.6-2/fs/exec.c	2007-05-22 13:10:45.000000000 +0200
@@ -282,7 +282,7 @@ int bprm_mm_init(struct linux_binprm *bp
 		 * move this to an appropriate place.  We don't use STACK_TOP
 		 * because that can depend on attributes which aren't
 		 * configured yet. */
-		vma->vm_end = TASK_SIZE;
+		vma->vm_end = STACK_TOP_MAX;
 		vma->vm_start = vma->vm_end - PAGE_SIZE;
 
 		vma->vm_flags = VM_STACK_FLAGS;

--=-AD3gMpMUuQSfYMFUfxVH
Content-Disposition: attachment; filename=setup_arg_pages.patch
Content-Type: text/x-patch; name=setup_arg_pages.patch; charset=utf-8
Content-Transfer-Encoding: 7bit


Convert the ia64/ia32 compat binfmt code to the new way of doing things.
Clean up the x86_64/ia32 code.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/ia64/ia32/binfmt_elf32.c  |   59 ++++++-----------------------------------
 arch/x86_64/ia32/ia32_aout.c   |    2 -
 arch/x86_64/ia32/ia32_binfmt.c |    7 ----
 fs/exec.c                      |    3 --
 4 files changed, 11 insertions(+), 60 deletions(-)

Index: linux-2.6-2/arch/x86_64/ia32/ia32_binfmt.c
===================================================================
--- linux-2.6-2.orig/arch/x86_64/ia32/ia32_binfmt.c	2007-05-22 13:10:45.000000000 +0200
+++ linux-2.6-2/arch/x86_64/ia32/ia32_binfmt.c	2007-05-22 13:16:14.000000000 +0200
@@ -281,13 +281,6 @@ static void elf32_init(struct pt_regs *r
 	me->thread.es = __USER_DS;
 }
 
-int ia32_setup_arg_pages(struct linux_binprm *bprm, unsigned long stack_top,
-			 int executable_stack)
-{
-	return setup_arg_pages(bprm, stack_top, executable_stack);
-}
-EXPORT_SYMBOL(ia32_setup_arg_pages);
-
 #ifdef CONFIG_SYSCTL
 /* Register vsyscall32 into the ABI table */
 #include <linux/sysctl.h>
Index: linux-2.6-2/arch/ia64/ia32/binfmt_elf32.c
===================================================================
--- linux-2.6-2.orig/arch/ia64/ia32/binfmt_elf32.c	2007-05-22 13:10:45.000000000 +0200
+++ linux-2.6-2/arch/ia64/ia32/binfmt_elf32.c	2007-05-22 13:16:14.000000000 +0200
@@ -198,59 +198,18 @@ ia64_elf32_init (struct pt_regs *regs)
 int
 ia32_setup_arg_pages (struct linux_binprm *bprm, int executable_stack)
 {
-	unsigned long stack_base;
-	struct vm_area_struct *mpnt;
-	struct mm_struct *mm = current->mm;
-	int i, ret;
-
-	stack_base = IA32_STACK_TOP - MAX_ARG_PAGES*PAGE_SIZE;
-	mm->arg_start = bprm->p + stack_base;
-
-	bprm->p += stack_base;
-	if (bprm->loader)
-		bprm->loader += stack_base;
-	bprm->exec += stack_base;
-
-	mpnt = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
-	if (!mpnt)
-		return -ENOMEM;
-
-	down_write(&current->mm->mmap_sem);
-	{
-		mpnt->vm_mm = current->mm;
-		mpnt->vm_start = PAGE_MASK & (unsigned long) bprm->p;
-		mpnt->vm_end = IA32_STACK_TOP;
-		if (executable_stack == EXSTACK_ENABLE_X)
-			mpnt->vm_flags = VM_STACK_FLAGS |  VM_EXEC;
-		else if (executable_stack == EXSTACK_DISABLE_X)
-			mpnt->vm_flags = VM_STACK_FLAGS & ~VM_EXEC;
-		else
-			mpnt->vm_flags = VM_STACK_FLAGS;
-		mpnt->vm_page_prot = (mpnt->vm_flags & VM_EXEC)?
-					PAGE_COPY_EXEC: PAGE_COPY;
-		if ((ret = insert_vm_struct(current->mm, mpnt))) {
-			up_write(&current->mm->mmap_sem);
-			kmem_cache_free(vm_area_cachep, mpnt);
-			return ret;
-		}
-		current->mm->stack_vm = current->mm->total_vm = vma_pages(mpnt);
-	}
+	int ret;
 
-	for (i = 0 ; i < MAX_ARG_PAGES ; i++) {
-		struct page *page = bprm->page[i];
-		if (page) {
-			bprm->page[i] = NULL;
-			install_arg_page(mpnt, page, stack_base);
-		}
-		stack_base += PAGE_SIZE;
+	ret = setup_arg_pages(bprm, IA32_STACK_TOP, executable_stack);
+	if (!ret) {
+		/*
+		 * Can't do it in ia64_elf32_init(). Needs to be done before
+		 * calls to elf32_map()
+		 */
+		current->thread.ppl = ia32_init_pp_list();
 	}
-	up_write(&current->mm->mmap_sem);
-
-	/* Can't do it in ia64_elf32_init(). Needs to be done before calls to
-	   elf32_map() */
-	current->thread.ppl = ia32_init_pp_list();
 
-	return 0;
+	return ret;
 }
 
 static void
Index: linux-2.6-2/fs/exec.c
===================================================================
--- linux-2.6-2.orig/fs/exec.c	2007-05-22 13:10:45.000000000 +0200
+++ linux-2.6-2/fs/exec.c	2007-05-22 13:16:14.000000000 +0200
@@ -535,14 +535,13 @@ int setup_arg_pages(struct linux_binprm 
 	stack_base = PAGE_ALIGN(stack_top - stack_base);
 
 	/* Make sure we didn't let the argument array grow too large. */
-	if (vma->vm_end - vma->vm_start > STACK_TOP - stack_base)
+	if (vma->vm_end - vma->vm_start > stack_base)
 		return -ENOMEM;
 
 	stack_shift = stack_base - vma->vm_start;
 	mm->arg_start = bprm->p + stack_shift;
 	bprm->p = vma->vm_end + stack_shift;
 #else
-	BUG_ON(stack_top > STACK_TOP);
 	BUG_ON(stack_top & ~PAGE_MASK);
 
 	stack_base = arch_align_stack(stack_top - mm->stack_vm*PAGE_SIZE);
Index: linux-2.6-2/arch/x86_64/ia32/ia32_aout.c
===================================================================
--- linux-2.6-2.orig/arch/x86_64/ia32/ia32_aout.c	2007-04-24 17:43:39.000000000 +0200
+++ linux-2.6-2/arch/x86_64/ia32/ia32_aout.c	2007-05-22 13:41:11.000000000 +0200
@@ -404,7 +404,7 @@ beyond_if:
 
 	set_brk(current->mm->start_brk, current->mm->brk);
 
-	retval = ia32_setup_arg_pages(bprm, IA32_STACK_TOP, EXSTACK_DEFAULT);
+	retval = setup_arg_pages(bprm, IA32_STACK_TOP, EXSTACK_DEFAULT);
 	if (retval < 0) { 
 		/* Someone check-me: is this error path enough? */ 
 		send_sig(SIGKILL, current, 0); 

--=-AD3gMpMUuQSfYMFUfxVH--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
