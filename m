Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 90E116B004D
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 00:41:33 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id D438E3EE0BD
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 14:41:31 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 79ED845DE59
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 14:41:31 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 529C845DE4D
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 14:41:31 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 377771DB8043
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 14:41:31 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B92B01DB8041
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 14:41:30 +0900 (JST)
Date: Wed, 29 Feb 2012 14:39:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3.3] memcg: fix deadlock by inverting lrucare nesting
Message-Id: <20120229143931.089e1c3f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1202282121160.4875@eggly.anvils>
References: <alpine.LSU.2.00.1202282121160.4875@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 28 Feb 2012 21:25:02 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> We have forgotten the rules of lock nesting: the irq-safe ones must be
> taken inside the non-irq-safe ones, otherwise we are open to deadlock:
> 
> CPU0                          CPU1
> ----                          ----
> lock(&(&pc->lock)->rlock);
>                               local_irq_disable();
>                               lock(&(&zone->lru_lock)->rlock);
>                               lock(&(&pc->lock)->rlock);
> <Interrupt>
> lock(&(&zone->lru_lock)->rlock);
> 
> To check a different locking issue, I happened to add a spin_lock to
> memcg's bit_spin_lock in lock_page_cgroup(), and lockdep very quickly
> complained about __mem_cgroup_commit_charge_lrucare() (on CPU1 above).
> 
> So delete __mem_cgroup_commit_charge_lrucare(), passing a bool lrucare
> to __mem_cgroup_commit_charge() instead, taking zone->lru_lock under
> lock_page_cgroup() in the lrucare case.
> 
> The original was using spin_lock_irqsave, but we'd be in more trouble
> if it were ever called at interrupt time: unconditional _irq is enough.
> And ClearPageLRU before del from lru, SetPageLRU before add to lru: no
> strong reason, but that is the ordering used consistently elsewhere.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Thank you. And I'm sorry for adding new bug :(

This is a fix for "memcg: simplify corner case handling of LRU"
as commit 36b62ad539498d00c2d280a151abad5f7630fa73 in upstream.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


> ---
> Not needed for -stable: this issue came into 3.3-rc1.
> 
>  mm/memcontrol.c |   72 +++++++++++++++++++++++-----------------------
>  1 file changed, 37 insertions(+), 35 deletions(-)
> 
> --- 3.3-rc5/mm/memcontrol.c	2012-02-25 13:02:05.165830574 -0800
> +++ linux/mm/memcontrol.c	2012-02-27 23:24:54.676160755 -0800
> @@ -2408,8 +2408,12 @@ static void __mem_cgroup_commit_charge(s
>  				       struct page *page,
>  				       unsigned int nr_pages,
>  				       struct page_cgroup *pc,
> -				       enum charge_type ctype)
> +				       enum charge_type ctype,
> +				       bool lrucare)
>  {
> +	struct zone *uninitialized_var(zone);
> +	bool was_on_lru = false;
> +
>  	lock_page_cgroup(pc);
>  	if (unlikely(PageCgroupUsed(pc))) {
>  		unlock_page_cgroup(pc);
> @@ -2420,6 +2424,21 @@ static void __mem_cgroup_commit_charge(s
>  	 * we don't need page_cgroup_lock about tail pages, becase they are not
>  	 * accessed by any other context at this point.
>  	 */
> +
> +	/*
> +	 * In some cases, SwapCache and FUSE(splice_buf->radixtree), the page
> +	 * may already be on some other mem_cgroup's LRU.  Take care of it.
> +	 */
> +	if (lrucare) {
> +		zone = page_zone(page);
> +		spin_lock_irq(&zone->lru_lock);
> +		if (PageLRU(page)) {
> +			ClearPageLRU(page);
> +			del_page_from_lru_list(zone, page, page_lru(page));
> +			was_on_lru = true;
> +		}
> +	}
> +
>  	pc->mem_cgroup = memcg;
>  	/*
>  	 * We access a page_cgroup asynchronously without lock_page_cgroup().
> @@ -2443,9 +2462,18 @@ static void __mem_cgroup_commit_charge(s
>  		break;
>  	}
>  
> +	if (lrucare) {
> +		if (was_on_lru) {
> +			VM_BUG_ON(PageLRU(page));
> +			SetPageLRU(page);
> +			add_page_to_lru_list(zone, page, page_lru(page));
> +		}
> +		spin_unlock_irq(&zone->lru_lock);
> +	}
> +
>  	mem_cgroup_charge_statistics(memcg, PageCgroupCache(pc), nr_pages);
>  	unlock_page_cgroup(pc);
> -	WARN_ON_ONCE(PageLRU(page));
> +
>  	/*
>  	 * "charge_statistics" updated event counter. Then, check it.
>  	 * Insert ancestor (and ancestor's ancestors), to softlimit RB-tree.
> @@ -2643,7 +2671,7 @@ static int mem_cgroup_charge_common(stru
>  	ret = __mem_cgroup_try_charge(mm, gfp_mask, nr_pages, &memcg, oom);
>  	if (ret == -ENOMEM)
>  		return ret;
> -	__mem_cgroup_commit_charge(memcg, page, nr_pages, pc, ctype);
> +	__mem_cgroup_commit_charge(memcg, page, nr_pages, pc, ctype, false);
>  	return 0;
>  }
>  
> @@ -2663,35 +2691,6 @@ static void
>  __mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr,
>  					enum charge_type ctype);
>  
> -static void
> -__mem_cgroup_commit_charge_lrucare(struct page *page, struct mem_cgroup *memcg,
> -					enum charge_type ctype)
> -{
> -	struct page_cgroup *pc = lookup_page_cgroup(page);
> -	struct zone *zone = page_zone(page);
> -	unsigned long flags;
> -	bool removed = false;
> -
> -	/*
> -	 * In some case, SwapCache, FUSE(splice_buf->radixtree), the page
> -	 * is already on LRU. It means the page may on some other page_cgroup's
> -	 * LRU. Take care of it.
> -	 */
> -	spin_lock_irqsave(&zone->lru_lock, flags);
> -	if (PageLRU(page)) {
> -		del_page_from_lru_list(zone, page, page_lru(page));
> -		ClearPageLRU(page);
> -		removed = true;
> -	}
> -	__mem_cgroup_commit_charge(memcg, page, 1, pc, ctype);
> -	if (removed) {
> -		add_page_to_lru_list(zone, page, page_lru(page));
> -		SetPageLRU(page);
> -	}
> -	spin_unlock_irqrestore(&zone->lru_lock, flags);
> -	return;
> -}
> -
>  int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
>  				gfp_t gfp_mask)
>  {
> @@ -2769,13 +2768,16 @@ static void
>  __mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *memcg,
>  					enum charge_type ctype)
>  {
> +	struct page_cgroup *pc;
> +
>  	if (mem_cgroup_disabled())
>  		return;
>  	if (!memcg)
>  		return;
>  	cgroup_exclude_rmdir(&memcg->css);
>  
> -	__mem_cgroup_commit_charge_lrucare(page, memcg, ctype);
> +	pc = lookup_page_cgroup(page);
> +	__mem_cgroup_commit_charge(memcg, page, 1, pc, ctype, true);
>  	/*
>  	 * Now swap is on-memory. This means this page may be
>  	 * counted both as mem and swap....double count.
> @@ -3248,7 +3250,7 @@ int mem_cgroup_prepare_migration(struct
>  		ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
>  	else
>  		ctype = MEM_CGROUP_CHARGE_TYPE_SHMEM;
> -	__mem_cgroup_commit_charge(memcg, newpage, 1, pc, ctype);
> +	__mem_cgroup_commit_charge(memcg, newpage, 1, pc, ctype, false);
>  	return ret;
>  }
>  
> @@ -3332,7 +3334,7 @@ void mem_cgroup_replace_page_cache(struc
>  	 * the newpage may be on LRU(or pagevec for LRU) already. We lock
>  	 * LRU while we overwrite pc->mem_cgroup.
>  	 */
> -	__mem_cgroup_commit_charge_lrucare(newpage, memcg, type);
> +	__mem_cgroup_commit_charge(memcg, newpage, 1, pc, type, true);
>  }
>  
>  #ifdef CONFIG_DEBUG_VM
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
