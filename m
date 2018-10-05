Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id D52F86B000A
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 19:21:59 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id j60-v6so6382287qtb.8
        for <linux-mm@kvack.org>; Fri, 05 Oct 2018 16:21:59 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b7-v6si565640qtt.307.2018.10.05.16.21.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Oct 2018 16:21:58 -0700 (PDT)
Date: Fri, 5 Oct 2018 19:21:55 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/2] mm: thp:  relax __GFP_THISNODE for MADV_HUGEPAGE
 mappings
Message-ID: <20181005232155.GA2298@redhat.com>
References: <20180925120326.24392-1-mhocko@kernel.org>
 <20180925120326.24392-2-mhocko@kernel.org>
 <alpine.DEB.2.21.1810041302330.16935@chino.kir.corp.google.com>
 <20181005073854.GB6931@suse.de>
 <alpine.DEB.2.21.1810051320270.202739@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1810051320270.202739@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

Hi,

On Fri, Oct 05, 2018 at 01:35:15PM -0700, David Rientjes wrote:
> Why is it ever appropriate to do heavy reclaim and swap activity to 
> allocate a transparent hugepage?  This is exactly what the __GFP_NORETRY 
> check for high-order allocations is attempting to avoid, and it explicitly 
> states that it is for thp faults.  The fact that we lost __GFP_NORERY for 
> thp allocations for all settings, including the default setting, other 
> than yours (setting of "always") is what I'm focusing on.  There is no 
> guarantee that this activity will free an entire pageblock or that it is 
> even worthwhile.

I tried to add just __GFP_NORETRY but it changes nothing. Try it
yourself if you think that can resolve the swap storm and excessive
reclaim CPU overhead... and see if it works. I didn't intend to
reinvent the wheel with __GFP_COMPACT_ONLY, if __GFP_NORETRY would
have worked. I tried adding __GFP_NORETRY first of course.

Reason why it doesn't help is: compaction fails because not enough
free RAM, reclaim is invoked, compaction succeeds, THP is allocated to
your lib user, compaction fails because not enough free RAM, reclaim
is invoked etc.. compact_result is not COMPACT_DEFERRED, but
COMPACT_SKIPPED.

See the part "reclaim is invoked" (with __GFP_THISNODE), is enough to
still create the same heavy swap storm and unfairly penalize all apps
with memory allocated in the local node like if your library had
actually the kernel privilege to run mbind or mlock, which is not ok.

Only __GFP_COMPACT_ONLY truly can avoid reclaim, the moment reclaim
can run with __GFP_THISNODE set, all bets are off and we're back to
square one, no difference (at best marginal difference) with
__GFP_NORETRY being set.

> That aside, removing __GFP_THISNODE can make the fault latency much worse 
> if remote notes are fragmented and/or reclaim has the inability to free 
> contiguous memory, which it likely cannot.  This is where I measured over 
> 40% fault latency regression from Linus's tree with this patch on a 
> fragmnented system where order-9 memory is neither available from node 0 
> or node 1 on Haswell.

Discussing the drawbacks of removing __GFP_THISNODE is an orthogonal
topic. __GFP_COMPACT_ONLY approach didn't have any of those drawbacks
about the remote latency because __GFP_THISNODE was still set at all
times, just as you like it. You seem to think __GFP_NORETRY will work
as well as __GFP_COMPACT_ONLY but it doesn't.

Calling compaction (and only compaction!) with __GFP_THISNODE set
doesn't break anything and that was what __GFP_COMPACT_ONLY was about.

> The behavior that MADV_HUGEPAGE specifies is certainly not clearly 
> defined, unfortunately.  The way that an application writer may read it, 
> as we have, is that it will make a stronger attempt at allocating a 
> hugepage at fault.  This actually works quite well when the allocation 
> correctly has __GFP_NORETRY, as it's supposed to, and compaction is 
> MIGRATE_ASYNC.

Like Mel said, your app just happens to fit in a local node, if the
user of the lib is slightly different and allocates 16G on a system
where each node is 4G, the post-fix MADV_HUGEPAGE will perform
extremely better also for the lib user.

And you know, if the lib user fits in one node, it can use mbind and
it won't hit OOM... and you'd need some capability giving the app
privilege anyway to keep MADV_HUGEPAGE as deep and unfair to the rest
of the processes running the local node (like mbind and mlock require
too).

Could you just run a test with the special lib and allocate 4 times
the size of a node, and see how the lib performs with upstream and
upstream+fix? Feel free to add __GFP_NORETRY anywhere you like in the
test of the upstream without fix.

The only constraint I would ask for the test (if the app using the lib
is not a massively multithreaded app, like qemu is, and you just
intend to run malloc(SIZEOFNODE*4); memset) is to run the app-lib
under "taskset -c 0". Otherwise NUMA balancing could move the the CPU
next to the last memory touched, which couldn't be done if each thread
accesses all ram at random from all 4 nodes at the same time (which is
a totally legitimate workload too and must not hit the "pathological
THP allocation performance").

> removed in a thp allocation.  I don't think anybody in this thread wants 
> 14% remote access latency regression if we allocate remotely or 40% fault 
> latency regression when remote nodes are fragmented as well.

Did you try the __GFP_COMPACT_ONLY patch? That won't have the 40%
fault latency already.

Also you're underestimating the benefit of THP given from remote nodes
for virt a bit, the 40% fault latency is not an issue when the
allocation is long lived, which is what MADV_HUGEPAGE is telling the
kernel, and the benefit of THP for guest is multiplied. It's more a
feature than a bug that 40% fault latency with MADV_HUGEPAGE set at
least for all long lived allocations (but if the allocations aren't
long lived, why should MADV_HUGEPAGE have been set in the first place?).

With the fix applied, if you want to add __GFP_THISNODE to compaction
only by default you still can, that solves the 40% fault latency just
like __GFP_COMPACT_ONLY patch would also have avoided that 40%
increased fault latency.

The issue here is very simple: you can't use __GFP_THISNODE for an
allocation that can invoke reclaim, unless you have mlock or mbind
higher privilege capabilities.

Compaction can be totally called with __GFP_THISNODE. Just I believe
KVM prefers the fault latency increased as it only happens during VM
warmup phase and it prefers more THP immediately. Compaction on the
remote nodes (i.e. the higher latency) is not wasted CPU for KVM, as
it would be for a short lived allocations (MADV_HUGEPAGE incidentally
is about to tell the kernel which allocations are long lived and to
tell the kernel when it's worth running compaction in direct reclaim).

> The numbers that you provide while using the non-default option to mimick 
> MADV_HUGEPAGE mappings but also use __GFP_NORETRY makes the actual source 
> of the problem quite easy to identify: there is an inconsistency in the 
> thp gfp mask and the page allocator implementation.

I'm still unconvinced about the __GFP_NORETRY arguments because I
tried it already. However if you send a patch that fixes everything by
only adding __GFP_NORETRY in every place you wish, I'd be glad to test
it and verify if it actually solves the problem. Also note:

+#define __GFP_ONLY_COMPACT     ((__force gfp_t)(___GFP_NORETRY | \
+                                                ___GFP_ONLY_COMPACT))

If ___GFP_NORETRY would have been enough __GFP_ONLY_COMPACT would have
defined to ___GFP_NORETRY alone. When I figured it wasn't enough I
added ___GFP_ONLY_COMPACT to retain the __GFP_THISNODE in the only
place it's safe to retain it (i.e. compaction).

Thanks,
Andrea
