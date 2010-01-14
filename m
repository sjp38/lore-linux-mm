Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 342D86B006A
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 13:01:36 -0500 (EST)
Date: Thu, 14 Jan 2010 11:01:33 -0700
From: Alex Chiang <achiang@hp.com>
Subject: Re: SLUB ia64 linux-next crash bisected to 756dee75
Message-ID: <20100114180133.GA4545@ldl.fc.hp.com>
References: <20100113002923.GF2985@ldl.fc.hp.com> <alpine.DEB.2.00.1001130851310.24496@router.home> <20100114005304.GC27766@ldl.fc.hp.com> <alpine.DEB.2.00.1001140858460.14164@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1001140858460.14164@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: penberg@cs.helsinki.fi, linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Christoph Lameter <cl@linux-foundation.org>:
> On Wed, 13 Jan 2010, Alex Chiang wrote:
> 
> > Firmware puts each cell into a NUMA node, so we should really
> > only have 2 nodes, but for some reason, that 3rd node gets
> > created too. I haven't inspected the SRAT/SLIT on this machine
> > recently, but can do so if you want me to.
> 
> May not have anything to do with the problem we are looking at but memory
> setup is screwed up. Funky effects may follow.

Actually, I was reminded off-list by my HP colleagues that the
memory setup I showed you is common on mid-range and high-end HP
ia64 platforms.

Lee tells me:

	The third node is the "interleaved memory" pseudo-node.
	The firmware always interleaves 512MB of phys address
	space across the nodes.  On these platforms, only
	interleaved memory is at phys addr 0--needed by firmware,
	...  All the real NUMA nodes' memory starts at some high
	phys addr. So, even in "numa mode" [a.k.a. 100% cell
	local memory], the firmware must create a region of
	interleaved memory at phys 0.  So, we get N+1 nodes.

	Because node 2 is at phys 0 and contains only 512MB, it
	is all ZONE_DMA memory.  DMA zone is 1st 4G on ia64.

Our platforms have been shipping like this for years, so it's not
like anything recent has changed.

Thanks,
/ac

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
