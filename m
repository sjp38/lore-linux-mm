Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 89A2F6B009F
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 20:29:38 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [PATCH v18 18/80] c/r: create syscalls: sys_checkpoint, sys_restart
Date: Wed, 23 Sep 2009 19:50:58 -0400
Message-Id: <1253749920-18673-19-git-send-email-orenl@librato.com>
In-Reply-To: <1253749920-18673-1-git-send-email-orenl@librato.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Pavel Emelyanov <xemul@openvz.org>, Oren Laadan <orenl@librato.com>, Oren Laadan <orenl@cs.columbia.edu>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Create trivial sys_checkpoint and sys_restore system calls. They will
enable to checkpoint and restart an entire container, to and from a
checkpoint image file descriptor.

The syscalls take a pid, a file descriptor (for the image file) and
flags as arguments. The pid identifies the top-most (root) task in the
process tree, e.g. the container init: for sys_checkpoint the first
argument identifies the pid of the target container/subtree; for
sys_restart it will identify the pid of restarting root task.

A checkpoint, much like a process coredump, dumps the state of multiple
processes at once, including the state of the container. The checkpoint
image is written to (and read from) the file descriptor directly from
the kernel. This way the data is generated and then pushed out naturally
as resources and tasks are scanned to save their state. This is the
approach taken by, e.g., Zap and OpenVZ.

By using a return value and not a file descriptor, we can distinguish
between a return from checkpoint, a return from restart (in case of a
checkpoint that includes self, i.e. a task checkpointing its own
container, or itself), and an error condition, in a manner analogous
to a fork() call.

We don't use copy_from_user()/copy_to_user() because it requires
holding the entire image in user space, and does not make sense for
restart.  Also, we don't use a pipe, pseudo-fs file and the like,
because they work by generating data on demand as the user pulls it
(unless the entire image is buffered in the kernel) and would require
more complex logic.  They also would significantly complicate
checkpoint that includes self.

Changelog[v18]:
  - [John Dykstra] Fix no-dot-config-targets pattern in linux/Makefile
Changelog[v17]:
  - Move checkpoint closer to namespaces (kconfig)
  - Kill "Enable" in c/r config option
Changelog[v16]:
  - Change sys_restart() first argument to be 'pid_t pid'
Changelog[v14]:
  - Change CONFIG_CHEKCPOINT_RESTART to CONFIG_CHECKPOINT (Ingo)
  - Remove line 'def_bool n' (default is already 'n')
  - Add CHECKPOINT_SUPPORT in Kconfig (Nathan Lynch)
Changelog[v5]:
  - Config is 'def_bool n' by default

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge Hallyn <serue@us.ibm.com>
Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---
 Makefile                           |    2 +-
 arch/x86/Kconfig                   |    4 +++
 arch/x86/include/asm/unistd_32.h   |    2 +
 arch/x86/kernel/syscall_table_32.S |    2 +
 checkpoint/Kconfig                 |   14 ++++++++++++
 checkpoint/Makefile                |    5 ++++
 checkpoint/sys.c                   |   41 ++++++++++++++++++++++++++++++++++++
 include/linux/syscalls.h           |    2 +
 init/Kconfig                       |    2 +
 kernel/sys_ni.c                    |    4 +++
 10 files changed, 77 insertions(+), 1 deletions(-)
 create mode 100644 checkpoint/Kconfig
 create mode 100644 checkpoint/Makefile
 create mode 100644 checkpoint/sys.c

diff --git a/Makefile b/Makefile
index 60de4ef..fe45658 100644
--- a/Makefile
+++ b/Makefile
@@ -401,7 +401,7 @@ endif
 # of make so .config is not included in this case either (for *config).
 
 no-dot-config-targets := clean mrproper distclean \
-			 cscope TAGS tags help %docs check% \
+			 cscope TAGS tags help %docs checkstack \
 			 include/linux/version.h headers_% \
 			 kernelrelease kernelversion
 
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 13ffa5d..5776452 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -86,6 +86,10 @@ config STACKTRACE_SUPPORT
 config HAVE_LATENCYTOP_SUPPORT
 	def_bool y
 
+config CHECKPOINT_SUPPORT
+	bool
+	default y if X86_32
+
 config FAST_CMPXCHG_LOCAL
 	bool
 	default y
diff --git a/arch/x86/include/asm/unistd_32.h b/arch/x86/include/asm/unistd_32.h
index f65b750..c25971b 100644
--- a/arch/x86/include/asm/unistd_32.h
+++ b/arch/x86/include/asm/unistd_32.h
@@ -343,6 +343,8 @@
 #define __NR_rt_tgsigqueueinfo	335
 #define __NR_perf_counter_open	336
 #define __NR_clone_with_pids	337
+#define __NR_checkpoint		338
+#define __NR_restart		339
 
 #ifdef __KERNEL__
 
diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_table_32.S
index 879e5ec..4741554 100644
--- a/arch/x86/kernel/syscall_table_32.S
+++ b/arch/x86/kernel/syscall_table_32.S
@@ -337,3 +337,5 @@ ENTRY(sys_call_table)
 	.long sys_rt_tgsigqueueinfo	/* 335 */
 	.long sys_perf_counter_open
 	.long ptregs_clone_with_pids
+	.long sys_checkpoint
+	.long sys_restart
diff --git a/checkpoint/Kconfig b/checkpoint/Kconfig
new file mode 100644
index 0000000..ef7d406
--- /dev/null
+++ b/checkpoint/Kconfig
@@ -0,0 +1,14 @@
+# Architectures should define CHECKPOINT_SUPPORT when they have
+# implemented the hooks for processor state etc. needed by the
+# core checkpoint/restart code.
+
+config CHECKPOINT
+	bool "Checkpoint/restart (EXPERIMENTAL)"
+	depends on CHECKPOINT_SUPPORT && EXPERIMENTAL
+	help
+	  Application checkpoint/restart is the ability to save the
+	  state of a running application so that it can later resume
+	  its execution from the time at which it was checkpointed.
+
+	  Turning this option on will enable checkpoint and restart
+	  functionality in the kernel.
diff --git a/checkpoint/Makefile b/checkpoint/Makefile
new file mode 100644
index 0000000..8a32c6f
--- /dev/null
+++ b/checkpoint/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for linux checkpoint/restart.
+#
+
+obj-$(CONFIG_CHECKPOINT) += sys.o
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
new file mode 100644
index 0000000..79936cc
--- /dev/null
+++ b/checkpoint/sys.c
@@ -0,0 +1,41 @@
+/*
+ *  Generic container checkpoint-restart
+ *
+ *  Copyright (C) 2008-2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <linux/sched.h>
+#include <linux/kernel.h>
+#include <linux/syscalls.h>
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
+SYSCALL_DEFINE3(checkpoint, pid_t, pid, int, fd, unsigned long, flags)
+{
+	return -ENOSYS;
+}
+
+/**
+ * sys_restart - restart a container
+ * @pid: pid of task root (in coordinator's namespace), or 0
+ * @fd: file from which read the checkpoint image
+ * @flags: restart operation flags
+ *
+ * Returns negative value on error, or otherwise returns in the realm
+ * of the original checkpoint
+ */
+SYSCALL_DEFINE3(restart, pid_t, pid, int, fd, unsigned long, flags)
+{
+	return -ENOSYS;
+}
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 80de700..33bce6e 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -754,6 +754,8 @@ asmlinkage long sys_pselect6(int, fd_set __user *, fd_set __user *,
 asmlinkage long sys_ppoll(struct pollfd __user *, unsigned int,
 			  struct timespec __user *, const sigset_t __user *,
 			  size_t);
+asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags);
+asmlinkage long sys_restart(pid_t pid, int fd, unsigned long flags);
 
 int kernel_execve(const char *filename, char *const argv[], char *const envp[]);
 
diff --git a/init/Kconfig b/init/Kconfig
index 46ee2c8..46329b9 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -715,6 +715,8 @@ config NET_NS
 	  Allow user space to create what appear to be multiple instances
 	  of the network stack.
 
+source "checkpoint/Kconfig"
+
 config BLK_DEV_INITRD
 	bool "Initial RAM filesystem and RAM disk (initramfs/initrd) support"
 	depends on BROKEN || !FRV
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 68320f6..32f3f26 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -178,3 +178,7 @@ cond_syscall(sys_eventfd2);
 
 /* performance counters: */
 cond_syscall(sys_perf_counter_open);
+
+/* checkpoint/restart */
+cond_syscall(sys_checkpoint);
+cond_syscall(sys_restart);
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
