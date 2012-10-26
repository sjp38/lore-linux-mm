Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 4F4FE6B0072
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 22:39:05 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so2688921pbb.14
        for <linux-mm@kvack.org>; Thu, 25 Oct 2012 19:39:04 -0700 (PDT)
Date: Fri, 26 Oct 2012 10:38:55 +0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [RFC 2/2]swap: make swap discard async
Message-ID: <20121026023855.GB1546@kernel.org>
References: <20121022023113.GB20255@kernel.org>
 <20121025005539.GB3838@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121025005539.GB3838@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, riel@redhat.com

On Thu, Oct 25, 2012 at 09:55:39AM +0900, Minchan Kim wrote:
> On Mon, Oct 22, 2012 at 10:31:13AM +0800, Shaohua Li wrote:
> > swap can do cluster discard for SSD, which is good, but there are some problems
> > here:
> > 1. swap do the discard just before page reclaim gets a swap entry and writes
> > the disk sectors. This is useless for high end SSD, because an overwrite to a
> > sector implies a discard to original nand flash too. A discard + overwrite ==
> > overwrite.
> > 2. the purpose of doing discard is to improve SSD firmware garbage collection.
> > Doing discard just before write doesn't help, because the interval between
> > discard and write is too short. Doing discard async and just after a swap entry
> > is freed can make the interval longer, so SSD firmware has more time to do gc.
> > 3. block discard is a sync API, which will delay scan_swap_map() significantly.
> > 4. Write and discard command can be executed parallel in PCIe SSD. Making
> > swap discard async can make execution more efficiently.
> 
> Great!
> 
> > 
> > This patch makes swap discard async, and move discard to where swap entry is
> > freed. Idealy we should do discard for any freed sectors, but some SSD discard
> 
> Yes. It's ideal but most of small storage(ex, eMMC) can't do it due to shortage of
> internal resource.
> 
> > is very slow. This patch still does discard for a whole cluster. 
> 
> That's good for small nonration storage.
> 
> > 
> > My test does a several round of 'mmap, write, unmap', which will trigger a lot
> > of swap discard. In a fusionio card, with this patch, the test runtime is
> > reduced to 18% of the time without it, so around 5.5x faster.
> 
> Could you share your test program?

Very simple.

for i in $(seq 1 5); do
/usr/bin/time -a -o discard-log $USEMEM --prefault 30G
done
 
I measure the time of the whole swapout.

> > +/* magic number to indicate the cluster is discardable */
> > +#define CLUSTER_COUNT_DISCARDABLE (SWAPFILE_CLUSTER * 2)
> > +#define CLUSTER_COUNT_DISCARDING (SWAPFILE_CLUSTER * 2 + 1)
> 
> #define CLUSTER_COUNT_DISCARDING (CLUSTER_COUNT_DISCARDABLE + 1)

That's fine, any number above CLUSTER_COUNT_DISCARDABLE is ok.
 
> > +static void swap_cluster_check_discard(struct swap_info_struct *si,
> > +		unsigned long offset)
> > +{
> > +	unsigned long cluster = offset/SWAPFILE_CLUSTER;
> > +
> > +	if (!(si->flags & SWP_DISCARDABLE))
> > +		return;
> > +	if (si->swap_cluster_count[cluster] > 0)
> > +		return;
> > +	si->swap_cluster_count[cluster] = CLUSTER_COUNT_DISCARDABLE;
> > +	/* Just mark the swap entries occupied */
> > +	memset(si->swap_map + (cluster << SWAPFILE_CLUSTER_SHIFT),
> > +			SWAP_MAP_BAD, SWAPFILE_CLUSTER);
> 
> You should explain why we need SWAP_MAP_BAD.

Ok.
 
> > +	schedule_work(&si->discard_work);
> > +}
> > +
> > +static void swap_discard_work(struct work_struct *work)
> > +{
> > +	struct swap_info_struct *si = container_of(work,
> > +		struct swap_info_struct, discard_work);
> > +	unsigned int *counter = si->swap_cluster_count;
> > +	int i;
> > +
> > +	for (i = round_up(si->cluster_next, SWAPFILE_CLUSTER) /
> 
> Why do we always start si->cluster_next?
> IMHO, It would be better to start offset where swap_entry_free free.

scan_swap_map() searches from si->cluster_next, my intention is this can let
scan_swap_map find cluster easily. Maybe I should add comment here.
 
> > +
> > +			discard_swap_cluster(si, i << SWAPFILE_CLUSTER_SHIFT,
> > +				SWAPFILE_CLUSTER);
> > +
> > +			spin_lock(&swap_lock);
> > +			counter[i] = 0;
> > +			memset(si->swap_map + (i << SWAPFILE_CLUSTER_SHIFT),
> > +					0, SWAPFILE_CLUSTER);
> > +			spin_unlock(&swap_lock);
> > +		}
> > +	}
> > +}
> 
> Whole searching for finding discardable cluster is rather overkill if we use
> big swap device.
> Couldn't we make global discarable cluster counter and loop until it is zero?
> Anyway, it's just optimization point and could add up based on this patch.
> It shouldn't merge your patch. :)

For a 500G swap, this sounds not a big deal. If it's really heavy, we can add a
bitmap to speed up the search too. That could be a future patch if we find this
is a real problem.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
