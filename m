Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id AA0E56B0253
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 07:51:28 -0400 (EDT)
Received: by pactm7 with SMTP id tm7so149602724pac.2
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 04:51:28 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id dm13si8949183pac.41.2015.07.09.04.51.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jul 2015 04:51:27 -0700 (PDT)
Date: Thu, 9 Jul 2015 14:51:14 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 1/8] memcg: export struct mem_cgroup
Message-ID: <20150709115114.GA9394@esperanza>
References: <1436358472-29137-1-git-send-email-mhocko@kernel.org>
 <1436358472-29137-2-git-send-email-mhocko@kernel.org>
 <20150708153925.GA2436@esperanza>
 <20150709112239.GE13872@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150709112239.GE13872@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Greg Thelen <gthelen@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 09, 2015 at 01:22:39PM +0200, Michal Hocko wrote:
> On Wed 08-07-15 18:39:26, Vladimir Davydov wrote:
> > On Wed, Jul 08, 2015 at 02:27:45PM +0200, Michal Hocko wrote:
[...]
> > > +struct cg_proto {
> > > +	struct page_counter	memory_allocated;	/* Current allocated memory. */
> > > +	struct percpu_counter	sockets_allocated;	/* Current number of sockets. */
> > > +	int			memory_pressure;
> > > +	long			sysctl_mem[3];
> > > +	unsigned long		flags;
> > > +	/*
> > > +	 * memcg field is used to find which memcg we belong directly
> > > +	 * Each memcg struct can hold more than one cg_proto, so container_of
> > > +	 * won't really cut.
> > > +	 *
> > > +	 * The elegant solution would be having an inverse function to
> > > +	 * proto_cgroup in struct proto, but that means polluting the structure
> > > +	 * for everybody, instead of just for memcg users.
> > > +	 */
> > > +	struct mem_cgroup	*memcg;
> > > +};
> > 
> > I'd prefer to leave it where it is now. I don't see any reason why we
> > have to embed it into mem_cgroup, so may be we'd better keep a pointer
> > to it in struct mem_cgroup instead?
> 
> This patch is supposed to be minimal without any functional changes.
> Changing tcp_mem to pointer would require allocation and freeing and that
> is out of scope of this patch. Besides that I do not see any stong
> advantage doing that.

OK, got it.

> > >  extern struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *memcg);
> > 
> > It's a trivial one line function, so why not inline it too?
> 
> Yes it is trivial but according to my notes it increased the code size
> by ~100B.

Ugh, it's surprising. I think this is because it's called from so many
places.

> > > -void __mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
> > >  static inline void mem_cgroup_count_vm_event(struct mm_struct *mm,
> > >  					     enum vm_event_item idx)
> > >  {
> > > +	struct mem_cgroup *memcg;
> > > +
> > >  	if (mem_cgroup_disabled())
> > >  		return;
> > > -	__mem_cgroup_count_vm_event(mm, idx);
> > > +
> > > +	rcu_read_lock();
> > > +	memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
> > > +	if (unlikely(!memcg))
> > > +		goto out;
> > > +
> > > +	switch (idx) {
> > > +	case PGFAULT:
> > > +		this_cpu_inc(memcg->stat->events[MEM_CGROUP_EVENTS_PGFAULT]);
> > > +		break;
> > > +	case PGMAJFAULT:
> > > +		this_cpu_inc(memcg->stat->events[MEM_CGROUP_EVENTS_PGMAJFAULT]);
> > > +		break;
> > > +	default:
> > > +		BUG();
> > 
> > This switch-case looks bulky and weird. Let's make this function accept
> > MEM_CGROUP_EVENTS_PGFAULT/PGMAJFAULT directly instead.
> 
> Yes it looks ugly but I didn't intend to change it in this particular
> patch. I wouldn't mind a follow up cleanup patch.

OK, I'll probably do that.

[...]
> The current diff against the patch is:
> ---
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index f5a8d0bbef8d..42f118ae04cf 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -28,6 +28,7 @@
>  #include <linux/mmzone.h>
>  #include <linux/writeback.h>
>  
> +struct mem_cgroup;
>  struct page;
>  struct mm_struct;
>  struct kmem_cache;
> @@ -83,6 +84,35 @@ enum mem_cgroup_events_target {
>  	MEM_CGROUP_NTARGETS,
>  };
>  
> +/*
> + * Bits in struct cg_proto.flags
> + */
> +enum cg_proto_flags {
> +	/* Currently active and new sockets should be assigned to cgroups */
> +	MEMCG_SOCK_ACTIVE,
> +	/* It was ever activated; we must disarm static keys on destruction */
> +	MEMCG_SOCK_ACTIVATED,
> +};
> +
> +struct cg_proto {
> +	struct page_counter	memory_allocated;	/* Current allocated memory. */
> +	struct percpu_counter	sockets_allocated;	/* Current number of sockets. */
> +	int			memory_pressure;
> +	long			sysctl_mem[3];
> +	unsigned long		flags;
> +	/*
> +	 * memcg field is used to find which memcg we belong directly
> +	 * Each memcg struct can hold more than one cg_proto, so container_of
> +	 * won't really cut.
> +	 *
> +	 * The elegant solution would be having an inverse function to
> +	 * proto_cgroup in struct proto, but that means polluting the structure
> +	 * for everybody, instead of just for memcg users.
> +	 */
> +	struct mem_cgroup	*memcg;
> +};
> +
> +#ifdef CONFIG_MEMCG
>  struct mem_cgroup_stat_cpu {
>  	long count[MEM_CGROUP_STAT_NSTATS];
>  	unsigned long events[MEMCG_NR_EVENTS];
> @@ -90,7 +120,7 @@ struct mem_cgroup_stat_cpu {
>  	unsigned long targets[MEM_CGROUP_NTARGETS];
>  };
>  
> -struct reclaim_iter {
> +struct mem_cgroup_reclaim_iter {
>  	struct mem_cgroup *position;
>  	/* scan generation, increased every round-trip */
>  	unsigned int generation;
> @@ -103,7 +133,7 @@ struct mem_cgroup_per_zone {
>  	struct lruvec		lruvec;
>  	unsigned long		lru_size[NR_LRU_LISTS];
>  
> -	struct reclaim_iter	iter[DEF_PRIORITY + 1];
> +	struct mem_cgroup_reclaim_iter	iter[DEF_PRIORITY + 1];
>  
>  	struct rb_node		tree_node;	/* RB tree node */
>  	unsigned long		usage_in_excess;/* Set to the value by which */
> @@ -144,35 +174,6 @@ struct mem_cgroup_thresholds {
>  };
>  
>  /*
> - * Bits in struct cg_proto.flags
> - */
> -enum cg_proto_flags {
> -	/* Currently active and new sockets should be assigned to cgroups */
> -	MEMCG_SOCK_ACTIVE,
> -	/* It was ever activated; we must disarm static keys on destruction */
> -	MEMCG_SOCK_ACTIVATED,
> -};
> -
> -struct cg_proto {
> -	struct page_counter	memory_allocated;	/* Current allocated memory. */
> -	struct percpu_counter	sockets_allocated;	/* Current number of sockets. */
> -	int			memory_pressure;
> -	long			sysctl_mem[3];
> -	unsigned long		flags;
> -	/*
> -	 * memcg field is used to find which memcg we belong directly
> -	 * Each memcg struct can hold more than one cg_proto, so container_of
> -	 * won't really cut.
> -	 *
> -	 * The elegant solution would be having an inverse function to
> -	 * proto_cgroup in struct proto, but that means polluting the structure
> -	 * for everybody, instead of just for memcg users.
> -	 */
> -	struct mem_cgroup	*memcg;
> -};
> -
> -#ifdef CONFIG_MEMCG
> -/*
>   * The memory controller data structure. The memory controller controls both
>   * page cache and RSS per cgroup. We would eventually like to provide
>   * statistics based on the statistics developed by Rik Van Riel for clock-pro,
> @@ -735,7 +736,10 @@ static inline bool memcg_kmem_enabled(void)
>  	return static_key_false(&memcg_kmem_enabled_key);
>  }
>  
> -bool memcg_kmem_is_active(struct mem_cgroup *memcg);
> +static inline bool memcg_kmem_is_active(struct mem_cgroup *memcg)
> +{
> +	return memcg->kmem_acct_active;
> +}
>  
>  /*
>   * In general, we'll do everything in our power to not incur in any overhead
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 759ec413e72c..a3543dedc153 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -184,13 +184,6 @@ struct mem_cgroup_event {
>  static void mem_cgroup_threshold(struct mem_cgroup *memcg);
>  static void mem_cgroup_oom_notify(struct mem_cgroup *memcg);
>  
> -#ifdef CONFIG_MEMCG_KMEM
> -bool memcg_kmem_is_active(struct mem_cgroup *memcg)
> -{
> -	return memcg->kmem_acct_active;
> -}
> -#endif
> -
>  /* Stuffs for move charges at task migration. */
>  /*
>   * Types of charges to be moved.
> @@ -841,7 +834,7 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
>  				   struct mem_cgroup *prev,
>  				   struct mem_cgroup_reclaim_cookie *reclaim)
>  {
> -	struct reclaim_iter *uninitialized_var(iter);
> +	struct mem_cgroup_reclaim_iter *uninitialized_var(iter);
>  	struct cgroup_subsys_state *css = NULL;
>  	struct mem_cgroup *memcg = NULL;
>  	struct mem_cgroup *pos = NULL;

Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
