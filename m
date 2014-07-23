Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f175.google.com (mail-yk0-f175.google.com [209.85.160.175])
	by kanga.kvack.org (Postfix) with ESMTP id 287696B0035
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 18:05:07 -0400 (EDT)
Received: by mail-yk0-f175.google.com with SMTP id q200so1224089ykb.34
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 15:05:06 -0700 (PDT)
Received: from relay.sgi.com (relay3.sgi.com. [192.48.152.1])
        by mx.google.com with ESMTP id v35si12180777yhp.208.2014.07.23.15.05.06
        for <linux-mm@kvack.org>;
        Wed, 23 Jul 2014 15:05:06 -0700 (PDT)
Date: Wed, 23 Jul 2014 17:05:38 -0500
From: Alex Thorlton <athorlton@sgi.com>
Subject: [BUG] THP allocations escape cpuset when defrag is off
Message-ID: <20140723220538.GT8578@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, mgorman@suse.de, riel@redhat.com, kirill.shutemov@linux.intel.com, mingo@kernel.org, hughd@google.com, lliubbo@gmail.com, hannes@cmpxchg.org, rientjes@google.com, srivatsa.bhat@linux.vnet.ibm.com, dave.hansen@linux.intel.com, dfults@sgi.com, hedi@sgi.com

Hey everyone,

We're hitting an interesting bug on systems with THP defrag turned off.
It seems that we're able to make very large THP allocations outside of
our cpuset.  Here's the test procedure I've been using:

- Create a mem_exclusive/hardwall cpuset that is restricted to memory
  on one node.
- Turn off swap (swapoff -a).  This step is not explicitly necessary,
  but it appears to speed up the reaction time of the OOM killer
  considerably.
- Turn off THP compaction/defrag.
- Run memhog inside the cpuset.  Tell it to allocate far more memory
  than should be available inside the cpuset.

Quick example:

# cat /sys/kernel/mm/transparent_hugepage/enabled
[always] madvise never
# cat /sys/kernel/mm/transparent_hugepage/defrag
always madvise [never]
# grep "[0-9]" cpu* mem*         <-- from /dev/cpuset/test01
cpu_exclusive:0
cpus:8-15
mem_exclusive:1
mem_hardwall:1
memory_migrate:0
memory_pressure:0
memory_spread_page:1
memory_spread_slab:1
mems:1                           <-- ~32g per node
# cat /proc/self/cpuset
/test01
# memhog 80g > /dev/null
(Runs to completion, which is the bug)

Monitoring 'numactl --hardware' with watch, you can see memhog's
allocations start spilling over onto the other nodes.  Take note that
this can be somewhat intermittent.  Often when running this test
immediately after a boot, the OOM killer will catch memhog and stop it
immediately, but subsequent runs can either run to completion, or at
least soak up good chunks of memory on nodes which they're not supposed
to be permitted to allocate memory on, before being killed.  I'm not
positive on all the factors that influence this timing yet.  It seems to
reproduce very reliably if you toggle swap back and forth with each run:

(Run before this was killed by OOM with swap off)
# swapon -a
# memhog 80g > /dev/null
# swapoff -a
# memhog 80g > /dev/null
(Both of these ran to completion.  Again, a sign of the bug)

After digging through the code quite a bit, I've managed to turn up
something that I think could be the cause of the problem here.  In
alloc_hugepage_vma we send a gfp_mask generated using
alloc_hugepage_gfpmask, which removes the ___GFP_WAIT bit from the
gfp_mask when defrag is off.

Further down in pagefault code path, when we fall back to the slowpath
for allocations (from my testing, this fallback appears to happen around
the same time that we run out of memory on our cpuset's node), we see
that, without the ___GFP_WAIT bit set, we will clear the ALLOC_CPUSET
flag from alloc_flags, which in turn allows us to grab memory from
any node. (See __alloc_pages_slowpath and gfp_to_alloc_flags to see
where ALLOC_CPUSET gets wiped out).

This simple patch seems to keep things inside our cpuset:

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 33514d8..7a05576 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -754,7 +754,7 @@ static int __do_huge_pmd_anonymous_page(struct
mm_struct *mm,

 static inline gfp_t alloc_hugepage_gfpmask(int defrag, gfp_t extra_gfp)
 {
-       return (GFP_TRANSHUGE & ~(defrag ? 0 : __GFP_WAIT)) | extra_gfp;
+       return GFP_TRANSHUGE | extra_gfp;
 }

My debug code shows that certain code paths are still allowing
ALLOC_CPUSET to get pulled off the alloc_flags with the patch, but
monitoring the memory usage shows that we're staying on node, aside from
some very small allocations, which may be other types of allocations that
are not necessarly confined to a cpuset.  Need a bit more research to
confirm that.

So, my question ends up being, why do we wipe out ___GFP_WAIT when
defrag is off?  I'll trust that there is good reason to do that, but, if
so, is the behavior that I'm seeing expected?

Any input is greatly appreciated.  Thanks!

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
