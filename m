Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id F07EF6B0261
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 17:35:48 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id d86so14201125pfk.19
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 14:35:48 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id q17si23324992pgt.123.2017.11.27.14.35.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 14:35:47 -0800 (PST)
Message-Id: <20171127223405.280205398@infradead.org>
Date: Mon, 27 Nov 2017 23:31:13 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH 3/5] x86/mm/kaiser: Revert ("Map the entry stack variables")
References: <20171127223110.479550152@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=peterz-kaiser-revert-syscall-entry-vars.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

Because its not needed. The entry_SYSCALL_64 code isn't ran when
KAISER is enabled, we use entry_SYSCALL_64_trampoline instead.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/x86/kernel/cpu/common.c |    2 +-
 arch/x86/kernel/process_64.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -1515,7 +1515,7 @@ EXPORT_PER_CPU_SYMBOL(__preempt_count);
  * the top of the kernel stack.  Use an extra percpu variable to track the
  * top of the kernel stack directly.
  */
-DEFINE_PER_CPU_USER_MAPPED(unsigned long, cpu_current_top_of_stack) =
+DEFINE_PER_CPU(unsigned long, cpu_current_top_of_stack) =
 	(unsigned long)&init_thread_union + THREAD_SIZE;
 EXPORT_PER_CPU_SYMBOL(cpu_current_top_of_stack);
 
--- a/arch/x86/kernel/process_64.c
+++ b/arch/x86/kernel/process_64.c
@@ -59,7 +59,7 @@
 #include <asm/unistd_32_ia32.h>
 #endif
 
-__visible DEFINE_PER_CPU_USER_MAPPED(unsigned long, rsp_scratch);
+__visible DEFINE_PER_CPU(unsigned long, rsp_scratch);
 
 /* Prints also some state that isn't saved in the pt_regs */
 void __show_regs(struct pt_regs *regs, int all)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
