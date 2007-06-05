Message-Id: <20070605151203.548530000@chello.nl>
References: <20070605150523.786600000@chello.nl>
Date: Tue, 05 Jun 2007 17:05:24 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 1/4] arch: personality independent stack top
Content-Disposition: inline; filename=stack_top_max.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
Cc: Ollie Wild <aaw@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@osdl.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

New arch macro STACK_TOP_MAX it gives the larges valid stack address for
the architecture in question.

It differs from STACK_TOP in that it will not distinguish between personalities
but will always return the largest possible address.

This is used to create the initial stack on execve, which we will move down
to the proper location once the binfmt code has figured out where that is.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Ollie Wild <aaw@google.com>
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
--- linux-2.6-2.orig/include/asm-alpha/a.out.h	2007-06-01 10:27:27.000000000 +0200
+++ linux-2.6-2/include/asm-alpha/a.out.h	2007-06-01 10:27:30.000000000 +0200
@@ -101,6 +101,8 @@ struct exec
 #define STACK_TOP \
   (current->personality & ADDR_LIMIT_32BIT ? 0x80000000 : 0x00120000000UL)
 
+#define STACK_TOP_MAX	0x00120000000UL
+
 #endif
 
 #endif /* __A_OUT_GNU_H__ */
Index: linux-2.6-2/include/asm-arm/a.out.h
===================================================================
--- linux-2.6-2.orig/include/asm-arm/a.out.h	2007-06-01 10:27:27.000000000 +0200
+++ linux-2.6-2/include/asm-arm/a.out.h	2007-06-01 10:27:30.000000000 +0200
@@ -30,6 +30,7 @@ struct exec
 #ifdef __KERNEL__
 #define STACK_TOP	((current->personality == PER_LINUX_32BIT) ? \
 			 TASK_SIZE : TASK_SIZE_26)
+#define STACK_TOP_MAX	TASK_SIZE
 #endif
 
 #ifndef LIBRARY_START_TEXT
Index: linux-2.6-2/include/asm-arm26/a.out.h
===================================================================
--- linux-2.6-2.orig/include/asm-arm26/a.out.h	2007-06-01 10:27:27.000000000 +0200
+++ linux-2.6-2/include/asm-arm26/a.out.h	2007-06-01 10:27:30.000000000 +0200
@@ -29,6 +29,7 @@ struct exec
 
 #ifdef __KERNEL__
 #define STACK_TOP	TASK_SIZE
+#define STACK_TOP_MAX	STACK_TOP
 #endif
 
 #ifndef LIBRARY_START_TEXT
Index: linux-2.6-2/include/asm-avr32/a.out.h
===================================================================
--- linux-2.6-2.orig/include/asm-avr32/a.out.h	2007-06-01 10:27:27.000000000 +0200
+++ linux-2.6-2/include/asm-avr32/a.out.h	2007-06-01 10:27:30.000000000 +0200
@@ -20,6 +20,7 @@ struct exec
 #ifdef __KERNEL__
 
 #define STACK_TOP	TASK_SIZE
+#define STACK_TOP_MAX	STACK_TOP
 
 #endif
 
Index: linux-2.6-2/include/asm-cris/a.out.h
===================================================================
--- linux-2.6-2.orig/include/asm-cris/a.out.h	2007-06-01 10:27:27.000000000 +0200
+++ linux-2.6-2/include/asm-cris/a.out.h	2007-06-01 10:27:30.000000000 +0200
@@ -8,6 +8,7 @@
 
 /* grabbed from the intel stuff  */   
 #define STACK_TOP TASK_SIZE
+#define STACK_TOP_MAX	STACK_TOP
 
 
 struct exec
Index: linux-2.6-2/include/asm-frv/mem-layout.h
===================================================================
--- linux-2.6-2.orig/include/asm-frv/mem-layout.h	2007-06-01 10:27:27.000000000 +0200
+++ linux-2.6-2/include/asm-frv/mem-layout.h	2007-06-01 10:27:30.000000000 +0200
@@ -60,6 +60,7 @@
  */
 #define BRK_BASE			__UL(2 * 1024 * 1024 + PAGE_SIZE)
 #define STACK_TOP			__UL(2 * 1024 * 1024)
+#define STACK_TOP_MAX	STACK_TOP
 
 /* userspace process size */
 #ifdef CONFIG_MMU
Index: linux-2.6-2/include/asm-h8300/a.out.h
===================================================================
--- linux-2.6-2.orig/include/asm-h8300/a.out.h	2007-06-01 10:27:27.000000000 +0200
+++ linux-2.6-2/include/asm-h8300/a.out.h	2007-06-01 10:27:30.000000000 +0200
@@ -20,6 +20,7 @@ struct exec
 #ifdef __KERNEL__
 
 #define STACK_TOP	TASK_SIZE
+#define STACK_TOP_MAX	STACK_TOP
 
 #endif
 
Index: linux-2.6-2/include/asm-i386/a.out.h
===================================================================
--- linux-2.6-2.orig/include/asm-i386/a.out.h	2007-06-01 10:27:27.000000000 +0200
+++ linux-2.6-2/include/asm-i386/a.out.h	2007-06-01 10:27:30.000000000 +0200
@@ -20,6 +20,7 @@ struct exec
 #ifdef __KERNEL__
 
 #define STACK_TOP	TASK_SIZE
+#define STACK_TOP_MAX	STACK_TOP
 
 #endif
 
Index: linux-2.6-2/include/asm-ia64/ustack.h
===================================================================
--- linux-2.6-2.orig/include/asm-ia64/ustack.h	2007-06-01 10:27:27.000000000 +0200
+++ linux-2.6-2/include/asm-ia64/ustack.h	2007-06-01 10:27:30.000000000 +0200
@@ -11,6 +11,7 @@
 /* The absolute hard limit for stack size is 1/2 of the mappable space in the region */
 #define MAX_USER_STACK_SIZE	(RGN_MAP_LIMIT/2)
 #define STACK_TOP		(0x6000000000000000UL + RGN_MAP_LIMIT)
+#define STACK_TOP_MAX		STACK_TOP
 #endif
 
 /* Make a default stack size of 2GiB */
Index: linux-2.6-2/include/asm-m32r/a.out.h
===================================================================
--- linux-2.6-2.orig/include/asm-m32r/a.out.h	2007-06-01 10:27:27.000000000 +0200
+++ linux-2.6-2/include/asm-m32r/a.out.h	2007-06-01 10:27:30.000000000 +0200
@@ -20,6 +20,7 @@ struct exec
 #ifdef __KERNEL__
 
 #define STACK_TOP	TASK_SIZE
+#define STACK_TOP_MAX	STACK_TOP
 
 #endif
 
Index: linux-2.6-2/include/asm-m68k/a.out.h
===================================================================
--- linux-2.6-2.orig/include/asm-m68k/a.out.h	2007-06-01 10:27:27.000000000 +0200
+++ linux-2.6-2/include/asm-m68k/a.out.h	2007-06-01 10:27:30.000000000 +0200
@@ -20,6 +20,7 @@ struct exec
 #ifdef __KERNEL__
 
 #define STACK_TOP	TASK_SIZE
+#define STACK_TOP_MAX	STACK_TOP
 
 #endif
 
Index: linux-2.6-2/include/asm-mips/a.out.h
===================================================================
--- linux-2.6-2.orig/include/asm-mips/a.out.h	2007-06-01 10:27:27.000000000 +0200
+++ linux-2.6-2/include/asm-mips/a.out.h	2007-06-01 10:27:30.000000000 +0200
@@ -40,6 +40,7 @@ struct exec
 #ifdef CONFIG_64BIT
 #define STACK_TOP	(current->thread.mflags & MF_32BIT_ADDR ? TASK_SIZE32 : TASK_SIZE)
 #endif
+#define STACK_TOP_MAX	TASK_SIZE
 
 #endif
 
Index: linux-2.6-2/include/asm-parisc/a.out.h
===================================================================
--- linux-2.6-2.orig/include/asm-parisc/a.out.h	2007-06-01 10:27:27.000000000 +0200
+++ linux-2.6-2/include/asm-parisc/a.out.h	2007-06-01 10:27:30.000000000 +0200
@@ -23,6 +23,7 @@ struct exec
  * prumpf */
 
 #define STACK_TOP	TASK_SIZE
+#define STACK_TOP_MAX	DEFAULT_TASK_SIZE
 
 #endif
 
Index: linux-2.6-2/include/asm-powerpc/a.out.h
===================================================================
--- linux-2.6-2.orig/include/asm-powerpc/a.out.h	2007-06-01 10:27:27.000000000 +0200
+++ linux-2.6-2/include/asm-powerpc/a.out.h	2007-06-01 10:27:30.000000000 +0200
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
--- linux-2.6-2.orig/include/asm-s390/a.out.h	2007-06-01 10:27:27.000000000 +0200
+++ linux-2.6-2/include/asm-s390/a.out.h	2007-06-01 10:27:30.000000000 +0200
@@ -32,6 +32,7 @@ struct exec
 #ifdef __KERNEL__
 
 #define STACK_TOP	TASK_SIZE
+#define STACK_TOP_MAX	DEFAULT_TASK_SIZE
 
 #endif
 
Index: linux-2.6-2/include/asm-sh/a.out.h
===================================================================
--- linux-2.6-2.orig/include/asm-sh/a.out.h	2007-06-01 10:27:27.000000000 +0200
+++ linux-2.6-2/include/asm-sh/a.out.h	2007-06-01 10:27:30.000000000 +0200
@@ -20,6 +20,7 @@ struct exec
 #ifdef __KERNEL__
 
 #define STACK_TOP	TASK_SIZE
+#define STACK_TOP_MAX	STACK_TOP
 
 #endif
 
Index: linux-2.6-2/include/asm-sh64/a.out.h
===================================================================
--- linux-2.6-2.orig/include/asm-sh64/a.out.h	2007-06-01 10:27:27.000000000 +0200
+++ linux-2.6-2/include/asm-sh64/a.out.h	2007-06-01 10:27:30.000000000 +0200
@@ -31,6 +31,7 @@ struct exec
 #ifdef __KERNEL__
 
 #define STACK_TOP	TASK_SIZE
+#define STACK_TOP_MAX	STACK_TOP
 
 #endif
 
Index: linux-2.6-2/include/asm-sparc/a.out.h
===================================================================
--- linux-2.6-2.orig/include/asm-sparc/a.out.h	2007-06-01 10:27:27.000000000 +0200
+++ linux-2.6-2/include/asm-sparc/a.out.h	2007-06-01 10:27:30.000000000 +0200
@@ -92,6 +92,7 @@ struct relocation_info /* used when head
 #include <asm/page.h>
 
 #define STACK_TOP	(PAGE_OFFSET - PAGE_SIZE)
+#define STACK_TOP_MAX	STACK_TOP
 
 #endif /* __KERNEL__ */
 
Index: linux-2.6-2/include/asm-sparc64/a.out.h
===================================================================
--- linux-2.6-2.orig/include/asm-sparc64/a.out.h	2007-06-01 10:27:27.000000000 +0200
+++ linux-2.6-2/include/asm-sparc64/a.out.h	2007-06-01 10:27:30.000000000 +0200
@@ -101,6 +101,8 @@ struct relocation_info /* used when head
 #define STACK_TOP (test_thread_flag(TIF_32BIT) ? \
 		   STACK_TOP32 : STACK_TOP64)
 
+#define STACK_TOP_MAX STACK_TOP64
+
 #endif
 
 #endif /* !(__ASSEMBLY__) */
Index: linux-2.6-2/include/asm-um/a.out.h
===================================================================
--- linux-2.6-2.orig/include/asm-um/a.out.h	2007-06-01 10:27:27.000000000 +0200
+++ linux-2.6-2/include/asm-um/a.out.h	2007-06-01 10:27:30.000000000 +0200
@@ -16,4 +16,6 @@ extern int honeypot;
 #define STACK_TOP \
 	CHOOSE_MODE((honeypot ? host_task_size : task_size), task_size)
 
+#define STACK_TOP_MAX	STACK_TOP
+
 #endif
Index: linux-2.6-2/include/asm-x86_64/a.out.h
===================================================================
--- linux-2.6-2.orig/include/asm-x86_64/a.out.h	2007-06-01 10:27:27.000000000 +0200
+++ linux-2.6-2/include/asm-x86_64/a.out.h	2007-06-01 10:27:30.000000000 +0200
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
--- linux-2.6-2.orig/include/asm-xtensa/a.out.h	2007-06-01 10:27:27.000000000 +0200
+++ linux-2.6-2/include/asm-xtensa/a.out.h	2007-06-01 10:27:30.000000000 +0200
@@ -17,6 +17,7 @@
 /* Note: the kernel needs the a.out definitions, even if only ELF is used. */
 
 #define STACK_TOP	TASK_SIZE
+#define STACK_TOP_MAX	STACK_TOP
 
 struct exec
 {

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
