Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f47.google.com (mail-bk0-f47.google.com [209.85.214.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0A8816B0031
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 16:09:55 -0500 (EST)
Received: by mail-bk0-f47.google.com with SMTP id mx12so403447bkb.6
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 13:09:55 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id pr4si595846bkb.314.2013.12.18.13.09.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Dec 2013 13:09:54 -0800 (PST)
Date: Wed, 18 Dec 2013 16:06:17 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH 0/6] Configurable fair allocation zone policy v4
Message-ID: <20131218210617.GC20038@cmpxchg.org>
References: <1387395723-25391-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1387395723-25391-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Dec 18, 2013 at 07:41:57PM +0000, Mel Gorman wrote:
> This is still a work in progress. I know Johannes is maintaining his own
> patch which takes a different approach and has different priorities. Michal
> Hocko has raised concerns potentially affecting both. I'm releasing this so
> there is a basis of comparison with Johannes' patch. It's not necessarily
> the final shape of what we want to merge but the test results highlight
> the current behaviour has regressed performance for basic workloads.
> 
> A big concern is the semantics and tradeoffs of the tunable are quite
> involved.  Basically no matter what workload you get right, there will be
> a workload that will be wrong. This might indicate that this really needs
> to be controlled via memory policies or some means of detecting online
> which policy should be used on a per-process basis.

I'm more and more agreeing with this.  As I stated in my answer to
Michal, I may have seen this too black and white and the flipside of
the coin as not important enough.

But it really does point to a mempolicy.  As long as we can agree on a
default that makes most sense for users, there is no harm in offering
a choice.  E.g. aging artifacts are simply irrelevant without reclaim
going on, so a workload that mostly avoids it can benefit from a
placement policy that strives for locality without any downsides.

> By default, this series does *not* interleave pagecache across nodes but
> it will interleave between local zones.
> 
> Changelog since V3
> o Add documentation
> o Bring tunable in line with Johannes
> o Common code when deciding to update the batch count and skip zones
> 
> Changelog since v2
> o Drop an accounting patch, behaviour is deliberate
> o Special case tmpfs and shmem pages for discussion
> 
> Changelog since v1
> o Fix lot of brain damage in the configurable policy patch
> o Yoink a page cache annotation patch
> o Only account batch pages against allocations eligible for the fair policy
> o Add patch that default distributes file pages on remote nodes
> 
> Commit 81c0a2bb ("mm: page_alloc: fair zone allocator policy") solved a
> bug whereby new pages could be reclaimed before old pages because of how
> the page allocator and kswapd interacted on the per-zone LRU lists.
> 
> Unfortunately a side-effect missed during review was that it's now very
> easy to allocate remote memory on NUMA machines. The problem is that
> it is not a simple case of just restoring local allocation policies as
> there are genuine reasons why global page aging may be prefereable. It's
> still a major change to default behaviour so this patch makes the policy
> configurable and sets what I think is a sensible default.

I wrote this to Michal, too: as 3.12 was only recently released and
its NUMA placement quite broken, I doubt that people running NUMA
machines already rely on this aspect of global page cache placement.

We should be able to restrict placement fairness to node-local zones
exclusively for 3.12-stable and possibly for 3.13, depending on how
fast we can agree on the interface.

I would prefer fixing the worst first so that we don't have to rush a
user interface in order to keep global cache aging, which nobody knows
exists yet.  But that part is simply not ready, so let's revert it.
And then place any subsequent attempts of implementing this for NUMA
on top of it, without depending on them for 3.12-stable and 3.13.

The following fix should produce the same outcomes on your tests:

---
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: page_alloc: revert NUMA aspect of fair allocation
 policy

81c0a2bb ("mm: page_alloc: fair zone allocator policy") meant to bring
aging fairness among zones in system, but it was overzealous and badly
regressed basic workloads on NUMA systems.

Due to the way kswapd and page allocator interacts, we still want to
make sure that all zones in any given node are used equally for all
allocations to maximize memory utilization and prevent thrashing on
the highest zone in the node.

While the same principle applies to NUMA nodes - memory utilization is
obviously improved by spreading allocations throughout all nodes -
remote references can be costly and so many workloads prefer locality
over memory utilization.  The original change assumed that
zone_reclaim_mode would be a good enough predictor for that, but it
turned out to be as indicative as a coin flip.

Revert the NUMA aspect of the fairness until we can find a proper way
to make it configurable and agree on a sane default.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: <stable@kernel.org> # 3.12
---
 mm/page_alloc.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index dd886fac451a..c5939317984f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1919,18 +1919,17 @@ get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
 		 * page was allocated in should have no effect on the
 		 * time the page has in memory before being reclaimed.
 		 *
-		 * When zone_reclaim_mode is enabled, try to stay in
-		 * local zones in the fastpath.  If that fails, the
-		 * slowpath is entered, which will do another pass
-		 * starting with the local zones, but ultimately fall
-		 * back to remote zones that do not partake in the
-		 * fairness round-robin cycle of this zonelist.
+		 * Try to stay in local zones in the fastpath.  If
+		 * that fails, the slowpath is entered, which will do
+		 * another pass starting with the local zones, but
+		 * ultimately fall back to remote zones that do not
+		 * partake in the fairness round-robin cycle of this
+		 * zonelist.
 		 */
 		if (alloc_flags & ALLOC_WMARK_LOW) {
 			if (zone_page_state(zone, NR_ALLOC_BATCH) <= 0)
 				continue;
-			if (zone_reclaim_mode &&
-			    !zone_local(preferred_zone, zone))
+			if (!zone_local(preferred_zone, zone))
 				continue;
 		}
 		/*
@@ -2396,7 +2395,7 @@ static void prepare_slowpath(gfp_t gfp_mask, unsigned int order,
 		 * thrash fairness information for zones that are not
 		 * actually part of this zonelist's round-robin cycle.
 		 */
-		if (zone_reclaim_mode && !zone_local(preferred_zone, zone))
+		if (!zone_local(preferred_zone, zone))
 			continue;
 		mod_zone_page_state(zone, NR_ALLOC_BATCH,
 				    high_wmark_pages(zone) -
-- 
1.8.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
