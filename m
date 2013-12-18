Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f42.google.com (mail-bk0-f42.google.com [209.85.214.42])
	by kanga.kvack.org (Postfix) with ESMTP id 99F4D6B0035
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 14:23:54 -0500 (EST)
Received: by mail-bk0-f42.google.com with SMTP id w11so371173bkz.1
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 11:23:53 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id lu3si527706bkb.214.2013.12.18.11.23.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Dec 2013 11:23:53 -0800 (PST)
Date: Wed, 18 Dec 2013 14:20:15 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH 0/6] Configurable fair allocation zone policy v3
Message-ID: <20131218192015.GA20038@cmpxchg.org>
References: <1387298904-8824-1-git-send-email-mgorman@suse.de>
 <20131217200210.GG21724@cmpxchg.org>
 <20131218145111.GA27510@dhcp22.suse.cz>
 <20131218151846.GM21724@cmpxchg.org>
 <20131218162050.GB27510@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131218162050.GB27510@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Dec 18, 2013 at 05:20:50PM +0100, Michal Hocko wrote:
> On Wed 18-12-13 10:18:46, Johannes Weiner wrote:
> > On Wed, Dec 18, 2013 at 03:51:11PM +0100, Michal Hocko wrote:
> > > On Tue 17-12-13 15:02:10, Johannes Weiner wrote:
> > > [...]
> > > > +pagecache_mempolicy_mode:
> > > > +
> > > > +This is available only on NUMA kernels.
> > > > +
> > > > +Per default, the configured memory policy is applicable to anonymous
> > > > +memory, shmem, tmpfs, etc., whereas pagecache is allocated in an
> > > > +interleaving fashion over all allowed nodes (hardbindings and
> > > > +zone_reclaim_mode excluded).
> > > > +
> > > > +The assumption is that, when it comes to pagecache, users generally
> > > > +prefer predictable replacement behavior regardless of NUMA topology
> > > > +and maximizing the cache's effectiveness in reducing IO over memory
> > > > +locality.
> > > 
> > > Isn't page spreading (PF_SPREAD_PAGE) intended to do the same thing
> > > semantically? The setting is per-cpuset rather than global which makes
> > > it harder to use but essentially it tries to distribute page cache pages
> > > across all the nodes.
> > >
> > > This is really getting confusing. We have zone_reclaim_mode to keep
> > > memory local in general, pagecache_mempolicy_mode to keep page cache
> > > local and PF_SPREAD_PAGE to spread the page cache around nodes.

You are right that the user interface we are exposing is kind of
cruddy and I'm less and less convinced that this is the right
direction.

> > zone_reclaim_mode is a global setting to go through great lengths to
> > stay on local nodes, intended to be used depending on the hardware,
> > not the workload.
> > 
> > Mempolicy on the other hand is to optimize placement for maximum
> > locality depending on access patterns of a workload or even just the
> > subset of a workload.  I'm trying to change whether this applies to
> > page cache (due to different locality / cache effectiveness tradeoff)
> > and we want to provide pagecache_mempolicy_mode to revert in the field
> > in case this is a mistake.
> > 
> > PF_SPREAD_PAGE becomes implied per default and should eventually be
> > removed.
> 
> I guess many loads do not care about page cache locality and the default
> spreading would be OK for them but what about those that do care?

Mel suggested that the page cache spreading be implemented as just
another memory policy and I rejected it on the grounds that we have
can have strange aging artifacts if it's not the default.

But you are right that there might be usecases that really have high
cache locality and don't incur any reclaim.  The aging artifacts are
non-existent to them but they would care about the NUMA locality.

And basically, the same aging artifacts apply to anon e.g., just that
the trade-off balance is different, as reclaim is much less common.
And we do offer interleaving for anon as well.  So the situation is
not all that different that I had myself convinced it would be...

So the more I'm thinking about it, the more I'm leaning towards making
it a mempolicy after all, provided that we can set a sane default.

Maybe we can make the new default a hybrid policy that keeps anon,
shmem, slab, kernel, etc. local but interleaves pagecache.  This
should make sense to most usecases while providing the ability for
custom placement policies per-process or per-VMA without having to
make the decision on a global level or through an unusual interface.

> Currently we have a per-process (cpuset in fact) flag but this will
> change it to all or nothing. Is this really a good step?
> Btw. I do not mind having PF_SPREAD_PAGE enabled by default.

I don't want to muck around with cpusets too much, tbh...  but I agree
that the behavior of PF_SPREAD_PAGE should be the default.  Except it
should honor zone_reclaim_mode and round-robin nodes that are within
RECLAIM_DISTANCE of the local one.

I will have spotty access to internet starting tomorrow night until
New Year's.  Is there a chance we can maybe revert the NUMA aspects of
the original patch for now and leave it as a node-local zone fairness
thing?  The NUMA behavior was so broken on 3.12 that I doubt that
people have come to rely on the cache fairness on such machines in
that one release.  So we should be able to release 3.12-stable and
3.13 with node-local zone fairness without regressing anybody, and
then give the NUMA aspect of it another try in 3.14.

Something like the following should restore NUMA behavior while still
fixing the kswapd vs. page allocator interaction bug of thrashing on
the highest zone.  PS: zone_local() is in a CONFIG_NUMA block, which
is why accessing zone->node is safe :-)

---

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index dd886fac451a..317ea747d2cd 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1822,7 +1822,7 @@ static void zlc_clear_zones_full(struct zonelist *zonelist)
 
 static bool zone_local(struct zone *local_zone, struct zone *zone)
 {
-	return node_distance(local_zone->node, zone->node) == LOCAL_DISTANCE;
+	return local_zone->node == zone->node;
 }
 
 static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
