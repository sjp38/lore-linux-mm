Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 3F9AC8D003E
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 19:46:03 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 4/8] Preserve original node for transparent huge page copies
Date: Wed,  2 Mar 2011 16:45:24 -0800
Message-Id: <1299113128-11349-5-git-send-email-andi@firstfloor.org>
In-Reply-To: <1299113128-11349-1-git-send-email-andi@firstfloor.org>
References: <1299113128-11349-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: aarcange@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>

From: Andi Kleen <ak@linux.intel.com>

This makes a difference for LOCAL policy, where the node cannot
be determined from the policy itself, but has to be gotten
from the original page.

Acked-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 mm/huge_memory.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index c7c2cd9..1802db8 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -799,8 +799,8 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 	}
 
 	for (i = 0; i < HPAGE_PMD_NR; i++) {
-		pages[i] = alloc_page_vma(GFP_HIGHUSER_MOVABLE,
-					  vma, address);
+		pages[i] = alloc_page_vma_node(GFP_HIGHUSER_MOVABLE,
+					       vma, address, page_to_nid(page));
 		if (unlikely(!pages[i] ||
 			     mem_cgroup_newpage_charge(pages[i], mm,
 						       GFP_KERNEL))) {
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
