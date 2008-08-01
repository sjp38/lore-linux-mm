Date: Fri, 01 Aug 2008 20:16:20 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: memory hotplug: hot-add to ZONE_MOVABLE vs. min_free_kbytes
In-Reply-To: <1217526327.4643.35.camel@localhost.localdomain>
References: <20080731132213.GF1704@csn.ul.ie> <1217526327.4643.35.camel@localhost.localdomain>
Message-Id: <20080801192646.EC99.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, Andy Whitcroft <apw@shadowen.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> Sorry for mixing things up in this thread, the min_free_kbytes issue is
> not related to memory hot-remove, but rather to hot-add and the things that
> happen in setup_per_zone_pages_min(), which is called from online_pages().
> It may well be that my assumptions are wrong, but I'd like to explain my
> concerns again:
> 
> If we have a system with 1 GB of memory, min_free_kbytes will be calculated
> to 4 MB for ZONE_NORMAL, for example. Now, if we add 3 GB of hotplug memory
> to ZONE_MOVABLE, the total min_free_kbytes will still remain 4 MB but it
> will be distributed differently: ZONE_NORMAL will now have only 1 MB of
> MIGRATE_RESERVE memory left, while ZONE_MOVABLE will have 3 MB, e.g.
> 

Right.

> My assumption is now, that the reserved 3 MB in ZONE_MOVABLE won't be
> usable by the kernel anymore, e.g. for PF_MEMALLOC, because it is in
> ZONE_MOVABLE now.

I don't make sense here. I suppose there is no relationship between
ZONE_MOVABLE, PF_MEMALLOC and MIGRATE_RESERVE pages.
Could you tell me more?


> This is what I mean with "effectively reducing the
> available min_free_kbytes". The system would now behave in the same way
> as a system which only had 1 MB of min_free_kbytes, although
> /proc/sys/vm/min_free_kbytes would still say 4 MB. After all, this tunable
> can have a rather negative impact on a system, especially if it is too
> low, hence my concerns.
>
> > > Setting pages_min to 0 for ZONE_MOVABLE, while not capping pages_low
> > > and pages_high, could be an option. I don't have a sufficient memory
> > > managment overview to tell if that has negative side effects, maybe
> > > someone with a deeper insight could comment on that.
> > > 
> > 
> > pages_min of 0 means the other values would be 0 as well. This means that
> > kswapd may never be woken up to free pages within that zone and lead to
> > poor utilisation of the zone as allocators fallback to other zones to
> > avoid direct reclaim. I don't think that is your intention nor will it
> > help memory hot-remove.
> 
> Do you mean pages_low and pages_high? In setup_per_zone_pages_min(),
> those would not be set to 0, even if we set pages_min to 0. Again, a
> similar strategy is being used for highmem in that function, only that
> pages_min is set to a small value instead of 0 in that case. So it should
> not affect kswapd but only __GFP_HIGH and PF_MEMALLOC allocations, which
> won't be allocated from ZONE_MOVABLE anyway if I understood that right.


pages_min seems to be used in get_pages_from_freelist().
Do you mean following is not executed?


                if (!(alloc_flags & ALLOC_NO_WATERMARKS)) {
                        unsigned long mark;
                        if (alloc_flags & ALLOC_WMARK_MIN)
                                mark = zone->pages_min;           <------!!!
                        else if (alloc_flags & ALLOC_WMARK_LOW)
                                mark = zone->pages_low;
                        else
                                mark = zone->pages_high;
                        if (!zone_watermark_ok(zone, order, mark,   <-----!!!
                                    classzone_idx, alloc_flags)) {
                                if (!zone_reclaim_mode ||
                                    !zone_reclaim(zone, gfp_mask, order))
                                        goto this_zone_full;
                        }
                }

But even if pages_min is not used as you said, I suppose it is
accidental by changing source code.
It should work as watermark to keep its meaning.
If not, it would be cause of bug in the future by misunderstanding.


Bye.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
