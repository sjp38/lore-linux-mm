Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id AB3106B009E
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 20:29:34 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [PATCH v18 80/80] powerpc: clone_with_pids implementation
Date: Wed, 23 Sep 2009 19:52:00 -0400
Message-Id: <1253749920-18673-81-git-send-email-orenl@librato.com>
In-Reply-To: <1253749920-18673-1-git-send-email-orenl@librato.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Pavel Emelyanov <xemul@openvz.org>, Nathan Lynch <ntl@pobox.com>
List-ID: <linux-mm.kvack.org>

From: Nathan Lynch <ntl@pobox.com>

Mostly copy-paste from existing clone code.

(may want to hold off applying this until the ongoing clone_with_pids
discussion is resolved.)

Signed-off-by: Nathan Lynch <ntl@pobox.com>
---
 arch/powerpc/include/asm/syscalls.h |    4 ++++
 arch/powerpc/include/asm/systbl.h   |    1 +
 arch/powerpc/include/asm/unistd.h   |    3 ++-
 arch/powerpc/kernel/entry_32.S      |    8 ++++++++
 arch/powerpc/kernel/entry_64.S      |    5 +++++
 arch/powerpc/kernel/process.c       |   20 +++++++++++++++++++-
 6 files changed, 39 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/include/asm/syscalls.h b/arch/powerpc/include/asm/syscalls.h
index eb8eb40..25dfe8b 100644
--- a/arch/powerpc/include/asm/syscalls.h
+++ b/arch/powerpc/include/asm/syscalls.h
@@ -24,6 +24,10 @@ asmlinkage int sys_execve(unsigned long a0, unsigned long a1,
 asmlinkage int sys_clone(unsigned long clone_flags, unsigned long usp,
 		int __user *parent_tidp, void __user *child_threadptr,
 		int __user *child_tidp, int p6, struct pt_regs *regs);
+asmlinkage int sys_clone_with_pids(unsigned long clone_flags,
+		unsigned long usp, int __user *parent_tidp,
+		void __user *child_threadptr, int __user *child_tidp,
+		void __user *upid_setp, struct pt_regs *regs);
 asmlinkage int sys_fork(unsigned long p1, unsigned long p2,
 		unsigned long p3, unsigned long p4, unsigned long p5,
 		unsigned long p6, struct pt_regs *regs);
diff --git a/arch/powerpc/include/asm/systbl.h b/arch/powerpc/include/asm/systbl.h
index 3d44cf3..e3c0b96 100644
--- a/arch/powerpc/include/asm/systbl.h
+++ b/arch/powerpc/include/asm/systbl.h
@@ -328,3 +328,4 @@ COMPAT_SYS_SPU(pwritev)
 COMPAT_SYS(rt_tgsigqueueinfo)
 SYSCALL(checkpoint)
 SYSCALL(restart)
+PPC_SYS(clone_with_pids)
diff --git a/arch/powerpc/include/asm/unistd.h b/arch/powerpc/include/asm/unistd.h
index ef41ebb..c54db8b 100644
--- a/arch/powerpc/include/asm/unistd.h
+++ b/arch/powerpc/include/asm/unistd.h
@@ -347,10 +347,11 @@
 #define __NR_rt_tgsigqueueinfo	322
 #define __NR_checkpoint		323
 #define __NR_restart		324
+#define __NR_clone_with_pids	325
 
 #ifdef __KERNEL__
 
-#define __NR_syscalls		325
+#define __NR_syscalls		326
 
 #define __NR__exit __NR_exit
 #define NR_syscalls	__NR_syscalls
diff --git a/arch/powerpc/kernel/entry_32.S b/arch/powerpc/kernel/entry_32.S
index 3cadba6..081dd36 100644
--- a/arch/powerpc/kernel/entry_32.S
+++ b/arch/powerpc/kernel/entry_32.S
@@ -586,6 +586,14 @@ ppc_clone:
 	stw	r0,_TRAP(r1)		/* register set saved */
 	b	sys_clone
 
+	.globl	ppc_clone_with_pids
+ppc_clone_with_pids:
+	SAVE_NVGPRS(r1)
+	lwz	r0,_TRAP(r1)
+	rlwinm	r0,r0,0,0,30		/* clear LSB to indicate full */
+	stw	r0,_TRAP(r1)		/* register set saved */
+	b	sys_clone_with_pids
+
 	.globl	ppc_swapcontext
 ppc_swapcontext:
 	SAVE_NVGPRS(r1)
diff --git a/arch/powerpc/kernel/entry_64.S b/arch/powerpc/kernel/entry_64.S
index 43e0734..39fa316 100644
--- a/arch/powerpc/kernel/entry_64.S
+++ b/arch/powerpc/kernel/entry_64.S
@@ -320,6 +320,11 @@ _GLOBAL(ppc_clone)
 	bl	.sys_clone
 	b	syscall_exit
 
+_GLOBAL(ppc_clone_with_pids)
+	bl	.save_nvgprs
+	bl	.sys_clone_with_pids
+	b	syscall_exit
+
 _GLOBAL(ppc32_swapcontext)
 	bl	.save_nvgprs
 	bl	.compat_sys_swapcontext
diff --git a/arch/powerpc/kernel/process.c b/arch/powerpc/kernel/process.c
index 892a9f2..7bf21cc 100644
--- a/arch/powerpc/kernel/process.c
+++ b/arch/powerpc/kernel/process.c
@@ -895,7 +895,25 @@ int sys_clone(unsigned long clone_flags, unsigned long usp,
 		child_tidp = TRUNC_PTR(child_tidp);
 	}
 #endif
- 	return do_fork(clone_flags, usp, regs, 0, parent_tidp, child_tidp);
+	return do_fork(clone_flags, usp, regs, 0, parent_tidp, child_tidp);
+}
+
+int sys_clone_with_pids(unsigned long clone_flags, unsigned long usp,
+	      int __user *parent_tidp, void __user *child_threadptr,
+	      int __user *child_tidp, void __user *upid_setp,
+	      struct pt_regs *regs)
+{
+	CHECK_FULL_REGS(regs);
+	if (usp == 0)
+		usp = regs->gpr[1];
+#ifdef CONFIG_PPC64
+	if (test_thread_flag(TIF_32BIT)) {
+		parent_tidp = TRUNC_PTR(parent_tidp);
+		child_tidp = TRUNC_PTR(child_tidp);
+	}
+#endif
+	return do_fork_with_pids(clone_flags, usp, regs, 0,
+				 parent_tidp, child_tidp, upid_setp);
 }
 
 int sys_fork(unsigned long p1, unsigned long p2, unsigned long p3,
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
