Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id AA28B6B0081
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 05:36:51 -0500 (EST)
Message-ID: <50AE0031.1020404@parallels.com>
Date: Thu, 22 Nov 2012 14:36:33 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] memcg: debugging facility to access dangling memcgs.
References: <1353580190-14721-1-git-send-email-glommer@parallels.com> <1353580190-14721-3-git-send-email-glommer@parallels.com>
In-Reply-To: <1353580190-14721-3-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, apw@canonical.com, Joe Perches <joe@perches.com>

On 11/22/2012 02:29 PM, Glauber Costa wrote:
> If memcg is tracking anything other than plain user memory (swap, tcp
> buf mem, or slab memory), it is possible that a reference will be held
> by the group after it is dead.
> 
> This patch provides a debugging facility in the root memcg, so we can
> inspect which memcgs still have pending objects, and what is the cause
> of this state.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  Documentation/cgroups/memory.txt |  13 ++++
>  mm/memcontrol.c                  | 156 +++++++++++++++++++++++++++++++++++++--
>  2 files changed, 162 insertions(+), 7 deletions(-)
> 
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index 8b8c28b..704247eb 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -70,6 +70,7 @@ Brief summary of control files.
>   memory.move_charge_at_immigrate # set/show controls of moving charges
>   memory.oom_control		 # set/show oom controls.
>   memory.numa_stat		 # show the number of memory usage per numa node
> + memory.dangling_memcgs          # show debugging information about dangling groups
>  
>   memory.kmem.limit_in_bytes      # set/show hard limit for kernel memory
>   memory.kmem.usage_in_bytes      # show current kernel memory allocation
> @@ -577,6 +578,18 @@ unevictable=<total anon pages> N0=<node 0 pages> N1=<node 1 pages> ...
>  
>  And we have total = file + anon + unevictable.
>  
> +5.7 dangling_memcgs
> +
> +This file will only be ever present in the root cgroup. When a memcg is
> +destroyed, the memory consumed by it may not be immediately freed. This is
> +because when some extensions are used, such as swap or kernel memory, objects
> +can outlive the group and hold a reference to it.
> +
> +If this is the case, the dangling_memcgs file will show information about what
> +are the memcgs still alive, and which references are still preventing it to be
> +freed. This is a debugging facility only, and no guarantees of interface
> +stability will be given.
> +
>  6. Hierarchy support
>  
>  The memory controller supports a deep hierarchy and hierarchical accounting.
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 05b87aa..46f7cfb 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -311,14 +311,31 @@ struct mem_cgroup {
>  	/* thresholds for mem+swap usage. RCU-protected */
>  	struct mem_cgroup_thresholds memsw_thresholds;
>  
> -	/* For oom notifier event fd */
> -	struct list_head oom_notify;
> +	union {
> +		/* For oom notifier event fd */
> +		struct list_head oom_notify;
> +		/*
> +		 * we can only trigger an oom event if the memcg is alive.
> +		 * so we will reuse this field to hook the memcg in the list
> +		 * of dead memcgs.
> +		 */
> +		struct list_head dead;
> +	};
>  
> -	/*
> -	 * Should we move charges of a task when a task is moved into this
> -	 * mem_cgroup ? And what type of charges should we move ?
> -	 */
> -	unsigned long 	move_charge_at_immigrate;
> +	union {
> +		/*
> +		 * Should we move charges of a task when a task is moved into
> +		 * this mem_cgroup ? And what type of charges should we move ?
> +		 */
> +		unsigned long	move_charge_at_immigrate;
> +
> +		/*
> +		 * We are no longer concerned about moving charges after memcg
> +		 * is dead. So we will fill this up with its name, to aid
> +		 * debugging.
> +		 */
> +		char *memcg_name;
> +	};
>  	/*
>  	 * set > 0 if pages under this cgroup are moving to other cgroup.
>  	 */
> @@ -349,6 +366,33 @@ struct mem_cgroup {
>  #endif
>  };
>  
> +#if defined(CONFIG_MEMCG_KMEM) || defined(CONFIG_MEMCG_SWAP)
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
> +
> +		mem_cgroup_dangling_swap(memcg, m);
> +		mem_cgroup_dangling_kmem(memcg, m);
> +	}
> +
> +	mutex_unlock(&dangling_memcgs_mutex);
> +	return 0;
> +}
> +#endif
> +
>  static int memcg_update_kmem_limit(struct cgroup *cont, u64 val)
>  {
>  	int ret = -EINVAL;
> @@ -5831,6 +5961,14 @@ static struct cftype mem_cgroup_files[] = {
>  	},
>  #endif
>  #endif
> +
> +#if defined(CONFIG_MEMCG_KMEM) || defined(CONFIG_MEMCG_SWAP)
> +	{
> +		.name = "dangling_memcgs",
> +		.read_seq_string = mem_cgroup_dangling_read,
> +		.flags = CFTYPE_ONLY_ON_ROOT,
> +	},
> +#endif
>  	{ },	/* terminate */
>  };
>  
> @@ -5933,6 +6071,7 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
>  	 * the cgroup_lock.
>  	 */
>  	disarm_static_keys(memcg);
> +
>  	if (size < PAGE_SIZE)
>  		kfree(memcg);
>  	else

damn me!

It's not the first time I've seen those extra newlines slipping through
the final private review and ending up in the final patch...

I wonder if there would be any value in having checkpatch checking for
those?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
