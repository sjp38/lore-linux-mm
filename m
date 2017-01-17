Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7DEE26B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 19:20:13 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 80so270680918pfy.2
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 16:20:13 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id w10si23020243pgc.131.2017.01.16.16.20.11
        for <linux-mm@kvack.org>;
        Mon, 16 Jan 2017 16:20:12 -0800 (PST)
Date: Tue, 17 Jan 2017 09:26:11 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 7/8] slab: remove synchronous synchronize_sched() from
 memcg cache deactivation path
Message-ID: <20170117002611.GC25218@js1304-P5Q-DELUXE>
References: <20170114184834.8658-1-tj@kernel.org>
 <20170114184834.8658-8-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170114184834.8658-8-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: vdavydov.dev@gmail.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, jsvana@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, kernel-team@fb.com

On Sat, Jan 14, 2017 at 01:48:33PM -0500, Tejun Heo wrote:
> With kmem cgroup support enabled, kmem_caches can be created and
> destroyed frequently and a great number of near empty kmem_caches can
> accumulate if there are a lot of transient cgroups and the system is
> not under memory pressure.  When memory reclaim starts under such
> conditions, it can lead to consecutive deactivation and destruction of
> many kmem_caches, easily hundreds of thousands on moderately large
> systems, exposing scalability issues in the current slab management
> code.  This is one of the patches to address the issue.
> 
> slub uses synchronize_sched() to deactivate a memcg cache.
> synchronize_sched() is an expensive and slow operation and doesn't
> scale when a huge number of caches are destroyed back-to-back.  While
> there used to be a simple batching mechanism, the batching was too
> restricted to be helpful.
> 
> This patch implements slab_deactivate_memcg_cache_rcu_sched() which
> slub can use to schedule sched RCU callback instead of performing
> synchronize_sched() synchronously while holding cgroup_mutex.  While
> this adds online cpus, mems and slab_mutex operations, operating on
> these locks back-to-back from the same kworker, which is what's gonna
> happen when there are many to deactivate, isn't expensive at all and
> this gets rid of the scalability problem completely.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Reported-by: Jay Vana <jsvana@fb.com>
> Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>  include/linux/slab.h |  6 ++++++
>  mm/slab.h            |  2 ++
>  mm/slab_common.c     | 60 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>  mm/slub.c            | 12 +++++++----
>  4 files changed, 76 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index 41c49cc..5ca8778 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -582,6 +582,12 @@ struct memcg_cache_params {
>  			struct mem_cgroup *memcg;
>  			struct list_head children_node;
>  			struct list_head kmem_caches_node;
> +
> +			void (*deact_fn)(struct kmem_cache *);
> +			union {
> +				struct rcu_head deact_rcu_head;
> +				struct work_struct deact_work;
> +			};
>  		};
>  	};
>  };
> diff --git a/mm/slab.h b/mm/slab.h
> index 0946d97..2fe07d7 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -304,6 +304,8 @@ static __always_inline void memcg_uncharge_slab(struct page *page, int order,
>  
>  extern void slab_init_memcg_params(struct kmem_cache *);
>  extern void memcg_link_cache(struct kmem_cache *s);
> +extern void slab_deactivate_memcg_cache_rcu_sched(struct kmem_cache *s,
> +				void (*deact_fn)(struct kmem_cache *));
>  
>  #else /* CONFIG_MEMCG && !CONFIG_SLOB */
>  
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index cd81cad..4a0605c 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -592,6 +592,66 @@ void memcg_create_kmem_cache(struct mem_cgroup *memcg,
>  	put_online_cpus();
>  }
>  
> +static void kmemcg_deactivate_workfn(struct work_struct *work)
> +{
> +	struct kmem_cache *s = container_of(work, struct kmem_cache,
> +					    memcg_params.deact_work);
> +
> +	get_online_cpus();
> +	get_online_mems();
> +
> +	mutex_lock(&slab_mutex);
> +
> +	s->memcg_params.deact_fn(s);
> +
> +	mutex_unlock(&slab_mutex);
> +
> +	put_online_mems();
> +	put_online_cpus();
> +
> +	/* done, put the ref from slab_deactivate_memcg_cache_rcu_sched() */
> +	css_put(&s->memcg_params.memcg->css);
> +}
> +
> +static void kmemcg_deactivate_rcufn(struct rcu_head *head)
> +{
> +	struct kmem_cache *s = container_of(head, struct kmem_cache,
> +					    memcg_params.deact_rcu_head);
> +
> +	/*
> +	 * We need to grab blocking locks.  Bounce to ->deact_work.  The
> +	 * work item shares the space with the RCU head and can't be
> +	 * initialized eariler.
> +	 */
> +	INIT_WORK(&s->memcg_params.deact_work, kmemcg_deactivate_workfn);
> +	schedule_work(&s->memcg_params.deact_work);
> +}

Isn't it better to submit one work item for each memcg like as
Vladimir did? Or, could you submit this work to the ordered workqueue?
I'm not an expert about workqueue like as you, but, I think
that there is a chance to create a lot of threads if there is
the slab_mutex lock contention.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
