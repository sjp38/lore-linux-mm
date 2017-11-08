Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id AF2916B02F5
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 14:47:28 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id g75so3033335pfg.4
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 11:47:28 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id i15si4807427pgv.60.2017.11.08.11.47.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Nov 2017 11:47:27 -0800 (PST)
Subject: [PATCH 14/30] x86, kaiser: map espfix structures
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 08 Nov 2017 11:47:11 -0800
References: <20171108194646.907A1942@viggo.jf.intel.com>
In-Reply-To: <20171108194646.907A1942@viggo.jf.intel.com>
Message-Id: <20171108194711.7939CA37@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

We have some rather arcane code to help when we IRET to 16-bit
segments: the "espfix" code.  This consists of a few per-cpu
variables:

	espfix_stack: tells us where we allocated the stack
	  	      (the bottom)
	espfix_waddr: tells us where we can actually point %rsp

and the stack itself.  We need all three things mapped for this
to work.

Note: the espfix code runs with a kernel GSBASE, but user
(shadow) page tables.  We could switch to the kernel page tables
here and then not have to map any of this, but just
user-pagetable-mapping is simpler.  To switch over to the kernel
copy, we would need some temporary storage which is in short
supply at this point.

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
--- a/arch/x86/kernel/espfix_64.c~kaiser-user-map-espfix	2017-11-08 10:45:33.465681385 -0800
+++ b/arch/x86/kernel/espfix_64.c	2017-11-08 10:45:33.469681385 -0800
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
