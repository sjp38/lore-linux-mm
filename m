Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 938626B004D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 11:16:18 -0500 (EST)
Date: Tue, 20 Dec 2011 17:16:15 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 4/4] memcg: simplify LRU handling by new rule
Message-ID: <20111220161615.GQ10565@tiehlicka.suse.cz>
References: <20111214164734.4d7d6d97.kamezawa.hiroyu@jp.fujitsu.com>
 <20111214165226.1c3b666e.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111214165226.1c3b666e.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>

On Wed 14-12-11 16:52:26, KAMEZAWA Hiroyuki wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Now, at LRU handling, memory cgroup needs to do complicated works
> to see valid pc->mem_cgroup, which may be overwritten.
> 
> This patch is for relaxing the protocol. This patch guarantees
>    - when pc->mem_cgroup is overwritten, page must not be on LRU.

How the patch guarantees that? I do not see any enforcement. In fact we
depend on the previous patches, don't we.

> 
> By this, LRU routine can believe pc->mem_cgroup and don't need to
> check bits on pc->flags. This new rule may adds small overheads to
> swapin. But in most case, lru handling gets faster.
> 
> After this patch, PCG_ACCT_LRU bit is obsolete and removed.

It makes things much more simpler. I just think it needs a better
description.

> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/page_cgroup.h |    8 -----
>  mm/memcontrol.c             |   72 ++++++++++--------------------------------
>  2 files changed, 17 insertions(+), 63 deletions(-)
> 
> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> index aaa60da..2cddacf 100644
> --- a/include/linux/page_cgroup.h
> +++ b/include/linux/page_cgroup.h
> @@ -10,8 +10,6 @@ enum {
>  	/* flags for mem_cgroup and file and I/O status */
>  	PCG_MOVE_LOCK, /* For race between move_account v.s. following bits */
>  	PCG_FILE_MAPPED, /* page is accounted as "mapped" */
> -	/* No lock in page_cgroup */
> -	PCG_ACCT_LRU, /* page has been accounted for (under lru_lock) */
>  	__NR_PCG_FLAGS,
>  };
>  
> @@ -75,12 +73,6 @@ TESTPCGFLAG(Used, USED)
>  CLEARPCGFLAG(Used, USED)
>  SETPCGFLAG(Used, USED)
>  
> -SETPCGFLAG(AcctLRU, ACCT_LRU)
> -CLEARPCGFLAG(AcctLRU, ACCT_LRU)
> -TESTPCGFLAG(AcctLRU, ACCT_LRU)
> -TESTCLEARPCGFLAG(AcctLRU, ACCT_LRU)
> -
> -
>  SETPCGFLAG(FileMapped, FILE_MAPPED)
>  CLEARPCGFLAG(FileMapped, FILE_MAPPED)
>  TESTPCGFLAG(FileMapped, FILE_MAPPED)
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 2ae973d..d5e21e7 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -974,30 +974,8 @@ struct lruvec *mem_cgroup_lru_add_list(struct zone *zone, struct page *page,
>  		return &zone->lruvec;
>  
>  	pc = lookup_page_cgroup(page);
> -	VM_BUG_ON(PageCgroupAcctLRU(pc));
> -	/*
> -	 * putback:				charge:
> -	 * SetPageLRU				SetPageCgroupUsed
> -	 * smp_mb				smp_mb
> -	 * PageCgroupUsed && add to memcg LRU	PageLRU && add to memcg LRU
> -	 *
> -	 * Ensure that one of the two sides adds the page to the memcg
> -	 * LRU during a race.
> -	 */
> -	smp_mb();
> -	/*
> -	 * If the page is uncharged, it may be freed soon, but it
> -	 * could also be swap cache (readahead, swapoff) that needs to
> -	 * be reclaimable in the future.  root_mem_cgroup will babysit
> -	 * it for the time being.
> -	 */
> -	if (PageCgroupUsed(pc)) {
> -		/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
> -		smp_rmb();
> -		memcg = pc->mem_cgroup;
> -		SetPageCgroupAcctLRU(pc);
> -	} else
> -		memcg = root_mem_cgroup;
> +	memcg = pc->mem_cgroup;
> +	VM_BUG_ON(!memcg);
>  	mz = page_cgroup_zoneinfo(memcg, page);
>  	/* compound_order() is stabilized through lru_lock */
>  	MEM_CGROUP_ZSTAT(mz, lru) += 1 << compound_order(page);
> @@ -1024,18 +1002,8 @@ void mem_cgroup_lru_del_list(struct page *page, enum lru_list lru)
>  		return;
>  
>  	pc = lookup_page_cgroup(page);
> -	/*
> -	 * root_mem_cgroup babysits uncharged LRU pages, but
> -	 * PageCgroupUsed is cleared when the page is about to get
> -	 * freed.  PageCgroupAcctLRU remembers whether the
> -	 * LRU-accounting happened against pc->mem_cgroup or
> -	 * root_mem_cgroup.
> -	 */
> -	if (TestClearPageCgroupAcctLRU(pc)) {
> -		VM_BUG_ON(!pc->mem_cgroup);
> -		memcg = pc->mem_cgroup;
> -	} else
> -		memcg = root_mem_cgroup;
> +	memcg = pc->mem_cgroup;
> +	VM_BUG_ON(!memcg);
>  	mz = page_cgroup_zoneinfo(memcg, page);
>  	/* huge page split is done under lru_lock. so, we have no races. */
>  	MEM_CGROUP_ZSTAT(mz, lru) -= 1 << compound_order(page);
> @@ -2377,6 +2345,7 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
>  
>  	mem_cgroup_charge_statistics(memcg, PageCgroupCache(pc), nr_pages);
>  	unlock_page_cgroup(pc);
> +	WARN_ON_ONCE(PageLRU(page));
>  	/*
>  	 * "charge_statistics" updated event counter. Then, check it.
>  	 * Insert ancestor (and ancestor's ancestors), to softlimit RB-tree.
> @@ -2388,7 +2357,7 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  
>  #define PCGF_NOCOPY_AT_SPLIT ((1 << PCG_LOCK) | (1 << PCG_MOVE_LOCK) |\
> -			(1 << PCG_ACCT_LRU) | (1 << PCG_MIGRATION))
> +			(1 << PCG_MIGRATION))
>  /*
>   * Because tail pages are not marked as "used", set it. We're under
>   * zone->lru_lock, 'splitting on pmd' and compound_lock.
> @@ -2399,6 +2368,8 @@ void mem_cgroup_split_huge_fixup(struct page *head)
>  {
>  	struct page_cgroup *head_pc = lookup_page_cgroup(head);
>  	struct page_cgroup *pc;
> +	struct mem_cgroup_per_zone *mz;
> +	enum lru_list lru;
>  	int i;
>  
>  	if (mem_cgroup_disabled())
> @@ -2407,23 +2378,15 @@ void mem_cgroup_split_huge_fixup(struct page *head)
>  		pc = head_pc + i;
>  		pc->mem_cgroup = head_pc->mem_cgroup;
>  		smp_wmb();/* see __commit_charge() */
> -		/*
> -		 * LRU flags cannot be copied because we need to add tail
> -		 * page to LRU by generic call and our hooks will be called.
> -		 */
>  		pc->flags = head_pc->flags & ~PCGF_NOCOPY_AT_SPLIT;
>  	}
> -
> -	if (PageCgroupAcctLRU(head_pc)) {
> -		enum lru_list lru;
> -		struct mem_cgroup_per_zone *mz;
> -		/*
> -		 * We hold lru_lock, then, reduce counter directly.
> -		 */
> -		lru = page_lru(head);
> -		mz = page_cgroup_zoneinfo(head_pc->mem_cgroup, head);
> -		MEM_CGROUP_ZSTAT(mz, lru) -= HPAGE_PMD_NR - 1;
> -	}
> +	/* 
> +	 * Tail pages will be added to LRU.
> +	 * We hold lru_lock,then,reduce counter directly.
> +	 */
> +	lru = page_lru(head);
> +	mz = page_cgroup_zoneinfo(head_pc->mem_cgroup, head);
> +	MEM_CGROUP_ZSTAT(mz, lru) -= HPAGE_PMD_NR - 1;
>  }
>  #endif
>  
> @@ -2656,10 +2619,9 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
>  	if (!page_is_file_cache(page))
>  		type = MEM_CGROUP_CHARGE_TYPE_SHMEM;
>  
> -	if (!PageSwapCache(page)) {
> +	if (!PageSwapCache(page))
>  		ret = mem_cgroup_charge_common(page, mm, gfp_mask, type);
> -		WARN_ON_ONCE(PageLRU(page));
> -	} else { /* page is swapcache/shmem */
> +	else { /* page is swapcache/shmem */
>  		ret = mem_cgroup_try_charge_swapin(mm, page, gfp_mask, &memcg);
>  		if (!ret)
>  			__mem_cgroup_commit_charge_swapin(page, memcg, type);
> -- 
> 1.7.4.1
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
