Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 20F976B078F
	for <linux-mm@kvack.org>; Sat, 10 Nov 2018 08:22:54 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id b54-v6so354844edc.22
        for <linux-mm@kvack.org>; Sat, 10 Nov 2018 05:22:54 -0800 (PST)
Received: from outbound-smtp27.blacknight.com (outbound-smtp27.blacknight.com. [81.17.249.195])
        by mx.google.com with ESMTPS id x34-v6si1389292edx.135.2018.11.10.05.22.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 10 Nov 2018 05:22:52 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp27.blacknight.com (Postfix) with ESMTPS id D1938B8789
	for <linux-mm@kvack.org>; Sat, 10 Nov 2018 13:22:51 +0000 (GMT)
Date: Sat, 10 Nov 2018 13:22:49 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC PATCH] mm: thp: implement THP reservations for anonymous
 memory
Message-ID: <20181110132249.GH23260@techsingularity.net>
References: <1541746138-6706-1-git-send-email-anthony.yznaga@oracle.com>
 <20181109121318.3f3ou56ceegrqhcp@kshutemo-mobl1>
 <20181109195150.GA24747@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20181109195150.GA24747@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Anthony Yznaga <anthony.yznaga@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, aneesh.kumar@linux.ibm.com, akpm@linux-foundation.org, jglisse@redhat.com, khandual@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, mhocko@kernel.org, minchan@kernel.org, peterz@infradead.org, rientjes@google.com, vbabka@suse.cz, willy@infradead.org, ying.huang@intel.com, nitingupta910@gmail.com

On Fri, Nov 09, 2018 at 02:51:50PM -0500, Andrea Arcangeli wrote:
> On Fri, Nov 09, 2018 at 03:13:18PM +0300, Kirill A. Shutemov wrote:
> > I haven't yet read the patch in details, but I'm skeptical about the
> > approach in general for few reasons:
> > 
> > - PTE page table retracting to replace it with huge PMD entry requires
> >   down_write(mmap_sem). It makes the approach not practical for many
> >   multi-threaded workloads.
> > 
> >   I don't see a way to avoid exclusive lock here. I will be glad to
> >   be proved otherwise.
> > 
> > - The promotion will also require TLB flush which might be prohibitively
> >   slow on big machines.
> > 
> > - Short living processes will fail to benefit from THP with the policy,
> >   even with plenty of free memory in the system: no time to promote to THP
> >   or, with synchronous promotion, cost will overweight the benefit.
> > 
> > The goal to reduce memory overhead of THP is admirable, but we need to be
> > careful not to kill THP benefit itself. The approach will reduce number of
> > THP mapped in the system and/or shift their allocation to later stage of
> > process lifetime.
> > 
> > The only way I see it can be useful is if it will be possible to apply the
> > policy on per-VMA basis. It will be very useful for malloc()
> > implementations, for instance. But as a global policy it's no-go to me.
> 
> I'm also skeptical about this: the current design is quite
> intentional. It's not a bug but a feature that we're not doing the
> promotion.
> 

Understood. I think with two people with extensive THP experience being
skeptical about this, we should take a step back before Anthony spends
too much more time on this. It would be a shame to work extensively on
a series just to have it rejected.

> Part of the tradeoff with THP is to use more RAM to save CPU, when you
> use less RAM you're inherently already wasting some CPU just for the
> reservation management and you don't get the immediate TLB benefit
> anymore either.
> 

This is true, there is a gap where there is no THP benefit. The big
question is how many workloads, if any, suffer as a result of premature
reclaim due to sparse references of the address space consuming too much
memory. Anthony, do you have any benchmarks in mind? I don't because the
HPC workloads I'm aware of are usually sized to fit in memory regardless
of THP use.

> And if you're in the camp that is concerned about the use of more RAM
> or/and about the higher latency of COW faults, I'm afraid the
> intermediate solution will be still slower than the already available
> MADV_NOHUGEPAGE or enabled=madvise.
> 

Does that not prevent huge page usage? Maybe you can spell it out a bit
better. What is the set of system calls an application should make to
not use huge pages either for the address space or on a per-VMA basis
and defer to kcompactd? I know that can be tuned globally but that's not
quite the same thing given that multiple applications or containers can
be running with different requirements.

> Now about the implementation: the whole point of the reservation
> complexity is to skip the khugepaged copy, so it can collapse in
> place. Is skipping the copy worth it? Isn't the big cost the IPI
> anyway to avoid leaving two simultaneous TLB mappings of different
> granularity?
> 

Not necessarily. With THP anon in the simple case, it might be just a
single thread and kcompact so that's one IPI (kcompactd flushes local and
one IPI to the CPU the thread was running on assuming it's not migrating
excessively). It would scale up with the number of threads but I suspect
the main cost is the actual copying, page table manipulation and the
locking required.

> So if you are ok to copy the memory that you promote to THP, you'd
> just need a global THP mode to avoid allocating THP even when they're
> available during the page fault (while still allowing khugepaged to
> collapse hugepages in the background), and then reduce max_ptes_none
> to get the desired promotion ratio.
> 

As an aside, a universal benefit would be looking at reducing the time
to allocate the necessary huge page as we know that can be excessive. It
would be ortogonal to this series.

> > <SNIP>
> >
> > Prove me wrong with performance data. :)
> 
> Same here.
> 

Could you and Kirill outline what sort of workloads you would consider
acceptable for evaluating this series? One would assume it covers at
least the following, potentially with a number of workloads.

1. Evaluate the collapse and copying costs (probing the entire time
   spent in collapse_huge_page might do it)
2. Evaluate mmap_sem hold time during hugepage collapse
3. Estimate excessive RAM use due to unnecessary THP usage
4. Estimate the slowdown due to delayed THP usage 

1 and 2 would indicate how much time is lost due to not using
reservations. That potentially goes in the direction of simply making
this faster -- fragmentation reduction (posted but unreviewed), faster
compaction searches, better page isolation during compaction to
avoid free pages being reused before an order-9 is free.

3 should be straight-forward but 4 would be the hardest to evaluate
because it would have to be determimed if 4 is offset by improvements to
1-3. If 1-3 is improved enough, it might remove the motivation for the
series entirely.

In other words, if we agree on a workload in advance, it might bring
this the right direction and not accidentally throw Anthony down a hole
working on a series that never gets ack'd.

I'm not necessarily the best person to answer because my natural inclination
after the fragmentation series would be to keep using thpfiosacle
(from the fragmentation avoidance series) and work on improving the THP
allocation success rates and reduce latencies. I've tunnel vision on that
for the moment.

Thanks.

-- 
Mel Gorman
SUSE Labs
