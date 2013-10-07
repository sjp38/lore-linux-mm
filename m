Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7F2969C0019
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 06:30:18 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id mc17so6898298pbc.18
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 03:30:18 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 36/63] mm: numa: Only trap pmd hinting faults if we would otherwise trap PTE faults
Date: Mon,  7 Oct 2013 11:29:14 +0100
Message-Id: <1381141781-10992-37-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-1-git-send-email-mgorman@suse.de>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Base page PMD faulting is meant to batch handle NUMA hinting faults from
PTEs. However, even is no PTE faults would ever be handled within a
range the kernel still traps PMD hinting faults. This patch avoids the
overhead.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/mprotect.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/mprotect.c b/mm/mprotect.c
index f0b087d..5aae390 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -146,6 +146,8 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 
 	pmd = pmd_offset(pud, addr);
 	do {
+		unsigned long this_pages;
+
 		next = pmd_addr_end(addr, end);
 		if (pmd_trans_huge(*pmd)) {
 			if (next - addr != HPAGE_PMD_SIZE)
@@ -165,8 +167,9 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 		}
 		if (pmd_none_or_clear_bad(pmd))
 			continue;
-		pages += change_pte_range(vma, pmd, addr, next, newprot,
+		this_pages = change_pte_range(vma, pmd, addr, next, newprot,
 				 dirty_accountable, prot_numa, &all_same_nidpid);
+		pages += this_pages;
 
 		/*
 		 * If we are changing protections for NUMA hinting faults then
@@ -174,7 +177,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 		 * node. This allows a regular PMD to be handled as one fault
 		 * and effectively batches the taking of the PTL
 		 */
-		if (prot_numa && all_same_nidpid)
+		if (prot_numa && this_pages && all_same_nidpid)
 			change_pmd_protnuma(vma->vm_mm, addr, pmd);
 	} while (pmd++, addr = next, addr != end);
 
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
