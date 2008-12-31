Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1D5D56B007E
	for <linux-mm@kvack.org>; Tue, 30 Dec 2008 23:01:24 -0500 (EST)
Message-ID: <495AEE1E.9050303@cn.fujitsu.com>
Date: Wed, 31 Dec 2008 11:59:26 +0800
From: Miao Xie <miaox@cn.fujitsu.com>
Reply-To: miaox@cn.fujitsu.com
MIME-Version: 1.0
Subject: Re: [PATCH] cpuset,mm: fix allocating page cache/slab object on the
 unallowed node when memory spread is set
References: <49547B93.5090905@cn.fujitsu.com> <20081230142805.3c6f78e3.akpm@linux-foundation.org> <200812311413.45127.nickpiggin@yahoo.com.au>
In-Reply-To: <200812311413.45127.nickpiggin@yahoo.com.au>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, menage@google.com, cl@linux-foundation.org, penberg@cs.helsinki.fi, mpm@selenic.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

on 2008-12-31 11:13 Nick Piggin wrote:
> On Wednesday 31 December 2008 09:28:05 Andrew Morton wrote:
>> On Fri, 26 Dec 2008 14:37:07 +0800
>>
>> Miao Xie <miaox@cn.fujitsu.com> wrote:
>>> The task still allocated the page caches on old node after modifying its
>>> cpuset's mems when 'memory_spread_page' was set, it is caused by the old
>>> mem_allowed_list of the task. Slab has the same problem.
>> ok...
>>
>>> diff --git a/mm/filemap.c b/mm/filemap.c
>>> index f3e5f89..d978983 100644
>>> --- a/mm/filemap.c
>>> +++ b/mm/filemap.c
>>> @@ -517,6 +517,9 @@ int add_to_page_cache_lru(struct page *page, struct
>>> address_space *mapping, #ifdef CONFIG_NUMA
>>>  struct page *__page_cache_alloc(gfp_t gfp)
>>>  {
>>> +	if ((gfp & __GFP_WAIT) && !in_interrupt())
>>> +		cpuset_update_task_memory_state();
>>> +
>>>  	if (cpuset_do_page_mem_spread()) {
>>>  		int n = cpuset_mem_spread_node();
>>>  		return alloc_pages_node(n, gfp, 0);
>>> diff --git a/mm/slab.c b/mm/slab.c
>>> index 0918751..3b6e3d7 100644
>>> --- a/mm/slab.c
>>> +++ b/mm/slab.c
>>> @@ -3460,6 +3460,9 @@ __cache_alloc(struct kmem_cache *cachep, gfp_t
>>> flags, void *caller) if (should_failslab(cachep, flags))
>>>  		return NULL;
>>>
>>> +	if ((flags & __GFP_WAIT) && !in_interrupt())
>>> +		cpuset_update_task_memory_state();
>>> +
> 
> These paths are pretty performance critical. Why don't cpusets code do this
> work in the slowpath where the cpuset's mems_allowed gets changed rather
> than putting these calls all over the place with apparently no real rhyme or
> reason :( (this is not against your patch, but just this part of the cpusets
> design)

I see. I will do it.

>>>  	cache_alloc_debugcheck_before(cachep, flags);
>>>  	local_irq_save(save_flags);
>>>  	objp = __do_cache_alloc(cachep, flags);
>> Problems.
>>
>> a) There's no need to test in_interrupt().  Any caller who passed us
>>    __GFP_WAIT from interrupt context is horridly buggy and needs to be
>>    fixed.
> 
> Right. There are existing sites that do the same check, which is probably
> where it is copied from.

I will do cleanup in the next patch.
Thanks!

> 
>> b) Even if the caller _did_ set __GFP_WAIT, there's no guarantee
>>    that we're deadlock safe here.  Does anyone ever do a __GFP_WAIT
>>    allocation while holding callback_mutex?  If so, it'll deadlock.
> 
> It's static to cpuset.c, so I'd hope not.
> 
> 
>> c) These are two of the kernel's hottest code paths.  We really
>>    really really really don't want to be polling for some dopey
>>    userspace admin change on each call to __cache_alloc()!
> 
> Yeah, right. Let's try to fix cpuset.c instead...
> 
>> d) How does slub handle this problem?
> 
> SLUB seems to do a "sloppy" kind of memory policy allocation, where it just
> relies on the page allocator to hand us the correct page and AFAIKS does not
> exactly obey this stuff all the time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
