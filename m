Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 711196B0047
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 03:18:58 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH 04/10] memcg: disable local interrupts in lock_page_cgroup()
References: <1286175485-30643-1-git-send-email-gthelen@google.com>
	<1286175485-30643-5-git-send-email-gthelen@google.com>
	<20101005155417.d9552689.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 05 Oct 2010 00:18:44 -0700
In-Reply-To: <20101005155417.d9552689.kamezawa.hiroyu@jp.fujitsu.com>
	(KAMEZAWA Hiroyuki's message of "Tue, 5 Oct 2010 15:54:17 +0900")
Message-ID: <xr9339slxg2z.fsf@ninji.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:

> On Sun,  3 Oct 2010 23:57:59 -0700
> Greg Thelen <gthelen@google.com> wrote:
>
>> If pages are being migrated from a memcg, then updates to that
>> memcg's page statistics are protected by grabbing a bit spin lock
>> using lock_page_cgroup().  In an upcoming commit memcg dirty page
>> accounting will be updating memcg page accounting (specifically:
>> num writeback pages) from softirq.  Avoid a deadlocking nested
>> spin lock attempt by disabling interrupts on the local processor
>> when grabbing the page_cgroup bit_spin_lock in lock_page_cgroup().
>> This avoids the following deadlock:
>> statistic
>>       CPU 0             CPU 1
>>                     inc_file_mapped
>>                     rcu_read_lock
>>   start move
>>   synchronize_rcu
>>                     lock_page_cgroup
>>                       softirq
>>                       test_clear_page_writeback
>>                       mem_cgroup_dec_page_stat(NR_WRITEBACK)
>>                       rcu_read_lock
>>                       lock_page_cgroup   /* deadlock */
>>                       unlock_page_cgroup
>>                       rcu_read_unlock
>>                     unlock_page_cgroup
>>                     rcu_read_unlock
>> 
>> By disabling interrupts in lock_page_cgroup, nested calls
>> are avoided.  The softirq would be delayed until after inc_file_mapped
>> enables interrupts when calling unlock_page_cgroup().
>> 
>> The normal, fast path, of memcg page stat updates typically
>> does not need to call lock_page_cgroup(), so this change does
>> not affect the performance of the common case page accounting.
>> 
>> Signed-off-by: Andrea Righi <arighi@develer.com>
>> Signed-off-by: Greg Thelen <gthelen@google.com>
>
> Nice Catch!
>
> But..hmm this wasn't necessary for FILE_MAPPED but necesary for new
> statistics, right ? (This affects the order of patches.)

This patch (disabling interrupts) is not needed until later patches (in
this series) update memcg statistics from softirq.  If we only had
FILE_MAPPED, then this patch would not be needed.  I placed this patch
before the following dependent patches that need it.  The opposite order
seemed wrong because it would introduce the possibility of the deadlock
until this patch was applied.  By having this patch come first there
should be no way to apply the series in order and see the mentioned
deadlock.

> Anyway
>
> Acked-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
>
>> ---
>>  include/linux/page_cgroup.h |    8 +++++-
>>  mm/memcontrol.c             |   51 +++++++++++++++++++++++++-----------------
>>  2 files changed, 36 insertions(+), 23 deletions(-)
>> 
>> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
>> index b59c298..872f6b1 100644
>> --- a/include/linux/page_cgroup.h
>> +++ b/include/linux/page_cgroup.h
>> @@ -117,14 +117,18 @@ static inline enum zone_type page_cgroup_zid(struct page_cgroup *pc)
>>  	return page_zonenum(pc->page);
>>  }
>>  
>> -static inline void lock_page_cgroup(struct page_cgroup *pc)
>> +static inline void lock_page_cgroup(struct page_cgroup *pc,
>> +				    unsigned long *flags)
>>  {
>> +	local_irq_save(*flags);
>>  	bit_spin_lock(PCG_LOCK, &pc->flags);
>>  }
>>  
>> -static inline void unlock_page_cgroup(struct page_cgroup *pc)
>> +static inline void unlock_page_cgroup(struct page_cgroup *pc,
>> +				      unsigned long flags)
>>  {
>>  	bit_spin_unlock(PCG_LOCK, &pc->flags);
>> +	local_irq_restore(flags);
>>  }
>>  
>>  #else /* CONFIG_CGROUP_MEM_RES_CTLR */
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index f4259f4..267d774 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -1599,6 +1599,7 @@ void mem_cgroup_update_page_stat(struct page *page,
>>  	struct mem_cgroup *mem;
>>  	struct page_cgroup *pc = lookup_page_cgroup(page);
>>  	bool need_unlock = false;
>> +	unsigned long flags;
>>  
>>  	if (unlikely(!pc))
>>  		return;
>> @@ -1610,7 +1611,7 @@ void mem_cgroup_update_page_stat(struct page *page,
>>  	/* pc->mem_cgroup is unstable ? */
>>  	if (unlikely(mem_cgroup_stealed(mem))) {
>>  		/* take a lock against to access pc->mem_cgroup */
>> -		lock_page_cgroup(pc);
>> +		lock_page_cgroup(pc, &flags);
>>  		need_unlock = true;
>>  		mem = pc->mem_cgroup;
>>  		if (!mem || !PageCgroupUsed(pc))
>> @@ -1633,7 +1634,7 @@ void mem_cgroup_update_page_stat(struct page *page,
>>  
>>  out:
>>  	if (unlikely(need_unlock))
>> -		unlock_page_cgroup(pc);
>> +		unlock_page_cgroup(pc, flags);
>>  	rcu_read_unlock();
>>  	return;
>>  }
>> @@ -2053,11 +2054,12 @@ struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
>>  	struct page_cgroup *pc;
>>  	unsigned short id;
>>  	swp_entry_t ent;
>> +	unsigned long flags;
>>  
>>  	VM_BUG_ON(!PageLocked(page));
>>  
>>  	pc = lookup_page_cgroup(page);
>> -	lock_page_cgroup(pc);
>> +	lock_page_cgroup(pc, &flags);
>>  	if (PageCgroupUsed(pc)) {
>>  		mem = pc->mem_cgroup;
>>  		if (mem && !css_tryget(&mem->css))
>> @@ -2071,7 +2073,7 @@ struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
>>  			mem = NULL;
>>  		rcu_read_unlock();
>>  	}
>> -	unlock_page_cgroup(pc);
>> +	unlock_page_cgroup(pc, flags);
>>  	return mem;
>>  }
>>  
>> @@ -2084,13 +2086,15 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
>>  				     struct page_cgroup *pc,
>>  				     enum charge_type ctype)
>>  {
>> +	unsigned long flags;
>> +
>>  	/* try_charge() can return NULL to *memcg, taking care of it. */
>>  	if (!mem)
>>  		return;
>>  
>> -	lock_page_cgroup(pc);
>> +	lock_page_cgroup(pc, &flags);
>>  	if (unlikely(PageCgroupUsed(pc))) {
>> -		unlock_page_cgroup(pc);
>> +		unlock_page_cgroup(pc, flags);
>>  		mem_cgroup_cancel_charge(mem);
>>  		return;
>>  	}
>> @@ -2120,7 +2124,7 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
>>  
>>  	mem_cgroup_charge_statistics(mem, pc, true);
>>  
>> -	unlock_page_cgroup(pc);
>> +	unlock_page_cgroup(pc, flags);
>>  	/*
>>  	 * "charge_statistics" updated event counter. Then, check it.
>>  	 * Insert ancestor (and ancestor's ancestors), to softlimit RB-tree.
>> @@ -2187,12 +2191,13 @@ static int mem_cgroup_move_account(struct page_cgroup *pc,
>>  		struct mem_cgroup *from, struct mem_cgroup *to, bool uncharge)
>>  {
>>  	int ret = -EINVAL;
>> -	lock_page_cgroup(pc);
>> +	unsigned long flags;
>> +	lock_page_cgroup(pc, &flags);
>>  	if (PageCgroupUsed(pc) && pc->mem_cgroup == from) {
>>  		__mem_cgroup_move_account(pc, from, to, uncharge);
>>  		ret = 0;
>>  	}
>> -	unlock_page_cgroup(pc);
>> +	unlock_page_cgroup(pc, flags);
>>  	/*
>>  	 * check events
>>  	 */
>> @@ -2298,6 +2303,7 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
>>  				gfp_t gfp_mask)
>>  {
>>  	int ret;
>> +	unsigned long flags;
>>  
>>  	if (mem_cgroup_disabled())
>>  		return 0;
>> @@ -2320,12 +2326,12 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
>>  		pc = lookup_page_cgroup(page);
>>  		if (!pc)
>>  			return 0;
>> -		lock_page_cgroup(pc);
>> +		lock_page_cgroup(pc, &flags);
>>  		if (PageCgroupUsed(pc)) {
>> -			unlock_page_cgroup(pc);
>> +			unlock_page_cgroup(pc, flags);
>>  			return 0;
>>  		}
>> -		unlock_page_cgroup(pc);
>> +		unlock_page_cgroup(pc, flags);
>>  	}
>>  
>>  	if (unlikely(!mm))
>> @@ -2511,6 +2517,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
>>  {
>>  	struct page_cgroup *pc;
>>  	struct mem_cgroup *mem = NULL;
>> +	unsigned long flags;
>>  
>>  	if (mem_cgroup_disabled())
>>  		return NULL;
>> @@ -2525,7 +2532,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
>>  	if (unlikely(!pc || !PageCgroupUsed(pc)))
>>  		return NULL;
>>  
>> -	lock_page_cgroup(pc);
>> +	lock_page_cgroup(pc, &flags);
>>  
>>  	mem = pc->mem_cgroup;
>>  
>> @@ -2560,7 +2567,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
>>  	 * special functions.
>>  	 */
>>  
>> -	unlock_page_cgroup(pc);
>> +	unlock_page_cgroup(pc, flags);
>>  	/*
>>  	 * even after unlock, we have mem->res.usage here and this memcg
>>  	 * will never be freed.
>> @@ -2576,7 +2583,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
>>  	return mem;
>>  
>>  unlock_out:
>> -	unlock_page_cgroup(pc);
>> +	unlock_page_cgroup(pc, flags);
>>  	return NULL;
>>  }
>>  
>> @@ -2765,12 +2772,13 @@ int mem_cgroup_prepare_migration(struct page *page,
>>  	struct mem_cgroup *mem = NULL;
>>  	enum charge_type ctype;
>>  	int ret = 0;
>> +	unsigned long flags;
>>  
>>  	if (mem_cgroup_disabled())
>>  		return 0;
>>  
>>  	pc = lookup_page_cgroup(page);
>> -	lock_page_cgroup(pc);
>> +	lock_page_cgroup(pc, &flags);
>>  	if (PageCgroupUsed(pc)) {
>>  		mem = pc->mem_cgroup;
>>  		css_get(&mem->css);
>> @@ -2806,7 +2814,7 @@ int mem_cgroup_prepare_migration(struct page *page,
>>  		if (PageAnon(page))
>>  			SetPageCgroupMigration(pc);
>>  	}
>> -	unlock_page_cgroup(pc);
>> +	unlock_page_cgroup(pc, flags);
>>  	/*
>>  	 * If the page is not charged at this point,
>>  	 * we return here.
>> @@ -2819,9 +2827,9 @@ int mem_cgroup_prepare_migration(struct page *page,
>>  	css_put(&mem->css);/* drop extra refcnt */
>>  	if (ret || *ptr == NULL) {
>>  		if (PageAnon(page)) {
>> -			lock_page_cgroup(pc);
>> +			lock_page_cgroup(pc, &flags);
>>  			ClearPageCgroupMigration(pc);
>> -			unlock_page_cgroup(pc);
>> +			unlock_page_cgroup(pc, flags);
>>  			/*
>>  			 * The old page may be fully unmapped while we kept it.
>>  			 */
>> @@ -2852,6 +2860,7 @@ void mem_cgroup_end_migration(struct mem_cgroup *mem,
>>  {
>>  	struct page *used, *unused;
>>  	struct page_cgroup *pc;
>> +	unsigned long flags;
>>  
>>  	if (!mem)
>>  		return;
>> @@ -2871,9 +2880,9 @@ void mem_cgroup_end_migration(struct mem_cgroup *mem,
>>  	 * Clear the flag and check the page should be charged.
>>  	 */
>>  	pc = lookup_page_cgroup(oldpage);
>> -	lock_page_cgroup(pc);
>> +	lock_page_cgroup(pc, &flags);
>>  	ClearPageCgroupMigration(pc);
>> -	unlock_page_cgroup(pc);
>> +	unlock_page_cgroup(pc, flags);
>>  
>>  	__mem_cgroup_uncharge_common(unused, MEM_CGROUP_CHARGE_TYPE_FORCE);
>>  
>> -- 
>> 1.7.1
>> 
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>> 
>> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
