Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp03.in.ibm.com (8.13.1/8.13.1) with ESMTP id m4VHJr4L000775
	for <linux-mm@kvack.org>; Sat, 31 May 2008 22:49:53 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4VHJaDl860264
	for <linux-mm@kvack.org>; Sat, 31 May 2008 22:49:39 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m4VHJoJT027011
	for <linux-mm@kvack.org>; Sat, 31 May 2008 22:49:50 +0530
Message-ID: <4841886A.1000901@linux.vnet.ibm.com>
Date: Sat, 31 May 2008 22:48:34 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/2] memcg: res_counter hierarchy
References: <48413482.5080409@linux.vnet.ibm.com> <48407DC3.8060001@linux.vnet.ibm.com> <20080530104312.4b20cc60.kamezawa.hiroyu@jp.fujitsu.com> <20080530104515.9afefdbb.kamezawa.hiroyu@jp.fujitsu.com> <25360008.1212199156779.kamezawa.hiroyu@jp.fujitsu.com> <26479923.1212245220415.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <26479923.1212245220415.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, xemul@openvz.org, menage@google.com, yamamoto@valinux.co.jp, lizf@cn.fujitsu.com
List-ID: <linux-mm.kvack.org>

kamezawa.hiroyu@jp.fujitsu.com wrote:
> ----- Original Message -----
> 
>>> One more problem is that it's hard to implement various kinds of hierarchy
>>> policy. I believe there are other hierarhcy policies rather than OpenVZ
>>> want to use. Kicking out functions to middleware AMAP is what I'm thinking
>>> now.
>> One way to manage hierarchies other than via limits is to use shares (please 
> see
>> the shares used by the cpu controller). Basically, what you've done with limi
> ts
>> is done with shares
>>
> Yes, I like _share_ rather than limits.
> 
>> If a parent has 100 shares, then it can decide how many to pass on to it's  c
> hildren
>> based on the shares of the child and your logic would work well. I propose
>> assigning top level (high resolution) shares to the root of the cgroup and in
>  a
>> hierarchy passing them down to children and sharing it with them. Based on th
> e
>> shares, deduce the limit of each node in the hierarchy.
>>
>> What do you think?
>>
> As you wrote, a middleware can do controls based on share by limits.
> And it seems much easier to implement it in userland rather than in the kernel
> .

The good thing about user space is that moves unnecessary code outside the
kernel, but the hard thing is standardization. If every middleware is going to
implement what you say, imagine the code duplication, unless we standardize this
into a library component. More comments below. I am not sure about the
difference between user_memory_limit and kernel_memory_limit. Could you please
elaborate.

> 
> Here is an example. (just an example...)
> Please point out if I'm misunderstanding "share".
> 
> root_level/                   = limit 1G.
>           /child_A = share=30
>           /child_B = share=15
>           /child_C = share=5
> (and assume there is no process under root_level for make explanation easy..)
> 
> 0. At first, before starting to use memory, set all kernel_memory_limit.
> root_level.limit = 1G
>   child_A.limit=64M,usage=0
>   child_B.limit=64M,usage=0
>   child_C.limit=64M,usage=0
>   free_resource=808M 
> 

This sounds incorrect, since the limits should be proportional to shares. If the
maximum shares in the root were 100 (*ideally we want higher resolution than that)
Then

child_A.limit = .3 * 1G
child_B.limit = .15 * 1G

and so on


> 1. next, a process in child_C start to run and use memory of 600M.
> root_level.limit = 1G
>   child_A.limit=64M
>   child_B.limit=64M
>   child_C.limit=600M,usage=600M
>   free_resource=272M
> 

How is that feasible, it's limit was 64M, how did it bump up to 600M? If you
want something like that, child_C should have no limits.

> 2. now, a process in child_A start tu run and use memory of 800M.
>   child_A.limit=800M,usage=800M
>   child_B.limit=64M,usage=0M
>   child_C.limit=136M,usage=136M
>   free_resouce=0,A:C=6:1
> 

Not sure I understand this step

> 3.Finally, a process in child_B start. and use memory of 500M.
>   child_A.limit=600M,usage=600M
>   child_B.limit=300M,usage=300M
>   child_C.limit=100M,usage=100M
>   free_resouce=0, A:B:C=6:3:1
> 

Not sure I understand this step

> 4. one more, a process in A exits.
>   child_A.limit=64M, usage=0M
>   child_B.limit=500M, usage=500M
>   child_C.limit=436M, usage=436M
>   free_resouce=0, B:C=3:1 (but B just want to use 500M)
> 

Not sure I understand this step

> This is only an example and the middleware can more pricise "limit"
> contols by checking statistics of memory controller hierarchy based on
> their own policy.
> 
> What I think now is what kind of statistics/notifier/controls are
> necessary to implement shares in middleware. How pricise/quick work the
> middleware can do is based on interfaces.
> Maybe the middleware should know "how fast the application runs now" by
> some kind of check or co-operative interface with the application.
> But I'm not sure how the kernel can help it.

I am not sure if I understand your proposal at this point.

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
