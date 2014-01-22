Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 1F6FE6B0039
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 13:49:16 -0500 (EST)
Received: by mail-wg0-f44.google.com with SMTP id l18so679446wgh.35
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 10:49:15 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id be10si7374803wjc.54.2014.01.22.10.49.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 10:49:15 -0800 (PST)
Date: Wed, 22 Jan 2014 13:48:36 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 9/9] mm: keep page cache radix tree nodes in check
Message-ID: <20140122184836.GE4407@cmpxchg.org>
References: <1389377443-11755-1-git-send-email-hannes@cmpxchg.org>
 <1389377443-11755-10-git-send-email-hannes@cmpxchg.org>
 <20140117000517.GB18112@dastard>
 <20140120231737.GS6963@cmpxchg.org>
 <20140121030358.GN18112@dastard>
 <20140121055017.GT6963@cmpxchg.org>
 <20140122030607.GB27606@dastard>
 <20140122065714.GU6963@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140122065714.GU6963@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Bob Liu <bob.liu@oracle.com>, Christoph Hellwig <hch@infradead.org>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>, Metin Doslu <metin@citusdata.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan.kim@gmail.com>, Ozgun Erdogan <ozgun@citusdata.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Roman Gushchin <klamm@yandex-team.ru>, Ryan Mallon <rmallon@gmail.com>, Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Jan 22, 2014 at 01:57:14AM -0500, Johannes Weiner wrote:
> Not at this time, I'll try to look into that.  For now, I am updating
> the patch to revert the shrinker back to DEFAULT_SEEKS and change the
> object count to only include objects above a certain threshold, which
> assumes a worst-case population of 4 in 64 slots.  It's not perfect,
> but neither was the seeks magic, and it's easier to reason about what
> it's actually doing.

Ah, the quality of 2am submissions...  8 out of 64 of course.

> @@ -266,14 +269,38 @@ struct list_lru workingset_shadow_nodes;
>  static unsigned long count_shadow_nodes(struct shrinker *shrinker,
>  					struct shrink_control *sc)
>  {
> -	return list_lru_count_node(&workingset_shadow_nodes, sc->nid);
> +	unsigned long shadow_nodes;
> +	unsigned long max_nodes;
> +	unsigned long pages;
> +
> +	shadow_nodes = list_lru_count_node(&workingset_shadow_nodes, sc->nid);
> +	pages = node_present_pages(sc->nid);
> +	/*
> +	 * Active cache pages are limited to 50% of memory, and shadow
> +	 * entries that represent a refault distance bigger than that
> +	 * do not have any effect.  Limit the number of shadow nodes
> +	 * such that shadow entries do not exceed the number of active
> +	 * cache pages, assuming a worst-case node population density
> +	 * of 1/16th on average.

1/8th.  The actual code is consistent:

> +	 * On 64-bit with 7 radix_tree_nodes per page and 64 slots
> +	 * each, this will reclaim shadow entries when they consume
> +	 * ~2% of available memory:
> +	 *
> +	 * PAGE_SIZE / radix_tree_nodes / node_entries / PAGE_SIZE
> +	 */
> +	max_nodes = pages >> (1 + RADIX_TREE_MAP_SHIFT - 3);
> +
> +	if (shadow_nodes <= max_nodes)
> +		return 0;
> +
> +	return shadow_nodes - max_nodes;
>  }
>  
>  static enum lru_status shadow_lru_isolate(struct list_head *item,
>  					  spinlock_t *lru_lock,
>  					  void *arg)
>  {
> -	unsigned long *nr_reclaimed = arg;
>  	struct address_space *mapping;
>  	struct radix_tree_node *node;
>  	unsigned int i;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
