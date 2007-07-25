Date: Wed, 25 Jul 2007 18:39:07 +0100
Subject: Re: NUMA policy issues with ZONE_MOVABLE
Message-ID: <20070725173907.GA1750@skynet.ie>
References: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com> <1185373621.5604.28.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1185373621.5604.28.camel@localhost>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, ak@suse.de, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On (25/07/07 10:27), Lee Schermerhorn didst pronounce:
> On Tue, 2007-07-24 at 21:20 -0700, Christoph Lameter wrote:
> > The outcome of the 2.6.23 merge was surprising. No antifrag but only 
> > ZONE_MOVABLE. ZONE_MOVABLE is the highest zone.
> > 
> > For the NUMA layer this has some weird consequences if ZONE_MOVABLE is populated
> > 
> > 1. It is the highest zone.
> > 
> > 2. Thus policy_zone == ZONE_MOVABLE
> > 
> > ZONE_MOVABLE contains only movable allocs by default. That is anonymous 
> > pages and page cache pages?
> > 
> > The NUMA layer only supports NUMA policies for the highest zone. 
> > Thus NUMA policies can control anonymous pages and the page cache pages 
> > allocated from ZONE_MOVABLE. 
> > 
> > However, NUMA policies will no longer affect non pagecache and non 
> > anonymous allocations. So policies can no longer redirect slab allocations 
> > and huge page allocations (unless huge page allocations are moved to 
> > ZONE_MOVABLE). And there are likely other allocations that are not 
> > movable.
> > 
> > If ZONE_MOVABLE is off then things should be working as normal.
> > 
> > Doesnt this mean that ZONE_MOVABLE is incompatible with CONFIG_NUMA?
> > 
> > 
> > The mobility approach used subcategories of a zone which would have 
> > allowed the application of memory policies.
> 
> Isn't ZONE_MOVABLE always a subset of the memory in the highest "real"
> zone--the one that WOULD be policy_zone if ZONE_MOVABLE weren't
> configured? 

Yes, it is always the case because the selected zone is always the same
zone as policy_zone.

> If so, perhaps we could just not assign ZONE_MOVABLE to
> policy_zone in check_highest zone. 

Yep.

> We already check for >= or <
> policy_zone where it's checked [zonelist_policy() and vma_migratable()],
> so ZONE_MOVABLE will get a free pass if we clip policy_zone at the
> highest !MOVABLE zone.
> 

Fully agreed on all counts. I'm pleased that this is pretty much
identical to what I have in the patch.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
