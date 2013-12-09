Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id C19876B0038
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 02:09:20 -0500 (EST)
Received: by mail-ee0-f51.google.com with SMTP id b15so1338940eek.38
        for <linux-mm@kvack.org>; Sun, 08 Dec 2013 23:09:20 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id a9si8231832eew.96.2013.12.08.23.09.17
        for <linux-mm@kvack.org>;
        Sun, 08 Dec 2013 23:09:17 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 03/18] mm: Clear pmd_numa before invalidating
Date: Mon,  9 Dec 2013 07:08:57 +0000
Message-Id: <1386572952-1191-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1386572952-1191-1-git-send-email-mgorman@suse.de>
References: <1386572952-1191-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alex Thorlton <athorlton@sgi.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

pmdp_invalidate clears the present bit without taking into account that it
might be in the _PAGE_NUMA bit leaving the PMD in an unexpected state. Clear
pmd_numa before invalidating.

Cc: stable@vger.kernel.org
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/pgtable-generic.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
index cbb3854..e84cad2 100644
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
