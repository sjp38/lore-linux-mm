From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 2/2] mm: oom: show unreclaimable slab info when unreclaimable
 slabs > user memory
Date: Sun, 1 Oct 2017 01:19:30 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1710010117410.25658@nuc-kabylake>
References: <1506548776-67535-1-git-send-email-yang.s@alibaba-inc.com> <1506548776-67535-3-git-send-email-yang.s@alibaba-inc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506548776-67535-3-git-send-email-yang.s@alibaba-inc.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

On Thu, 28 Sep 2017, Yang Shi wrote:

> diff --git a/mm/slab.h b/mm/slab.h
> index 0733628..b0496d1 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -505,6 +505,14 @@ static inline struct kmem_cache_node *get_node(struct kmem_cache *s, int node)
>  void memcg_slab_stop(struct seq_file *m, void *p);
>  int memcg_slab_show(struct seq_file *m, void *p);
>
> +#ifdef CONFIG_SLABINFO
> +void dump_unreclaimable_slab(void);
> +#else
> +static inline void dump_unreclaimable_slab(void)
> +{
> +}
> +#endif
> +
>  void ___cache_free(struct kmem_cache *cache, void *x, unsigned long addr);
>
>  #ifdef CONFIG_SLAB_FREELIST_RANDOM
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 904a83b..d08213d 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -1272,6 +1272,35 @@ static int slab_show(struct seq_file *m, void *p)
>  	return 0;
>  }
>
> +void dump_unreclaimable_slab(void)
> +{
> +	struct kmem_cache *s, *s2;
> +	struct slabinfo sinfo;
> +
> +	pr_info("Unreclaimable slab info:\n");
> +	pr_info("Name                      Used          Total\n");
> +
> +	/*
> +	 * Here acquiring slab_mutex is unnecessary since we don't prefer to
> +	 * get sleep in oom path right before kernel panic, and avoid race
> +	 * condition.
> +	 * Since it is already oom, so there should be not any big allocation
> +	 * which could change the statistics significantly.
> +	 */
> +	list_for_each_entry_safe(s, s2, &slab_caches, list) {
> +		if (!is_root_cache(s) || (s->flags & SLAB_RECLAIM_ACCOUNT))
> +			continue;
> +
> +		memset(&sinfo, 0, sizeof(sinfo));
> +		get_slabinfo(s, &sinfo);
> +
> +		if (sinfo.num_objs > 0)
> +			pr_info("%-17s %10luKB %10luKB\n", cache_name(s),
> +				(sinfo.active_objs * s->size) / 1024,
> +				(sinfo.num_objs * s->size) / 1024);
> +	}
> +}
> +
>  #if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
>  void *memcg_slab_start(struct seq_file *m, loff_t *pos)
>  {
>

SLABINFO is a legacy feature abd dump_unreclaimable_slab is definitely
not. It also does not depend on /proc/slabinfo support.

Please move the code out of the #ifdef CONFIG_SLABINFO section.
