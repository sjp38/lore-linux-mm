Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5592E8D0080
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 02:43:47 -0500 (EST)
Date: Tue, 16 Nov 2010 18:43:35 +1100
From: Nick Piggin <npiggin@kernel.dk>
Subject: Re: [patch] mm: vmscan implement per-zone shrinkers
Message-ID: <20101116074335.GA3460@amd>
References: <20101109123246.GA11477@amd>
 <20101114182614.BEE5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101114182614.BEE5.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Nick Piggin <npiggin@kernel.dk>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sun, Nov 14, 2010 at 07:07:17PM +0900, KOSAKI Motohiro wrote:
> Hi
> 
> > Hi,
> > 
> > I'm doing some works that require per-zone shrinkers, I'd like to get
> > the vmscan part signed off and merged by interested mm people, please.
> > 
> > [And before anybody else kindly suggests per-node shrinkers, please go
> > back and read all the discussion about this first.]
> 
> vmscan part looks good to me. however I hope fs folks review too even though
> I'm not sure who is best.
> 
> btw, I have some nitpick comments. see below.

Thanks for the review, it's very helpful.


> > +	void (*shrink_zone)(struct shrinker *shrink,
> > +		struct zone *zone, unsigned long scanned,
> > +		unsigned long total, unsigned long global,
> > +		unsigned long flags, gfp_t gfp_mask);
> > +
> 
> shrink_zone is slightly grep unfriendly. Can you consider shrink_slab_zone() 
> or something else?

Yes that's true. I want to move away from the term "slab" shrinker
however. It seems to confuse people (of course, the shrinker can shrink
memory from any allocator, not just slab).

shrink_cache_zone()?


> > +void shrinker_add_scan(unsigned long *dst,
> > +			unsigned long scanned, unsigned long total,
> > +			unsigned long objects, unsigned int ratio)
> >  {
> > -	struct shrinker *shrinker;
> > -	unsigned long ret = 0;
> > +	unsigned long long delta;
> >  
> > -	if (scanned == 0)
> > -		scanned = SWAP_CLUSTER_MAX;
> > +	delta = (unsigned long long)scanned * objects;
> > +	delta *= SHRINK_FACTOR;
> > +	do_div(delta, total + 1);
> 
> > +	delta *= SHRINK_FACTOR; /* ratio is also in SHRINK_FACTOR units */
> > +	do_div(delta, ratio + 1);
> 
> introdusing tiny macro is better than the comment.
> 
> >  
> > -	if (!down_read_trylock(&shrinker_rwsem))
> > -		return 1;	/* Assume we'll be able to shrink next time */
> > +	/*
> > +	 * Avoid risking looping forever due to too large nr value:
> > +	 * never try to free more than twice the estimate number of
> > +	 * freeable entries.
> > +	 */
> > +	*dst += delta;
> > +
> > +	if (*dst / SHRINK_FACTOR > objects)
> > +		*dst = objects * SHRINK_FACTOR;
> 
> objects * SHRINK_FACTOR appear twice in this function.
> calculate "objects = obj * SHRINK_FACTOR" at first improve
> code readability slightly.
 
I wasn't quite sure what you meant with this comment and the above one.
Could you illustrate what your preferred code would look like?


> > +unsigned long shrinker_do_scan(unsigned long *dst, unsigned long batch)
> 
> Seems misleading name a bit. shrinker_do_scan() does NOT scan. 
> It only does batch adjustment.

True. shrinker_get_batch_nr() or similar?

 
> > +{
> > +	unsigned long nr = ACCESS_ONCE(*dst);
> 
> Dumb question: why is this ACCESS_ONCE() necessary?
> 
> 
> > +	if (nr < batch * SHRINK_FACTOR)
> > +		return 0;
> > +	*dst = nr - batch * SHRINK_FACTOR;
> > +	return batch;

It should have a comment: *dst can be accessed without a lock.
However if nr is reloaded from memory between the two expressions
and *dst changes during that time, we could end up with a negative
result in *dst.

> {
> 	unsigned long nr = ACCESS_ONCE(*dst);
> 	batch *= SHRINK_FACTOR;
> 
> 	if (nr < batch)
> 		return 0;
> 	*dst = nr - batch;
> 	return batch;
> }
> 
> is slighly cleaner. however It's unclear why dst and batch argument
> need to have different unit (i.e why caller can't do batch * FACTOR?).

OK I'll take it into consideration. I guess I didn't want the caller
to care too much about the fixed point.


> > +	list_for_each_entry(shrinker, &shrinker_list, list) {
> > +		if (!shrinker->shrink_zone)
> > +			continue;
> > +		(*shrinker->shrink_zone)(shrinker, zone, scanned,
> > +					total, global, 0, gfp_mask);
> 
> flags argument is unused?

Yes it is, at the moment. I actually have a flag that I would like
to use (close to OOM flag), so I've just added the placeholder for
now.

It may well be useful for other things in future too.


> > @@ -1844,6 +1985,23 @@ static void shrink_zone(int priority, st
> >  	if (inactive_anon_is_low(zone, sc))
> >  		shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
> >  
> > +	/*
> > +	 * Don't shrink slabs when reclaiming memory from
> > +	 * over limit cgroups
> > +	 */
> > +	if (sc->may_reclaim_slab) {
> > +		struct reclaim_state *reclaim_state = current->reclaim_state;
> > +
> > +		shrink_slab(zone, sc->nr_scanned - nr_scanned,
> 
> Doubtful calculation. What mean "sc->nr_scanned - nr_scanned"?
> I think nr_scanned simply keep old slab balancing behavior.

OK, good catch.


> > +		for_each_zone_zonelist(zone, z, zonelist,
> > +				gfp_zone(sc->gfp_mask)) {
> > +			if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
> > +				continue;
> >  
> > -			shrink_slab(sc->nr_scanned, sc->gfp_mask, lru_pages);
> > -			if (reclaim_state) {
> > -				sc->nr_reclaimed += reclaim_state->reclaimed_slab;
> > -				reclaim_state->reclaimed_slab = 0;
> > -			}
> > +			lru_pages += zone_reclaimable_pages(zone);
> 
> Do we really need this doubtful cpuset hardwall filtering? Why do we
> need to change slab reclaim pressure if cpuset is used. In old days,
> we didn't have per-zone slab shrinker, then we need artificial slab
> pressure boost for preventing false positive oom-killer. but now we have.

Yeah I'm not completely sure. But we should be mindful that until the
major caches are converted to LRU, we still have to care for the global
shrinker case too.


> However, If you strongly keep old behavior at this time, I don't oppose.
> We can change it later.

Yes I would prefer that, but I would welcome patches to improve things.


> > +		/*
> > +		 * lru_pages / 10  -- put a 10% pressure on the slab
> > +		 * which roughly corresponds to ZONE_RECLAIM_PRIORITY
> > +		 * scanning 1/16th of pagecache.
> > +		 *
> > +		 * Global slabs will be shrink at a relatively more
> > +		 * aggressive rate because we don't calculate the
> > +		 * global lru size for speed. But they really should
> > +		 * be converted to per zone slabs if they are important
> > +		 */
> > +		shrink_slab(zone, lru_pages / 10, lru_pages, lru_pages,
> > +				gfp_mask);
> 
> Why don't you use sc.nr_scanned? It seems straight forward.

Well it may not be over the pagecache limit.

I agree the situation is pretty ugly here with all these magic
constants, but I didn't want to change too much in this patch.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
