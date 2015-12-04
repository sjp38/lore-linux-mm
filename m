Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 544196B025A
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 20:14:43 -0500 (EST)
Received: by pfdd184 with SMTP id d184so17256306pfd.3
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 17:14:43 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id b1si15412861pat.193.2015.12.03.17.14.35
        for <linux-mm@kvack.org>;
        Thu, 03 Dec 2015 17:14:35 -0800 (PST)
Subject: [PATCH 07/34] x86, pkeys: PTE bits for storing protection key
From: Dave Hansen <dave@sr71.net>
Date: Thu, 03 Dec 2015 17:14:34 -0800
References: <20151204011424.8A36E365@viggo.jf.intel.com>
In-Reply-To: <20151204011424.8A36E365@viggo.jf.intel.com>
Message-Id: <20151204011434.CB5FDF0F@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

Previous documentation has referred to these 4 bits as "ignored".
That means that software could have made use of them.  But, as
far as I know, the kernel never used them.

They are still ignored when protection keys is not enabled, so
they could theoretically still get used for software purposes.

We also implement "empty" versions so that code that references
to them can be optimized away by the compiler when the config
option is not enabled.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
---

 b/arch/x86/include/asm/pgtable_types.h |   17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff -puN arch/x86/include/asm/pgtable_types.h~pkeys-04-ptebits arch/x86/include/asm/pgtable_types.h
--- a/arch/x86/include/asm/pgtable_types.h~pkeys-04-ptebits	2015-12-03 16:21:21.207470895 -0800
+++ b/arch/x86/include/asm/pgtable_types.h	2015-12-03 16:21:21.211471076 -0800
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
