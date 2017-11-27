Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id AC2A96B0253
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 17:35:48 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id i89so25809891pfj.9
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 14:35:48 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 42si24249346ple.438.2017.11.27.14.35.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 14:35:45 -0800 (PST)
Message-Id: <20171127223405.329572992@infradead.org>
Date: Mon, 27 Nov 2017 23:31:14 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH 4/5] x86/mm/kaiser: Remove superfluous SWITCH_TO_KERNEL
References: <20171127223110.479550152@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=peterz-kaiser-fixup-syscall-switch.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

We never use this code-path with KAISER enabled.

Fixes: ("Prepare the x86/entry assembly code for entry/exit CR3 switching")
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/x86/entry/entry_64.S |    8 --------
 1 file changed, 8 deletions(-)

--- a/arch/x86/entry/entry_64.S
+++ b/arch/x86/entry/entry_64.S
@@ -201,14 +201,6 @@ ENTRY(entry_SYSCALL_64)
 
 	swapgs
 	movq	%rsp, PER_CPU_VAR(rsp_scratch)
-
-	/*
-	 * The kernel CR3 is needed to map the process stack, but we
-	 * need a scratch register to be able to load CR3.  %rsp is
-	 * clobberable right now, so use it as a scratch register.
-	 * %rsp will look crazy here for a couple instructions.
-	 */
-	SWITCH_TO_KERNEL_CR3 scratch_reg=%rsp
 	movq	PER_CPU_VAR(cpu_current_top_of_stack), %rsp
 
 	/* Construct struct pt_regs on stack */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
