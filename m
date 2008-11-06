Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id mA6E099K017142
	for <linux-mm@kvack.org>; Thu, 6 Nov 2008 19:30:09 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mA6E09km4419616
	for <linux-mm@kvack.org>; Thu, 6 Nov 2008 19:30:09 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id mA6E09rC017653
	for <linux-mm@kvack.org>; Fri, 7 Nov 2008 01:00:09 +1100
Message-ID: <4912F866.9080009@linux.vnet.ibm.com>
Date: Thu, 06 Nov 2008 19:30:06 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [mm] [PATCH 3/4] Memory cgroup hierarchical reclaim
References: <20081101184812.2575.68112.sendpatchset@balbir-laptop> <20081101184849.2575.37734.sendpatchset@balbir-laptop> <20081102143707.1bf7e2d0.kamezawa.hiroyu@jp.fujitsu.com> <490D3E50.9070606@linux.vnet.ibm.com> <20081104111751.51ea897b.kamezawa.hiroyu@jp.fujitsu.com> <4911A0FC.9@linux.vnet.ibm.com> <45571.10.75.179.62.1225902029.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <45571.10.75.179.62.1225902029.squirrel@webmail-b.css.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Balbir Singh said:
>>>>>> +	list_for_each_entry_safe_from(cgroup, cg,
>>>>>> &cg_current->parent->children,
>>>>>> +						 sibling) {
>>>>>> +		mem_child = mem_cgroup_from_cont(cgroup);
>>>>>> +
>>>>>> +		/*
>>>>>> +		 * Move beyond last scanned child
>>>>>> +		 */
>>>>>> +		if (mem_child == mem->last_scanned_child)
>>>>>> +			continue;
>>>>>> +
>>>>>> +		ret = try_to_free_mem_cgroup_pages(mem_child, gfp_mask);
>>>>>> +		mem->last_scanned_child = mem_child;
>>>>>> +
>>>>>> +		if (res_counter_check_under_limit(&mem->res)) {
>>>>>> +			ret = 0;
>>>>>> +			goto done;
>>>>>> +		}
>>>>>> +	}
>>>>> Is this safe against cgroup create/remove ? cgroup_mutex is held ?
>>>> Yes, I thought about it, but with the setup, each parent will be busy
>>>> since they
>>>> have children and hence cannot be removed. The leaf child itself has
>>>> tasks, so
>>>> it cannot be removed. IOW, it should be safe against removal.
>>>>
>>> I'm sorry if I misunderstand something. could you explain folloing ?
>>>
>>> In following tree,
>>>
>>>     level-1
>>>          -  level-2
>>>                 -  level-3
>>>                        -  level-4
>>> level-1's usage = level-1 + level-2 + level-3 + level-4
>>> level-2's usage = level-2 + level-3 + level-4
>>> level-3's usage = level-3 + level-4
>>> level-4's usage = level-4
>>>
>>> Assume that a task in level-2 hits its limit. It has to reclaim memory
>>> from
>>> level-2 and level-3, level-4.
>>>
>>> How can we guarantee level-4 has a task in this case ?
>> Good question. If there is no task, the LRU's will be empty and reclaim
>> will
>> return. We could also add other checks if needed.
>>
> If needed ?, yes, you need.
> The problem is that you are walking a list in usual way without any lock
> or guarantee that the list will never be modified.
> 
> My quick idea is following.
> ==
> Before start reclaim.
>  1. take lock_cgroup()
>  2. scan the tree and create "private" list as snapshot of tree to be
>     scanned.

This might not be feasible, since we would need to recurse down tree structures.
I am wondering what is the best way to walk down a hierarchy, Paul any suggestions?

Here is what I have so far

1. take cgroup lock
2. list_for_each_safe.* to walk cgroup
3. Reclaim from local tasks
4. Reclaim from child cgroups (starting from last child we stopped at),
recursively, so that we can walk down the full hierarchy
5. unlock cgroup



-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
