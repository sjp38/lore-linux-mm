Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3B97E6B0024
	for <linux-mm@kvack.org>; Sat, 24 Mar 2018 09:11:36 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id h191-v6so4626794lfg.18
        for <linux-mm@kvack.org>; Sat, 24 Mar 2018 06:11:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s193-v6sor2688183lfs.43.2018.03.24.06.11.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 24 Mar 2018 06:11:34 -0700 (PDT)
Date: Sat, 24 Mar 2018 16:11:31 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH] mm, slab: eagerly delete inactive offlined SLABs
Message-ID: <20180324131131.blg3eqsfjc6issp2@esperanza>
References: <20180321224301.142879-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180321224301.142879-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello Shakeel,

The patch makes sense to me, but I have a concern about synchronization
of cache destruction vs concurrent kmem_cache_free. Please, see my
comments inline.

On Wed, Mar 21, 2018 at 03:43:01PM -0700, Shakeel Butt wrote:
> With kmem cgroup support, high memcgs churn can leave behind a lot of
> empty kmem_caches. Usually such kmem_caches will be destroyed when the
> corresponding memcg gets released but the memcg release can be
> arbitrarily delayed. These empty kmem_caches wastes cache_reaper's time.
> So, the reaper should destroy such empty offlined kmem_caches.

> diff --git a/mm/slab.c b/mm/slab.c
> index 66f2db98f026..9c174a799ffb 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -4004,6 +4004,16 @@ static void drain_array(struct kmem_cache *cachep, struct kmem_cache_node *n,
>  	slabs_destroy(cachep, &list);
>  }
>  
> +static bool is_slab_active(struct kmem_cache *cachep)
> +{
> +	int node;
> +	struct kmem_cache_node *n;
> +
> +	for_each_kmem_cache_node(cachep, node, n)
> +		if (READ_ONCE(n->total_slabs) - n->free_slabs)

Why READ_ONCE total_slabs, but not free_slabs?

Anyway, AFAIU there's no guarantee that this CPU sees the two fields
updated in the same order as they were actually updated on another CPU.
For example, suppose total_slabs is 2 and free_slabs is 1, and another
CPU is freeing a slab page concurrently from kmem_cache_free, i.e.
subtracting 1 from both total_slabs and free_slabs. Then this CPU might
see a transient state, when total_slabs is already updated (set to 1),
but free_slabs is not (still equals 1), and decide that it's safe to
destroy this slab cache while in fact it isn't.

Such a race will probably not result in any serious problems, because
shutdown_cache() checks that the cache is empty and does nothing if it
isn't, but still it looks suspicious and at least deserves a comment.
To eliminate the race, we should check total_slabs vs free_slabs with
kmem_cache_node->list_lock held. Alternatively, I think we could just
check if total_slabs is 0 - sooner or later cache_reap() will release
all empty slabs anyway.

> +			return true;
> +	return false;
> +}

> @@ -4061,6 +4071,10 @@ static void cache_reap(struct work_struct *w)
>  				5 * searchp->num - 1) / (5 * searchp->num));
>  			STATS_ADD_REAPED(searchp, freed);
>  		}
> +
> +		/* Eagerly delete inactive kmem_cache of an offlined memcg. */
> +		if (!is_memcg_online(searchp) && !is_slab_active(searchp))

I don't think we need to define is_memcg_online in generic code.
I would merge is_memcg_online and is_slab_active, and call the
resulting function cache_is_active.

> +			shutdown_cache(searchp);
>  next:
>  		cond_resched();
>  	}
