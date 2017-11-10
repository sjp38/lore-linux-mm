Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6F369440D2B
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 14:31:56 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 76so8447623pfr.3
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 11:31:56 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id s194si1238906pgc.0.2017.11.10.11.31.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Nov 2017 11:31:55 -0800 (PST)
Subject: [PATCH 15/30] x86, kaiser: map entry stack variables
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 10 Nov 2017 11:31:30 -0800
References: <20171110193058.BECA7D88@viggo.jf.intel.com>
In-Reply-To: <20171110193058.BECA7D88@viggo.jf.intel.com>
Message-Id: <20171110193130.411328D7@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

There are times where the kernel is entered but there is not a
safe stack, like at SYSCALL entry.  To obtain a safe stack, the
per-cpu variables 'rsp_scratch' and 'cpu_current_top_of_stack'
are used to save the old %rsp value and to find where the kernel
stack should start.

You can not directly manipulate the CR3 register.  You can only
'MOV' to it from another register, which means a register must be
clobbered in order to do any CR3 manipulation.  User-mapping
these variables allows us to obtain a safe stack and use it for
temporary storage *before* CR3 is switched.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
Cc: Richard Fellner <richard.fellner@student.tugraz.at>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: x86@kernel.org
---

 b/arch/x86/kernel/cpu/common.c |    2 +-
 b/arch/x86/kernel/process_64.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff -puN arch/x86/kernel/cpu/common.c~kaiser-user-map-stack-helper-vars arch/x86/kernel/cpu/common.c
--- a/arch/x86/kernel/cpu/common.c~kaiser-user-map-stack-helper-vars	2017-11-10 11:22:13.203244939 -0800
+++ b/arch/x86/kernel/cpu/common.c	2017-11-10 11:22:13.209244939 -0800
@@ -1447,7 +1447,7 @@ DEFINE_PER_CPU_ALIGNED(struct stack_cana
  * trampoline, not the thread stack.  Use an extra percpu variable to track
  * the top of the kernel stack directly.
  */
-DEFINE_PER_CPU(unsigned long, cpu_current_top_of_stack) =
+DEFINE_PER_CPU_USER_MAPPED(unsigned long, cpu_current_top_of_stack) =
 	(unsigned long)&init_thread_union + THREAD_SIZE;
 EXPORT_PER_CPU_SYMBOL(cpu_current_top_of_stack);
 
diff -puN arch/x86/kernel/process_64.c~kaiser-user-map-stack-helper-vars arch/x86/kernel/process_64.c
--- a/arch/x86/kernel/process_64.c~kaiser-user-map-stack-helper-vars	2017-11-10 11:22:13.205244939 -0800
+++ b/arch/x86/kernel/process_64.c	2017-11-10 11:22:13.209244939 -0800
@@ -59,7 +59,7 @@
 #include <asm/unistd_32_ia32.h>
 #endif
 
-__visible DEFINE_PER_CPU(unsigned long, rsp_scratch);
+__visible DEFINE_PER_CPU_USER_MAPPED(unsigned long, rsp_scratch);
 
 /* Prints also some state that isn't saved in the pt_regs */
 void __show_regs(struct pt_regs *regs, int all)
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
