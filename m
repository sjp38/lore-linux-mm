Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id E24E96B0003
	for <linux-mm@kvack.org>; Mon,  8 Oct 2018 23:59:16 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id e136-v6so150437oib.11
        for <linux-mm@kvack.org>; Mon, 08 Oct 2018 20:59:16 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id l18-v6si8424775oth.164.2018.10.08.20.59.15
        for <linux-mm@kvack.org>;
        Mon, 08 Oct 2018 20:59:15 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: [PATCH] mm/thp: Correctly differentiate between mapped THP and PMD migration entry
Date: Tue,  9 Oct 2018 09:28:58 +0530
Message-Id: <1539057538-27446-1-git-send-email-anshuman.khandual@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, zi.yan@cs.rutgers.edu, will.deacon@arm.com

A normal mapped THP page at PMD level should be correctly differentiated
from a PMD migration entry while walking the page table. A mapped THP would
additionally check positive for pmd_present() along with pmd_trans_huge()
as compared to a PMD migration entry. This just adds a new conditional test
differentiating the two while walking the page table.

Fixes: 616b8371539a6 ("mm: thp: enable thp migration in generic path")
Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
On X86, pmd_trans_huge() and is_pmd_migration_entry() are always mutually
exclusive which makes the current conditional block work for both mapped
and migration entries. This is not same with arm64 where pmd_trans_huge()
returns positive for both mapped and migration entries. Could some one
please explain why pmd_trans_huge() has to return false for migration
entries which just install swap bits and its still a PMD ? Nonetheless
pmd_present() seems to be a better check to distinguish between mapped
and (non-mapped non-present) migration entries without any ambiguity.

 mm/page_vma_mapped.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/page_vma_mapped.c b/mm/page_vma_mapped.c
index ae3c2a3..b384396 100644
--- a/mm/page_vma_mapped.c
+++ b/mm/page_vma_mapped.c
@@ -161,7 +161,8 @@ bool page_vma_mapped_walk(struct page_vma_mapped_walk *pvmw)
 	pmde = READ_ONCE(*pvmw->pmd);
 	if (pmd_trans_huge(pmde) || is_pmd_migration_entry(pmde)) {
 		pvmw->ptl = pmd_lock(mm, pvmw->pmd);
-		if (likely(pmd_trans_huge(*pvmw->pmd))) {
+		if (likely(pmd_trans_huge(*pvmw->pmd) &&
+					pmd_present(*pvmw->pmd))) {
 			if (pvmw->flags & PVMW_MIGRATION)
 				return not_found(pvmw);
 			if (pmd_page(*pvmw->pmd) != page)
-- 
2.7.4
