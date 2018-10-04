Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 337B86B000A
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 19:05:30 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id a64-v6so1658212pfg.16
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 16:05:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 38-v6sor5142026pln.41.2018.10.04.16.05.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Oct 2018 16:05:28 -0700 (PDT)
Date: Thu, 4 Oct 2018 16:05:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mm: thp:  relax __GFP_THISNODE for MADV_HUGEPAGE
 mappings
In-Reply-To: <20181004211029.GE7344@redhat.com>
Message-ID: <alpine.DEB.2.21.1810041541350.81111@chino.kir.corp.google.com>
References: <20180925120326.24392-1-mhocko@kernel.org> <20180925120326.24392-2-mhocko@kernel.org> <alpine.DEB.2.21.1810041302330.16935@chino.kir.corp.google.com> <20181004211029.GE7344@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Thu, 4 Oct 2018, Andrea Arcangeli wrote:

> Hello David,
> 

Hi Andrea,

> On Thu, Oct 04, 2018 at 01:16:32PM -0700, David Rientjes wrote:
> > There are ways to address this without introducing regressions for 
> > existing users of MADV_HUGEPAGE: introduce an madvise() mode to accept 
> > remote thp allocations, which users of this library would never set, or 
> > fix memory compaction so that it does not incur substantial allocation 
> > latency when it will likely fail.
> 
> These librarians needs to call a new MADV_ and the current
> MADV_HUGEPAGE should not be affected because the new MADV_ will
> require some capbility (i.e. root privilege).
> 
> qemu was the first user of MADV_HUGEPAGE and I don't think it's fair
> to break it and require change to it to run at higher privilege to
> retain the direct compaction behavior of MADV_HUGEPAGE.
> 
> The new behavior you ask to retain in MADV_HUGEPAGE, generated the
> same misbehavior to VM as mlock could have done too, so it can't just
> be given by default without any privilege whatsoever.
> 
> Ok you could mitigate the breakage that MADV_HUGEPAGE could have
> generated (before the recent fix) by isolating malicious or
> inefficient programs with memcg, but by default in a multiuser system
> without cgroups the global disruption provided before the fix
> (i.e. the pathological THP behavior) is not warranted. memcg shouldn't
> be mandatory to avoid a process to affect the VM in such a strong way
> (i.e. all other processes who happened to be allocated in the node
> where the THP allocation triggered, being trashed in swap like if all
> memory of all other nodes was not completely free).
> 

The source of the problem needs to be addressed: memory compaction.  We 
regress because we lose __GFP_NORETRY and pointlessly try reclaim, but 
deferred compaction is supposedly going to prevent repeated (and 
unnecessary) calls to memory compaction that ends up thrashing your local 
node.

This is likely because your workload has a size greater than 2MB * the 
deferred compaction threshold, normally set at 64.  This ends up 
repeatedly calling memory compaction and ending up being expensive when it 
should fail once and not be called again in the near term.

But that's a memory compaction issue, not a thp gfp mask issue; the 
reclaim issue is responded to below.

> Not only that, it's not only about malicious processes it's also
> excessively inefficient for processes that just don't fit in a local
> node and use MADV_HUGEPAGE. Your processes all fit in the local node
> for sure if they're happy about it. This was reported as a
> "pathological THP regression" after all in a workload that couldn't
> swap at all because of the iommu gup persistent refcount pins.
> 

This patch causes an even worse regression if all system memory is 
fragmented such that thp cannot be allocated because it tries to stress 
compaction on remote nodes, which ends up unsuccessfully, not just the 
local node.

On Haswell, when all memory is fragmented (not just the local node as I 
obtained by 13.9% regression result), the patch results in a fault latency 
regression of 40.9% for MADV_HUGEPAGE region of 8GB.  This is because it 
is thrashing both nodes pointlessly instead of just failing for 
__GFP_THISNODE.

So the end result is that the patch regresses access latency forever by 
13.9% when the local node is fragmented because it is accessing remote thp 
vs local pages of the native page size, and regresses fault latency of 
40.9% when the system is fully fragmented.  The only time that fault 
latency is improved is when remote memory is not fully fragmented, but 
then you must incur the remote access latency.

> Overall I think the call about the default behavior of MADV_HUGEPAGE
> is still between removing __GFP_THISNODE if gfp_flags can reclaim (the
> fix in -mm), or by changing direct compaction to only call compaction
> and not reclaim (i.e. __GFP_COMPACT_ONLY) when __GFP_THISNODE is set.
> 

There's two issues: the expensiveness of the page allocator involving 
compaction for MADV_HUGEPAGE mappings and the desire for userspace to 
fault thp remotely and incur the 13.9% performance regression forever.

If reclaim is avoided like it should be with __GFP_NORETRY for even 
MADV_HUGEPAGE regions, you should only experience latency introduced by 
node local memory compaction.  The __GFP_NORETRY was removed by commit 
2516035499b9 ("mm, thp: remove __GFP_NORETRY from khugepaged and madvised 
allocations").  The current implementation of the page allocator does not 
match the expected behavior of the thp gfp flags.

Memory compaction has deferred compaction to avoid costly scanning when it 
has recently failed, and that likely needs to be addressed directly rather 
than relying on a count of how many times it has failed; if you fault more 
than 128MB at the same time, does it make sense to immediately compact 
again?  Likely not.

> To go beyond that some privilege is needed and a new MADV_ flag can
> require privilege or return error if there's not enough privilege. So
> the lib with 100's users can try to use that new flag first, show an
> error in stderr (maybe under debug), and fallback to MADV_HUGEPAGE if
> the app hasn't enough privilege. The alternative is to add a new mem
> policy less strict than MPOL_BIND to achieve what you need on top of
> MADV_HUGEPAGE (which also would require some privilege of course as
> all mbinds). I assume you already evaluated the preferred and local
> mbinds and it's not a perfect fit?
> 
> If we keep this as a new MADV_HUGEPAGE_FORCE_LOCAL flag, you could
> still add a THP sysfs/sysctl control to lift the privilege requirement
> marking it as insecure setting in docs
> (mm/transparent_hugepage/madv_hugepage_force_local=0|1 forced to 0 by
> default). This would be on the same lines of other sysctl that
> increase the max number of files open and such things (perhaps a
> sysctl would be better in fact for tuning in /etc/sysctl.conf).
> 
> Note there was still some improvement left possible in my
> __GFP_COMPACT_ONLY patch alternative. Notably if the watermarks for
> the local node shown the local node not to have enough real "free"
> PAGE_SIZEd pages to succeed the PAGE_SIZEd local THP allocation if
> compaction failed, we should have relaxed __GFP_THISNODE and tried to
> allocate THP from the NUMA-remote nodes before falling back to
> PAGE_SIZEd allocations. That also won't require any new privilege.
> 

Direct reclaim doesn't make much sense for thp allocations if compaction 
has failed, even for MADV_HUGEPAGE.  I've discounted Mel's results because 
he is using thp defrag set to "always", which includes __GFP_NORETRY but 
the default option and anything else other than "always" does not use 
__GFP_NORETRY like the page allocator believes it does:

                /*
                 * Checks for costly allocations with __GFP_NORETRY, which
                 * includes THP page fault allocations
                 */
                if (costly_order && (gfp_mask & __GFP_NORETRY)) {
                        /*
                         * If compaction is deferred for high-order allocations,
                         * it is because sync compaction recently failed. If
                         * this is the case and the caller requested a THP
                         * allocation, we do not want to heavily disrupt the
                         * system, so we fail the allocation instead of entering
                         * direct reclaim.
                         */
                        if (compact_result == COMPACT_DEFERRED)
                                goto nopage;

So he is avoiding the cost of reclaim, which you are not, specifically 
because he is using defrag == "always".  __GFP_NORETRY should be included 
for any thp allocation and it's a regression that it doesn't.
