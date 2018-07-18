Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2ADC56B027A
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 05:41:32 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d5-v6so1699665edq.3
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 02:41:32 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id r47-v6si332790edr.420.2018.07.18.02.41.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 02:41:30 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 14/39] x86/entry: Rename update_sp0 to update_task_stack
Date: Wed, 18 Jul 2018 11:40:51 +0200
Message-Id: <1531906876-13451-15-git-send-email-joro@8bytes.org>
In-Reply-To: <1531906876-13451-1-git-send-email-joro@8bytes.org>
References: <1531906876-13451-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

The function does not update sp0 anymore but updates makes
the task-stack visible for entry code. This is by either
writing it to sp1 or by doing a hypercall. Rename the
function to get rid of the misleading name.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/include/asm/switch_to.h | 2 +-
 arch/x86/kernel/process_32.c     | 2 +-
 arch/x86/kernel/process_64.c     | 2 +-
 arch/x86/kernel/vm86_32.c        | 4 ++--
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/arch/x86/include/asm/switch_to.h b/arch/x86/include/asm/switch_to.h
index 8bc2f70..36bd243 100644
--- a/arch/x86/include/asm/switch_to.h
+++ b/arch/x86/include/asm/switch_to.h
@@ -87,7 +87,7 @@ static inline void refresh_sysenter_cs(struct thread_struct *thread)
 #endif
 
 /* This is used when switching tasks or entering/exiting vm86 mode. */
-static inline void update_sp0(struct task_struct *task)
+static inline void update_task_stack(struct task_struct *task)
 {
 	/* sp0 always points to the entry trampoline stack, which is constant: */
 #ifdef CONFIG_X86_32
diff --git a/arch/x86/kernel/process_32.c b/arch/x86/kernel/process_32.c
index 0ae659d..2924fd4 100644
--- a/arch/x86/kernel/process_32.c
+++ b/arch/x86/kernel/process_32.c
@@ -285,7 +285,7 @@ __switch_to(struct task_struct *prev_p, struct task_struct *next_p)
 	 * current_thread_info().  Refresh the SYSENTER configuration in
 	 * case prev or next is vm86.
 	 */
-	update_sp0(next_p);
+	update_task_stack(next_p);
 	refresh_sysenter_cs(next);
 	this_cpu_write(cpu_current_top_of_stack,
 		       (unsigned long)task_stack_page(next_p) +
diff --git a/arch/x86/kernel/process_64.c b/arch/x86/kernel/process_64.c
index 12bb445..476e3dd 100644
--- a/arch/x86/kernel/process_64.c
+++ b/arch/x86/kernel/process_64.c
@@ -478,7 +478,7 @@ __switch_to(struct task_struct *prev_p, struct task_struct *next_p)
 	this_cpu_write(cpu_current_top_of_stack, task_top_of_stack(next_p));
 
 	/* Reload sp0. */
-	update_sp0(next_p);
+	update_task_stack(next_p);
 
 	/*
 	 * Now maybe reload the debug registers and handle I/O bitmaps
diff --git a/arch/x86/kernel/vm86_32.c b/arch/x86/kernel/vm86_32.c
index 9d0b5af..1c03e4a 100644
--- a/arch/x86/kernel/vm86_32.c
+++ b/arch/x86/kernel/vm86_32.c
@@ -149,7 +149,7 @@ void save_v86_state(struct kernel_vm86_regs *regs, int retval)
 	preempt_disable();
 	tsk->thread.sp0 = vm86->saved_sp0;
 	tsk->thread.sysenter_cs = __KERNEL_CS;
-	update_sp0(tsk);
+	update_task_stack(tsk);
 	refresh_sysenter_cs(&tsk->thread);
 	vm86->saved_sp0 = 0;
 	preempt_enable();
@@ -374,7 +374,7 @@ static long do_sys_vm86(struct vm86plus_struct __user *user_vm86, bool plus)
 		refresh_sysenter_cs(&tsk->thread);
 	}
 
-	update_sp0(tsk);
+	update_task_stack(tsk);
 	preempt_enable();
 
 	if (vm86->flags & VM86_SCREEN_BITMAP)
-- 
2.7.4
