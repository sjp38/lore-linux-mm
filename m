Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 4B9446B025C
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 14:43:05 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id 65so46914237pfd.2
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 11:43:05 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id r19si26023708pfi.140.2016.01.29.11.43.04
        for <linux-mm@kvack.org>;
        Fri, 29 Jan 2016 11:43:04 -0800 (PST)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v3 1/3] x86/mm: Add INVPCID helpers
Date: Fri, 29 Jan 2016 11:42:57 -0800
Message-Id: <8a62b23ad686888cee01da134c91409e22064db9.1454096309.git.luto@kernel.org>
In-Reply-To: <cover.1454096309.git.luto@kernel.org>
References: <cover.1454096309.git.luto@kernel.org>
In-Reply-To: <cover.1454096309.git.luto@kernel.org>
References: <cover.1454096309.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-kernel@vger.kernel.org
Cc: Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andy Lutomirski <luto@kernel.org>

This adds helpers for each of the four currently-specified INVPCID
modes.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/include/asm/tlbflush.h | 48 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 48 insertions(+)

diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index 6df2029405a3..8b576832777e 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -7,6 +7,54 @@
 #include <asm/processor.h>
 #include <asm/special_insns.h>
 
+static inline void __invpcid(unsigned long pcid, unsigned long addr,
+			     unsigned long type)
+{
+	u64 desc[2] = { pcid, addr };
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
+		      : : "m" (desc), "a" (type), "c" (desc) : "memory");
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
 #ifdef CONFIG_PARAVIRT
 #include <asm/paravirt.h>
 #else
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
