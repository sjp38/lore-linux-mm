Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id AB33F6B0069
	for <linux-mm@kvack.org>; Thu,  6 Oct 2016 08:05:51 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b80so7449660wme.1
        for <linux-mm@kvack.org>; Thu, 06 Oct 2016 05:05:51 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id cc10si16614619wjc.34.2016.10.06.05.05.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Oct 2016 05:05:50 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id b201so3204046wmb.1
        for <linux-mm@kvack.org>; Thu, 06 Oct 2016 05:05:50 -0700 (PDT)
Date: Thu, 6 Oct 2016 14:05:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: memcontrol: use special workqueue for creating
 per-memcg caches
Message-ID: <20161006120548.GH10570@dhcp22.suse.cz>
References: <c509c51d47b387c3d8e879678aca0b5e881b4613.1475329751.git.vdavydov.dev@gmail.com>
 <20161003120641.GC26768@dhcp22.suse.cz>
 <20161003123505.GA1862@esperanza>
 <20161003131930.GE26768@dhcp22.suse.cz>
 <20161004131417.GC1862@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161004131417.GC1862@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 04-10-16 16:14:17, Vladimir Davydov wrote:
[...]
> >From 10f5f126800912c6a4b78a8b615138c1322694ad Mon Sep 17 00:00:00 2001
> From: Vladimir Davydov <vdavydov.dev@gmail.com>
> Date: Sat, 1 Oct 2016 16:39:09 +0300
> Subject: [PATCH] mm: memcontrol: use special workqueue for creating per-memcg
>  caches
> 
> Creating a lot of cgroups at the same time might stall all worker
> threads with kmem cache creation works, because kmem cache creation is
> done with the slab_mutex held. The problem was amplified by commits
> 801faf0db894 ("mm/slab: lockless decision to grow cache") in case of
> SLAB and 81ae6d03952c ("mm/slub.c: replace kick_all_cpus_sync() with
> synchronize_sched() in kmem_cache_shrink()") in case of SLUB, which
> increased the maximal time the slab_mutex can be held.
> 
> To prevent that from happening, let's use a special ordered single
> threaded workqueue for kmem cache creation. This shouldn't introduce any
> functional changes regarding how kmem caches are created, as the work
> function holds the global slab_mutex during its whole runtime anyway,
> making it impossible to run more than one work at a time. By using a
> single threaded workqueue, we just avoid creating a thread per each
> work. Ordering is required to avoid a situation when a cgroup's work is
> put off indefinitely because there are other cgroups to serve, in other
> words to guarantee fairness.

I am not sure an indefinit starving was possible but a fairness seems to
be real AFAICS.

> 
> Link: https://bugzilla.kernel.org/show_bug.cgi?id=172981
> Signed-off-by: Vladimir Davydov <vdavydov.dev@gmail.com>
> Reported-by: Doug Smythies <dsmythies@telus.net>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Pekka Enberg <penberg@kernel.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 4be518d4e68a..8d753d87ca37 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2175,6 +2175,8 @@ struct memcg_kmem_cache_create_work {
>  	struct work_struct work;
>  };
>  
> +static struct workqueue_struct *memcg_kmem_cache_create_wq;
> +
>  static void memcg_kmem_cache_create_func(struct work_struct *w)
>  {
>  	struct memcg_kmem_cache_create_work *cw =
> @@ -2206,7 +2208,7 @@ static void __memcg_schedule_kmem_cache_create(struct mem_cgroup *memcg,
>  	cw->cachep = cachep;
>  	INIT_WORK(&cw->work, memcg_kmem_cache_create_func);
>  
> -	schedule_work(&cw->work);
> +	queue_work(memcg_kmem_cache_create_wq, &cw->work);
>  }
>  
>  static void memcg_schedule_kmem_cache_create(struct mem_cgroup *memcg,
> @@ -5794,6 +5796,17 @@ static int __init mem_cgroup_init(void)
>  {
>  	int cpu, node;
>  
> +#ifndef CONFIG_SLOB
> +	/*
> +	 * Kmem cache creation is mostly done with the slab_mutex held,
> +	 * so use a special workqueue to avoid stalling all worker
> +	 * threads in case lots of cgroups are created simultaneously.
> +	 */
> +	memcg_kmem_cache_create_wq =
> +		alloc_ordered_workqueue("memcg_kmem_cache_create", 0);
> +	BUG_ON(!memcg_kmem_cache_create_wq);
> +#endif
> +
>  	hotcpu_notifier(memcg_cpu_hotplug_callback, 0);
>  
>  	for_each_possible_cpu(cpu)

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
