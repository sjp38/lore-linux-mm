Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f172.google.com (mail-ea0-f172.google.com [209.85.215.172])
	by kanga.kvack.org (Postfix) with ESMTP id A75236B003C
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 03:52:08 -0500 (EST)
Received: by mail-ea0-f172.google.com with SMTP id q10so9863808ead.3
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 00:52:08 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id p9si2261622eey.70.2013.12.03.00.52.07
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 00:52:08 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 06/15] mm: Clear pmd_numa before invalidating
Date: Tue,  3 Dec 2013 08:51:53 +0000
Message-Id: <1386060721-3794-7-git-send-email-mgorman@suse.de>
In-Reply-To: <1386060721-3794-1-git-send-email-mgorman@suse.de>
References: <1386060721-3794-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

pmdp_invalidate clears the present bit without taking into account that it
might be in the _PAGE_NUMA bit leaving the PMD in an unexpected state. Clear
pmd_numa before invalidating.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/pgtable-generic.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
index 3929a40..a7aefd3 100644
--- a/mm/pgtable-generic.c
+++ b/mm/pgtable-generic.c
@@ -191,6 +191,9 @@ pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp)
 void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
 		     pmd_t *pmdp)
 {
+	pmd_t entry = *pmdp;
+	if (pmd_numa(entry))
+		entry = pmd_mknonnuma(entry);
 	set_pmd_at(vma->vm_mm, address, pmdp, pmd_mknotpresent(*pmdp));
 	flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
 }
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
