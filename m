Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 19CD38D003E
	for <linux-mm@kvack.org>; Mon, 21 Feb 2011 14:08:25 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 1/8] Fix interleaving for transparent hugepages
Date: Mon, 21 Feb 2011 11:07:43 -0800
Message-Id: <1298315270-10434-2-git-send-email-andi@firstfloor.org>
In-Reply-To: <1298315270-10434-1-git-send-email-andi@firstfloor.org>
References: <1298315270-10434-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, lwoodman@redhat.com, Andi Kleen <ak@linux.intel.com>

From: Andi Kleen <ak@linux.intel.com>

Bugfix, independent from the rest of the series.

The THP code didn't pass the correct interleaving shift to the memory
policy code. Fix this here by adjusting for the order.

Cc: aarcange@redhat.com
Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 mm/mempolicy.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 368fc9d..76c51b7 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1830,7 +1830,7 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 	if (unlikely(pol->mode == MPOL_INTERLEAVE)) {
 		unsigned nid;
 
-		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT);
+		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT << order);
 		mpol_cond_put(pol);
 		page = alloc_page_interleave(gfp, order, nid);
 		put_mems_allowed();
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
