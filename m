Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 11FF26B0095
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 23:43:53 -0400 (EDT)
Date: Tue, 21 Apr 2009 20:41:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memcg: remove trylock_page_cgroup
Message-Id: <20090421204104.faf9fc56.akpm@linux-foundation.org>
In-Reply-To: <20090422121641.eb84a07e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090416120316.GG7082@balbir.in.ibm.com>
	<20090417091459.dac2cc39.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417014042.GB18558@balbir.in.ibm.com>
	<20090417110350.3144183d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417034539.GD18558@balbir.in.ibm.com>
	<20090417124951.a8472c86.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417045623.GA3896@balbir.in.ibm.com>
	<20090417141726.a69ebdcc.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417064726.GB3896@balbir.in.ibm.com>
	<20090417155608.eeed1f02.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417141837.GD3896@balbir.in.ibm.com>
	<20090421132551.38e9960a.akpm@linux-foundation.org>
	<20090422090218.6d451a08.kamezawa.hiroyu@jp.fujitsu.com>
	<20090422121641.eb84a07e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 22 Apr 2009 12:16:41 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> How about this ? worth to be tested, I think.
> -Kame
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Before synchronized-LRU patch, mem cgroup had its own LRU lock.
> And there was a code which does
> # assume mz as per zone struct of memcg. 
> 
>    spin_lock mz->lru_lock
> 	lock_page_cgroup(pc).
>    and
>    lock_page_cgroup(pc)
> 	spin_lock mz->lru_lock
> 
> because we cannot locate "mz" until we see pc->page_cgroup, we used
> trylock(). But now, we don't have mz->lru_lock. All cgroup
> uses zone->lru_lock for handling list. Moreover, manipulation of
> LRU depends on global LRU now and we can isolate page from LRU by
> very generic way.(isolate_lru_page()).
> So, this kind of trylock is not necessary now.
> 
> I thought I removed all trylock in synchronized-LRU patch but there
> is still one. This patch removes trylock used in memcontrol.c and
> its definition. If someone needs, he should add this again with enough
> reason.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/page_cgroup.h |    5 -----
>  mm/memcontrol.c             |    3 +--
>  2 files changed, 1 insertion(+), 7 deletions(-)
> 
> Index: mmotm-2.6.30-Apr21/include/linux/page_cgroup.h
> ===================================================================
> --- mmotm-2.6.30-Apr21.orig/include/linux/page_cgroup.h
> +++ mmotm-2.6.30-Apr21/include/linux/page_cgroup.h
> @@ -61,11 +61,6 @@ static inline void lock_page_cgroup(stru
>  	bit_spin_lock(PCG_LOCK, &pc->flags);
>  }
>  
> -static inline int trylock_page_cgroup(struct page_cgroup *pc)
> -{
> -	return bit_spin_trylock(PCG_LOCK, &pc->flags);
> -}
> -
>  static inline void unlock_page_cgroup(struct page_cgroup *pc)
>  {
>  	bit_spin_unlock(PCG_LOCK, &pc->flags);
> Index: mmotm-2.6.30-Apr21/mm/memcontrol.c
> ===================================================================
> --- mmotm-2.6.30-Apr21.orig/mm/memcontrol.c
> +++ mmotm-2.6.30-Apr21/mm/memcontrol.c
> @@ -1148,8 +1148,7 @@ static int mem_cgroup_move_account(struc
>  	from_mz =  mem_cgroup_zoneinfo(from, nid, zid);
>  	to_mz =  mem_cgroup_zoneinfo(to, nid, zid);
>  
> -	if (!trylock_page_cgroup(pc))
> -		return ret;
> +	lock_page_cgroup(pc);
>  
>  	if (!PageCgroupUsed(pc))
>  		goto out;

But we can't remove that nasty `while (loop--)' thing?

I expect that it will reliably fail if the caller is running as
SCHED_FIFO and the machine is single-CPU, or if we're trying to yield
to a SCHED_OTHER task which is pinned to this CPU, etc.  The cond_resched()
won't work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
