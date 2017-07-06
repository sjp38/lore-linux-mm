Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B37A56B0279
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 11:47:07 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id u110so1541799wrb.14
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 08:47:07 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id j79si665818wmf.14.2017.07.06.08.47.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 06 Jul 2017 08:47:06 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 9CBC899800
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 15:47:05 +0000 (UTC)
Date: Thu, 6 Jul 2017 16:47:05 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: make allocation counters per-order
Message-ID: <20170706154704.owxsnyizel6bcgku@techsingularity.net>
References: <1499346271-15653-1-git-send-email-guro@fb.com>
 <20170706131941.omod4zl4cyuscmjo@techsingularity.net>
 <20170706144634.GB14840@castle>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170706144634.GB14840@castle>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Rik van Riel <riel@redhat.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Thu, Jul 06, 2017 at 03:46:34PM +0100, Roman Gushchin wrote:
> > The alloc counter updates are themselves a surprisingly heavy cost to
> > the allocation path and this makes it worse for a debugging case that is
> > relatively rare. I'm extremely reluctant for such a patch to be added
> > given that the tracepoints can be used to assemble such a monitor even
> > if it means running a userspace daemon to keep track of it. Would such a
> > solution be suitable? Failing that if this is a severe issue, would it be
> > possible to at least make this a compile-time or static tracepoint option?
> > That way, only people that really need it have to take the penalty.
> 
> I've tried to measure the difference with my patch applied and without
> any accounting at all (__count_alloc_event() redefined to an empty function),
> and I wasn't able to find any measurable difference.
> Can you, please, provide more details, how your scenario looked like,
> when alloc coutners were costly?
> 

At the time I used a page allocator microbenchmark from mmtests to call
the allocator directly without zeroing pages. Triggering allocations from
userspace generally mask the overhead by the zeroing costs. It's just a few
cycles but given the budget for the page allocator in some circumstances
is tiny, it was noticable. perf was used to examine the cost.

> As new counters replace an old one, and both are per-cpu counters, I believe,
> that the difference should be really small.
> 

Minimally you add a new branch and a small number of computations. It's
small but it's there. The cache footprint of the counters is also increased.
That is hard to take given that it's overhead for everybody on the off-chance
it can debug something.

It's not a strong objection and I won't nak it on this basis but given
that the same information can be easily obtained using tracepoints
(optionally lower overhead with systemtap), the information is rarely
going to be useful (no latency information for example) and there is an
increased maintenance cost then it does not seem to be that useful.

Maybe it would be slightly more convincing if there was an example of
real problems in the field that can be debugged with this. For high-order
allocations, I previously found that it was the latency that was of the
most concern and not the absolute count that happened since the system
started. Granted, the same criticism could be leveled at the existing
alloc counters but at least by correlating that value with allocstall,
you can determine what percentage of allocations stalled recently and
optionally ftrace at that point to figure out why. The same steps would
indicate then if it's only high-order allocations that stall, add stack
tracing to figure out where they are coming from and go from there. Even if
the per-order counters exist, all the other debugging steps are necessary
so I'm struggling to see how I would use them properly.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
