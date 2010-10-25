Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6EBA78D0001
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 11:00:24 -0400 (EDT)
Date: Mon, 25 Oct 2010 09:59:58 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: shrinkers: Add node to indicate where to target shrinking
In-Reply-To: <20101024014256.GD3168@amd>
Message-ID: <alpine.DEB.2.00.1010250957120.7461@router.home>
References: <alpine.DEB.2.00.1010211255570.24115@router.home> <alpine.DEB.2.00.1010211259360.24115@router.home> <20101021235854.GD3270@amd> <20101022155513.GA26790@infradead.org> <alpine.DEB.2.00.1010221121550.22051@router.home> <20101024014256.GD3168@amd>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@kernel.dk>
Cc: Christoph Hellwig <hch@infradead.org>, akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Sun, 24 Oct 2010, Nick Piggin wrote:

> > A reclaim that does per zone reclaim (but in reality reclaims all objects
> > in a node (or worse as most shrinkers do today in the whole system) will
> > put 3x the pressure on node 0.
>
> No it doesn't. This is how it works:
>
> node0zoneD has 1% of pagecache for node 0
> node0zoneD32 has 9% of pagecache
> node0zoneN has 90% of pagecache
>
> If there is a memory shortage in all node0 zones, the first zone will
> get 1% of the pagecache scanning pressure, dma32 will get 9% and normal
> will get 90%, for equal pressure on each zone.
>
> In my patch, those numbers will pass through to shrinker for each zone,
> and ask the shrinker to scan and equal proportion of objects in each of
> its zones.

Many shrinkers do not implement such a scheme.

> If you have a per node shrinker, you will get asymmetries in pressures
> whenever there is not an equal amount of reclaimable objects in all
> the zones of a node.

Sure there would be different amounts allocated in the various nodes but
you will get an equal amount of calls to the shrinkers. Anyways as you
pointed out the shrinker can select the zones it will perform reclaim on.
So for the slab shrinker it would not be an issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
