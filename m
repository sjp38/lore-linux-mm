Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 36493440D2B
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 14:31:49 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id b79so8407836pfk.9
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 11:31:49 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id 17si9813985pfk.175.2017.11.10.11.31.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Nov 2017 11:31:48 -0800 (PST)
Subject: [PATCH 14/30] x86, kaiser: map espfix structures
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 10 Nov 2017 11:31:29 -0800
References: <20171110193058.BECA7D88@viggo.jf.intel.com>
In-Reply-To: <20171110193058.BECA7D88@viggo.jf.intel.com>
Message-Id: <20171110193128.14219F08@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

There is some rather arcane code to help when an IRET returns
to 16-bit segments.  It is referred to as the "espfix" code.
This consists of a few per-cpu variables:

	espfix_stack: tells us where the stack is allocated
	  	      (the bottom)
	espfix_waddr: tells us to where %rsp may be pointed
		      (the top)

These are in addition to the stack itself.  All three things must
be mapped for the espfix code to function.

Note: the espfix code runs with a kernel GSBASE, but user
(shadow) page tables.  A switch to the kernel page tables could
be performed instead of mapping these structures, but mapping
them is simpler and less likely to break the assembly.  To switch
over to the kernel copy, additional temporary storage would be
required which is in short supply in this context.

The original KAISER patch missed this case.

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

 b/arch/x86/kernel/espfix_64.c |   12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff -puN arch/x86/kernel/espfix_64.c~kaiser-user-map-espfix arch/x86/kernel/espfix_64.c
--- a/arch/x86/kernel/espfix_64.c~kaiser-user-map-espfix	2017-11-10 11:22:12.669244941 -0800
+++ b/arch/x86/kernel/espfix_64.c	2017-11-10 11:22:12.673244941 -0800
@@ -33,6 +33,7 @@
 
 #include <linux/init.h>
 #include <linux/init_task.h>
+#include <linux/kaiser.h>
 #include <linux/kernel.h>
 #include <linux/percpu.h>
 #include <linux/gfp.h>
@@ -41,7 +42,6 @@
 #include <asm/pgalloc.h>
 #include <asm/setup.h>
 #include <asm/espfix.h>
-#include <asm/kaiser.h>
 
 /*
  * Note: we only need 6*8 = 48 bytes for the espfix stack, but round
@@ -61,8 +61,8 @@
 #define PGALLOC_GFP (GFP_KERNEL | __GFP_NOTRACK | __GFP_ZERO)
 
 /* This contains the *bottom* address of the espfix stack */
-DEFINE_PER_CPU_READ_MOSTLY(unsigned long, espfix_stack);
-DEFINE_PER_CPU_READ_MOSTLY(unsigned long, espfix_waddr);
+DEFINE_PER_CPU_USER_MAPPED(unsigned long, espfix_stack);
+DEFINE_PER_CPU_USER_MAPPED(unsigned long, espfix_waddr);
 
 /* Initialization mutex - should this be a spinlock? */
 static DEFINE_MUTEX(espfix_init_mutex);
@@ -225,4 +225,10 @@ done:
 	per_cpu(espfix_stack, cpu) = addr;
 	per_cpu(espfix_waddr, cpu) = (unsigned long)stack_page
 				      + (addr & ~PAGE_MASK);
+	/*
+	 * _PAGE_GLOBAL is not really required.  This is not a hot
+	 * path, but we do it here for consistency.
+	 */
+	kaiser_add_mapping((unsigned long)stack_page, PAGE_SIZE,
+			__PAGE_KERNEL | _PAGE_GLOBAL);
 }
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
