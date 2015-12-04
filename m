Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id AABEF82F64
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 20:14:57 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so77839561pac.3
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 17:14:57 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id q62si15484388pfq.5.2015.12.03.17.14.44
        for <linux-mm@kvack.org>;
        Thu, 03 Dec 2015 17:14:44 -0800 (PST)
Subject: [PATCH 14/34] x86, pkeys: add functions to fetch PKRU
From: Dave Hansen <dave@sr71.net>
Date: Thu, 03 Dec 2015 17:14:44 -0800
References: <20151204011424.8A36E365@viggo.jf.intel.com>
In-Reply-To: <20151204011424.8A36E365@viggo.jf.intel.com>
Message-Id: <20151204011444.526641BA@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

This adds the raw instruction to access PKRU as well as some
accessor functions that correctly handle when the CPU does not
support the instruction.  We don't use it here, but we will use
read_pkru() in the next patch.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/arch/x86/include/asm/pgtable.h       |    8 ++++++++
 b/arch/x86/include/asm/special_insns.h |   22 ++++++++++++++++++++++
 2 files changed, 30 insertions(+)

diff -puN arch/x86/include/asm/pgtable.h~pkeys-13-kernel-pkru-instructions arch/x86/include/asm/pgtable.h
--- a/arch/x86/include/asm/pgtable.h~pkeys-13-kernel-pkru-instructions	2015-12-03 16:21:24.298611081 -0800
+++ b/arch/x86/include/asm/pgtable.h	2015-12-03 16:21:24.303611308 -0800
@@ -102,6 +102,14 @@ static inline int pte_dirty(pte_t pte)
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
diff -puN arch/x86/include/asm/special_insns.h~pkeys-13-kernel-pkru-instructions arch/x86/include/asm/special_insns.h
--- a/arch/x86/include/asm/special_insns.h~pkeys-13-kernel-pkru-instructions	2015-12-03 16:21:24.300611172 -0800
+++ b/arch/x86/include/asm/special_insns.h	2015-12-03 16:21:24.303611308 -0800
@@ -98,6 +98,28 @@ static inline void native_write_cr8(unsi
 }
 #endif
 
+#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
+static inline u32 __read_pkru(void)
+{
+	unsigned int ecx = 0;
+	unsigned int edx, pkru;
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
