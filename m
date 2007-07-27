Subject: Re: NUMA policy issues with ZONE_MOVABLE
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070726225920.GA10225@skynet.ie>
References: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com>
	 <20070725111646.GA9098@skynet.ie>
	 <Pine.LNX.4.64.0707251212300.8820@schroedinger.engr.sgi.com>
	 <20070726132336.GA18825@skynet.ie>
	 <Pine.LNX.4.64.0707261104360.2374@schroedinger.engr.sgi.com>
	 <20070726225920.GA10225@skynet.ie>
Content-Type: text/plain
Date: Fri, 27 Jul 2007 10:24:19 -0400
Message-Id: <1185546260.5069.10.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, ak@suse.de, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, akpm@linux-foundation.org, pj@sgi.com, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-07-26 at 23:59 +0100, Mel Gorman wrote:
> On (26/07/07 11:07), Christoph Lameter didst pronounce:
> > On Thu, 26 Jul 2007, Mel Gorman wrote:
> > 
> > > > How about changing __alloc_pages to lookup the zonelist on its own based 
> > > > on a node parameter and a set of allowed nodes? That may significantly 
> > > > clean up the memory policy layer and the cpuset layer. But it will 
> > > > increase the effort to scan zonelists on each allocation. A large system 
> > > > with 1024 nodes may have more than 1024 zones on each nodelist!
> > > > 
> > > 
> > > That sounds like it would require the creation of a zonelist for each
> > > allocation attempt. That is not ideal as there is no place to allocate
> > > the zonelist during __alloc_pages(). It's not like it can call
> > > kmalloc().
> > 
> > Nope it would just require scanning the full zonelists on every alloc as 
> > you already propose.
> > 
> 
> Right. For this current problem, I would rather not to that. I would rather
> fix the bug at hand for 2.6.23 and aim to reduce the number of zonelists in
> the next timeframe after a spell in -mm and wider testing. This is to reduce
> the risk of introducing performance regressions for a bugfix.
> 
> > > > Nope it would not fail. NUMAQ has policy_zone == HIGHMEM and slab 
> > > > allocations do not use highmem.
> > > 
> > > It would fail if policy_zone didn't exist, that was my point. Without
> > > policy_zone, we apply policy to all allocations and that causes
> > > problems.
> > 
> > policy_zone can not exist due to ZONE_DMA32 ZONE_NORMAL issues. See my 
> > other email.
> > 
> > 
> > > I ran the patch on a wide variety of machines, NUMA and non-NUMA. The
> > > non-NUMA machines showed no differences as you would expect for
> > > kernbench and aim9. On NUMA machines, I saw both small gains and small
> > > regressions. By and large, the performance was the same or within 0.08%
> > > for kernbench which is within noise basically.
> > 
> > Sound okay.
> > 
> > > It might be more pronounced on larger NUMA machines though, I cannot
> > > generate those figures.
> > 
> > I say lets go with the filtering. That would allow us to also catch other 
> > issues that are now developing on x86_64 with ZONE_NORMAL and ZONE_DMA32.
> >  
> > > I'll try adding a should_filter to zonelist that is only set for
> > > MPOL_BIND and see what it looks like.
> > 
> > Maybe that is not worth it.
> 
> This patch filters only when MPOL_BIND is in use. In non-numa, the
> checks do not exist and in NUMA cases, the filtering usually does not
> take place. I'd like this to be the bug fix for policy + ZONE_MOVABLE
> and then deal with reducing zonelists to see if there is any performance
> gain as well as a simplification in how policies and cpusets are
> implemented.
> 
> Testing shows no difference on non-numa as you'd expect and on NUMA machines,
> there are very small differences on NUMA (kernbench figures range from -0.02%
> to 0.15% differences on machines). Lee, can you test this patch in relation
> to MPOL_BIND?  I'll look at the numactl tests tomorrow as well.
> 
> Comments?
> 
<snip>

Mel,

I'll queue this up.  Not sure I'll get to it before the weekend, tho'.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
