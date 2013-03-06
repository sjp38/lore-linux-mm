Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 98EEB6B0006
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 06:00:16 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 484E43EE0B6
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 20:00:15 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D55145DE4F
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 20:00:15 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 130AD45DE4E
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 20:00:15 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 044E51DB803B
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 20:00:15 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AA9DE1DB803F
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 20:00:14 +0900 (JST)
Message-ID: <513721A5.6080401@jp.fujitsu.com>
Date: Wed, 06 Mar 2013 19:59:49 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/5] memcg: provide root figures from system totals
References: <1362489058-3455-1-git-send-email-glommer@parallels.com> <1362489058-3455-3-git-send-email-glommer@parallels.com> <51368D80.20701@jp.fujitsu.com> <5136FEC2.2050004@parallels.com> <51371E4A.7090807@jp.fujitsu.com> <51371FEF.3020507@parallels.com>
In-Reply-To: <51371FEF.3020507@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, handai.szj@gmail.com, anton.vorontsov@linaro.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>

(2013/03/06 19:52), Glauber Costa wrote:
> On 03/06/2013 02:45 PM, Kamezawa Hiroyuki wrote:
>> (2013/03/06 17:30), Glauber Costa wrote:
>>> On 03/06/2013 04:27 AM, Kamezawa Hiroyuki wrote:
>>>> (2013/03/05 22:10), Glauber Costa wrote:
>>>>> +	case _MEMSWAP: {
>>>>> +		struct sysinfo i;
>>>>> +		si_swapinfo(&i);
>>>>> +
>>>>> +		return ((memcg_read_root_rss() +
>>>>> +		atomic_long_read(&vm_stat[NR_FILE_PAGES])) << PAGE_SHIFT) +
>>>>> +		i.totalswap - i.freeswap;
>>>>
>>>> How swapcache is handled ? ...and How kmem works with this calc ?
>>>>
>>> I am ignoring kmem, because we don't account kmem for the root cgroup
>>> anyway.
>>>
>>> Setting the limit is invalid, and we don't account until the limit is
>>> set. Then it will be 0, always.
>>>
>>> For swapcache, I am hoping that totalswap - freeswap will cover
>>> everything swap related. If you think I am wrong, please enlighten me.
>>>
>>
>> i.totalswap - i.freeswap = # of used swap entries.
>>
>> SwapCache can be rss and used swap entry at the same time.
>>
> 
> Well, yes, but the rss entries would be accounted for in get_mm_rss(),
> won't they ?
> 
> What am I missing ?


I think the correct caluculation is

  Sum of all RSS + All file caches + (i.total_swap - i.freeswap - # of mapped SwapCache)


In the patch, mapped SwapCache is counted as both of rss and swap.

BTW, how about

  Sum of all LRU + (i.total_swap - i.freeswap - # of all SwapCache)
?

Thanks,
-Kame









--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
