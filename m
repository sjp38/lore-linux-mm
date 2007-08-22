Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7MNIBIj029779
	for <linux-mm@kvack.org>; Wed, 22 Aug 2007 19:18:11 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7MNIBo6411154
	for <linux-mm@kvack.org>; Wed, 22 Aug 2007 19:18:11 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7MNIBTA030262
	for <linux-mm@kvack.org>; Wed, 22 Aug 2007 19:18:11 -0400
Subject: [PATCH 5/9] introduce TASK_SIZE_OF() for all arches
From: Dave Hansen <haveblue@us.ibm.com>
Date: Wed, 22 Aug 2007 16:18:09 -0700
References: <20070822231804.1132556D@kernel>
In-Reply-To: <20070822231804.1132556D@kernel>
Message-Id: <20070822231809.26DCC223@kernel>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mpm@selenic.com
Cc: linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

(already sent to linux-arch, just repeating here in case someone
 wants to test these in their entirety)

For the /proc/<pid>/pagemap code[1], we need to able to query how
much virtual address space a particular task has.  The trick is
that we do it through /proc and can't use TASK_SIZE since it
references "current" on some arches.  The process opening the
/proc file might be a 32-bit process opening a 64-bit process's
pagemap file.

x86_64 already has a TASK_SIZE_OF() macro:

#define TASK_SIZE_OF(child)     ((test_tsk_thread_flag(child, TIF_IA32)) ? IA32_PAGE_OFFSET : TASK_SIZE64)

I'd like to have that for other architectures.  So, add it
for all the architectures that actually use "current" in 
their TASK_SIZE.  For the others, just add a quick #define
in sched.h to use plain old TASK_SIZE.

1. http://www.linuxworld.com/news/2007/042407-kernel.html

- MIPS portion from Ralf Baechle <ralf@linux-mips.org>

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
---

 lxc-dave/include/asm-ia64/processor.h    |    3 ++-
 lxc-dave/include/asm-mips/processor.h    |    4 ++++
 lxc-dave/include/asm-parisc/processor.h  |    3 ++-
 lxc-dave/include/asm-powerpc/processor.h |    4 +++-
 lxc-dave/include/asm-s390/processor.h    |    2 ++
 lxc-dave/include/linux/sched.h           |    4 ++++
 6 files changed, 17 insertions(+), 3 deletions(-)

diff -puN include/asm-ia64/processor.h~task_size_of include/asm-ia64/processor.h
--- lxc/include/asm-ia64/processor.h~task_size_of	2007-08-22 16:16:52.000000000 -0700
+++ lxc-dave/include/asm-ia64/processor.h	2007-08-22 16:16:52.000000000 -0700
@@ -31,7 +31,8 @@
  * each (assuming 8KB page size), for a total of 8TB of user virtual
  * address space.
  */
-#define TASK_SIZE		(current->thread.task_size)
+#define TASK_SIZE_OF(tsk)	((tsk)->thread.task_size)
+#define TASK_SIZE       	TASK_SIZE_OF(current)
 
 /*
  * This decides where the kernel will search for a free chunk of vm
diff -puN include/asm-mips/processor.h~task_size_of include/asm-mips/processor.h
--- lxc/include/asm-mips/processor.h~task_size_of	2007-08-22 16:16:52.000000000 -0700
+++ lxc-dave/include/asm-mips/processor.h	2007-08-22 16:16:53.000000000 -0700
@@ -45,6 +45,8 @@ extern unsigned int vced_count, vcei_cou
  * space during mmap's.
  */
 #define TASK_UNMAPPED_BASE	(PAGE_ALIGN(TASK_SIZE / 3))
+#define TASK_SIZE_OF(tsk)						\
+	(test_thread_flag(TIF_32BIT_ADDR) ? TASK_SIZE32 : TASK_SIZE)
 #endif
 
 #ifdef CONFIG_64BIT
@@ -65,6 +67,8 @@ extern unsigned int vced_count, vcei_cou
 #define TASK_UNMAPPED_BASE						\
 	(test_thread_flag(TIF_32BIT_ADDR) ?				\
 		PAGE_ALIGN(TASK_SIZE32 / 3) : PAGE_ALIGN(TASK_SIZE / 3))
+#define TASK_SIZE_OF(tsk)						\
+	(test_thread_flag(TIF_32BIT_ADDR) ? TASK_SIZE32 : TASK_SIZE)
 #endif
 
 #define NUM_FPU_REGS	32
diff -puN include/asm-parisc/processor.h~task_size_of include/asm-parisc/processor.h
--- lxc/include/asm-parisc/processor.h~task_size_of	2007-08-22 16:16:52.000000000 -0700
+++ lxc-dave/include/asm-parisc/processor.h	2007-08-22 16:16:52.000000000 -0700
@@ -32,7 +32,8 @@
 #endif
 #define current_text_addr() ({ void *pc; current_ia(pc); pc; })
 
-#define TASK_SIZE               (current->thread.task_size)
+#define TASK_SIZE_OF(tsk)       ((tsk)->thread.task_size)
+#define TASK_SIZE	         (current->thread.task_size)
 #define TASK_UNMAPPED_BASE      (current->thread.map_base)
 
 #define DEFAULT_TASK_SIZE32	(0xFFF00000UL)
diff -puN include/asm-powerpc/processor.h~task_size_of include/asm-powerpc/processor.h
--- lxc/include/asm-powerpc/processor.h~task_size_of	2007-08-22 16:16:52.000000000 -0700
+++ lxc-dave/include/asm-powerpc/processor.h	2007-08-22 16:16:52.000000000 -0700
@@ -99,7 +99,9 @@ extern struct task_struct *last_task_use
  */
 #define TASK_SIZE_USER32 (0x0000000100000000UL - (1*PAGE_SIZE))
 
-#define TASK_SIZE (test_thread_flag(TIF_32BIT) ? \
+#define TASK_SIZE	  (test_thread_flag(TIF_32BIT) ? \
+		TASK_SIZE_USER32 : TASK_SIZE_USER64)
+#define TASK_SIZE_OF(tsk) (test_tsk_thread_flag(tsk, TIF_32BIT) ? \
 		TASK_SIZE_USER32 : TASK_SIZE_USER64)
 
 /* This decides where the kernel will search for a free chunk of vm
diff -puN include/asm-s390/processor.h~task_size_of include/asm-s390/processor.h
--- lxc/include/asm-s390/processor.h~task_size_of	2007-08-22 16:16:52.000000000 -0700
+++ lxc-dave/include/asm-s390/processor.h	2007-08-22 16:16:52.000000000 -0700
@@ -75,6 +75,8 @@ extern struct task_struct *last_task_use
 
 # define TASK_SIZE		(test_thread_flag(TIF_31BIT) ? \
 					(0x80000000UL) : (0x40000000000UL))
+# define TASK_SIZE_OF(tsk)	(test_tsk_thread_flag(tsk, TIF_31BIT) ? \
+					(0x80000000UL) : (0x40000000000UL))
 # define TASK_UNMAPPED_BASE	(TASK_SIZE / 2)
 # define DEFAULT_TASK_SIZE	(0x40000000000UL)
 
diff -puN include/linux/sched.h~task_size_of include/linux/sched.h
--- lxc/include/linux/sched.h~task_size_of	2007-08-22 16:16:52.000000000 -0700
+++ lxc-dave/include/linux/sched.h	2007-08-22 16:16:52.000000000 -0700
@@ -1810,6 +1810,10 @@ static inline void inc_syscw(struct task
 }
 #endif
 
+#ifndef TASK_SIZE_OF
+#define TASK_SIZE_OF(tsk)	TASK_SIZE
+#endif
+
 #endif /* __KERNEL__ */
 
 #endif
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
