Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 880A26B0006
	for <linux-mm@kvack.org>; Mon, 12 Mar 2018 06:02:59 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id e19so1384478pga.1
        for <linux-mm@kvack.org>; Mon, 12 Mar 2018 03:02:59 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id b1-v6si5700764plr.335.2018.03.12.03.02.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Mar 2018 03:02:58 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/4] x86/boot/compressed/64: Use stack from trampoline memory
Date: Mon, 12 Mar 2018 13:02:44 +0300
Message-Id: <20180312100246.89175-3-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180312100246.89175-1-kirill.shutemov@linux.intel.com>
References: <20180312100246.89175-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

As the first step on using trampoline memory, let's make 32-bit code use
stack there.

Separate stack is required to return back from trampoline and we cannot
user stack from 64-bit mode as it may be above 4G.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/boot/compressed/head_64.S | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/arch/x86/boot/compressed/head_64.S b/arch/x86/boot/compressed/head_64.S
index f0c3a2f7e528..0014459d9bcb 100644
--- a/arch/x86/boot/compressed/head_64.S
+++ b/arch/x86/boot/compressed/head_64.S
@@ -33,6 +33,7 @@
 #include <asm/processor-flags.h>
 #include <asm/asm-offsets.h>
 #include <asm/bootparam.h>
+#include "pgtable.h"
 
 /*
  * Locally defined symbols should be marked hidden:
@@ -359,6 +360,8 @@ ENTRY(startup_64)
 	pushq	%rax
 	lretq
 lvl5:
+	/* Restore the stack, the 32-bit trampoline uses its own stack */
+	leaq	boot_stack_end(%rbx), %rsp
 
 	/*
 	 * cleanup_trampoline() would restore trampoline memory.
@@ -513,6 +516,9 @@ compatible_mode:
 	movl	%eax, %ds
 	movl	%eax, %ss
 
+	/* Setup new stack */
+	leal	TRAMPOLINE_32BIT_STACK_END(%ecx), %esp
+
 	/* Disable paging */
 	movl	%cr0, %eax
 	btrl	$X86_CR0_PG_BIT, %eax
-- 
2.16.1
