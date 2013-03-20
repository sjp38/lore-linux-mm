Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id B47A46B0002
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 16:51:33 -0400 (EDT)
Date: Wed, 20 Mar 2013 13:51:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 3/4 v3]swap: make swap discard async
Message-Id: <20130320135131.e74306f007de6be45de40f29@linux-foundation.org>
In-Reply-To: <20130221021800.GC32580@kernel.org>
References: <20130221021800.GC32580@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, hughd@google.com, riel@redhat.com, minchan@kernel.org, kmpark@infradead.org

On Thu, 21 Feb 2013 10:18:00 +0800 Shaohua Li <shli@kernel.org> wrote:

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
>  
> @@ -202,6 +196,71 @@ static int wait_for_discard(void *word)
>  	do { info = (cluster_flag(info) << 24) | (n); } while (0)
>  #define cluster_is_free(info) (cluster_flag(info) & CLUSTER_FLAG_FREE)
>  
> +static int swap_cluster_check_discard(struct swap_info_struct *si,
> +		unsigned int idx)

This is a poor name.  Check what?  And return what value if the
unspecified-thing-we're-checking meets the unspecified conditions?

Consider this simplified example:

	bool check_temperature(...);

versus

	bool temperature_too_high(...);

The latter is a better name, because it tells the reader what the
function's return value means.

The fact that both swap_cluster_check_discard() and its caller are
totally uncommented just worsens things.


> +{
> +
> +	if (!(si->flags & SWP_DISCARDABLE))
> +		return 0;
> +	/*
> +	 * If scan_swap_map() can't find a free cluster, it will check
> +	 * si->swap_map directly. To make sure discarding cluster isn't taken,

"discarding cluster isn't taken" is unclear.  Please rephrase that?

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

This is a nicer layout:

	struct swap_info_struct *si;
	unsigned int *info;
	unsigned int idx;

	si = container_of(work, struct swap_info_struct, discard_work);
	info = si->cluster_info;

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

Please add a comment.  Explain why this function returns under these
conditions.

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

Add a comment here explaining what's going on.

> +				spin_unlock(&si->lock);
> +				schedule_work(&si->discard_work);
> +				flush_work(&si->discard_work);

That's a slow way of calling swap_discard work().  Can't we just call
it directly, after a bit of refactoring?

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
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
