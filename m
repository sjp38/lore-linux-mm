Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id E87776B004A
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 04:50:01 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 3E2973EE0BD
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 18:50:00 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C85245DE58
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 18:50:00 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0288D45DE54
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 18:50:00 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DA07F1DB8046
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 18:49:59 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8A9F91DB8032
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 18:49:59 +0900 (JST)
Date: Tue, 21 Feb 2012 18:48:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 8/10] mm/memcg: nest lru_lock inside page_cgroup lock
Message-Id: <20120221184829.78d523a8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1202201535460.23274@eggly.anvils>
References: <alpine.LSU.2.00.1202201518560.23274@eggly.anvils>
	<alpine.LSU.2.00.1202201535460.23274@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 20 Feb 2012 15:36:55 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> Cut back on some of the overhead we've added, particularly the lruvec
> locking added to every __mem_cgroup_uncharge_common(), and the page
> cgroup locking in mem_cgroup_reset_uncharged_to_root().
> 
> Our hands were tied by the lock ordering (page cgroup inside lruvec)
> defined by __mem_cgroup_commit_charge_lrucare().  There is no strong
> reason for why that nesting needs to be one way or the other, and if
> we invert it, then some optimizations become possible.
> 
> So delete __mem_cgroup_commit_charge_lrucare(), passing a bool lrucare
> to __mem_cgroup_commit_charge() instead, using page_lock_lruvec() there
> inside lock_page_cgroup() in the lrucare case.  (I'd prefer to work it
> out internally, than rely upon an lrucare argument: but that is hard -
> certainly PageLRU is not enough, racing with pages on pagevec about to
> be flushed to lru.)  Use page_relock_lruvec() after setting mem_cgroup,
> before adding to the appropriate new lruvec: so that (if lock depends
> on memcg) old lock is held across change in ownership while off lru.
> 
> Delete the lruvec locking on entry to __mem_cgroup_uncharge_common();
> but if the page being uncharged is not on lru, then we do need to
> reset its ownership, and must dance very carefully with mem_cgroup_
> reset_uncharged_to_root(), to make sure that when there's a race
> between uncharging and removing from lru, one side or the other
> will see it - smp_mb__after_clear_bit() at both ends.
> 

> Avoid overhead of calls to mem_cgroup_reset_uncharged_to_root() from
> release_pages() and __page_cache_release(), by doing its work inside
> page_relock_lruvec() when the page_count is 0 i.e. the page is frozen
> from other references and about to be freed.  That was not possible
> with the old lock ordering, since __mem_cgroup_uncharge_common()'s
> lock then changed ownership too soon.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
>  mm/memcontrol.c |  142 ++++++++++++++++++++++++----------------------
>  mm/swap.c       |    2 
>  2 files changed, 75 insertions(+), 69 deletions(-)
> 
> --- mmotm.orig/mm/memcontrol.c	2012-02-18 11:57:55.551524898 -0800
> +++ mmotm/mm/memcontrol.c	2012-02-18 11:58:02.451525062 -0800
> @@ -1059,6 +1059,14 @@ void page_relock_lruvec(struct page *pag
>  		 */
>  		if (unlikely(!memcg))
>  			memcg = pc->mem_cgroup = root_mem_cgroup;
> +		/*
> +		 * We must reset pc->mem_cgroup back to root before freeing
> +		 * a page: avoid additional callouts from hot paths by doing
> +		 * it here when we see the page is frozen (can safely be done
> +		 * before taking lru_lock because the page is frozen).
> +		 */
> +		if (memcg != root_mem_cgroup && !page_count(page))
> +			pc->mem_cgroup = root_mem_cgroup;
>  		mz = page_cgroup_zoneinfo(memcg, page);
>  		lruvec = &mz->lruvec;
>  	}
> @@ -1083,23 +1091,20 @@ void mem_cgroup_reset_uncharged_to_root(
>  		return;
>  
>  	VM_BUG_ON(PageLRU(page));
> +	/*
> +	 * Caller just did ClearPageLRU():
> +	 * make sure that __mem_cgroup_uncharge_common()
> +	 * can see that before we test PageCgroupUsed(pc).
> +	 */
> +	smp_mb__after_clear_bit();
>  
>  	/*
>  	 * Once an uncharged page is isolated from the mem_cgroup's lru,
>  	 * it no longer protects that mem_cgroup from rmdir: reset to root.
> -	 *
> -	 * __page_cache_release() and release_pages() may be called at
> -	 * interrupt time: we cannot lock_page_cgroup() then (we might
> -	 * have interrupted a section with page_cgroup already locked),
> -	 * nor do we need to since the page is frozen and about to be freed.
>  	 */
>  	pc = lookup_page_cgroup(page);
> -	if (page_count(page))
> -		lock_page_cgroup(pc);
>  	if (!PageCgroupUsed(pc) && pc->mem_cgroup != root_mem_cgroup)
>  		pc->mem_cgroup = root_mem_cgroup;
> -	if (page_count(page))
> -		unlock_page_cgroup(pc);
>  }
>  
>  /**
> @@ -2422,9 +2427,11 @@ static void __mem_cgroup_commit_charge(s
>  				       struct page *page,
>  				       unsigned int nr_pages,
>  				       struct page_cgroup *pc,
> -				       enum charge_type ctype)
> +				       enum charge_type ctype,
> +				       bool lrucare)
>  {
> -	bool anon;
> +	struct lruvec *lruvec;
> +	bool was_on_lru = false;
>  
>  	lock_page_cgroup(pc);
>  	if (unlikely(PageCgroupUsed(pc))) {
> @@ -2433,28 +2440,41 @@ static void __mem_cgroup_commit_charge(s
>  		return;
>  	}
>  	/*
> -	 * we don't need page_cgroup_lock about tail pages, becase they are not
> -	 * accessed by any other context at this point.
> +	 * We don't need lock_page_cgroup on tail pages, because they are not
> +	 * accessible to any other context at this point.
>  	 */
> -	pc->mem_cgroup = memcg;
> +
>  	/*
> -	 * We access a page_cgroup asynchronously without lock_page_cgroup().
> -	 * Especially when a page_cgroup is taken from a page, pc->mem_cgroup
> -	 * is accessed after testing USED bit. To make pc->mem_cgroup visible
> -	 * before USED bit, we need memory barrier here.
> -	 * See mem_cgroup_add_lru_list(), etc.
> - 	 */
> -	smp_wmb();
> +	 * In some cases, SwapCache and FUSE(splice_buf->radixtree), the page
> +	 * may already be on some other page_cgroup's LRU.  Take care of it.
> +	 */
> +	if (lrucare) {
> +		lruvec = page_lock_lruvec(page);
> +		if (PageLRU(page)) {
> +			ClearPageLRU(page);
> +			del_page_from_lru_list(page, lruvec, page_lru(page));
> +			was_on_lru = true;
> +		}
> +	}
>  
> +	pc->mem_cgroup = memcg;
>  	SetPageCgroupUsed(pc);
> -	if (ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
> -		anon = true;
> -	else
> -		anon = false;
>  
> -	mem_cgroup_charge_statistics(memcg, anon, nr_pages);
> +	if (lrucare) {
> +		if (was_on_lru) {
> +			page_relock_lruvec(page, &lruvec);
> +			if (!PageLRU(page)) {
> +				SetPageLRU(page);
> +				add_page_to_lru_list(page, lruvec, page_lru(page));
> +			}
> +		}
> +		unlock_lruvec(lruvec);
> +	}
> +
> +	mem_cgroup_charge_statistics(memcg,
> +			ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED, nr_pages);
>  	unlock_page_cgroup(pc);
> -	WARN_ON_ONCE(PageLRU(page));
> +
>  	/*
>  	 * "charge_statistics" updated event counter. Then, check it.
>  	 * Insert ancestor (and ancestor's ancestors), to softlimit RB-tree.
> @@ -2652,7 +2672,7 @@ static int mem_cgroup_charge_common(stru
>  	ret = __mem_cgroup_try_charge(mm, gfp_mask, nr_pages, &memcg, oom);
>  	if (ret == -ENOMEM)
>  		return ret;
> -	__mem_cgroup_commit_charge(memcg, page, nr_pages, pc, ctype);
> +	__mem_cgroup_commit_charge(memcg, page, nr_pages, pc, ctype, false);
>  	return 0;
>  }
>  
> @@ -2672,34 +2692,6 @@ static void
>  __mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr,
>  					enum charge_type ctype);
>  
> -static void
> -__mem_cgroup_commit_charge_lrucare(struct page *page, struct mem_cgroup *memcg,
> -					enum charge_type ctype)
> -{
> -	struct page_cgroup *pc = lookup_page_cgroup(page);
> -	struct lruvec *lruvec;
> -	bool removed = false;
> -
> -	/*
> -	 * In some case, SwapCache, FUSE(splice_buf->radixtree), the page
> -	 * is already on LRU. It means the page may on some other page_cgroup's
> -	 * LRU. Take care of it.
> -	 */
> -	lruvec = page_lock_lruvec(page);
> -	if (PageLRU(page)) {
> -		del_page_from_lru_list(page, lruvec, page_lru(page));
> -		ClearPageLRU(page);
> -		removed = true;
> -	}
> -	__mem_cgroup_commit_charge(memcg, page, 1, pc, ctype);
> -	if (removed) {
> -		page_relock_lruvec(page, &lruvec);
> -		add_page_to_lru_list(page, lruvec, page_lru(page));
> -		SetPageLRU(page);
> -	}
> -	unlock_lruvec(lruvec);
> -}
> -
>  int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
>  				gfp_t gfp_mask)
>  {
> @@ -2777,13 +2769,16 @@ static void
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
> @@ -2898,7 +2893,6 @@ __mem_cgroup_uncharge_common(struct page
>  	struct mem_cgroup *memcg = NULL;
>  	unsigned int nr_pages = 1;
>  	struct page_cgroup *pc;
> -	struct lruvec *lruvec;
>  	bool anon;
>  
>  	if (mem_cgroup_disabled())
> @@ -2918,7 +2912,6 @@ __mem_cgroup_uncharge_common(struct page
>  	if (unlikely(!PageCgroupUsed(pc)))
>  		return NULL;
>  
> -	lruvec = page_lock_lruvec(page);
>  	lock_page_cgroup(pc);
>  
>  	memcg = pc->mem_cgroup;
> @@ -2950,16 +2943,31 @@ __mem_cgroup_uncharge_common(struct page
>  	mem_cgroup_charge_statistics(memcg, anon, -nr_pages);
>  
>  	ClearPageCgroupUsed(pc);
> +	/*
> +	 * Make sure that mem_cgroup_reset_uncharged_to_root()
> +	 * can see that before we test PageLRU(page).
> +	 */
> +	smp_mb__after_clear_bit();
>  
>  	/*
>  	 * Once an uncharged page is isolated from the mem_cgroup's lru,
>  	 * it no longer protects that mem_cgroup from rmdir: reset to root.
> -	 */
> -	if (!PageLRU(page) && pc->mem_cgroup != root_mem_cgroup)
> -		pc->mem_cgroup = root_mem_cgroup;
> -
> +	 *
> +	 * The page_count() test avoids the lock in the common case when
> +	 * shrink_page_list()'s __remove_mapping() has frozen references
> +	 * to 0 and the page is on its way to freedom.
> +	 */
> +	if (!PageLRU(page) && pc->mem_cgroup != root_mem_cgroup) {
> +		struct lruvec *lruvec = NULL;
> +
> +		if (page_count(page))
> +			lruvec = page_lock_lruvec(page);
> +		if (!PageLRU(page))
> +			pc->mem_cgroup = root_mem_cgroup;
> +		if (lruvec)
> +			unlock_lruvec(lruvec);
> +	}

Hmm. ok, isoalte_lru_page() at el take care of all problems if PageLRU()==true,
right ?

I wonder which is better to delay freeing lruvec or this locking scheme...

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
