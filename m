Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id CEF9F6B0292
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 16:02:48 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 23so3226290wry.4
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 13:02:48 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id x4si1036994wmg.27.2017.07.06.13.02.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 06 Jul 2017 13:02:46 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id 2899098D3E
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 20:02:46 +0000 (UTC)
Date: Thu, 6 Jul 2017 21:02:45 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: make allocation counters per-order
Message-ID: <20170706200245.epiyxhllgc3c4asn@techsingularity.net>
References: <1499346271-15653-1-git-send-email-guro@fb.com>
 <20170706131941.omod4zl4cyuscmjo@techsingularity.net>
 <20170706144634.GB14840@castle>
 <20170706154704.owxsnyizel6bcgku@techsingularity.net>
 <20170706164304.GA23662@castle>
 <20170706171658.mohgkjcefql4wekz@techsingularity.net>
 <CAATkVEw22YAfSH4GKY1Y9Qz9chCAz1cgcesz_xg3O2-0XxY_ng@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAATkVEw22YAfSH4GKY1Y9Qz9chCAz1cgcesz_xg3O2-0XxY_ng@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Debabrata Banerjee <dbavatar@gmail.com>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Rik van Riel <riel@redhat.com>, kernel-team@fb.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Jul 06, 2017 at 02:00:00PM -0400, Debabrata Banerjee wrote:
> On Thu, Jul 6, 2017 at 1:16 PM, Mel Gorman <mgorman@techsingularity.net> wrote:
> >
> > I'm still struggling to see how counters help when an agent that monitors
> > for high CPU usage could be activated
> >
> 
> I suspect Roman has the same problem set as us, the CPU usage is
> either always high, high and service critical likely when something
> interesting is happening. We'd like to collect data on 200k machines,
> and study the results statistically and with respect to time based on
> kernel versions, build configs, hardware types, process types, load
> patterns, etc, etc. Even finding good candidate machines and at the
> right time of day to manually debug with ftrace is problematic.
> Granted we could be utilizing existing counters like compact_fail
> better. Ultimately the data either leads to dealing with certain bad
> actors, different vm tunings, or patches to mm.

Same issue as described in the other mail. The number of high-order
allocations that happened in the past or even the recent past does not
give you useful information for debugging high-order allocation stalls
or fragmentation-related issues. If the high-order allocations are
steady then two machines running similar workloads can both have similar
allocation counts but only one of them may be experiencing high latency.
Similarly, with high CPU usage, it may be due to compaction or a whole
variety of other factors. Even doing a statistical analysis is not going
to be enough unless all the relevant variables are accounted for and the
raw allocation count in isolation is one of the weakest variables to
draw conclusions from.

Correlating allocstall with compaction activity from just /proc/vmstat gives
a much better hint as to whether high CPU activity is due to high-order
allocations. Combining it with top will indicate whether it's direct or
indirect costs. If it really is high-order allocations then ftrace to
identify the source of the high-order allocations becomes relevant and if
it's due to fragmentation, it's a case of tracing the allocator itself to
determine why the fragmentation occurred.

The proc file with allocation counts is such a tiny part of debugging this
class of problem that it's almost irrelevant which is why minimally I think
it should be behind Kconfig at absolute minimum. If you want to activate
it across production machines then by all means go ahead and if so, I'd
be very interested in hearing what class of problem could be debugged and
either tuned or fixed without needing ftrace to gather more information. I
say "almost irrelevant" because technically, correlating high allocation
counts with a kernel version change may be a relevant factor if a kernel
introduced a new source of high-order allocations but I suspect that's
the exception. It would be much more interesting to correlate increased
latency with a kernel version because it's much more relevant. You may
be able to correlate high allocation counts with particular hardware
(particularly network hardware that cannot scatter/gather) *but* the
same proc will will not tell you if those increased requests are
actually a problem so the usefulness is diminished.

I'm not saying that fragmentation and high-order allocation stalls are not a
problem because they can be, but the proc file is unlikely to help and even
an extremely basic systemtap script would give you the same information,
work on much older kernels and with a trivial amount of additional work
it can gather latency information as well as counts.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
