Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 0E24B6B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 05:43:37 -0400 (EDT)
Date: Thu, 4 Apr 2013 11:43:33 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC][PATCH 3/7] memcg: use css_get/put when charging/uncharging
 kmem
Message-ID: <20130404094333.GE29911@dhcp22.suse.cz>
References: <515BF233.6070308@huawei.com>
 <515BF284.7060401@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <515BF284.7060401@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Wed 03-04-13 17:12:36, Li Zefan wrote:
> Use css_get/put instead of mem_cgroup_get/put.
> 
> We can't do a simple replacement, because here mem_cgroup_put()
> is called during mem_cgroup_css_free(), while mem_cgroup_css_free()
> won't be called until css refcnt goes down to 0.
> 
> Instead we increment css refcnt in mem_cgroup_css_offline(), and
> then check if there's still kmem charges. If not, css refcnt will
> be decremented, otherwise the refcnt will be decremented when
> kmem charges goes down to 0.

Yes the patch makes sense and I actually like it. We just have to be
sure to document the reference counting as much as possible (see
bellow). I also thing that we need a memory barrier in the offline code.

> Signed-off-by: Li Zefan <lizefan@huawei.com>
> ---
>  mm/memcontrol.c | 49 ++++++++++++++++++++++++++-----------------------
>  1 file changed, 26 insertions(+), 23 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index dafacb8..877551d 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3004,7 +3004,7 @@ static void memcg_uncharge_kmem(struct mem_cgroup *memcg, u64 size)
>  		return;
>  
	/*
	 * releases a reference taken in kmem_cgroup_css_offline in case
	 * this last uncharge is racing with the offlining code or it is
	 * outliving the memcg existence.
	 * The memory barrier imposed by test&clear is pair with the
	 * explicit one in kmem_cgroup_css_offline.
	 */
>  	if (memcg_kmem_test_and_clear_dead(memcg))
> -		mem_cgroup_put(memcg);
> +		css_put(&memcg->css);
>  }
>  
>  void memcg_cache_list_add(struct mem_cgroup *memcg, struct kmem_cache *cachep)
> @@ -5089,14 +5089,6 @@ static int memcg_update_kmem_limit(struct cgroup *cont, u64 val)
>  		 * starts accounting before all call sites are patched
>  		 */
>  		memcg_kmem_set_active(memcg);
> -
> -		/*
> -		 * kmem charges can outlive the cgroup. In the case of slab
> -		 * pages, for instance, a page contain objects from various
> -		 * processes, so it is unfeasible to migrate them away. We
> -		 * need to reference count the memcg because of that.
> -		 */
> -		mem_cgroup_get(memcg);

>  	} else
>  		ret = res_counter_set_limit(&memcg->kmem, val);
>  out:
> @@ -5129,12 +5121,11 @@ static int memcg_propagate_kmem(struct mem_cgroup *memcg)
>  		goto out;
>  
>  	/*
> -	 * destroy(), called if we fail, will issue static_key_slow_inc() and
> -	 * mem_cgroup_put() if kmem is enabled. We have to either call them
> -	 * unconditionally, or clear the KMEM_ACTIVE flag. I personally find
> -	 * this more consistent, since it always leads to the same destroy path
> +	 * destroy(), called if we fail, will issue static_key_slow_dec() if
> +	 * kmem is enabled. We have to either call them unconditionally, or
> +	 * clear the KMEM_ACTIVE flag. I personally find this more consistent,
> +	 * since it always leads to the same destroy path
>  	 */

Can we make this comment more clear while you are changing it, please? E.g.
	/*
	 * __mem_cgroup_free will issue static_key_slow_dec because this
	 * memcg is active already. If the later initialization fails
	 * then the cgroup core triggers the cleanup so we do not have
	 * to do it here.
	 */
> -	mem_cgroup_get(memcg);
>  	static_key_slow_inc(&memcg_kmem_enabled_key);
>  
>  	mutex_lock(&set_limit_mutex);
> @@ -5823,23 +5814,33 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
>  	return mem_cgroup_sockets_init(memcg, ss);
>  };
>  
> -static void kmem_cgroup_destroy(struct mem_cgroup *memcg)
> +static void kmem_cgroup_css_offline(struct mem_cgroup *memcg)
>  {
> -	mem_cgroup_sockets_destroy(memcg);
> +	/*
> +	 * kmem charges can outlive the cgroup. In the case of slab
> +	 * pages, for instance, a page contain objects from various
> +	 * processes, so it is unfeasible to migrate them away. We
> +	 * need to reference count the memcg because of that.
> +	 */

I would prefer if we could merge all three comments in this function
into a single one. What about something like the following?
	/*
	 * kmem charges can outlive the cgroup. In the case of slab
	 * pages, for instance, a page contain objects from various
	 * processes. As we prevent from taking a reference for every
	 * such allocation we have to be careful when doing uncharge
	 * (see memcg_uncharge_kmem) and here during offlining.
	 * The idea is that that only the _last_ uncharge which sees
	 * the dead memcg will drop the last reference. An additional
	 * reference is taken here before the group is marked dead
	 * which is then paired with css_put during uncharge resp. here.
	 * Although this might sound strange as this path is called when
	 * the reference has already dropped down to 0 and shouldn't be
	 * incremented anymore (css_tryget would fail) we do not have
	 * other options because of the kmem allocations lifetime.
	 */
> +	css_get(&memcg->css);

I think that you need a write memory barrier here because css_get
nor memcg_kmem_mark_dead implies it. memcg_uncharge_kmem uses
memcg_kmem_test_and_clear_dead which imply a full memory barrier but it
should see the elevated reference count. No?

> +	/*
> +	 * We need to call css_get() first, because memcg_uncharge_kmem()
> +	 * will call css_put() if it sees the memcg is dead.
> +	 */
>  	memcg_kmem_mark_dead(memcg);
>  
>  	if (res_counter_read_u64(&memcg->kmem, RES_USAGE) != 0)
>  		return;
>  
>  	/*
> -	 * Charges already down to 0, undo mem_cgroup_get() done in the charge
> -	 * path here, being careful not to race with memcg_uncharge_kmem: it is
> -	 * possible that the charges went down to 0 between mark_dead and the
> -	 * res_counter read, so in that case, we don't need the put
> +	 * Charges already down to 0, undo css_get() done previosly,, being
> +	 * careful not to race with memcg_uncharge_kmem: it is possible that
> +	 * the charges went down to 0 between mark_dead and the res_counter
> +	 * read, so in that case, we don't need the put
>  	 */

>  	if (memcg_kmem_test_and_clear_dead(memcg))
> -		mem_cgroup_put(memcg);
> +		css_put(&memcg->css);
>  }
>  #else
>  static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
> @@ -5847,7 +5848,7 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
>  	return 0;
>  }
>  
> -static void kmem_cgroup_destroy(struct mem_cgroup *memcg)
> +static void kmem_cgroup_css_offline(struct mem_cgroup *memcg)
>  {
>  }
>  #endif
> @@ -6274,6 +6275,8 @@ static void mem_cgroup_css_offline(struct cgroup *cont)
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
>  
> +	kmem_cgroup_css_offline(memcg);
> +
>  	mem_cgroup_invalidate_reclaim_iterators(memcg);
>  	mem_cgroup_reparent_charges(memcg);
>  	mem_cgroup_destroy_all_caches(memcg);
> @@ -6283,7 +6286,7 @@ static void mem_cgroup_css_free(struct cgroup *cont)
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
>  
> -	kmem_cgroup_destroy(memcg);
> +	mem_cgroup_sockets_destroy(memcg);
>  
>  	mem_cgroup_put(memcg);
>  }
> -- 
> 1.8.0.2

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
