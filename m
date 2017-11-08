Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id DF23F6B02F6
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 14:47:29 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id m18so3544477pgd.13
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 11:47:29 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id u196si4451654pgc.643.2017.11.08.11.47.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Nov 2017 11:47:28 -0800 (PST)
Subject: [PATCH 16/30] x86, kaiser: map trace interrupt entry
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 08 Nov 2017 11:47:17 -0800
References: <20171108194646.907A1942@viggo.jf.intel.com>
In-Reply-To: <20171108194646.907A1942@viggo.jf.intel.com>
Message-Id: <20171108194717.148CC613@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

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
Cc: Richard Fellner <richard.fellner@student.tugraz.at>
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
--- a/arch/x86/mm/kaiser.c~kaiser-user-map-trace-irqentry_text	2017-11-08 10:45:34.557681382 -0800
+++ b/arch/x86/mm/kaiser.c	2017-11-08 10:45:34.562681382 -0800
@@ -19,6 +19,7 @@
 #include <linux/types.h>
 #include <linux/bug.h>
 #include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/spinlock.h>
 #include <linux/mm.h>
 #include <linux/uaccess.h>
@@ -371,6 +372,19 @@ void __init kaiser_init(void)
 	 */
 	kaiser_add_user_map_early(get_cpu_gdt_ro(0), PAGE_SIZE,
 				  __PAGE_KERNEL_RO | _PAGE_GLOBAL);
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
+				       __PAGE_KERNEL_RX | _PAGE_GLOBAL);
 }
 
 int kaiser_add_mapping(unsigned long addr, unsigned long size,
diff -puN include/asm-generic/vmlinux.lds.h~kaiser-user-map-trace-irqentry_text include/asm-generic/vmlinux.lds.h
--- a/include/asm-generic/vmlinux.lds.h~kaiser-user-map-trace-irqentry_text	2017-11-08 10:45:34.559681382 -0800
+++ b/include/asm-generic/vmlinux.lds.h	2017-11-08 10:45:34.563681382 -0800
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
