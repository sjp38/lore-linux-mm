Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id C4DE46B0120
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 20:05:35 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id E081A3EE0AE
	for <linux-mm@kvack.org>; Thu, 29 Mar 2012 09:05:33 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C947B45DE50
	for <linux-mm@kvack.org>; Thu, 29 Mar 2012 09:05:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B22FC45DE4F
	for <linux-mm@kvack.org>; Thu, 29 Mar 2012 09:05:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A7B1D1DB803E
	for <linux-mm@kvack.org>; Thu, 29 Mar 2012 09:05:33 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 58C361DB802F
	for <linux-mm@kvack.org>; Thu, 29 Mar 2012 09:05:33 +0900 (JST)
Message-ID: <4F73A6E8.8010402@jp.fujitsu.com>
Date: Thu, 29 Mar 2012 09:03:52 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC] simple system for enable/disable slabs being tracked by
 memcg.
References: <1332952945-15909-1-git-send-email-glommer@parallels.com>
In-Reply-To: <1332952945-15909-1-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

(2012/03/29 1:42), Glauber Costa wrote:

> Hi.
> 
> This is a proposal I've got for how to finally settle down the
> question of which slabs should be tracked. The patch I am providing
> is for discussion only, and should apply ontop of Suleiman's latest
> version posted to the list.
> 
> The idea is to create a new file, memory.kmem.slabs_allowed.
> I decided not to overload the slabinfo file for that, but I can,
> if you ultimately want to. I just think it is cleaner this way.
> As a small rationale, I'd like to somehow show which caches are
> available but disabled. And yet, keep the format compatible with
> /proc/slabinfo.
> 
> Reading from this file will provide this information
> Writers should write a string:
>  [+-]cache_name
> 
> The wild card * is accepted, but only that. I am leaving
> any complex processing to userspace.
> 
> The * wildcard, though, is nice. It allows us to do:
>  -* (disable all)
>  +cache1
>  +cache2
> 

I like to pass a word 'all' explicitly rather than wildcard..

Hmm, but having private format of list is good ?
In another idea, how about having 3 files as device cgroup ?

	memory.kmem.slabs.allow   (similar to device.allow)
	memory.kmem.slabs.deny    (similar to device.deny)
	memory.kmem.slabs.list	    (similar to device.list)

BTW, when a slab which is accounted is changed to be unaccounted,
res_counter.usage will decrease properly ?

small comments in below.


> and so on.
> 
> Part of this patch is actually converting the slab pointers in memcg
> to a complex memcg-specific structure that can hold a disabled pointer.
> 
> We could actually store it in a free bit in the address, but that is
> a first version. Let me know if this is how you would like me to tackle
> this.
> 
> With a system like this (either this, or something alike), my opposition
> to Suleiman's idea of tracking everything under the sun basically vanishes,
> since I can then selectively disable most of them.
> 
> I still prefer a special kmalloc call than a GFP flag, though.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: Suleiman Souhlal <suleiman@google.com>
> CC: Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Johannes Weiner <hannes@cmpxchg.org>
> CC: Michal Hocko <mhocko@suse.cz>
> ---
>  include/linux/memcontrol.h |   17 ++++++++
>  include/linux/slab.h       |   13 ++++++
>  mm/memcontrol.c            |   87 ++++++++++++++++++++++++++++++++++----
>  mm/slab.c                  |   99 ++++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 207 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index f5458b0..acd38a5 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -427,6 +427,9 @@ bool mem_cgroup_charge_slab(struct kmem_cache *cachep, gfp_t gfp, size_t size);
>  void mem_cgroup_uncharge_slab(struct kmem_cache *cachep, size_t size);
>  void mem_cgroup_flush_cache_create_queue(void);
>  void mem_cgroup_remove_child_kmem_cache(struct kmem_cache *cachep, int id);
> +int mem_cgroup_slab_allowed(struct mem_cgroup *memcg, int id);
> +void mem_cgroup_slab_allow(struct mem_cgroup *memcg, int id);
> +void mem_cgroup_slab_disallow(struct mem_cgroup *memcg, int id);
>  #else /* CONFIG_CGROUP_MEM_RES_CTLR_KMEM */
>  static inline void sock_update_memcg(struct sock *sk)
>  {
> @@ -456,6 +459,20 @@ static inline void
>  mem_cgroup_flush_cache_create_queue(void)
>  {
>  }
> +
> +int mem_cgroup_slab_allowed(struct mem_cgroup *memcg, int id)
> +{
> +	return 0;
> +}
> +
> +void mem_cgroup_slab_disallow(struct mem_cgroup *memcg, int id)
> +{
> +}
> +
> +void mem_cgroup_slab_allow(struct mem_cgroup *memcg, int id)
> +{
> +}
> +
>  #endif /* CONFIG_CGROUP_MEM_RES_CTLR_KMEM */
>  #endif /* _LINUX_MEMCONTROL_H */
>  
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index 0ff5ee2..3106843 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -380,6 +380,8 @@ void kmem_cache_drop_ref(struct kmem_cache *cachep);
>  
>  void *kmalloc_no_account(size_t size, gfp_t flags);
>  
> +int mem_cgroup_tune_slab(struct mem_cgroup *mem, const char *buffer);
> +int mem_cgroup_probe_slab(struct mem_cgroup *mem, struct seq_file *m);
>  #else /* !CONFIG_CGROUP_MEM_RES_CTLR_KMEM || !CONFIG_SLAB */
>  
>  #define MAX_KMEM_CACHE_TYPES 0
> @@ -407,6 +409,17 @@ mem_cgroup_slabinfo(struct mem_cgroup *mem, struct seq_file *m)
>  	return 0;
>  }
>  
> +static inline int mem_cgroup_tune_slab(struct mem_cgroup *mem, const char *buffer)
> +{
> +	return 0;
> +}
> +
> +static inline int mem_cgroup_probe_slab(struct mem_cgroup *mem, const char *buffer)
> +{
> +	return 0;
> +}
> +
> +
>  #endif /* CONFIG_CGROUP_MEM_RES_CTLR_KMEM && CONFIG_SLAB */
>  
>  #endif	/* _LINUX_SLAB_H */
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index ba042d9..e8c6a92 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -226,6 +226,11 @@ enum memcg_flags {
>  					 */
>  };
>  
> +struct memcg_slab {
> +	struct kmem_cache *cache;
> +	bool disabled;
> +};
> +
>  /*
>   * The memory controller data structure. The memory controller controls both
>   * page cache and RSS per cgroup. We would eventually like to provide
> @@ -305,7 +310,7 @@ struct mem_cgroup {
>  
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
>  	/* Slab accounting */
> -	struct kmem_cache *slabs[MAX_KMEM_CACHE_TYPES];
> +	struct memcg_slab slabs[MAX_KMEM_CACHE_TYPES];
>  #endif
>  };
>  
> @@ -4671,6 +4676,21 @@ static int mem_cgroup_independent_kmem_limit_write(struct cgroup *cgrp,
>  	return 0;
>  }
>  
> +int mem_cgroup_slab_allowed(struct mem_cgroup *memcg, int idx)
> +{
> +	return !memcg->slabs[idx].disabled;
> +}
> +
> +void mem_cgroup_slab_allow(struct mem_cgroup *memcg, int idx)
> +{
> +	memcg->slabs[idx].disabled = false;
> +}
> +
> +void mem_cgroup_slab_disallow(struct mem_cgroup *memcg, int idx)
> +{
> +	memcg->slabs[idx].disabled = true;
> +}
> +


>  static int
>  mem_cgroup_slabinfo_show(struct cgroup *cgroup, struct cftype *ctf,
>      struct seq_file *m)
> @@ -4685,6 +4705,35 @@ mem_cgroup_slabinfo_show(struct cgroup *cgroup, struct cftype *ctf,
>  	return mem_cgroup_slabinfo(mem, m);
>  }
>  
> +static int mem_cgroup_slabs_read(struct cgroup *cgroup, struct cftype *ctf,
> +				 struct seq_file *m)
> +{
> +	struct mem_cgroup *mem;
> +
> +	mem  = mem_cgroup_from_cont(cgroup);
> +
> +	if (mem == root_mem_cgroup)
> +		return -EINVAL;
> +
> +	if (!list_empty(&cgroup->children))
> +		return -EBUSY;
> +
> +	return mem_cgroup_probe_slab(mem, m);
> +}
> +
> +static int mem_cgroup_slabs_write(struct cgroup *cgroup, struct cftype *cft,
> +				  const char *buffer)
> +{
> +	struct mem_cgroup *mem;
> +
> +	mem  = mem_cgroup_from_cont(cgroup);
> +
> +	if (mem == root_mem_cgroup)
> +		return -EINVAL;
> +
> +	return mem_cgroup_tune_slab(mem, buffer);
> +}
> +
>  static struct cftype kmem_cgroup_files[] = {
>  	{
>  		.name = "kmem.independent_kmem_limit",
> @@ -4706,6 +4755,12 @@ static struct cftype kmem_cgroup_files[] = {
>  		.name = "kmem.slabinfo",
>  		.read_seq_string = mem_cgroup_slabinfo_show,
>  	},
> +	{
> +		.name = "kmem.slabs_allowed",
> +		.read_seq_string = mem_cgroup_slabs_read,
> +		.write_string = mem_cgroup_slabs_write,
> +	},
> +
>  };
>  
>  static int register_kmem_files(struct cgroup *cont, struct cgroup_subsys *ss)
> @@ -5765,7 +5820,7 @@ memcg_create_kmem_cache(struct mem_cgroup *memcg, struct kmem_cache *cachep)
>  	 * This should behave as a write barrier, so we should be fine
>  	 * with RCU.
>  	 */
> -	if (cmpxchg(&memcg->slabs[idx], NULL, new_cachep) != NULL) {
> +	if (cmpxchg(&memcg->slabs[idx].cache, NULL, new_cachep) != NULL) {
>  		kmem_cache_destroy(new_cachep);
>  		return cachep;
>  	}


I'm sorry if I misunderstand.... can we use cmpxchg in generic code of the kernel ?
We need to put this under #if defined(__HAVE_ARCH_CMPXCHG) ?


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
