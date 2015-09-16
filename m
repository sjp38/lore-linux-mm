Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 681876B025D
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 13:49:26 -0400 (EDT)
Received: by padhk3 with SMTP id hk3so215096538pad.3
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 10:49:26 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id gk11si31520258pbd.34.2015.09.16.10.49.09
        for <linux-mm@kvack.org>;
        Wed, 16 Sep 2015 10:49:09 -0700 (PDT)
Subject: [PATCH 11/26] x86, pkeys: add functions for set/fetch PKRU
From: Dave Hansen <dave@sr71.net>
Date: Wed, 16 Sep 2015 10:49:06 -0700
References: <20150916174903.E112E464@viggo.jf.intel.com>
In-Reply-To: <20150916174903.E112E464@viggo.jf.intel.com>
Message-Id: <20150916174906.4F375766@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org


This adds the raw instructions to access PKRU as well as some
accessor functions that correctly handle when the CPU does
not support the instruction.  We don't use them here, but
we will use read_pkru() in the next patch.

I do not see an immediate use for write_pkru().  But, we put it
here for partity with its twin.

---

 b/arch/x86/include/asm/pgtable.h       |   15 +++++++++++++++
 b/arch/x86/include/asm/special_insns.h |   33 +++++++++++++++++++++++++++++++++
 2 files changed, 48 insertions(+)

diff -puN arch/x86/include/asm/pgtable.h~pkeys-13-kernel-pkru-instructions arch/x86/include/asm/pgtable.h
--- a/arch/x86/include/asm/pgtable.h~pkeys-13-kernel-pkru-instructions	2015-09-16 10:48:16.151187564 -0700
+++ b/arch/x86/include/asm/pgtable.h	2015-09-16 10:48:16.156187791 -0700
@@ -881,6 +881,21 @@ static inline pte_t pte_swp_clear_soft_d
 }
 #endif
 
+
+static inline u32 read_pkru(void)
+{
+	if (boot_cpu_has(X86_FEATURE_OSPKE))
+		return __read_pkru();
+	return 0;
+}
+static inline void write_pkru(u32 pkru)
+{
+	if (boot_cpu_has(X86_FEATURE_OSPKE))
+		__write_pkru(pkru);
+	else
+		VM_WARN_ON_ONCE(pkru);
+}
+
 static inline u32 pte_pkey(pte_t pte)
 {
 #ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
diff -puN arch/x86/include/asm/special_insns.h~pkeys-13-kernel-pkru-instructions arch/x86/include/asm/special_insns.h
--- a/arch/x86/include/asm/special_insns.h~pkeys-13-kernel-pkru-instructions	2015-09-16 10:48:16.152187610 -0700
+++ b/arch/x86/include/asm/special_insns.h	2015-09-16 10:48:16.156187791 -0700
@@ -98,6 +98,39 @@ static inline void native_write_cr8(unsi
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
+
+static inline void __write_pkru(u32 pkru)
+{
+        unsigned int eax = pkru;
+        unsigned int ecx = 0;
+        unsigned int edx = 0;
+
+        asm volatile(".byte 0x0f,0x01,0xef\n\t"
+                     : : "a" (eax), "c" (ecx), "d" (edx));
+}
+#else
+static inline u32 __read_pkru(void)
+{
+	return 0;
+}
+static inline void __write_pkru(u32 pkru)
+{
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
