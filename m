Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 8AA696B0068
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 20:50:18 -0400 (EDT)
Date: Thu, 25 Oct 2012 09:55:39 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 2/2]swap: make swap discard async
Message-ID: <20121025005539.GB3838@bbox>
References: <20121022023113.GB20255@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121022023113.GB20255@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, riel@redhat.com

On Mon, Oct 22, 2012 at 10:31:13AM +0800, Shaohua Li wrote:
> swap can do cluster discard for SSD, which is good, but there are some problems
> here:
> 1. swap do the discard just before page reclaim gets a swap entry and writes
> the disk sectors. This is useless for high end SSD, because an overwrite to a
> sector implies a discard to original nand flash too. A discard + overwrite ==
> overwrite.
> 2. the purpose of doing discard is to improve SSD firmware garbage collection.
> Doing discard just before write doesn't help, because the interval between
> discard and write is too short. Doing discard async and just after a swap entry
> is freed can make the interval longer, so SSD firmware has more time to do gc.
> 3. block discard is a sync API, which will delay scan_swap_map() significantly.
> 4. Write and discard command can be executed parallel in PCIe SSD. Making
> swap discard async can make execution more efficiently.

Great!

> 
> This patch makes swap discard async, and move discard to where swap entry is
> freed. Idealy we should do discard for any freed sectors, but some SSD discard

Yes. It's ideal but most of small storage(ex, eMMC) can't do it due to shortage of
internal resource.

> is very slow. This patch still does discard for a whole cluster. 

That's good for small nonration storage.

> 
> My test does a several round of 'mmap, write, unmap', which will trigger a lot
> of swap discard. In a fusionio card, with this patch, the test runtime is
> reduced to 18% of the time without it, so around 5.5x faster.

Could you share your test program?

> 
> Signed-off-by: Shaohua Li <shli@fusionio.com>
> ---
>  include/linux/swap.h |    3 
>  mm/swapfile.c        |  177 +++++++++++++++++++++++++++------------------------
>  2 files changed, 98 insertions(+), 82 deletions(-)
> 
> Index: linux/include/linux/swap.h
> ===================================================================
> --- linux.orig/include/linux/swap.h	2012-10-22 09:20:50.462043746 +0800
> +++ linux/include/linux/swap.h	2012-10-22 09:23:27.720066736 +0800
> @@ -192,8 +192,6 @@ struct swap_info_struct {
>  	unsigned int inuse_pages;	/* number of those currently in use */
>  	unsigned int cluster_next;	/* likely index for next allocation */
>  	unsigned int cluster_nr;	/* countdown to next cluster search */
> -	unsigned int lowest_alloc;	/* while preparing discard cluster */
> -	unsigned int highest_alloc;	/* while preparing discard cluster */
>  	struct swap_extent *curr_swap_extent;
>  	struct swap_extent first_swap_extent;
>  	struct block_device *bdev;	/* swap device or bdev of swap file */
> @@ -203,6 +201,7 @@ struct swap_info_struct {
>  	unsigned long *frontswap_map;	/* frontswap in-use, one bit per page */
>  	atomic_t frontswap_pages;	/* frontswap pages in-use counter */
>  #endif
> +	struct work_struct discard_work;
>  };
>  
>  struct swap_list_t {
> Index: linux/mm/swapfile.c
> ===================================================================
> --- linux.orig/mm/swapfile.c	2012-10-22 09:21:34.317493506 +0800
> +++ linux/mm/swapfile.c	2012-10-22 09:56:17.379304667 +0800
> @@ -173,15 +173,82 @@ static void discard_swap_cluster(struct
>  	}
>  }
>  
> -static int wait_for_discard(void *word)
> -{
> -	schedule();
> -	return 0;
> -}
> -
> -#define SWAPFILE_CLUSTER	256
> +#define SWAPFILE_CLUSTER_SHIFT	8
> +#define SWAPFILE_CLUSTER	(1<<SWAPFILE_CLUSTER_SHIFT)
>  #define LATENCY_LIMIT		256
>  
> +/* magic number to indicate the cluster is discardable */
> +#define CLUSTER_COUNT_DISCARDABLE (SWAPFILE_CLUSTER * 2)
> +#define CLUSTER_COUNT_DISCARDING (SWAPFILE_CLUSTER * 2 + 1)

#define CLUSTER_COUNT_DISCARDING (CLUSTER_COUNT_DISCARDABLE + 1)

> +static void swap_cluster_check_discard(struct swap_info_struct *si,
> +		unsigned long offset)
> +{
> +	unsigned long cluster = offset/SWAPFILE_CLUSTER;
> +
> +	if (!(si->flags & SWP_DISCARDABLE))
> +		return;
> +	if (si->swap_cluster_count[cluster] > 0)
> +		return;
> +	si->swap_cluster_count[cluster] = CLUSTER_COUNT_DISCARDABLE;
> +	/* Just mark the swap entries occupied */
> +	memset(si->swap_map + (cluster << SWAPFILE_CLUSTER_SHIFT),
> +			SWAP_MAP_BAD, SWAPFILE_CLUSTER);

You should explain why we need SWAP_MAP_BAD.

> +	schedule_work(&si->discard_work);
> +}
> +
> +static void swap_discard_work(struct work_struct *work)
> +{
> +	struct swap_info_struct *si = container_of(work,
> +		struct swap_info_struct, discard_work);
> +	unsigned int *counter = si->swap_cluster_count;
> +	int i;
> +
> +	for (i = round_up(si->cluster_next, SWAPFILE_CLUSTER) /

Why do we always start si->cluster_next?
IMHO, It would be better to start offset where swap_entry_free free.

> +	     SWAPFILE_CLUSTER; i < round_down(si->highest_bit,
> +	     SWAPFILE_CLUSTER) / SWAPFILE_CLUSTER; i++) {
> +		if (counter[i] == CLUSTER_COUNT_DISCARDABLE) {
> +			spin_lock(&swap_lock);
> +			if (counter[i] != CLUSTER_COUNT_DISCARDABLE) {
> +				spin_unlock(&swap_lock);
> +				continue;
> +			}
> +			counter[i] = CLUSTER_COUNT_DISCARDING;
> +			spin_unlock(&swap_lock);
> +
> +			discard_swap_cluster(si, i << SWAPFILE_CLUSTER_SHIFT,
> +				SWAPFILE_CLUSTER);
> +
> +			spin_lock(&swap_lock);
> +			counter[i] = 0;
> +			memset(si->swap_map + (i << SWAPFILE_CLUSTER_SHIFT),
> +					0, SWAPFILE_CLUSTER);
> +			spin_unlock(&swap_lock);
> +		}
> +	}
> +	for (i = round_up(si->lowest_bit, SWAPFILE_CLUSTER) /
> +	     SWAPFILE_CLUSTER; i < round_down(si->cluster_next,
> +	     SWAPFILE_CLUSTER) / SWAPFILE_CLUSTER; i++) {
> +		if (counter[i] == CLUSTER_COUNT_DISCARDABLE) {
> +			spin_lock(&swap_lock);
> +			if (counter[i] != CLUSTER_COUNT_DISCARDABLE) {
> +				spin_unlock(&swap_lock);
> +				continue;
> +			}
> +			counter[i] = CLUSTER_COUNT_DISCARDING;
> +			spin_unlock(&swap_lock);
> +
> +			discard_swap_cluster(si, i << SWAPFILE_CLUSTER_SHIFT,
> +				SWAPFILE_CLUSTER);
> +
> +			spin_lock(&swap_lock);
> +			counter[i] = 0;
> +			memset(si->swap_map + (i << SWAPFILE_CLUSTER_SHIFT),
> +					0, SWAPFILE_CLUSTER);
> +			spin_unlock(&swap_lock);
> +		}
> +	}
> +}

Whole searching for finding discardable cluster is rather overkill if we use
big swap device.
Couldn't we make global discarable cluster counter and loop until it is zero?
Anyway, it's just optimization point and could add up based on this patch.
It shouldn't merge your patch. :)

I like this patch very much because it would be very good with [1/2] for nonrotation
small device, I believe and remove lots of complicated code in swapfile. Hugh?

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
