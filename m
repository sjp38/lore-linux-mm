Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 80B576B00A5
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 21:11:09 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o292B6iA013685
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 9 Mar 2010 11:11:06 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id EBD3C45DE55
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 11:11:05 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C1E4645DE52
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 11:11:05 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A618CE18006
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 11:11:05 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4ABD4E18001
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 11:11:05 +0900 (JST)
Date: Tue, 9 Mar 2010 11:07:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH mmotm 2.5/4] memcg: disable irq at page cgroup lock (Re:
 [PATCH -mmotm 3/4] memcg: dirty pages accounting and limiting
 infrastructure)
Message-Id: <20100309110722.6e0490f6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100309102928.9f36d2bb.nishimura@mxp.nes.nec.co.jp>
References: <1267995474-9117-1-git-send-email-arighi@develer.com>
	<1267995474-9117-4-git-send-email-arighi@develer.com>
	<20100308104447.c124c1ff.nishimura@mxp.nes.nec.co.jp>
	<20100308105641.e2e714f4.kamezawa.hiroyu@jp.fujitsu.com>
	<20100308111724.3e48aee3.nishimura@mxp.nes.nec.co.jp>
	<20100308113711.d7a249da.kamezawa.hiroyu@jp.fujitsu.com>
	<20100308170711.4d8b02f0.nishimura@mxp.nes.nec.co.jp>
	<20100308173100.b5997fd4.kamezawa.hiroyu@jp.fujitsu.com>
	<20100309001252.GB13490@linux>
	<20100309091914.4b5f6661.kamezawa.hiroyu@jp.fujitsu.com>
	<20100309102928.9f36d2bb.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Vivek Goyal <vgoyal@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 9 Mar 2010 10:29:28 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > please go ahead in this direction. Nishimura-san, would you post an
> > independent patch ? If no, Andrea-san, please.
> > 
> This is the updated version.
> 
> Andrea-san, can you merge this into your patch set ?
> 
> ===
> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> In current implementation, we don't have to disable irq at lock_page_cgroup()
> because the lock is never acquired in interrupt context.
> But we are going to call it in later patch in an interrupt context or with
> irq disabled, so this patch disables irq at lock_page_cgroup() and enables it
> at unlock_page_cgroup().
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



> ---
>  include/linux/page_cgroup.h |   16 ++++++++++++++--
>  mm/memcontrol.c             |   43 +++++++++++++++++++++++++------------------
>  2 files changed, 39 insertions(+), 20 deletions(-)
> 
> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> index 30b0813..0d2f92c 100644
> --- a/include/linux/page_cgroup.h
> +++ b/include/linux/page_cgroup.h
> @@ -83,16 +83,28 @@ static inline enum zone_type page_cgroup_zid(struct page_cgroup *pc)
>  	return page_zonenum(pc->page);
>  }
>  
> -static inline void lock_page_cgroup(struct page_cgroup *pc)
> +static inline void __lock_page_cgroup(struct page_cgroup *pc)
>  {
>  	bit_spin_lock(PCG_LOCK, &pc->flags);
>  }
>  
> -static inline void unlock_page_cgroup(struct page_cgroup *pc)
> +static inline void __unlock_page_cgroup(struct page_cgroup *pc)
>  {
>  	bit_spin_unlock(PCG_LOCK, &pc->flags);
>  }
>  
> +#define lock_page_cgroup(pc, flags)		\
> +	do {					\
> +		local_irq_save(flags);		\
> +		__lock_page_cgroup(pc);		\
> +	} while (0)
> +
> +#define unlock_page_cgroup(pc, flags)		\
> +	do {					\
> +		__unlock_page_cgroup(pc);	\
> +		local_irq_restore(flags);	\
> +	} while (0)
> +
>  #else /* CONFIG_CGROUP_MEM_RES_CTLR */
>  struct page_cgroup;
>  
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 7fab84e..a9fd736 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1352,12 +1352,13 @@ void mem_cgroup_update_file_mapped(struct page *page, int val)
>  {
>  	struct mem_cgroup *mem;
>  	struct page_cgroup *pc;
> +	unsigned long flags;
>  
>  	pc = lookup_page_cgroup(page);
>  	if (unlikely(!pc))
>  		return;
>  
> -	lock_page_cgroup(pc);
> +	lock_page_cgroup(pc, flags);
>  	mem = pc->mem_cgroup;
>  	if (!mem)
>  		goto done;
> @@ -1371,7 +1372,7 @@ void mem_cgroup_update_file_mapped(struct page *page, int val)
>  	__this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED], val);
>  
>  done:
> -	unlock_page_cgroup(pc);
> +	unlock_page_cgroup(pc, flags);
>  }
>  
>  /*
> @@ -1705,11 +1706,12 @@ struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
>  	struct page_cgroup *pc;
>  	unsigned short id;
>  	swp_entry_t ent;
> +	unsigned long flags;
>  
>  	VM_BUG_ON(!PageLocked(page));
>  
>  	pc = lookup_page_cgroup(page);
> -	lock_page_cgroup(pc);
> +	lock_page_cgroup(pc, flags);
>  	if (PageCgroupUsed(pc)) {
>  		mem = pc->mem_cgroup;
>  		if (mem && !css_tryget(&mem->css))
> @@ -1723,7 +1725,7 @@ struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
>  			mem = NULL;
>  		rcu_read_unlock();
>  	}
> -	unlock_page_cgroup(pc);
> +	unlock_page_cgroup(pc, flags);
>  	return mem;
>  }
>  
> @@ -1736,13 +1738,15 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
>  				     struct page_cgroup *pc,
>  				     enum charge_type ctype)
>  {
> +	unsigned long flags;
> +
>  	/* try_charge() can return NULL to *memcg, taking care of it. */
>  	if (!mem)
>  		return;
>  
> -	lock_page_cgroup(pc);
> +	lock_page_cgroup(pc, flags);
>  	if (unlikely(PageCgroupUsed(pc))) {
> -		unlock_page_cgroup(pc);
> +		unlock_page_cgroup(pc, flags);
>  		mem_cgroup_cancel_charge(mem);
>  		return;
>  	}
> @@ -1772,7 +1776,7 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
>  
>  	mem_cgroup_charge_statistics(mem, pc, true);
>  
> -	unlock_page_cgroup(pc);
> +	unlock_page_cgroup(pc, flags);
>  	/*
>  	 * "charge_statistics" updated event counter. Then, check it.
>  	 * Insert ancestor (and ancestor's ancestors), to softlimit RB-tree.
> @@ -1842,12 +1846,13 @@ static int mem_cgroup_move_account(struct page_cgroup *pc,
>  		struct mem_cgroup *from, struct mem_cgroup *to, bool uncharge)
>  {
>  	int ret = -EINVAL;
> -	lock_page_cgroup(pc);
> +	unsigned long flags;
> +	lock_page_cgroup(pc, flags);
>  	if (PageCgroupUsed(pc) && pc->mem_cgroup == from) {
>  		__mem_cgroup_move_account(pc, from, to, uncharge);
>  		ret = 0;
>  	}
> -	unlock_page_cgroup(pc);
> +	unlock_page_cgroup(pc, flags);
>  	/*
>  	 * check events
>  	 */
> @@ -1974,17 +1979,17 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
>  	 */
>  	if (!(gfp_mask & __GFP_WAIT)) {
>  		struct page_cgroup *pc;
> -
> +		unsigned long flags;
>  
>  		pc = lookup_page_cgroup(page);
>  		if (!pc)
>  			return 0;
> -		lock_page_cgroup(pc);
> +		lock_page_cgroup(pc, flags);
>  		if (PageCgroupUsed(pc)) {
> -			unlock_page_cgroup(pc);
> +			unlock_page_cgroup(pc, flags);
>  			return 0;
>  		}
> -		unlock_page_cgroup(pc);
> +		unlock_page_cgroup(pc, flags);
>  	}
>  
>  	if (unlikely(!mm && !mem))
> @@ -2166,6 +2171,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
>  	struct page_cgroup *pc;
>  	struct mem_cgroup *mem = NULL;
>  	struct mem_cgroup_per_zone *mz;
> +	unsigned long flags;
>  
>  	if (mem_cgroup_disabled())
>  		return NULL;
> @@ -2180,7 +2186,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
>  	if (unlikely(!pc || !PageCgroupUsed(pc)))
>  		return NULL;
>  
> -	lock_page_cgroup(pc);
> +	lock_page_cgroup(pc, flags);
>  
>  	mem = pc->mem_cgroup;
>  
> @@ -2219,7 +2225,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
>  	 */
>  
>  	mz = page_cgroup_zoneinfo(pc);
> -	unlock_page_cgroup(pc);
> +	unlock_page_cgroup(pc, flags);
>  
>  	memcg_check_events(mem, page);
>  	/* at swapout, this memcg will be accessed to record to swap */
> @@ -2229,7 +2235,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
>  	return mem;
>  
>  unlock_out:
> -	unlock_page_cgroup(pc);
> +	unlock_page_cgroup(pc, flags);
>  	return NULL;
>  }
>  
> @@ -2417,17 +2423,18 @@ int mem_cgroup_prepare_migration(struct page *page, struct mem_cgroup **ptr)
>  	struct page_cgroup *pc;
>  	struct mem_cgroup *mem = NULL;
>  	int ret = 0;
> +	unsigned long flags;
>  
>  	if (mem_cgroup_disabled())
>  		return 0;
>  
>  	pc = lookup_page_cgroup(page);
> -	lock_page_cgroup(pc);
> +	lock_page_cgroup(pc, flags);
>  	if (PageCgroupUsed(pc)) {
>  		mem = pc->mem_cgroup;
>  		css_get(&mem->css);
>  	}
> -	unlock_page_cgroup(pc);
> +	unlock_page_cgroup(pc, flags);
>  
>  	if (mem) {
>  		ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem, false);
> -- 
> 1.6.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
