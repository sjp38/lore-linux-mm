Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 03ED56B0261
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 05:35:58 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id o124so2474975ioo.20
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 02:35:58 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id h23si994014iob.158.2017.11.29.02.35.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 02:35:57 -0800 (PST)
Message-Id: <20171129103512.720277518@infradead.org>
Date: Wed, 29 Nov 2017 11:33:03 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH 2/6] x86/mm/kaiser: Fix inconsistency in SAVE_AND_SWITCH_TO_KERNEL_CR3
References: <20171129103301.131535445@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=peterz-kaiser-clean-up-scratch_reg.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

For some obscure reason \scratch_reg is not including the %r while
\save_reg is.

Also-Reported-by: Borislav Petkov <bp@alien8.de>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/x86/entry/calling.h  |   10 +++++-----
 arch/x86/entry/entry_64.S |    2 +-
 2 files changed, 6 insertions(+), 6 deletions(-)

--- a/arch/x86/entry/calling.h
+++ b/arch/x86/entry/calling.h
@@ -227,8 +227,8 @@ For 32-bit we have the following convent
 
 .macro SAVE_AND_SWITCH_TO_KERNEL_CR3 scratch_reg:req save_reg:req
 	STATIC_JUMP_IF_FALSE .Ldone_\@, kaiser_enabled_key, def=1
-	movq	%cr3, %r\scratch_reg
-	movq	%r\scratch_reg, \save_reg
+	movq	%cr3, \scratch_reg
+	movq	\scratch_reg, \save_reg
 	/*
 	 * Is the "switch mask" all zero?  That means that both of
 	 * these are zero:
@@ -239,11 +239,11 @@ For 32-bit we have the following convent
 	 *
 	 * That indicates a kernel CR3 value, not user/shadow.
 	 */
-	testq	$(KAISER_SWITCH_MASK), %r\scratch_reg
+	testq	$(KAISER_SWITCH_MASK), \scratch_reg
 	jz	.Ldone_\@
 
-	ADJUST_KERNEL_CR3 %r\scratch_reg
-	movq	%r\scratch_reg, %cr3
+	ADJUST_KERNEL_CR3 \scratch_reg
+	movq	\scratch_reg, %cr3
 
 .Ldone_\@:
 .endm
--- a/arch/x86/entry/entry_64.S
+++ b/arch/x86/entry/entry_64.S
@@ -1254,7 +1254,7 @@ ENTRY(paranoid_entry)
 	xorl	%ebx, %ebx
 
 1:
-	SAVE_AND_SWITCH_TO_KERNEL_CR3 scratch_reg=ax save_reg=%r14
+	SAVE_AND_SWITCH_TO_KERNEL_CR3 scratch_reg=%rax save_reg=%r14
 
 	ret
 END(paranoid_entry)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
