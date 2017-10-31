Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 22D986B0271
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 18:32:12 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e64so405578pfk.0
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 15:32:12 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id n62si2718422pfh.229.2017.10.31.15.32.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 15:32:11 -0700 (PDT)
Subject: [PATCH 13/23] x86, kaiser: map espfix structures
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Tue, 31 Oct 2017 15:32:09 -0700
References: <20171031223146.6B47C861@viggo.jf.intel.com>
In-Reply-To: <20171031223146.6B47C861@viggo.jf.intel.com>
Message-Id: <20171031223209.5AB995C7@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


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
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: x86@kernel.org
---

 b/arch/x86/kernel/espfix_64.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff -puN arch/x86/kernel/espfix_64.c~kaiser-user-map-espfix arch/x86/kernel/espfix_64.c
--- a/arch/x86/kernel/espfix_64.c~kaiser-user-map-espfix	2017-10-31 15:03:55.601361577 -0700
+++ b/arch/x86/kernel/espfix_64.c	2017-10-31 15:03:55.605361766 -0700
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
@@ -225,4 +225,5 @@ done:
 	per_cpu(espfix_stack, cpu) = addr;
 	per_cpu(espfix_waddr, cpu) = (unsigned long)stack_page
 				      + (addr & ~PAGE_MASK);
+	kaiser_add_mapping((unsigned long)stack_page, PAGE_SIZE, __PAGE_KERNEL);
 }
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
