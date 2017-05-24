Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 447846B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 07:55:39 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 62so193190733pft.3
        for <linux-mm@kvack.org>; Wed, 24 May 2017 04:55:39 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a1si24657871pgn.129.2017.05.24.04.55.37
        for <linux-mm@kvack.org>;
        Wed, 24 May 2017 04:55:38 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: [PATCH v4 4/8] mm, gup: Ensure real head page is ref-counted when using hugepages
Date: Wed, 24 May 2017 12:54:05 +0100
Message-Id: <20170524115409.31309-5-punit.agrawal@arm.com>
In-Reply-To: <20170524115409.31309-1-punit.agrawal@arm.com>
References: <20170524115409.31309-1-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Punit Agrawal <punit.agrawal@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, mike.kravetz@oracle.com, steve.capper@arm.com, mark.rutland@arm.com, linux-arch@vger.kernel.org, aneesh.kumar@linux.vnet.ibm.com, Michal Hocko <mhocko@suse.com>

When speculatively taking references to a hugepage using
page_cache_add_speculative() in gup_huge_pmd(), it is assumed that the
page returned by pmd_page() is the head page. Although normally true,
this assumption doesn't hold when the hugepage comprises of successive
page table entries such as when using contiguous bit on arm64 at PTE or
PMD levels.

This can be addressed by ensuring that the page passed to
page_cache_add_speculative() is the real head or by de-referencing the
head page within the function.

We take the first approach to keep the usage pattern aligned with
page_cache_get_speculative() where users already pass the appropriate
page, i.e., the de-referenced head.

Apply the same logic to fix gup_huge_[pud|pgd]() as well.

Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
Acked-by: Steve Capper <steve.capper@arm.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/gup.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index ccf8cb38234f..be67996513be 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1358,8 +1358,7 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
 		return __gup_device_huge_pmd(orig, addr, end, pages, nr);
 
 	refs = 0;
-	head = pmd_page(orig);
-	page = head + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
+	page = pmd_page(orig) + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
 	do {
 		pages[*nr] = page;
 		(*nr)++;
@@ -1367,6 +1366,7 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
 		refs++;
 	} while (addr += PAGE_SIZE, addr != end);
 
+	head = compound_head(page);
 	if (!page_cache_add_speculative(head, refs)) {
 		*nr -= refs;
 		return 0;
@@ -1396,8 +1396,7 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
 		return __gup_device_huge_pud(orig, addr, end, pages, nr);
 
 	refs = 0;
-	head = pud_page(orig);
-	page = head + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
+	page = pud_page(orig) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
 	do {
 		pages[*nr] = page;
 		(*nr)++;
@@ -1405,6 +1404,7 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
 		refs++;
 	} while (addr += PAGE_SIZE, addr != end);
 
+	head = compound_head(page);
 	if (!page_cache_add_speculative(head, refs)) {
 		*nr -= refs;
 		return 0;
@@ -1433,8 +1433,7 @@ static int gup_huge_pgd(pgd_t orig, pgd_t *pgdp, unsigned long addr,
 
 	BUILD_BUG_ON(pgd_devmap(orig));
 	refs = 0;
-	head = pgd_page(orig);
-	page = head + ((addr & ~PGDIR_MASK) >> PAGE_SHIFT);
+	page = pgd_page(orig) + ((addr & ~PGDIR_MASK) >> PAGE_SHIFT);
 	do {
 		pages[*nr] = page;
 		(*nr)++;
@@ -1442,6 +1441,7 @@ static int gup_huge_pgd(pgd_t orig, pgd_t *pgdp, unsigned long addr,
 		refs++;
 	} while (addr += PAGE_SIZE, addr != end);
 
+	head = compound_head(page);
 	if (!page_cache_add_speculative(head, refs)) {
 		*nr -= refs;
 		return 0;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
