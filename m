Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l7LJa0IT023555
	for <linux-mm@kvack.org>; Tue, 21 Aug 2007 15:36:00 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7LKgtQo254526
	for <linux-mm@kvack.org>; Tue, 21 Aug 2007 14:42:55 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7LKgtmc002849
	for <linux-mm@kvack.org>; Tue, 21 Aug 2007 14:42:55 -0600
Subject: [RFC][PATCH 5/9] introduce TASK_SIZE_OF() for all arches
From: Dave Hansen <haveblue@us.ibm.com>
Date: Tue, 21 Aug 2007 13:42:53 -0700
References: <20070821204248.0F506A29@kernel>
In-Reply-To: <20070821204248.0F506A29@kernel>
Message-Id: <20070821204253.FDA0E340@kernel>
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

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 lxc-dave/include/asm-ia64/processor.h    |    3 ++-
 lxc-dave/include/asm-parisc/processor.h  |    3 ++-
 lxc-dave/include/asm-powerpc/processor.h |    4 +++-
 lxc-dave/include/asm-s390/processor.h    |    2 ++
 lxc-dave/include/linux/sched.h           |    4 ++++
 5 files changed, 13 insertions(+), 3 deletions(-)

diff -puN include/asm-ia64/processor.h~task_size_of include/asm-ia64/processor.h
--- lxc/include/asm-ia64/processor.h~task_size_of	2007-08-21 13:30:52.000000000 -0700
+++ lxc-dave/include/asm-ia64/processor.h	2007-08-21 13:30:52.000000000 -0700
@@ -31,7 +31,8 @@
  * each (assuming 8KB page size), for a total of 8TB of user virtual
  * address space.
  */
-#define TASK_SIZE		(current->thread.task_size)
+#define TASK_SIZE_OF(tsk)	((tsk)->thread.task_size)
+#define TASK_SIZE       	TASK_SIZE_OF(current)
 
 /*
  * This decides where the kernel will search for a free chunk of vm
diff -puN include/asm-parisc/processor.h~task_size_of include/asm-parisc/processor.h
--- lxc/include/asm-parisc/processor.h~task_size_of	2007-08-21 13:30:52.000000000 -0700
+++ lxc-dave/include/asm-parisc/processor.h	2007-08-21 13:30:52.000000000 -0700
@@ -32,7 +32,8 @@
 #endif
 #define current_text_addr() ({ void *pc; current_ia(pc); pc; })
 
-#define TASK_SIZE               (current->thread.task_size)
+#define TASK_SIZE_OF(tsk)       ((tsk)->thread.task_size)
+#define TASK_SIZE	         (current->thread.task_size)
 #define TASK_UNMAPPED_BASE      (current->thread.map_base)
 
 #define DEFAULT_TASK_SIZE32	(0xFFF00000UL)
diff -puN include/asm-powerpc/processor.h~task_size_of include/asm-powerpc/processor.h
--- lxc/include/asm-powerpc/processor.h~task_size_of	2007-08-21 13:30:52.000000000 -0700
+++ lxc-dave/include/asm-powerpc/processor.h	2007-08-21 13:30:52.000000000 -0700
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
--- lxc/include/asm-s390/processor.h~task_size_of	2007-08-21 13:30:52.000000000 -0700
+++ lxc-dave/include/asm-s390/processor.h	2007-08-21 13:30:52.000000000 -0700
@@ -75,6 +75,8 @@ extern struct task_struct *last_task_use
 
 # define TASK_SIZE		(test_thread_flag(TIF_31BIT) ? \
 					(0x80000000UL) : (0x40000000000UL))
+# define TASK_SIZE_OF(tsk)	(test_tsk_thread_flag(tsk, TIF_31BIT) ? \
+					(0x80000000UL) : (0x40000000000UL))
 # define TASK_UNMAPPED_BASE	(TASK_SIZE / 2)
 # define DEFAULT_TASK_SIZE	(0x40000000000UL)
 
diff -puN include/linux/sched.h~task_size_of include/linux/sched.h
--- lxc/include/linux/sched.h~task_size_of	2007-08-21 13:30:52.000000000 -0700
+++ lxc-dave/include/linux/sched.h	2007-08-21 13:30:52.000000000 -0700
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
