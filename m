Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id C36476B0068
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 14:10:30 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id k14so945494oag.14
        for <linux-mm@kvack.org>; Wed, 24 Oct 2012 11:10:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1350656442-1523-9-git-send-email-glommer@parallels.com>
References: <1350656442-1523-1-git-send-email-glommer@parallels.com>
	<1350656442-1523-9-git-send-email-glommer@parallels.com>
Date: Thu, 25 Oct 2012 03:10:29 +0900
Message-ID: <CAAmzW4N40MedsCfcj+eiM-i6cU65n3z7uy08YFyknXbBKj7Z-g@mail.gmail.com>
Subject: Re: [PATCH v5 08/18] memcg: infrastructure to match an allocation to
 the right cache
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, devel@openvz.org, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

2012/10/19 Glauber Costa <glommer@parallels.com>:
> @@ -2930,9 +2937,188 @@ int memcg_register_cache(struct mem_cgroup *memcg, struct kmem_cache *s)
>
>  void memcg_release_cache(struct kmem_cache *s)
>  {
> +       struct kmem_cache *root;
> +       int id = memcg_css_id(s->memcg_params->memcg);
> +
> +       if (s->memcg_params->is_root_cache)
> +               goto out;
> +
> +       root = s->memcg_params->root_cache;
> +       root->memcg_params->memcg_caches[id] = NULL;
> +       mem_cgroup_put(s->memcg_params->memcg);
> +out:
>         kfree(s->memcg_params);
>  }

memcg_css_id should be called after checking "s->memcg_params->is_root_cache".
Because when is_root_cache == true, memcg_params has no memcg object.


> +/*
> + * This lock protects updaters, not readers. We want readers to be as fast as
> + * they can, and they will either see NULL or a valid cache value. Our model
> + * allow them to see NULL, in which case the root memcg will be selected.
> + *
> + * We need this lock because multiple allocations to the same cache from a non
> + * GFP_WAIT area will span more than one worker. Only one of them can create
> + * the cache.
> + */
> +static DEFINE_MUTEX(memcg_cache_mutex);
> +static struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
> +                                                 struct kmem_cache *cachep)
> +{
> +       struct kmem_cache *new_cachep;
> +       int idx;
> +
> +       BUG_ON(!memcg_can_account_kmem(memcg));
> +
> +       idx = memcg_css_id(memcg);
> +
> +       mutex_lock(&memcg_cache_mutex);
> +       new_cachep = cachep->memcg_params->memcg_caches[idx];
> +       if (new_cachep)
> +               goto out;
> +
> +       new_cachep = kmem_cache_dup(memcg, cachep);
> +
> +       if (new_cachep == NULL) {
> +               new_cachep = cachep;
> +               goto out;
> +       }
> +
> +       mem_cgroup_get(memcg);
> +       cachep->memcg_params->memcg_caches[idx] = new_cachep;
> +       wmb(); /* the readers won't lock, make sure everybody sees it */

Is there any rmb() pair?
As far as I know, without rmb(), wmb() doesn't guarantee anything.

> +       new_cachep->memcg_params->memcg = memcg;
> +       new_cachep->memcg_params->root_cache = cachep;

It may be better these assignment before the statement
"cachep->memcg_params->memcg_caches[idx] = new_cachep".
Otherwise, it may produce race situation.

And assigning value to memcg_params->memcg and root_cache is redundant,
because it is already done in memcg_register_cache().

> +/*
> + * Return the kmem_cache we're supposed to use for a slab allocation.
> + * We try to use the current memcg's version of the cache.
> + *
> + * If the cache does not exist yet, if we are the first user of it,
> + * we either create it immediately, if possible, or create it asynchronously
> + * in a workqueue.
> + * In the latter case, we will let the current allocation go through with
> + * the original cache.
> + *
> + * Can't be called in interrupt context or from kernel threads.
> + * This function needs to be called with rcu_read_lock() held.
> + */
> +struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep,
> +                                         gfp_t gfp)
> +{
> +       struct mem_cgroup *memcg;
> +       int idx;
> +
> +       if (cachep->memcg_params && cachep->memcg_params->memcg)
> +               return cachep;

In __memcg_kmem_get_cache, cachep may be always root cache.
So checking "cachep->memcg_params->memcg" is somewhat strange.
Is it right?


Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
