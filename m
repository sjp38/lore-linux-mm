Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 16F276B0272
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 05:41:29 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id r9-v6so1701507edh.14
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 02:41:29 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id p7-v6si687097edh.418.2018.07.18.02.41.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 02:41:27 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 03/39] x86/entry/32: Load task stack from x86_tss.sp1 in SYSENTER handler
Date: Wed, 18 Jul 2018 11:40:40 +0200
Message-Id: <1531906876-13451-4-git-send-email-joro@8bytes.org>
In-Reply-To: <1531906876-13451-1-git-send-email-joro@8bytes.org>
References: <1531906876-13451-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

We want x86_tss.sp0 point to the entry stack later to use
it as a trampoline stack for other kernel entry points
besides SYSENTER.

So store the task stack pointer in x86_tss.sp1, which is
otherwise unused by the hardware, as Linux doesn't make use
of Ring 1.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/kernel/asm-offsets_32.c | 9 +++++++--
 arch/x86/kernel/process_32.c     | 2 ++
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/arch/x86/kernel/asm-offsets_32.c b/arch/x86/kernel/asm-offsets_32.c
index 15b3f45..82826f2 100644
--- a/arch/x86/kernel/asm-offsets_32.c
+++ b/arch/x86/kernel/asm-offsets_32.c
@@ -46,9 +46,14 @@ void foo(void)
 	OFFSET(saved_context_gdt_desc, saved_context, gdt_desc);
 	BLANK();
 
-	/* Offset from the entry stack to task stack stored in TSS */
+	/*
+	 * Offset from the entry stack to task stack stored in TSS. Kernel entry
+	 * happens on the per-cpu entry-stack, and the asm code switches to the
+	 * task-stack pointer stored in x86_tss.sp1, which is a copy of
+	 * task->thread.sp0 where entry code can find it.
+	 */
 	DEFINE(TSS_entry2task_stack,
-	       offsetof(struct cpu_entry_area, tss.x86_tss.sp0) -
+	       offsetof(struct cpu_entry_area, tss.x86_tss.sp1) -
 	       offsetofend(struct cpu_entry_area, entry_stack_page.stack));
 
 #ifdef CONFIG_STACKPROTECTOR
diff --git a/arch/x86/kernel/process_32.c b/arch/x86/kernel/process_32.c
index 0ae659d..ec62cc7 100644
--- a/arch/x86/kernel/process_32.c
+++ b/arch/x86/kernel/process_32.c
@@ -290,6 +290,8 @@ __switch_to(struct task_struct *prev_p, struct task_struct *next_p)
 	this_cpu_write(cpu_current_top_of_stack,
 		       (unsigned long)task_stack_page(next_p) +
 		       THREAD_SIZE);
+	/* SYSENTER reads the task-stack from tss.sp1 */
+	this_cpu_write(cpu_tss_rw.x86_tss.sp1, next_p->thread.sp0);
 
 	/*
 	 * Restore %gs if needed (which is common)
-- 
2.7.4
