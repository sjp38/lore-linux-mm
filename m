Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id m6477rt8027950
	for <linux-mm@kvack.org>; Fri, 4 Jul 2008 12:37:53 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6476aZd512216
	for <linux-mm@kvack.org>; Fri, 4 Jul 2008 12:36:36 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id m6477rDi024607
	for <linux-mm@kvack.org>; Fri, 4 Jul 2008 12:37:53 +0530
Message-ID: <486DCC4E.3030203@linux.vnet.ibm.com>
Date: Fri, 04 Jul 2008 12:37:58 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 2.6.26-rc8-mm1] memrlimit: fix mmap_sem deadlock
References: <Pine.LNX.4.64.0807032143110.10641@blonde.site> <20080703160117.b3781463.akpm@linux-foundation.org> <486D81B9.9030704@linux.vnet.ibm.com> <20080703190123.1d72e9d1.akpm@linux-foundation.org> <486D970F.2000607@linux.vnet.ibm.com> <20080703212707.e0f6bbda.akpm@linux-foundation.org>
In-Reply-To: <20080703212707.e0f6bbda.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Fri, 04 Jul 2008 08:50:47 +0530 Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>>> I was referring to the below (which is where the conversation ended).
>>>
>>> It questions the basis of the whole feature.
>>>
>> In the email below, I referred to Hugh's comment on tracking total_vm as a more
>> achievable target and it gives a rough approximation of something worth
>> limiting. I agree with him on those points and mentioned my motivation for the
>> memrlimit patchset. We also look forward to enhancing memrlimit to control
>> mlock'ed pages (as it provides the generic infrastructure to control RLIMIT'ed
>> resources). Given Hugh's comment, I looked at it from the more positive side
>> rather the pessimistic angle. I've had discussions along these lines with Paul
>> Menage and Kamezawa. In the past we've discussed and there are cases where
>> memrlimit is not useful (large VM allocations with sparse usage), but there are
>> cases as mentioned below in the motivation for memrlimits as to why and where
>> they are useful.
>>
>> If there are suggestions to help improve the feature or provide similar
>> functionality without the noise; I am all ears
> 
> Well I've never reeeeeeealy understood what the whole feature is for.
> 
> +Advantages of providing this feature
> +
> +1. Control over virtual address space allows for a cgroup to fail gracefully
> +   i.e., via a malloc or mmap failure as compared to OOM kill when no
> +   pages can be reclaimed.
> +2. It provides better control over how many pages can be swapped out when
> +   the cgroup goes over its limit. A badly setup cgroup can cause excessive
> +   swapping. Providing control over the address space allocations ensures
> +   that the system administrator has control over the total swapping that
> +   can take place.
> 
> umm, OK.  I'm not sure _why_ someone would want to do that.  Perhaps
> some use-cases would help motivate us.  Perhaps desriptions of
> real-world operational problems would would be improved or solved were
> this feature available to the operator.

I can go over the use cases and some of the motivation

0. Provide the basic infrastructure for rlimit control for cgroups (mlock comes
to mind right away)
1. Similar to the goals of over commit accounting (although not that granular),
we would like to be able to decide on a per cgroup node, how much to overcommit
the system by
2. With the memory controller in place, a cgroup that exceeds it's limit is sent
to the reclaimer. We swap out pages or OOM the heaviest task in the cgroup. The
swap controller will help, but we want a gentler way of saying "No more virtual
RSS+swap space is available", so I am failing this allocation. The application
can then decide if it can free up some memory now or if it has to fail.

As far as real examples are concerned, I was told (via private communication -
discussion), by a user that scientific jobs can sometimes cause a havoc on
shared systems. They don't have control over how much virtual memory the set of
jobs consume. They would ideally like to be able to provide feedback to the
application about the maximum RSS + Swap that it can consume (case 1). With a
memrlimit address space controller in place, a failed allocation would tell the
jobs to use lesser memory (and potentially take longer) to finish the job,
instead of causing large amounts of swapping or OOM on the system.


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
