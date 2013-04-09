Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 5F45A6B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 22:42:15 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 3E26E3EE0BC
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 11:42:12 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2058845DE54
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 11:42:12 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id EF1D645DE51
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 11:42:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DFD7D1DB803B
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 11:42:11 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C46B1DB8041
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 11:42:11 +0900 (JST)
Message-ID: <51637FF7.4070101@jp.fujitsu.com>
Date: Tue, 09 Apr 2013 11:41:59 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] memcg: consistently use vmalloc for page_cgroup allocations
References: <1365156072-24100-1-git-send-email-glommer@parallels.com> <1365156072-24100-2-git-send-email-glommer@parallels.com> <20130405120604.GN1953@cmpxchg.org> <515EC34C.8040704@parallels.com> <20130405162536.GO1953@cmpxchg.org>
In-Reply-To: <20130405162536.GO1953@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Glauber Costa <glommer@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>

(2013/04/06 1:25), Johannes Weiner wrote:
> On Fri, Apr 05, 2013 at 04:27:56PM +0400, Glauber Costa wrote:
>> On 04/05/2013 04:06 PM, Johannes Weiner wrote:
>>> On Fri, Apr 05, 2013 at 02:01:11PM +0400, Glauber Costa wrote:
>>>> Right now, allocation for page_cgroup is a bit complicated, dependent on
>>>> a variety of system conditions:
>>>>
>>>> For flat memory, we are likely to need quite big pages, so the page
>>>> allocator won't cut. We are forced to init flatmem mappings very early,
>>>> because if we run after the page allocator is in place those allocations
>>>> will be denied. Flatmem mappings thus resort to the bootmem allocator.
>>>>
>>>> We can fix this by using vmalloc for flatmem mappings. However, we now
>>>> have the situation in which flatmem mapping allocate using vmalloc, but
>>>> sparsemem may or may not allocate with vmalloc. It will try the
>>>> page_allocator first, and retry vmalloc if it fails.
>>>
>>> Vmalloc space is a precious resource on 32-bit systems and harder on
>>> the TLB than the identity mapping.
>>>
>>> It's a last resort thing for when you need an unusually large chunk of
>>> contiguously addressable memory during runtime, like loading a module,
>>> buffers shared with userspace etc..  But here we know, during boot
>>> time, the exact amount of memory we need for the page_cgroup array.
>>>
>>> Code cleanup is not a good reason to use vmalloc in this case, IMO.
>>>
>> This is indeed a code cleanup, but a code cleanup with a side goal:
>> freeing us from the need to register page_cgroup mandatorily at init
>> time. This is done because page_cgroup_init_flatmem will use the bootmem
>> allocator, to avoid the page allocator limitations.
>>
>> What I can try to do, and would happily do, is to try a normal page
>> allocation and then resort to vmalloc if it is too big.
>>
>> Would that be okay to you ?
>
> With the size of page_cgroup right now (2 words), we need half a page
> per MB of represented memory on 32 bit, so booting on a 4GB 32 bit
> machine needs an order-11 (MAX_ORDER) allocation and thus fall back to
> 8MB of the 128MB vmalloc space.  A 16GB machine falls back to 32MB, a
> quarter of the vmalloc space.
>
> Now, I think we all agree that these are not necessarily recommended
> configurations but we should not be breaking them for the hell of it
> either.
>
> How about leaving flatmem as it is and have an on-demand allocation
> model that just works with sparsemem?  A 128MB section on 64 bit
> "only" needs order-7 pages, but we satisfy order-9 THP allocations all
> the time during runtime, so this may just work.
>

I agree to Johannes' option.

Thanks,
-Kame






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
