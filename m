Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 15E476B006C
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 05:32:52 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 17/50] mm: Do not flush TLB during protection change if !pte_present && !migration_entry
Date: Tue, 10 Sep 2013 10:31:57 +0100
Message-Id: <1378805550-29949-18-git-send-email-mgorman@suse.de>
In-Reply-To: <1378805550-29949-1-git-send-email-mgorman@suse.de>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
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
index 1f9b54b..1e9cef0 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -109,8 +109,9 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
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
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
