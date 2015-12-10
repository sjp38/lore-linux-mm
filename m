Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id EFB2B6B026B
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 21:38:14 -0500 (EST)
Received: by pacej9 with SMTP id ej9so39543516pac.2
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 18:38:14 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id b69si16799361pfd.30.2015.12.09.18.38.14
        for <linux-mm@kvack.org>;
        Wed, 09 Dec 2015 18:38:14 -0800 (PST)
Subject: [-mm PATCH v2 07/25] um: kill pfn_t
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 09 Dec 2015 18:37:47 -0800
Message-ID: <20151210023747.30368.62997.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151210023708.30368.92962.stgit@dwillia2-desk3.jf.intel.com>
References: <20151210023708.30368.92962.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-nvdimm@lists.01.org, Richard Weinberger <richard@nod.at>, Jeff Dike <jdike@addtoit.com>, Dave Hansen <dave@sr71.net>, linux-mm@kvack.org

The core has developed a need for a "pfn_t" type [1].  Convert the usage
of pfn_t by usermode-linux to an unsigned long, and update pfn_to_phys()
to drop its expectation of a typed pfn.

[1]: https://lists.01.org/pipermail/linux-nvdimm/2015-September/002199.html

Cc: Dave Hansen <dave@sr71.net>
Cc: Jeff Dike <jdike@addtoit.com>
Cc: Richard Weinberger <richard@nod.at>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/um/include/asm/page.h           |    7 +++----
 arch/um/include/asm/pgtable-3level.h |    4 ++--
 arch/um/include/asm/pgtable.h        |    2 +-
 3 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/arch/um/include/asm/page.h b/arch/um/include/asm/page.h
index 71c5d132062a..e13d41c392ae 100644
--- a/arch/um/include/asm/page.h
+++ b/arch/um/include/asm/page.h
@@ -18,6 +18,7 @@
 
 struct page;
 
+#include <linux/pfn.h>
 #include <linux/types.h>
 #include <asm/vm-flags.h>
 
@@ -52,7 +53,6 @@ typedef struct { unsigned long pgd; } pgd_t;
 #define pmd_val(x)	((x).pmd)
 #define __pmd(x) ((pmd_t) { (x) } )
 
-typedef unsigned long long pfn_t;
 typedef unsigned long long phys_t;
 
 #else
@@ -76,7 +76,6 @@ typedef struct { unsigned long pmd; } pmd_t;
 #define pte_is_zero(p) (!((p).pte & ~_PAGE_NEWPAGE))
 #define pte_set_val(p, phys, prot) (p).pte = (phys | pgprot_val(prot))
 
-typedef unsigned long pfn_t;
 typedef unsigned long phys_t;
 
 #endif
@@ -109,8 +108,8 @@ extern unsigned long uml_physmem;
 #define __pa(virt) to_phys((void *) (unsigned long) (virt))
 #define __va(phys) to_virt((unsigned long) (phys))
 
-#define phys_to_pfn(p) ((pfn_t) ((p) >> PAGE_SHIFT))
-#define pfn_to_phys(pfn) ((phys_t) ((pfn) << PAGE_SHIFT))
+#define phys_to_pfn(p) ((p) >> PAGE_SHIFT)
+#define pfn_to_phys(pfn) PFN_PHYS(pfn)
 
 #define pfn_valid(pfn) ((pfn) < max_mapnr)
 #define virt_addr_valid(v) pfn_valid(phys_to_pfn(__pa(v)))
diff --git a/arch/um/include/asm/pgtable-3level.h b/arch/um/include/asm/pgtable-3level.h
index 2b4274e7c095..bae8523a162f 100644
--- a/arch/um/include/asm/pgtable-3level.h
+++ b/arch/um/include/asm/pgtable-3level.h
@@ -98,7 +98,7 @@ static inline unsigned long pte_pfn(pte_t pte)
 	return phys_to_pfn(pte_val(pte));
 }
 
-static inline pte_t pfn_pte(pfn_t page_nr, pgprot_t pgprot)
+static inline pte_t pfn_pte(unsigned long page_nr, pgprot_t pgprot)
 {
 	pte_t pte;
 	phys_t phys = pfn_to_phys(page_nr);
@@ -107,7 +107,7 @@ static inline pte_t pfn_pte(pfn_t page_nr, pgprot_t pgprot)
 	return pte;
 }
 
-static inline pmd_t pfn_pmd(pfn_t page_nr, pgprot_t pgprot)
+static inline pmd_t pfn_pmd(unsigned long page_nr, pgprot_t pgprot)
 {
 	return __pmd((page_nr << PAGE_SHIFT) | pgprot_val(pgprot));
 }
diff --git a/arch/um/include/asm/pgtable.h b/arch/um/include/asm/pgtable.h
index 18eb9924dda3..7485398d0737 100644
--- a/arch/um/include/asm/pgtable.h
+++ b/arch/um/include/asm/pgtable.h
@@ -271,7 +271,7 @@ static inline int pte_same(pte_t pte_a, pte_t pte_b)
 
 #define phys_to_page(phys) pfn_to_page(phys_to_pfn(phys))
 #define __virt_to_page(virt) phys_to_page(__pa(virt))
-#define page_to_phys(page) pfn_to_phys((pfn_t) page_to_pfn(page))
+#define page_to_phys(page) pfn_to_phys(page_to_pfn(page))
 #define virt_to_page(addr) __virt_to_page((const unsigned long) addr)
 
 #define mk_pte(page, pgprot) \

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
