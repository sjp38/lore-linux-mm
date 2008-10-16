Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m9GIHDWM032129
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 14:17:14 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9GIEKsf076174
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 14:14:20 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9GIEJ33027423
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 14:14:20 -0400
Subject: [PATCH 1/9] Create syscalls: sys_checkpoint, sys_restart
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Thu, 16 Oct 2008 11:14:15 -0700
References: <20081016181414.934C4FCC@kernel>
In-Reply-To: <20081016181414.934C4FCC@kernel>
Message-Id: <20081016181415.B63AF0FA@kernel>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, linux-mm <linux-mm@kvack.org>, containers <containers@lists.linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Serge E. Hallyn" <serue@us.ibm.com>, Oren Laadan <orenl@cs.columbia.edu>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

From: Oren Laadan <orenl@cs.columbia.edu>

Create trivial sys_checkpoint and sys_restore system calls. They will
enable to checkpoint and restart an entire container, to and from a
checkpoint image file descriptor.

The syscalls take a file descriptor (for the image file) and flags as
arguments. For sys_checkpoint the first argument identifies the target
container; for sys_restart it will identify the checkpoint image.

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge Hallyn <serue@us.ibm.com>
Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/arch/x86/kernel/syscall_table_32.S |    2 
 linux-2.6.git-dave/checkpoint/Kconfig                 |   11 ++++
 linux-2.6.git-dave/checkpoint/Makefile                |    5 ++
 linux-2.6.git-dave/checkpoint/sys.c                   |   41 ++++++++++++++++++
 linux-2.6.git-dave/include/asm-x86/unistd_32.h        |    2 
 linux-2.6.git-dave/include/linux/syscalls.h           |    2 
 linux-2.6.git-dave/init/Kconfig                       |    2 
 linux-2.6.git-dave/kernel/sys_ni.c                    |    4 +
 8 files changed, 69 insertions(+)

diff -puN arch/x86/kernel/syscall_table_32.S~v6_PATCH_1_9_Create_syscalls-_sys_checkpoint_sys_restart arch/x86/kernel/syscall_table_32.S
--- linux-2.6.git/arch/x86/kernel/syscall_table_32.S~v6_PATCH_1_9_Create_syscalls-_sys_checkpoint_sys_restart	2008-10-16 10:53:33.000000000 -0700
+++ linux-2.6.git-dave/arch/x86/kernel/syscall_table_32.S	2008-10-16 10:53:33.000000000 -0700
@@ -332,3 +332,5 @@ ENTRY(sys_call_table)
 	.long sys_dup3			/* 330 */
 	.long sys_pipe2
 	.long sys_inotify_init1
+	.long sys_checkpoint
+	.long sys_restart
diff -puN /dev/null checkpoint/Kconfig
--- /dev/null	2008-09-02 09:40:19.000000000 -0700
+++ linux-2.6.git-dave/checkpoint/Kconfig	2008-10-16 10:53:33.000000000 -0700
@@ -0,0 +1,11 @@
+config CHECKPOINT_RESTART
+	prompt "Enable checkpoint/restart (EXPERIMENTAL)"
+	def_bool n
+	depends on X86_32 && EXPERIMENTAL
+	help
+	  Application checkpoint/restart is the ability to save the
+	  state of a running application so that it can later resume
+	  its execution from the time at which it was checkpointed.
+
+	  Turning this option on will enable checkpoint and restart
+	  functionality in the kernel.
diff -puN /dev/null checkpoint/Makefile
--- /dev/null	2008-09-02 09:40:19.000000000 -0700
+++ linux-2.6.git-dave/checkpoint/Makefile	2008-10-16 10:53:33.000000000 -0700
@@ -0,0 +1,5 @@
+#
+# Makefile for linux checkpoint/restart.
+#
+
+obj-$(CONFIG_CHECKPOINT_RESTART) += sys.o
diff -puN /dev/null checkpoint/sys.c
--- /dev/null	2008-09-02 09:40:19.000000000 -0700
+++ linux-2.6.git-dave/checkpoint/sys.c	2008-10-16 10:53:33.000000000 -0700
@@ -0,0 +1,41 @@
+/*
+ *  Generic container checkpoint-restart
+ *
+ *  Copyright (C) 2008 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <linux/sched.h>
+#include <linux/kernel.h>
+
+/**
+ * sys_checkpoint - checkpoint a container
+ * @pid: pid of the container init(1) process
+ * @fd: file to which dump the checkpoint image
+ * @flags: checkpoint operation flags
+ *
+ * Returns positive identifier on success, 0 when returning from restart
+ * or negative value on error
+ */
+asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags)
+{
+	pr_debug("sys_checkpoint not implemented yet\n");
+	return -ENOSYS;
+}
+/**
+ * sys_restart - restart a container
+ * @crid: checkpoint image identifier
+ * @fd: file from which read the checkpoint image
+ * @flags: restart operation flags
+ *
+ * Returns negative value on error, or otherwise returns in the realm
+ * of the original checkpoint
+ */
+asmlinkage long sys_restart(int crid, int fd, unsigned long flags)
+{
+	pr_debug("sys_restart not implemented yet\n");
+	return -ENOSYS;
+}
diff -puN include/asm-x86/unistd_32.h~v6_PATCH_1_9_Create_syscalls-_sys_checkpoint_sys_restart include/asm-x86/unistd_32.h
--- linux-2.6.git/include/asm-x86/unistd_32.h~v6_PATCH_1_9_Create_syscalls-_sys_checkpoint_sys_restart	2008-10-16 10:53:33.000000000 -0700
+++ linux-2.6.git-dave/include/asm-x86/unistd_32.h	2008-10-16 10:53:33.000000000 -0700
@@ -338,6 +338,8 @@
 #define __NR_dup3		330
 #define __NR_pipe2		331
 #define __NR_inotify_init1	332
+#define __NR_checkpoint		333
+#define __NR_restart		334
 
 #ifdef __KERNEL__
 
diff -puN include/linux/syscalls.h~v6_PATCH_1_9_Create_syscalls-_sys_checkpoint_sys_restart include/linux/syscalls.h
--- linux-2.6.git/include/linux/syscalls.h~v6_PATCH_1_9_Create_syscalls-_sys_checkpoint_sys_restart	2008-10-16 10:53:33.000000000 -0700
+++ linux-2.6.git-dave/include/linux/syscalls.h	2008-10-16 10:53:33.000000000 -0700
@@ -622,6 +622,8 @@ asmlinkage long sys_timerfd_gettime(int 
 asmlinkage long sys_eventfd(unsigned int count);
 asmlinkage long sys_eventfd2(unsigned int count, int flags);
 asmlinkage long sys_fallocate(int fd, int mode, loff_t offset, loff_t len);
+asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags);
+asmlinkage long sys_restart(int crid, int fd, unsigned long flags);
 
 int kernel_execve(const char *filename, char *const argv[], char *const envp[]);
 
diff -puN init/Kconfig~v6_PATCH_1_9_Create_syscalls-_sys_checkpoint_sys_restart init/Kconfig
--- linux-2.6.git/init/Kconfig~v6_PATCH_1_9_Create_syscalls-_sys_checkpoint_sys_restart	2008-10-16 10:53:33.000000000 -0700
+++ linux-2.6.git-dave/init/Kconfig	2008-10-16 10:53:33.000000000 -0700
@@ -779,6 +779,8 @@ config MARKERS
 
 source "arch/Kconfig"
 
+source "checkpoint/Kconfig"
+
 endmenu		# General setup
 
 config HAVE_GENERIC_DMA_COHERENT
diff -puN kernel/sys_ni.c~v6_PATCH_1_9_Create_syscalls-_sys_checkpoint_sys_restart kernel/sys_ni.c
--- linux-2.6.git/kernel/sys_ni.c~v6_PATCH_1_9_Create_syscalls-_sys_checkpoint_sys_restart	2008-10-16 10:53:33.000000000 -0700
+++ linux-2.6.git-dave/kernel/sys_ni.c	2008-10-16 10:53:33.000000000 -0700
@@ -169,3 +169,7 @@ cond_syscall(compat_sys_timerfd_settime)
 cond_syscall(compat_sys_timerfd_gettime);
 cond_syscall(sys_eventfd);
 cond_syscall(sys_eventfd2);
+
+/* checkpoint/restart */
+cond_syscall(sys_checkpoint);
+cond_syscall(sys_restart);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
