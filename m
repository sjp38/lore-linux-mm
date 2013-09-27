Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 1194C900002
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 09:28:01 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id y10so2582746pdj.39
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 06:28:01 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 07/63] mm: Account for a THP NUMA hinting update as one PTE update
Date: Fri, 27 Sep 2013 14:26:52 +0100
Message-Id: <1380288468-5551-8-git-send-email-mgorman@suse.de>
In-Reply-To: <1380288468-5551-1-git-send-email-mgorman@suse.de>
References: <1380288468-5551-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

A THP PMD update is accounted for as 512 pages updated in vmstat.  This is
large difference when estimating the cost of automatic NUMA balancing and
can be misleading when comparing results that had collapsed versus split
THP. This patch addresses the accounting issue.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/mprotect.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mprotect.c b/mm/mprotect.c
index 94722a4..2bbb648 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -145,7 +145,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
 				split_huge_page_pmd(vma, addr, pmd);
 			else if (change_huge_pmd(vma, pmd, addr, newprot,
 						 prot_numa)) {
-				pages += HPAGE_PMD_NR;
+				pages++;
 				continue;
 			}
 			/* fall through */
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
