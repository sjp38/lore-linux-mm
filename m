Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id E40066B0261
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 18:15:39 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id yy13so196754090pab.3
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 15:15:39 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id xj5si66138734pab.84.2016.01.08.15.15.39
        for <linux-mm@kvack.org>;
        Fri, 08 Jan 2016 15:15:39 -0800 (PST)
From: Andy Lutomirski <luto@kernel.org>
Subject: [RFC 02/13] x86/mm: Add INVPCID helpers
Date: Fri,  8 Jan 2016 15:15:20 -0800
Message-Id: <21ffa5af2491feec9927446451e3d23548a7cbc0.1452294700.git.luto@kernel.org>
In-Reply-To: <cover.1452294700.git.luto@kernel.org>
References: <cover.1452294700.git.luto@kernel.org>
In-Reply-To: <cover.1452294700.git.luto@kernel.org>
References: <cover.1452294700.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-kernel@vger.kernel.org
Cc: Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>

This adds helpers for each of the four currently-specified INVPCID
modes.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/include/asm/tlbflush.h | 41 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)

diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index 6df2029405a3..20fc38d8478a 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -7,6 +7,47 @@
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
+	 */
+	asm volatile (
+		".byte 0x66, 0x0f, 0x38, 0x82, 0x01"	/* invpcid (%cx), %ax */
+		: : "m" (desc), "a" (type), "c" (desc) : "memory");
+}
+
+/* Flush all mappings for a given pcid and addr, not including globals. */
+static inline void invpcid_flush_one(unsigned long pcid,
+				     unsigned long addr)
+{
+	__invpcid(pcid, addr, 0);
+}
+
+/* Flush all mappings for a given PCID, not including globals. */
+static inline void invpcid_flush_single_context(unsigned long pcid)
+{
+	__invpcid(pcid, 0, 1);
+}
+
+/* Flush all mappings, including globals, for all PCIDs. */
+static inline void invpcid_flush_everything(void)
+{
+	__invpcid(0, 0, 2);
+}
+
+/* Flush all mappings for all PCIDs except globals. */
+static inline void invpcid_flush_all_nonglobals(void)
+{
+	__invpcid(0, 0, 3);
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
