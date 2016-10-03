Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 17DAB6B0069
	for <linux-mm@kvack.org>; Mon,  3 Oct 2016 08:06:45 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id d64so79327668wmh.1
        for <linux-mm@kvack.org>; Mon, 03 Oct 2016 05:06:45 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id g136si18456950wmd.28.2016.10.03.05.06.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Oct 2016 05:06:43 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id b201so9206157wmb.1
        for <linux-mm@kvack.org>; Mon, 03 Oct 2016 05:06:43 -0700 (PDT)
Date: Mon, 3 Oct 2016 14:06:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: memcontrol: use special workqueue for creating
 per-memcg caches
Message-ID: <20161003120641.GC26768@dhcp22.suse.cz>
References: <c509c51d47b387c3d8e879678aca0b5e881b4613.1475329751.git.vdavydov.dev@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c509c51d47b387c3d8e879678aca0b5e881b4613.1475329751.git.vdavydov.dev@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>

On Sat 01-10-16 16:56:47, Vladimir Davydov wrote:
> Creating a lot of cgroups at the same time might stall all worker
> threads with kmem cache creation works, because kmem cache creation is
> done with the slab_mutex held. To prevent that from happening, let's use
> a special workqueue for kmem cache creation with max in-flight work
> items equal to 1.
> 
> Link: https://bugzilla.kernel.org/show_bug.cgi?id=172981

This looks like a regression but I am not really sure I understand what
has caused it. We had the WQ based cache creation since kmem was
introduced more or less. So is it 801faf0db894 ("mm/slab: lockless
decision to grow cache") which was pointed by bisection that changed the
timing resp. relaxed the cache creation to the point that would allow
this runaway? This would be really useful for the stable backport
consideration.

Also, if I understand the fix correctly, now we do limit the number of
workers to 1 thread. Is this really what we want? Wouldn't it be
possible that few memcgs could starve others fromm having their cache
created? What would be the result, missed charges?

> Signed-off-by: Vladimir Davydov <vdavydov.dev@gmail.com>
> Reported-by: Doug Smythies <dsmythies@telus.net>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Pekka Enberg <penberg@kernel.org>
> ---
>  mm/memcontrol.c | 15 ++++++++++++++-
>  1 file changed, 14 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 4be518d4e68a..c1efe59e3a20 100644
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
> +		alloc_workqueue("memcg_kmem_cache_create", 0, 1);
> +	BUG_ON(!memcg_kmem_cache_create_wq);
> +#endif
> +
>  	hotcpu_notifier(memcg_cpu_hotplug_callback, 0);
>  
>  	for_each_possible_cpu(cpu)
> -- 
> 2.1.4

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
