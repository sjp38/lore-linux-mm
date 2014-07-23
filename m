Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id B52AE6B0035
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 18:28:12 -0400 (EDT)
Received: by mail-ig0-f179.google.com with SMTP id h18so2000718igc.0
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 15:28:12 -0700 (PDT)
Received: from mail-ie0-x229.google.com (mail-ie0-x229.google.com [2607:f8b0:4001:c03::229])
        by mx.google.com with ESMTPS id is9si14393746igb.50.2014.07.23.15.28.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 23 Jul 2014 15:28:12 -0700 (PDT)
Received: by mail-ie0-f169.google.com with SMTP id rd18so1564088iec.0
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 15:28:11 -0700 (PDT)
Date: Wed, 23 Jul 2014 15:28:09 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [BUG] THP allocations escape cpuset when defrag is off
In-Reply-To: <20140723220538.GT8578@sgi.com>
Message-ID: <alpine.DEB.2.02.1407231516570.23495@chino.kir.corp.google.com>
References: <20140723220538.GT8578@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, riel@redhat.com, kirill.shutemov@linux.intel.com, mingo@kernel.org, hughd@google.com, lliubbo@gmail.com, hannes@cmpxchg.org, srivatsa.bhat@linux.vnet.ibm.com, dave.hansen@linux.intel.com, dfults@sgi.com, hedi@sgi.com

On Wed, 23 Jul 2014, Alex Thorlton wrote:

> Hey everyone,
> 
> We're hitting an interesting bug on systems with THP defrag turned off.
> It seems that we're able to make very large THP allocations outside of
> our cpuset.  Here's the test procedure I've been using:
> 
> - Create a mem_exclusive/hardwall cpuset that is restricted to memory
>   on one node.
> - Turn off swap (swapoff -a).  This step is not explicitly necessary,
>   but it appears to speed up the reaction time of the OOM killer
>   considerably.
> - Turn off THP compaction/defrag.
> - Run memhog inside the cpuset.  Tell it to allocate far more memory
>   than should be available inside the cpuset.
> 
> Quick example:
> 
> # cat /sys/kernel/mm/transparent_hugepage/enabled
> [always] madvise never
> # cat /sys/kernel/mm/transparent_hugepage/defrag
> always madvise [never]
> # grep "[0-9]" cpu* mem*         <-- from /dev/cpuset/test01
> cpu_exclusive:0
> cpus:8-15
> mem_exclusive:1
> mem_hardwall:1
> memory_migrate:0
> memory_pressure:0
> memory_spread_page:1
> memory_spread_slab:1
> mems:1                           <-- ~32g per node
> # cat /proc/self/cpuset
> /test01
> # memhog 80g > /dev/null
> (Runs to completion, which is the bug)
> 
> Monitoring 'numactl --hardware' with watch, you can see memhog's
> allocations start spilling over onto the other nodes.  Take note that
> this can be somewhat intermittent.  Often when running this test
> immediately after a boot, the OOM killer will catch memhog and stop it
> immediately, but subsequent runs can either run to completion, or at
> least soak up good chunks of memory on nodes which they're not supposed
> to be permitted to allocate memory on, before being killed.  I'm not
> positive on all the factors that influence this timing yet.  It seems to
> reproduce very reliably if you toggle swap back and forth with each run:
> 
> (Run before this was killed by OOM with swap off)
> # swapon -a
> # memhog 80g > /dev/null
> # swapoff -a
> # memhog 80g > /dev/null
> (Both of these ran to completion.  Again, a sign of the bug)
> 
> After digging through the code quite a bit, I've managed to turn up
> something that I think could be the cause of the problem here.  In
> alloc_hugepage_vma we send a gfp_mask generated using
> alloc_hugepage_gfpmask, which removes the ___GFP_WAIT bit from the
> gfp_mask when defrag is off.
> 
> Further down in pagefault code path, when we fall back to the slowpath
> for allocations (from my testing, this fallback appears to happen around
> the same time that we run out of memory on our cpuset's node), we see
> that, without the ___GFP_WAIT bit set, we will clear the ALLOC_CPUSET
> flag from alloc_flags, which in turn allows us to grab memory from
> any node. (See __alloc_pages_slowpath and gfp_to_alloc_flags to see
> where ALLOC_CPUSET gets wiped out).
> 
> This simple patch seems to keep things inside our cpuset:
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 33514d8..7a05576 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -754,7 +754,7 @@ static int __do_huge_pmd_anonymous_page(struct
> mm_struct *mm,
> 
>  static inline gfp_t alloc_hugepage_gfpmask(int defrag, gfp_t extra_gfp)
>  {
> -       return (GFP_TRANSHUGE & ~(defrag ? 0 : __GFP_WAIT)) | extra_gfp;
> +       return GFP_TRANSHUGE | extra_gfp;
>  }
> 
> My debug code shows that certain code paths are still allowing
> ALLOC_CPUSET to get pulled off the alloc_flags with the patch, but
> monitoring the memory usage shows that we're staying on node, aside from
> some very small allocations, which may be other types of allocations that
> are not necessarly confined to a cpuset.  Need a bit more research to
> confirm that.
> 

ALLOC_CPUSET should get stripped for the cases outlined in 
__cpuset_node_allowed_softwall(), specifically for GFP_ATOMIC which does 
not have __GFP_WAIT set.

> So, my question ends up being, why do we wipe out ___GFP_WAIT when
> defrag is off?  I'll trust that there is good reason to do that, but, if
> so, is the behavior that I'm seeing expected?
> 

The intention is to avoid memory compaction (and direct reclaim), 
obviously, which does not run when __GFP_WAIT is not set.  But you're 
exactly right that this abuses the allocflags conversion that allows 
ALLOC_CPUSET to get cleared because it is using the aforementioned 
GFP_ATOMIC exception for cpuset allocation.

We can't use PF_MEMALLOC or TIF_MEMDIE for hugepage allocation because it 
affects the allowed watermarks and nothing else prevents memory compaction 
or direct reclaim from running in the page allocator slowpath.

So it looks like a modification to the page allocator is needed, see 
below.

It's also been a long-standing issue that cpusets and mempolicies are 
ignored by khugepaged that allows memory to be migrated remotely to nodes 
that are not allowed by a cpuset's mems or a mempolicy's nodemask.  Even 
with this issue fixed, you may find that some memory is migrated remotely, 
although it may be negligible, by khugepaged.

 [ We should really rename __GFP_NO_KSWAPD to __GFP_THP and not allow the
   other users to piggyback off it. ]
---
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2447,7 +2447,8 @@ static inline int
 gfp_to_alloc_flags(gfp_t gfp_mask)
 {
 	int alloc_flags = ALLOC_WMARK_MIN | ALLOC_CPUSET;
-	const gfp_t wait = gfp_mask & __GFP_WAIT;
+	const bool atomic = (gfp_mask & (__GFP_WAIT | __GFP_NO_KSWAPD)) ==
+			    __GFP_WAIT;
 
 	/* __GFP_HIGH is assumed to be the same as ALLOC_HIGH to save a branch. */
 	BUILD_BUG_ON(__GFP_HIGH != (__force gfp_t) ALLOC_HIGH);
@@ -2456,20 +2457,20 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 	 * The caller may dip into page reserves a bit more if the caller
 	 * cannot run direct reclaim, or if the caller has realtime scheduling
 	 * policy or is asking for __GFP_HIGH memory.  GFP_ATOMIC requests will
-	 * set both ALLOC_HARDER (!wait) and ALLOC_HIGH (__GFP_HIGH).
+	 * set both ALLOC_HARDER (atomic == true) and ALLOC_HIGH (__GFP_HIGH).
 	 */
 	alloc_flags |= (__force int) (gfp_mask & __GFP_HIGH);
 
-	if (!wait) {
+	if (atomic) {
 		/*
 		 * Not worth trying to allocate harder for
 		 * __GFP_NOMEMALLOC even if it can't schedule.
 		 */
-		if  (!(gfp_mask & __GFP_NOMEMALLOC))
+		if (!(gfp_mask & __GFP_NOMEMALLOC))
 			alloc_flags |= ALLOC_HARDER;
 		/*
-		 * Ignore cpuset if GFP_ATOMIC (!wait) rather than fail alloc.
-		 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
+		 * Ignore cpuset for GFP_ATOMIC rather than fail alloc.
+		 * See also cpuset_zone_allowed_softwall() comment.
 		 */
 		alloc_flags &= ~ALLOC_CPUSET;
 	} else if (unlikely(rt_task(current)) && !in_interrupt())

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
