Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B3B206B005C
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 02:15:22 -0500 (EST)
Message-ID: <496EE25E.3030703@cn.fujitsu.com>
Date: Thu, 15 Jan 2009 15:14:38 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC] [PATCH] memcg: fix infinite loop
References: <496ED2B7.5050902@cn.fujitsu.com>	<20090115061557.GD30358@balbir.in.ibm.com> <20090115153134.632ebc85.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090115153134.632ebc85.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Thu, 15 Jan 2009 11:45:57 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> * Li Zefan <lizf@cn.fujitsu.com> [2009-01-15 14:07:51]:
>>
>>> 1. task p1 is in /memcg/0
>>> 2. p1 does mmap(4096*2, MAP_LOCKED)
>>> 3. echo 4096 > /memcg/0/memory.limit_in_bytes
>>>
>>> The above 'echo' will never return, unless p1 exited or freed the memory.
>>> The cause is we can't reclaim memory from p1, so the while loop in
>>> mem_cgroup_resize_limit() won't break.
>>>
>>> This patch fixes it by decrementing retry_count regardless the return value
>>> of mem_cgroup_hierarchical_reclaim().
>>>
>> The problem definitely seems to exist, shouldn't we fix reclaim to
>> return 0, so that we know progress is not made and retry count
>> decrements? 
>>
> 
> The behavior is correct. And we already check signal_pending() in the loop.
> Ctrl-C or SIGALARM will works better than checking retry count.

But this behavior seems like a regression. Please try it in 2.6.28, you'll see
it returns EBUSY immediately.

Looks like the return value of mem_cgroup_hierarchical_reclaim() is buggy ?

>  But adding a new control file, memory.resize_timeout to check timeout is a choice.
> 
> Second thought is.
> thanks to Kosaki at el, LRU for locked pages is now visible in memory.stat
> file. So, we may able to have clever way.
> 
> == 
>  unevictable = mem_cgroup_get_all_zonestat(mem, LRU_UNEVICLABLE);
>  if (newlimit < unevictable)
> 	break;
> ==
> But considering hierarchy, this can be complex.
> please don't modify current behavior for a while, I'll try to write "hierarchical stat"
> with CSS_ID patch set's easy hierarchy walk.
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
