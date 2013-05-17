Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id E54626B0032
	for <linux-mm@kvack.org>; Thu, 16 May 2013 20:51:38 -0400 (EDT)
Date: Fri, 17 May 2013 10:51:34 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v6 12/31] fs: convert inode and dentry shrinking to be
 node aware
Message-ID: <20130517005134.GK24635@dastard>
References: <1368382432-25462-1-git-send-email-glommer@openvz.org>
 <1368382432-25462-13-git-send-email-glommer@openvz.org>
 <20130514095200.GI29466@dastard>
 <5193A95E.70205@parallels.com>
 <20130516000216.GC24635@dastard>
 <5195302A.2090406@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5195302A.2090406@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, Dave Chinner <dchinner@redhat.com>

On Thu, May 16, 2013 at 11:14:50PM +0400, Glauber Costa wrote:
> 
> > IOWs, shr->nr_in_batch can grow much larger than any single node LRU
> > list, and the deffered count is only limited to (2 * max_pass).
> > Hence if the same node is the one that keeps stealing the global
> > shr->nr_in_batch calculation, it will always be a number related to
> > the size of the cache on that node. All the other nodes will simply
> > keep adding their delta counts to it.
> > 
> > Hence if you've got a node with less cache in it than others, and
> > kswapd comes along, it will see a gigantic amount of deferred work
> > in nr_in_batch, and then we end up removing a large amount of the
> > cache on that node, even though it hasn't had a significant amount
> > of pressure. And the node that has pressure continues to wind up
> > nr_in_batch until it's the one that gets hit by a kswapd run with
> > that wound up nr_in_batch....
> > 
> > Cheers,
> > 
> > Dave.
> > 
> Ok Dave,
> 
> My system in general seems to behave quite differently than this. In
> special, I hardly see peaks and the caches fill up very slowly. They
> later are pruned but always down to the same level, and then they grow
> slowly again, in a triangular fashion. Always within a fairly reasonable
> range. This might be because my disks are slower than yours.

Yes, that is the sort of pattern I'd expect from slower disks....

> It may also be some glitch in my setup. I spent a fair amount of time
> today trying to see your behavior but I can't. I will try more tomorrow.
> 
> For the time being, what do you think about the following patch (that
> obviously need a lot more work, just a PoC) ?
> 
> If we are indeed deferring work to unrelated nodes, keeping the deferred
> work per-node should help. I don't want to make it a static array
> because the shrinker structure tend to be embedded in structures. In
> particular, the superblock already have two list_lrus with per-node
> static arrays. This will make the sb gigantic. But that is not the main
> thing.

I'm not concerned about the size of the superblock structure, to
tell the truth. ;)


What I'd suggest is that the shrinker needs a flags/capabilities
field that indicates we care about per-node accounting, and only use
this method for the shrinkers that can actually do numa aware
shrinking.

> diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
> index 98be3ab..3edcd7f 100644
> --- a/include/linux/shrinker.h
> +++ b/include/linux/shrinker.h
> @@ -53,7 +53,7 @@ struct shrinker {
>  
>  	/* These are for internal use */
>  	struct list_head list;
> -	atomic_long_t nr_in_batch; /* objs pending delete */
> +	atomic_long_t *nr_in_batch; /* objs pending delete, per node */
>  };
>  #define DEFAULT_SEEKS 2 /* A good number if you don't know better. */
>  extern void register_shrinker(struct shrinker *);
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 35a6a9b..6dddc8d 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -159,7 +159,14 @@ static unsigned long get_lru_size(struct lruvec *lruvec, enum lru_list lru)
>   */
>  void register_shrinker(struct shrinker *shrinker)
>  {
> -	atomic_long_set(&shrinker->nr_in_batch, 0);
> +	int i = 0;
> +
> +	shrinker->nr_in_batch = kmalloc(sizeof(atomic_long_t) * nr_node_ids, GFP_KERNEL);
> +	BUG_ON(!shrinker->nr_in_batch); /* obviously bogus */
> +
> +	for (i = 0; i < nr_node_ids; i++)
> +		atomic_long_set(&shrinker->nr_in_batch[i], 0);
> +

just use kzalloc....

>  	down_write(&shrinker_rwsem);
>  	list_add_tail(&shrinker->list, &shrinker_list);
>  	up_write(&shrinker_rwsem);
> @@ -211,6 +218,7 @@ unsigned long shrink_slab(struct shrink_control *shrinkctl,
>  {
>  	struct shrinker *shrinker;
>  	unsigned long freed = 0;
> +	unsigned long nr_active_nodes = 0;
>  
>  	if (nr_pages_scanned == 0)
>  		nr_pages_scanned = SWAP_CLUSTER_MAX;
> @@ -229,6 +237,7 @@ unsigned long shrink_slab(struct shrink_control *shrinkctl,
>  		long new_nr;
>  		long batch_size = shrinker->batch ? shrinker->batch
>  						  : SHRINK_BATCH;
> +		int nid;
>  
>  		if (shrinker->scan_objects) {
>  			max_pass = shrinker->count_objects(shrinker, shrinkctl);
> @@ -238,12 +247,17 @@ unsigned long shrink_slab(struct shrink_control *shrinkctl,
>  		if (max_pass <= 0)
>  			continue;
>  
> -		/*
> -		 * copy the current shrinker scan count into a local variable
> -		 * and zero it so that other concurrent shrinker invocations
> -		 * don't also do this scanning work.
> -		 */
> -		nr = atomic_long_xchg(&shrinker->nr_in_batch, 0);
> +		nr = 0;
> +		for_each_node_mask(nid, shrinkctl->nodes_to_scan) {
> +			/*
> +			 * copy the current shrinker scan count into a local
> +			 * variable and zero it so that other concurrent
> +			 * shrinker invocations don't also do this scanning
> +			 * work.
> +			 */
> +			nr += atomic_long_xchg(&shrinker->nr_in_batch[nid], 0);

Just a thought - let's rename "nr_in_batch" to
"deferred_scan"....

> +			nr_active_nodes++;
> +		}
.....
> +		total_scan /= nr_active_nodes;
> +		for_each_node_mask(nid, shrinkctl->nodes_to_scan) {
> +			if (total_scan > 0)
> +				new_nr += atomic_long_add_return(total_scan / nr_active_nodes,
> +						&shrinker->nr_in_batch[nid]);

(you do the total_scan / nr_active_nodes twice here)

> +			else
> +				new_nr += atomic_long_read(&shrinker->nr_in_batch[nid]);
>  
> +		}

I don't think this solves the problem entirely - it still aggregates
multiple nodes together into the one count. It might be better, but
it will still bleed the deferred count from a single node into other
nodes that have no deferred count.

Perhaps we need to factor this code a little first - separate the
calculation from the per-shrinker loop, so we can do something like:

shrink_slab_node(shr, sc, nid)
{
	nodemask_clear(sc->nodemask);
	nodemask_set(sc->nodemask, nid)
	for each shrinker {
		deferred_count = atomic_long_xchg(&shr->deferred_scan[nid], 0);

		deferred_count = __shrink_slab(shr, sc, deferred_count);

		atomic_long_add(deferred_count, &shr->deferred_scan[nid]);
	}
}

And the existing shrink_slab function becomes something like:

shrink_slab(shr, sc, nodemask)
{
	if (shr->flags & SHRINKER_NUMA_AWARE) {
		for_each_node_mask(nid, nodemask)
			shrink_slab_node(shr, sc, nid)
		return;
	}

	for each shrinker {
		deferred_count = atomic_long_xchg(&shr->deferred_scan[0], 0);

		deferred_count = __shrink_slab(shr, sc, deferred_count);

		atomic_long_add(deferred_count, &shr->deferred_scan[0]);
	}
}

This then makes the deferred count properly node aware when the
underlying shrinker needs it to be, and prevents bleed from one node
to another. I'd much prefer to see us move to an explicitly node
based iteration like this than try to hack more stuff into
shrink_slab() and confuse it further.

The only thing I don't like about this is the extra nodemask needed,
which, like the scan control, would have to sit on the stack.
Suggestions for avoiding that problem are welcome.. :)

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
