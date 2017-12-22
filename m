Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id D61476B0038
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 03:50:26 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id f4so16251900wre.9
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 00:50:26 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b48si11616231wrb.47.2017.12.22.00.50.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Dec 2017 00:50:25 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.4 03/78] x86/mm: Add INVPCID helpers
Date: Fri, 22 Dec 2017 09:45:44 +0100
Message-Id: <20171222084557.244913465@linuxfoundation.org>
In-Reply-To: <20171222084556.909780563@linuxfoundation.org>
References: <20171222084556.909780563@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Luis R. Rodriguez" <mcgrof@suse.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Toshi Kani <toshi.kani@hp.com>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

4.4-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Andy Lutomirski <luto@kernel.org>

commit 060a402a1ddb551455ee410de2eadd3349f2801b upstream.

This adds helpers for each of the four currently-specified INVPCID
modes.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
Reviewed-by: Borislav Petkov <bp@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Toshi Kani <toshi.kani@hp.com>
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/8a62b23ad686888cee01da134c91409e22064db9.1454096309.git.luto@kernel.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 arch/x86/include/asm/tlbflush.h |   48 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 48 insertions(+)

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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
