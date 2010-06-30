Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6E71C600227
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 10:33:19 -0400 (EDT)
Date: Wed, 30 Jun 2010 22:03:53 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 50/52] mm: implement per-zone shrinker
Message-ID: <20100630120353.GA21358@laptop>
References: <20100624030212.676457061@suse.de>
 <20100624030733.676440935@suse.de>
 <20100630062858.GE24712@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20100630062858.GE24712@dastard>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Stultz <johnstul@us.ibm.com>, Frank Mayhar <fmayhar@google.com>
List-ID: <linux-mm.kvack.org>

Wow, some reviewing! Thanks Dave.

On Wed, Jun 30, 2010 at 04:28:58PM +1000, Dave Chinner wrote:
> On Thu, Jun 24, 2010 at 01:03:02PM +1000, npiggin@suse.de wrote:
> >  9 files changed, 47 insertions(+), 106 deletions(-)
> 
> The diffstat doesn't match the patch ;)

Bah, sorry.


> > Index: linux-2.6/include/linux/mm.h
> > ===================================================================
> > --- linux-2.6.orig/include/linux/mm.h
> > +++ linux-2.6/include/linux/mm.h
> > @@ -999,16 +999,19 @@ static inline void sync_mm_rss(struct ta
> >   * querying the cache size, so a fastpath for that case is appropriate.
> >   */
> >  struct shrinker {
> > -	int (*shrink)(int nr_to_scan, gfp_t gfp_mask);
> > -	int seeks;	/* seeks to recreate an obj */
> > -
> > +	int (*shrink)(struct zone *zone, unsigned long scanned, unsigned long total,
> > +					unsigned long global, gfp_t gfp_mask);
> 
> Can we add the shrinker structure to taht callback, too, so that we
> can get away from needing global context for the shrinker?

I was planning to merge this on top of your shrinker change (which I
like how the locking / refcounting worked out). So I was just going to
leave that part for you :)


> > +unsigned long shrinker_do_scan(unsigned long *dst, unsigned long batch)
> > +{
> > +	unsigned long nr = ACCESS_ONCE(*dst);
> 
> What's the point of ACCESS_ONCE() here?
> 
> /me gets most of the way into the patch
> 
> Oh, it's because you are using static variables for nr_to_scan and
> hence when concurrent shrinkers are running they are all
> incrementing and decrementing the same variable. That doesn't sound
> like a good idea to me - concurrent shrinkers are much more likely
> with per-zone shrinker callouts. It seems to me that a reclaim
> thread could be kept in a shrinker long after it has run it's
> scan count if new shrinker calls from a different reclaim context
> occur before the first has finished....

I don't think parallelism will be much changed. The existing shrinker
didn't provide any serialisation. It likewise did not serialise any
updates to shrinker->nr accumulator (reclaim is a crappy heuristic
anyway so it apparently doesn't matter too much that it is racy). So
a lot of your criticism of racy access to the accumulators isn't really
inherent to this patch

(where it's easy, I did put them under locks, but I didn't go out of my
way -- a subsequent patch could do that if we really wanted)

 
> As a further question - why do some shrinkerN? get converted to a
> single global nr_to_scan, and others get converted to a private
> nr_to_scan? Shouldn't they all use the same method? The static
> variable method looks to me to be full of races - concurrent callers
> to shrinker_add_scan() does not look at all thread safe to me.

Hmm, they should all have their own nr_to_scan.

 
> > +	if (nr < batch)
> > +		return 0;
> 
> Why wouldn't we return nr here to drain the remaining objects?

I was thinking, because it's not worth taking locks for a small
number of objects.

> Doesn't this mean we can't shrink caches that have a scan count of
> less than SHRINK_BATCH?

No, they just accumulate slowly until hitting the batch size.

 
> > -			count_vm_events(SLABS_SCANNED, this_scan);
> > -			total_scan -= this_scan;
> > -
> > -			cond_resched();
> 
> Removing this means we need cond_resched() in all shrinker loops now
> to maintain the same latencies as we currently have. I note that
> you've done this for most of the shrinkers, but the documentation
> needs to be updated to mention this...

That's true, yes.


> > -		}
> > -
> > -		shrinker->nr += total_scan;
> 
> And dropping this means we do not carry over the remainder of the
> previous scan into the next scan. This means we could be scanning a
> lot less with this new code.

We do because they accumulate to static variables. It's effectively
the same as accumulating to shrinker->nr, but it allows the per-zone
patches to change to accumulate to per-zone counters.


> > +again:
> > +	nr = 0;
> > +	for_each_zone(zone)
> > +		nr += shrink_slab(zone, 1, 1, 1, GFP_KERNEL);
> > +	if (nr >= 10)
> > +		goto again;
> 
> 	do {
> 		nr = 0;
> 		for_each_zone(zone)
> 			nr += shrink_slab(zone, 1, 1, 1, GFP_KERNEL);
> 	} while (nr >= 10);

OK.


> > @@ -1705,6 +1708,23 @@ static void shrink_zone(int priority, st
> >  	if (inactive_anon_is_low(zone, sc) && nr_swap_pages > 0)
> >  		shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
> >  
> > +	/*
> > +	 * Don't shrink slabs when reclaiming memory from
> > +	 * over limit cgroups
> > +	 */
> > +	if (scanning_global_lru(sc)) {
> > +		struct reclaim_state *reclaim_state = current->reclaim_state;
> > +
> > +		shrink_slab(zone, sc->nr_scanned - nr_scanned,
> > +			lru_pages, global_lru_pages, sc->gfp_mask);
> > +		if (reclaim_state) {
> > +			nr_reclaimed += reclaim_state->reclaimed_slab;
> > +			reclaim_state->reclaimed_slab = 0;
> > +		}
> > +	}
> 
> So effectively we are going to be calling shrink_slab() once per
> zone instead of once per priority loop, right? That means we are

Yes.


> going to be doing a lot more concurrent shrink_slab() calls that the
> current code. Combine that with the removal of residual aggregation,
> I think this will alter the reclaim balance somewhat. Have you tried
> to quantify this?

It will alter reclaim a bit. I don't think it will change the
concurrency too much (per-prio which gets chopped into batch
size calls into shrinker versus per-zone call which the shrinker
chops up itself).

Basically, the number of items to scan should be about the same,
and chopped into the same number of batches. It just depends on
exactly when it gets done.


> > -static int shrink_dcache_memory(int nr, gfp_t gfp_mask)
> > +static int shrink_dcache_memory(struct zone *zone, unsigned long scanned,
> > +		unsigned long total, unsigned long global, gfp_t gfp_mask)
> >  {
> > -	if (nr) {
> > -		if (!(gfp_mask & __GFP_FS))
> > -			return -1;
> > -		prune_dcache(nr);
> > -	}
> > -	return (dentry_stat.nr_unused / 100) * sysctl_vfs_cache_pressure;
> > +	prune_dcache(zone, scanned, global, gfp_mask);
> > +	return 0;
> >  }
> 
> I would have thought that putting the shrinker_add_scan/
> shrinker_do_scan loop in shrink_dcache_memory() and leaving
> prune_dcache untouched would have been a better separation.
> I note that this is what you did with prune_icache(), so consistency
> between the two would be good ;)

You're probably right, I'll go back and take a look.

 
> Also, this patch drops the __GFP_FS check from the dcache shrinker -
> not intentional, right?

Right, thanks.

 
> > +again:
> > +	nr = shrinker_do_scan(&nr_to_scan, SHRINK_BATCH);
> > +	if (!nr) {
> >  		spin_unlock(&mb_cache_spinlock);
> > -		goto out;
> > +		return 0;
> >  	}
> > -	while (nr_to_scan-- && !list_empty(&mb_cache_lru_list)) {
> > +	while (!list_empty(&mb_cache_lru_list)) {
> >  		struct mb_cache_entry *ce =
> >  			list_entry(mb_cache_lru_list.next,
> >  				   struct mb_cache_entry, e_lru_list);
> >  		list_move_tail(&ce->e_lru_list, &free_list);
> >  		__mb_cache_entry_unhash(ce);
> > +		cond_resched_lock(&mb_cache_spinlock);
> > +		if (!--nr)
> > +			break;
> >  	}
> >  	spin_unlock(&mb_cache_spinlock);
> >  	list_for_each_safe(l, ltmp, &free_list) {
> >  		__mb_cache_entry_forget(list_entry(l, struct mb_cache_entry,
> >  						   e_lru_list), gfp_mask);
> >  	}
> > -out:
> > -	return (count / 100) * sysctl_vfs_cache_pressure;
> > +	if (!nr) {
> > +		spin_lock(&mb_cache_spinlock);
> > +		goto again;
> > +	}
> 
> Another candidate for a do-while loop.

Maybe. I prefer not to indent so much (then one would argue to put the
body in a seperate function :), but meh)


> > +	nr = ACCESS_ONCE(nr_to_scan);
> > +	nr_to_scan = 0;
> 
> That's not safe for concurrent callers. Both could get nr =
> nr_to_scan rather than nr(1) = nr_to_scan and nr(2) = 0 which I
> think is the intent....

...

> I note that this use of a static scan count is thread safe because
> all the calculations are done under the kvm_lock. THat's three
> different ways the shrinkers implement the same functionality
> now....

...

> That's not thread safe - it's under a read lock. This code really
> needs a shrinker context....

So as I said above, lost updates are not cared about.


> > +	if (!(gfp_mask & __GFP_FS)) {
> > +		up_read(&xfs_mount_list_lock);
> > +		return 0;
> > +	}
> > +
> > +done:
> > +	nr = shrinker_do_scan(&nr_to_scan, SHRINK_BATCH);
> > +	if (!nr) {
> > +		up_read(&xfs_mount_list_lock);
> > +		return 0;
> > +	}
> > +	list_for_each_entry(mp, &xfs_mount_list, m_mplist) {
> > +		xfs_inode_ag_iterator(mp, xfs_reclaim_inode, 0,
> > +				XFS_ICI_RECLAIM_TAG, 1, &nr);
> > +		if (nr <= 0)
> > +			goto done;
> > +	}
> 
> That's missing conditional reschedules....

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
