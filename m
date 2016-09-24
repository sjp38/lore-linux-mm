Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 332366B0291
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 23:27:07 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id t83so332582783oie.0
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 20:27:07 -0700 (PDT)
Received: from mail-oi0-x22e.google.com (mail-oi0-x22e.google.com. [2607:f8b0:4003:c06::22e])
        by mx.google.com with ESMTPS id i35si346431ote.211.2016.09.23.20.27.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Sep 2016 20:27:06 -0700 (PDT)
Received: by mail-oi0-x22e.google.com with SMTP id t83so155615215oie.3
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 20:27:06 -0700 (PDT)
Date: Fri, 23 Sep 2016 20:27:04 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 3/3] mm: delete unnecessary and unsafe init_tlb_ubc()
In-Reply-To: <alpine.LSU.2.11.1609232014130.2495@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1609232024340.2495@eggly.anvils>
References: <alpine.LSU.2.11.1609232014130.2495@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

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
Acked-by: Mel Gorman <mgorman@techsingularity.net>
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
