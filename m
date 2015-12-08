Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id DE28A6B0284
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 20:34:28 -0500 (EST)
Received: by pfdd184 with SMTP id d184so3060712pfd.3
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 17:34:28 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id xk9si1324948pab.38.2015.12.07.17.34.28
        for <linux-mm@kvack.org>;
        Mon, 07 Dec 2015 17:34:28 -0800 (PST)
Subject: [PATCH -mm 16/25] x86, mm: introduce _PAGE_DEVMAP
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 07 Dec 2015 17:34:01 -0800
Message-ID: <20151208013401.25030.67383.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151208013236.25030.68781.stgit@dwillia2-desk3.jf.intel.com>
References: <20151208013236.25030.68781.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-nvdimm@lists.01.org

_PAGE_DEVMAP is a hardware-unused pte bit that will later be used in the
get_user_pages() path to identify pfns backed by the dynamic allocation
established by devm_memremap_pages.  Upon seeing that bit the gup path
will lookup and pin the allocation while the pages are in use.

Since the _PAGE_DEVMAP bit is > 32 it requires workarounds in
pmd_flags() to allow it to build the realmode boot code as well as
satsify pmd_bad();

In file included from ./arch/x86/include/asm/boot.h:5:0,
                 from arch/x86/realmode/rm/../../boot/boot.h:26,
                 from arch/x86/realmode/rm/../../boot/regs.c:19,
                 from arch/x86/realmode/rm/regs.c:1:
./arch/x86/include/asm/pgtable_types.h: In function a??pmd_pfn_maska??:
./arch/x86/include/asm/pgtable_types.h:310:3: warning: left shift count >= width of type
   return mask ^ _PAGE_DEVMAP;

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/x86/include/asm/page_types.h    |    3 ++-
 arch/x86/include/asm/pgtable_types.h |    7 ++++++-
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/page_types.h b/arch/x86/include/asm/page_types.h
index c5b7fb2774d0..160a19786806 100644
--- a/arch/x86/include/asm/page_types.h
+++ b/arch/x86/include/asm/page_types.h
@@ -15,7 +15,8 @@
 /* Cast PAGE_MASK to a signed type so that it is sign-extended if
    virtual addresses are 32-bits but physical addresses are larger
    (ie, 32-bit PAE). */
-#define PHYSICAL_PAGE_MASK	(((signed long)PAGE_MASK) & __PHYSICAL_MASK)
+#define PHYSICAL_PAGE_MASK	(((signed long)PAGE_MASK) & (__PHYSICAL_MASK \
+						& ~_PAGE_DEVMAP))
 
 #define PMD_PAGE_SIZE		(_AC(1, UL) << PMD_SHIFT)
 #define PMD_PAGE_MASK		(~(PMD_PAGE_SIZE-1))
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index 116fc4ee586f..08475aab4c66 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -24,7 +24,9 @@
 #define _PAGE_BIT_CPA_TEST	_PAGE_BIT_SOFTW1
 #define _PAGE_BIT_HIDDEN	_PAGE_BIT_SOFTW3 /* hidden by kmemcheck */
 #define _PAGE_BIT_SOFT_DIRTY	_PAGE_BIT_SOFTW3 /* software dirty tracking */
-#define _PAGE_BIT_NX           63       /* No execute: only valid after cpuid check */
+#define _PAGE_BIT_SOFTW4	58	/* available for programmer */
+#define _PAGE_BIT_DEVMAP		_PAGE_BIT_SOFTW4
+#define _PAGE_BIT_NX		63	/* No execute: only valid after cpuid check */
 
 /* If _PAGE_BIT_PRESENT is clear, we use these: */
 /* - if the user mapped it with PROT_NONE; pte_present gives true */
@@ -83,8 +85,11 @@
 
 #if defined(CONFIG_X86_64) || defined(CONFIG_X86_PAE)
 #define _PAGE_NX	(_AT(pteval_t, 1) << _PAGE_BIT_NX)
+#define _PAGE_DEVMAP	(_AT(u64, 1) << _PAGE_BIT_DEVMAP)
+#define __HAVE_ARCH_PTE_DEVMAP
 #else
 #define _PAGE_NX	(_AT(pteval_t, 0))
+#define _PAGE_DEVMAP	(_AT(pteval_t, 0))
 #endif
 
 #define _PAGE_PROTNONE	(_AT(pteval_t, 1) << _PAGE_BIT_PROTNONE)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
