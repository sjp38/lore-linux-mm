Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f46.google.com (mail-ee0-f46.google.com [74.125.83.46])
	by kanga.kvack.org (Postfix) with ESMTP id 0C69E6B009C
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 15:13:45 -0500 (EST)
Received: by mail-ee0-f46.google.com with SMTP id d49so838976eek.33
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 12:13:45 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id y41si4311573eee.48.2014.02.26.12.13.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 26 Feb 2014 12:13:40 -0800 (PST)
Date: Wed, 26 Feb 2014 15:13:33 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 1/2] mm: page_alloc: reset aging cycle with GFP_THISNODE
Message-ID: <20140226201333.GV6963@cmpxchg.org>
References: <1393360022-22566-1-git-send-email-hannes@cmpxchg.org>
 <20140226095422.GY6732@suse.de>
 <20140226171206.GU6963@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140226171206.GU6963@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Stancek <jstancek@redhat.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Feb 26, 2014 at 12:12:06PM -0500, Johannes Weiner wrote:
> On Wed, Feb 26, 2014 at 09:54:22AM +0000, Mel Gorman wrote:
> > How about special casing the (alloc_flags & ALLOC_WMARK_LOW) check in
> > get_page_from_freelist to also ignore GFP_THISNODE? The NR_ALLOC_BATCH
> > will go further negative if there are storms of GFP_THISNODE allocations
> > forcing other allocations into the slow path doing multiple calls to
> > prepare_slowpath but it would be closer to current behaviour and avoid
> > weirdness with kswapd.
> 
> I think the result would be much uglier.  The allocations wouldn't
> participate in the fairness protocol, and they'd create work for
> kswapd without waking it up, diminishing the latency reduction for
> which we have kswapd in the first place.
> 
> If kswapd wakeups should be too aggressive, I'd rather we ratelimit
> them in some way rather than exempting random order-0 allocation types
> as a moderation measure.  Exempting higher order wakeups, like THP
> does is one thing, but we want order-0 watermarks to be met at all
> times anyway, so it would make sense to me to nudge kswapd for every
> failing order-0 request.

So I'd still like to fix this and wake kswapd even for GFP_THISNODE
allocations, but let's defer it for now in favor of a minimal bugfix
that can be ported to -stable.

Would this be an acceptable replacement for 1/2?

---

From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/2] mm: page_alloc: exempt GFP_THISNODE allocations from zone
 fairness

Jan Stancek reports manual page migration encountering allocation
failures after some pages when there is still plenty of memory free,
and bisected the problem down to 81c0a2bb515f ("mm: page_alloc: fair
zone allocator policy").

The problem is that GFP_THISNODE obeys the zone fairness allocation
batches on one hand, but doesn't reset them and wake kswapd on the
other hand.  After a few of those allocations, the batches are
exhausted and the allocations fail.

Fixing this means either having GFP_THISNODE wake up kswapd, or
GFP_THISNODE not participating in zone fairness at all.  The latter
seems safer as an acute bugfix, we can clean up later.

Reported-by: Jan Stancek <jstancek@redhat.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: <stable@kernel.org> # 3.12+
---
 mm/page_alloc.c | 26 ++++++++++++++++++++++----
 1 file changed, 22 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e3758a09a009..14372bec0e81 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1236,6 +1236,15 @@ void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp)
 	}
 	local_irq_restore(flags);
 }
+static bool gfp_thisnode_allocation(gfp_t gfp_mask)
+{
+	return (gfp_mask & GFP_THISNODE) == GFP_THISNODE;
+}
+#else
+static bool gfp_thisnode_allocation(gfp_t gfp_mask)
+{
+	return false;
+}
 #endif
 
 /*
@@ -1572,7 +1581,13 @@ again:
 					  get_pageblock_migratetype(page));
 	}
 
-	__mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
+	/*
+	 * NOTE: GFP_THISNODE allocations do not partake in the kswapd
+	 * aging protocol, so they can't be fair.
+	 */
+	if (!gfp_thisnode_allocation(gfp_flags))
+		__mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
+
 	__count_zone_vm_events(PGALLOC, zone, 1 << order);
 	zone_statistics(preferred_zone, zone, gfp_flags);
 	local_irq_restore(flags);
@@ -1944,8 +1959,12 @@ zonelist_scan:
 		 * ultimately fall back to remote zones that do not
 		 * partake in the fairness round-robin cycle of this
 		 * zonelist.
+		 *
+		 * NOTE: GFP_THISNODE allocations do not partake in
+		 * the kswapd aging protocol, so they can't be fair.
 		 */
-		if (alloc_flags & ALLOC_WMARK_LOW) {
+		if ((alloc_flags & ALLOC_WMARK_LOW) &&
+		    !gfp_thisnode_allocation(gfp_mask)) {
 			if (zone_page_state(zone, NR_ALLOC_BATCH) <= 0)
 				continue;
 			if (!zone_local(preferred_zone, zone))
@@ -2501,8 +2520,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	 * allowed per node queues are empty and that nodes are
 	 * over allocated.
 	 */
-	if (IS_ENABLED(CONFIG_NUMA) &&
-			(gfp_mask & GFP_THISNODE) == GFP_THISNODE)
+	if (gfp_thisnode_allocation(gfp_mask))
 		goto nopage;
 
 restart:
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
