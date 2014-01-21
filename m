Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f173.google.com (mail-yk0-f173.google.com [209.85.160.173])
	by kanga.kvack.org (Postfix) with ESMTP id AB0FA6B0035
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 22:04:33 -0500 (EST)
Received: by mail-yk0-f173.google.com with SMTP id 20so3300630yks.4
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 19:04:33 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [2001:44b8:8060:ff02:300:1:2:7])
        by mx.google.com with ESMTP id 49si1643937yhj.263.2014.01.20.19.04.30
        for <linux-mm@kvack.org>;
        Mon, 20 Jan 2014 19:04:32 -0800 (PST)
Date: Tue, 21 Jan 2014 14:03:58 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [patch 9/9] mm: keep page cache radix tree nodes in check
Message-ID: <20140121030358.GN18112@dastard>
References: <1389377443-11755-1-git-send-email-hannes@cmpxchg.org>
 <1389377443-11755-10-git-send-email-hannes@cmpxchg.org>
 <20140117000517.GB18112@dastard>
 <20140120231737.GS6963@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140120231737.GS6963@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Bob Liu <bob.liu@oracle.com>, Christoph Hellwig <hch@infradead.org>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>, Metin Doslu <metin@citusdata.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan.kim@gmail.com>, Ozgun Erdogan <ozgun@citusdata.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Roman Gushchin <klamm@yandex-team.ru>, Ryan Mallon <rmallon@gmail.com>, Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Jan 20, 2014 at 06:17:37PM -0500, Johannes Weiner wrote:
> On Fri, Jan 17, 2014 at 11:05:17AM +1100, Dave Chinner wrote:
> > On Fri, Jan 10, 2014 at 01:10:43PM -0500, Johannes Weiner wrote:
> > > +	/* Only shadow entries in there, keep track of this node */
> > > +	if (!(node->count & RADIX_TREE_COUNT_MASK) &&
> > > +	    list_empty(&node->private_list)) {
> > > +		node->private_data = mapping;
> > > +		list_lru_add(&workingset_shadow_nodes, &node->private_list);
> > > +	}
> > 
> > You can't do this list_empty(&node->private_list) check safely
> > externally to the list_lru code - only time that entry can be
> > checked safely is under the LRU list locks. This is the reason that
> > list_lru_add/list_lru_del return a boolean to indicate is the object
> > was added/removed from the list - they do this list_empty() check
> > internally. i.e. the correct, safe way to do conditionally update
> > state iff the object was added to the LRU is:
> > 
> > 	if (!(node->count & RADIX_TREE_COUNT_MASK)) {
> > 		if (list_lru_add(&workingset_shadow_nodes, &node->private_list))
> > 			node->private_data = mapping;
> > 	}
> > 
> > > +	radix_tree_replace_slot(slot, page);
> > > +	mapping->nrpages++;
> > > +	if (node) {
> > > +		node->count++;
> > > +		/* Installed page, can't be shadow-only anymore */
> > > +		if (!list_empty(&node->private_list))
> > > +			list_lru_del(&workingset_shadow_nodes,
> > > +				     &node->private_list);
> > > +	}
> > 
> > Same issue here:
> > 
> > 	if (node) {
> > 		node->count++;
> > 		list_lru_del(&workingset_shadow_nodes, &node->private_list);
> > 	}
> 
> All modifications to node->private_list happen under
> mapping->tree_lock, and modifications of a neighboring link should not
> affect the outcome of the list_empty(), so I don't think the lru lock
> is necessary.

Can you please add that as a comment somewhere explaining why it is
safe to do this?

> > > +		case LRU_REMOVED_RETRY:
> > >  			if (--nlru->nr_items == 0)
> > >  				node_clear(nid, lru->active_nodes);
> > >  			WARN_ON_ONCE(nlru->nr_items < 0);
> > >  			isolated++;
> > > +			/*
> > > +			 * If the lru lock has been dropped, our list
> > > +			 * traversal is now invalid and so we have to
> > > +			 * restart from scratch.
> > > +			 */
> > > +			if (ret == LRU_REMOVED_RETRY)
> > > +				goto restart;
> > >  			break;
> > >  		case LRU_ROTATE:
> > >  			list_move_tail(item, &nlru->list);
> > 
> > I think that we need to assert that the list lru lock is correctly
> > held here on return with LRU_REMOVED_RETRY. i.e.
> > 
> > 		case LRU_REMOVED_RETRY:
> > 			assert_spin_locked(&nlru->lock);
> > 		case LRU_REMOVED:
> 
> Ah, good idea.  How about adding it to LRU_RETRY as well?

Yup, good idea.

> > > +static struct shrinker workingset_shadow_shrinker = {
> > > +	.count_objects = count_shadow_nodes,
> > > +	.scan_objects = scan_shadow_nodes,
> > > +	.seeks = DEFAULT_SEEKS * 4,
> > > +	.flags = SHRINKER_NUMA_AWARE,
> > > +};
> > 
> > Can you add a comment explaining how you calculated the .seeks
> > value? It's important to document the weighings/importance
> > we give to slab reclaim so we can determine if it's actually
> > acheiving the desired balance under different loads...
> 
> This is not an exact science, to say the least.

I know, that's why I asked it be documented rather than be something
kept in your head.

> The shadow entries are mostly self-regulated, so I don't want the
> shrinker to interfere while the machine is just regularly trimming
> caches during normal operation.
> 
> It should only kick in when either a) reclaim is picking up and the
> scan-to-reclaim ratio increases due to mapped pages, dirty cache,
> swapping etc. or b) the number of objects compared to LRU pages
> becomes excessive.
> 
> I think that is what most shrinkers with an elevated seeks value want,
> but this translates very awkwardly (and not completely) to the current
> cost model, and we should probably rework that interface.
> 
> "Seeks" currently encodes 3 ratios:
> 
>   1. the cost of creating an object vs. a page
> 
>   2. the expected number of objects vs. pages

It doesn't encode that at all. If it did, then the default value
wouldn't be "2".

>   3. the cost of reclaiming an object vs. a page

Which, when you consider #3 in conjunction with #1, the actual
intended meaning of .seeks is "the cost of replacing this object in
the cache compared to the cost of replacing a page cache page."

> but they are not necessarily correlated.  How I would like to
> configure the shadow shrinker instead is:
> 
>   o scan objects when reclaim efficiency is down to 75%, because they
>     are more valuable than use-once cache but less than workingset
> 
>   o scan objects when the ratio between them and the number of pages
>     exceeds 1/32 (one shadow entry for each resident page, up to 64
>     entries per shrinkable object, assume 50% packing for robustness)
> 
>   o as the expected balance between objects and lru pages is 1:32,
>     reclaim one object for every 32 reclaimed LRU pages, instead of
>     assuming that number of scanned pages corresponds meaningfully to
>     number of objects to scan.

You're assuming that every radix tree node has a full population of
pages. This only occurs on sequential read and write workloads, and
so isn't going tobe true for things like mapped executables or any
semi-randomly accessed data set...

> "4" just doesn't have the same ring to it.

Right, but you still haven't explained how you came to the value of
"4"....

> It would be great if we could eliminate the reclaim cost assumption by
> turning the nr_to_scan into a nr_to_reclaim, and then set the other
> two ratios independently.

That doesn't work for caches that are full of objects that can't (or
won't) be reclaimed immediately. The CPU cost of repeatedly scanning
to find N reclaimable objects when you have millions of objects in
the cache is prohibitive.

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
