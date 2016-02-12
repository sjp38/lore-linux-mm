Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 03115828F3
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 16:02:49 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id fy10so12784740pac.1
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 13:02:48 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id sm4si22146491pac.245.2016.02.12.13.02.35
        for <linux-mm@kvack.org>;
        Fri, 12 Feb 2016 13:02:35 -0800 (PST)
Subject: [PATCH 09/33] x86, pkeys: PTE bits for storing protection key
From: Dave Hansen <dave@sr71.net>
Date: Fri, 12 Feb 2016 13:02:05 -0800
References: <20160212210152.9CAD15B0@viggo.jf.intel.com>
In-Reply-To: <20160212210152.9CAD15B0@viggo.jf.intel.com>
Message-Id: <20160212210205.81E33ED6@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


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

 b/arch/x86/include/asm/pgtable_types.h |   22 +++++++++++++++++++---
 1 file changed, 19 insertions(+), 3 deletions(-)

diff -puN arch/x86/include/asm/pgtable_types.h~pkeys-04-ptebits arch/x86/include/asm/pgtable_types.h
--- a/arch/x86/include/asm/pgtable_types.h~pkeys-04-ptebits	2016-02-12 10:44:17.672312467 -0800
+++ b/arch/x86/include/asm/pgtable_types.h	2016-02-12 10:44:17.675312604 -0800
@@ -20,13 +20,18 @@
 #define _PAGE_BIT_SOFTW2	10	/* " */
 #define _PAGE_BIT_SOFTW3	11	/* " */
 #define _PAGE_BIT_PAT_LARGE	12	/* On 2MB or 1GB pages */
+#define _PAGE_BIT_SOFTW4	58	/* available for programmer */
+#define _PAGE_BIT_PKEY_BIT0	59	/* Protection Keys, bit 1/4 */
+#define _PAGE_BIT_PKEY_BIT1	60	/* Protection Keys, bit 2/4 */
+#define _PAGE_BIT_PKEY_BIT2	61	/* Protection Keys, bit 3/4 */
+#define _PAGE_BIT_PKEY_BIT3	62	/* Protection Keys, bit 4/4 */
+#define _PAGE_BIT_NX		63	/* No execute: only valid after cpuid check */
+
 #define _PAGE_BIT_SPECIAL	_PAGE_BIT_SOFTW1
 #define _PAGE_BIT_CPA_TEST	_PAGE_BIT_SOFTW1
 #define _PAGE_BIT_HIDDEN	_PAGE_BIT_SOFTW3 /* hidden by kmemcheck */
 #define _PAGE_BIT_SOFT_DIRTY	_PAGE_BIT_SOFTW3 /* software dirty tracking */
-#define _PAGE_BIT_SOFTW4	58	/* available for programmer */
-#define _PAGE_BIT_DEVMAP		_PAGE_BIT_SOFTW4
-#define _PAGE_BIT_NX		63	/* No execute: only valid after cpuid check */
+#define _PAGE_BIT_DEVMAP	_PAGE_BIT_SOFTW4
 
 /* If _PAGE_BIT_PRESENT is clear, we use these: */
 /* - if the user mapped it with PROT_NONE; pte_present gives true */
@@ -47,6 +52,17 @@
 #define _PAGE_PAT_LARGE (_AT(pteval_t, 1) << _PAGE_BIT_PAT_LARGE)
 #define _PAGE_SPECIAL	(_AT(pteval_t, 1) << _PAGE_BIT_SPECIAL)
 #define _PAGE_CPA_TEST	(_AT(pteval_t, 1) << _PAGE_BIT_CPA_TEST)
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
