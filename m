Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 920BA6B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 18:40:30 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id rp2so804476pbb.34
        for <linux-mm@kvack.org>; Tue, 19 Mar 2013 15:40:29 -0700 (PDT)
Date: Tue, 19 Mar 2013 15:40:03 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [patch 3/4 v3]swap: make swap discard async
In-Reply-To: <20130221021800.GC32580@kernel.org>
Message-ID: <alpine.LNX.2.00.1303191434440.5966@eggly.anvils>
References: <20130221021800.GC32580@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: Rafael Aquini <aquini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, minchan@kernel.org, kmpark@infradead.org, linux-mm@kvack.org

On Thu, 21 Feb 2013, Shaohua Li wrote:

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
> 
> This patch makes swap discard async, and move discard to where swap entry is
> freed. Idealy we should do discard for any freed sectors, but some SSD discard
> is very slow. This patch still does discard for a whole cluster. 
> 
> My test does a several round of 'mmap, write, unmap', which will trigger a lot
> of swap discard. In a fusionio card, with this patch, the test runtime is
> reduced to 18% of the time without it, so around 5.5x faster.
> 
> Signed-off-by: Shaohua Li <shli@fusionio.com>

Acked-by: Hugh Dickins <hughd@google.com>

Good, this is much better than what I had for discard (I believe:
I don't claim to have done any performance measurements) - thank you.

I did it the original way because scan_swap_map() was where we knew
an empty cluster (and I never believed that discarding 4k at a time
could be efficient); but now that you have a map of free clusters,
yes, much better to do it like this.

And this (together with your __swap_duplicate change) must fix an
issue I kept quiet about, and worried about less once we stopped
discarding by default.  read_swap_cache_async() can race against
get_swap_page(), and meet a SWAP_HAS_CACHE entry in the swap_map,
whose page has not yet been put into swap cache: it just loops
around in that -EEXIST case, expecting it to be a momentary glitch;
but my old placement of discard inserted a wait for I/O completion
in there, so read_swap_cache_async() would spin around while the
other end scheduled away - maybe only an issue if !CONFIG_PREEMPT,
and maybe the SSD which showed me that was defective, but good to
have it fixed now.

Maybe that issue is, or relates to, the softlockup storm which
Rafael mentioned when discussing 1/4.

> ---
>  include/linux/swap.h |    5 -
>  mm/swapfile.c        |  161 ++++++++++++++++++++++++++-------------------------
>  2 files changed, 86 insertions(+), 80 deletions(-)
> 
> Index: linux/include/linux/swap.h
> ===================================================================
> --- linux.orig/include/linux/swap.h	2013-02-18 19:42:50.143529913 +0800
> +++ linux/include/linux/swap.h	2013-02-19 14:44:08.873688932 +0800
> @@ -194,8 +194,6 @@ struct swap_info_struct {
>  	unsigned int inuse_pages;	/* number of those currently in use */
>  	unsigned int cluster_next;	/* likely index for next allocation */
>  	unsigned int cluster_nr;	/* countdown to next cluster search */
> -	unsigned int lowest_alloc;	/* while preparing discard cluster */
> -	unsigned int highest_alloc;	/* while preparing discard cluster */
>  	struct swap_extent *curr_swap_extent;
>  	struct swap_extent first_swap_extent;
>  	struct block_device *bdev;	/* swap device or bdev of swap file */
> @@ -217,6 +215,9 @@ struct swap_info_struct {
>  					 * swap_lock. If both locks need hold,
>  					 * hold swap_lock first.
>  					 */
> +	struct work_struct discard_work;
> +	unsigned int discard_cluster_head;
> +	unsigned int discard_cluster_tail;
>  };
>  
>  struct swap_list_t {
> Index: linux/mm/swapfile.c
> ===================================================================
> --- linux.orig/mm/swapfile.c	2013-02-18 19:45:10.061770901 +0800
> +++ linux/mm/swapfile.c	2013-02-19 14:45:42.732507754 +0800
> @@ -175,12 +175,6 @@ static void discard_swap_cluster(struct
>  	}
>  }
>  
> -static int wait_for_discard(void *word)
> -{
> -	schedule();
> -	return 0;
> -}
> -
>  #define SWAPFILE_CLUSTER	256
>  #define LATENCY_LIMIT		256
>  
> @@ -202,6 +196,71 @@ static int wait_for_discard(void *word)
>  	do { info = (cluster_flag(info) << 24) | (n); } while (0)
>  #define cluster_is_free(info) (cluster_flag(info) & CLUSTER_FLAG_FREE)
>  
> +static int swap_cluster_check_discard(struct swap_info_struct *si,
> +		unsigned int idx)
> +{
> +
> +	if (!(si->flags & SWP_DISCARDABLE))
> +		return 0;
> +	/*
> +	 * If scan_swap_map() can't find a free cluster, it will check
> +	 * si->swap_map directly. To make sure discarding cluster isn't taken,
> +	 * mark the swap entries bad (occupied). It will be cleared after
> +	 * discard
> +	 */
> +	memset(si->swap_map + idx * SWAPFILE_CLUSTER,
> +			SWAP_MAP_BAD, SWAPFILE_CLUSTER);
> +
> +	if (si->discard_cluster_head == CLUSTER_NULL) {
> +		si->discard_cluster_head = idx;
> +		si->discard_cluster_tail = idx;
> +	} else {
> +		cluster_set_next(si->cluster_info[si->discard_cluster_tail],
> +			idx);
> +		si->discard_cluster_tail = idx;
> +	}
> +
> +	schedule_work(&si->discard_work);
> +	return 1;
> +}
> +
> +static void swap_discard_work(struct work_struct *work)
> +{
> +	struct swap_info_struct *si = container_of(work,
> +		struct swap_info_struct, discard_work);
> +	unsigned int *info = si->cluster_info;
> +	unsigned int idx;
> +
> +	spin_lock(&si->lock);
> +	while (si->discard_cluster_head != CLUSTER_NULL) {
> +		idx = si->discard_cluster_head;
> +
> +		si->discard_cluster_head = cluster_next(info[idx]);
> +		if (si->discard_cluster_tail == idx) {
> +			si->discard_cluster_tail = CLUSTER_NULL;
> +			si->discard_cluster_head = CLUSTER_NULL;
> +		}
> +		spin_unlock(&si->lock);
> +
> +		discard_swap_cluster(si, idx * SWAPFILE_CLUSTER,
> +				SWAPFILE_CLUSTER);
> +
> +		spin_lock(&si->lock);
> +		cluster_set_flag(info[idx], CLUSTER_FLAG_FREE);
> +		if (si->free_cluster_head == CLUSTER_NULL) {
> +			si->free_cluster_head = idx;
> +			si->free_cluster_tail = idx;
> +		} else {
> +			cluster_set_next(info[si->free_cluster_tail], idx);
> +			si->free_cluster_tail = idx;
> +		}
> +		memset(si->swap_map + idx * SWAPFILE_CLUSTER,
> +				0, SWAPFILE_CLUSTER);
> +	}
> +
> +	spin_unlock(&si->lock);
> +}
> +
>  static inline void inc_cluster_info_page(struct swap_info_struct *p,
>  	unsigned int *cluster_info, unsigned long page_nr)
>  {
> @@ -238,6 +297,9 @@ static inline void dec_cluster_info_page
>  		cluster_count(cluster_info[idx]) - 1);
>  
>  	if (cluster_count(cluster_info[idx]) == 0) {
> +		if (swap_cluster_check_discard(p, idx))
> +			return;
> +
>  		cluster_set_flag(cluster_info[idx], CLUSTER_FLAG_FREE);
>  		if (p->free_cluster_head == CLUSTER_NULL) {
>  			p->free_cluster_head = idx;
> @@ -270,7 +332,6 @@ static unsigned long scan_swap_map(struc
>  	unsigned long scan_base;
>  	unsigned long last_in_cluster = 0;
>  	int latency_ration = LATENCY_LIMIT;
> -	int found_free_cluster = 0;
>  
>  	/*
>  	 * We try to cluster swap pages by allocating them sequentially
> @@ -291,34 +352,28 @@ static unsigned long scan_swap_map(struc
>  			si->cluster_nr = SWAPFILE_CLUSTER - 1;
>  			goto checks;
>  		}
> -		if (si->flags & SWP_DISCARDABLE) {
> -			/*
> -			 * Start range check on racing allocations, in case
> -			 * they overlap the cluster we eventually decide on
> -			 * (we scan without swap_lock to allow preemption).
> -			 * It's hardly conceivable that cluster_nr could be
> -			 * wrapped during our scan, but don't depend on it.
> -			 */
> -			if (si->lowest_alloc)
> -				goto checks;
> -			si->lowest_alloc = si->max;
> -			si->highest_alloc = 0;
> -		}
>  check_cluster:
>  		if (si->free_cluster_head != CLUSTER_NULL) {
>  			offset = si->free_cluster_head * SWAPFILE_CLUSTER;
>  			last_in_cluster = offset + SWAPFILE_CLUSTER - 1;
>  			si->cluster_next = offset;
>  			si->cluster_nr = SWAPFILE_CLUSTER - 1;
> -			found_free_cluster = 1;
>  			goto checks;
>  		} else if (si->cluster_info) {
> +			if (si->discard_cluster_head != CLUSTER_NULL) {
> +				spin_unlock(&si->lock);
> +				schedule_work(&si->discard_work);
> +				flush_work(&si->discard_work);
> +
> +				spin_lock(&si->lock);
> +				goto check_cluster;
> +			}
> +
>  			/*
>  			 * Checking free cluster is fast enough, we can do the
>  			 * check every time
>  			 */
>  			si->cluster_nr = 0;
> -			si->lowest_alloc = 0;
>  			goto checks;
>  		}
>  
> @@ -345,7 +400,6 @@ check_cluster:
>  				offset -= SWAPFILE_CLUSTER - 1;
>  				si->cluster_next = offset;
>  				si->cluster_nr = SWAPFILE_CLUSTER - 1;
> -				found_free_cluster = 1;
>  				goto checks;
>  			}
>  			if (unlikely(--latency_ration < 0)) {
> @@ -366,7 +420,6 @@ check_cluster:
>  				offset -= SWAPFILE_CLUSTER - 1;
>  				si->cluster_next = offset;
>  				si->cluster_nr = SWAPFILE_CLUSTER - 1;
> -				found_free_cluster = 1;
>  				goto checks;
>  			}
>  			if (unlikely(--latency_ration < 0)) {
> @@ -378,7 +431,6 @@ check_cluster:
>  		offset = scan_base;
>  		spin_lock(&si->lock);
>  		si->cluster_nr = SWAPFILE_CLUSTER - 1;
> -		si->lowest_alloc = 0;
>  	}
>  
>  checks:
> @@ -420,59 +472,6 @@ checks:
>  	si->cluster_next = offset + 1;
>  	si->flags -= SWP_SCANNING;
>  
> -	if (si->lowest_alloc) {
> -		/*
> -		 * Only set when SWP_DISCARDABLE, and there's a scan
> -		 * for a free cluster in progress or just completed.
> -		 */
> -		if (found_free_cluster) {
> -			/*
> -			 * To optimize wear-levelling, discard the
> -			 * old data of the cluster, taking care not to
> -			 * discard any of its pages that have already
> -			 * been allocated by racing tasks (offset has
> -			 * already stepped over any at the beginning).
> -			 */
> -			if (offset < si->highest_alloc &&
> -			    si->lowest_alloc <= last_in_cluster)
> -				last_in_cluster = si->lowest_alloc - 1;
> -			si->flags |= SWP_DISCARDING;
> -			spin_unlock(&si->lock);
> -
> -			if (offset < last_in_cluster)
> -				discard_swap_cluster(si, offset,
> -					last_in_cluster - offset + 1);
> -
> -			spin_lock(&si->lock);
> -			si->lowest_alloc = 0;
> -			si->flags &= ~SWP_DISCARDING;
> -
> -			smp_mb();	/* wake_up_bit advises this */
> -			wake_up_bit(&si->flags, ilog2(SWP_DISCARDING));
> -
> -		} else if (si->flags & SWP_DISCARDING) {
> -			/*
> -			 * Delay using pages allocated by racing tasks
> -			 * until the whole discard has been issued. We
> -			 * could defer that delay until swap_writepage,
> -			 * but it's easier to keep this self-contained.
> -			 */
> -			spin_unlock(&si->lock);
> -			wait_on_bit(&si->flags, ilog2(SWP_DISCARDING),
> -				wait_for_discard, TASK_UNINTERRUPTIBLE);
> -			spin_lock(&si->lock);
> -		} else {
> -			/*
> -			 * Note pages allocated by racing tasks while
> -			 * scan for a free cluster is in progress, so
> -			 * that its final discard can exclude them.
> -			 */
> -			if (offset < si->lowest_alloc)
> -				si->lowest_alloc = offset;
> -			if (offset > si->highest_alloc)
> -				si->highest_alloc = offset;
> -		}
> -	}
>  	return offset;
>  
>  scan:
> @@ -1730,6 +1729,8 @@ SYSCALL_DEFINE1(swapoff, const char __us
>  		goto out_dput;
>  	}
>  
> +	flush_work(&p->discard_work);
> +
>  	destroy_swap_extents(p);
>  	if (p->flags & SWP_CONTINUED)
>  		free_swap_count_continuations(p);
> @@ -2089,6 +2090,8 @@ static int setup_swap_map_and_extents(st
>  
>  	p->free_cluster_head = CLUSTER_NULL;
>  	p->free_cluster_tail = CLUSTER_NULL;
> +	p->discard_cluster_head = CLUSTER_NULL;
> +	p->discard_cluster_tail = CLUSTER_NULL;
>  
>  	for (i = 0; i < swap_header->info.nr_badpages; i++) {
>  		unsigned int page_nr = swap_header->info.badpages[i];
> @@ -2181,6 +2184,8 @@ SYSCALL_DEFINE2(swapon, const char __use
>  	if (IS_ERR(p))
>  		return PTR_ERR(p);
>  
> +	INIT_WORK(&p->discard_work, swap_discard_work);
> +
>  	name = getname(specialfile);
>  	if (IS_ERR(name)) {
>  		error = PTR_ERR(name);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
