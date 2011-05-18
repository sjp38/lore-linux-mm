Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 1A7FD6B0023
	for <linux-mm@kvack.org>; Wed, 18 May 2011 05:47:26 -0400 (EDT)
Date: Wed, 18 May 2011 10:47:18 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/2] mm: vmscan: If kswapd has been running too long,
 allow it to sleep
Message-ID: <20110518094718.GP5279@suse.de>
References: <1305558417-24354-1-git-send-email-mgorman@suse.de>
 <1305558417-24354-3-git-send-email-mgorman@suse.de>
 <20110516141654.2728f05a.akpm@linux-foundation.org>
 <1305614225.6008.19.camel@mulgrave.site>
 <20110517162226.96974d89.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110517162226.96974d89.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, stable <stable@kernel.org>

On Tue, May 17, 2011 at 04:22:26PM -0700, Andrew Morton wrote:
> On Tue, 17 May 2011 10:37:04 +0400
> James Bottomley <James.Bottomley@HansenPartnership.com> wrote:
> 
> > On Mon, 2011-05-16 at 14:16 -0700, Andrew Morton wrote:
> > > On Mon, 16 May 2011 16:06:57 +0100
> > > Mel Gorman <mgorman@suse.de> wrote:
> > > 
> > > > Under constant allocation pressure, kswapd can be in the situation where
> > > > sleeping_prematurely() will always return true even if kswapd has been
> > > > running a long time. Check if kswapd needs to be scheduled.
> > > > 
> > > > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > > > Acked-by: Rik van Riel <riel@redhat.com>
> > > > ---
> > > >  mm/vmscan.c |    4 ++++
> > > >  1 files changed, 4 insertions(+), 0 deletions(-)
> > > > 
> > > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > > index af24d1e..4d24828 100644
> > > > --- a/mm/vmscan.c
> > > > +++ b/mm/vmscan.c
> > > > @@ -2251,6 +2251,10 @@ static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining,
> > > >  	unsigned long balanced = 0;
> > > >  	bool all_zones_ok = true;
> > > >  
> > > > +	/* If kswapd has been running too long, just sleep */
> > > > +	if (need_resched())
> > > > +		return false;
> > > > +
> > > >  	/* If a direct reclaimer woke kswapd within HZ/10, it's premature */
> > > >  	if (remaining)
> > > >  		return true;
> > > 
> > > I'm a bit worried by this one.
> > > 
> > > Do we really fully understand why kswapd is continuously running like
> > > this?  The changelog makes me think "no" ;)
> > > 
> > > Given that the page-allocating process is madly reclaiming pages in
> > > direct reclaim (yes?) and that kswapd is madly reclaiming pages on a
> > > different CPU, we should pretty promptly get into a situation where
> > > kswapd can suspend itself.  But that obviously isn't happening.  So
> > > what *is* going on?
> > 
> > The triggering workload is a massive untar using a file on the same
> > filesystem, so that's a continuous stream of pages read into the cache
> > for the input and a stream of dirty pages out for the writes.  We
> > thought it might have been out of control shrinkers, so we already
> > debugged that and found it wasn't.  It just seems to be an imbalance in
> > the zones that the shrinkers can't fix which causes
> > sleeping_prematurely() to return true almost indefinitely.
> 
> Is the untar disk-bound?  The untar has presumably hit the writeback
> dirty_ratio?  So its rate of page allocation is approximately equal to
> the write speed of the disks?
> 

A reasonable assumption but it gets messy.

> If so, the VM is consuming 100% of a CPU to reclaim pages at a mere
> tens-of-megabytes-per-second.  If so, there's something seriously wrong
> here - under favorable conditions one would expect reclaim to free up
> 100,000 pages/sec, maybe more.
> 
> If the untar is not disk-bound and the required page reclaim rate is
> equal to the rate at which a CPU can read, decompress and write to
> pagecache then, err, maybe possible.  But it still smells of
> inefficient reclaim.
> 

I think it's higher than just the rate of data but couldn't guess by
how much exactly. Reproducing this locally would have been nice but
the following conditions are likely happening on the problem machine.

   SLUB is using high-orders for its slabs, kswapd and reclaimers are
   reclaiming at a faster rate than required for just the data. SLUB
   is using order-2 allocs for inodes so every 18 files created by
   untar, we need an order-2 page. For ext4_io_end, we need order-3
   allocs and we are allocating these due to delayed block allocation.

   So for example: 50 files, each less than 1 page in size needs 50
   order-0 pages, 3 order-2 page and 2 order-3 pages

   To satisfy the high order pages, we are reclaiming at least 28
   pages. For compaction, we are migrating these so we are allocating
   a further 28 pages and then copying putting further pressure on
   the system. We may do this multiple times as order-0 allocations
   could be breaking up the pages again. Without compaction, we are
   only reclaiming but can get stalled for significant periods of
   time if dirty or writeback pages are encountered in the contiguous
   blocks and can reclaim too many pages quite easily.

So the rate of allocation required to write out data is higher than
just the data rate. The reclaim rate could be just fine but the number
of pages we need to reclaim to allocate slab objects can be screwy.

> > > Secondly, taking an up-to-100ms sleep in response to a need_resched()
> > > seems pretty savage and I suspect it risks undesirable side-effects.  A
> > > plain old cond_resched() would be more cautious.  But presumably
> > > kswapd() is already running cond_resched() pretty frequently, so why
> > > didn't that work?
> > 
> > So the specific problem with cond_resched() is that kswapd is still
> > runnable, so even if there's other work the system can be getting on
> > with, it quickly comes back to looping madly in kswapd.  If we return
> > false from sleeping_prematurely(), we stop kswapd until its woken up to
> > do more work.  This manifests, even on non sandybridge systems that
> > don't hang as a lot of time burned in kswapd.
> > 
> > I think the sandybridge bug I see on the laptop is that cond_resched()
> > is somehow ineffective:  kswapd is usually hogging one CPU and there are
> > runnable processes but they seem to cluster on other CPUs, leaving
> > kswapd to spin at close to 100% system time.
> > 
> > When the problem was first described, we tried sprinkling more
> > cond_rescheds() in the shrinker loop and it didn't work.
> 
> Seems to me that kswapd for some reason is doing too much work.  Or,
> more specifically is doing its work very inefficiently.  Making kswapd
> take arbitrary naps when it's misbehaving didn't fix that misbehaviour!
> 

It is likely to be doing work inefficiently in one of two ways

  1. We are reclaiming far more pages than required by the data
     for slab objects

  2. The rate we are reclaiming is fast enough that dirty pages are
     reaching the end of the LRU quickly

The latter part is also important. I doubt we are getting stalled in
writepage as this is new data being written to disk to blocks aren't
allocated yet but kswapd is encountering the dirty_ratio of pages
on the LRU and churning them through the LRU and reclaims the clean
pages in between.

In effect, this "sorts" the LRU lists so the dirty pages get grouped
together. At worst on a 2G system such as James', we have 104857
(20% of memory in pages) pages together on the LRU, all dirty and
all being skipped over by kswapd and direct reclaimers. This is at
least 3276 takings of the zone LRU lock assuming we isolate pages in
groups of SWAP_CLUSTER_MAX which a lot of list walking and CPU usage
for no pages reclaimed.

In this case, kswapd might as well take a brief nap as it can't clean
the pages so the flusher threads can get some work done.

> It would be interesting to watch kswapd's page reclaim inefficiency
> when this is happening: /proc/vmstat:pgscan_kswapd_* versus
> /proc/vmstat:kswapd_steal.  If that ration is high then kswapd is
> scanning many pages and not reclaiming them.
> 
> But given the prominence of shrink_slab in the traces, perhaps that
> isn't happening.
> 

As we are aggressively shrinking slab, we can reach the stage where
we scan the requested number of objects and reclaim none of them
potentially setting zone->all_unreclaimable to 1 if a lot of scanning
has also taken place recently without pages being freed. Once this
happens, kswapd isn't even trying to reclaim pages and is instead stuck
in shrink_slab until a page is freed clearing zone->all_unreclaimable
and zone->pages-scanned.

The ratio during that window would not change but slabs_scanned would
continue to increase.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
