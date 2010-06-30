Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 28AD86B01B4
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 02:29:18 -0400 (EDT)
Date: Wed, 30 Jun 2010 16:28:58 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [patch 50/52] mm: implement per-zone shrinker
Message-ID: <20100630062858.GE24712@dastard>
References: <20100624030212.676457061@suse.de>
 <20100624030733.676440935@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20100624030733.676440935@suse.de>
Sender: owner-linux-mm@kvack.org
To: npiggin@suse.de
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Stultz <johnstul@us.ibm.com>, Frank Mayhar <fmayhar@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 24, 2010 at 01:03:02PM +1000, npiggin@suse.de wrote:
> Allow the shrinker to do per-zone shrinking. This means it is called for
> each zone scanned. The shrinker is now completely responsible for calculating
> and batching (given helpers), which provides better flexibility.
> 
> Finding the ratio of objects to scan requires scaling the ratio of pagecache
> objects scanned. By passing down both the per-zone and the global reclaimable
> pages, per-zone caches and global caches can be calculated correctly.
> 
> Finally, add some fixed-point scaling to the ratio, which helps calculations.
> 
> Signed-off-by: Nick Piggin <npiggin@suse.de>
> ---
>  fs/dcache.c        |    2 
>  fs/drop_caches.c   |    2 
>  fs/inode.c         |    2 
>  fs/mbcache.c       |    4 -
>  fs/nfs/dir.c       |    2 
>  fs/nfs/internal.h  |    2 
>  fs/quota/dquot.c   |    2 
>  include/linux/mm.h |    6 +-
>  mm/vmscan.c        |  131 ++++++++++++++---------------------------------------
>  9 files changed, 47 insertions(+), 106 deletions(-)

The diffstat doesn't match the patch ;)


> Index: linux-2.6/include/linux/mm.h
> ===================================================================
> --- linux-2.6.orig/include/linux/mm.h
> +++ linux-2.6/include/linux/mm.h
> @@ -999,16 +999,19 @@ static inline void sync_mm_rss(struct ta
>   * querying the cache size, so a fastpath for that case is appropriate.
>   */
>  struct shrinker {
> -	int (*shrink)(int nr_to_scan, gfp_t gfp_mask);
> -	int seeks;	/* seeks to recreate an obj */
> -
> +	int (*shrink)(struct zone *zone, unsigned long scanned, unsigned long total,
> +					unsigned long global, gfp_t gfp_mask);

Can we add the shrinker structure to taht callback, too, so that we
can get away from needing global context for the shrinker?


> +unsigned long shrinker_do_scan(unsigned long *dst, unsigned long batch)
> +{
> +	unsigned long nr = ACCESS_ONCE(*dst);

What's the point of ACCESS_ONCE() here?

/me gets most of the way into the patch

Oh, it's because you are using static variables for nr_to_scan and
hence when concurrent shrinkers are running they are all
incrementing and decrementing the same variable. That doesn't sound
like a good idea to me - concurrent shrinkers are much more likely
with per-zone shrinker callouts. It seems to me that a reclaim
thread could be kept in a shrinker long after it has run it's
scan count if new shrinker calls from a different reclaim context
occur before the first has finished....

As a further question - why do some shrinkerN? get converted to a
single global nr_to_scan, and others get converted to a private
nr_to_scan? Shouldn't they all use the same method? The static
variable method looks to me to be full of races - concurrent callers
to shrinker_add_scan() does not look at all thread safe to me.

> +	if (nr < batch)
> +		return 0;

Why wouldn't we return nr here to drain the remaining objects?
Doesn't this mean we can't shrink caches that have a scan count of
less than SHRINK_BATCH?

> +	*dst = nr - batch;

Similarly, that is not a threadsafe update.

> +	return batch;
> +}
> +EXPORT_SYMBOL(shrinker_do_scan);
> +
>  /*
>   * Call the shrink functions to age shrinkable caches
>   *
> @@ -198,8 +228,8 @@ EXPORT_SYMBOL(unregister_shrinker);
>   *
>   * Returns the number of slab objects which we shrunk.
>   */
> -unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
> -			unsigned long lru_pages)
> +static unsigned long shrink_slab(struct zone *zone, unsigned long scanned, unsigned long total,
> +			unsigned long global, gfp_t gfp_mask)
>  {
>  	struct shrinker *shrinker;
>  	unsigned long ret = 0;
> @@ -211,55 +241,25 @@ unsigned long shrink_slab(unsigned long
>  		return 1;	/* Assume we'll be able to shrink next time */
>  
>  	list_for_each_entry(shrinker, &shrinker_list, list) {
> -		unsigned long long delta;
> -		unsigned long total_scan;
> -		unsigned long max_pass = (*shrinker->shrink)(0, gfp_mask);
> -
> -		delta = (4 * scanned) / shrinker->seeks;
> -		delta *= max_pass;
> -		do_div(delta, lru_pages + 1);
> -		shrinker->nr += delta;
> -		if (shrinker->nr < 0) {
> -			printk(KERN_ERR "shrink_slab: %pF negative objects to "
> -			       "delete nr=%ld\n",
> -			       shrinker->shrink, shrinker->nr);
> -			shrinker->nr = max_pass;
> -		}
> -
> -		/*
> -		 * Avoid risking looping forever due to too large nr value:
> -		 * never try to free more than twice the estimate number of
> -		 * freeable entries.
> -		 */
> -		if (shrinker->nr > max_pass * 2)
> -			shrinker->nr = max_pass * 2;
> -
> -		total_scan = shrinker->nr;
> -		shrinker->nr = 0;
> -
> -		while (total_scan >= SHRINK_BATCH) {
> -			long this_scan = SHRINK_BATCH;
> -			int shrink_ret;
> -			int nr_before;
> -
> -			nr_before = (*shrinker->shrink)(0, gfp_mask);
> -			shrink_ret = (*shrinker->shrink)(this_scan, gfp_mask);
> -			if (shrink_ret == -1)
> -				break;
> -			if (shrink_ret < nr_before)
> -				ret += nr_before - shrink_ret;
> -			count_vm_events(SLABS_SCANNED, this_scan);
> -			total_scan -= this_scan;
> -
> -			cond_resched();

Removing this means we need cond_resched() in all shrinker loops now
to maintain the same latencies as we currently have. I note that
you've done this for most of the shrinkers, but the documentation
needs to be updated to mention this...


> -		}
> -
> -		shrinker->nr += total_scan;

And dropping this means we do not carry over the remainder of the
previous scan into the next scan. This means we could be scanning a
lot less with this new code.

> +		(*shrinker->shrink)(zone, scanned, total, global, gfp_mask);
>  	}
>  	up_read(&shrinker_rwsem);
>  	return ret;
>  }
>  
> +void shrink_all_slab(void)
> +{
> +	struct zone *zone;
> +	unsigned long nr;
> +
> +again:
> +	nr = 0;
> +	for_each_zone(zone)
> +		nr += shrink_slab(zone, 1, 1, 1, GFP_KERNEL);
> +	if (nr >= 10)
> +		goto again;

	do {
		nr = 0;
		for_each_zone(zone)
			nr += shrink_slab(zone, 1, 1, 1, GFP_KERNEL);
	} while (nr >= 10);

> @@ -1705,6 +1708,23 @@ static void shrink_zone(int priority, st
>  	if (inactive_anon_is_low(zone, sc) && nr_swap_pages > 0)
>  		shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
>  
> +	/*
> +	 * Don't shrink slabs when reclaiming memory from
> +	 * over limit cgroups
> +	 */
> +	if (scanning_global_lru(sc)) {
> +		struct reclaim_state *reclaim_state = current->reclaim_state;
> +
> +		shrink_slab(zone, sc->nr_scanned - nr_scanned,
> +			lru_pages, global_lru_pages, sc->gfp_mask);
> +		if (reclaim_state) {
> +			nr_reclaimed += reclaim_state->reclaimed_slab;
> +			reclaim_state->reclaimed_slab = 0;
> +		}
> +	}

So effectively we are going to be calling shrink_slab() once per
zone instead of once per priority loop, right? That means we are
going to be doing a lot more concurrent shrink_slab() calls that the
current code. Combine that with the removal of residual aggregation,
I think this will alter the reclaim balance somewhat. Have you tried
to quantify this?

> Index: linux-2.6/fs/dcache.c
> ===================================================================
> --- linux-2.6.orig/fs/dcache.c
> +++ linux-2.6/fs/dcache.c
> @@ -748,20 +748,26 @@ again2:
>   *
>   * This function may fail to free any resources if all the dentries are in use.
>   */
> -static void prune_dcache(int count)
> +static void prune_dcache(struct zone *zone, unsigned long scanned,
> +			unsigned long total, gfp_t gfp_mask)
> +
>  {
> +	unsigned long nr_to_scan;
>  	struct super_block *sb, *n;
>  	int w_count;
> -	int unused = dentry_stat.nr_unused;
>  	int prune_ratio;
> -	int pruned;
> +	int count, pruned;
>  
> -	if (unused == 0 || count == 0)
> +	shrinker_add_scan(&nr_to_scan, scanned, total, dentry_stat.nr_unused,
> +			DEFAULT_SEEKS * sysctl_vfs_cache_pressure / 100);
> +done:
> +	count = shrinker_do_scan(&nr_to_scan, SHRINK_BATCH);
> +	if (dentry_stat.nr_unused == 0 || count == 0)
>  		return;
> -	if (count >= unused)
> +	if (count >= dentry_stat.nr_unused)
>  		prune_ratio = 1;
>  	else
> -		prune_ratio = unused / count;
> +		prune_ratio = dentry_stat.nr_unused / count;
>  	spin_lock(&sb_lock);
>  	list_for_each_entry_safe(sb, n, &super_blocks, s_list) {
>  		if (list_empty(&sb->s_instances))
> @@ -810,6 +816,10 @@ static void prune_dcache(int count)
>  			break;
>  	}
>  	spin_unlock(&sb_lock);
> +	if (count <= 0) {
> +		cond_resched();
> +		goto done;
> +	}
>  }
>  
>  /**
> @@ -1176,19 +1186,15 @@ EXPORT_SYMBOL(shrink_dcache_parent);
>   *
>   * In this case we return -1 to tell the caller that we baled.
>   */
> -static int shrink_dcache_memory(int nr, gfp_t gfp_mask)
> +static int shrink_dcache_memory(struct zone *zone, unsigned long scanned,
> +		unsigned long total, unsigned long global, gfp_t gfp_mask)
>  {
> -	if (nr) {
> -		if (!(gfp_mask & __GFP_FS))
> -			return -1;
> -		prune_dcache(nr);
> -	}
> -	return (dentry_stat.nr_unused / 100) * sysctl_vfs_cache_pressure;
> +	prune_dcache(zone, scanned, global, gfp_mask);
> +	return 0;
>  }

I would have thought that putting the shrinker_add_scan/
shrinker_do_scan loop in shrink_dcache_memory() and leaving
prune_dcache untouched would have been a better separation.
I note that this is what you did with prune_icache(), so consistency
between the two would be good ;)

Also, this patch drops the __GFP_FS check from the dcache shrinker -
not intentional, right?

> @@ -211,28 +215,38 @@ mb_cache_shrink_fn(int nr_to_scan, gfp_t
>  			  atomic_read(&cache->c_entry_count));
>  		count += atomic_read(&cache->c_entry_count);
>  	}
> +	shrinker_add_scan(&nr_to_scan, scanned, global, count,
> +			DEFAULT_SEEKS * sysctl_vfs_cache_pressure / 100);
>  	mb_debug("trying to free %d entries", nr_to_scan);
> -	if (nr_to_scan == 0) {
> +
> +again:
> +	nr = shrinker_do_scan(&nr_to_scan, SHRINK_BATCH);
> +	if (!nr) {
>  		spin_unlock(&mb_cache_spinlock);
> -		goto out;
> +		return 0;
>  	}
> -	while (nr_to_scan-- && !list_empty(&mb_cache_lru_list)) {
> +	while (!list_empty(&mb_cache_lru_list)) {
>  		struct mb_cache_entry *ce =
>  			list_entry(mb_cache_lru_list.next,
>  				   struct mb_cache_entry, e_lru_list);
>  		list_move_tail(&ce->e_lru_list, &free_list);
>  		__mb_cache_entry_unhash(ce);
> +		cond_resched_lock(&mb_cache_spinlock);
> +		if (!--nr)
> +			break;
>  	}
>  	spin_unlock(&mb_cache_spinlock);
>  	list_for_each_safe(l, ltmp, &free_list) {
>  		__mb_cache_entry_forget(list_entry(l, struct mb_cache_entry,
>  						   e_lru_list), gfp_mask);
>  	}
> -out:
> -	return (count / 100) * sysctl_vfs_cache_pressure;
> +	if (!nr) {
> +		spin_lock(&mb_cache_spinlock);
> +		goto again;
> +	}

Another candidate for a do-while loop.

> +	return 0;
>  }
>  
> -
>  /*
>   * mb_cache_create()  create a new cache
>   *
> Index: linux-2.6/fs/nfs/dir.c
> ===================================================================
> --- linux-2.6.orig/fs/nfs/dir.c
> +++ linux-2.6/fs/nfs/dir.c
> @@ -1709,21 +1709,31 @@ static void nfs_access_free_list(struct
>  	}
>  }
>  
> -int nfs_access_cache_shrinker(int nr_to_scan, gfp_t gfp_mask)
> +int nfs_access_cache_shrinker(struct zone *zone, unsigned long scanned,
> +		unsigned long total, unsigned long global, gfp_t gfp_mask)
>  {
> +	static unsigned long nr_to_scan;
>  	LIST_HEAD(head);
> -	struct nfs_inode *nfsi;
>  	struct nfs_access_entry *cache;
> -
> -	if ((gfp_mask & GFP_KERNEL) != GFP_KERNEL)
> -		return (nr_to_scan == 0) ? 0 : -1;
> +	unsigned long nr;
>  
>  	spin_lock(&nfs_access_lru_lock);
> -	list_for_each_entry(nfsi, &nfs_access_lru_list, access_cache_inode_lru) {
> +	shrinker_add_scan(&nr_to_scan, scanned, global,
> +			atomic_long_read(&nfs_access_nr_entries),
> +			DEFAULT_SEEKS * sysctl_vfs_cache_pressure / 100);
> +	if (!(gfp_mask & __GFP_FS) || nr_to_scan < SHRINK_BATCH) {
> +		spin_unlock(&nfs_access_lru_lock);
> +		return 0;
> +	}
> +	nr = ACCESS_ONCE(nr_to_scan);
> +	nr_to_scan = 0;

That's not safe for concurrent callers. Both could get nr =
nr_to_scan rather than nr(1) = nr_to_scan and nr(2) = 0 which I
think is the intent....

> Index: linux-2.6/arch/x86/kvm/mmu.c
> ===================================================================
> --- linux-2.6.orig/arch/x86/kvm/mmu.c
> +++ linux-2.6/arch/x86/kvm/mmu.c
> @@ -2924,14 +2924,29 @@ static int kvm_mmu_remove_some_alloc_mmu
>  	return kvm_mmu_zap_page(kvm, page) + 1;
>  }
>  
> -static int mmu_shrink(int nr_to_scan, gfp_t gfp_mask)
> +static int mmu_shrink(struct zone *zone, unsigned long scanned,
> +                unsigned long total, unsigned long global, gfp_t gfp_mask)
>  {
> +	static unsigned long nr_to_scan;
>  	struct kvm *kvm;
>  	struct kvm *kvm_freed = NULL;
> -	int cache_count = 0;
> +	unsigned long cache_count = 0;
>  
>  	spin_lock(&kvm_lock);
> +	list_for_each_entry(kvm, &vm_list, vm_list) {
> +		cache_count += kvm->arch.n_alloc_mmu_pages -
> +			 kvm->arch.n_free_mmu_pages;
> +	}
>  
> +	shrinker_add_scan(&nr_to_scan, scanned, global, cache_count,
> +			DEFAULT_SEEKS*10);
> +
> +done:
> +	cache_count = shrinker_do_scan(&nr_to_scan, SHRINK_BATCH);
> +	if (!cache_count) {
> +		spin_unlock(&kvm_lock);
> +		return 0;
> +	}

I note that this use of a static scan count is thread safe because
all the calculations are done under the kvm_lock. THat's three
different ways the shrinkers implement the same functionality
now....

> Index: linux-2.6/fs/xfs/linux-2.6/xfs_sync.c
> ===================================================================
> --- linux-2.6.orig/fs/xfs/linux-2.6/xfs_sync.c
> +++ linux-2.6/fs/xfs/linux-2.6/xfs_sync.c
> @@ -838,43 +838,52 @@ static struct rw_semaphore xfs_mount_lis
>  
>  static int
>  xfs_reclaim_inode_shrink(
> -	int		nr_to_scan,
> +	struct zone	*zone,
> +	unsigned long	scanned,
> +	unsigned long	total,
> +	unsigned long	global,
>  	gfp_t		gfp_mask)
>  {
> +	static unsigned long nr_to_scan;
> +	int		nr;
>  	struct xfs_mount *mp;
>  	struct xfs_perag *pag;
>  	xfs_agnumber_t	ag;
> -	int		reclaimable = 0;
> -
> -	if (nr_to_scan) {
> -		if (!(gfp_mask & __GFP_FS))
> -			return -1;
> -
> -		down_read(&xfs_mount_list_lock);
> -		list_for_each_entry(mp, &xfs_mount_list, m_mplist) {
> -			xfs_inode_ag_iterator(mp, xfs_reclaim_inode, 0,
> -					XFS_ICI_RECLAIM_TAG, 1, &nr_to_scan);
> -			if (nr_to_scan <= 0)
> -				break;
> -		}
> -		up_read(&xfs_mount_list_lock);
> -	}
> +	unsigned long	nr_reclaimable = 0;
>  
>  	down_read(&xfs_mount_list_lock);
>  	list_for_each_entry(mp, &xfs_mount_list, m_mplist) {
>  		for (ag = 0; ag < mp->m_sb.sb_agcount; ag++) {
>  			pag = xfs_perag_get(mp, ag);
> -			reclaimable += pag->pag_ici_reclaimable;
> +			nr_reclaimable += pag->pag_ici_reclaimable;
>  			xfs_perag_put(pag);
>  		}
>  	}
> +	shrinker_add_scan(&nr_to_scan, scanned, global, nr_reclaimable,
> +				DEFAULT_SEEKS);

That's not thread safe - it's under a read lock. This code really
needs a shrinker context....

> +	if (!(gfp_mask & __GFP_FS)) {
> +		up_read(&xfs_mount_list_lock);
> +		return 0;
> +	}
> +
> +done:
> +	nr = shrinker_do_scan(&nr_to_scan, SHRINK_BATCH);
> +	if (!nr) {
> +		up_read(&xfs_mount_list_lock);
> +		return 0;
> +	}
> +	list_for_each_entry(mp, &xfs_mount_list, m_mplist) {
> +		xfs_inode_ag_iterator(mp, xfs_reclaim_inode, 0,
> +				XFS_ICI_RECLAIM_TAG, 1, &nr);
> +		if (nr <= 0)
> +			goto done;
> +	}

That's missing conditional reschedules....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
