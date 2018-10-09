Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8BD3F6B000D
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 05:48:33 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id e3-v6so606836pld.13
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 02:48:33 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n15-v6si21375189pgc.143.2018.10.09.02.48.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 02:48:31 -0700 (PDT)
Date: Tue, 9 Oct 2018 10:48:25 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/2] mm: thp:  relax __GFP_THISNODE for MADV_HUGEPAGE
 mappings
Message-ID: <20181009094825.GC6931@suse.de>
References: <20180925120326.24392-1-mhocko@kernel.org>
 <20180925120326.24392-2-mhocko@kernel.org>
 <alpine.DEB.2.21.1810041302330.16935@chino.kir.corp.google.com>
 <20181005073854.GB6931@suse.de>
 <alpine.DEB.2.21.1810051320270.202739@chino.kir.corp.google.com>
 <20181005232155.GA2298@redhat.com>
 <alpine.DEB.2.21.1810081303060.221006@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1810081303060.221006@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Mon, Oct 08, 2018 at 01:41:09PM -0700, David Rientjes wrote:
> On Fri, 5 Oct 2018, Andrea Arcangeli wrote:
> 
> > I tried to add just __GFP_NORETRY but it changes nothing. Try it
> > yourself if you think that can resolve the swap storm and excessive
> > reclaim CPU overhead... and see if it works. I didn't intend to
> > reinvent the wheel with __GFP_COMPACT_ONLY, if __GFP_NORETRY would
> > have worked. I tried adding __GFP_NORETRY first of course.
> > 
> > Reason why it doesn't help is: compaction fails because not enough
> > free RAM, reclaim is invoked, compaction succeeds, THP is allocated to
> > your lib user, compaction fails because not enough free RAM, reclaim
> > is invoked etc.. compact_result is not COMPACT_DEFERRED, but
> > COMPACT_SKIPPED.
> > 
> > See the part "reclaim is invoked" (with __GFP_THISNODE), is enough to
> > still create the same heavy swap storm and unfairly penalize all apps
> > with memory allocated in the local node like if your library had
> > actually the kernel privilege to run mbind or mlock, which is not ok.
> > 
> > Only __GFP_COMPACT_ONLY truly can avoid reclaim, the moment reclaim
> > can run with __GFP_THISNODE set, all bets are off and we're back to
> > square one, no difference (at best marginal difference) with
> > __GFP_NORETRY being set.
> > 
> 
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
> 

I am concerned that we may be trying to deal with this in terms of right
and wrong when the range of workloads and their preferred semantics
force us into a grey area.

The THP user without __GFP_NORETRY is "always"

always
        means that an application requesting THP will stall on
        allocation failure and directly reclaim pages and compact
        memory in an effort to allocate a THP immediately. This may be
        desirable for virtual machines that benefit heavily from THP
        use and are willing to delay the VM start to utilise them.

Removing __GFP_NORETRY in this instance is due to the tuning hinting that
direct reclaim is prefectly acceptable. __GFP_NORETRY means that the kernel
will not compact memory after a recent failure but if the caller is willing
to reclaim memory, then it follows that retrying compaction is justified.

Is this the correct thing to do in 100% of cases? Probably not, there
will be corner cases but it also does not necessarily follow that
__GFP_NORETRY should be univeral.

What is missing here is an agreed upon set of reference test cases
that can be used for the basis of evaluating patches like this. They
should be somewhat representative of the target applications of virtual
memory initialisation (forget about runtime at the moment as that is
stacking problems), a simulator of the google workload and library and
my test case of simply referencing an amount of memory larger than one
node. That would cover the current discussion at least but more would be
needed later. Otherwise we're going to endlessly whack-a-mole fixing one
workload and hurting another. It might be overkill but otherwise this
discussion risks going in circles.

The previous reference cases were ones that focused on either THP
allocation success rates or the benefit of THP itself, neither of which
are particularly useful in the current context.

> Our library that uses MADV_HUGEPAGE only invokes direct compaction because 
> we're on an older kernel: it does not attempt to do reclaim to make 
> compaction happy so that it finds memory that it can migrate memory to.  
> For reference, we use defrag setting of "defer+madvise".  Everybody who 
> does not use MADV_HUGEPAGE kicks off kswapd/kcompactd and fails, 
> MADV_HUGEPAGE users do the same but also try direct compaction.  That 
> direct compaction uses a mode of MIGRATE_ASYNC so it normally fails 
> because of need_resched() or spinlock contention.
> 
> These allocations always fail, MADV_HUGEPAGE or otherwise, without 
> invoking direct reclaim.
> 
> I am agreeing with both you and Mel that it makes no sense to thrash the 
> local node to make compaction happy and then hugepage-order memory 
> available.  I'm only differing with you on the mechanism to fail early: we 
> never want to do attempt reclaim on thp allocations specifically because 
> it leads to the behavior you are addressing.
> 
> My contention is that removing __GFP_THISNODE papers over the problem, 
> especially in cases where remote memory is also fragmnented. It incurs a 
> much higher (40%) fault latency and then incurs 13.9% greater access 
> latency.  It is not a good result, at least for Haswell, Naples, and Rome.
> 

Ok, this is a good point. MADV_HUGEPAGE is hinting that huge pages
are desired and in recent kernels, that also meant they would be local
pages i.e. locality is more important than huge pages even if huge pages
are desirable. With this change, it indicates that huge pages are more
important than locality because that is what userspace hinted.

Which is better?

locality is more important if your workload fits in memory and the
	initialisation phase is not performance-critical. It would
	also be more important if your workload is larger than a
	node but the critical working set fits within a node while
	the other usages are like streaming readers and writers where
	the data is referenced once and can be safely reclaimed later.
huge pages is more important if your workload is virtualised and
	benefits heavily due to reduced TLB cost from EPT.
	Similarly it's better if the workload has high special locality,
	particularly if it is also fitting within a cache where the
	remote cost is masked.

These are simple examples and even then we cannot detect which case
applies in advance so it falls back to what does the hint mean? The name
suggests that huge pages are desirable and the locality is a hint. Granted,
if that means THP is going remote and incurring cost there, it might be
worse overall for some workloads, particularly if the system is fragmented.

This goes back to my point that the MADV_HUGEPAGE hint should not make
promises about locality and that introducing MADV_LOCAL for specialised
libraries may be more appropriate with the initial semantic being how it
treats MADV_HUGEPAGE regions.

> To make a case that we should fault hugepages remotely as fallback, either 
> for non-MADV_HUGEPAGE users who do not use direct compaction, or 
> MADV_HUGEPAGE users who use direct compaction, we need numbers that 
> suggest there is a performance benefit in terms of access latency to 
> suggest that it is better; this is especially the case when the fault 
> latency is 40% higher.  On Haswell, Naples, and Rome, it is quite obvious 
> that this patch works much harder to fault memory remotely that incurs a 
> substantial performance penalty when it fails and in the cases where it 
> succeeds we have much worse access latency.
> 
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
> 

On the flip side, we've also heard how some other applications are
adversely affected such as virtual machine start-ups.

What you're asking for asking is an astonishing amount of work --
a multi platform study against a wide variety of workloads with the
addition that some test should be able to start in a fragmented state
that is reproducible.

What is being asked of you is to consider introducing a new madvise hint and
having MADV_HUGEPAGE being about huge pages and introducing a new hint that
is hinting about locality without the strictness of memory binding. That
is significantly more tractable and you also presumably have access to
a reasonable reproduction cases even though I doubt you can release it.

> > Like Mel said, your app just happens to fit in a local node, if the
> > user of the lib is slightly different and allocates 16G on a system
> > where each node is 4G, the post-fix MADV_HUGEPAGE will perform
> > extremely better also for the lib user.
> > 
> 
> It won't if the remote memory is fragmented; the patch is premised on the 
> argument that remote memory is never fragmented or under memory pressure 
> otherwise it is multiplying the fault latency by the number of nodes.  
> Sure, creating test cases where the local node is under heavy memory 
> pressure yet remote nodes are mostly free will minimize the impact this 
> has on fault latency.  It still is a substantial increase, as I've 
> measured on Haswell, but the access latency forever is the penalty.  This 
> patch cannot make access to remote memory faster.
> 

Indeed not but remote costs are highly platform dependant so decisions
made for haswell are not necessarily justified on EPYC or any later Intel
processor either. Because these goalposts will keep changing, I think
it's better to have more clearly defined madvise hints and rely less on
implementation details that are subject to change. Otherwise we will get
stuck in an endless debate about "is workload X more important than Y"?

No doubt this patch will have problems but it treats MADV_HUGEPAGE as a
more stricter hint that huge pages are desirable.

> > <SNIP>
> >
> > I'm still unconvinced about the __GFP_NORETRY arguments because I
> > tried it already. However if you send a patch that fixes everything by
> > only adding __GFP_NORETRY in every place you wish, I'd be glad to test
> > it and verify if it actually solves the problem. Also note:
> > 
> > +#define __GFP_ONLY_COMPACT     ((__force gfp_t)(___GFP_NORETRY | \
> > +                                                ___GFP_ONLY_COMPACT))
> > 
> > If ___GFP_NORETRY would have been enough __GFP_ONLY_COMPACT would have
> > defined to ___GFP_NORETRY alone. When I figured it wasn't enough I
> > added ___GFP_ONLY_COMPACT to retain the __GFP_THISNODE in the only
> > place it's safe to retain it (i.e. compaction).
> > 
> 
> We don't need __GFP_NORETRY anymore with this, it wouldn't be useful to 
> continually compact memory in isolation if it already has failed.  It 
> seems strange to be using __GFP_DIRECT_RECLAIM | __GFP_ONLY_COMPACT, 
> though, as I assume this would evolve into.
> 
> Are there any other proposed users for __GFP_ONLY_COMPACT beyond thp 
> allocations?  If not, we should just save the gfp bit and encode the logic 
> directly into the page allocator.
> 
> Would you support this?

I don't think it's necessarily bad but it cannot distinguish between
THP and hugetlbfs. Hugetlbfs users are typically more willing to accept
high overheads as they may be required for the application to function.
That's probably fixable but will still leave us in the state where
MADV_HUGEPAGE is also a hint about locality. It'd still be interesting
to hear if it fixes the VM initialisation issue but do note that if this
patch is used as a replacement that hugetlbfs users may complain down
the line.

-- 
Mel Gorman
SUSE Labs
