Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id DF1986B027B
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 19:36:06 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id 62so37518plc.6
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:36:06 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id b6si1365002pgt.534.2017.11.22.16.36.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 16:36:05 -0800 (PST)
Subject: [PATCH 11/23] x86, kaiser: map entry stack variables
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 22 Nov 2017 16:34:59 -0800
References: <20171123003438.48A0EEDE@viggo.jf.intel.com>
In-Reply-To: <20171123003438.48A0EEDE@viggo.jf.intel.com>
Message-Id: <20171123003459.C0FF167A@viggo.jf.intel.com>
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
--- a/arch/x86/kernel/cpu/common.c~kaiser-user-map-stack-helper-vars	2017-11-22 15:45:50.128619736 -0800
+++ b/arch/x86/kernel/cpu/common.c	2017-11-22 15:45:50.134619736 -0800
@@ -1524,7 +1524,7 @@ EXPORT_PER_CPU_SYMBOL(__preempt_count);
  * the top of the kernel stack.  Use an extra percpu variable to track the
  * top of the kernel stack directly.
  */
-DEFINE_PER_CPU(unsigned long, cpu_current_top_of_stack) =
+DEFINE_PER_CPU_USER_MAPPED(unsigned long, cpu_current_top_of_stack) =
 	(unsigned long)&init_thread_union + THREAD_SIZE;
 EXPORT_PER_CPU_SYMBOL(cpu_current_top_of_stack);
 
diff -puN arch/x86/kernel/process_64.c~kaiser-user-map-stack-helper-vars arch/x86/kernel/process_64.c
--- a/arch/x86/kernel/process_64.c~kaiser-user-map-stack-helper-vars	2017-11-22 15:45:50.130619736 -0800
+++ b/arch/x86/kernel/process_64.c	2017-11-22 15:45:50.134619736 -0800
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
