Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id CA52A6B0089
	for <linux-mm@kvack.org>; Sun,  5 Dec 2010 22:52:25 -0500 (EST)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp03.au.ibm.com (8.14.4/8.13.1) with ESMTP id oB63m65x008686
	for <linux-mm@kvack.org>; Mon, 6 Dec 2010 14:48:06 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oB63qJoh1871928
	for <linux-mm@kvack.org>; Mon, 6 Dec 2010 14:52:20 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oB63qIdj009002
	for <linux-mm@kvack.org>; Mon, 6 Dec 2010 14:52:19 +1100
Date: Mon, 6 Dec 2010 09:04:55 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 3/7] move memcg reclaimable page into tail of
 inactive list
Message-ID: <20101206033455.GA3158@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <cover.1291568905.git.minchan.kim@gmail.com>
 <a11d438e09af9808ac0cb0aba3e74c8a8deb4076.1291568905.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <a11d438e09af9808ac0cb0aba3e74c8a8deb4076.1291568905.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* MinChan Kim <minchan.kim@gmail.com> [2010-12-06 02:29:11]:

> Golbal page reclaim moves reclaimalbe pages into inactive list

Some typos here and Rik already pointed out some other changes.

> to reclaim asap. This patch apply the rule in memcg.
> It can help to prevent unnecessary working page eviction of memcg.
> 
> Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> ---
>  include/linux/memcontrol.h |    6 ++++++
>  mm/memcontrol.c            |   27 +++++++++++++++++++++++++++
>  mm/swap.c                  |    3 ++-
>  3 files changed, 35 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 067115c..8317f5c 100644
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
> @@ -207,6 +208,11 @@ static inline void mem_cgroup_del_lru_list(struct page *page, int lru)
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
> index 729beb7..f9435be 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -829,6 +829,33 @@ void mem_cgroup_del_lru(struct page *page)
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
> +	mz = page_cgroup_zoneinfo(pc);
> +	list_move_tail(&pc->lru, &mz->lists[lru]);
> +}
> +
>  void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list lru)
>  {
>  	struct mem_cgroup_per_zone *mz;
> diff --git a/mm/swap.c b/mm/swap.c
> index 1f36f6f..0fe98e7 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -122,8 +122,9 @@ static void pagevec_move_tail(struct pagevec *pvec)
>  		}
>  		if (PageLRU(page) && !PageActive(page) &&
>  					!PageUnevictable(page)) {
> -			int lru = page_lru_base_type(page);
> +			enum lru_list lru = page_lru_base_type(page);
>  			list_move_tail(&page->lru, &zone->lru[lru].list);
> +			mem_cgroup_rotate_reclaimable_page(page);
>  			pgmoved++;
>  		}
>  	}

Looks good, do you have any numbers, workloads that benefit? I agree
that keeping both global and memcg reclaim in sync is a good idea.

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
