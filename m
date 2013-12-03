Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f44.google.com (mail-yh0-f44.google.com [209.85.213.44])
	by kanga.kvack.org (Postfix) with ESMTP id 437496B0031
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 05:48:57 -0500 (EST)
Received: by mail-yh0-f44.google.com with SMTP id f64so9909385yha.3
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 02:48:56 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [2001:44b8:8060:ff02:300:1:2:6])
        by mx.google.com with ESMTP id m9si6923194yha.223.2013.12.03.02.48.54
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 02:48:55 -0800 (PST)
Date: Tue, 3 Dec 2013 21:48:49 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v12 09/18] vmscan: shrink slab on memcg pressure
Message-ID: <20131203104849.GD8803@dastard>
References: <cover.1385974612.git.vdavydov@parallels.com>
 <be01fd9afeedb7d5c7979347f4d6ddaf67c9082d.1385974612.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <be01fd9afeedb7d5c7979347f4d6ddaf67c9082d.1385974612.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, dchinner@redhat.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon, Dec 02, 2013 at 03:19:44PM +0400, Vladimir Davydov wrote:
> This patch makes direct reclaim path shrink slabs not only on global
> memory pressure, but also when we reach memory cgroup limit. To achieve
> that, it introduces a new per-shrinker flag, SHRINKER_MEMCG_AWARE, which
> should be set if the shrinker can handle per-memcg reclaim. For such
> shrinkers, shrink_slab() will iterate over all eligible memory cgroups
> (i.e. the cgroup that triggered the reclaim and all its descendants) and
> pass the current memory cgroup to the shrinker in shrink_control.memcg
> just like it passes the current NUMA node to NUMA-aware shrinkers.  It
> is completely up to memcg-aware shrinkers how to organize objects in
> order to provide required functionality. Currently none of the existing
> shrinkers is memcg-aware, but next patches will introduce per-memcg
> list_lru, which will facilitate the process of turning shrinkers that
> use list_lru to be memcg-aware.
> 
> The number of slab objects scanned on memcg pressure is calculated in
> the same way as on global pressure - it is proportional to the number of
> pages scanned over the number of pages eligible for reclaim (i.e. the
> number of on-LRU pages in the target memcg and all its descendants) -
> except we do not employ the nr_deferred per-shrinker counter to avoid
> memory cgroup isolation issues. Ideally, this counter should be made
> per-memcg.
> 
....

> @@ -236,11 +236,17 @@ shrink_slab_node(struct shrink_control *shrinkctl, struct shrinker *shrinker,
>  		return 0;
>  
>  	/*
> -	 * copy the current shrinker scan count into a local variable
> -	 * and zero it so that other concurrent shrinker invocations
> -	 * don't also do this scanning work.
> +	 * Do not touch global counter of deferred objects on memcg pressure to
> +	 * avoid isolation issues. Ideally the counter should be per-memcg.
>  	 */
> -	nr = atomic_long_xchg(&shrinker->nr_deferred[nid], 0);
> +	if (!shrinkctl->target_mem_cgroup) {
> +		/*
> +		 * copy the current shrinker scan count into a local variable
> +		 * and zero it so that other concurrent shrinker invocations
> +		 * don't also do this scanning work.
> +		 */
> +		nr = atomic_long_xchg(&shrinker->nr_deferred[nid], 0);
> +	}

That's ugly. Effectively it means that memcg reclaim is going to be
completely ineffective when large numbers of allocations and hence
reclaim attempts are done under GFP_NOFS context.

The only thing that keeps filesystem caches in balance when there is
lots of filesystem work going on (i.e. lots of GFP_NOFS allocations)
is the deferal of reclaim work to a context that can do something
about it.

>  	total_scan = nr;
>  	delta = (4 * fraction) / shrinker->seeks;
> @@ -296,21 +302,46 @@ shrink_slab_node(struct shrink_control *shrinkctl, struct shrinker *shrinker,
>  		cond_resched();
>  	}
>  
> -	/*
> -	 * move the unused scan count back into the shrinker in a
> -	 * manner that handles concurrent updates. If we exhausted the
> -	 * scan, there is no need to do an update.
> -	 */
> -	if (total_scan > 0)
> -		new_nr = atomic_long_add_return(total_scan,
> +	if (!shrinkctl->target_mem_cgroup) {
> +		/*
> +		 * move the unused scan count back into the shrinker in a
> +		 * manner that handles concurrent updates. If we exhausted the
> +		 * scan, there is no need to do an update.
> +		 */
> +		if (total_scan > 0)
> +			new_nr = atomic_long_add_return(total_scan,
>  						&shrinker->nr_deferred[nid]);
> -	else
> -		new_nr = atomic_long_read(&shrinker->nr_deferred[nid]);
> +		else
> +			new_nr = atomic_long_read(&shrinker->nr_deferred[nid]);
> +	}

So, if the memcg can't make progress, why wouldn't you defer the
work to the global scan? Or can't a global scan trim memcg LRUs?
And if it can't, then isn't that a major design flaw? Why not just
allow kswapd to walk memcg LRUs in the background?

/me just looked at patch 13

Yeah, this goes some way to explaining why something like patch 13
is necessary - slab shrinkers are not keeping up with page cache
reclaim because of GFP_NOFS allocations, and so the page cache
empties only leaving slab caches to be trimmed....


> +static unsigned long
> +shrink_slab_memcg(struct shrink_control *shrinkctl, struct shrinker *shrinker,
> +		  unsigned long fraction, unsigned long denominator)

what's this function got to do with memcgs? Why did you rename it
from the self explanitory shrink_slab_one() name that Glauber gave
it?

> +{
> +	unsigned long freed = 0;
> +
> +	if (shrinkctl->memcg && !memcg_kmem_is_active(shrinkctl->memcg))
> +		return 0;

Why here? why not check that in the caller where memcg's are being
iterated?

> +
> +	for_each_node_mask(shrinkctl->nid, shrinkctl->nodes_to_scan) {
> +		if (!node_online(shrinkctl->nid))
> +			continue;
> +
> +		if (!(shrinker->flags & SHRINKER_NUMA_AWARE) &&
> +		    (shrinkctl->nid != 0))
> +			break;

Hmmm - this looks broken. Nothing guarantees that node 0 in
shrinkctl->nodes_to_scan is ever set, so non-numa aware shrinkers
will do nothing when the first node in the mask is not set. For non-numa
aware shrinkers, the shrinker should always be called once with a
node id of 0.

That's what earlier versions of the numa aware shrinker patch set
did, and it seems to have been lost along the way.  Yeah, there's
the last version from Glauber's tree that I saw:

static unsigned long
shrink_slab_one(struct shrink_control *shrinkctl, struct shrinker *shrinker,
               unsigned long nr_pages_scanned, unsigned long lru_pages)
{
       unsigned long freed = 0;

       if (!(shrinker->flags & SHRINKER_NUMA_AWARE)) {
               shrinkctl->nid = 0;

               return shrink_slab_node(shrinkctl, shrinker,
                        nr_pages_scanned, lru_pages,
                        &shrinker->nr_deferred);
       }

       for_each_node_mask(shrinkctl->nid, shrinkctl->nodes_to_scan)

               if (!node_online(shrinkctl->nid))
                       continue;

               freed += shrink_slab_node(shrinkctl, shrinker,
                        nr_pages_scanned, lru_pages,
			 &shrinker->nr_deferred_node[shrinkctl->nid]);
       }

       return freed;
}

So, that's likely to be another reason that all the non-numa slab
caches are not being shrunk appropriately and need to be hit with a
bit hammer...

> @@ -352,18 +383,23 @@ unsigned long shrink_slab(struct shrink_control *shrinkctl,
>  	}
>  
>  	list_for_each_entry(shrinker, &shrinker_list, list) {
> -		for_each_node_mask(shrinkctl->nid, shrinkctl->nodes_to_scan) {
> -			if (!node_online(shrinkctl->nid))
> -				continue;
> -
> -			if (!(shrinker->flags & SHRINKER_NUMA_AWARE) &&
> -			    (shrinkctl->nid != 0))
> +		shrinkctl->memcg = shrinkctl->target_mem_cgroup;
> +		do {
> +			if (!(shrinker->flags & SHRINKER_MEMCG_AWARE) &&
> +			    (shrinkctl->memcg != NULL)) {
> +				mem_cgroup_iter_break(
> +						shrinkctl->target_mem_cgroup,
> +						shrinkctl->memcg);
>  				break;
> +			}
>  
> -			freed += shrink_slab_node(shrinkctl, shrinker,
> -						  fraction, denominator);
> +			freed += shrink_slab_memcg(shrinkctl, shrinker,
> +						   fraction, denominator);
> +			shrinkctl->memcg = mem_cgroup_iter(
> +						shrinkctl->target_mem_cgroup,
> +						shrinkctl->memcg, NULL);
> +		} while (shrinkctl->memcg);

Glauber's tree also had a bunch of comments explaining what was
going on here. I've got no idea what the hell this code is doing,
and why the hell we are iterating memcgs here and how and why the
normal, non-memcg scan and shrinkers still worked.

This is now just a bunch of memcg gobbledegook with no explanations
to tell us what it is supposed to be doing. Comments are important -
you might not think they are necessary, but seeing comments like
this:

+               /*
+                * In a hierarchical chain, it might be that not all memcgs are
+                * kmem active. kmemcg design mandates that when one memcg is
+                * active, its children will be active as well. But it is
+                * perfectly possible that its parent is not.
+                *
+                * We also need to make sure we scan at least once, for the
+                * global case. So if we don't have a target memcg (saved in
+                * root), we proceed normally and expect to break in the next
+                * round.
+                */

in Glauber's tree helped an awful lot to explain the mess that the
memcg stuff was making of the code...

I'm liking this patch set less and less as I work my way through
it...

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
