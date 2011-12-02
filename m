Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7157B6B0047
	for <linux-mm@kvack.org>; Fri,  2 Dec 2011 07:09:02 -0500 (EST)
Date: Fri, 2 Dec 2011 13:08:49 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC][PATCH] memcg: remove PCG_ACCT_LRU.
Message-ID: <20111202120849.GA1295@cmpxchg.org>
References: <20111202190622.8e0488d6.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111202190622.8e0488d6.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cgroups@vger.kernel.org

On Fri, Dec 02, 2011 at 07:06:22PM +0900, KAMEZAWA Hiroyuki wrote:
> I'm now testing this patch, removing PCG_ACCT_LRU, onto mmotm.
> How do you think ?

> @@ -1024,18 +1026,8 @@ void mem_cgroup_lru_del_list(struct page *page, enum lru_list lru)
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
> +	memcg = pc->mem_cgroup ? pc->mem_cgroup : root_mem_cgroup;
> +	VM_BUG_ON(memcg != pc->mem_cgroup_lru);
>  	mz = page_cgroup_zoneinfo(memcg, page);
>  	/* huge page split is done under lru_lock. so, we have no races. */
>  	MEM_CGROUP_ZSTAT(mz, lru) -= 1 << compound_order(page);

Nobody clears pc->mem_cgroup upon uncharge, so this may end up
mistakenly lru-unaccount a page that was never charged against the
stale pc->mem_cgroup (e.g. a swap readahead page that has not been
charged yet gets isolated by reclaim).

On the other hand, pages that were uncharged just before the lru_del
MUST be lru-unaccounted against pc->mem_cgroup.

PageCgroupAcctLRU made it possible to tell those two scenarios apart.

A possible solution could be to clear pc->mem_cgroup when the page is
finally freed so that only pages that have been charged since their
last allocation have pc->mem_cgroup set.  But this means that the page
freeing hotpath will have to grow a lookup_page_cgroup(), amortizing
the winnings at least to some extent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
