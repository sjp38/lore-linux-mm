Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id m5T52SdU004750
	for <linux-mm@kvack.org>; Sun, 29 Jun 2008 15:02:28 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5T51w3Y283912
	for <linux-mm@kvack.org>; Sun, 29 Jun 2008 15:01:58 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5T51v8J016905
	for <linux-mm@kvack.org>; Sun, 29 Jun 2008 15:01:58 +1000
Message-ID: <4867174B.3090005@linux.vnet.ibm.com>
Date: Sun, 29 Jun 2008 10:32:03 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC 0/5] Memory controller soft limit introduction (v3)
References: <20080627151808.31664.36047.sendpatchset@balbir-laptop> <20080628133615.a5fa16cf.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080628133615.a5fa16cf.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Fri, 27 Jun 2008 20:48:08 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> This patchset implements the basic changes required to implement soft limits
>> in the memory controller. A soft limit is a variation of the currently
>> supported hard limit feature. A memory cgroup can exceed it's soft limit
>> provided there is no contention for memory.
>>
>> These patches were tested on a x86_64 box, by running a programs in parallel,
>> and checking their behaviour for various soft limit values.
>>
>> These patches were developed on top of 2.6.26-rc5-mm3. Comments, suggestions,
>> criticism are all welcome!
>>
>> A previous version of the patch can be found at
>>
>> http://kerneltrap.org/mailarchive/linux-kernel/2008/2/19/904114
>>
> I have a couple of comments.
> 
> 1. Why you add soft_limit to res_coutner ?
>    Is there any other controller which uses soft-limit ?
>    I'll move watermark handling to memcg from res_counter becasue it's
>    required only by memcg.
> 

I expect soft_limits to be controller independent. The same thing can be applied
to an io-controller for example, right?

> 2. *please* handle NUMA
>    There is a fundamental difference between global VMM and memcg.
>      global VMM - reclaim memory at memory shortage.
>      memcg     - for reclaim memory at memory limit
>    Then, memcg wasn't required to handle place-of-memory at hitting limit. 
>    *just reducing the usage* was enough.
>    In this set, you try to handle memory shortage handling.
>    So, please handle NUMA, i.e. "what node do you want to reclaim memory from ?"
>    If not, 
>     - memory placement of Apps can be terrible.
>     - cannot work well with cpuset. (I think)
> 

try_to_free_mem_cgroup_pages() handles NUMA right? We start with the
node_zonelists of the current node on which we are executing.  I can pass on the
zonelist from __alloc_pages_internal() to try_to_free_mem_cgroup_pages(). Is
there anything else you had in mind?


> 3. I think  when "mem_cgroup_reclaim_on_contention" exits is unclear.
>    plz add explanation of algorithm. It returns when some pages are reclaimed ?
> 

Sure, I will do that.

> 4. When swap-full cgroup is on the top of heap, which tends to contain
>    tons of memory, much amount of cpu-time will be wasted.
>    Can we add "ignore me" flag  ?
> 

Could you elaborate on swap-full cgroup please? Are you referring to changes
introduced by the memcg-handle-swap-cache patch? I don't mind adding a ignore me
flag, but I guess we need to figure out when a cgroup is swap full.

> Maybe "2" is the most important to implement this.
> I think this feature itself is interesting, so please handle NUMA.
> 

Thanks, I'll definitely fix what ever is needed to make the functionality more
correct and useful.

> "4" includes the user's (middleware's) memcg handling problem. But maybe
> a problem should be fixed in future.

Thanks for the review!

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
