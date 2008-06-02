Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp03.in.ibm.com (8.13.1/8.13.1) with ESMTP id m526HtxY025530
	for <linux-mm@kvack.org>; Mon, 2 Jun 2008 11:47:55 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m526He5S671852
	for <linux-mm@kvack.org>; Mon, 2 Jun 2008 11:47:40 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id m526HsGI016531
	for <linux-mm@kvack.org>; Mon, 2 Jun 2008 11:47:54 +0530
Message-ID: <4843903F.1090009@linux.vnet.ibm.com>
Date: Mon, 02 Jun 2008 11:46:31 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/2] memcg: res_counter hierarchy
References: <4841886A.1000901@linux.vnet.ibm.com> <48413482.5080409@linux.vnet.ibm.com> <48407DC3.8060001@linux.vnet.ibm.com> <20080530104312.4b20cc60.kamezawa.hiroyu@jp.fujitsu.com> <20080530104515.9afefdbb.kamezawa.hiroyu@jp.fujitsu.com> <25360008.1212199156779.kamezawa.hiroyu@jp.fujitsu.com> <26479923.1212245220415.kamezawa.hiroyu@jp.fujitsu.com> <5049235.1212280513897.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <5049235.1212280513897.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, xemul@openvz.org, menage@google.com, yamamoto@valinux.co.jp, lizf@cn.fujitsu.com
List-ID: <linux-mm.kvack.org>

Hi, Kamezawa-san,

kamezawa.hiroyu@jp.fujitsu.com wrote:
> 
> It's not problem. We're not developing world-wide eco system.
> It's good that there are several development groups. It's a way to evolution.
> Something popular will be defacto standard. 
> What we have to do is providing proper interfaces for allowing fair race.
> 

I did not claim that we were developing an eco system either :)
My point is that we should not confuse *Linux* users. Lets do the common/useful
stuff in the kernel and make it easy for users to use the cgroup subsystem.

>>> Here is an example. (just an example...)
>>> Please point out if I'm misunderstanding "share".
>>>
>>> root_level/                   = limit 1G.
>>>           /child_A = share=30
>>>           /child_B = share=15
>>>           /child_C = share=5
>>> (and assume there is no process under root_level for make explanation easy.
> .)
>>> 0. At first, before starting to use memory, set all kernel_memory_limit.
>>> root_level.limit = 1G
>>>   child_A.limit=64M,usage=0
>>>   child_B.limit=64M,usage=0
>>>   child_C.limit=64M,usage=0
>>>   free_resource=808M 
>>>
>> This sounds incorrect, since the limits should be proportional to shares. If 
> the
>> maximum shares in the root were 100 (*ideally we want higher resolution than 
> that)
>> Then
>>
>> child_A.limit = .3 * 1G
>> child_B.limit = .15 * 1G
>>
>> and so on
>>
> Above just showing param to the kernel. 
> From user's view, memory limitation is A:B:C=6:3:1 if memory is fully used.
> (In above case, usage=0)
> 
> In general, "share" works only when the total usage reaches limitation.
> (See how cpu scheduler works.)
> When the usage doesn't reach limit, there is no limitatiuon.
> 

If you are implying that shares imply a soft limit, I agree. But the only
parameter in the kernel right now is hard limits. We need to add soft limit support.

>>> 1. next, a process in child_C start to run and use memory of 600M.
>>> root_level.limit = 1G
>>>   child_A.limit=64M
>>>   child_B.limit=64M
>>>   child_C.limit=600M,usage=600M
>>>   free_resource=272M
>>>
>> How is that feasible, it's limit was 64M, how did it bump up to 600M? If you
>> want something like that, child_C should have no limits.
> 
> middleware just do when child_C.failcnt hits.
> echo 64M > childC.memory.limits_in_bytes.
> and periodically checks A,B,C and allow C to use what it wants becasue
> A and B doesn't want memory.
> 
>>> 2. now, a process in child_A start tu run and use memory of 800M.
>>>   child_A.limit=800M,usage=800M
>>>   child_B.limit=64M,usage=0M
>>>   child_C.limit=136M,usage=136M
>>>   free_resouce=0,A:C=6:1
>>>
>> Not sure I understand this step
>>
> Middleware notices that usage in A is growing and moves resources to A.
> 
> echo current child_C's limit - 64M > child_C
> echo current child_A's limit + 64M > child_A
> do above in step by step with loops for making A:C = 6:1
> (64M is just an example)
> 
>>> 3.Finally, a process in child_B start. and use memory of 500M.
>>>   child_A.limit=600M,usage=600M
>>>   child_B.limit=300M,usage=300M
>>>   child_C.limit=100M,usage=100M
>>>   free_resouce=0, A:B:C=6:3:1
>>>
>> Not sure I understand this step
>>
> echo current child_C's limit - 64M > child_C
> echo current child_A's limit - 64M > child_A
> echo current child_B's limit + 64M > child_B
> do above in step by step with loops for making A:B:C = 6:3:1
> 
> 
>>> 4. one more, a process in A exits.
>>>   child_A.limit=64M, usage=0M
>>>   child_B.limit=500M, usage=500M
>>>   child_C.limit=436M, usage=436M
>>>   free_resouce=0, B:C=3:1 (but B just want to use 500M)
>>>
>> Not sure I understand this step
>>
> middleware can notice memory pressure from Child_A is reduced.
> 
> echo current child_A's limit - 64M > child_A
> echo current child_C's limit + 64M > child_C
> echo current child_B's limit + 64M > child_B
> do above in step by step with loops for making B:C = 3:1 with avoiding
> the waste of resources.
> 
> 
> 
>>> This is only an example and the middleware can more pricise "limit"
>>> contols by checking statistics of memory controller hierarchy based on
>>> their own policy.
>>>
>>> What I think now is what kind of statistics/notifier/controls are
>>> necessary to implement shares in middleware. How pricise/quick work the
>>> middleware can do is based on interfaces.
>>> Maybe the middleware should know "how fast the application runs now" by
>>> some kind of check or co-operative interface with the application.
>>> But I'm not sure how the kernel can help it.
>> I am not sure if I understand your proposal at this point.
>>
> 
> The most important point is cgoups.memory.memory.limit_in_bytes
> is _just_ a notification to ask the kernel to limit the memory
> usage of process groups temporally. It changes often.
> Based on user's notification to the middleware (share or limit),
> the middleware changes limit_in_bytes to be suitable value
> and change it dynamically and periodically. 
> 

Why don't we add soft limits, so that we don't have to go to the kernel and
change limits frequently. One missing piece in the memory controller is that we
don't shrink the memory controller when limits change or when tasks move. I
think soft limits is a better solution.

Thanks for patiently explaining all of this.

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
