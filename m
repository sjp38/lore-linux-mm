Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 83ABF82F5F
	for <linux-mm@kvack.org>; Thu, 18 Aug 2016 07:52:24 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id o80so14616017wme.1
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 04:52:24 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id sn9si1541685wjb.45.2016.08.18.04.52.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Aug 2016 04:52:21 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id i138so5245843wmf.3
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 04:52:21 -0700 (PDT)
Date: Thu, 18 Aug 2016 13:52:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm/slab: Improve performance of gathering slabinfo
 stats
Message-ID: <20160818115218.GJ30162@dhcp22.suse.cz>
References: <1471458050-29622-1-git-send-email-aruna.ramakrishna@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1471458050-29622-1-git-send-email-aruna.ramakrishna@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aruna Ramakrishna <aruna.ramakrishna@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Kravetz <mike.kravetz@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed 17-08-16 11:20:50, Aruna Ramakrishna wrote:
> On large systems, when some slab caches grow to millions of objects (and
> many gigabytes), running 'cat /proc/slabinfo' can take up to 1-2 seconds.
> During this time, interrupts are disabled while walking the slab lists
> (slabs_full, slabs_partial, and slabs_free) for each node, and this
> sometimes causes timeouts in other drivers (for instance, Infiniband).
> 
> This patch optimizes 'cat /proc/slabinfo' by maintaining a counter for
> total number of allocated slabs per node, per cache. This counter is
> updated when a slab is created or destroyed. This enables us to skip
> traversing the slabs_full list while gathering slabinfo statistics, and
> since slabs_full tends to be the biggest list when the cache is large, it
> results in a dramatic performance improvement. Getting slabinfo statistics
> now only requires walking the slabs_free and slabs_partial lists, and
> those lists are usually much smaller than slabs_full. We tested this after
> growing the dentry cache to 70GB, and the performance improved from 2s to
> 5ms.

I am not opposing the patch (to be honest it is quite neat) but this
is buggering me for quite some time. Sorry for hijacking this email
thread but I couldn't resist. Why are we trying to optimize SLAB and
slowly converge it to SLUB feature-wise. I always thought that SLAB
should remain stable and time challenged solution which works reasonably
well for many/most workloads, while SLUB is an optimized implementation
which experiment with slightly different concepts that might boost the
performance considerably but might also surprise from time to time. If
this is not the case then why do we have both of them in the kernel. It
is a lot of code and some features need tweaking both while only one
gets testing coverage. So this is mainly a question for maintainers. Why
do we maintain both and what is the purpose of them.

> Signed-off-by: Aruna Ramakrishna <aruna.ramakrishna@oracle.com>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
> Note: this has been tested only on x86_64.
> 
>  mm/slab.c | 26 +++++++++++++++++---------
>  mm/slab.h |  1 +
>  2 files changed, 18 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/slab.c b/mm/slab.c
> index b672710..3da34fe 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -233,6 +233,7 @@ static void kmem_cache_node_init(struct kmem_cache_node *parent)
>  	spin_lock_init(&parent->list_lock);
>  	parent->free_objects = 0;
>  	parent->free_touched = 0;
> +	parent->num_slabs = 0;
>  }
>  
>  #define MAKE_LIST(cachep, listp, slab, nodeid)				\
> @@ -2326,6 +2327,7 @@ static int drain_freelist(struct kmem_cache *cache,
>  
>  		page = list_entry(p, struct page, lru);
>  		list_del(&page->lru);
> +		n->num_slabs--;
>  		/*
>  		 * Safe to drop the lock. The slab is no longer linked
>  		 * to the cache.
> @@ -2764,6 +2766,8 @@ static void cache_grow_end(struct kmem_cache *cachep, struct page *page)
>  		list_add_tail(&page->lru, &(n->slabs_free));
>  	else
>  		fixup_slab_list(cachep, n, page, &list);
> +
> +	n->num_slabs++;
>  	STATS_INC_GROWN(cachep);
>  	n->free_objects += cachep->num - page->active;
>  	spin_unlock(&n->list_lock);
> @@ -3455,6 +3459,7 @@ static void free_block(struct kmem_cache *cachep, void **objpp,
>  
>  		page = list_last_entry(&n->slabs_free, struct page, lru);
>  		list_move(&page->lru, list);
> +		n->num_slabs--;
>  	}
>  }
>  
> @@ -4111,6 +4116,8 @@ void get_slabinfo(struct kmem_cache *cachep, struct slabinfo *sinfo)
>  	unsigned long num_objs;
>  	unsigned long active_slabs = 0;
>  	unsigned long num_slabs, free_objects = 0, shared_avail = 0;
> +	unsigned long num_slabs_partial = 0, num_slabs_free = 0;
> +	unsigned long num_slabs_full = 0;
>  	const char *name;
>  	char *error = NULL;
>  	int node;
> @@ -4123,33 +4130,34 @@ void get_slabinfo(struct kmem_cache *cachep, struct slabinfo *sinfo)
>  		check_irq_on();
>  		spin_lock_irq(&n->list_lock);
>  
> -		list_for_each_entry(page, &n->slabs_full, lru) {
> -			if (page->active != cachep->num && !error)
> -				error = "slabs_full accounting error";
> -			active_objs += cachep->num;
> -			active_slabs++;
> -		}
> +		num_slabs += n->num_slabs;
> +
>  		list_for_each_entry(page, &n->slabs_partial, lru) {
>  			if (page->active == cachep->num && !error)
>  				error = "slabs_partial accounting error";
>  			if (!page->active && !error)
>  				error = "slabs_partial accounting error";
>  			active_objs += page->active;
> -			active_slabs++;
> +			num_slabs_partial++;
>  		}
> +
>  		list_for_each_entry(page, &n->slabs_free, lru) {
>  			if (page->active && !error)
>  				error = "slabs_free accounting error";
> -			num_slabs++;
> +			num_slabs_free++;
>  		}
> +
>  		free_objects += n->free_objects;
>  		if (n->shared)
>  			shared_avail += n->shared->avail;
>  
>  		spin_unlock_irq(&n->list_lock);
>  	}
> -	num_slabs += active_slabs;
>  	num_objs = num_slabs * cachep->num;
> +	active_slabs = num_slabs - num_slabs_free;
> +	num_slabs_full = num_slabs - (num_slabs_partial + num_slabs_free);
> +	active_objs += (num_slabs_full * cachep->num);
> +
>  	if (num_objs - active_objs != free_objects && !error)
>  		error = "free_objects accounting error";
>  
> diff --git a/mm/slab.h b/mm/slab.h
> index 9653f2e..bc05fdc 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -432,6 +432,7 @@ struct kmem_cache_node {
>  	struct list_head slabs_partial;	/* partial list first, better asm code */
>  	struct list_head slabs_full;
>  	struct list_head slabs_free;
> +	unsigned long num_slabs;
>  	unsigned long free_objects;
>  	unsigned int free_limit;
>  	unsigned int colour_next;	/* Per-node cache coloring */
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
