Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 2A9AE6B004D
	for <linux-mm@kvack.org>; Thu, 19 Apr 2012 20:40:20 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 411E63EE0BC
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 09:40:18 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 270BE45DE53
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 09:40:18 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D0CD45DE4F
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 09:40:18 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id F0E62E08002
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 09:40:17 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A05021DB8037
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 09:40:17 +0900 (JST)
Message-ID: <4F90AFDE.2000707@jp.fujitsu.com>
Date: Fri, 20 Apr 2012 09:37:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2] memcg: add mlock statistic in memory.stat
References: <1334773315-32215-1-git-send-email-yinghan@google.com> <20120418163330.ca1518c7.akpm@linux-foundation.org> <4F8F6368.2090005@jp.fujitsu.com> <20120419131211.GA1759@cmpxchg.org>
In-Reply-To: <20120419131211.GA1759@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org

(2012/04/19 22:12), Johannes Weiner wrote:

> On Thu, Apr 19, 2012 at 09:59:20AM +0900, KAMEZAWA Hiroyuki wrote:
>> (2012/04/19 8:33), Andrew Morton wrote:
>>
>>> On Wed, 18 Apr 2012 11:21:55 -0700
>>> Ying Han <yinghan@google.com> wrote:
>>>>  static void __free_pages_ok(struct page *page, unsigned int order)
>>>>  {
>>>>  	unsigned long flags;
>>>> -	int wasMlocked = __TestClearPageMlocked(page);
>>>> +	bool locked;
>>>>  
>>>>  	if (!free_pages_prepare(page, order))
>>>>  		return;
>>>>  
>>>>  	local_irq_save(flags);
>>>> -	if (unlikely(wasMlocked))
>>>> +	mem_cgroup_begin_update_page_stat(page, &locked, &flags);
>>>
>>> hm, what's going on here.  The page now has a zero refcount and is to
>>> be returned to the buddy.  But mem_cgroup_begin_update_page_stat()
>>> assumes that the page still belongs to a memcg.  I'd have thought that
>>> any page_cgroup backreferences would have been torn down by now?
>>>
>>>> +	if (unlikely(__TestClearPageMlocked(page)))
>>>>  		free_page_mlock(page);
>>>
>>
>>
>> Ah, this is problem. Now, we have following code.
>> ==
>>
>>> struct lruvec *mem_cgroup_lru_add_list(struct zone *zone, struct page *page,
>>>                                        enum lru_list lru)
>>> {
>>>         struct mem_cgroup_per_zone *mz;
>>>         struct mem_cgroup *memcg;
>>>         struct page_cgroup *pc;
>>>
>>>         if (mem_cgroup_disabled())
>>>                 return &zone->lruvec;
>>>
>>>         pc = lookup_page_cgroup(page);
>>>         memcg = pc->mem_cgroup;
>>>
>>>         /*
>>>          * Surreptitiously switch any uncharged page to root:
>>>          * an uncharged page off lru does nothing to secure
>>>          * its former mem_cgroup from sudden removal.
>>>          *
>>>          * Our caller holds lru_lock, and PageCgroupUsed is updated
>>>          * under page_cgroup lock: between them, they make all uses
>>>          * of pc->mem_cgroup safe.
>>>          */
>>>         if (!PageCgroupUsed(pc) && memcg != root_mem_cgroup)
>>>                 pc->mem_cgroup = memcg = root_mem_cgroup;
>>
>> ==
>>
>> Then, accessing pc->mem_cgroup without checking PCG_USED bit is dangerous.
>> It may trigger #GP because of suddern removal of memcg or because of above
>> code, mis-accounting will happen... pc->mem_cgroup may be overwritten already.
>>
>> Proposal from me is calling TestClearPageMlocked(page) via mem_cgroup_uncharge().
>>
>> Like this.
>> ==
>>         mem_cgroup_charge_statistics(memcg, anon, -nr_pages);
>>
>> 	/*
>>          * Pages reach here when it's fully unmapped or dropped from file cache.
>> 	 * we are under lock_page_cgroup() and have no race with memcg activities.
>>          */
>> 	if (unlikely(PageMlocked(page))) {
>> 		if (TestClearPageMlocked())
>> 			decrement counter.
>> 	}
>>
>>         ClearPageCgroupUsed(pc);
>> ==
>> But please check performance impact...
> 
> This makes the lifetime rules of mlocked anon really weird.
> 

yes.

> Plus this code runs for ALL uncharges, the unlikely() and preliminary
> flag testing don't make it okay.  It's bad that we have this in the
> allocator, but at least it would be good to hook into that branch and
> not add another one.
> 
> pc->mem_cgroup stays intact after the uncharge.  Could we make the
> memcg removal path wait on the mlock counter to drop to zero instead
> and otherwise keep Ying's version?
> 


handling problem in ->destroy() path ? Hmm, it will work against use-after-free.
But accounting problem which may be caused by mem_cgroup_lru_add_list() cannot
be handled, which overwrites pc->mem_cgroup. 

But hm, is this too slow ?...
==
mem_cgroup_uncharge_common()
{
	....
	if (PageSwapCache(page) || PageMlocked(page))
		return NULL;
}

page_alloc.c::

static inline void free_page_mlock(struct page *page)
{

	__dec_zone_page_state(page, NR_MLOCK);
	__count_vm_event(UNEVICTABLE_MLOCKFREED);

	mem_cgroup_uncharge_page(page);
}
==

BTW, at reading code briefly....why we have hooks in free_page() ?

It seems do_munmap() and exit_mmap() calls munlock_vma_pages_all().
So, it seems all vmas which has VM_MLOCKED are checked before freeing.
vmscan never frees mlocked pages, I think.

Any other path to free mlocked pages without munlock ?
I feel freeing Mlocked page is a cause of problems.


Thanks,
-Kame







Thanks,
-Kame


	










--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
