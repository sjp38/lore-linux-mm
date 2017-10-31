Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 744206B0272
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 18:32:15 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id y5so431042pgq.15
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 15:32:15 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id u5si2565026pgn.73.2017.10.31.15.32.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 15:32:14 -0700 (PDT)
Subject: [PATCH 15/23] x86, kaiser: map trace interrupt entry
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Tue, 31 Oct 2017 15:32:13 -0700
References: <20171031223146.6B47C861@viggo.jf.intel.com>
In-Reply-To: <20171031223146.6B47C861@viggo.jf.intel.com>
Message-Id: <20171031223213.BC519F99@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


We put all of the interrupt entry/exit code into a special
section (.irqentry.text).  This enables the ftrace code to figure
out when we are in a "grey area" of interrupt handling before the
C code has taken over and marked the data structures that we are
in an interrupt.

KAISER needs to map this section into the user page tables
because it contains the assembly that helps us enter interrupt
routines.  In addition to the assembly which KAISER *needs*, the
section also contains the first C function that handles an
interrupt.  This is unfortunate, but it doesn't really hurt
anything.

This patch also aligns the .entry.text and .irqentry.text.  This
ensures that we KAISER-map the section we want and *only* the
section we want.  Otherwise, we might pull in extra code that
should be explicitly KAISER-mapped, but just happened to get
pulled in with something that shared the same page.  That also
generally does not hurt anything, but it can make things hard
to debug because random build alignment can cause things to
fail.

This was missed in the original KAISER patch.

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

 b/arch/x86/mm/kaiser.c              |   14 ++++++++++++++
 b/include/asm-generic/vmlinux.lds.h |   10 ++++++++++
 2 files changed, 24 insertions(+)

diff -puN arch/x86/mm/kaiser.c~kaiser-user-map-trace-irqentry_text arch/x86/mm/kaiser.c
--- a/arch/x86/mm/kaiser.c~kaiser-user-map-trace-irqentry_text	2017-10-31 15:03:56.764416549 -0700
+++ b/arch/x86/mm/kaiser.c	2017-10-31 15:03:56.770416832 -0700
@@ -19,6 +19,7 @@
 #include <linux/types.h>
 #include <linux/bug.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/spinlock.h>
 #include <linux/mm.h>
 #include <linux/uaccess.h>
@@ -339,6 +340,19 @@ void __init kaiser_init(void)
 	 */
 	kaiser_add_user_map_early(get_cpu_gdt_ro(0), PAGE_SIZE,
 				  __PAGE_KERNEL_RO);
+
+	/*
+	 * .irqentry.text helps us identify code that runs before
+	 * we get a chance to call entering_irq().  This includes
+	 * the interrupt entry assembly plus the first C function
+	 * that gets called.  KAISER does not need the C code
+	 * mapped.  We just use the .irqentry.text section as-is
+	 * to avoid having to carve out a new section for the
+	 * assembly only.
+	 */
+	kaiser_add_user_map_ptrs_early(__irqentry_text_start,
+				       __irqentry_text_end,
+				       __PAGE_KERNEL_RX);
 }
 
 int kaiser_add_mapping(unsigned long addr, unsigned long size,
diff -puN include/asm-generic/vmlinux.lds.h~kaiser-user-map-trace-irqentry_text include/asm-generic/vmlinux.lds.h
--- a/include/asm-generic/vmlinux.lds.h~kaiser-user-map-trace-irqentry_text	2017-10-31 15:03:56.766416643 -0700
+++ b/include/asm-generic/vmlinux.lds.h	2017-10-31 15:03:56.772416927 -0700
@@ -59,6 +59,12 @@
 /* Align . to a 8 byte boundary equals to maximum function alignment. */
 #define ALIGN_FUNCTION()  . = ALIGN(8)
 
+#ifdef CONFIG_KAISER
+#define ALIGN_KAISER()	. = ALIGN(PAGE_SIZE);
+#else
+#define ALIGN_KAISER()
+#endif
+
 /*
  * LD_DEAD_CODE_DATA_ELIMINATION option enables -fdata-sections, which
  * generates .data.identifier sections, which need to be pulled in with
@@ -493,15 +499,19 @@
 		VMLINUX_SYMBOL(__kprobes_text_end) = .;
 
 #define ENTRY_TEXT							\
+		ALIGN_KAISER();						\
 		ALIGN_FUNCTION();					\
 		VMLINUX_SYMBOL(__entry_text_start) = .;			\
 		*(.entry.text)						\
+		ALIGN_KAISER();						\
 		VMLINUX_SYMBOL(__entry_text_end) = .;
 
 #define IRQENTRY_TEXT							\
+		ALIGN_KAISER();						\
 		ALIGN_FUNCTION();					\
 		VMLINUX_SYMBOL(__irqentry_text_start) = .;		\
 		*(.irqentry.text)					\
+		ALIGN_KAISER();						\
 		VMLINUX_SYMBOL(__irqentry_text_end) = .;
 
 #define SOFTIRQENTRY_TEXT						\
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
