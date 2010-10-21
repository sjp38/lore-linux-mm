Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D00135F0040
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 16:15:07 -0400 (EDT)
Date: Thu, 21 Oct 2010 13:14:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: vmscan: Do not run shrinkers for zones other than ZONE_NORMAL
Message-Id: <20101021131428.f2f7214a.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1010211455100.30295@router.home>
References: <alpine.DEB.2.00.1010211255570.24115@router.home>
	<20101021124054.14b85e50.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1010211455100.30295@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: npiggin@kernel.dk, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Thu, 21 Oct 2010 15:03:32 -0500 (CDT)
Christoph Lameter <cl@linux.com> wrote:

> On Thu, 21 Oct 2010, Andrew Morton wrote:
> 
> > The patch doesn't patch direct reclaim, in do_try_to_free_pages().  How
> > come?
> 
> Direct reclaim does not run node specific shrink_slab. Direct reclaim does
> a general pass after the individual zones have been shrunk.
> 
> > OK, maybe this.  Suppose we have a machine with 800M lowmem and 200M
> > highmem.  And suppose the lowmem region is stuffed full of clean
> > icache/dcache.  A __GFP_HIGHMEM allocation should put pressure on
> > lowmem to get some of those pages back.  What we don't want to do is to
> > keep on reclaiming the highmem zone and allocating pages from there,
> > because the machine would effectively end up with only 200M available
> > for pagecache.
> 
> Shrinker reclaim is not zone specific. It either occurs on a node or on
> the system as a whole. A failure of HIGHMEM allocation in the direct
> reclaim path will result in shrinkers being called with NO_NUMA_NODE and
> therefore global reclaim will take place everywhere.
> 
> Per node reclaim occurs from kswapd and covers all zones of that node.
> 
> > Please convince us that your patch doesn't screw up zone balancing?
> 
> There are no slab allocations in HIGHMEM or MOVABLE. Nothing to balance
> there.
> 

The patch changes balance_pgdat() to not shrink slab when inspecting
the highmem zone.  It will therefore change zone balancing behaviour on
a humble 1G laptop, will it not?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
