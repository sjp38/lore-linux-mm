Date: Mon, 13 Aug 2007 15:00:14 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 3/4] Embed zone_id information within the zonelist->zones
 pointer
In-Reply-To: <20070813225020.GE3406@bingen.suse.de>
Message-ID: <Pine.LNX.4.64.0708131457190.28445@schroedinger.engr.sgi.com>
References: <20070809210616.14702.73376.sendpatchset@skynet.skynet.ie>
 <200708102013.49170.ak@suse.de> <Pine.LNX.4.64.0708101201240.17549@schroedinger.engr.sgi.com>
 <200708110304.55433.ak@suse.de> <Pine.LNX.4.64.0708131423050.28026@schroedinger.engr.sgi.com>
 <20070813225020.GE3406@bingen.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Mel Gorman <mel@skynet.ie>, Lee.Schermerhorn@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 14 Aug 2007, Andi Kleen wrote:

> > > The DMA zone will be still there, but only reachable with special functions.
> > 
> > Not too happy with that one but this is going the right direcrtion.
> > 
> > On NUMA this would still mean allocating space for the DMA zone on all 
> > nodes although we only need this on node 0.
> 
> The DMA allocator is NUMA unaware. This means it doesn't require multiple
> dma zones per node, but is happy with a global one that can live somewhere
> else outside the pgdat. I also removed PCP and other fanciness so it's
> really quite independent and much simpler than the normal one.  It also
> doesn't need try_to_free_pages() because in a isolated zone there
> shouldn't be any freeable pages.

You said that ZONE_DMA will still be there right? So the zone will be 
replicated over all nodes but remain unused except for node 0.

> There are still other architectures that use it. Biggest offender
> is s390. I'll leave them to their respective maintainers.

IA64 also uses ZONE_DMA to support 32bit controllers. 

So I think we can only get rid of ZONE_DMA in its 16MB incarnation for 
i386 and x86_64.

But you will be keeping ZONE_DMA32?

If so then it may be better to drop ZONE_DMA32 and make ZONE_DMA be below 
4GB like other 64bit arches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
