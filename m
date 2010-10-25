Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 796B36B0095
	for <linux-mm@kvack.org>; Sun, 24 Oct 2010 20:57:19 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9P0vG19025210
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 25 Oct 2010 09:57:17 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5EB5545DE4D
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 09:57:16 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E6CC45DE60
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 09:57:16 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E4B461DB803E
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 09:57:15 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 61E9F1DB803A
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 09:57:15 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: shrinkers: Add node to indicate where to target shrinking
In-Reply-To: <20101024014256.GD3168@amd>
References: <alpine.DEB.2.00.1010221121550.22051@router.home> <20101024014256.GD3168@amd>
Message-Id: <20101025095004.9157.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 25 Oct 2010 09:57:13 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@kernel.dk>
Cc: kosaki.motohiro@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, Christoph Hellwig <hch@infradead.org>, akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

> On Fri, Oct 22, 2010 at 11:32:37AM -0500, Christoph Lameter wrote:
> > On Fri, 22 Oct 2010, Christoph Hellwig wrote:
> > >
> > > I think making shrinking decision per-zone is fine.  But do we need to
> > > duplicate all the lru lists and infrastructure per-zone for that instead
> > > of simply per-zone?   Even with per-node lists we can easily skip over
> > > items from the wrong zone.
> > >
> > > Given that we have up to 6 zones per node currently, and we would mostly
> > > use one with a few fallbacks that seems like a lot of overkill.
> > 
> > Zones can also cause asymmetry in reclaim if per zone reclaim is done.
> > 
> > Look at the following zone setup of a Dell R910:
> > 
> > grep "^Node" /proc/zoneinfo
> > Node 0, zone      DMA
> > Node 0, zone    DMA32
> > Node 0, zone   Normal
> > Node 1, zone   Normal
> > Node 2, zone   Normal
> > Node 3, zone   Normal
> > 
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
> 
> If you have a per node shrinker, you will get asymmetries in pressures
> whenever there is not an equal amount of reclaimable objects in all
> the zones of a node.

Interesting. your explanation itself seems correct. but it inspire me
that there is another issue in both Christoph and your patch.

On ideal 32bit highmem system, memory usage are

	DMA:	unused
	NORMAL:	100% slab, 0% page cache
	HIGHMEM: 0% slab, 100% page cache

So, per-zone slab/page-cache shrinker balancing logic don't works on
32bit x86. kswapd should reclaim some objects from normal zone even if
it couldn't reclaim any page cache from normal zone.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
