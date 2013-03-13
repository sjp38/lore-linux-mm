Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 74A076B0002
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 05:59:30 -0400 (EDT)
Received: by mail-bk0-f50.google.com with SMTP id jg9so345703bkc.37
        for <linux-mm@kvack.org>; Wed, 13 Mar 2013 02:59:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <514043B5.1090205@jp.fujitsu.com>
References: <1362489058-3455-1-git-send-email-glommer@parallels.com>
	<1362489058-3455-3-git-send-email-glommer@parallels.com>
	<51368D80.20701@jp.fujitsu.com>
	<5136FEC2.2050004@parallels.com>
	<51371E4A.7090807@jp.fujitsu.com>
	<51371FEF.3020507@parallels.com>
	<513721A5.6080401@jp.fujitsu.com>
	<CAFj3OHWm_GjLFwNEE=D69DR-YSF25AZvKTLHpyHq7aYDi12b0g@mail.gmail.com>
	<514043B5.1090205@jp.fujitsu.com>
Date: Wed, 13 Mar 2013 17:59:28 +0800
Message-ID: <CAFj3OHUupqG-178gnTUWc787n5cJjGgGZRzXuNRVvOvYqkHvgA@mail.gmail.com>
Subject: Re: [PATCH v2 2/5] memcg: provide root figures from system totals
From: Sha Zhengju <handai.szj@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, anton.vorontsov@linaro.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>

On Wed, Mar 13, 2013 at 5:15 PM, Kamezawa Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> (2013/03/13 15:58), Sha Zhengju wrote:
>>
>> On Wed, Mar 6, 2013 at 6:59 PM, Kamezawa Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>>
>>> (2013/03/06 19:52), Glauber Costa wrote:
>>>>
>>>> On 03/06/2013 02:45 PM, Kamezawa Hiroyuki wrote:
>>>>>
>>>>> (2013/03/06 17:30), Glauber Costa wrote:
>>>>>>
>>>>>> On 03/06/2013 04:27 AM, Kamezawa Hiroyuki wrote:
>>>>>>>
>>>>>>> (2013/03/05 22:10), Glauber Costa wrote:
>>>>>>>>
>>>>>>>> + case _MEMSWAP: {
>>>>>>>> +         struct sysinfo i;
>>>>>>>> +         si_swapinfo(&i);
>>>>>>>> +
>>>>>>>> +         return ((memcg_read_root_rss() +
>>>>>>>> +         atomic_long_read(&vm_stat[NR_FILE_PAGES])) << PAGE_SHIFT)
>>>>>>>> +
>>>>>>>> +         i.totalswap - i.freeswap;
>>>>>>>
>>>>>>>
>>>>>>> How swapcache is handled ? ...and How kmem works with this calc ?
>>>>>>>
>>>>>> I am ignoring kmem, because we don't account kmem for the root cgroup
>>>>>> anyway.
>>>>>>
>>>>>> Setting the limit is invalid, and we don't account until the limit is
>>>>>> set. Then it will be 0, always.
>>>>>>
>>>>>> For swapcache, I am hoping that totalswap - freeswap will cover
>>>>>> everything swap related. If you think I am wrong, please enlighten me.
>>>>>>
>>>>>
>>>>> i.totalswap - i.freeswap = # of used swap entries.
>>>>>
>>>>> SwapCache can be rss and used swap entry at the same time.
>>>>>
>>>>
>>>> Well, yes, but the rss entries would be accounted for in get_mm_rss(),
>>>> won't they ?
>>>>
>>>> What am I missing ?
>>>
>>>
>>>
>>> I think the correct caluculation is
>>>
>>>    Sum of all RSS + All file caches + (i.total_swap - i.freeswap - # of
>>> mapped SwapCache)
>>>
>>>
>>> In the patch, mapped SwapCache is counted as both of rss and swap.
>>>
>>
>> After a quick look, swapcache is counted as file pages and meanwhile
>> use a swap entry at the same time(__add_to{delete_from}_swap_cache()).
>> Even though, I think we still do not need to exclude swapcache out,
>> because it indeed uses two copy of resource: one is swap entry, one is
>> cache, so the usage should count both of them in.
>>
>> What I think it matters is that swapcache may be counted as both file
>> pages and rss(if it's a process's anonymous page), which we need to
>> subtract # of swapcache to avoid double-counting. But it isn't always
>> so: a shmem/tmpfs page may use swapcache and be counted as file pages
>> but not a rss, then we can not subtract swapcache... Is there anything
>> I lost?
>>
>
>
> Please don't think difficult. All pages for user/caches are counted in
> LRU. All swap-entry usage can be cauht by total_swap_pages - nr_swap_pages.
> We just need to subtract number of swap-cache which is double counted
> as swap-entry and a page in LRU.
>
> NR_ACTIVE_ANON + NR_INACTIVE_ANON + NR_ACTIVE_FILE + NR_INACTIVE_FILE
> + NR_UNEVICTABLE + total_swap_pages - nr_swap_pages - NR_SWAP_CACHE
>

Using LRU numbers is more suitable. But forgive me, I still doubt
whether we should subtract NR_SWAP_CACHE out because it uses both a
swap entry and a page cache and it isn't a real double counting.


Thanks,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
