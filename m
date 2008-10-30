From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v8][PATCH 01/12] Create syscalls: sys_checkpoint, sys_restart
Date: Thu, 30 Oct 2008 09:51:04 -0400
Message-Id: <1225374675-22850-2-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1225374675-22850-1-git-send-email-orenl@cs.columbia.edu>
References: <1225374675-22850-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Create trivial sys_checkpoint and sys_restore system calls. They will
enable to checkpoint and restart an entire container, to and from a
checkpoint image file descriptor.

The syscalls take a file descriptor (for the image file) and flags as
arguments. For sys_checkpoint the first argument identifies the target
container; for sys_restart it will identify the checkpoint image.

The checkpoint image is written to (and read from) the file descriptor
directly from the kernel. This way the data is generated and pushed
out naturally as resources and tasks are scanned to save their state.
This is the approach taken by, e.g., Zap and OpenVZ.

By using a return value and not a file descriptor, we can distinguish
between a return from checkpoint, a return from restart (in case of a
checkpoint that includes self, i.e. a task checkpointing its own
container, or itself), and an error condition, in a manner analogous
to a fork() call.

We don't use copyin()/copyout() because it requires holding the entire
image in user space, and does not make sense for restart.  Also, we
don't use a pipe, pseudo-fs file and the like, because they work by
generating data on demand as the user pulls it (unless the entire
image is buffered in the kernel) and would require more complex logic.
They also would significantly complicate checkpoint that includes self.

Changelog[v5]:
  - Config is 'def_bool n' by default

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge Hallyn <serue@us.ibm.com>
Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---
 arch/x86/kernel/syscall_table_32.S |    2 +
 checkpoint/Kconfig                 |   11 +++++++++
 checkpoint/Makefile                |    5 ++++
 checkpoint/sys.c                   |   41 ++++++++++++++++++++++++++++++++++++
 include/asm-x86/unistd_32.h        |    2 +
 include/linux/syscalls.h           |    2 +
 init/Kconfig                       |    2 +
 kernel/sys_ni.c                    |    4 +++
 8 files changed, 69 insertions(+), 0 deletions(-)
 create mode 100644 checkpoint/Kconfig
 create mode 100644 checkpoint/Makefile
 create mode 100644 checkpoint/sys.c

diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_table_32.S
index d44395f..5543136 100644
--- a/arch/x86/kernel/syscall_table_32.S
+++ b/arch/x86/kernel/syscall_table_32.S
@@ -332,3 +332,5 @@ ENTRY(sys_call_table)
 	.long sys_dup3			/* 330 */
 	.long sys_pipe2
 	.long sys_inotify_init1
+	.long sys_checkpoint
+	.long sys_restart
diff --git a/checkpoint/Kconfig b/checkpoint/Kconfig
new file mode 100644
index 0000000..ffaa635
--- /dev/null
+++ b/checkpoint/Kconfig
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
diff --git a/checkpoint/Makefile b/checkpoint/Makefile
new file mode 100644
index 0000000..07d018b
--- /dev/null
+++ b/checkpoint/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for linux checkpoint/restart.
+#
+
+obj-$(CONFIG_CHECKPOINT_RESTART) += sys.o
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
new file mode 100644
index 0000000..375129c
--- /dev/null
+++ b/checkpoint/sys.c
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
diff --git a/include/asm-x86/unistd_32.h b/include/asm-x86/unistd_32.h
index d739467..88bdec4 100644
--- a/include/asm-x86/unistd_32.h
+++ b/include/asm-x86/unistd_32.h
@@ -338,6 +338,8 @@
 #define __NR_dup3		330
 #define __NR_pipe2		331
 #define __NR_inotify_init1	332
+#define __NR_checkpoint		333
+#define __NR_restart		334
 
 #ifdef __KERNEL__
 
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index d6ff145..edc218b 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -622,6 +622,8 @@ asmlinkage long sys_timerfd_gettime(int ufd, struct itimerspec __user *otmr);
 asmlinkage long sys_eventfd(unsigned int count);
 asmlinkage long sys_eventfd2(unsigned int count, int flags);
 asmlinkage long sys_fallocate(int fd, int mode, loff_t offset, loff_t len);
+asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags);
+asmlinkage long sys_restart(int crid, int fd, unsigned long flags);
 
 int kernel_execve(const char *filename, char *const argv[], char *const envp[]);
 
diff --git a/init/Kconfig b/init/Kconfig
index c11da38..fd5f7bf 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -779,6 +779,8 @@ config MARKERS
 
 source "arch/Kconfig"
 
+source "checkpoint/Kconfig"
+
 config PROC_PAGE_MONITOR
  	default y
 	depends on PROC_FS && MMU
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 08d6e1b..ca95c25 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -168,3 +168,7 @@ cond_syscall(compat_sys_timerfd_settime);
 cond_syscall(compat_sys_timerfd_gettime);
 cond_syscall(sys_eventfd);
 cond_syscall(sys_eventfd2);
+
+/* checkpoint/restart */
+cond_syscall(sys_checkpoint);
+cond_syscall(sys_restart);
-- 
1.5.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
