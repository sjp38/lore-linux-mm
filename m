Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id m1K621RJ004234
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 11:32:01 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1K620Zc946204
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 11:32:01 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id m1K620qg022658
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 06:02:00 GMT
Message-ID: <47BBC15E.5070405@linux.vnet.ibm.com>
Date: Wed, 20 Feb 2008 11:27:50 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
References: <20080219215431.1aa9fa8a.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0802191449490.6254@blonde.site>
In-Reply-To: <Pine.LNX.4.64.0802191449490.6254@blonde.site>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "riel@redhat.com" <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Tue, 19 Feb 2008, KAMEZAWA Hiroyuki wrote:
>> I'd like to start from RFC.
>>
>> In following code
>> ==
>>   lock_page_cgroup(page);
>>   pc = page_get_page_cgroup(page);
>>   unlock_page_cgroup(page);
>>
>>   access 'pc' later..
>> == (See, page_cgroup_move_lists())
>>
>> There is a race because 'pc' is not a stable value without lock_page_cgroup().
>> (mem_cgroup_uncharge can free this 'pc').
>>
>> For example, page_cgroup_move_lists() access pc without lock.
>> There is a small race window, between page_cgroup_move_lists()
>> and mem_cgroup_uncharge(). At uncharge, page_cgroup struct is immedieately
>> freed but move_list can access it after taking lru_lock.
>> (*) mem_cgroup_uncharge_page() can be called without zone->lru lock.
>>
>> This is not good manner.
>> .....
>> There is no quick fix (maybe). Moreover, I hear some people around me said
>> current memcontrol.c codes are very complicated.
>> I agree ;( ..it's caued by my work.
>>
>> I'd like to fix problems in clean way.
>> (Note: current -rc2 codes works well under heavy pressure. but there
>>  is possibility of race, I think.)
> 
> Yes, yes, indeed, I've been working away on this too.
> 
> Ever since the VM_BUG_ON(page_get_page_cgroup(page)) went into
> free_hot_cold_page (at my own prompting), I've been hitting it
> just very occasionally in my kernel build testing.  Was unable
> to reproduce it over the New Year, but a week or two ago found
> one machine and config on which it is relatively reproducible,
> pretty sure to happen within 12 hours.
> 
> And on Saturday evening at last identified the cause, exactly
> where you have: that unsafety in mem_cgroup_move_lists - which
> has the nice property of putting pages from the lru on to SLUB's
> freelist!
> 
> Unlike the unsafeties of force_empty, this is liable to hit anyone
> running with MEM_CONT compiled in, they don't have to be consciously
> using mem_cgroups at all.
> 
> (I consider that, by the way, quite a serious defect in the current
> mem_cgroup work: that a distro compiling it in for 1% of customers
> is then subjecting all to the mem_cgroup overhead - effectively
> doubled struct page size and unnecessary accounting overhead.  I
> believe there needs to be a way to opt out, a force_empty which
> sticks.  Yes, I know the page_cgroup which does that doubling of
> size is only allocated on demand, but every page cache page and
> every anonymous page is going to have one.  A kmem_cache for them
> will reduce the extra, but there still needs to be a way to opt
> out completely.)
> 

I've been thinking along these lines as well

1. Have a boot option to turn on/off the memory controller
2. Have a separate cache for the page_cgroup structure. I sent this suggestion
   out just yesterday or so.

I agree that these are necessary enhancements/changes.

[snip]



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
