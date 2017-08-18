Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 17E526B049A
	for <linux-mm@kvack.org>; Fri, 18 Aug 2017 14:54:58 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k46so7444773wre.9
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 11:54:58 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id f192si413082wmg.38.2017.08.18.11.54.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 18 Aug 2017 11:54:56 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 27439F4267
	for <linux-mm@kvack.org>; Fri, 18 Aug 2017 18:54:56 +0000 (UTC)
Date: Fri, 18 Aug 2017 19:54:55 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/2] sched/wait: Break up long wake list walk
Message-ID: <20170818185455.qol3st2nynfa47yc@techsingularity.net>
References: <CA+55aFznC1wqBSfYr8=92LGqz5-F6fHMzdXoqM4aOYx8sT1Dhg@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F07753786CE9@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFwzTMrZwh7TE_VeZt8gx5Syoop-kA=Xqs56=FkyakrM6g@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378761B@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFy_RNx5TQ8esjPPOKuW-o+fXbZgWapau2MHyexcAZtqsw@mail.gmail.com>
 <20170818122339.24grcbzyhnzmr4qw@techsingularity.net>
 <37D7C6CF3E00A74B8858931C1DB2F077537879BB@SHSMSX103.ccr.corp.intel.com>
 <20170818144622.oabozle26hasg5yo@techsingularity.net>
 <37D7C6CF3E00A74B8858931C1DB2F07753787AE4@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFxZjjqUM4kPvNEeZahPovBHFATiwADj-iPTDN0-jnU67Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CA+55aFxZjjqUM4kPvNEeZahPovBHFATiwADj-iPTDN0-jnU67Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Liang, Kan" <kan.liang@intel.com>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Aug 18, 2017 at 10:48:23AM -0700, Linus Torvalds wrote:
> On Fri, Aug 18, 2017 at 9:53 AM, Liang, Kan <kan.liang@intel.com> wrote:
> >
> >> On Fri, Aug 18, 2017 Mel Gorman wrote:
> >>
> >> That indicates that it may be a hot page and it's possible that the page is
> >> locked for a short time but waiters accumulate.  What happens if you leave
> >> NUMA balancing enabled but disable THP?
> >
> > No, disabling THP doesn't help the case.
> 
> Interesting.  That particular code sequence should only be active for
> THP. What does the profile look like with THP disabled but with NUMA
> balancing still enabled?
> 

While that specific code sequence is active in the example, the problem is
fundamental to what NUMA balancing does. If many threads share a single page,
base page or THP, then any thread accessing the data during migration will
block on page lock. The symptoms will be difference but I am willing to
bet it'll be a wake on a page lock either way. NUMA balancing is somewhat
unique in that it's relatively easy to have lots of threads depend on a
single pages lock.

> Just asking because maybe that different call chain could give us some
> other ideas of what the commonality here is that triggers out
> behavioral problem.
> 

I am reasonably confident that the commonality is multiple threads sharing
a page. Maybe it's a single hot structure that is shared between threads.
Maybe it's parallel buffers that are aligned on a sub-page boundary.
Multiple threads accessing buffers aligned by cache lines would do it
which is reasonable behaviour for a parallelised compute load for example.
If I'm right, writing a test case for it is straight-forward and I'll get
to it on Monday when I'm back near my normal work machine.

The initial guess that it may be allocation latency was obviously way
off. I didn't follow through properly but the fact it's not THP specific
means the length of time it takes to migrate is possibly irrelevant. If
the page is hot enough, threads will block once migration starts even if
the migration completes quickly.

> I was really hoping that we'd root-cause this and have a solution (and
> then apply Tim's patch as a "belt and suspenders" kind of thing), but
> it's starting to smell like we may have to apply Tim's patch as a
> band-aid, and try to figure out what the trigger is longer-term.
> 

I believe the trigger is simply because a hot page gets unmapped and
then threads lock on it.

One option to mitigate (but not eliminate) the problem is to record when
the page lock is contended and pass in TNF_PAGE_CONTENDED (new flag) to
task_numa_fault(). For each time it's passed in, shift numa_scan_period
<< 1 which will slow the scanner and reduce the frequency contention
occurs at.  If it's heavily contended, the period will quickly reach
numa_scan_period_max. That is simple with the caveat that a single hot
contended page will slow all balancing. The main problem is that this
mitigates and not eliminates the problem. No matter how slow the scanner
is, it'll still hit the case where many threads contend on a single page.

An alternative is to set a VMA flag on VMAs if many contentions are
detected and stop scanning that VMA entirely. It would need a VMA flag
which right now might mean making vm_flags u64 and increasing the size of
vm_area_struct on 32-bit. The downside is that it is permanent. If heavy
contention happens then scanning that VMA is disabled for the lifetime
of the process because there would no longer be a way to detect that
re-enabling is appropriate.

A variation would be to record contentions in struct numa_group and return
false in should_numa_migrate_memory if contentions are high and scale it
down over time. It wouldn't be perfect as processes sharing hot pages are
not guaranteed to have a numa_group in common but it may be sufficient.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
