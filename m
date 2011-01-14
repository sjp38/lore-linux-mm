Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D538D6B0092
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 07:21:39 -0500 (EST)
Date: Fri, 14 Jan 2011 13:21:31 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 4/4] [BUGFIX] fix account leak at force_empty, rmdir with
 THP
Message-ID: <20110114122131.GR23189@cmpxchg.org>
References: <20110114190412.73362cd7.kamezawa.hiroyu@jp.fujitsu.com>
 <20110114191535.309b634c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110114191535.309b634c.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Greg Thelen <gthelen@google.com>, aarcange@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 14, 2011 at 07:15:35PM +0900, KAMEZAWA Hiroyuki wrote:
> 
> Now, when THP is enabled, memcg's rmdir() function is broken
> because move_account() for THP page is not supported.
> 
> This will cause account leak or -EBUSY issue at rmdir().
> This patch fixes the issue by supporting move_account() THP pages.
> 
> And account information will be moved to its parent at rmdir().
> 
> How to test:
>    79  mount -t cgroup none /cgroup/memory/ -o memory
>    80  mkdir /cgroup/A/
>    81  mkdir /cgroup/memory/A
>    82  mkdir /cgroup/memory/A/B
>    83  cgexec -g memory:A/B ./malloc 128 &
>    84  grep anon /cgroup/memory/A/B/memory.stat
>    85  grep rss /cgroup/memory/A/B/memory.stat
>    86  echo 1728 > /cgroup/memory/A/tasks
>    87  grep rss /cgroup/memory/A/memory.stat
>    88  rmdir /cgroup/memory/A/B/
>    89  grep rss /cgroup/memory/A/memory.stat
> 
> - Create 2 level directory and exec a task calls malloc(big chunk).
> - Move a task somewhere (its parent cgroup in above)
> - rmdir /A/B
> - check memory.stat in /A/B is moved to /A after rmdir. and confirm
>   RSS/LRU information includes usages it was charged against /A/B.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |   32 ++++++++++++++++++++++----------
>  1 file changed, 22 insertions(+), 10 deletions(-)
> 
> Index: mmotm-0107/mm/memcontrol.c
> ===================================================================
> --- mmotm-0107.orig/mm/memcontrol.c
> +++ mmotm-0107/mm/memcontrol.c
> @@ -2154,6 +2154,10 @@ void mem_cgroup_split_huge_fixup(struct 
>  	smp_wmb(); /* see __commit_charge() */
>  	SetPageCgroupUsed(tpc);
>  	VM_BUG_ON(PageCgroupCache(hpc));
> +	/*
> + 	 * Note: if dirty ratio etc..are supported,
> +         * other flags may need to be copied.
> +         */

That's a good comment, but it should be in the patch that introduces
this function and is a bit unrelated in this one.

>  }
>  #endif
>  
> @@ -2175,8 +2179,11 @@ void mem_cgroup_split_huge_fixup(struct 
>   */
>  
>  static void __mem_cgroup_move_account(struct page_cgroup *pc,
> -	struct mem_cgroup *from, struct mem_cgroup *to, bool uncharge)
> +	struct mem_cgroup *from, struct mem_cgroup *to, bool uncharge,
> +	int charge_size)
>  {
> +	int pagenum = charge_size >> PAGE_SHIFT;

nr_pages?

> +
>  	VM_BUG_ON(from == to);
>  	VM_BUG_ON(PageLRU(pc->page));
>  	VM_BUG_ON(!page_is_cgroup_locked(pc));
> @@ -2190,14 +2197,14 @@ static void __mem_cgroup_move_account(st
>  		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
>  		preempt_enable();
>  	}
> -	mem_cgroup_charge_statistics(from, PageCgroupCache(pc), -1);
> +	mem_cgroup_charge_statistics(from, PageCgroupCache(pc), -pagenum);
>  	if (uncharge)
>  		/* This is not "cancel", but cancel_charge does all we need. */
> -		mem_cgroup_cancel_charge(from, PAGE_SIZE);
> +		mem_cgroup_cancel_charge(from, charge_size);
>  
>  	/* caller should have done css_get */
>  	pc->mem_cgroup = to;
> -	mem_cgroup_charge_statistics(to, PageCgroupCache(pc), 1);
> +	mem_cgroup_charge_statistics(to, PageCgroupCache(pc), pagenum);
>  	/*
>  	 * We charges against "to" which may not have any tasks. Then, "to"
>  	 * can be under rmdir(). But in current implementation, caller of
> @@ -2212,7 +2219,8 @@ static void __mem_cgroup_move_account(st
>   * __mem_cgroup_move_account()
>   */
>  static int mem_cgroup_move_account(struct page_cgroup *pc,
> -		struct mem_cgroup *from, struct mem_cgroup *to, bool uncharge)
> +		struct mem_cgroup *from, struct mem_cgroup *to,
> +		bool uncharge, int charge_size)
>  {
>  	int ret = -EINVAL;
>  	unsigned long flags;
> @@ -2220,7 +2228,7 @@ static int mem_cgroup_move_account(struc
>  	lock_page_cgroup(pc);
>  	if (PageCgroupUsed(pc) && pc->mem_cgroup == from) {
>  		move_lock_page_cgroup(pc, &flags);
> -		__mem_cgroup_move_account(pc, from, to, uncharge);
> +		__mem_cgroup_move_account(pc, from, to, uncharge, charge_size);
>  		move_unlock_page_cgroup(pc, &flags);
>  		ret = 0;
>  	}
> @@ -2245,6 +2253,7 @@ static int mem_cgroup_move_parent(struct
>  	struct cgroup *cg = child->css.cgroup;
>  	struct cgroup *pcg = cg->parent;
>  	struct mem_cgroup *parent;
> +	int charge_size = PAGE_SIZE;
>  	int ret;
>  
>  	/* Is ROOT ? */
> @@ -2256,16 +2265,19 @@ static int mem_cgroup_move_parent(struct
>  		goto out;
>  	if (isolate_lru_page(page))
>  		goto put;
> +	/* The page is isolated from LRU and we have no race with splitting */
> +	if (PageTransHuge(page))
> +		charge_size = PAGE_SIZE << compound_order(page);

The same as in the previous patch, compound_order() implicitely
handles order-0 pages and should do the right thing without an extra
check.

The comment is valuable, though!

Nitpicks aside:
Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
