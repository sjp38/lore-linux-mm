Message-ID: <437E3CC2.6000003@argo.co.il>
Date: Fri, 18 Nov 2005 22:42:42 +0200
From: Avi Kivity <avi@argo.co.il>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/8] Critical Page Pool
References: <437E2C69.4000708@us.ibm.com> <437E2F22.6000809@argo.co.il> <437E30A8.1040307@us.ibm.com>
In-Reply-To: <437E30A8.1040307@us.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dobson <colpatch@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Matthew Dobson wrote:

>Avi Kivity wrote:
>  
>
>>1. If you have two subsystems which allocate critical pages, how do you
>>protect against the condition where one subsystem allocates all the
>>critical memory, causing the second to oom?
>>    
>>
>
>You don't.  You make sure that you size the critical pool appropriately for
>your workload.
>
>  
>
This may not be possible. What if subsystem A depends on subsystem B to 
do its work, both are critical, and subsystem A allocated all the memory 
reserve?
If A and B have different allocation thresholds, the deadlock is avoided.

At the very least you need a critical pool per subsystem.

>  
>
>>2. There already exists a critical pool: ordinary allocations fail if
>>free memory is below some limit, but special processes (kswapd) can
>>allocate that memory by setting PF_MEMALLOC. Perhaps this should be
>>extended, possibly with a per-process threshold.
>>    
>>
>
>The exception for threads with PF_MEMALLOC set is there because those
>threads are essentially promising that if the kernel gives them memory,
>they will use that memory to free up MORE memory.  If we ignore that
>promise, and (ab)use the PF_MEMALLOC flag to simply bypass the
>zone_watermarks, we'll simply OOM faster, and potentially in situations
>that could be avoided (ie: we steal memory that kswapd could have used to
>free up more memory).
>  
>
Sure, but that's just an example of a critical subsystem.

If we introduce yet another mechanism for critical memory allocation, 
we'll have a hard time making different subsystems, which use different 
critical allocation mechanisms, play well together.

I propose that instead of a single watermark, there should be a 
watermark per critical subsystem. The watermarks would be arranged 
according to the dependency graph, with the depended-on services allowed 
to go the deepest into the reserves.

(instead of PF_MEMALLOC have a tsk->memory_allocation_threshold, or 
similar. set it to 0 for kswapd, and for other systems according to taste)

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
