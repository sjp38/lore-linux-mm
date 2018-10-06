Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id D7F186B000A
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 23:19:30 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id y201-v6so9995263qka.1
        for <linux-mm@kvack.org>; Fri, 05 Oct 2018 20:19:30 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o30-v6si1817449qve.201.2018.10.05.20.19.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Oct 2018 20:19:29 -0700 (PDT)
Date: Fri, 5 Oct 2018 23:19:26 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/2] mm: thp:  relax __GFP_THISNODE for MADV_HUGEPAGE
 mappings
Message-ID: <20181006031926.GB2298@redhat.com>
References: <20180925120326.24392-1-mhocko@kernel.org>
 <20180925120326.24392-2-mhocko@kernel.org>
 <alpine.DEB.2.21.1810041302330.16935@chino.kir.corp.google.com>
 <20181004211029.GE7344@redhat.com>
 <alpine.DEB.2.21.1810041541350.81111@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1810041541350.81111@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

Hello,

On Thu, Oct 04, 2018 at 04:05:26PM -0700, David Rientjes wrote:
> The source of the problem needs to be addressed: memory compaction.  We 
> regress because we lose __GFP_NORETRY and pointlessly try reclaim, but 

I commented in detail about the __GFP_NORETRY topic in the other email
so I will skip the discussion about __GFP_NORETRY in the context of
this answer except for the comment at the end of the email to the
actual code that implements __GFP_NORETRY.

> But that's a memory compaction issue, not a thp gfp mask issue; the 
> reclaim issue is responded to below.

Actually memory compaction has no issues whatsoever with
__GFP_THISNODE regardless of __GFP_NORETRY.

> This patch causes an even worse regression if all system memory is 
> fragmented such that thp cannot be allocated because it tries to stress 
> compaction on remote nodes, which ends up unsuccessfully, not just the 
> local node.
> 
> On Haswell, when all memory is fragmented (not just the local node as I 
> obtained by 13.9% regression result), the patch results in a fault latency 
> regression of 40.9% for MADV_HUGEPAGE region of 8GB.  This is because it 
> is thrashing both nodes pointlessly instead of just failing for 
> __GFP_THISNODE.

There's no I/O involved at the very least on compaction, nor we drop
any cache or shrink any slab by mistake by just invoking compaction.
Even when you hit the worst case "all nodes are 100% fragmented"
scenario that generates the 40% increased allocation latency, all
other tasks running in the local node will keep running fine, and they
won't be pushed away forcefully into swap with all their kernel cache
depleted, which is a mlock/mbind privileged behavior that the app
using the MADV_HUGEPAGE lib should not ever been able to inflict on
other processes running in the node from different users (users as in
uid).

Furthermore when you incur the worst case latency after that there's
compact deferred logic skipping compaction next time around if all
nodes were so fragmented to the point of guaranteed failure. While
there's nothing stopping reclaim to run every time COMPACT_SKIPPED is
returned just because compaction keeps succeeding as reclaim keeps
pushing more 2M amounts into swap from the local nodes.

I don't doubt with 1024 nodes things can get pretty bad when they're
all 100% fragmented, __GFP_THISNODE would win in such case, but then
what you're asking then is the __GFP_COMPACT_ONLY behavior. That will
solve it.

What we'd need probably regardless of how we solve this bug (because
not all compaction invocations are THP invocations... and we can't
keep making special cases and optimizations tailored for THP or we end
up in that same 40% higher latency for large skbs and other stuff) is
a more sophisticated COMPACT_DEFERRED logic where you can track when
remote compaction failed. Then you wait many more times before trying
a global compaction. It could be achieved with just a compact_deferred
counter in the zone/pgdat (wherever it fits best).

Overall I don't think the bug we're dealing with and the slowdown of
compaction on the remote nodes are comparable, also considering the
latter will still happen regardless if you've large skbs or other
drivers allocating large amounts of memory as an optimization.

> So the end result is that the patch regresses access latency forever by 
> 13.9% when the local node is fragmented because it is accessing remote thp 
> vs local pages of the native page size, and regresses fault latency of 
> 40.9% when the system is fully fragmented.  The only time that fault 
> latency is improved is when remote memory is not fully fragmented, but 
> then you must incur the remote access latency.

You get THP however which will reduce the TLB miss cost and maximize
TLB usage, so it depends on the app if that 13.9% cost is actually
offseted by the THP benefit or not.

It entirely depends if large part of the workload mostly fits in
in-socket CPU cache. The more the in-socket/node CPU cache pays off,
the more remote-THP also pays off. There would be definitely workloads
that would run faster, not slower, with the remote THP instead of
local PAGE_SIZEd memory. The benefit of THP is also larger for the
guest loads than for host loads, so it depends on that too.

We agree about the latency issue with a ton of RAM and thousands of
nodes, but again that can be mitigated with a NUMA friendly
COMPACT_DEFERRED logic NUMA aware. Even without such
NUMA-aware-compact_deferred logic improvement, the worst case of the
remote compaction behavior still doesn't look nearly as bad as this
bug by thinking about it. And it only is a concern for extremely large
NUMA systems (which may run the risk of running in other solubility
issues in other places if random workloads are applied to it and all
nodes are low on memory and fully fragmented which is far from common
scenario on those large systems), while the bug we fixed was hurting
badly all very common 2 nodes installs with workloads that are common
and should run fine.

> Direct reclaim doesn't make much sense for thp allocations if compaction 
> has failed, even for MADV_HUGEPAGE.  I've discounted Mel's results because 
> he is using thp defrag set to "always", which includes __GFP_NORETRY but 
> the default option and anything else other than "always" does not use 
> __GFP_NORETRY like the page allocator believes it does:
> 
>                 /*
>                  * Checks for costly allocations with __GFP_NORETRY, which
>                  * includes THP page fault allocations
>                  */
>                 if (costly_order && (gfp_mask & __GFP_NORETRY)) {
>                         /*
>                          * If compaction is deferred for high-order allocations,
>                          * it is because sync compaction recently failed. If
>                          * this is the case and the caller requested a THP
>                          * allocation, we do not want to heavily disrupt the
>                          * system, so we fail the allocation instead of entering
>                          * direct reclaim.
>                          */
>                         if (compact_result == COMPACT_DEFERRED)
>                                 goto nopage;
> 
> So he is avoiding the cost of reclaim, which you are not, specifically 
> because he is using defrag == "always".  __GFP_NORETRY should be included 
> for any thp allocation and it's a regression that it doesn't.

Compaction doesn't fail, it returns COMPACT_SKIPPED and it asks to do
a run of reclam to generate those 2M of PAGE_SIZEd memory required to
move a 2M piece into the newly freely PAGE_SIZEd fragments. So
__GFP_NORETRY never jumps to "nopage" and it never gets deferred either.

For the record, I didn't trace it literally with gdb to validate my
theory of why forcefully adding __GFP_NORETRY didn't move the needle,
so feel free to do more investigations in that area if you see any
pitfall in the theory.

Thanks,
Andrea
