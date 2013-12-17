Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id C37A76B0035
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 06:13:56 -0500 (EST)
Received: by mail-ee0-f48.google.com with SMTP id e49so2764434eek.21
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 03:13:56 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e48si4551912eeh.92.2013.12.17.03.13.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 03:13:55 -0800 (PST)
Date: Tue, 17 Dec 2013 11:13:52 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 3/7] mm: page_alloc: Use zone node IDs to approximate
 locality
Message-ID: <20131217111352.GZ11295@suse.de>
References: <1386943807-29601-1-git-send-email-mgorman@suse.de>
 <1386943807-29601-4-git-send-email-mgorman@suse.de>
 <20131216202507.GZ21724@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131216202507.GZ21724@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Dec 16, 2013 at 03:25:07PM -0500, Johannes Weiner wrote:
> On Fri, Dec 13, 2013 at 02:10:03PM +0000, Mel Gorman wrote:
> > zone_local is using node_distance which is a more expensive call than
> > necessary. On x86, it's another function call in the allocator fast path
> > and increases cache footprint. This patch makes the assumption zones on a
> > local node will share the same node ID. The necessary information should
> > already be cache hot.
> > 
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > ---
> >  mm/page_alloc.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 64020eb..fd9677e 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1816,7 +1816,7 @@ static void zlc_clear_zones_full(struct zonelist *zonelist)
> >  
> >  static bool zone_local(struct zone *local_zone, struct zone *zone)
> >  {
> > -	return node_distance(local_zone->node, zone->node) == LOCAL_DISTANCE;
> > +	return zone_to_nid(zone) == numa_node_id();
> 
> Why numa_node_id()?  We pass in the preferred zone as @local_zone:
> 

Initially because I was thinking "local node" and numa_node_id() is a
per-cpu variable that should be cheap to access and in some cases
cache-hot as the top-level gfp API calls numa_node_id().

Thinking about it more though it still makes sense because the preferred
zone is not necessarily local. If the allocation request requires ZONE_DMA32
and the local node does not have that zone then preferred zone is on a
remote node.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
