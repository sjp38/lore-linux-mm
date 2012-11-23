Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id C38836B005D
	for <linux-mm@kvack.org>; Fri, 23 Nov 2012 04:20:15 -0500 (EST)
Received: by mail-vb0-f41.google.com with SMTP id v13so11357723vbk.14
        for <linux-mm@kvack.org>; Fri, 23 Nov 2012 01:20:14 -0800 (PST)
Date: Fri, 23 Nov 2012 10:20:10 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] memcg: debugging facility to access dangling memcgs.
Message-ID: <20121123092010.GD24698@dhcp22.suse.cz>
References: <1353580190-14721-1-git-send-email-glommer@parallels.com>
 <1353580190-14721-3-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1353580190-14721-3-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>

On Thu 22-11-12 14:29:50, Glauber Costa wrote:
[...]
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 05b87aa..46f7cfb 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
[...]
> @@ -349,6 +366,33 @@ struct mem_cgroup {
>  #endif
>  };
>  
> +#if defined(CONFIG_MEMCG_KMEM) || defined(CONFIG_MEMCG_SWAP)

Can we have a common config for this something like CONFIG_MEMCG_ASYNC_DESTROY
which would be selected if either of the two (or potentially others)
would be selected.
Also you are saying that the feature is only for debugging purposes so
it shouldn't be on by default probably.

> +static LIST_HEAD(dangling_memcgs);
> +static DEFINE_MUTEX(dangling_memcgs_mutex);
> +
> +static inline void memcg_dangling_free(struct mem_cgroup *memcg)
> +{
> +	mutex_lock(&dangling_memcgs_mutex);
> +	list_del(&memcg->dead);
> +	mutex_unlock(&dangling_memcgs_mutex);
> +	kfree(memcg->memcg_name);
> +}
> +
> +static inline void memcg_dangling_add(struct mem_cgroup *memcg)
> +{
> +
> +	memcg->memcg_name = kstrdup(cgroup_name(memcg->css.cgroup), GFP_KERNEL);

Who gets charged for this allocation? What if the allocation fails (not
that it would be probable but still...)?

> +
> +	INIT_LIST_HEAD(&memcg->dead);
> +	mutex_lock(&dangling_memcgs_mutex);
> +	list_add(&memcg->dead, &dangling_memcgs);
> +	mutex_unlock(&dangling_memcgs_mutex);
> +}
> +#else
> +static inline void memcg_dangling_free(struct mem_cgroup *memcg) {}
> +static inline void memcg_dangling_add(struct mem_cgroup *memcg) {}
> +#endif
> +
>  /* internal only representation about the status of kmem accounting. */
>  enum {
>  	KMEM_ACCOUNTED_ACTIVE = 0, /* accounted by this cgroup itself */
> @@ -4868,6 +4912,92 @@ static ssize_t mem_cgroup_read(struct cgroup *cont, struct cftype *cft,
>  	return simple_read_from_buffer(buf, nbytes, ppos, str, len);
>  }
>  
> +#if defined(CONFIG_MEMCG_KMEM) || defined(CONFIG_MEMCG_SWAP)
> +static void
> +mem_cgroup_dangling_swap(struct mem_cgroup *memcg, struct seq_file *m)
> +{
> +#ifdef CONFIG_MEMCG_SWAP
> +	u64 kmem;
> +	u64 memsw;
> +
> +	/*
> +	 * kmem will also propagate here, so we are only interested in the
> +	 * difference.  See comment in mem_cgroup_reparent_charges for details.
> +	 *
> +	 * We could save this value for later consumption by kmem reports, but
> +	 * there is not a lot of problem if the figures differ slightly.
> +	 */
> +	kmem = res_counter_read_u64(&memcg->kmem, RES_USAGE);
> +	memsw = res_counter_read_u64(&memcg->memsw, RES_USAGE) - kmem;
> +	seq_printf(m, "\t%llu swap bytes\n", memsw);
> +#endif
> +}
> +
> +static void
> +mem_cgroup_dangling_kmem(struct mem_cgroup *memcg, struct seq_file *m)
> +{
> +#ifdef CONFIG_MEMCG_KMEM
> +	u64 kmem;
> +	struct memcg_cache_params *params;
> +
> +#ifdef CONFIG_INET
> +	struct tcp_memcontrol *tcp = &memcg->tcp_mem;
> +	s64 tcp_socks;
> +	u64 tcp_bytes;
> +
> +	tcp_socks = percpu_counter_sum_positive(&tcp->tcp_sockets_allocated);
> +	tcp_bytes = res_counter_read_u64(&tcp->tcp_memory_allocated, RES_USAGE);
> +	seq_printf(m, "\t%llu tcp bytes, in %lld sockets\n",
> +		   tcp_bytes, tcp_socks);
> +
> +#endif

Looks like this deserves its own function rather than this ifdef games
inside functions.

> +
> +	kmem = res_counter_read_u64(&memcg->kmem, RES_USAGE);
> +	seq_printf(m, "\t%llu kmem bytes", kmem);
> +
> +	/* list below may not be initialized, so not even try */
> +	if (!kmem)
> +		return;
> +
> +	seq_printf(m, " in caches");
> +	mutex_lock(&memcg->slab_caches_mutex);
> +	list_for_each_entry(params, &memcg->memcg_slab_caches, list) {
> +			struct kmem_cache *s = memcg_params_to_cache(params);
> +
> +		seq_printf(m, " %s", s->name);
> +	}
> +	mutex_unlock(&memcg->slab_caches_mutex);
> +	seq_printf(m, "\n");
> +#endif
> +}
> +
> +/*
> + * After a memcg is destroyed, it may still be kept around in memory.
> + * Currently, the two main reasons for it are swap entries, and kernel memory.
> + * Because they will be freed assynchronously, they will pin the memcg structure
> + * and its resources until the last reference goes away.
> + *
> + * This root-only file will show information about which users
> + */
> +static int mem_cgroup_dangling_read(struct cgroup *cont, struct cftype *cft,
> +					struct seq_file *m)
> +{
> +	struct mem_cgroup *memcg;
> +
> +	mutex_lock(&dangling_memcgs_mutex);
> +
> +	list_for_each_entry(memcg, &dangling_memcgs, dead) {
> +		seq_printf(m, "%s:\n", memcg->memcg_name);

Hmm, we have lost the cgroup path so know there is something called A
but we do not know whether it was A/A A/B/A A/......../A (aka we have
lost the hierarchy information and a group with the same name might
exist which can be really confusing).

That being said I would prefer if this was covered by a debugging
option, off by default.
It would be better if we could preserve the whole group name (something
like cgroup_path does) but I guess this would break caches names, right?
And finally it would be really nice if you described what is the
exported information good for. Can I somehow change the current state
(e.g. force freeing those objects so that the memcg can finally pass out
in piece)?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
