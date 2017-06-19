Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 548736B02C3
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 13:02:37 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id w12so106915816pfk.1
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 10:02:37 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 4si10370724plc.165.2017.06.19.10.02.36
        for <linux-mm@kvack.org>;
        Mon, 19 Jun 2017 10:02:36 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: [PATCH v5 3/8] mm, gup: Remove broken VM_BUG_ON_PAGE compound check for hugepages
Date: Mon, 19 Jun 2017 18:01:40 +0100
Message-Id: <20170619170145.25577-4-punit.agrawal@arm.com>
In-Reply-To: <20170619170145.25577-1-punit.agrawal@arm.com>
References: <20170619170145.25577-1-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, mike.kravetz@oracle.com, steve.capper@arm.com, mark.rutland@arm.com, linux-arch@vger.kernel.org, aneesh.kumar@linux.vnet.ibm.com, Punit Agrawal <punit.agrawal@arm.com>

From: Will Deacon <will.deacon@arm.com>

When operating on hugepages with DEBUG_VM enabled, the GUP code checks the
compound head for each tail page prior to calling page_cache_add_speculative.
This is broken, because on the fast-GUP path (where we don't hold any page
table locks) we can be racing with a concurrent invocation of
split_huge_page_to_list.

split_huge_page_to_list deals with this race by using page_ref_freeze to
freeze the page and force concurrent GUPs to fail whilst the component
pages are modified. This modification includes clearing the compound_head
field for the tail pages, so checking this prior to a successful call
to page_cache_add_speculative can lead to false positives: In fact,
page_cache_add_speculative *already* has this check once the page refcount
has been successfully updated, so we can simply remove the broken calls
to VM_BUG_ON_PAGE.

Signed-off-by: Will Deacon <will.deacon@arm.com>
Acked-by: Steve Capper <steve.capper@arm.com>
Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
Acked-by: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/gup.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index b3c7214d710d..e74e0b5a0c7c 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1357,7 +1357,6 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
 	head = pmd_page(orig);
 	page = head + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
 	do {
-		VM_BUG_ON_PAGE(compound_head(page) != head, page);
 		pages[*nr] = page;
 		(*nr)++;
 		page++;
@@ -1396,7 +1395,6 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
 	head = pud_page(orig);
 	page = head + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
 	do {
-		VM_BUG_ON_PAGE(compound_head(page) != head, page);
 		pages[*nr] = page;
 		(*nr)++;
 		page++;
@@ -1434,7 +1432,6 @@ static int gup_huge_pgd(pgd_t orig, pgd_t *pgdp, unsigned long addr,
 	head = pgd_page(orig);
 	page = head + ((addr & ~PGDIR_MASK) >> PAGE_SHIFT);
 	do {
-		VM_BUG_ON_PAGE(compound_head(page) != head, page);
 		pages[*nr] = page;
 		(*nr)++;
 		page++;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
