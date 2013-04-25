Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 385E66B0032
	for <linux-mm@kvack.org>; Thu, 25 Apr 2013 08:51:32 -0400 (EDT)
Message-ID: <51792686.50009@huawei.com>
Date: Thu, 25 Apr 2013 20:50:14 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] memcg: reap dead memcgs under pressure
References: <1366705329-9426-1-git-send-email-glommer@openvz.org> <1366705329-9426-3-git-send-email-glommer@openvz.org>
In-Reply-To: <1366705329-9426-3-git-send-email-glommer@openvz.org>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Anton Vorontsov <anton.vorontsov@linaro.org>, John Stultz <john.stultz@linaro.org>, Joonsoo Kim <js1304@gmail.com>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

> +static void memcg_vmpressure_shrink_dead(void)
> +{
> +	struct memcg_cache_params *params, *tmp;
> +	struct kmem_cache *cachep;
> +	struct mem_cgroup *memcg;
> +
> +	mutex_lock(&dangling_memcgs_mutex);
> +	list_for_each_entry(memcg, &dangling_memcgs, dead) {
> +
> +		mem_cgroup_get(memcg);

This mem_cgroup_get() looks redundant to me, because you're iterating the list
and never release dangling_memcgs_mutex in the middle.

> +		mutex_lock(&memcg->slab_caches_mutex);
> +		/* The element may go away as an indirect result of shrink */
> +		list_for_each_entry_safe(params, tmp,
> +					 &memcg->memcg_slab_caches, list) {
> +
> +			cachep = memcg_params_to_cache(params);
> +			/*
> +			 * the cpu_hotplug lock is taken in kmem_cache_create
> +			 * outside the slab_caches_mutex manipulation. It will
> +			 * be taken by kmem_cache_shrink to flush the cache.
> +			 * So we need to drop the lock. It is all right because
> +			 * the lock only protects elements moving in and out the
> +			 * list.
> +			 */
> +			mutex_unlock(&memcg->slab_caches_mutex);
> +			kmem_cache_shrink(cachep);
> +			mutex_lock(&memcg->slab_caches_mutex);
> +		}
> +		mutex_unlock(&memcg->slab_caches_mutex);
> +		mem_cgroup_put(memcg);
> +	}
> +	mutex_unlock(&dangling_memcgs_mutex);
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
