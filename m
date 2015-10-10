Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id DB9996B025D
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 21:02:00 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so100752172pab.3
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 18:02:00 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id zn6si474421pac.223.2015.10.09.18.02.00
        for <linux-mm@kvack.org>;
        Fri, 09 Oct 2015 18:02:00 -0700 (PDT)
Subject: [PATCH v2 10/20] um: kill pfn_t
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 09 Oct 2015 20:56:17 -0400
Message-ID: <20151010005617.17221.12773.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
References: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Dave Hansen <dave@sr71.net>, Richard Weinberger <richard@nod.at>, Jeff Dike <jdike@addtoit.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ross.zwisler@linux.intel.com, hch@lst.de

The core has developed a need for a "pfn_t" type [1].  Convert the usage
of pfn_t by usermode-linux to an unsigned long, and update pfn_to_phys()
to drop its expectation of a typed pfn.

[1]: https://lists.01.org/pipermail/linux-nvdimm/2015-September/002199.html

Cc: Dave Hansen <dave@sr71.net>
Cc: Jeff Dike <jdike@addtoit.com>
Cc: Richard Weinberger <richard@nod.at>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/um/include/asm/page.h           |    6 +++---
 arch/um/include/asm/pgtable-3level.h |    4 ++--
 arch/um/include/asm/pgtable.h        |    2 +-
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/arch/um/include/asm/page.h b/arch/um/include/asm/page.h
index 71c5d132062a..fe26a5e06268 100644
--- a/arch/um/include/asm/page.h
+++ b/arch/um/include/asm/page.h
@@ -18,6 +18,7 @@
 
 struct page;
 
+#include <linux/pfn.h>
 #include <linux/types.h>
 #include <asm/vm-flags.h>
 
@@ -76,7 +77,6 @@ typedef struct { unsigned long pmd; } pmd_t;
 #define pte_is_zero(p) (!((p).pte & ~_PAGE_NEWPAGE))
 #define pte_set_val(p, phys, prot) (p).pte = (phys | pgprot_val(prot))
 
-typedef unsigned long pfn_t;
 typedef unsigned long phys_t;
 
 #endif
@@ -109,8 +109,8 @@ extern unsigned long uml_physmem;
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
