Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 498FC6B005C
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 02:33:01 -0500 (EST)
Message-ID: <496EE683.8090101@cn.fujitsu.com>
Date: Thu, 15 Jan 2009 15:32:19 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC] [PATCH] memcg: fix infinite loop
References: <496ED2B7.5050902@cn.fujitsu.com>	<20090115061557.GD30358@balbir.in.ibm.com>	<20090115153134.632ebc85.kamezawa.hiroyu@jp.fujitsu.com>	<496EE25E.3030703@cn.fujitsu.com> <20090115162126.cf040c63.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090115162126.cf040c63.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Thu, 15 Jan 2009 15:14:38 +0800
> Li Zefan <lizf@cn.fujitsu.com> wrote:
> 
>> KAMEZAWA Hiroyuki wrote:
>>> On Thu, 15 Jan 2009 11:45:57 +0530
>>> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>>
>>>> * Li Zefan <lizf@cn.fujitsu.com> [2009-01-15 14:07:51]:
>>>>
>>>>> 1. task p1 is in /memcg/0
>>>>> 2. p1 does mmap(4096*2, MAP_LOCKED)
>>>>> 3. echo 4096 > /memcg/0/memory.limit_in_bytes
>>>>>
>>>>> The above 'echo' will never return, unless p1 exited or freed the memory.
>>>>> The cause is we can't reclaim memory from p1, so the while loop in
>>>>> mem_cgroup_resize_limit() won't break.
>>>>>
>>>>> This patch fixes it by decrementing retry_count regardless the return value
>>>>> of mem_cgroup_hierarchical_reclaim().
>>>>>
>>>> The problem definitely seems to exist, shouldn't we fix reclaim to
>>>> return 0, so that we know progress is not made and retry count
>>>> decrements? 
>>>>
>>> The behavior is correct. And we already check signal_pending() in the loop.
>>> Ctrl-C or SIGALARM will works better than checking retry count.
>> But this behavior seems like a regression. Please try it in 2.6.28, you'll see
>> it returns EBUSY immediately.
>>
>> Looks like the return value of mem_cgroup_hierarchical_reclaim() is buggy ?
>>
> 
> This is intentional behavior change by
> ==
>  memcg-make-oom-less-frequently.patch
> ==
> 
> try_to_free_page() returns positive value if try_to_free_page() reclaims at
> least 1 pages. It itself doesn't seem to be buggy.
> 
> What buggy is resize_limit's retry-out check code, I think.
> 
> How about following ?

Not sure.

I didn't look into the reclaim code, so I'd rather let you and Balbir decide if
this is a bug and (if yes) how to fix it.

> ==
> 	while (1) {
> 		if (signal_pending())
> 			break;
> 		try to set limit ....
> 		...
> 		ret = mem_cgroup_hierarchical_reclaim(memcg,  GFP_KERNEL, false);
> 		total_progress += ret;	
> 
> 		if (total_progress > (memcg->res.usage - val) * 2) {
> 			/*
> 			 * It seems we reclaimed twice of necessary
> 			 * pages...this memcg is busy
> 			 */
> 			ret = -EBUSY;
> 			break;
> 		}
> 	}
> ==
> 
> Thanks,
> -Kame
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
