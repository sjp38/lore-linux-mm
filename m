Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id AC8AA4403E5
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 16:38:49 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id v69so5620750wmd.2
        for <linux-mm@kvack.org>; Sat, 16 Dec 2017 13:38:49 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id k12si7407945wrk.28.2017.12.16.13.38.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sat, 16 Dec 2017 13:38:48 -0800 (PST)
Message-Id: <20171216213137.916155048@linutronix.de>
Date: Sat, 16 Dec 2017 22:24:12 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch V149 18/50] x86/mm: Create asm/invpcid.h
References: <20171216212354.120930222@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline; filename=0062-x86-mm-Create-asm-invpcid.h.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Rik van Riel <riel@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, daniel.gruss@iaik.tugraz.at, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org

From: Peter Zijlstra <peterz@infradead.org>

Unclutter tlbflush.h a little.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: David Laight <David.Laight@aculab.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: Eduardo Valentin <eduval@amazon.com>
Cc: Greg KH <gregkh@linuxfoundation.org>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: aliguori@amazon.com
Cc: daniel.gruss@iaik.tugraz.at
Cc: hughd@google.com
Cc: keescook@google.com
Cc: linux-mm@kvack.org
---
 arch/x86/include/asm/invpcid.h  |   53 ++++++++++++++++++++++++++++++++++++++++
 arch/x86/include/asm/tlbflush.h |   49 ------------------------------------
 2 files changed, 54 insertions(+), 48 deletions(-)

--- /dev/null
+++ b/arch/x86/include/asm/invpcid.h
@@ -0,0 +1,53 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#ifndef _ASM_X86_INVPCID
+#define _ASM_X86_INVPCID
+
+static inline void __invpcid(unsigned long pcid, unsigned long addr,
+			     unsigned long type)
+{
+	struct { u64 d[2]; } desc = { { pcid, addr } };
+
+	/*
+	 * The memory clobber is because the whole point is to invalidate
+	 * stale TLB entries and, especially if we're flushing global
+	 * mappings, we don't want the compiler to reorder any subsequent
+	 * memory accesses before the TLB flush.
+	 *
+	 * The hex opcode is invpcid (%ecx), %eax in 32-bit mode and
+	 * invpcid (%rcx), %rax in long mode.
+	 */
+	asm volatile (".byte 0x66, 0x0f, 0x38, 0x82, 0x01"
+		      : : "m" (desc), "a" (type), "c" (&desc) : "memory");
+}
+
+#define INVPCID_TYPE_INDIV_ADDR		0
+#define INVPCID_TYPE_SINGLE_CTXT	1
+#define INVPCID_TYPE_ALL_INCL_GLOBAL	2
+#define INVPCID_TYPE_ALL_NON_GLOBAL	3
+
+/* Flush all mappings for a given pcid and addr, not including globals. */
+static inline void invpcid_flush_one(unsigned long pcid,
+				     unsigned long addr)
+{
+	__invpcid(pcid, addr, INVPCID_TYPE_INDIV_ADDR);
+}
+
+/* Flush all mappings for a given PCID, not including globals. */
+static inline void invpcid_flush_single_context(unsigned long pcid)
+{
+	__invpcid(pcid, 0, INVPCID_TYPE_SINGLE_CTXT);
+}
+
+/* Flush all mappings, including globals, for all PCIDs. */
+static inline void invpcid_flush_all(void)
+{
+	__invpcid(0, 0, INVPCID_TYPE_ALL_INCL_GLOBAL);
+}
+
+/* Flush all mappings for all PCIDs except globals. */
+static inline void invpcid_flush_all_nonglobals(void)
+{
+	__invpcid(0, 0, INVPCID_TYPE_ALL_NON_GLOBAL);
+}
+
+#endif /* _ASM_X86_INVPCID */
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -9,54 +9,7 @@
 #include <asm/cpufeature.h>
 #include <asm/special_insns.h>
 #include <asm/smp.h>
-
-static inline void __invpcid(unsigned long pcid, unsigned long addr,
-			     unsigned long type)
-{
-	struct { u64 d[2]; } desc = { { pcid, addr } };
-
-	/*
-	 * The memory clobber is because the whole point is to invalidate
-	 * stale TLB entries and, especially if we're flushing global
-	 * mappings, we don't want the compiler to reorder any subsequent
-	 * memory accesses before the TLB flush.
-	 *
-	 * The hex opcode is invpcid (%ecx), %eax in 32-bit mode and
-	 * invpcid (%rcx), %rax in long mode.
-	 */
-	asm volatile (".byte 0x66, 0x0f, 0x38, 0x82, 0x01"
-		      : : "m" (desc), "a" (type), "c" (&desc) : "memory");
-}
-
-#define INVPCID_TYPE_INDIV_ADDR		0
-#define INVPCID_TYPE_SINGLE_CTXT	1
-#define INVPCID_TYPE_ALL_INCL_GLOBAL	2
-#define INVPCID_TYPE_ALL_NON_GLOBAL	3
-
-/* Flush all mappings for a given pcid and addr, not including globals. */
-static inline void invpcid_flush_one(unsigned long pcid,
-				     unsigned long addr)
-{
-	__invpcid(pcid, addr, INVPCID_TYPE_INDIV_ADDR);
-}
-
-/* Flush all mappings for a given PCID, not including globals. */
-static inline void invpcid_flush_single_context(unsigned long pcid)
-{
-	__invpcid(pcid, 0, INVPCID_TYPE_SINGLE_CTXT);
-}
-
-/* Flush all mappings, including globals, for all PCIDs. */
-static inline void invpcid_flush_all(void)
-{
-	__invpcid(0, 0, INVPCID_TYPE_ALL_INCL_GLOBAL);
-}
-
-/* Flush all mappings for all PCIDs except globals. */
-static inline void invpcid_flush_all_nonglobals(void)
-{
-	__invpcid(0, 0, INVPCID_TYPE_ALL_NON_GLOBAL);
-}
+#include <asm/invpcid.h>
 
 static inline u64 inc_mm_tlb_gen(struct mm_struct *mm)
 {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
