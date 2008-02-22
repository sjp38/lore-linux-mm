Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id m1MBJJYj021642
	for <linux-mm@kvack.org>; Fri, 22 Feb 2008 22:19:19 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1MBJpnq3002526
	for <linux-mm@kvack.org>; Fri, 22 Feb 2008 22:19:52 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1MBJpGk008866
	for <linux-mm@kvack.org>; Fri, 22 Feb 2008 22:19:51 +1100
Message-ID: <47BEAEA9.10801@linux.vnet.ibm.com>
Date: Fri, 22 Feb 2008 16:44:49 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
References: <20080219215431.1aa9fa8a.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0802191449490.6254@blonde.site> <20080220.152753.98212356.taka@valinux.co.jp> <20080220155049.094056ac.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0802220916290.18145@blonde.site>
In-Reply-To: <Pine.LNX.4.64.0802220916290.18145@blonde.site>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hirokazu Takahashi <taka@valinux.co.jp>, linux-mm@kvack.org, yamamoto@valinux.co.jp, riel@redhat.com
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Wed, 20 Feb 2008, KAMEZAWA Hiroyuki wrote:
>> On Wed, 20 Feb 2008 15:27:53 +0900 (JST)
>> Hirokazu Takahashi <taka@valinux.co.jp> wrote:
>>
>>>> Unlike the unsafeties of force_empty, this is liable to hit anyone
>>>> running with MEM_CONT compiled in, they don't have to be consciously
>>>> using mem_cgroups at all.
>>> As for force_empty, though this may not be the main topic here,
>>> mem_cgroup_force_empty_list() can be implemented simpler.
>>> It is possible to make the function just call mem_cgroup_uncharge_page()
>>> instead of releasing page_cgroups by itself. The tips is to call get_page()
>>> before invoking mem_cgroup_uncharge_page() so the page won't be released
>>> during this function.
>>>
>>> Kamezawa-san, you may want look into the attached patch.
>>> I think you will be free from the weired complexity here.
>>>
>>> This code can be optimized but it will be enough since this function
>>> isn't critical.
>>>
>>> Thanks.
>>>
>>>
>>> Signed-off-by: Hirokazu Takahashi <taka@vallinux.co.jp>
> 
> Hirokazu-san, may I change that to <taka@valinux.co.jp>?
> 
>> ...
>>
>> Seems simple. But isn't there following case ?
>>
>> ==in force_empty==
>>
>> pc1 = list_entry(list->prev, struct page_cgroup, lru);
>> page = pc1->page;
>> get_page(page)
>> spin_unlock_irqrestore(&mz->lru_lock, flags)
>> mem_cgroup_uncharge_page(page);
>> 	=> lock_page_cgroup(page);
>> 		=> pc2 = page_get_page_cgroup(page);
>>
>> Here, pc2 != pc1 and pc2->mem_cgroup != pc1->mem_cgroup.
>> maybe need some check.
>>
>> But maybe yours is good direction.
> 
> I like Hirokazu-san's approach very much.
> 
> Although I eventually completed the locking for my mem_cgroup_move_lists
> (SLAB_DESTROY_BY_RCU didn't help there, actually, because it left a
> possibility that the same page_cgroup got reused for the same page
> but a different mem_cgroup: in which case we got the wrong spinlock),
> his reversal in force_empty lets us use straightforward locking in
> mem_cgroup_move_lists (though it still has to try_lock_page_cgroup).
> So I want to take Hirokazu-san's patch into my bugfix and cleanup
> series, where it's testing out fine so far.
> 
> Regarding your point above, Kamezawa-san: you're surely right that can
> happen, but is it a case that we actually need to avoid?  Aren't we
> entitled to take the page out of pc2->mem_cgroup there, because if any
> such race occurs, it could easily have happened the other way around,
> removing the page from pc1->mem_cgroup just after pc2->mem_cgroup
> touched it, so ending up with that page in neither?
> 
> I'd just prefer not to handle it as you did in your patch, because
> earlier in my series I'd removed the mem_cgroup_uncharge level (which
> just gets in the way, requiring a silly lock_page_cgroup at the end
> just to match the unlock_page_cgroup at the mem_cgroup_uncharge_page
> level), and don't much want to add it back in.
> 

I've been looking through the code time and again, looking for races. I will try
and build a sketch of all the functions and dependencies tonight. One thing that
struck me was that making page_get_page_cgroup() call lock_page_cgroup()
internally might potentially fix a lot of racy call sites. I was thinking of
splitting page_get_page_cgroup into __page_get_page_cgroup() <--> just get the
pc without lock and page_get_page_cgroup(), that holds the lock and then returns pc.

Of course, this is just a thought process. I am yet to write the code and look
at the results.

> While we're thinking of races...
> 
> It seemed to me that mem_cgroup_uncharge should be doing its css_put
> after its __mem_cgroup_remove_list: doesn't doing it before leave open
> a slight danger that the struct mem_cgroup could be freed before the
> remove_list?  Perhaps there's some other refcounting that makes that
> impossible, but I've felt safer shifting those around.
> 

Yes, it's a good idea to move it down.

> Hugh


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
