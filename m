Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id EDD466B005A
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 19:08:17 -0400 (EDT)
Date: Wed, 5 Jun 2013 16:08:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v10 13/35] vmscan: per-node deferred work
Message-Id: <20130605160815.fb69f7d4d1736455727fc669@linux-foundation.org>
In-Reply-To: <1370287804-3481-14-git-send-email-glommer@openvz.org>
References: <1370287804-3481-1-git-send-email-glommer@openvz.org>
	<1370287804-3481-14-git-send-email-glommer@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>, Dave Chinner <dchinner@redhat.com>

On Mon,  3 Jun 2013 23:29:42 +0400 Glauber Costa <glommer@openvz.org> wrote:

> We already keep per-node LRU lists for objects being shrunk, but the
> work that is deferred from one run to another is kept global. This
> creates an impedance problem, where upon node pressure, work deferred
> will accumulate and end up being flushed in other nodes.

This changelog would be more useful if it had more specificity.  Where
do we keep these per-node LRU lists (names of variables?).  Where do we
keep the global data?  In what function does this other-node flushing
happen?

Generally so that readers can go and look at the data structures and
functions which you're talking about.

> In large machines, many nodes can accumulate at the same time, all
> adding to the global counter.

What global counter?

>  As we accumulate more and more, we start
> to ask for the caches to flush even bigger numbers.

Where does this happen?

> The result is that
> the caches are depleted and do not stabilize. To achieve stable steady
> state behavior, we need to tackle it differently.
> 
> In this patch we keep the deferred count per-node, and will never
> accumulate that to other nodes.
> 
> ...
>
> --- a/include/linux/shrinker.h
> +++ b/include/linux/shrinker.h
> @@ -19,6 +19,8 @@ struct shrink_control {
>  
>  	/* shrink from these nodes */
>  	nodemask_t nodes_to_scan;
> +	/* current node being shrunk (for NUMA aware shrinkers) */
> +	int nid;
>  };
>  
>  /*
> @@ -42,6 +44,8 @@ struct shrink_control {
>   * objects freed during the scan, or -1 if progress cannot be made due to
>   * potential deadlocks. If -1 is returned, then no further attempts to call the
>   * @scan_objects will be made from the current reclaim context.
> + *
> + * @flags determine the shrinker abilities, like numa awareness 
>   */
>  struct shrinker {
>  	int (*shrink)(struct shrinker *, struct shrink_control *sc);
> @@ -50,12 +54,34 @@ struct shrinker {
>  
>  	int seeks;	/* seeks to recreate an obj */
>  	long batch;	/* reclaim batch size, 0 = default */
> +	unsigned long flags;
>  
>  	/* These are for internal use */
>  	struct list_head list;
> -	atomic_long_t nr_in_batch; /* objs pending delete */
> +	/*
> +	 * We would like to avoid allocating memory when registering a new
> +	 * shrinker.

That's quite surprising.  What are the reasons for this?

>		 All shrinkers will need to keep track of deferred objects,

What is a deferred object and why does this deferral happen?

> +	 * and we need a counter for this. If the shrinkers are not NUMA aware,
> +	 * this is a small and bounded space that fits into an atomic_long_t.
> +	 * This is because that the deferring decisions are global, and we will

s/that//

> +	 * not allocate in this case.
> +	 *
> +	 * When the shrinker is NUMA aware, we will need this to be a per-node
> +	 * array. Numerically speaking, the minority of shrinkers are NUMA
> +	 * aware, so this saves quite a bit.
> +	 */

I don't really understand what's going on here :(

> +	union {
> +		/* objs pending delete */
> +		atomic_long_t nr_deferred;
> +		/* objs pending delete, per node */
> +		atomic_long_t *nr_deferred_node;
> +	};
>  };
>  #define DEFAULT_SEEKS 2 /* A good number if you don't know better. */
> -extern void register_shrinker(struct shrinker *);
> +
> +/* Flags */
> +#define SHRINKER_NUMA_AWARE (1 << 0)
> +
> +extern int register_shrinker(struct shrinker *);
>  extern void unregister_shrinker(struct shrinker *);
>  #endif
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 53e647f..08eec9d 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -155,14 +155,36 @@ static unsigned long get_lru_size(struct lruvec *lruvec, enum lru_list lru)
>  }
>  
>  /*
> - * Add a shrinker callback to be called from the vm
> + * Add a shrinker callback to be called from the vm.
> + *
> + * It cannot fail, unless the flag SHRINKER_NUMA_AWARE is specified.
> + * With this flag set, this function will allocate memory and may fail.
>   */

Again, I don't see what the big deal is with memory allocation. 
register_shrinker() is pretty rare, is likely to happen when the system
is under little stress and GFP_KERNEL is quite strong.  Why all the
concern?

> -void register_shrinker(struct shrinker *shrinker)
> +int register_shrinker(struct shrinker *shrinker)
>  {
> -	atomic_long_set(&shrinker->nr_in_batch, 0);
> +	/*
> +	 * If we only have one possible node in the system anyway, save
> +	 * ourselves the trouble and disable NUMA aware behavior. This way we
> +	 * will allocate nothing and save memory and some small loop time
> +	 * later.
> +	 */
> +	if (nr_node_ids == 1)
> +		shrinker->flags &= ~SHRINKER_NUMA_AWARE;
> +
> +	if (shrinker->flags & SHRINKER_NUMA_AWARE) {
> +		size_t size;
> +
> +		size = sizeof(*shrinker->nr_deferred_node) * nr_node_ids;
> +		shrinker->nr_deferred_node = kzalloc(size, GFP_KERNEL);
> +		if (!shrinker->nr_deferred_node)
> +			return -ENOMEM;
> +	} else
> +		atomic_long_set(&shrinker->nr_deferred, 0);
> +
>  	down_write(&shrinker_rwsem);
>  	list_add_tail(&shrinker->list, &shrinker_list);
>  	up_write(&shrinker_rwsem);
> +	return 0;
>  }
>  EXPORT_SYMBOL(register_shrinker);

What would be the cost if we were to do away with SHRINKER_NUMA_AWARE
and treat all shrinkers the same way?  The need to allocate extra
memory per shrinker?  That sounds pretty cheap?

> @@ -186,6 +208,116 @@ static inline int do_shrinker_shrink(struct shrinker *shrinker,
>  }
>  
>  #define SHRINK_BATCH 128
> +
> +static unsigned long
> +shrink_slab_node(struct shrink_control *shrinkctl, struct shrinker *shrinker,
> +		 unsigned long nr_pages_scanned, unsigned long lru_pages,
> +		 atomic_long_t *deferred)
> +{
> +	unsigned long freed = 0;
> +	unsigned long long delta;
> +	long total_scan;
> +	long max_pass;
> +	long nr;
> +	long new_nr;
> +	long batch_size = shrinker->batch ? shrinker->batch
> +					  : SHRINK_BATCH;
> +
> +	if (shrinker->scan_objects) {
> +		max_pass = shrinker->count_objects(shrinker, shrinkctl);
> +		WARN_ON(max_pass < 0);
> +	} else
> +		max_pass = do_shrinker_shrink(shrinker, shrinkctl, 0);
> +	if (max_pass <= 0)
> +		return 0;
> +
> +	/*
> +	 * copy the current shrinker scan count into a local variable
> +	 * and zero it so that other concurrent shrinker invocations
> +	 * don't also do this scanning work.
> +	 */
> +	nr = atomic_long_xchg(deferred, 0);

This comment seems wrong.  It implies that "deferred" refers to "the
current shrinker scan count".  But how are these two the same thing?  A
"scan count" would refer to the number of objects to be scanned (or
which were scanned - it's unclear).  Whereas "deferred" would refer to
the number of those to-be-scanned objects which we didn't process and
is hence less than or equal to the "scan count".

It's all very foggy :(  This whole concept of deferral needs more
explanation, please.

> +	total_scan = nr;
> +	delta = (4 * nr_pages_scanned) / shrinker->seeks;
> +	delta *= max_pass;
> +	do_div(delta, lru_pages + 1);
> +	total_scan += delta;
> +	if (total_scan < 0) {
> +		printk(KERN_ERR
> +		"shrink_slab: %pF negative objects to delete nr=%ld\n",
> +		       shrinker->shrink, total_scan);
> +		total_scan = max_pass;
> +	}
> +
> +	/*
> +	 * We need to avoid excessive windup on filesystem shrinkers
> +	 * due to large numbers of GFP_NOFS allocations causing the
> +	 * shrinkers to return -1 all the time. This results in a large
> +	 * nr being built up so when a shrink that can do some work
> +	 * comes along it empties the entire cache due to nr >>>
> +	 * max_pass.  This is bad for sustaining a working set in
> +	 * memory.
> +	 *
> +	 * Hence only allow the shrinker to scan the entire cache when
> +	 * a large delta change is calculated directly.
> +	 */

That was an important comment.  So the whole problem we're tackling
here is fs shrinkers baling out in GFP_NOFS allocations?


> +	if (delta < max_pass / 4)
> +		total_scan = min(total_scan, max_pass / 2);
> +
> +	/*
> +	 * Avoid risking looping forever due to too large nr value:
> +	 * never try to free more than twice the estimate number of

"estimated"

> +	 * freeable entries.
> +	 */
> +	if (total_scan > max_pass * 2)
> +		total_scan = max_pass * 2;
> +
> +	trace_mm_shrink_slab_start(shrinker, shrinkctl, nr,
> +				nr_pages_scanned, lru_pages,
> +				max_pass, delta, total_scan);
> +
> +	while (total_scan >= batch_size) {
> +		long ret;
> +
> +		if (shrinker->scan_objects) {
> +			shrinkctl->nr_to_scan = batch_size;
> +			ret = shrinker->scan_objects(shrinker, shrinkctl);
> +
> +			if (ret == -1)
> +				break;
> +			freed += ret;
> +		} else {
> +			int nr_before;
> +			nr_before = do_shrinker_shrink(shrinker, shrinkctl, 0);
> +			ret = do_shrinker_shrink(shrinker, shrinkctl,
> +							batch_size);
> +			if (ret == -1)
> +				break;
> +			if (ret < nr_before)
> +				freed += nr_before - ret;
> +		}
> +
> +		count_vm_events(SLABS_SCANNED, batch_size);
> +		total_scan -= batch_size;
> +
> +		cond_resched();
> +	}
> +
> +	/*
> +	 * move the unused scan count back into the shrinker in a
> +	 * manner that handles concurrent updates. If we exhausted the
> +	 * scan, there is no need to do an update.
> +	 */
> +	if (total_scan > 0)
> +		new_nr = atomic_long_add_return(total_scan, deferred);
> +	else
> +		new_nr = atomic_long_read(deferred);
> +
> +	trace_mm_shrink_slab_end(shrinker, freed, nr, new_nr);
> +	return freed;
> +}
> 
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
