Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id CA7AE900004
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 06:29:54 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id kx10so7146794pab.41
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 03:29:54 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 10/63] mm: Do not flush TLB during protection change if !pte_present && !migration_entry
Date: Mon,  7 Oct 2013 11:28:48 +0100
Message-Id: <1381141781-10992-11-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-1-git-send-email-mgorman@suse.de>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

NUMA PTE scanning is expensive both in terms of the scanning itself and
the TLB flush if there are any updates. Currently non-present PTEs are
accounted for as an update and incurring a TLB flush where it is only
necessary for anonymous migration entries. This patch addresses the
problem and should reduce TLB flushes.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/mprotect.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/mprotect.c b/mm/mprotect.c
index 2bbb648..7bdbd4b 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -101,8 +101,9 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 				make_migration_entry_read(&entry);
 				set_pte_at(mm, addr, pte,
 					swp_entry_to_pte(entry));
+
+				pages++;
 			}
-			pages++;
 		}
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 	arch_leave_lazy_mmu_mode();
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
