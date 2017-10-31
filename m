Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id F40C16B0272
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 18:32:13 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id r25so415776pgn.23
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 15:32:13 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id q22si2716380pfk.572.2017.10.31.15.32.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 15:32:12 -0700 (PDT)
Subject: [PATCH 14/23] x86, kaiser: map entry stack variables
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Tue, 31 Oct 2017 15:32:11 -0700
References: <20171031223146.6B47C861@viggo.jf.intel.com>
In-Reply-To: <20171031223146.6B47C861@viggo.jf.intel.com>
Message-Id: <20171031223211.314156CE@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


There are times that we enter the kernel and do not have a safe
stack, like at SYSCALL entry.  We use the per-cpu vairables
'rsp_scratch' and 'cpu_current_top_of_stack' to save off the old
%rsp and find a safe place to have a stack.

You can not directly manipulate the CR3 register.  You can only
'MOV' to it from another register, which means we need to clobber
a register in order to do any CR3 manipulation.  User-mapping these
variables allows us to obtain a safe stack *before* we switch the
CR3 value.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
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
--- a/arch/x86/kernel/cpu/common.c~kaiser-user-map-stack-helper-vars	2017-10-31 15:03:56.168388378 -0700
+++ b/arch/x86/kernel/cpu/common.c	2017-10-31 15:03:56.175388709 -0700
@@ -1440,7 +1440,7 @@ EXPORT_PER_CPU_SYMBOL(__preempt_count);
  * the top of the kernel stack.  Use an extra percpu variable to track the
  * top of the kernel stack directly.
  */
-DEFINE_PER_CPU(unsigned long, cpu_current_top_of_stack) =
+DEFINE_PER_CPU_USER_MAPPED(unsigned long, cpu_current_top_of_stack) =
 	(unsigned long)&init_thread_union + THREAD_SIZE;
 EXPORT_PER_CPU_SYMBOL(cpu_current_top_of_stack);
 
diff -puN arch/x86/kernel/process_64.c~kaiser-user-map-stack-helper-vars arch/x86/kernel/process_64.c
--- a/arch/x86/kernel/process_64.c~kaiser-user-map-stack-helper-vars	2017-10-31 15:03:56.170388472 -0700
+++ b/arch/x86/kernel/process_64.c	2017-10-31 15:03:56.176388756 -0700
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
