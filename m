Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f42.google.com (mail-bk0-f42.google.com [209.85.214.42])
	by kanga.kvack.org (Postfix) with ESMTP id AB8A26B0035
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 17:31:47 -0500 (EST)
Received: by mail-bk0-f42.google.com with SMTP id w11so3133749bkz.1
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 14:31:46 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id pf10si5730250bkb.249.2013.12.17.14.31.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 14:31:46 -0800 (PST)
Date: Tue, 17 Dec 2013 17:31:36 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/7] mm: page_alloc: Use zone node IDs to approximate
 locality
Message-ID: <20131217223136.GI21724@cmpxchg.org>
References: <1386943807-29601-1-git-send-email-mgorman@suse.de>
 <1386943807-29601-4-git-send-email-mgorman@suse.de>
 <20131216202507.GZ21724@cmpxchg.org>
 <20131217111352.GZ11295@suse.de>
 <20131217153829.GC21724@cmpxchg.org>
 <20131217160808.GF11295@suse.de>
 <20131217201147.GH21724@cmpxchg.org>
 <20131217210340.GJ11295@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131217210340.GJ11295@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Dec 17, 2013 at 09:03:40PM +0000, Mel Gorman wrote:
> On Tue, Dec 17, 2013 at 03:11:47PM -0500, Johannes Weiner wrote:
> > On Tue, Dec 17, 2013 at 04:08:08PM +0000, Mel Gorman wrote:
> > > On Tue, Dec 17, 2013 at 10:38:29AM -0500, Johannes Weiner wrote:
> > > > On Tue, Dec 17, 2013 at 11:13:52AM +0000, Mel Gorman wrote:
> > > > > On Mon, Dec 16, 2013 at 03:25:07PM -0500, Johannes Weiner wrote:
> > > > > > On Fri, Dec 13, 2013 at 02:10:03PM +0000, Mel Gorman wrote:
> > > > > > > zone_local is using node_distance which is a more expensive call than
> > > > > > > necessary. On x86, it's another function call in the allocator fast path
> > > > > > > and increases cache footprint. This patch makes the assumption zones on a
> > > > > > > local node will share the same node ID. The necessary information should
> > > > > > > already be cache hot.
> > > > > > > 
> > > > > > > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > > > > > > ---
> > > > > > >  mm/page_alloc.c | 2 +-
> > > > > > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > > > > > 
> > > > > > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > > > > > index 64020eb..fd9677e 100644
> > > > > > > --- a/mm/page_alloc.c
> > > > > > > +++ b/mm/page_alloc.c
> > > > > > > @@ -1816,7 +1816,7 @@ static void zlc_clear_zones_full(struct zonelist *zonelist)
> > > > > > >  
> > > > > > >  static bool zone_local(struct zone *local_zone, struct zone *zone)
> > > > > > >  {
> > > > > > > -	return node_distance(local_zone->node, zone->node) == LOCAL_DISTANCE;
> > > > > > > +	return zone_to_nid(zone) == numa_node_id();
> > > > > > 
> > > > > > Why numa_node_id()?  We pass in the preferred zone as @local_zone:
> > > > > > 
> > > > > 
> > > > > Initially because I was thinking "local node" and numa_node_id() is a
> > > > > per-cpu variable that should be cheap to access and in some cases
> > > > > cache-hot as the top-level gfp API calls numa_node_id().
> > > > > 
> > > > > Thinking about it more though it still makes sense because the preferred
> > > > > zone is not necessarily local. If the allocation request requires ZONE_DMA32
> > > > > and the local node does not have that zone then preferred zone is on a
> > > > > remote node.
> > > > 
> > > > Don't we treat everything in relation to the preferred zone?
> > > 
> > > Usually yes, but this time we really care about whether the memory is
> > > local or remote. It makes sense to me as it is and struggle to see an
> > > advantage of expressing it in terms of the preferred zone. Minimally
> > > zone_local would need to be renamed if it could return true for a remote
> > > zone and I see no advantage in doing that.
> > 
> > What the function tests for is whether any given zone is close
> > enough/local to the given preferred zone such that we can allocate
> > from it without having to invoke zone_reclaim_mode.
> > 
> 
> Fine. The helper should then be renamed to zone_preferred_node because
> it's no longer about being local.

Fair enough!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
