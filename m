Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 16A439000BD
	for <linux-mm@kvack.org>; Thu, 22 Sep 2011 04:53:07 -0400 (EDT)
Date: Thu, 22 Sep 2011 10:52:42 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [patch 2/4] mm: writeback: distribute write pages across
 allowable zones
Message-ID: <20110922085242.GA29046@redhat.com>
References: <1316526315-16801-1-git-send-email-jweiner@redhat.com>
 <1316526315-16801-3-git-send-email-jweiner@redhat.com>
 <20110921160226.1bf74494.akpm@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110921160226.1bf74494.akpm@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@google.com>
Cc: Mel Gorman <mgorman@suse.de>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Chris Mason <chris.mason@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, xfs@oss.sgi.com, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Wed, Sep 21, 2011 at 04:02:26PM -0700, Andrew Morton wrote:
> On Tue, 20 Sep 2011 15:45:13 +0200
> Johannes Weiner <jweiner@redhat.com> wrote:
> 
> > This patch allows allocators to pass __GFP_WRITE when they know in
> > advance that the allocated page will be written to and become dirty
> > soon.  The page allocator will then attempt to distribute those
> > allocations across zones, such that no single zone will end up full of
> > dirty, and thus more or less, unreclaimable pages.
> 
> Across all zones, or across the zones within the node or what?  Some
> more description of how all this plays with NUMA is needed, please.

Across the zones the allocator considers for allocation, which on NUMA
is determined by the allocating task's NUMA memory policy.

> > The global dirty limits are put in proportion to the respective zone's
> > amount of dirtyable memory
> 
> I don't know what this means.  How can a global limit be controlled by
> what is happening within each single zone?  Please describe this design
> concept fully.

Yikes, it's mein English.

A zone's dirty limit is to the zone's contribution of dirtyable memory
what the global dirty limit is to the global amount of dirtyable
memory.

As a result, the sum of the dirty limits of all existing zones equals
the global dirty limit, such that no single zone receives more than
its fair share of the globally allowable dirty pages.

When the allocator tries to allocate from the list of allowable zones,
it skips those that have reached their maximum share of dirty pages.

> > For now, the problem remains for NUMA configurations where the zones
> > allowed for allocation are in sum not big enough to trigger the global
> > dirty limits, but a future approach to solve this can reuse the
> > per-zone dirty limit infrastructure laid out in this patch to have
> > dirty throttling and the flusher threads consider individual zones.

> > +static unsigned long zone_dirtyable_memory(struct zone *zone)
> 
> Appears to return the number of pages in a particular zone which are
> considered "dirtyable".  Some discussion of how this decision is made
> would be illuminating.

Is the proportional relationship between zones and the global level a
satisfactory explanation?

Because I am looking for a central place to explain all this.

> > +{
> > +	unsigned long x;
> > +	/*
> > +	 * To keep a reasonable ratio between dirty memory and lowmem,
> > +	 * highmem is not considered dirtyable on a global level.
> 
> Whereabouts in the kernel is this policy implemented? 
> determine_dirtyable_memory()?  It does (or can) consider highmem
> pages?  Comment seems wrong?

Yes, in determine_dirtyable_memory().

It is possible to configure an unreasonable ratio between dirty memory
and lowmem with the vm_highmem_is_dirtyable sysctl.  The point is that
even though highmem is subtracted from the effective amount of global
dirtyable memory again (which is strictly a big-picture measure), we
only care about the individual zone here and so highmem can very much
always hold dirty pages up to its dirty limit.

> Should we rename determine_dirtyable_memory() to
> global_dirtyable_memory(), to get some sense of its relationship with
> zone_dirtyable_memory()?

Sounds good.

> > +	 * But we allow individual highmem zones to hold a potentially
> > +	 * bigger share of that global amount of dirty pages as long
> > +	 * as they have enough free or reclaimable pages around.
> > +	 */
> > +	x = zone_page_state(zone, NR_FREE_PAGES) - zone->totalreserve_pages;
> > +	x += zone_reclaimable_pages(zone);
> > +	return x;
> > +}
> > +
> > 
> > ...
> >
> > -void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
> > +static void dirty_limits(struct zone *zone,
> > +			 unsigned long *pbackground,
> > +			 unsigned long *pdirty)
> >  {
> > +	unsigned long uninitialized_var(zone_memory);
> > +	unsigned long available_memory;
> > +	unsigned long global_memory;
> >  	unsigned long background;
> > -	unsigned long dirty;
> > -	unsigned long uninitialized_var(available_memory);
> >  	struct task_struct *tsk;
> > +	unsigned long dirty;
> >  
> > -	if (!vm_dirty_bytes || !dirty_background_bytes)
> > -		available_memory = determine_dirtyable_memory();
> > +	global_memory = determine_dirtyable_memory();
> > +	if (zone)
> > +		available_memory = zone_memory = zone_dirtyable_memory(zone);
> > +	else
> > +		available_memory = global_memory;
> >  
> > -	if (vm_dirty_bytes)
> > +	if (vm_dirty_bytes) {
> >  		dirty = DIV_ROUND_UP(vm_dirty_bytes, PAGE_SIZE);
> > -	else
> > +		if (zone)
> 
> So passing zone==NULL alters dirty_limits()'s behaviour.  Seems that it
> flips the function between global_dirty_limits and zone_dirty_limits?

Yes.

> Would it be better if we actually had separate global_dirty_limits()
> and zone_dirty_limits() rather than a magical mode?

I did that the first time around, but Mel raised the valid point that
this will be bad for maintainability.

The global dirty limit and the per-zone dirty limit are not only
incidentally calculated the same way, they are intentionally similar
in the geometrical sense (modulo workarounds for not having fp
arithmetic), so it would be good to keep this stuff together.

But the same applies to determine_dirtyable_memory() and
zone_dirtyable_memory(), so they should be done the same way and I
don't care too much which that would be.

If noone complains, I would structure the code such that
global_dirtyable_memory() and zone_dirtyable_memory(), as well as
global_dirty_limits() and zone_dirty_limits() are separate functions
next to each other with a big fat comment above that block explaining
the per-zone dirty limits and the proportional relationship to the
global parameters.

> > +			dirty = dirty * zone_memory / global_memory;
> > +	} else
> >  		dirty = (vm_dirty_ratio * available_memory) / 100;
> >  
> > -	if (dirty_background_bytes)
> > +	if (dirty_background_bytes) {
> >  		background = DIV_ROUND_UP(dirty_background_bytes, PAGE_SIZE);
> > -	else
> > +		if (zone)
> > +			background = background * zone_memory / global_memory;
> > +	} else
> >  		background = (dirty_background_ratio * available_memory) / 100;
> >  
> >  	if (background >= dirty)
> > 
> > ...
> >
> > +bool zone_dirty_ok(struct zone *zone)
> 
> Full description of the return value, please.

Returns false when the zone has reached its maximum share of the
global allowed dirty pages, true otherwise.

> 
> > +{
> > +	unsigned long background_thresh, dirty_thresh;
> > +
> > +	dirty_limits(zone, &background_thresh, &dirty_thresh);
> > +
> > +	return zone_page_state(zone, NR_FILE_DIRTY) +
> > +		zone_page_state(zone, NR_UNSTABLE_NFS) +
> > +		zone_page_state(zone, NR_WRITEBACK) <= dirty_thresh;
> > +}
> 
> We never needed to calculate &background_thresh,.  I wonder if that
> matters.

I didn't think dirty_limits() could take another branch, but if I
split up the function I will drop it.  It's not rocket science and can
be easily added on demand.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
