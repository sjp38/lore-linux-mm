Date: Fri, 1 Aug 2008 17:26:57 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: memory hotplug: hot-add to ZONE_MOVABLE vs. min_free_kbytes
Message-ID: <20080801162656.GA10388@csn.ul.ie>
References: <20080723105318.81BC.E1E9C6FF@jp.fujitsu.com> <1217347653.4829.17.camel@localhost.localdomain> <20080730110444.27DE.E1E9C6FF@jp.fujitsu.com> <1217420161.4545.10.camel@localhost.localdomain> <20080731132213.GF1704@csn.ul.ie> <1217526327.4643.35.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1217526327.4643.35.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, Andy Whitcroft <apw@shadowen.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On (31/07/08 19:45), Gerald Schaefer didst pronounce:
> On Thu, 2008-07-31 at 14:22 +0100, Mel Gorman wrote:
> > > The more memory we add to ZONE_MOVABLE, the less reserved pages will
> > > remain to the other zones. In setup_per_zone_pages_min(), min_free_kbytes
> > > will be redistributed to a zone where the kernel cannot make any use of
> > > it, effectively reducing the available min_free_kbytes. 
> > 
> > I'm not sure what you mean by "available min_free_kbytes". The overall value
> > for min_free_kbytes should be approximately the same whether the zone exists
> > or not. However, you're right in that the distribution of minimum free pages
> > changes with ZONE_MOVABLE because the zones are different sizes now. This
> > affects reclaim, not memory hot-remove.
> 
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

Ok, I haven't double checked your figures but lets go with the assumption -
adding memory means min_free_kbytes will be distributed differently.

> My assumption is now, that the reserved 3 MB in ZONE_MOVABLE won't be
> usable by the kernel anymore, e.g. for PF_MEMALLOC, because it is in
> ZONE_MOVABLE now.

Nothing stops PF_MEMALLOC being used and the only thing that stops 3MB
being used in ZONE_MOVABLE is min_free_kbytes, not the fact there is a
MIGRATE_RESERVE there. PF_MEMALLOC and MIGRATE_RESERVE are not related.

I think you are confusing what MIGRATE_RESERVE is for. A number of pageblocks
at the start of a zone are marked MIGRATE_RESERVE depending on the size of
min_free_kbytes for that value. The kernel will try avoiding allocating from
there so that high-order-atomic-allocatons have a chance of succeeding from
there. It's not kept aside for emergency-allocations.

> This is what I mean with "effectively reducing the
> available min_free_kbytes". The system would now behave in the same way
> as a system which only had 1 MB of min_free_kbytes, although
> /proc/sys/vm/min_free_kbytes would still say 4 MB. After all, this tunable
> can have a rather negative impact on a system, especially if it is too
> low, hence my concerns.
> 

Increase min_free_kbytes on memory hot-add?

> 
> > > This just doesn't
> > > sound right. I believe that a similar situation is the reason why highmem
> > > pages are skipped in the calculation and I think that we need that for
> > > ZONE_MOVABLE too. Any thoughts on that problem?
> > > 
> > 
> > is_highmem(ZONE_MOVABLE) should be returning true if the zone is really
> > part of himem.
> 
> We don't have highmem on s390, I was just trying to give an example: I
> noticed that there is special treatment for highmem pages in
> setup_per_zone_pages_min(), and thought that we may also need to handle
> ZONE_MOVABLE in a special way.
> 

ZONE_MOVABLE should be treated the same as highmem would be in terms of
tuning

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
> 

Ok, I'm losing track here, maybe it's just too late on a friday. right now,
ZONE_MOVABLE should be setup similar to what HIGHMEM would have been. It
shouldn't get its pages_min value set to 0 and even if it did, it would not
help memory hot-remove.

Also, nothing stops __GFP_HIGH or PF_MEMALLOC using ZONE_MOVABLE as long as the
caller is using __GFP_MOVABLE. However, as it is unlikely that combination
of flags would occur I'd be open to examining how min_free_kbytes gets
distibuted. It is an independent topic to why the beginning of the zone is
not removable though. I suspect MIGRATE_RESERVE is a red herring.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
