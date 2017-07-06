Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 388426B0292
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 13:17:01 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id p64so2241213wrc.8
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 10:17:01 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id z1si677215edd.127.2017.07.06.10.16.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jul 2017 10:16:59 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id DDE951C255F
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 18:16:58 +0100 (IST)
Date: Thu, 6 Jul 2017 18:16:58 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: make allocation counters per-order
Message-ID: <20170706171658.mohgkjcefql4wekz@techsingularity.net>
References: <1499346271-15653-1-git-send-email-guro@fb.com>
 <20170706131941.omod4zl4cyuscmjo@techsingularity.net>
 <20170706144634.GB14840@castle>
 <20170706154704.owxsnyizel6bcgku@techsingularity.net>
 <20170706164304.GA23662@castle>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170706164304.GA23662@castle>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Rik van Riel <riel@redhat.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Thu, Jul 06, 2017 at 05:43:04PM +0100, Roman Gushchin wrote:
> > At the time I used a page allocator microbenchmark from mmtests to call
> > the allocator directly without zeroing pages. Triggering allocations from
> > userspace generally mask the overhead by the zeroing costs. It's just a few
> > cycles but given the budget for the page allocator in some circumstances
> > is tiny, it was noticable. perf was used to examine the cost.
> 
> I'll try to measure the difference with mmtests.
> 
> I agree, that it's not a feature that worth significant performance penalty,
> but if it's small even in a special benchmark, I'd say, it's acceptable.
> 

Note that even if you keep the cycle overhead down, the CPU cache footprint
for such a large increase remains. That will be permanent and unfixable which
is why I would like a Kconfig option at the very least for the vast majority
of people that have no intention or ability to debug such a situation.

> > > As new counters replace an old one, and both are per-cpu counters, I believe,
> > > that the difference should be really small.
> > > 
> > 
> > Minimally you add a new branch and a small number of computations. It's
> > small but it's there. The cache footprint of the counters is also increased.
> > That is hard to take given that it's overhead for everybody on the off-chance
> > it can debug something.
> > 
> > It's not a strong objection and I won't nak it on this basis but given
> > that the same information can be easily obtained using tracepoints
> > (optionally lower overhead with systemtap), the information is rarely
> > going to be useful (no latency information for example) and there is an
> > increased maintenance cost then it does not seem to be that useful.
> 
> Tracepoints are good for investigations on one machine, not so convenient
> if we are talking about gathering stats from the fleet with production load.
> Unfortunately, some memory fragmentation issues are hard to reproduce on
> a single dev machine.
> 

Sure, but just knowing that some high-order allocations occurred in the
past doesn't help either.

> > Maybe it would be slightly more convincing if there was an example of
> > real problems in the field that can be debugged with this. For high-order
> > allocations, I previously found that it was the latency that was of the
> > most concern and not the absolute count that happened since the system
> > started.
> 
> We met an issue with compaction consuming too much CPU under some specific
> conditions, and one of the suspicions was a significant number of high-order
> allocations, requested by some third-party device drivers.
> 

Even if this was the suspicion, you would have to activate monitoring on
the machine under load at the time the problem is occurring to determine if
the high-order allocations are currently happening or happened in the past.
If you are continually logging this data then logging allocation stalls for
high-order allocations would give you similar information. If you have to
activate a monitor anyway (or an agent that monitors for high CPU usage),
then it might as well be ftrace based as well as anything else. Even a
basic systemtap script would be able to capture only stack traces for
allocation requests that take longer than a threshold to limit the amount
of data recorded. Even *if* you had these counters running on your grid,
they will tell you nothing about how long those allocations are or whether
compaction is involved and that is what is key to begin debugging the issue.

A basic monitor of /proc/vmstat for the compact_* can be used an indication
of excessive time spent in compaction although you're back to ftrace to
quantify how much of a problem it is in terms of time. For example,
rapidly increasing compact_fail combined with rapidly increasing
compact_migrate_scanned and compact_free_scanned will tell you that
compaction is active and failing with a comparison of the ratio of
compact_fail to compact_success telling you if it's persistent or slow
progress. You'd need top information to see if it's the compaction daemon
that is consuming all the CPU or processes. If it's the daemon then that
points you in the direction of what potentially needs fixing. If it's
processes then there is a greater problem and ftrace needs to be used to
establish *what* is doing the high-allocation requests and whether they
can be reduced somehow or whether it's a general fragmentation problem
(in which case your day takes a turn for the worse).

What I'm trying to say is that in themselves, an high-order allocation
count doesn't help debug this class of problem as much as you'd think.
Hopefully the above information is more useful to you in helping debug
what's actually wrong.

> Knowing the number of allocations is especially helpful for comparing
> different kernel versions in a such case, as it's hard to distinguish changes
> in mm, changes in these drivers or just workload/environment changes,
> leaded to an increased or decreased fragmentation.
> 

I'm still struggling to see how counters help when an agent that monitors
for high CPU usage could be activated that captures tracing to see if it's
allocation and compaction stalls that are contributing to the overall load
or "something else".

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
