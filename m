Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 70EC86B0031
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 06:37:56 -0400 (EDT)
Received: by mail-ie0-f172.google.com with SMTP id 16so6618151iea.17
        for <linux-mm@kvack.org>; Thu, 18 Jul 2013 03:37:55 -0700 (PDT)
Date: Thu, 18 Jul 2013 18:37:52 +0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [patch 2/4 v6]swap: make swap discard async
Message-ID: <20130718103752.GB25547@kernel.org>
References: <20130715204341.GB7925@kernel.org>
 <20130717150913.1286deef1a27bf2d2712e16f@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130717150913.1286deef1a27bf2d2712e16f@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, riel@redhat.com, minchan@kernel.org, kmpark@infradead.org, hughd@google.com, aquini@redhat.com

On Wed, Jul 17, 2013 at 03:09:13PM -0700, Andrew Morton wrote:
> On Tue, 16 Jul 2013 04:43:41 +0800 Shaohua Li <shli@kernel.org> wrote:
> 
> > swap can do cluster discard for SSD, which is good, but there are some problems
> > here:
> > 1. swap do the discard just before page reclaim gets a swap entry and writes
> > the disk sectors. This is useless for high end SSD, because an overwrite to a
> > sector implies a discard to original sector too. A discard + overwrite ==
> > overwrite.
> > 2. the purpose of doing discard is to improve SSD firmware garbage collection.
> > Idealy we should send discard as early as possible, so firmware can do
> > something smart. Sending discard just after swap entry is freed is considered
> > early compared to sending discard before write. Of course, if workload is
> > already bound to gc speed, sending discard earlier or later doesn't make
> > difference.
> > 3. block discard is a sync API, which will delay scan_swap_map() significantly.
> > 4. Write and discard command can be executed parallel in PCIe SSD. Making
> > swap discard async can make execution more efficiently.
> > 
> > This patch makes swap discard async and move discard to where swap entry is
> > freed. Discard and write have no dependence now, so above issues can be avoided.
> > Idealy we should do discard for any freed sectors, but some SSD discard is very
> > slow. This patch still does discard for a whole cluster. 
> > 
> > My test does a several round of 'mmap, write, unmap', which will trigger a lot
> > of swap discard. In a fusionio card, with this patch, the test runtime is
> > reduced to 18% of the time without it, so around 5.5x faster.
> > 
> > ...
> >
> > +static void swap_do_scheduled_discard(struct swap_info_struct *si)
> > +{
> > +	struct swap_cluster_info *info;
> > +	unsigned int idx;
> > +
> > +	info = si->cluster_info;
> > +
> > +	while (!cluster_is_null(&si->discard_cluster_head)) {
> > +		idx = cluster_next(&si->discard_cluster_head);
> > +
> > +		cluster_set_next_flag(&si->discard_cluster_head,
> > +						cluster_next(&info[idx]), 0);
> > +		if (cluster_next(&si->discard_cluster_tail) == idx) {
> > +			cluster_set_null(&si->discard_cluster_head);
> > +			cluster_set_null(&si->discard_cluster_tail);
> > +		}
> > +		spin_unlock(&si->lock);
> > +
> > +		discard_swap_cluster(si, idx * SWAPFILE_CLUSTER,
> > +				SWAPFILE_CLUSTER);
> > +
> > +		spin_lock(&si->lock);
> > +		cluster_set_flag(&info[idx], CLUSTER_FLAG_FREE);
> 
> Wait.  How can we do this?  We dropped the spinlock, so `idx' is now
> invalid.

idx is the current cluster (an index of array) we are discarding, it's not
invalid after we drop lock.
 
> > +		if (cluster_is_null(&si->free_cluster_head)) {
> > +			cluster_set_next_flag(&si->free_cluster_head,
> > +						idx, 0);
> > +			cluster_set_next_flag(&si->free_cluster_tail,
> > +						idx, 0);
> > +		} else {
> > +			unsigned int next;
> > +
> > +			next = cluster_next(&si->free_cluster_tail);
> > +			cluster_set_next(&info[next], idx);
> > +			cluster_set_next_flag(&si->free_cluster_tail,
> > +						idx, 0);
> 
> ditto.
> 
> > +		}
> > +		memset(si->swap_map + idx * SWAPFILE_CLUSTER,
> > +				0, SWAPFILE_CLUSTER);
> 
> again.
> 
> > +	}
> > +}
> > +
> > 
> > ...
> >
> > @@ -331,19 +414,6 @@ static unsigned long scan_swap_map(struc
> >  			si->cluster_nr = SWAPFILE_CLUSTER - 1;
> >  			goto checks;
> >  		}
> > -		if (si->flags & SWP_PAGE_DISCARD) {
> > -			/*
> > -			 * Start range check on racing allocations, in case
> > -			 * they overlap the cluster we eventually decide on
> > -			 * (we scan without swap_lock to allow preemption).
> > -			 * It's hardly conceivable that cluster_nr could be
> > -			 * wrapped during our scan, but don't depend on it.
> > -			 */
> > -			if (si->lowest_alloc)
> > -				goto checks;
> > -			si->lowest_alloc = si->max;
> > -			si->highest_alloc = 0;
> > -		}
> >  check_cluster:
> >  		if (!cluster_is_null(&si->free_cluster_head)) {
> >  			offset = cluster_next(&si->free_cluster_head) *
> > @@ -351,15 +421,22 @@ check_cluster:
> >  			last_in_cluster = offset + SWAPFILE_CLUSTER - 1;
> >  			si->cluster_next = offset;
> >  			si->cluster_nr = SWAPFILE_CLUSTER - 1;
> > -			found_free_cluster = 1;
> >  			goto checks;
> >  		} else if (si->cluster_info) {
> >  			/*
> > +			 * we don't have free cluster but have some clusters in
> > +			 * discarding, do discard now and reclaim them
> > +			 */
> > +			if (!cluster_is_null(&si->discard_cluster_head)) {
> > +				swap_do_scheduled_discard(si);
> > +				goto check_cluster;
> 
> Again, swap_do_scheduled_discard() might have dropped the lock.  The
> state which scan_swap_map() has copied in from the swap_info_struct is
> now invalidated.  `scan_base' and `offset' might have changed. 
> si->cluster_nr may have changed.  

it doesn't matter actually. With it, we might scan to different position, but
it doesn't break anthing. But I agree this is confusion. I'll move the goto
above.

Thanks,
Shaohua 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
