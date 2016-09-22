Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 706006B026B
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 13:41:53 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 21so178330471pfy.3
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 10:41:53 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id z8si2774886pac.112.2016.09.22.10.41.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Sep 2016 10:41:52 -0700 (PDT)
Received: by mail-pa0-x22d.google.com with SMTP id qn7so13903017pac.3
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 10:41:52 -0700 (PDT)
Date: Thu, 22 Sep 2016 10:41:50 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm: delete unnecessary and unsafe init_tlb_ubc()
Message-ID: <alpine.LSU.2.11.1609221037170.17333@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

init_tlb_ubc() looked unnecessary to me: tlb_ubc is statically initialized
with zeroes in the init_task, and copied from parent to child while it is
quiescent in arch_dup_task_struct(); so I went to delete it.

But inserted temporary debug WARN_ONs in place of init_tlb_ubc() to check
that it was always empty at that point, and found them firing: because
memcg reclaim can recurse into global reclaim (when allocating biosets
for swapout in my case), and arrive back at the init_tlb_ubc() in
shrink_node_memcg().

Resetting tlb_ubc.flush_required at that point is wrong: if the upper
level needs a deferred TLB flush, but the lower level turns out not to,
we miss a TLB flush.  But fortunately, that's the only part of the
protocol that does not nest: with the initialization removed, cpumask 
collects bits from upper and lower levels, and flushes TLB when needed.

Fixes: 72b252aed506 ("mm: send one IPI per CPU to TLB flush all entries after unmapping pages")
Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: stable@vger.kernel.org # 4.3+
---

 mm/vmscan.c |   19 -------------------
 1 file changed, 19 deletions(-)

--- 4.8-rc7/mm/vmscan.c	2016-09-05 16:42:52.496692429 -0700
+++ linux/mm/vmscan.c	2016-09-22 09:32:37.900894833 -0700
@@ -2303,23 +2303,6 @@ out:
 	}
 }
 
-#ifdef CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH
-static void init_tlb_ubc(void)
-{
-	/*
-	 * This deliberately does not clear the cpumask as it's expensive
-	 * and unnecessary. If there happens to be data in there then the
-	 * first SWAP_CLUSTER_MAX pages will send an unnecessary IPI and
-	 * then will be cleared.
-	 */
-	current->tlb_ubc.flush_required = false;
-}
-#else
-static inline void init_tlb_ubc(void)
-{
-}
-#endif /* CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH */
-
 /*
  * This is a basic per-node page freer.  Used by both kswapd and direct reclaim.
  */
@@ -2355,8 +2338,6 @@ static void shrink_node_memcg(struct pgl
 	scan_adjusted = (global_reclaim(sc) && !current_is_kswapd() &&
 			 sc->priority == DEF_PRIORITY);
 
-	init_tlb_ubc();
-
 	blk_start_plug(&plug);
 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
 					nr[LRU_INACTIVE_FILE]) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
