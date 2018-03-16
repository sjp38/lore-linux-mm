Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5924A6B028C
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 15:31:45 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id d23so1355770wmd.1
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 12:31:45 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id s35si4345524eda.464.2018.03.16.12.30.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 12:30:04 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 12/35] x86/32: Use tss.sp1 as cpu_current_top_of_stack
Date: Fri, 16 Mar 2018 20:29:30 +0100
Message-Id: <1521228593-3820-13-git-send-email-joro@8bytes.org>
In-Reply-To: <1521228593-3820-1-git-send-email-joro@8bytes.org>
References: <1521228593-3820-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

Now that we store the task-stack in tss.sp1 we can also use
it as cpu_current_top_of_stack. This unifies the handling
with x86-64.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/include/asm/processor.h   | 4 ----
 arch/x86/include/asm/thread_info.h | 2 --
 arch/x86/kernel/cpu/common.c       | 4 ----
 arch/x86/kernel/process_32.c       | 6 ------
 4 files changed, 16 deletions(-)

diff --git a/arch/x86/include/asm/processor.h b/arch/x86/include/asm/processor.h
index 513f960..b7c238e 100644
--- a/arch/x86/include/asm/processor.h
+++ b/arch/x86/include/asm/processor.h
@@ -374,12 +374,8 @@ DECLARE_PER_CPU_PAGE_ALIGNED(struct tss_struct, cpu_tss_rw);
 #define __KERNEL_TSS_LIMIT	\
 	(IO_BITMAP_OFFSET + IO_BITMAP_BYTES + sizeof(unsigned long) - 1)
 
-#ifdef CONFIG_X86_32
-DECLARE_PER_CPU(unsigned long, cpu_current_top_of_stack);
-#else
 /* The RO copy can't be accessed with this_cpu_xyz(), so use the RW copy. */
 #define cpu_current_top_of_stack cpu_tss_rw.x86_tss.sp1
-#endif
 
 /*
  * Save the original ist values for checking stack pointers during debugging
diff --git a/arch/x86/include/asm/thread_info.h b/arch/x86/include/asm/thread_info.h
index eda3b68..ea7e118 100644
--- a/arch/x86/include/asm/thread_info.h
+++ b/arch/x86/include/asm/thread_info.h
@@ -207,9 +207,7 @@ static inline int arch_within_stack_frames(const void * const stack,
 
 #else /* !__ASSEMBLY__ */
 
-#ifdef CONFIG_X86_64
 # define cpu_current_top_of_stack (cpu_tss_rw + TSS_sp1)
-#endif
 
 #endif
 
diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
index a0ed348..de1c595 100644
--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -1503,10 +1503,6 @@ EXPORT_PER_CPU_SYMBOL(__preempt_count);
  * the top of the kernel stack.  Use an extra percpu variable to track the
  * top of the kernel stack directly.
  */
-DEFINE_PER_CPU(unsigned long, cpu_current_top_of_stack) =
-	(unsigned long)&init_thread_union + THREAD_SIZE;
-EXPORT_PER_CPU_SYMBOL(cpu_current_top_of_stack);
-
 #ifdef CONFIG_CC_STACKPROTECTOR
 DEFINE_PER_CPU_ALIGNED(struct stack_canary, stack_canary);
 #endif
diff --git a/arch/x86/kernel/process_32.c b/arch/x86/kernel/process_32.c
index 3f3a8c6..8c29fd5 100644
--- a/arch/x86/kernel/process_32.c
+++ b/arch/x86/kernel/process_32.c
@@ -290,12 +290,6 @@ __switch_to(struct task_struct *prev_p, struct task_struct *next_p)
 	update_sp0(next_p);
 	refresh_sysenter_cs(next);
 	this_cpu_write(cpu_current_top_of_stack, task_top_of_stack(next_p));
-	/*
-	 * TODO: Find a way to let cpu_current_top_of_stack point to
-	 * cpu_tss_rw.x86_tss.sp1. Doing so now results in stack corruption with
-	 * iret exceptions.
-	 */
-	this_cpu_write(cpu_tss_rw.x86_tss.sp1, next_p->thread.sp0);
 
 	/*
 	 * Restore %gs if needed (which is common)
-- 
2.7.4
