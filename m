Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 251A56B02F3
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 12:43:33 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id d80so1789717lfg.0
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 09:43:33 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id c78si264372ljd.35.2017.07.06.09.43.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jul 2017 09:43:31 -0700 (PDT)
Date: Thu, 6 Jul 2017 17:43:04 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH] mm: make allocation counters per-order
Message-ID: <20170706164304.GA23662@castle>
References: <1499346271-15653-1-git-send-email-guro@fb.com>
 <20170706131941.omod4zl4cyuscmjo@techsingularity.net>
 <20170706144634.GB14840@castle>
 <20170706154704.owxsnyizel6bcgku@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170706154704.owxsnyizel6bcgku@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Rik van Riel <riel@redhat.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Thu, Jul 06, 2017 at 04:47:05PM +0100, Mel Gorman wrote:
> On Thu, Jul 06, 2017 at 03:46:34PM +0100, Roman Gushchin wrote:
> > > The alloc counter updates are themselves a surprisingly heavy cost to
> > > the allocation path and this makes it worse for a debugging case that is
> > > relatively rare. I'm extremely reluctant for such a patch to be added
> > > given that the tracepoints can be used to assemble such a monitor even
> > > if it means running a userspace daemon to keep track of it. Would such a
> > > solution be suitable? Failing that if this is a severe issue, would it be
> > > possible to at least make this a compile-time or static tracepoint option?
> > > That way, only people that really need it have to take the penalty.
> > 
> > I've tried to measure the difference with my patch applied and without
> > any accounting at all (__count_alloc_event() redefined to an empty function),
> > and I wasn't able to find any measurable difference.
> > Can you, please, provide more details, how your scenario looked like,
> > when alloc coutners were costly?
> > 
> 
> At the time I used a page allocator microbenchmark from mmtests to call
> the allocator directly without zeroing pages. Triggering allocations from
> userspace generally mask the overhead by the zeroing costs. It's just a few
> cycles but given the budget for the page allocator in some circumstances
> is tiny, it was noticable. perf was used to examine the cost.

I'll try to measure the difference with mmtests.

I agree, that it's not a feature that worth significant performance penalty,
but if it's small even in a special benchmark, I'd say, it's acceptable.

> > As new counters replace an old one, and both are per-cpu counters, I believe,
> > that the difference should be really small.
> > 
> 
> Minimally you add a new branch and a small number of computations. It's
> small but it's there. The cache footprint of the counters is also increased.
> That is hard to take given that it's overhead for everybody on the off-chance
> it can debug something.
> 
> It's not a strong objection and I won't nak it on this basis but given
> that the same information can be easily obtained using tracepoints
> (optionally lower overhead with systemtap), the information is rarely
> going to be useful (no latency information for example) and there is an
> increased maintenance cost then it does not seem to be that useful.

Tracepoints are good for investigations on one machine, not so convenient
if we are talking about gathering stats from the fleet with production load.
Unfortunately, some memory fragmentation issues are hard to reproduce on
a single dev machine.

> Maybe it would be slightly more convincing if there was an example of
> real problems in the field that can be debugged with this. For high-order
> allocations, I previously found that it was the latency that was of the
> most concern and not the absolute count that happened since the system
> started.

We met an issue with compaction consuming too much CPU under some specific
conditions, and one of the suspicions was a significant number of high-order
allocations, requested by some third-party device drivers.

Knowing the number of allocations is especially helpful for comparing
different kernel versions in a such case, as it's hard to distinguish changes
in mm, changes in these drivers or just workload/environment changes,
leaded to an increased or decreased fragmentation.

Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
