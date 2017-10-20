Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D56EE6B026B
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 22:46:17 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id t188so8049355pfd.20
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 19:46:17 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id a6si3441669pll.474.2017.10.19.19.46.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Oct 2017 19:46:16 -0700 (PDT)
Subject: [PATCH v3 10/13] mm: disable get_user_pages_fast() for dax
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 19 Oct 2017 19:39:51 -0700
Message-ID: <150846719161.24336.5799047274707349501.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150846713528.24336.4459262264611579791.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150846713528.24336.4459262264611579791.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, linux-nvdimm@lists.01.org, Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, hch@lst.de, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

In preparation for solving the dax-dma vs truncate race, disable
get_user_pages_fast(). The race fix relies on the vma being available.

We can still support get_user_pages_fast() for 1GB (pud) 'devmap'
mappings since those are only implemented for device-dax, everything
else needs the vma and the gup-slow-path in case it might be a
filesytem-dax mapping.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 mm/gup.c |   48 +++++++++++++-----------------------------------
 1 file changed, 13 insertions(+), 35 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index b2b4d4263768..308be897d22a 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1290,22 +1290,12 @@ static inline pte_t gup_get_pte(pte_t *ptep)
 }
 #endif
 
-static void undo_dev_pagemap(int *nr, int nr_start, struct page **pages)
-{
-	while ((*nr) - nr_start) {
-		struct page *page = pages[--(*nr)];
-
-		ClearPageReferenced(page);
-		put_page(page);
-	}
-}
-
 #ifdef __HAVE_ARCH_PTE_SPECIAL
 static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 			 int write, struct page **pages, int *nr)
 {
 	struct dev_pagemap *pgmap = NULL;
-	int nr_start = *nr, ret = 0;
+	int ret = 0;
 	pte_t *ptep, *ptem;
 
 	ptem = ptep = pte_offset_map(&pmd, addr);
@@ -1323,13 +1313,7 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 		if (!pte_access_permitted(pte, write))
 			goto pte_unmap;
 
-		if (pte_devmap(pte)) {
-			pgmap = get_dev_pagemap(pte_pfn(pte), pgmap);
-			if (unlikely(!pgmap)) {
-				undo_dev_pagemap(nr, nr_start, pages);
-				goto pte_unmap;
-			}
-		} else if (pte_special(pte))
+		if (pte_devmap(pte) || (pte_special(pte)))
 			goto pte_unmap;
 
 		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
@@ -1378,6 +1362,16 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 #endif /* __HAVE_ARCH_PTE_SPECIAL */
 
 #if defined(__HAVE_ARCH_PTE_DEVMAP) && defined(CONFIG_TRANSPARENT_HUGEPAGE)
+static void undo_dev_pagemap(int *nr, int nr_start, struct page **pages)
+{
+	while ((*nr) - nr_start) {
+		struct page *page = pages[--(*nr)];
+
+		ClearPageReferenced(page);
+		put_page(page);
+	}
+}
+
 static int __gup_device_huge(unsigned long pfn, unsigned long addr,
 		unsigned long end, struct page **pages, int *nr)
 {
@@ -1402,15 +1396,6 @@ static int __gup_device_huge(unsigned long pfn, unsigned long addr,
 	return 1;
 }
 
-static int __gup_device_huge_pmd(pmd_t pmd, unsigned long addr,
-		unsigned long end, struct page **pages, int *nr)
-{
-	unsigned long fault_pfn;
-
-	fault_pfn = pmd_pfn(pmd) + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
-	return __gup_device_huge(fault_pfn, addr, end, pages, nr);
-}
-
 static int __gup_device_huge_pud(pud_t pud, unsigned long addr,
 		unsigned long end, struct page **pages, int *nr)
 {
@@ -1420,13 +1405,6 @@ static int __gup_device_huge_pud(pud_t pud, unsigned long addr,
 	return __gup_device_huge(fault_pfn, addr, end, pages, nr);
 }
 #else
-static int __gup_device_huge_pmd(pmd_t pmd, unsigned long addr,
-		unsigned long end, struct page **pages, int *nr)
-{
-	BUILD_BUG();
-	return 0;
-}
-
 static int __gup_device_huge_pud(pud_t pud, unsigned long addr,
 		unsigned long end, struct page **pages, int *nr)
 {
@@ -1445,7 +1423,7 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
 		return 0;
 
 	if (pmd_devmap(orig))
-		return __gup_device_huge_pmd(orig, addr, end, pages, nr);
+		return 0;
 
 	refs = 0;
 	page = pmd_page(orig) + ((addr & ~PMD_MASK) >> PAGE_SHIFT);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
