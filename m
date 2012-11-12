Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 010FA6B004D
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 07:20:01 -0500 (EST)
Date: Mon, 12 Nov 2012 12:19:57 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: kswapd0: excessive CPU usage
Message-ID: <20121112121956.GT8218@suse.de>
References: <20121012135726.GY29125@suse.de>
 <507BDD45.1070705@suse.cz>
 <20121015110937.GE29125@suse.de>
 <5093A3F4.8090108@redhat.com>
 <5093A631.5020209@suse.cz>
 <509422C3.1000803@suse.cz>
 <509C84ED.8090605@linux.vnet.ibm.com>
 <509CB9D1.6060704@redhat.com>
 <20121109090635.GG8218@suse.de>
 <509F6C2A.9060502@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <509F6C2A.9060502@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zdenek Kabelac <zkabelac@redhat.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Jiri Slaby <jslaby@suse.cz>, Valdis.Kletnieks@vt.edu, Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Robert Jennings <rcj@linux.vnet.ibm.com>

On Sun, Nov 11, 2012 at 10:13:14AM +0100, Zdenek Kabelac wrote:
> Hmm,  so it's just took longer to hit the problem and observe kswapd0
> spinning on my CPU again - it's not as endless like before - but
> still it easily eats minutes - it helps to  turn off  Firefox or TB
> (memory hungry apps) so kswapd0 stops soon - and restart those apps
> again.
> (And I still have like >1GB of cached memory)
> 

I posted a "safe" patch that I believe explains why you are seeing what
you are seeing. It does mean that there will still be some stalls due to
THP because kswapd is not helping and it's avoiding the problem rather
than trying to deal with it.

Hence, I'm also going to post this patch even though I have not tested
it myself. If you find it fixes the problem then it would be a
preferable patch to the revert. It still is the case that the
balance_pgdat() logic is in sort need of a rethink as it's pretty
twisted right now.

Thanks

---8<---
mm: Avoid waking kswapd for THP allocations when compaction is deferred or contended

With "mm: vmscan: scale number of pages reclaimed by reclaim/compaction
based on failures" reverted, Zdenek Kabelac reported the following

	Hmm,  so it's just took longer to hit the problem and observe
	kswapd0 spinning on my CPU again - it's not as endless like before -
	but still it easily eats minutes - it helps to	turn off  Firefox
	or TB  (memory hungry apps) so kswapd0 stops soon - and restart
	those apps again.  (And I still have like >1GB of cached memory)

	kswapd0         R  running task        0    30      2 0x00000000
	 ffff8801331efae8 0000000000000082 0000000000000018 0000000000000246
	 ffff880135b9a340 ffff8801331effd8 ffff8801331effd8 ffff8801331effd8
	 ffff880055dfa340 ffff880135b9a340 00000000331efad8 ffff8801331ee000
	Call Trace:
	 [<ffffffff81555bf2>] preempt_schedule+0x42/0x60
	 [<ffffffff81557a95>] _raw_spin_unlock+0x55/0x60
	 [<ffffffff81192971>] put_super+0x31/0x40
	 [<ffffffff81192a42>] drop_super+0x22/0x30
	 [<ffffffff81193b89>] prune_super+0x149/0x1b0
	 [<ffffffff81141e2a>] shrink_slab+0xba/0x510

The sysrq+m indicates the system has no swap so it'll never reclaim
anonymous pages as part of reclaim/compaction. That is one part of the
problem but not the root cause as file-backed pages could also be reclaimed.

The likely underlying problem is that kswapd is woken up or kept awake
for each THP allocation request in the page allocator slow path.

If compaction fails for the requesting process then compaction will be
deferred for a time and direct reclaim is avoided. However, if there
are a storm of THP requests that are simply rejected, it will still
be the the case that kswapd is awake for a prolonged period of time
as pgdat->kswapd_max_order is updated each time. This is noticed by
the main kswapd() loop and it will not call kswapd_try_to_sleep().
Instead it will loopp, shrinking a small number of pages and calling
shrink_slab() on each iteration.

This patch defers when kswapd gets woken up for THP allocations. For !THP
allocations, kswapd is always woken up. For THP allocations, kswapd is
woken up iff the process is willing to enter into direct
reclaim/compaction.

Signed-off-by: Mel Gorman <mgorman@suse.de>

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bb90971..0b469b4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2378,6 +2378,15 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	return !!(gfp_to_alloc_flags(gfp_mask) & ALLOC_NO_WATERMARKS);
 }
 
+/* Returns true if the allocation is likely for THP */
+static bool is_thp_alloc(gfp_t gfp_mask, unsigned int order)
+{
+	if (order == pageblock_order &&
+	    (gfp_mask & (__GFP_MOVABLE|__GFP_REPEAT)) == __GFP_MOVABLE)
+		return true;
+	return false;
+}
+
 static inline struct page *
 __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
@@ -2416,7 +2425,9 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		goto nopage;
 
 restart:
-	wake_all_kswapd(order, zonelist, high_zoneidx,
+	/* The decision whether to wake kswapd for THP is made later */
+	if (!is_thp_alloc(gfp_mask, order))
+		wake_all_kswapd(order, zonelist, high_zoneidx,
 					zone_idx(preferred_zone));
 
 	/*
@@ -2487,15 +2498,21 @@ rebalance:
 		goto got_pg;
 	sync_migration = true;
 
-	/*
-	 * If compaction is deferred for high-order allocations, it is because
-	 * sync compaction recently failed. In this is the case and the caller
-	 * requested a movable allocation that does not heavily disrupt the
-	 * system then fail the allocation instead of entering direct reclaim.
-	 */
-	if ((deferred_compaction || contended_compaction) &&
-	    (gfp_mask & (__GFP_MOVABLE|__GFP_REPEAT)) == __GFP_MOVABLE)
-		goto nopage;
+	if (is_thp_alloc(gfp_mask, order)) {
+		/*
+		 * If compaction is deferred for high-order allocations, it is
+		 * because sync compaction recently failed. In this is the case
+		 * and the caller requested a movable allocation that does not
+		 * heavily disrupt the system then fail the allocation instead
+		 * of entering direct reclaim.
+		 */
+		if (deferred_compaction || contended_compaction)
+			goto nopage;
+
+		/* If process is willing to reclaim/compact then wake kswapd */
+		wake_all_kswapd(order, zonelist, high_zoneidx,
+					zone_idx(preferred_zone));
+	}
 
 	/* Try direct reclaim and then allocating */
 	page = __alloc_pages_direct_reclaim(gfp_mask, order,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
