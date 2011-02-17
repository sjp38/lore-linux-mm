Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 22D058D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 11:10:35 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 364E63EE0BB
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 01:10:32 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0DBBC2AEA8D
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 01:10:32 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id EAB6F45DE63
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 01:10:31 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DCD151DB8045
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 01:10:31 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 637BA1DB804A
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 01:10:31 +0900 (JST)
Date: Fri, 18 Feb 2011 01:04:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v5 2/4] memcg: move memcg reclaimable page into tail of
 inactive list
Message-Id: <20110218010416.230a65df.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <442221b243154ef2546cb921d53b774f2c8f5df5.1297940291.git.minchan.kim@gmail.com>
References: <cover.1297940291.git.minchan.kim@gmail.com>
	<442221b243154ef2546cb921d53b774f2c8f5df5.1297940291.git.minchan.kim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Steven Barrett <damentz@liquorix.net>, Ben Gamari <bgamari.foss@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>

On Fri, 18 Feb 2011 00:08:20 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> The rotate_reclaimable_page function moves just written out
> pages, which the VM wanted to reclaim, to the end of the
> inactive list.  That way the VM will find those pages first
> next time it needs to free memory.
> This patch apply the rule in memcg.
> It can help to prevent unnecessary working page eviction of memcg.
> 
> Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> ---
> Changelog since v4:
>  - add acked-by and reviewed-by
>  - change description - suggested by Rik
> 
>  include/linux/memcontrol.h |    6 ++++++
>  mm/memcontrol.c            |   27 +++++++++++++++++++++++++++
>  mm/swap.c                  |    3 ++-
>  3 files changed, 35 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 3da48ae..5a5ce70 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -62,6 +62,7 @@ extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
>  					gfp_t gfp_mask);
>  extern void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru);
>  extern void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru);
> +extern void mem_cgroup_rotate_reclaimable_page(struct page *page);
>  extern void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list lru);
>  extern void mem_cgroup_del_lru(struct page *page);
>  extern void mem_cgroup_move_lists(struct page *page,
> @@ -215,6 +216,11 @@ static inline void mem_cgroup_del_lru_list(struct page *page, int lru)
>  	return ;
>  }
>  
> +static inline inline void mem_cgroup_rotate_reclaimable_page(struct page *page)
> +{
> +	return ;
> +}
> +
>  static inline void mem_cgroup_rotate_lru_list(struct page *page, int lru)
>  {
>  	return ;
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 686f1ce..ab8bdff 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -813,6 +813,33 @@ void mem_cgroup_del_lru(struct page *page)
>  	mem_cgroup_del_lru_list(page, page_lru(page));
>  }
>  
> +/*
> + * Writeback is about to end against a page which has been marked for immediate
> + * reclaim.  If it still appears to be reclaimable, move it to the tail of the
> + * inactive list.
> + */
> +void mem_cgroup_rotate_reclaimable_page(struct page *page)
> +{
> +	struct mem_cgroup_per_zone *mz;
> +	struct page_cgroup *pc;
> +	enum lru_list lru = page_lru_base_type(page);
> +
> +	if (mem_cgroup_disabled())
> +		return;
> +
> +	pc = lookup_page_cgroup(page);
> +	/*
> +	 * Used bit is set without atomic ops but after smp_wmb().
> +	 * For making pc->mem_cgroup visible, insert smp_rmb() here.
> +	 */
> +	smp_rmb();
> +	/* unused or root page is not rotated. */
> +	if (!PageCgroupUsed(pc) || mem_cgroup_is_root(pc->mem_cgroup))
> +		return;
> +	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
> +	list_move_tail(&pc->lru, &mz->lists[lru]);
> +}
> +

Hmm, I'm sorry I misunderstand this. IIUC, page_lru_base_type() always returns
LRU_INACTIVE_XXX and this function may move page from active LRU to inactive LRU.

Then, LRU counters for memcg should be updated.

Could you replace after lookup like this ?

     VM_BUG_ON(!PageCgroupAcctLRU(pc))  /* Implies this pages must be on some LRU */
     if (!PageCgroupUsed(pc))
           return;
     /* Used bit check is not necessary, because there is a case Unused page
        is lazily on LRU. We trust AcctLRU bit. */
     mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
     MEM_CGROUP_ZSTAT(mz, page_lru(page)) -= 1 << compound_order(page);     
     MEM_CGROUP_ZSTAT(mz, lru) += 1 << compound_order(page)
     if (mem_cgroup_is_root(pc->mem_cgroup))
           return;
     list_move_tail(&pc->lru, &mz->lists[lru])


Thanks,
-Kame
>  void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list lru)
>  {
>  	struct mem_cgroup_per_zone *mz;
> diff --git a/mm/swap.c b/mm/swap.c
> index 4aea806..1b9e4eb 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -200,8 +200,9 @@ static void pagevec_move_tail(struct pagevec *pvec)
>  			spin_lock(&zone->lru_lock);
>  		}
>  		if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
> -			int lru = page_lru_base_type(page);
> +			enum lru_list lru = page_lru_base_type(page);
>  			list_move_tail(&page->lru, &zone->lru[lru].list);
> +			mem_cgroup_rotate_reclaimable_page(page);
>  			pgmoved++;
>  		}
>  	}
> -- 
> 1.7.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
