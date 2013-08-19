Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 14B3D6B0033
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 15:28:46 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id uo5so5292917pbc.23
        for <linux-mm@kvack.org>; Mon, 19 Aug 2013 12:28:46 -0700 (PDT)
Date: Mon, 19 Aug 2013 12:28:31 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH mmotm,next] mm: fix memcg-less page reclaim
In-Reply-To: <20130819095136.GB3396@dhcp22.suse.cz>
Message-ID: <alpine.LNX.2.00.1308191154230.1505@eggly.anvils>
References: <alpine.LNX.2.00.1308182254220.1040@eggly.anvils> <20130819074407.GA3396@dhcp22.suse.cz> <20130819095136.GB3396@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Mon, 19 Aug 2013, Michal Hocko wrote:
> [Let's CC Johannes, Kamezewa and Kosaki]
> 
> On Mon 19-08-13 09:44:07, Michal Hocko wrote:
> > On Sun 18-08-13 23:05:25, Hugh Dickins wrote:
> [...]
> > > Adding mem_cgroup_disabled() and once++ test there is ugly.  Ideally,
> > > even a !CONFIG_MEMCG build might in future have a stub root_mem_cgroup,
> > > which would get around this: but that's not so at present.
> > > 
> > > However, it appears that nothing actually dereferences the memcg pointer
> > > in the mem_cgroup_disabled() case, here or anywhere else that case can
> > > reach mem_cgroup_iter() (mem_cgroup_iter_break() is not called in
> > > global reclaim).
> > > 
> > > So, simply pass back an ordinarily-oopsing non-NULL address the first
> > > time, and we shall hear about it if I'm wrong.
> > 
> > This is a bit tricky but it seems like the easiest way for now. I will
> > look at the fake root cgroup for !CONFIG_MEMCG.
> 
> OK, the following builds for both CONFIG_MEMCG enabled and disabled and
> should work with cgroup_disable=memory as well as we are allocating
> root_mem_cgroup for disabled case as well AFAICS.
> 
> It looks less scary than I expected. I haven't tested it yet but if you
> think that it looks promising I will send a full patch with changelog.

Sorry, I think this is merely more complicated and wasteful than
the two-liner I sent.  And I'd be surprised if it's handling the
cgroup_disable=memory case correctly.

I do imagine that one day a root_mem_cgroup for all may provide useful
simplifications - avoiding many of the mem_cgroup_disabled() tests
scattered around, for example.  But it's not obvious what fields that
ought to have initialized; and it's not obvious how many of the
skip-doing-this-on-root-memcg decisions should be re-evaluated
in going that way.  It's not something to rush into.

I don't see any point in introducing it now, solely for the
mem_cgroup_iter_cond() loop: that's better served by my patch.

Sorry if my comment misled you into doing this: I meant that your iter
loop would work naturally if everyone had a non-NULL root_mem_cgroup,
and maybe in future that will be the case, but not now.

Hugh

> ---
> From 954085db1837874f94e0249e74b5ae1b49dcb9f8 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Mon, 19 Aug 2013 10:51:07 +0200
> Subject: [PATCH] memcg: add a fake root_mem_cgroup for !CONFIG_MEMCG
> 
> TODO proper changelog
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  include/linux/memcontrol.h |    8 ++++++--
>  mm/Makefile                |    3 +++
>  mm/fake_root_memcg.c       |   14 ++++++++++++++
>  mm/memcontrol.c            |   17 +++++++++++++----
>  mm/vmscan.c                |    8 ++++----
>  5 files changed, 40 insertions(+), 10 deletions(-)
>  create mode 100644 mm/fake_root_memcg.c
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 8a9ed4d..1d795a8 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -25,6 +25,8 @@
>  #include <linux/jump_label.h>
>  
>  struct mem_cgroup;
> +struct mem_cgroup *get_root_mem_cgroup(void);
> +
>  struct page_cgroup;
>  struct page;
>  struct mm_struct;
> @@ -370,7 +372,9 @@ mem_cgroup_iter_cond(struct mem_cgroup *root,
>  		struct mem_cgroup_reclaim_cookie *reclaim,
>  		mem_cgroup_iter_filter cond)
>  {
> -	return NULL;
> +	if (prev)
> +		return NULL;
> +	return root;
>  }
>  
>  static inline struct mem_cgroup *
> @@ -378,7 +382,7 @@ mem_cgroup_iter(struct mem_cgroup *root,
>  		struct mem_cgroup *prev,
>  		struct mem_cgroup_reclaim_cookie *reclaim)
>  {
> -	return NULL;
> +	return mem_cgroup_iter_cond(root, prev, reclaim, NULL);
>  }
>  
>  static inline void mem_cgroup_iter_break(struct mem_cgroup *root,
> diff --git a/mm/Makefile b/mm/Makefile
> index 305d10a..fadc984 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -52,6 +52,9 @@ obj-$(CONFIG_MIGRATION) += migrate.o
>  obj-$(CONFIG_QUICKLIST) += quicklist.o
>  obj-$(CONFIG_TRANSPARENT_HUGEPAGE) += huge_memory.o
>  obj-$(CONFIG_MEMCG) += memcontrol.o page_cgroup.o vmpressure.o
> +ifndef CONFIG_MEMCG
> +	obj-y 		+= fake_root_memcg.o
> +endif
>  obj-$(CONFIG_CGROUP_HUGETLB) += hugetlb_cgroup.o
>  obj-$(CONFIG_MEMORY_FAILURE) += memory-failure.o
>  obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
> diff --git a/mm/fake_root_memcg.c b/mm/fake_root_memcg.c
> new file mode 100644
> index 0000000..e98bd1e
> --- /dev/null
> +++ b/mm/fake_root_memcg.c
> @@ -0,0 +1,14 @@
> +#include <linux/memcontrol.h>
> +
> +/* Make a type placeholder for root_mem_cgroup. */
> +struct mem_cgroup {};
> +
> +/*
> + * This is a fake root_mem_cgroup which will be used as a placeholder
> + * for !CONFIG_MEMCG.
> + */
> +struct mem_cgroup root_mem_cgroup;
> +struct mem_cgroup *get_root_mem_cgroup(void)
> +{
> +	return &root_mem_cgroup;
> +}
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index b73988a..69ed11b 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -68,6 +68,11 @@ EXPORT_SYMBOL(mem_cgroup_subsys);
>  #define MEM_CGROUP_RECLAIM_RETRIES	5
>  static struct mem_cgroup *root_mem_cgroup __read_mostly;
>  
> +struct mem_cgroup *get_root_mem_cgroup(void)
> +{
> +	return root_mem_cgroup;

I expect that returns NULL when booted with cgroup_disable=memory.

> +}
> +
>  #ifdef CONFIG_MEMCG_SWAP
>  /* Turned on only when memory cgroup is enabled && really_do_swap_account = 1 */
>  int do_swap_account __read_mostly;
> @@ -1109,8 +1114,12 @@ struct mem_cgroup *mem_cgroup_iter_cond(struct mem_cgroup *root,
>  	struct mem_cgroup *memcg = NULL;
>  	struct mem_cgroup *last_visited = NULL;
>  
> -	if (mem_cgroup_disabled())
> -		return NULL;
> +	VM_BUG_ON(!root);
> +	if (mem_cgroup_disabled()) {
> +		if (prev)
> +			return NULL;
> +		return root;
> +	}
>  
>  	if (!root)
>  		root = root_mem_cgroup;
> @@ -1198,9 +1207,9 @@ void mem_cgroup_iter_break(struct mem_cgroup *root,
>  	     iter = mem_cgroup_iter(root, iter, NULL))
>  
>  #define for_each_mem_cgroup(iter)			\
> -	for (iter = mem_cgroup_iter(NULL, NULL, NULL);	\
> +	for (iter = mem_cgroup_iter(root_mem_cgroup, NULL, NULL);	\
>  	     iter != NULL;				\
> -	     iter = mem_cgroup_iter(NULL, iter, NULL))
> +	     iter = mem_cgroup_iter(root_mem_cgroup, iter, NULL))
>  
>  void __mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
>  {
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a3bf7fd..d10b44a 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2596,7 +2596,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
>  		.may_swap = 1,
>  		.order = order,
>  		.priority = DEF_PRIORITY,
> -		.target_mem_cgroup = NULL,
> +		.target_mem_cgroup = get_root_mem_cgroup(),
>  		.nodemask = nodemask,
>  	};
>  	struct shrink_control shrink = {
> @@ -2714,7 +2714,7 @@ static void age_active_anon(struct zone *zone, struct scan_control *sc)
>  	if (!total_swap_pages)
>  		return;
>  
> -	memcg = mem_cgroup_iter(NULL, NULL, NULL);
> +	memcg = mem_cgroup_iter(get_root_mem_cgroup(), NULL, NULL);
>  	do {
>  		struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, memcg);
>  
> @@ -2722,7 +2722,7 @@ static void age_active_anon(struct zone *zone, struct scan_control *sc)
>  			shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
>  					   sc, LRU_ACTIVE_ANON);
>  
> -		memcg = mem_cgroup_iter(NULL, memcg, NULL);
> +		memcg = mem_cgroup_iter(get_root_mem_cgroup(), memcg, NULL);
>  	} while (memcg);
>  }
>  
> @@ -2949,7 +2949,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
>  		.may_swap = 1,
>  		.may_writepage = !laptop_mode,
>  		.order = order,
> -		.target_mem_cgroup = NULL,
> +		.target_mem_cgroup = get_root_mem_cgroup(),
>  	};
>  	count_vm_event(PAGEOUTRUN);
>  
> -- 
> 1.7.10.4
> 
> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
