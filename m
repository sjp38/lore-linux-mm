Message-ID: <47DDE130.4040509@cn.fujitsu.com>
Date: Mon, 17 Mar 2008 12:10:40 +0900
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 7/7] memcg: freeing page_cgroup at suitable chance
References: <20080314185954.5cd51ff6.kamezawa.hiroyu@jp.fujitsu.com> <20080314192253.edb38762.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080314192253.edb38762.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, xemul@openvz.org, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> This patch is for freeing page_cgroup if a chunk of pages are freed.
> 
> How this works 
>  * when the order of free page reaches PCGRP_SHRINK_ORDER, pcgrp is freed.
>    This will be done by RCU.
> 
> I think this works well because
>    - unnecessary freeing will not occur in busy servers.
>    - page_cgroup will be removed at necessary point (allocating Hugepage,etc..)
>    - If tons of pages are freed (ex. big file is removed), page_cgroup will
>      be removed.
> 
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsuc.com>
> 
> 
>  include/linux/page_cgroup.h |   15 +++++++++++-
>  mm/page_alloc.c             |    3 ++
>  mm/page_cgroup.c            |   54 ++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 71 insertions(+), 1 deletion(-)
> 
> Index: mm-2.6.25-rc5-mm1/include/linux/page_cgroup.h
> ===================================================================
> --- mm-2.6.25-rc5-mm1.orig/include/linux/page_cgroup.h
> +++ mm-2.6.25-rc5-mm1/include/linux/page_cgroup.h
> @@ -39,6 +39,12 @@ DECLARE_PER_CPU(struct page_cgroup_cache
>  #define PCGRP_SHIFT	(CONFIG_CGROUP_PAGE_CGROUP_ORDER)
>  #define PCGRP_SIZE	(1 << PCGRP_SHIFT)
>  
> +#if PCGRP_SHIFT + 3 >= MAX_ORDER
> +#define PCGRP_SHRINK_ORDER	(MAX_ORDER - 1)
> +#else
> +#define PCGRP_SHRINK_ORDER	(PCGRP_SHIFT + 3)
> +#endif
> +
>  /*
>   * Lookup and return page_cgroup struct.
>   * returns NULL when
> @@ -70,12 +76,19 @@ get_page_cgroup(struct page *page, gfp_t
>  	return (ret)? ret : __get_page_cgroup(page, gfpmask, allocate);
>  }
>  
> +void try_to_shrink_page_cgroup(struct page *page, int order);
> +

extern void

>  #else
>  
> -static struct page_cgroup *
> +static inline struct page_cgroup *
>  get_page_cgroup(struct page *page, gfp_t gfpmask, bool allocate)
>  {
>  	return NULL;
>  }
> +static inline void try_to_shrink_page_cgroup(struct page *page, int order)
> +{
> +	return;
> +}
> +#define PCGRP_SHRINK_ORDER	(MAX_ORDER)
>  #endif
>  #endif
> Index: mm-2.6.25-rc5-mm1/mm/page_cgroup.c
> ===================================================================
> --- mm-2.6.25-rc5-mm1.orig/mm/page_cgroup.c
> +++ mm-2.6.25-rc5-mm1/mm/page_cgroup.c
> @@ -12,6 +12,7 @@
>   */
>  
>  #include <linux/mm.h>
> +#include <linux/mmzone.h>
>  #include <linux/slab.h>
>  #include <linux/radix-tree.h>
>  #include <linux/memcontrol.h>
> @@ -80,6 +81,7 @@ static void save_result(struct page_cgro
>  	pcp = &__get_cpu_var(pcpu_page_cgroup_cache);
>  	pcp->ents[hash].idx = idx;
>  	pcp->ents[hash].base = base;
> +	smp_wmb();

Whenever you add a memory barrier, you should comment on it.

>  	preempt_enable();
>  }
>  
> @@ -156,6 +158,58 @@ out:
>  	return pc;
>  }
>  
> +/* Must be called under zone->lock */
> +void try_to_shrink_page_cgroup(struct page *page, int order)
> +{
> +	unsigned long pfn = page_to_pfn(page);
> +	int nid = page_to_nid(page);
> +	int idx = pfn >> PCGRP_SHIFT;
> +	int hnum = (PAGE_CGROUP_NR_CACHE - 1);
> +	struct page_cgroup_cache *pcp;
> +	struct page_cgroup_head *head;
> +	struct page_cgroup_root *root;
> +	unsigned long end_pfn;
> +	int cpu;
> +
> +

redundant empty line

> +	root = root_dir[nid];
> +	if (!root || in_interrupt() || (order < PCGRP_SHIFT))
> +		return;
> +
> +	pfn = page_to_pfn(page);
> +	end_pfn = pfn + (1 << order);
> +
> +	while (pfn != end_pfn) {
> +		idx = pfn >> PCGRP_SHIFT;
> +		/* Is this pfn has entry ? */
> +		rcu_read_lock();
> +		head = radix_tree_lookup(&root->root_node, idx);
> +		rcu_read_unlock();
> +		if (!head) {
> +			pfn += (1 << PCGRP_SHIFT);

pfn += PCGRP_SIZE;

> +			continue;
> +		}
> +		/* It's guaranteed that no one access to this pfn/idx
> +		   because there is no reference to this page. */
> +		hnum = (idx) & (PAGE_CGROUP_NR_CACHE - 1);
> +		for_each_online_cpu(cpu) {
> +			pcp = &per_cpu(pcpu_page_cgroup_cache, cpu);
> +			smp_rmb();
> +			if (pcp->ents[hnum].idx == idx)
> +				pcp->ents[hnum].base = NULL;
> +		}
> +		if (spin_trylock(&root->tree_lock)) {
> +			/* radix tree is freed by RCU. so they will not call
> +			   free_pages() right now.*/
> +			radix_tree_delete(&root->root_node, idx);
> +			spin_unlock(&root->tree_lock);
> +			/* We can free this in lazy fashion .*/
> +			free_page_cgroup(head);
> +		}
> +		pfn += (1 << PCGRP_SHIFT);

ditto

> +	}
> +}
> +
>  __init int page_cgroup_init(void)
>  {
>  	int nid;
> Index: mm-2.6.25-rc5-mm1/mm/page_alloc.c
> ===================================================================
> --- mm-2.6.25-rc5-mm1.orig/mm/page_alloc.c
> +++ mm-2.6.25-rc5-mm1/mm/page_alloc.c
> @@ -45,6 +45,7 @@
>  #include <linux/fault-inject.h>
>  #include <linux/page-isolation.h>
>  #include <linux/memcontrol.h>
> +#include <linux/page_cgroup.h>
>  
>  #include <asm/tlbflush.h>
>  #include <asm/div64.h>
> @@ -463,6 +464,8 @@ static inline void __free_one_page(struc
>  		order++;
>  	}
>  	set_page_order(page, order);
> +	if (order >= PCGRP_SHRINK_ORDER)
> +		try_to_shrink_page_cgroup(page, order);
>  	list_add(&page->lru,
>  		&zone->free_area[order].free_list[migratetype]);
>  	zone->free_area[order].nr_free++;
> 
> --

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
