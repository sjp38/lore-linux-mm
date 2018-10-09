Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5BE896B026F
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 18:21:34 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id p128-v6so3033719qke.13
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 15:21:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c14-v6si5403290qvs.97.2018.10.09.15.21.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 15:21:32 -0700 (PDT)
Date: Tue, 9 Oct 2018 18:21:29 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/2] mm: thp:  relax __GFP_THISNODE for MADV_HUGEPAGE
 mappings
Message-ID: <20181009222129.GC9307@redhat.com>
References: <20180925120326.24392-1-mhocko@kernel.org>
 <20180925120326.24392-2-mhocko@kernel.org>
 <alpine.DEB.2.21.1810041302330.16935@chino.kir.corp.google.com>
 <20181005073854.GB6931@suse.de>
 <alpine.DEB.2.21.1810051320270.202739@chino.kir.corp.google.com>
 <20181005232155.GA2298@redhat.com>
 <alpine.DEB.2.21.1810081303060.221006@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1810081303060.221006@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Mon, Oct 08, 2018 at 01:41:09PM -0700, David Rientjes wrote:
> The page allocator is expecting __GFP_NORETRY for thp allocations per its 
> comment:
> 
> 		/*
> 		 * Checks for costly allocations with __GFP_NORETRY, which
> 		 * includes THP page fault allocations
> 		 */
> 		if (costly_order && (gfp_mask & __GFP_NORETRY)) {
> 
> And that enables us to check compact_result to determine whether thp 
> allocation should fail or continue to reclaim.  I don't think it helps 
> that some thp fault allocations use __GFP_NORETRY and others do not.  I 
> think that deserves a fix to alloc_hugepage_direct_gfpmask() or 
> GFP_TRANSHUGE_LIGHT.

With your patch that changes how __GFP_NORETRY works for order =
pageblock_order then this can help. However it solves nothing for
large skbs and all other "costly_order" allocations. So if you think
it's so bad to have a 40% increased allocation latency if all nodes
are heavily fragmented for THP under MADV_HUGEPAGE (which are
guaranteed to be long lived allocations or they wouldn't set
MADV_HUGEPAGE in the first place), I'm not sure why you ignore the
same exact overhead for all other "costly_order" allocations that
would never set __GFP_THISNODE and will not even use
GFP_TRANSHUGE_LIGHT so they may not set __GFP_NORETRY at all.

I think it would be better to view the problem from a generic
"costly_order" allocation prospective without so much "hardcoded"
focus on THP MADV_HUGEPAGE only (which in fact are the least concern
of all in terms of that 40% latency increase if all nodes are totally
fragmented and compaction fails on all nodes, because they're long
lived so the impact of the increased latency is more likely to be lost
in the noise).

> Our library that uses MADV_HUGEPAGE only invokes direct compaction because 
> we're on an older kernel: it does not attempt to do reclaim to make 
> compaction happy so that it finds memory that it can migrate memory to.  
> For reference, we use defrag setting of "defer+madvise".  Everybody who 
> does not use MADV_HUGEPAGE kicks off kswapd/kcompactd and fails, 
> MADV_HUGEPAGE users do the same but also try direct compaction.  That 
> direct compaction uses a mode of MIGRATE_ASYNC so it normally fails 
> because of need_resched() or spinlock contention.
> These allocations always fail, MADV_HUGEPAGE or otherwise, without 
> invoking direct reclaim.

Even older kernels (before "defer+madvise" option was available)
always invoked reclaim if COMPACT_SKIPPED was returned. The
COMPACT_SKIPPED behavior I referred that explains why __GFP_NORETRY
doesn't prevent reclaim to be invoked, is nothing new, it always
worked that way from the day compaction was introduced.

So it's fairly strange that your kernel doesn't call reclaim at all if
COMPACT_SKIPPED is returned.

> I am agreeing with both you and Mel that it makes no sense to thrash the 
> local node to make compaction happy and then hugepage-order memory 
> available.  I'm only differing with you on the mechanism to fail early: we 
> never want to do attempt reclaim on thp allocations specifically because 
> it leads to the behavior you are addressing.

Not sure I can agree with the above.

If all nodes (not only the local one) are already below the watermarks
and compaction returns COMPACT_SKIPPED, there is zero global free
memory available, we would need to swap anyway to succeed the 2M
allocation. So it's better to reclaim 2M from on node and then retry
compaction again on the same node if compaction is failing on the node
because of COMPACT_SKIPPED and the global free memory is zero. If it
swapouts it would have swapped out anyway but this way THP will be
returned.

It's just __GFP_THISNODE that broke the above logic. __GFP_THISNODE
may just be safe to use only if the global amount of free memory (in
all nodes) is zero (or below HPAGE_PMD_SIZE generally speaking).

> My contention is that removing __GFP_THISNODE papers over the problem, 
> especially in cases where remote memory is also fragmnented. It incurs a 
> much higher (40%) fault latency and then incurs 13.9% greater access 
> latency.  It is not a good result, at least for Haswell, Naples, and Rome.
> 
> To make a case that we should fault hugepages remotely as fallback, either 
> for non-MADV_HUGEPAGE users who do not use direct compaction, or 
> MADV_HUGEPAGE users who use direct compaction, we need numbers that 
> suggest there is a performance benefit in terms of access latency to 
> suggest that it is better; this is especially the case when the fault 
> latency is 40% higher.  On Haswell, Naples, and Rome, it is quite obvious 
> that this patch works much harder to fault memory remotely that incurs a 
> substantial performance penalty when it fails and in the cases where it 
> succeeds we have much worse access latency.

What we're fixing is a effectively a breakage and insecure behavior
too and that must be fixed first. A heavily multithreaded processes
with its memory not fitting in a single NUMA node is too common of a
workload to misbehave so bad as it did. The above issue is a much
smaller concern and it's not a breakage nor insecure.

__GFP_THISNODE semantics are not enough to express what you need
there.

Like Mel said we need two tests, one that represents the "pathological
THP allocation behavior" which is trivial (any heavy multithreaded app
accessing all memory of all nodes from all CPUs will do). And one that
represents your workload.

By thinking about it, it's almost impossible that eliminating 100% of
swapouts from the multithreaded app runtime, will not bring a benefit
that is orders of magnitude bigger than the elimination of remote
compaction and having more local THP pages for your app.

It's just on a different scale and the old behavior was insecure to
begin with because it allowed a process to heavily penalize the
runtime of other apps running with different uid, without requiring
any privilege.

> For users who bind their applications to a subset of cores on a NUMA node, 
> fallback is egregious: we are guaranteed to never have local access 
> latency and in the case when the local node is fragmented and remote 
> memory is not our fault latency goes through the roof when local native 
> pages would have been much better.
> 
> I've brought numbers on how poor this patch performs, so I'm asking for a 
> rebuttal that suggests it is better on some platforms.  (1) On what 
> platforms is it better to fault remote hugepages over local native pages?  
> (2) What is the fault latency increase when remote nodes are fragmented as 
> well?

That I don't think is the primary issue, the issue here is the one of
the previous paragrah.

Then there may be workloads and/or platforms where allocating remote
THP instead of local PAGE_SIZEd memory is better regardless and
__GFP_THISNODE hurted twice (but we could ignore those for now, and
just focus where __GFP_THISNODE provided a benefit like for your app
using the lib).

> > Like Mel said, your app just happens to fit in a local node, if the
> > user of the lib is slightly different and allocates 16G on a system
> > where each node is 4G, the post-fix MADV_HUGEPAGE will perform
> > extremely better also for the lib user.
> > 
> 
> It won't if the remote memory is fragmented; the patch is premised on the 

How could compaction run slower than heavy swapping gigabytes of
memory?

> argument that remote memory is never fragmented or under memory pressure 
> otherwise it is multiplying the fault latency by the number of nodes.  
> Sure, creating test cases where the local node is under heavy memory 
> pressure yet remote nodes are mostly free will minimize the impact this 
> has on fault latency.  It still is a substantial increase, as I've 
> measured on Haswell, but the access latency forever is the penalty.  This 
> patch cannot make access to remote memory faster.

I still doubt you measured the performance of the app using the lib
when the app requires more 4 times the size of the local NUMA node
under "taskset -c 0". If you do that, the app using the lib shall fall
into the "pathological THP allocation behavior" too. As long as the
spillover is 10-20% perhaps it's not as bad and if it's not heavily
multithreaded doing scattered random access like a virtual machine
will do, NUMA balancing will hide the issue by moving the thread to
CPU of the NUMA node where the 10-20% spillover happened (which is why
I asked "taskset -c 0" to simulate a multithreaded app accessing all
memory in a scattered way without locality.

The multithreaded app with scattered access is not unreasonable
workload and it must perform well: all workloads using MPOL_INTERLEAVE
would fit the criteria, not just qemu.

> > And you know, if the lib user fits in one node, it can use mbind and
> > it won't hit OOM... and you'd need some capability giving the app
> > privilege anyway to keep MADV_HUGEPAGE as deep and unfair to the rest
> > of the processes running the local node (like mbind and mlock require
> > too).
> > 
> 
> No, the lib user does not fit into a single node, we have cases where 
> these nodes are under constant memory pressure.  We are on an older 
> kernel, however, that fails because of need_resched() and spinlock 
> contention rather than falling back to local reclaim.

It's unclear which need_resched() and spinlock contention induces this
failure.

> > Did you try the __GFP_COMPACT_ONLY patch? That won't have the 40%
> > fault latency already.
> > 
> 
> I remember Kirill saying that he preferred node local memory allocation 
> over thp allocation in the review, which I agree with, but it was much 
> better than this patch.  I see no reason why we should work so hard to 
> reclaim memory, thrash local memory, and swap so that the compaction 
> freeing scanner can find memory when there is *no* guarantee that the 
> migration scanner can free an entire pageblock.  That is completely 
> pointless work, even for an MADV_HUGEPAGE user, and we certainly don't 
> have such pathological behavior on older kernels.

The compaction scanner is succeeding at migrating the entire
pageblock every time. The local node isn't so fragmented, it's just
full of anonymous memory that is getting swapped out at every further
invocation of reclaim. If it was fragmented __GFP_NORETRY would have
had an effect because compaction would have been deferred.

> Completely agreed, and I'm very strongly suggesting that we do not invoke 
> reclaim.  Memory compaction provides no guarantee that it can free an 
> entire pageblock, even for MIGRATE_ASYNC compaction under MADV_HUGEPAGE it 
> will attempt to migrate SWAP_CLUSTER_MAX pages from a pageblock without 
> considering if the entire pageblock could eventually become freed for 
> order-9 memory.  The vast majority of the time this reclaim could be 
> completely pointless.  We cannot use it.

If we don't invoke reclaim __GFP_THISNODE is fine to keep, however
that means direction compaction doesn't work at all if all nodes are
full of filesystem cache. This was a drawback of __GFP_COMPACT_ONLY
too. A minor one compared to the corner case created by
__GFP_THISNODE.

> We don't need __GFP_NORETRY anymore with this, it wouldn't be useful to 
> continually compact memory in isolation if it already has failed.  It 
> seems strange to be using __GFP_DIRECT_RECLAIM | __GFP_ONLY_COMPACT, 
> though, as I assume this would evolve into.
> 
> Are there any other proposed users for __GFP_ONLY_COMPACT beyond thp 
> allocations?  If not, we should just save the gfp bit and encode the logic 
> directly into the page allocator.

Yes that's seems equivalent, just it embeds __GFP_COMPACT_ONLY in
__GFP_NORETRY and ends up setting __GFP_NORETRY for everything,
__GFP_COMPACT_ONLY didn't alter the __GFP_NORETRY semantics instead.

> Would you support this?

I didn't consider it a problem the 40% increased allocation latency, I
thought __GFP_COMPACT_ONLY or the other fix in -mm was just about the
remote THP vs local PAGE_SIZEd memory tradeoff (considering this logic
was already hardcoded only for THP so I tried to keep it).

Now that you raise this higher compaction latency as a big regression
in not fixing the VM with __GFP_COMPACT_ONLY semantics in
__GFP_NORETRY, the next question is why you don't care at all about
such increased latency for all other "costly_order" allocations that
won't use __GFP_THISNODE and where your altered __GFP_NORETRY won't
help to skip compaction on the remote nodes.

In other words if such compaction invocation in fully fragmented
remote nodes is such a big concern for THP, why is not an issue at all
for all other "costly_order" allocations?

> +			if (order == pageblock_order &&
> +					!(current->flags & PF_KTHREAD))
> +				goto nopage;

For a more reliable THP hardcoding HPAGE_PMD_ORDER would be better
than pageblock_order (I guess especially for non-x86 archs where the
match between hugetlbfs size and thp size is less obvious), but then
the hardcoding itself now looks the worst part of this patch if the
concern is the 40% increased allocation latency (and not only the
remote compound page vs local 4k page).

Thanks,
Andrea
