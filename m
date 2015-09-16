Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 660CC6B0265
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 13:50:48 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so219560111pac.2
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 10:50:48 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id lg2si42353578pbc.60.2015.09.16.10.50.47
        for <linux-mm@kvack.org>;
        Wed, 16 Sep 2015 10:50:47 -0700 (PDT)
Subject: [PATCH 06/26] x86, pkeys: PTE bits for storing protection key
From: Dave Hansen <dave@sr71.net>
Date: Wed, 16 Sep 2015 10:49:05 -0700
References: <20150916174903.E112E464@viggo.jf.intel.com>
In-Reply-To: <20150916174903.E112E464@viggo.jf.intel.com>
Message-Id: <20150916174905.4DDDE8FF@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org


Previous documentation has referred to these 4 bits as "ignored".
That means that software could have made use of them.  But, as
far as I know, the kernel never used them.

They are still ignored when protection keys is not enabled, so
they could theoretically still get used for software purposes.

We also implement "empty" versions so that code that references
to them can be optimized away by the compiler when the config
option is not enabled.

---

 b/arch/x86/include/asm/pgtable_types.h |   17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff -puN arch/x86/include/asm/pgtable_types.h~pkeys-04-ptebits arch/x86/include/asm/pgtable_types.h
--- a/arch/x86/include/asm/pgtable_types.h~pkeys-04-ptebits	2015-09-16 10:48:13.805081207 -0700
+++ b/arch/x86/include/asm/pgtable_types.h	2015-09-16 10:48:13.809081388 -0700
@@ -25,7 +25,11 @@
 #define _PAGE_BIT_SPLITTING	_PAGE_BIT_SOFTW2 /* only valid on a PSE pmd */
 #define _PAGE_BIT_HIDDEN	_PAGE_BIT_SOFTW3 /* hidden by kmemcheck */
 #define _PAGE_BIT_SOFT_DIRTY	_PAGE_BIT_SOFTW3 /* software dirty tracking */
-#define _PAGE_BIT_NX           63       /* No execute: only valid after cpuid check */
+#define _PAGE_BIT_PKEY_BIT0	59       /* Protection Keys, bit 1/4 */
+#define _PAGE_BIT_PKEY_BIT1	60       /* Protection Keys, bit 2/4 */
+#define _PAGE_BIT_PKEY_BIT2	61       /* Protection Keys, bit 3/4 */
+#define _PAGE_BIT_PKEY_BIT3	62       /* Protection Keys, bit 4/4 */
+#define _PAGE_BIT_NX		63       /* No execute: only valid after cpuid check */
 
 /* If _PAGE_BIT_PRESENT is clear, we use these: */
 /* - if the user mapped it with PROT_NONE; pte_present gives true */
@@ -47,6 +51,17 @@
 #define _PAGE_SPECIAL	(_AT(pteval_t, 1) << _PAGE_BIT_SPECIAL)
 #define _PAGE_CPA_TEST	(_AT(pteval_t, 1) << _PAGE_BIT_CPA_TEST)
 #define _PAGE_SPLITTING	(_AT(pteval_t, 1) << _PAGE_BIT_SPLITTING)
+#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
+#define _PAGE_PKEY_BIT0	(_AT(pteval_t, 1) << _PAGE_BIT_PKEY_BIT0)
+#define _PAGE_PKEY_BIT1	(_AT(pteval_t, 1) << _PAGE_BIT_PKEY_BIT1)
+#define _PAGE_PKEY_BIT2	(_AT(pteval_t, 1) << _PAGE_BIT_PKEY_BIT2)
+#define _PAGE_PKEY_BIT3	(_AT(pteval_t, 1) << _PAGE_BIT_PKEY_BIT3)
+#else
+#define _PAGE_PKEY_BIT0	(_AT(pteval_t, 0))
+#define _PAGE_PKEY_BIT1	(_AT(pteval_t, 0))
+#define _PAGE_PKEY_BIT2	(_AT(pteval_t, 0))
+#define _PAGE_PKEY_BIT3	(_AT(pteval_t, 0))
+#endif
 #define __HAVE_ARCH_PTE_SPECIAL
 
 #ifdef CONFIG_KMEMCHECK
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
