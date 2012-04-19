Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 251DD6B0104
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 21:01:16 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 2E5C03EE0C0
	for <linux-mm@kvack.org>; Thu, 19 Apr 2012 10:01:14 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0379845DE51
	for <linux-mm@kvack.org>; Thu, 19 Apr 2012 10:01:14 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id DEA9D45DE4D
	for <linux-mm@kvack.org>; Thu, 19 Apr 2012 10:01:13 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D2395E08002
	for <linux-mm@kvack.org>; Thu, 19 Apr 2012 10:01:13 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 824C61DB8037
	for <linux-mm@kvack.org>; Thu, 19 Apr 2012 10:01:13 +0900 (JST)
Message-ID: <4F8F6368.2090005@jp.fujitsu.com>
Date: Thu, 19 Apr 2012 09:59:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2] memcg: add mlock statistic in memory.stat
References: <1334773315-32215-1-git-send-email-yinghan@google.com> <20120418163330.ca1518c7.akpm@linux-foundation.org>
In-Reply-To: <20120418163330.ca1518c7.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org

(2012/04/19 8:33), Andrew Morton wrote:

> On Wed, 18 Apr 2012 11:21:55 -0700
> Ying Han <yinghan@google.com> wrote:
> 
>> We have the nr_mlock stat both in meminfo as well as vmstat system wide, this
>> patch adds the mlock field into per-memcg memory stat. The stat itself enhances
>> the metrics exported by memcg since the unevictable lru includes more than
>> mlock()'d page like SHM_LOCK'd.
>>
>> Why we need to count mlock'd pages while they are unevictable and we can not
>> do much on them anyway?
>>
>> This is true. The mlock stat I am proposing is more helpful for system admin
>> and kernel developer to understand the system workload. The same information
>> should be helpful to add into OOM log as well. Many times in the past that we
>> need to read the mlock stat from the per-container meminfo for different
>> reason. Afterall, we do have the ability to read the mlock from meminfo and
>> this patch fills the info in memcg.
>>
>>
>> ...
>>
>>  static inline int is_mlocked_vma(struct vm_area_struct *vma, struct page *page)
>>  {
>> +	bool locked;
>> +	unsigned long flags;
>> +
>>  	VM_BUG_ON(PageLRU(page));
>>  
>>  	if (likely((vma->vm_flags & (VM_LOCKED | VM_SPECIAL)) != VM_LOCKED))
>>  		return 0;
>>  
>> +	mem_cgroup_begin_update_page_stat(page, &locked, &flags);
>>  	if (!TestSetPageMlocked(page)) {
>>  		inc_zone_page_state(page, NR_MLOCK);
>> +		mem_cgroup_inc_page_stat(page, MEMCG_NR_MLOCK);
>>  		count_vm_event(UNEVICTABLE_PGMLOCKED);
>>  	}
>> +	mem_cgroup_end_update_page_stat(page, &locked, &flags);
>> +
>>  	return 1;
>>  }
> 
> Unrelated to this patch: is_mlocked_vma() is misnamed.  A function with
> that name should be a bool-returning test which has no side-effects.
> 
>>
>> ...
>>
>>  static void __free_pages_ok(struct page *page, unsigned int order)
>>  {
>>  	unsigned long flags;
>> -	int wasMlocked = __TestClearPageMlocked(page);
>> +	bool locked;
>>  
>>  	if (!free_pages_prepare(page, order))
>>  		return;
>>  
>>  	local_irq_save(flags);
>> -	if (unlikely(wasMlocked))
>> +	mem_cgroup_begin_update_page_stat(page, &locked, &flags);
> 
> hm, what's going on here.  The page now has a zero refcount and is to
> be returned to the buddy.  But mem_cgroup_begin_update_page_stat()
> assumes that the page still belongs to a memcg.  I'd have thought that
> any page_cgroup backreferences would have been torn down by now?
> 
>> +	if (unlikely(__TestClearPageMlocked(page)))
>>  		free_page_mlock(page);
> 


Ah, this is problem. Now, we have following code.
==

> struct lruvec *mem_cgroup_lru_add_list(struct zone *zone, struct page *page,
>                                        enum lru_list lru)
> {
>         struct mem_cgroup_per_zone *mz;
>         struct mem_cgroup *memcg;
>         struct page_cgroup *pc;
> 
>         if (mem_cgroup_disabled())
>                 return &zone->lruvec;
> 
>         pc = lookup_page_cgroup(page);
>         memcg = pc->mem_cgroup;
> 
>         /*
>          * Surreptitiously switch any uncharged page to root:
>          * an uncharged page off lru does nothing to secure
>          * its former mem_cgroup from sudden removal.
>          *
>          * Our caller holds lru_lock, and PageCgroupUsed is updated
>          * under page_cgroup lock: between them, they make all uses
>          * of pc->mem_cgroup safe.
>          */
>         if (!PageCgroupUsed(pc) && memcg != root_mem_cgroup)
>                 pc->mem_cgroup = memcg = root_mem_cgroup;

==

Then, accessing pc->mem_cgroup without checking PCG_USED bit is dangerous.
It may trigger #GP because of suddern removal of memcg or because of above
code, mis-accounting will happen... pc->mem_cgroup may be overwritten already.

Proposal from me is calling TestClearPageMlocked(page) via mem_cgroup_uncharge().

Like this.
==
        mem_cgroup_charge_statistics(memcg, anon, -nr_pages);

	/*
         * Pages reach here when it's fully unmapped or dropped from file cache.
	 * we are under lock_page_cgroup() and have no race with memcg activities.
         */
	if (unlikely(PageMlocked(page))) {
		if (TestClearPageMlocked())
			decrement counter.
	}

        ClearPageCgroupUsed(pc);
==
But please check performance impact...

Thanks,
-Kame















--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
