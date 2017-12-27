Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 52DC26B0271
	for <linux-mm@kvack.org>; Wed, 27 Dec 2017 11:48:40 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id n126so8713656wma.7
        for <linux-mm@kvack.org>; Wed, 27 Dec 2017 08:48:40 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m203si14088110wmd.252.2017.12.27.08.48.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Dec 2017 08:48:39 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.14 28/74] x86/mm: Create asm/invpcid.h
Date: Wed, 27 Dec 2017 17:46:01 +0100
Message-Id: <20171227164615.223499127@linuxfoundation.org>
In-Reply-To: <20171227164614.109898944@linuxfoundation.org>
References: <20171227164614.109898944@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

4.14-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Peter Zijlstra <peterz@infradead.org>

commit 1a3b0caeb77edeac5ce5fa05e6a61c474c9a9745 upstream.

Unclutter tlbflush.h a little.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
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
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Will Deacon <will.deacon@arm.com>
Cc: aliguori@amazon.com
Cc: daniel.gruss@iaik.tugraz.at
Cc: hughd@google.com
Cc: keescook@google.com
Cc: linux-mm@kvack.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

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
