Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id jAL5b1Kt012424
	for <linux-mm@kvack.org>; Mon, 21 Nov 2005 00:37:01 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jAL5b1X1093122
	for <linux-mm@kvack.org>; Mon, 21 Nov 2005 00:37:01 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id jAL5b0Mt028215
	for <linux-mm@kvack.org>; Mon, 21 Nov 2005 00:37:00 -0500
Message-ID: <43815CFB.9040805@us.ibm.com>
Date: Sun, 20 Nov 2005 21:36:59 -0800
From: Matthew Dobson <colpatch@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/8] Critical Page Pool
References: <437E2C69.4000708@us.ibm.com> <437E2F22.6000809@argo.co.il> <437E30A8.1040307@us.ibm.com> <437E3CC2.6000003@argo.co.il>
In-Reply-To: <437E3CC2.6000003@argo.co.il>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Avi Kivity <avi@argo.co.il>
Cc: linux-kernel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Appologies for the delay in responding to comments, but I have been en
route to the East Coast of the US to visit family.

Avi Kivity wrote:
> Matthew Dobson wrote:
> 
>> Avi Kivity wrote:
>>  
>>
>>> 1. If you have two subsystems which allocate critical pages, how do you
>>> protect against the condition where one subsystem allocates all the
>>> critical memory, causing the second to oom?
>>>   
>>
>>
>> You don't.  You make sure that you size the critical pool
>> appropriately for
>> your workload.
>>
>>  
>>
> This may not be possible. What if subsystem A depends on subsystem B to
> do its work, both are critical, and subsystem A allocated all the memory
> reserve?
> If A and B have different allocation thresholds, the deadlock is avoided.
> 
> At the very least you need a critical pool per subsystem.

As Paul suggested in his follow up to your mail, to even attempt a
"guarantee" that you won't still run out of memory, your subsystem does
need an upper bound on how much memory it could possibly need.  If there is
NO upper limit, then the possibility of exhausting your critical pool is
very real.


>>> 2. There already exists a critical pool: ordinary allocations fail if
>>> free memory is below some limit, but special processes (kswapd) can
>>> allocate that memory by setting PF_MEMALLOC. Perhaps this should be
>>> extended, possibly with a per-process threshold.
>>>   
>>
>>
>> The exception for threads with PF_MEMALLOC set is there because those
>> threads are essentially promising that if the kernel gives them memory,
>> they will use that memory to free up MORE memory.  If we ignore that
>> promise, and (ab)use the PF_MEMALLOC flag to simply bypass the
>> zone_watermarks, we'll simply OOM faster, and potentially in situations
>> that could be avoided (ie: we steal memory that kswapd could have used to
>> free up more memory).
>>  
>>
> Sure, but that's just an example of a critical subsystem.
> 
> If we introduce yet another mechanism for critical memory allocation,
> we'll have a hard time making different subsystems, which use different
> critical allocation mechanisms, play well together.
> 
> I propose that instead of a single watermark, there should be a
> watermark per critical subsystem. The watermarks would be arranged
> according to the dependency graph, with the depended-on services allowed
> to go the deepest into the reserves.
> 
> (instead of PF_MEMALLOC have a tsk->memory_allocation_threshold, or
> similar. set it to 0 for kswapd, and for other systems according to taste)

Your idea is certainly an interesting approach to solving the problem.  I'm
not sure it quite does what I'm looking for, but I'll have to think about
your idea some more to be sure.  One problem is that networking doesn't
have a specific "task" associated with it, where we could set a
memory_allocation_threshold.

Thanks!

-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
