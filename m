Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 300C88D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 11:53:20 -0400 (EDT)
Received: by pxi10 with SMTP id 10so72930pxi.8
        for <linux-mm@kvack.org>; Tue, 29 Mar 2011 08:53:16 -0700 (PDT)
Message-ID: <4D920066.7000609@gmail.com>
Date: Tue, 29 Mar 2011 21:23:10 +0530
From: Balbir Singh <bsingharora@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC 0/3] Implementation of cgroup isolation
References: <20110328093957.089007035@suse.cz> <20110328200332.17fb4b78.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110328200332.17fb4b78.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 03/28/11 16:33, KAMEZAWA Hiroyuki wrote:
> On Mon, 28 Mar 2011 11:39:57 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
> 
>> Hi all,
>>
>> Memory cgroups can be currently used to throttle memory usage of a group of
>> processes. It, however, cannot be used for an isolation of processes from
>> the rest of the system because all the pages that belong to the group are
>> also placed on the global LRU lists and so they are eligible for the global
>> memory reclaim.
>>
>> This patchset aims at providing an opt-in memory cgroup isolation. This
>> means that a cgroup can be configured to be isolated from the rest of the
>> system by means of cgroup virtual filesystem (/dev/memctl/group/memory.isolated).
>>
>> Isolated mem cgroup can be particularly helpful in deployments where we have
>> a primary service which needs to have a certain guarantees for memory
>> resources (e.g. a database server) and we want to shield it off the
>> rest of the system (e.g. a burst memory activity in another group). This is
>> currently possible only with mlocking memory that is essential for the
>> application(s) or a rather hacky configuration where the primary app is in
>> the root mem cgroup while all the other system activity happens in other
>> groups.
>>
>> mlocking is not an ideal solution all the time because sometimes the working
>> set is very large and it depends on the workload (e.g. number of incoming
>> requests) so it can end up not fitting in into memory (leading to a OOM
>> killer). If we use mem. cgroup isolation instead we are keeping memory resident
>> and if the working set goes wild we can still do per-cgroup reclaim so the
>> service is less prone to be OOM killed.
>>
>> The patch series is split into 3 patches. First one adds a new flag into
>> mem_cgroup structure which controls whether the group is isolated (false by
>> default) and a cgroup fs interface to set it.
>> The second patch implements interaction with the global LRU. The current
>> semantic is that we are putting a page into a global LRU only if mem cgroup
>> LRU functions say they do not want the page for themselves.
>> The last patch prevents from soft reclaim if the group is isolated.
>>
>> I have tested the patches with the simple memory consumer (allocating
>> private and shared anon memory and SYSV SHM). 
>>
>> One instance (call it big consumer) running in the group and paging in the
>> memory (>90% of cgroup limit) and sleeping for the rest of its life. Then I
>> had a pool of consumers running in the same cgroup which page in smaller
>> amount of memory and paging them in the loop to simulate in group memory
>> pressure (call them sharks).
>> The sum of consumed memory is more than memory.limit_in_bytes so some
>> portion of the memory is swapped out.
>> There is one consumer running in the root cgroup running in parallel which
>> makes a pressure on the memory (to trigger background reclaim).
>>
>> Rss+cache of the group drops down significantly (~66% of the limit) if the
>> group is not isolated. On the other hand if we isolate the group we are
>> still saturating the group (~97% of the limit). I can show more
>> comprehensive results if somebody is interested.
>>
> 
> Isn't it the same result with the case where no cgroup is used ?
> What is the problem ?
> Why it's not a problem of configuration ?
> IIUC, you can put all logins to some cgroup by using cgroupd/libgcgroup.
> 

I agree with Kame, I am still at loss in terms of understand the use
case, I should probably see the rest of the patches

>> Thanks for comments.
>>
> 
> 
> Maybe you just want "guarantee".
> At 1st thought, this approarch has 3 problems. And memcg is desgined
> never to prevent global vm scans,
> 
> 1. This cannot be used as "guarantee". Just a way for "don't steal from me!!!"
>    This just implements a "first come, first served" system.
>    I guess this can be used for server desgines.....only with very very careful play.
>    If an application exits and lose its memory, there is no guarantee anymore.
> 
> 2. Even with isolation, a task in memcg can be killed by OOM-killer at
>    global memory shortage.
> 
> 3. it seems this will add more page fragmentation if implemented poorly, IOW,
>    can this be work with compaction ?
> 

Good points

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
