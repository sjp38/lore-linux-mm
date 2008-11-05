Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id mA5HqnjG028346
	for <linux-mm@kvack.org>; Thu, 6 Nov 2008 04:52:49 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mA5Hqkfg3612840
	for <linux-mm@kvack.org>; Thu, 6 Nov 2008 04:52:46 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mA5HqgJB019262
	for <linux-mm@kvack.org>; Thu, 6 Nov 2008 04:52:43 +1100
Message-ID: <4911DD64.7010508@linux.vnet.ibm.com>
Date: Wed, 05 Nov 2008 23:22:36 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [mm][PATCH 0/4] Memory cgroup hierarchy introduction
References: <20081101184812.2575.68112.sendpatchset@balbir-laptop> <20081104091510.01cf3a1e.kamezawa.hiroyu@jp.fujitsu.com> <4911A4D8.4010402@linux.vnet.ibm.com> <50093.10.75.179.62.1225902786.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <50093.10.75.179.62.1225902786.squirrel@webmail-b.css.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Balbir Singh said:
>> KAMEZAWA Hiroyuki wrote:
>>> On Sun, 02 Nov 2008 00:18:12 +0530
>>> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>> As first impression, I think hierarchical LRU management is not
>>> good...means
>>> not fair from viewpoint of memory management.
>> Could you elaborate on this further? Is scanning of children during
>> reclaim the
>> issue? Do you want weighted reclaim for each of the children?
>>
> No. Consider follwing case
>    /root/group_root/group_A
>                    /group_B
>                    /group_C
> 
>   sum of group A, B, C is limited by group_root's limit.
> 
>   Now,
>         /group_root limit=1G, usage=990M
>                     /group_A  usage=600M , no limit, no tasks for a while
>                     /group_B  usage=10M  , no limit, no tasks
>                     /group_C  usage=380M , no limit, 2 tasks
> 
>   A user run a new task in group_B.
>   In your algorithm, group_A and B and C's memory are reclaimed
>   to the same extent becasue there is no information to show
>   "group A's memory are not accessed recently rather than B or C".
> 
>   This information is what we want for managing memory.
> 

For that sort of implementation, we'll need a common LRU. I actually thought of
implementing it by sharing a common LRU, but then we would end up with just one
common LRU at the root :)

The reclaim algorithm is smart in that it knows what pages are commonly
accessed. group A will get reclaimed more since those pages are not actively
referenced. reclaim on group_C will be harder. Simple experiments seem to show that.


>>> I'd like to show some other possible implementation of
>>> try_to_free_mem_cgroup_pages() if I can.
>>>
>> Elaborate please!
>>
> ok. but, at least, please add
>   - per-subtree hierarchy flag.
>   - cgroup_lock to walk list of cgroups somewhere.
> 
> I already sent my version "shared LRU" just as a hint for you.
> It is something extreme but contains something good, I think.
> 
>>> Anyway, I have to merge this with mem+swap controller.
>> Cool! I'll send you an updated version.
>>
> 
> Synchronized LRU patch may help you.

Let me get a good working version against current -mm and then we'll integrate
our patches.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
