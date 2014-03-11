Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 16E8F6B0085
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 08:05:11 -0400 (EDT)
Received: by mail-la0-f42.google.com with SMTP id ec20so5669939lab.29
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 05:05:11 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id z8si21770802lal.31.2014.03.11.05.05.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Mar 2014 05:05:10 -0700 (PDT)
Message-ID: <531EFB83.1070404@huawei.com>
Date: Tue, 11 Mar 2014 20:03:15 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: Re: [patch 00/11] userspace out of memory handling
References: <alpine.DEB.2.02.1403041952170.8067@chino.kir.corp.google.com> <20140305131743.b9a916fbc4e40fd895bc4e76@linux-foundation.org> <alpine.DEB.2.02.1403051831100.30075@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1403051831100.30075@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Tejun Heo <tj@kernel.org>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Tim Hockin <thockin@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-doc@vger.kernel.org

On 2014/3/6 10:52, David Rientjes wrote:

> On Wed, 5 Mar 2014, Andrew Morton wrote:
> 
>>> This patchset introduces a standard interface through memcg that allows
>>> both of these conditions to be handled in the same clean way: users
>>> define memory.oom_reserve_in_bytes to define the reserve and this
>>> amount is allowed to be overcharged to the process handling the oom
>>> condition's memcg.  If used with the root memcg, this amount is allowed
>>> to be allocated below the per-zone watermarks for root processes that
>>> are handling such conditions (only root may write to
>>> cgroup.event_control for the root memcg).
>>
>> If process A is trying to allocate memory, cannot do so and the
>> userspace oom-killer is invoked, there must be means via which process
>> A waits for the userspace oom-killer's action.
> 
> It does so by relooping in the page allocator waiting for memory to be 
> freed just like it would if the kernel oom killer were called and process 
> A was waiting for the oom kill victim process B to exit, we don't have the 
> ability to put it on a waitqueue because we don't touch the freeing 
> hotpath.  The userspace oom handler may not even necessarily kill 
> anything, it may be able to free its own memory and start throttling other 
> processes, for example.
> 
>> And there must be
>> fallbacks which occur if the userspace oom killer fails to clear the
>> oom condition, or times out.
>>
> 
> I agree completely and proposed this before as memory.oom_delay_millisecs 
> at http://lwn.net/Articles/432226 which we use internally when memory 
> can't be freed or a memcg's limit cannot be expanded.  I guess it makes 
> more sense alongside the rest of this patchset now, I can add it as an 
> additional patch next time around.
> 
>> Would be interested to see a description of how all this works.
>>
> 
> There's an article for LWN also being developed on this topic.  As 
> mentioned in that article, I think it would be best to generalize a lot of 
> the common functions and the eventfd handling entirely into a library.  
> I've attached an example implementation that just invokes a function to 
> handle the situation.
> 
> For Google's usecase specifically, at the root memcg level (system oom) we 
> want to do priority based memcg killing.  We want to kill from within a 
> memcg hierarchy that has the lowest priority relative to other memcgs.  
> This cannot be implemented with /proc/pid/oom_score_adj today.  Those 
> priorities may also change depending on whether a memcg hierarchy is 
> "overlimit", i.e. its limit has been increased temporarily because it has 
> hit a memcg oom and additional memory is readily available on the system.
> 
> So why not just introduce a memcg tunable that specifies a priority?  
> Well, it's not that simple.  Other users will want to implement different 
> policies on system oom (think about things like existing panic_on_oom or 
> oom_kill_allocating_task sysctls).  I introduced oom_kill_allocating_task 
> originally for SGI because they wanted a fast oom kill rather than 
> expensive tasklist scan: the allocating task itself is rather irrelevant, 
> it was just the unlucky task that was allocating at the moment that oom 
> was triggered.  What's guaranteed is that current in that case will always 
> free memory from under oom (it's not a member of some other mempolicy or 
> cpuset that would be needlessly killed).  Both sysctls could trivially be 
> reimplemented in userspace with this feature.
> 
> I have other customers who don't run in a memcg environment at all, they 
> simply reattach all processes to root and delete all other memcgs.  These 
> customers are only concerned about system oom conditions and want to do 
> something "interesting" before a process is killed.  Some want to log the 
> VM statistics as an artifact to examine later, some want to examine heap 
> profiles, others can start throttling and freeing memory rather than kill 
> anything.  All of this is impossible today because the kernel oom killer 
> will simply kill something immediately and any stats we collect afterwards 
> don't represent the oom condition.  The heap profiles are lost, throttling 
> is useless, etc.
> 
> Jianguo (cc'd) may also have usecases not described here.
> 

I want to log memory usage, like slabinfo, vmalloc info, page-cache info, etc. before
kill anything.

>> It is unfortunate that this feature is memcg-only.  Surely it could
>> also be used by non-memcg setups.  Would like to see at least a
>> detailed description of how this will all be presented and implemented.
>> We should aim to make the memcg and non-memcg userspace interfaces and
>> user-visible behaviour as similar as possible.
>>
> 
> It's memcg only because it can handle both system and memcg oom conditions 
> with the same clean interface, it would be possible to implement only 
> system oom condition handling through procfs (a little sloppy since it 
> needs to register the eventfd) but then a userspace oom handler would need 
> to determine which interface to use based on whether it was running in a 
> memcg or non-memcg environment.  I implemented this feature with userspace 
> in mind: I didn't want it to need two different implementations to do the 
> same thing depending on memcg.  The way it is written, a userspace oom 
> handler does not know (nor need not care) whether it is constrained by the 
> amount of system RAM or a memcg limit.  It can simply write the reserve to 
> its memcg's memory.oom_reserve_in_bytes, attach to memory.oom_control and 
> be done.
> 
> This does mean that memcg needs to be enabled for the support, though.  
> This is already done on most distributions, the cgroup just needs to be 
> mounted.  Would it be better to duplicate the interface in two different 
> spots depending on CONFIG_MEMCG?  I didn't think so, and I think the idea 
> of a userspace library that takes care of this registration (and mounting, 
> perhaps) proposed on LWN would be the best of both worlds.
> 
>> Patches 1, 2, 3 and 5 appear to be independent and useful so I think
>> I'll cherrypick those, OK?
>>
> 
> Ok!  I'm hoping that the PF_MEMPOLICY bit that is removed in those patches 
> is at least temporarily reserved for PF_OOM_HANDLER introduced here, I 
> removed it purposefully :)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
