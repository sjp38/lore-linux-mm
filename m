Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id E184B6B0007
	for <linux-mm@kvack.org>; Mon,  8 Oct 2018 16:41:13 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id h76-v6so18383576pfd.10
        for <linux-mm@kvack.org>; Mon, 08 Oct 2018 13:41:13 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b66-v6sor15752400pfm.43.2018.10.08.13.41.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Oct 2018 13:41:12 -0700 (PDT)
Date: Mon, 8 Oct 2018 13:41:09 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mm: thp:  relax __GFP_THISNODE for MADV_HUGEPAGE
 mappings
In-Reply-To: <20181005232155.GA2298@redhat.com>
Message-ID: <alpine.DEB.2.21.1810081303060.221006@chino.kir.corp.google.com>
References: <20180925120326.24392-1-mhocko@kernel.org> <20180925120326.24392-2-mhocko@kernel.org> <alpine.DEB.2.21.1810041302330.16935@chino.kir.corp.google.com> <20181005073854.GB6931@suse.de> <alpine.DEB.2.21.1810051320270.202739@chino.kir.corp.google.com>
 <20181005232155.GA2298@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Fri, 5 Oct 2018, Andrea Arcangeli wrote:

> I tried to add just __GFP_NORETRY but it changes nothing. Try it
> yourself if you think that can resolve the swap storm and excessive
> reclaim CPU overhead... and see if it works. I didn't intend to
> reinvent the wheel with __GFP_COMPACT_ONLY, if __GFP_NORETRY would
> have worked. I tried adding __GFP_NORETRY first of course.
> 
> Reason why it doesn't help is: compaction fails because not enough
> free RAM, reclaim is invoked, compaction succeeds, THP is allocated to
> your lib user, compaction fails because not enough free RAM, reclaim
> is invoked etc.. compact_result is not COMPACT_DEFERRED, but
> COMPACT_SKIPPED.
> 
> See the part "reclaim is invoked" (with __GFP_THISNODE), is enough to
> still create the same heavy swap storm and unfairly penalize all apps
> with memory allocated in the local node like if your library had
> actually the kernel privilege to run mbind or mlock, which is not ok.
> 
> Only __GFP_COMPACT_ONLY truly can avoid reclaim, the moment reclaim
> can run with __GFP_THISNODE set, all bets are off and we're back to
> square one, no difference (at best marginal difference) with
> __GFP_NORETRY being set.
> 

The page allocator is expecting __GFP_NORETRY for thp allocations per its 
comment:

		/*
		 * Checks for costly allocations with __GFP_NORETRY, which
		 * includes THP page fault allocations
		 */
		if (costly_order && (gfp_mask & __GFP_NORETRY)) {

And that enables us to check compact_result to determine whether thp 
allocation should fail or continue to reclaim.  I don't think it helps 
that some thp fault allocations use __GFP_NORETRY and others do not.  I 
think that deserves a fix to alloc_hugepage_direct_gfpmask() or 
GFP_TRANSHUGE_LIGHT.

Our library that uses MADV_HUGEPAGE only invokes direct compaction because 
we're on an older kernel: it does not attempt to do reclaim to make 
compaction happy so that it finds memory that it can migrate memory to.  
For reference, we use defrag setting of "defer+madvise".  Everybody who 
does not use MADV_HUGEPAGE kicks off kswapd/kcompactd and fails, 
MADV_HUGEPAGE users do the same but also try direct compaction.  That 
direct compaction uses a mode of MIGRATE_ASYNC so it normally fails 
because of need_resched() or spinlock contention.

These allocations always fail, MADV_HUGEPAGE or otherwise, without 
invoking direct reclaim.

I am agreeing with both you and Mel that it makes no sense to thrash the 
local node to make compaction happy and then hugepage-order memory 
available.  I'm only differing with you on the mechanism to fail early: we 
never want to do attempt reclaim on thp allocations specifically because 
it leads to the behavior you are addressing.

My contention is that removing __GFP_THISNODE papers over the problem, 
especially in cases where remote memory is also fragmnented. It incurs a 
much higher (40%) fault latency and then incurs 13.9% greater access 
latency.  It is not a good result, at least for Haswell, Naples, and Rome.

To make a case that we should fault hugepages remotely as fallback, either 
for non-MADV_HUGEPAGE users who do not use direct compaction, or 
MADV_HUGEPAGE users who use direct compaction, we need numbers that 
suggest there is a performance benefit in terms of access latency to 
suggest that it is better; this is especially the case when the fault 
latency is 40% higher.  On Haswell, Naples, and Rome, it is quite obvious 
that this patch works much harder to fault memory remotely that incurs a 
substantial performance penalty when it fails and in the cases where it 
succeeds we have much worse access latency.

For users who bind their applications to a subset of cores on a NUMA node, 
fallback is egregious: we are guaranteed to never have local access 
latency and in the case when the local node is fragmented and remote 
memory is not our fault latency goes through the roof when local native 
pages would have been much better.

I've brought numbers on how poor this patch performs, so I'm asking for a 
rebuttal that suggests it is better on some platforms.  (1) On what 
platforms is it better to fault remote hugepages over local native pages?  
(2) What is the fault latency increase when remote nodes are fragmented as 
well?

> Like Mel said, your app just happens to fit in a local node, if the
> user of the lib is slightly different and allocates 16G on a system
> where each node is 4G, the post-fix MADV_HUGEPAGE will perform
> extremely better also for the lib user.
> 

It won't if the remote memory is fragmented; the patch is premised on the 
argument that remote memory is never fragmented or under memory pressure 
otherwise it is multiplying the fault latency by the number of nodes.  
Sure, creating test cases where the local node is under heavy memory 
pressure yet remote nodes are mostly free will minimize the impact this 
has on fault latency.  It still is a substantial increase, as I've 
measured on Haswell, but the access latency forever is the penalty.  This 
patch cannot make access to remote memory faster.

> And you know, if the lib user fits in one node, it can use mbind and
> it won't hit OOM... and you'd need some capability giving the app
> privilege anyway to keep MADV_HUGEPAGE as deep and unfair to the rest
> of the processes running the local node (like mbind and mlock require
> too).
> 

No, the lib user does not fit into a single node, we have cases where 
these nodes are under constant memory pressure.  We are on an older 
kernel, however, that fails because of need_resched() and spinlock 
contention rather than falling back to local reclaim.

> Did you try the __GFP_COMPACT_ONLY patch? That won't have the 40%
> fault latency already.
> 

I remember Kirill saying that he preferred node local memory allocation 
over thp allocation in the review, which I agree with, but it was much 
better than this patch.  I see no reason why we should work so hard to 
reclaim memory, thrash local memory, and swap so that the compaction 
freeing scanner can find memory when there is *no* guarantee that the 
migration scanner can free an entire pageblock.  That is completely 
pointless work, even for an MADV_HUGEPAGE user, and we certainly don't 
have such pathological behavior on older kernels.

> Also you're underestimating the benefit of THP given from remote nodes
> for virt a bit, the 40% fault latency is not an issue when the
> allocation is long lived, which is what MADV_HUGEPAGE is telling the
> kernel, and the benefit of THP for guest is multiplied. It's more a
> feature than a bug that 40% fault latency with MADV_HUGEPAGE set at
> least for all long lived allocations (but if the allocations aren't
> long lived, why should MADV_HUGEPAGE have been set in the first place?).
> 

For the long-term benefit of thp to outweigh the 40% fault latency 
increase, it would require that the access latency is better on remote 
memory.  It's worse, it's 13.9% worse access latency on Haswell.  It's a 
negative result for both allocation and access latency.

> With the fix applied, if you want to add __GFP_THISNODE to compaction
> only by default you still can, that solves the 40% fault latency just
> like __GFP_COMPACT_ONLY patch would also have avoided that 40%
> increased fault latency.
> 
> The issue here is very simple: you can't use __GFP_THISNODE for an
> allocation that can invoke reclaim, unless you have mlock or mbind
> higher privilege capabilities.
> 

Completely agreed, and I'm very strongly suggesting that we do not invoke 
reclaim.  Memory compaction provides no guarantee that it can free an 
entire pageblock, even for MIGRATE_ASYNC compaction under MADV_HUGEPAGE it 
will attempt to migrate SWAP_CLUSTER_MAX pages from a pageblock without 
considering if the entire pageblock could eventually become freed for 
order-9 memory.  The vast majority of the time this reclaim could be 
completely pointless.  We cannot use it.

> I'm still unconvinced about the __GFP_NORETRY arguments because I
> tried it already. However if you send a patch that fixes everything by
> only adding __GFP_NORETRY in every place you wish, I'd be glad to test
> it and verify if it actually solves the problem. Also note:
> 
> +#define __GFP_ONLY_COMPACT     ((__force gfp_t)(___GFP_NORETRY | \
> +                                                ___GFP_ONLY_COMPACT))
> 
> If ___GFP_NORETRY would have been enough __GFP_ONLY_COMPACT would have
> defined to ___GFP_NORETRY alone. When I figured it wasn't enough I
> added ___GFP_ONLY_COMPACT to retain the __GFP_THISNODE in the only
> place it's safe to retain it (i.e. compaction).
> 

We don't need __GFP_NORETRY anymore with this, it wouldn't be useful to 
continually compact memory in isolation if it already has failed.  It 
seems strange to be using __GFP_DIRECT_RECLAIM | __GFP_ONLY_COMPACT, 
though, as I assume this would evolve into.

Are there any other proposed users for __GFP_ONLY_COMPACT beyond thp 
allocations?  If not, we should just save the gfp bit and encode the logic 
directly into the page allocator.

Would you support this?
---
diff --git a/drivers/gpu/drm/ttm/ttm_page_alloc.c b/drivers/gpu/drm/ttm/ttm_page_alloc.c
--- a/drivers/gpu/drm/ttm/ttm_page_alloc.c
+++ b/drivers/gpu/drm/ttm/ttm_page_alloc.c
@@ -860,7 +860,7 @@ static int ttm_get_pages(struct page **pages, unsigned npages, int flags,
 			while (npages >= HPAGE_PMD_NR) {
 				gfp_t huge_flags = gfp_flags;
 
-				huge_flags |= GFP_TRANSHUGE_LIGHT | __GFP_NORETRY |
+				huge_flags |= GFP_TRANSHUGE_LIGHT |
 					__GFP_KSWAPD_RECLAIM;
 				huge_flags &= ~__GFP_MOVABLE;
 				huge_flags &= ~__GFP_COMP;
@@ -978,13 +978,13 @@ int ttm_page_alloc_init(struct ttm_mem_global *glob, unsigned max_pages)
 				  GFP_USER | GFP_DMA32, "uc dma", 0);
 
 	ttm_page_pool_init_locked(&_manager->wc_pool_huge,
-				  (GFP_TRANSHUGE_LIGHT | __GFP_NORETRY |
+				  (GFP_TRANSHUGE_LIGHT |
 				   __GFP_KSWAPD_RECLAIM) &
 				  ~(__GFP_MOVABLE | __GFP_COMP),
 				  "wc huge", order);
 
 	ttm_page_pool_init_locked(&_manager->uc_pool_huge,
-				  (GFP_TRANSHUGE_LIGHT | __GFP_NORETRY |
+				  (GFP_TRANSHUGE_LIGHT |
 				   __GFP_KSWAPD_RECLAIM) &
 				  ~(__GFP_MOVABLE | __GFP_COMP)
 				  , "uc huge", order);
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -298,7 +298,8 @@ struct vm_area_struct;
 #define GFP_HIGHUSER	(GFP_USER | __GFP_HIGHMEM)
 #define GFP_HIGHUSER_MOVABLE	(GFP_HIGHUSER | __GFP_MOVABLE)
 #define GFP_TRANSHUGE_LIGHT	((GFP_HIGHUSER_MOVABLE | __GFP_COMP | \
-			 __GFP_NOMEMALLOC | __GFP_NOWARN) & ~__GFP_RECLAIM)
+			 __GFP_NOMEMALLOC | __GFP_NORETRY | __GFP_NOWARN) & \
+			~__GFP_RECLAIM)
 #define GFP_TRANSHUGE	(GFP_TRANSHUGE_LIGHT | __GFP_DIRECT_RECLAIM)
 
 /* Convert GFP flags to their corresponding migrate type */
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -628,13 +628,15 @@ static vm_fault_t __do_huge_pmd_anonymous_page(struct vm_fault *vmf,
  * madvise: directly stall for MADV_HUGEPAGE, otherwise fail if not immediately
  *	    available
  * never: never stall for any thp allocation
+ *
+ * "Stalling" here implies direct memory compaction but not direct reclaim.
  */
 static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma)
 {
 	const bool vma_madvised = !!(vma->vm_flags & VM_HUGEPAGE);
 
 	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags))
-		return GFP_TRANSHUGE | (vma_madvised ? 0 : __GFP_NORETRY);
+		return GFP_TRANSHUGE;
 	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags))
 		return GFP_TRANSHUGE_LIGHT | __GFP_KSWAPD_RECLAIM;
 	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_OR_MADV_FLAG, &transparent_hugepage_flags))
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4145,6 +4145,18 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 			if (compact_result == COMPACT_DEFERRED)
 				goto nopage;
 
+			/*
+			 * If faulting a hugepage, it is very unlikely that
+			 * thrashing the zonelist is going to assist compaction
+			 * in freeing an entire pageblock.  There are no
+			 * guarantees memory compaction can free an entire
+			 * pageblock under such memory pressure that it is
+			 * better to simply fail and fallback to native pages.
+			 */
+			if (order == pageblock_order &&
+					!(current->flags & PF_KTHREAD))
+				goto nopage;
+
 			/*
 			 * Looks like reclaim/compaction is worth trying, but
 			 * sync compaction could be very expensive, so keep
