Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5285F6B0087
	for <linux-mm@kvack.org>; Sat, 23 Oct 2010 21:42:59 -0400 (EDT)
Date: Sun, 24 Oct 2010 12:42:56 +1100
From: Nick Piggin <npiggin@kernel.dk>
Subject: Re: shrinkers: Add node to indicate where to target shrinking
Message-ID: <20101024014256.GD3168@amd>
References: <alpine.DEB.2.00.1010211255570.24115@router.home>
 <alpine.DEB.2.00.1010211259360.24115@router.home>
 <20101021235854.GD3270@amd>
 <20101022155513.GA26790@infradead.org>
 <alpine.DEB.2.00.1010221121550.22051@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1010221121550.22051@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Christoph Hellwig <hch@infradead.org>, Nick Piggin <npiggin@kernel.dk>, akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 22, 2010 at 11:32:37AM -0500, Christoph Lameter wrote:
> On Fri, 22 Oct 2010, Christoph Hellwig wrote:
> >
> > I think making shrinking decision per-zone is fine.  But do we need to
> > duplicate all the lru lists and infrastructure per-zone for that instead
> > of simply per-zone?   Even with per-node lists we can easily skip over
> > items from the wrong zone.
> >
> > Given that we have up to 6 zones per node currently, and we would mostly
> > use one with a few fallbacks that seems like a lot of overkill.
> 
> Zones can also cause asymmetry in reclaim if per zone reclaim is done.
> 
> Look at the following zone setup of a Dell R910:
> 
> grep "^Node" /proc/zoneinfo
> Node 0, zone      DMA
> Node 0, zone    DMA32
> Node 0, zone   Normal
> Node 1, zone   Normal
> Node 2, zone   Normal
> Node 3, zone   Normal
> 
> A reclaim that does per zone reclaim (but in reality reclaims all objects
> in a node (or worse as most shrinkers do today in the whole system) will
> put 3x the pressure on node 0.

No it doesn't. This is how it works:

node0zoneD has 1% of pagecache for node 0
node0zoneD32 has 9% of pagecache
node0zoneN has 90% of pagecache

If there is a memory shortage in all node0 zones, the first zone will
get 1% of the pagecache scanning pressure, dma32 will get 9% and normal
will get 90%, for equal pressure on each zone.

In my patch, those numbers will pass through to shrinker for each zone,
and ask the shrinker to scan and equal proportion of objects in each of
its zones.

If you have a per node shrinker, you will get asymmetries in pressures
whenever there is not an equal amount of reclaimable objects in all
the zones of a node.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
