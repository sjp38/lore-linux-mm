Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id m713RA8W006416
	for <linux-mm@kvack.org>; Fri, 1 Aug 2008 13:27:10 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m713SAmX4718638
	for <linux-mm@kvack.org>; Fri, 1 Aug 2008 13:28:10 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m713SA45001025
	for <linux-mm@kvack.org>; Fri, 1 Aug 2008 13:28:10 +1000
Message-ID: <489282C7.2020500@linux.vnet.ibm.com>
Date: Fri, 01 Aug 2008 08:58:07 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: memo: mem+swap controller
References: <20080731101533.c82357b7.kamezawa.hiroyu@jp.fujitsu.com> <20080731152533.dea7713a.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20080731152533.dea7713a.nishimura@mxp.nes.nec.co.jp>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "hugh@veritas.com" <hugh@veritas.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Daisuke Nishimura wrote:
> Hi, Kamezawa-san.
> 
> On Thu, 31 Jul 2008 10:15:33 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> Hi, mem+swap controller is suggested by Hugh Dickins and I think it's a great
>> idea. Its concept is having 2 limits. (please point out if I misunderstand.)
>>
>>  - memory.limit_in_bytes       .... limit memory usage.
>>  - memory.total_limit_in_bytes .... limit memory+swap usage.
>>
> When I've considered more, I wonder how we can accomplish
> "do not use swap in this group".
> 

It's easy use the memrlimit controller and set virtual address limit <=
memory.limit_in_bytes. I use that to make sure I never swap out.

> Setting "limit_in_bytes == total_limit_in_bytes" doesn't meet it, I think.
> "limit_in_bytes = total_limit_in_bytes = 1G" cannot
> avoid "memory.usage = 700M swap.usage = 300M" under memory pressure
> outside of the group(and I think this behavior is the diffrence
> of "memory controller + swap controller" and "mem+swap controller").
> 
> I think total_limit_in_bytes and swappiness(or some flag to indicate
> "do not swap out"?) for each group would make more sense.

I do intend to add the swappiness feature soon for control groups.

> 
>> By this, we can avoid excessive use of swap under a cgroup without any bad effect
>> to global LRU. (in page selection algorithm...overhead will be added, of course)
>>
> Sorry, I cannot understand this part.
> 
>> Following is state transition and counter handling design memo.
>> This uses "3" counters to handle above conrrectly. If you have other logic,
>> please teach me. (and blame me if my diagram is broken.)
>>
> I don't think counting "disk swap" is good idea(global linux
> dosen't count it).
> Instead, I prefer counting "total swap"(that is swap entry).
> 
>> A point is how to handle swap-cache, I think.
>> (Maybe we need a _big_ change in memcg.)
>>
> I think swap cache should be counted as both memory and swap,
> as global linux does.
> 
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
