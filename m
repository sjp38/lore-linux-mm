Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id CF37B6B016B
	for <linux-mm@kvack.org>; Wed,  3 Aug 2011 16:22:06 -0400 (EDT)
Date: Wed, 3 Aug 2011 22:21:46 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [patch 4/5] mm: writeback: throttle __GFP_WRITE on per-zone
 dirty limits
Message-ID: <20110803202146.GB5873@redhat.com>
References: <1311625159-13771-1-git-send-email-jweiner@redhat.com>
 <1311625159-13771-5-git-send-email-jweiner@redhat.com>
 <20110726144242.GD3010@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110726144242.GD3010@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, linux-kernel@vger.kernel.org

On Tue, Jul 26, 2011 at 03:42:42PM +0100, Mel Gorman wrote:
> On Mon, Jul 25, 2011 at 10:19:18PM +0200, Johannes Weiner wrote:
> > From: Johannes Weiner <hannes@cmpxchg.org>
> > 
> > Allow allocators to pass __GFP_WRITE when they know in advance that
> > the allocated page will be written to and become dirty soon.
> > 
> > The page allocator will then attempt to distribute those allocations
> > across zones, such that no single zone will end up full of dirty and
> > thus more or less unreclaimable pages.
> > 
> 
> On 32-bit, this idea increases lowmem pressure. Ordinarily, this is
> only a problem when the higher zone is really large and management
> structures can only be allocated from the lower zones. Granted,
> it is rare this is the case but in the last 6 months, I've seen at
> least one bug report that could be attributed to lowmem pressure
> (24G x86 machine).
> 
> A brief explanation as to why this is not a problem may be needed.

Only lowmem is considered dirtyable memory per default, so more
highmem does not mean more dirty pages.  If the highmem zone is equal
to or bigger than the lowmem zones, the amount of dirtyable memory
(dirty_ratio * lowmem) can still be placed completely into the highmem
zone (dirty_ratio * highmem) - if the gfp_mask allows for it.

For this patchset, I (blindly) copied this highmem exclusion also when
it comes to allocation placement, with the result that no highmem page
is allowed for __GFP_WRITE.  I need to fix this.

But generally, this patchset rather protects lower zones.  As the
higher zones fill up with first-dirty-then-clean-pages, subsequent
allocations for soon-dirty pages fill up the lower zones.  The
per-zone dirty limit prevents that and forces the allocator to reclaim
the clean pages of the higher zone(s) instead.  This was observable
with the DMA zone during testing for example, which hat consistently
less dirty pages in it on the patched kernel.

> > The global dirty limits are put in proportion to the respective zone's
> > amount of dirtyable memory and the allocation denied when the limit of
> > that zone is reached.
> > 
> 
> What are the risks of a process stalling on dirty pages in a high zone
> that is very small (e.g. 64M) ?

It will fall back to the lower zones.  I should have added that...

The allocation will only stall if all considered zones reached their
dirty limits.  At this point, the implementation basically bangs its
head against the wall until it passes out, hoping the flushers catch
up in the meantime.  There might be some space for improvement.

> > @@ -85,6 +86,7 @@ struct vm_area_struct;
> >  
> >  #define __GFP_NO_KSWAPD	((__force gfp_t)___GFP_NO_KSWAPD)
> >  #define __GFP_OTHER_NODE ((__force gfp_t)___GFP_OTHER_NODE) /* On behalf of other node */
> > +#define __GFP_WRITE	((__force gfp_t)___GFP_WRITE)	/* Will be dirtied soon */
> >  
> 
> /* May be dirtied soon */ :)

Right :)

> > diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> > index 41dc871..ce673ec 100644
> > --- a/mm/page-writeback.c
> > +++ b/mm/page-writeback.c
> > @@ -154,6 +154,18 @@ static unsigned long determine_dirtyable_memory(void)
> >  	return x + 1;	/* Ensure that we never return 0 */
> >  }
> >  
> > +static unsigned long zone_dirtyable_memory(struct zone *zone)
> > +{
> 
> Terse comment there :)

I tried to write more but was forced to balance dirty laundry.

"Document interfaces" is on the todo list for the next version,
though.

> > +	unsigned long x = 1; /* Ensure that we never return 0 */
> > +
> > +	if (is_highmem(zone) && !vm_highmem_is_dirtyable)
> > +		return x;
> > +
> > +	x += zone_page_state(zone, NR_FREE_PAGES);
> > +	x += zone_reclaimable_pages(zone);
> > +	return x;
> > +}
> 
> It's very similar to determine_dirtyable_memory(). Would be preferable
> if the shared a core function of some sort even if that was implemented
> as by "if (zone == NULL)". Otherwise, these will get out of sync
> eventually.

That makes sense, I'll do that.

> > @@ -378,6 +390,24 @@ int bdi_set_max_ratio(struct backing_dev_info *bdi, unsigned max_ratio)
> >  }
> >  EXPORT_SYMBOL(bdi_set_max_ratio);
> >  
> > +static void sanitize_dirty_limits(unsigned long *pbackground,
> > +				  unsigned long *pdirty)
> > +{
> 
> Maybe a small comment saying to look at the comment in
> global_dirty_limits() to see what this is doing and why.
> 
> sanitize feels like an odd name to me. The arguements are not
> "objectionable" in some way that needs to be corrected.
> scale_dirty_limits maybe?

The background limit is kind of sanitized if it exceeds the foreground
limit.  But yeah, the name sucks given that this is not all the
function does.

I'll just go with scale_dirty_limits().

> > @@ -661,6 +710,57 @@ void throttle_vm_writeout(gfp_t gfp_mask)
> >          }
> >  }
> >  
> > +bool zone_dirty_ok(struct zone *zone)
> > +{
> > +	unsigned long background_thresh, dirty_thresh;
> > +	unsigned long nr_reclaimable, nr_writeback;
> > +
> > +	zone_dirty_limits(zone, &background_thresh, &dirty_thresh);
> > +
> > +	nr_reclaimable = zone_page_state(zone, NR_FILE_DIRTY) +
> > +		zone_page_state(zone, NR_UNSTABLE_NFS);
> > +	nr_writeback = zone_page_state(zone, NR_WRITEBACK);
> > +
> > +	return nr_reclaimable + nr_writeback <= dirty_thresh;
> > +}
> > +
> > +void try_to_writeback_pages(struct zonelist *zonelist, gfp_t gfp_mask,
> > +			    nodemask_t *nodemask)
> > +{
> > +	unsigned int nr_exceeded = 0;
> > +	unsigned int nr_zones = 0;
> > +	struct zoneref *z;
> > +	struct zone *zone;
> > +
> > +	for_each_zone_zonelist_nodemask(zone, z, zonelist, gfp_zone(gfp_mask),
> > +					nodemask) {
> > +		unsigned long background_thresh, dirty_thresh;
> > +		unsigned long nr_reclaimable, nr_writeback;
> > +
> > +		nr_zones++;
> > +
> > +		zone_dirty_limits(zone, &background_thresh, &dirty_thresh);
> > +
> > +		nr_reclaimable = zone_page_state(zone, NR_FILE_DIRTY) +
> > +			zone_page_state(zone, NR_UNSTABLE_NFS);
> > +		nr_writeback = zone_page_state(zone, NR_WRITEBACK);
> > +
> > +		if (nr_reclaimable + nr_writeback <= background_thresh)
> > +			continue;
> > +
> > +		if (nr_reclaimable > nr_writeback)
> > +			wakeup_flusher_threads(nr_reclaimable - nr_writeback);
> > +
> 
> This is a potential mess. wakeup_flusher_threads() ultimately
> calls "work = kzalloc(sizeof(*work), GFP_ATOMIC)" from the page
> allocator. Under enough pressure, particularly if the machine has
> very little memory, you may see this spewing out warning messages
> which ironically will have to be written to syslog dirtying more
> pages.  I know I've made the same mistake at least once by calling
> wakeup_flusher_thrads() from page reclaim.

Oops.  Actually, I chose to do this as I remembered your patches
trying to add calls like this.

The problem really is that I have no better idea what to do if all
considered zones exceed their dirty limit.

I think it would be much better to do nothing more than to check for
the global dirty limit and wait for some writeback, then try other
means of reclaim.  If fallback to other nodes is allowed, all
dirtyable zones have been considered and the global dirty limit MUST
be exceeded, writeback is happening.  If a specific node is requested
that has reached its per-zone dirty limits, there are likely clean
pages around to reclaim.

> It's also still not controlling where the pages are being
> written from.  On a large enough NUMA machine, there is a risk that
> wakeup_flusher_treads() will be called very frequently to write pages
> from remote nodes that are not in trouble.

> > +		if (nr_reclaimable + nr_writeback <= dirty_thresh)
> > +			continue;
> > +
> > +		nr_exceeded++;
> > +	}
> > +
> > +	if (nr_zones == nr_exceeded)
> > +		congestion_wait(BLK_RW_ASYNC, HZ/10);
> > +}
> > +
> 
> So, you congestion wait but then potentially continue on even
> though it is still over the dirty limits.  Should this be more like
> throttle_vm_writeout()?

I need to think about what to do here in general a bit more.

> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 4e8985a..1fac154 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1666,6 +1666,9 @@ zonelist_scan:
> >  			!cpuset_zone_allowed_softwall(zone, gfp_mask))
> >  				goto try_next_zone;
> >  
> > +		if ((gfp_mask & __GFP_WRITE) && !zone_dirty_ok(zone))
> > +			goto this_zone_full;
> > +
> 
> So this part needs to explain why using the lower zones does not
> potentially cause lowmem pressure on 32-bit. It's not a show stopper
> as such but it shouldn't be ignored either.

Agreed.

> > @@ -2135,6 +2154,14 @@ rebalance:
> >  	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
> >  		goto nopage;
> >  
> > +	/* Try writing back pages if per-zone dirty limits are reached */
> > +	page = __alloc_pages_writeback(gfp_mask, order, zonelist,
> > +				       high_zoneidx, nodemask,
> > +				       alloc_flags, preferred_zone,
> > +				       migratetype);
> > +	if (page)
> > +		goto got_pg;
> > +
> 
> I like the general idea but we are still not controlling where
> pages are being written from, the potential lowmem pressure problem
> needs to be addressed and care needs to be taken with the frequency
> wakeup_flusher_threads is called due to it using kmalloc.
> 
> I suspect where the performance gain is being seen is due to
> the flusher threads being woken earlier, more frequently and are
> aggressively writing due to wakeup_flusher_threads() passing in loads
> of requests. As you are seeing a performance gain, that is interesting
> in itself if it is true.

As written in another email, the flushers are never woken through this
code in the tests.  The benefits really come from keeping enough clean
pages in the zones and reduce reclaim latencies.

Thanks for your input.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
