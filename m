Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id BAB936B00DB
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 14:09:43 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH 00/10] memcg: per cgroup dirty page accounting
References: <1286175485-30643-1-git-send-email-gthelen@google.com>
	<20101018145636.806446aa.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 18 Oct 2010 11:09:26 -0700
In-Reply-To: <20101018145636.806446aa.kamezawa.hiroyu@jp.fujitsu.com>
	(KAMEZAWA Hiroyuki's message of "Mon, 18 Oct 2010 14:56:36 +0900")
Message-ID: <xr93d3r79xux.fsf@ninji.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:

> On Sun,  3 Oct 2010 23:57:55 -0700
> Greg Thelen <gthelen@google.com> wrote:
>
>> Greg Thelen (10):
>>   memcg: add page_cgroup flags for dirty page tracking
>>   memcg: document cgroup dirty memory interfaces
>>   memcg: create extensible page stat update routines
>>   memcg: disable local interrupts in lock_page_cgroup()
>>   memcg: add dirty page accounting infrastructure
>>   memcg: add kernel calls for memcg dirty page stats
>>   memcg: add dirty limits to mem_cgroup
>>   memcg: add cgroupfs interface to memcg dirty limits
>>   writeback: make determine_dirtyable_memory() static.
>>   memcg: check memcg dirty limits in page writeback
>
> Greg, this is a patch on your set.
>
>  mmotm-1014 
>  - memcg-reduce-lock-hold-time-during-charge-moving.patch
>    (I asked Andrew to drop this)
>  + your 1,2,3,5,6,7,8,9,10 (dropped patch "4")
>
> I'm grad if you merge this to your set as replacement of "4".
> I'll prepare a performance improvement patch and post it if this dirty_limit
> patches goes to -mm.

Thanks for the patch.  I will merge your patch (below) as a replacement
of memcg dirty limits patch #4 and repost the entire series.

> Thank you for your work.
>
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> Now, at supporing dirty limit, there is a deadlock problem in accounting.
>
>  1. If pages are being migrated from a memcg, then updates to that
> memcg page statistics are protected by grabbing a bit spin lock
> using lock_page_cgroup().  In recent changes of dirty page accounting
> is updating memcg page accounting (specifically: num writeback pages)
> from IRQ context (softirq).  Avoid a deadlocking nested spin lock attempt
> by irq on the local processor when grabbing the page_cgroup.
>
>  2. lock for update_stat is used only for avoiding race with move_account().
> So, IRQ awareness of lock_page_cgroup() itself is not a problem. The problem
> is in update_stat() and move_account().
>
> Then, this reworks locking scheme of update_stat() and move_account() by
> adding new lock bit PCG_MOVE_LOCK, which is always taken under IRQ disable.
>
> Trade-off
>   * using lock_page_cgroup() + disable IRQ has some impacts on performance
>     and I think it's bad to disable IRQ when it's not necessary.
>   * adding a new lock makes move_account() slow. Score is here.
>
> Peformance Impact: moving a 8G anon process.
>
> Before:
> 	real    0m0.792s
> 	user    0m0.000s
> 	sys     0m0.780s
>
> After:
> 	real    0m0.854s
> 	user    0m0.000s
> 	sys     0m0.842s
>
> This score is bad but planned patches for optimization can reduce
> this impact.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/page_cgroup.h |   31 ++++++++++++++++++++++++++++---
>  mm/memcontrol.c             |    9 +++++++--
>  2 files changed, 35 insertions(+), 5 deletions(-)
>
> Index: dirty_limit_new/include/linux/page_cgroup.h
> ===================================================================
> --- dirty_limit_new.orig/include/linux/page_cgroup.h
> +++ dirty_limit_new/include/linux/page_cgroup.h
> @@ -35,15 +35,18 @@ struct page_cgroup *lookup_page_cgroup(s
>  
>  enum {
>  	/* flags for mem_cgroup */
> -	PCG_LOCK,  /* page cgroup is locked */
> +	PCG_LOCK,  /* Lock for pc->mem_cgroup and following bits. */
>  	PCG_CACHE, /* charged as cache */
>  	PCG_USED, /* this object is in use. */
> -	PCG_ACCT_LRU, /* page has been accounted for */
> +	PCG_MIGRATION, /* under page migration */
> +	/* flags for mem_cgroup and file and I/O status */
> +	PCG_MOVE_LOCK, /* For race between move_account v.s. following bits */
>  	PCG_FILE_MAPPED, /* page is accounted as "mapped" */
>  	PCG_FILE_DIRTY, /* page is dirty */
>  	PCG_FILE_WRITEBACK, /* page is under writeback */
>  	PCG_FILE_UNSTABLE_NFS, /* page is NFS unstable */
> -	PCG_MIGRATION, /* under page migration */
> +	/* No lock in page_cgroup */
> +	PCG_ACCT_LRU, /* page has been accounted for (under lru_lock) */
>  };
>  
>  #define TESTPCGFLAG(uname, lname)			\
> @@ -119,6 +122,10 @@ static inline enum zone_type page_cgroup
>  
>  static inline void lock_page_cgroup(struct page_cgroup *pc)
>  {
> +	/*
> +	 * Don't take this lock in IRQ context.
> +	 * This lock is for pc->mem_cgroup, USED, CACHE, MIGRATION
> +	 */
>  	bit_spin_lock(PCG_LOCK, &pc->flags);
>  }
>  
> @@ -127,6 +134,24 @@ static inline void unlock_page_cgroup(st
>  	bit_spin_unlock(PCG_LOCK, &pc->flags);
>  }
>  
> +static inline void move_lock_page_cgroup(struct page_cgroup *pc,
> +	unsigned long *flags)
> +{
> +	/*
> +	 * We know updates to pc->flags of page cache's stats are from both of
> +	 * usual context or IRQ context. Disable IRQ to avoid deadlock.
> +	 */
> +	local_irq_save(*flags);
> +	bit_spin_lock(PCG_MOVE_LOCK, &pc->flags);
> +}
> +
> +static inline void move_unlock_page_cgroup(struct page_cgroup *pc,
> +	unsigned long *flags)
> +{
> +	bit_spin_unlock(PCG_MOVE_LOCK, &pc->flags);
> +	local_irq_restore(*flags);
> +}
> +
>  #else /* CONFIG_CGROUP_MEM_RES_CTLR */
>  struct page_cgroup;
>  
> Index: dirty_limit_new/mm/memcontrol.c
> ===================================================================
> --- dirty_limit_new.orig/mm/memcontrol.c
> +++ dirty_limit_new/mm/memcontrol.c
> @@ -1784,6 +1784,7 @@ void mem_cgroup_update_page_stat(struct 
>  	struct mem_cgroup *mem;
>  	struct page_cgroup *pc = lookup_page_cgroup(page);
>  	bool need_unlock = false;
> +	unsigned long uninitialized_var(flags);
>  
>  	if (unlikely(!pc))
>  		return;
> @@ -1795,7 +1796,7 @@ void mem_cgroup_update_page_stat(struct 
>  	/* pc->mem_cgroup is unstable ? */
>  	if (unlikely(mem_cgroup_stealed(mem))) {
>  		/* take a lock against to access pc->mem_cgroup */
> -		lock_page_cgroup(pc);
> +		move_lock_page_cgroup(pc, &flags);
>  		need_unlock = true;
>  		mem = pc->mem_cgroup;
>  		if (!mem || !PageCgroupUsed(pc))
> @@ -1856,7 +1857,7 @@ void mem_cgroup_update_page_stat(struct 
>  
>  out:
>  	if (unlikely(need_unlock))
> -		unlock_page_cgroup(pc);
> +		move_unlock_page_cgroup(pc, &flags);
>  	rcu_read_unlock();
>  	return;
>  }
> @@ -2426,9 +2427,13 @@ static int mem_cgroup_move_account(struc
>  		struct mem_cgroup *from, struct mem_cgroup *to, bool uncharge)
>  {
>  	int ret = -EINVAL;
> +	unsigned long flags;
> +
>  	lock_page_cgroup(pc);
>  	if (PageCgroupUsed(pc) && pc->mem_cgroup == from) {
> +		move_lock_page_cgroup(pc, &flags);
>  		__mem_cgroup_move_account(pc, from, to, uncharge);
> +		move_unlock_page_cgroup(pc, &flags);
>  		ret = 0;
>  	}
>  	unlock_page_cgroup(pc);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
