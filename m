Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id AF8A76B0264
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 15:18:33 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so85258257pab.3
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 12:18:33 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id qo8si14118536pac.117.2015.09.28.12.18.22
        for <linux-mm@kvack.org>;
        Mon, 28 Sep 2015 12:18:23 -0700 (PDT)
Subject: [PATCH 12/25] x86, pkeys: add functions to fetch PKRU
From: Dave Hansen <dave@sr71.net>
Date: Mon, 28 Sep 2015 12:18:22 -0700
References: <20150928191817.035A64E2@viggo.jf.intel.com>
In-Reply-To: <20150928191817.035A64E2@viggo.jf.intel.com>
Message-Id: <20150928191822.9FFCB461@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: borntraeger@de.ibm.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org


From: Dave Hansen <dave.hansen@linux.intel.com>

This adds the raw instruction to access PKRU as well as some
accessor functions that correctly handle when the CPU does not
support the instruction.  We don't use it here, but we will use
read_pkru() in the next patch.

eigned-off-by: Dave Hansen <dave.hansen@linux.intel.com>

---

 b/arch/x86/include/asm/pgtable.h       |    8 ++++++++
 b/arch/x86/include/asm/special_insns.h |   20 ++++++++++++++++++++
 2 files changed, 28 insertions(+)

diff -puN arch/x86/include/asm/pgtable.h~pkeys-13-kernel-pkru-instructions arch/x86/include/asm/pgtable.h
--- a/arch/x86/include/asm/pgtable.h~pkeys-13-kernel-pkru-instructions	2015-09-28 11:39:46.356201421 -0700
+++ b/arch/x86/include/asm/pgtable.h	2015-09-28 11:39:46.361201648 -0700
@@ -95,6 +95,14 @@ static inline int pte_dirty(pte_t pte)
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
--- a/arch/x86/include/asm/special_insns.h~pkeys-13-kernel-pkru-instructions	2015-09-28 11:39:46.357201466 -0700
+++ b/arch/x86/include/asm/special_insns.h	2015-09-28 11:39:46.361201648 -0700
@@ -98,6 +98,26 @@ static inline void native_write_cr8(unsi
 }
 #endif
 
+#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
+static inline u32 __read_pkru(void)
+{
+        unsigned int eax, edx;
+        unsigned int ecx = 0;
+        unsigned int pkru;
+
+        asm volatile(".byte 0x0f,0x01,0xee\n\t"
+                     : "=a" (eax), "=d" (edx)
+                     : "c" (ecx));
+        pkru = eax;
+        return pkru;
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
