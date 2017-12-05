Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7A3B06B025E
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 07:41:31 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id g69so783097ita.9
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 04:41:31 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id l73si204531itl.132.2017.12.05.04.41.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 04:41:30 -0800 (PST)
Message-Id: <20171205123819.985685386@infradead.org>
Date: Tue, 05 Dec 2017 13:34:47 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH 2/9] x86/mm: Create asm/invpcid.h
References: <20171205123444.990868007@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=peterz-move-invpcid.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Rik van Riel <riel@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, daniel.gruss@iaik.tugraz.at, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, moritz.lipp@iaik.tugraz.at, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at

Unclutter tlbflush.h a little.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
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
@@ -11,54 +11,7 @@
 #include <asm/smp.h>
 #include <asm/kpti.h>
 #include <asm/processor-flags.h>
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
