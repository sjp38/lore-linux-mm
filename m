Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 5B855828DF
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 13:17:19 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id n128so45582738pfn.3
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 10:17:19 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id we3si3530534pab.52.2016.01.29.10.17.02
        for <linux-mm@kvack.org>;
        Fri, 29 Jan 2016 10:17:03 -0800 (PST)
Subject: [PATCH 14/31] x86, pkeys: add functions to fetch PKRU
From: Dave Hansen <dave@sr71.net>
Date: Fri, 29 Jan 2016 10:17:02 -0800
References: <20160129181642.98E7D468@viggo.jf.intel.com>
In-Reply-To: <20160129181642.98E7D468@viggo.jf.intel.com>
Message-Id: <20160129181702.70523C9C@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

This adds the raw instruction to access PKRU as well as some
accessor functions that correctly handle when the CPU does not
support the instruction.  We don't use it here, but we will use
read_pkru() in the next patch.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
---

 b/arch/x86/include/asm/pgtable.h       |    8 ++++++++
 b/arch/x86/include/asm/special_insns.h |   22 ++++++++++++++++++++++
 2 files changed, 30 insertions(+)

diff -puN arch/x86/include/asm/pgtable.h~pkeys-10-kernel-pkru-instructions arch/x86/include/asm/pgtable.h
--- a/arch/x86/include/asm/pgtable.h~pkeys-10-kernel-pkru-instructions	2016-01-28 15:52:22.425498599 -0800
+++ b/arch/x86/include/asm/pgtable.h	2016-01-28 15:52:22.430498828 -0800
@@ -99,6 +99,14 @@ static inline int pte_dirty(pte_t pte)
 	return pte_flags(pte) & _PAGE_DIRTY;
 }
 
+
+static inline u32 read_pkru(void)
+{
+	if (boot_cpu_has(X86_FEATURE_OSPKE))
+		return __read_pkru();
+	return 0;
+}
+
 static inline int pte_young(pte_t pte)
 {
 	return pte_flags(pte) & _PAGE_ACCESSED;
diff -puN arch/x86/include/asm/special_insns.h~pkeys-10-kernel-pkru-instructions arch/x86/include/asm/special_insns.h
--- a/arch/x86/include/asm/special_insns.h~pkeys-10-kernel-pkru-instructions	2016-01-28 15:52:22.427498691 -0800
+++ b/arch/x86/include/asm/special_insns.h	2016-01-28 15:52:22.431498874 -0800
@@ -98,6 +98,28 @@ static inline void native_write_cr8(unsi
 }
 #endif
 
+#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
+static inline u32 __read_pkru(void)
+{
+	u32 ecx = 0;
+	u32 edx, pkru;
+
+	/*
+	 * "rdpkru" instruction.  Places PKRU contents in to EAX,
+	 * clears EDX and requires that ecx=0.
+	 */
+	asm volatile(".byte 0x0f,0x01,0xee\n\t"
+		     : "=a" (pkru), "=d" (edx)
+		     : "c" (ecx));
+	return pkru;
+}
+#else
+static inline u32 __read_pkru(void)
+{
+	return 0;
+}
+#endif
+
 static inline void native_wbinvd(void)
 {
 	asm volatile("wbinvd": : :"memory");
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
