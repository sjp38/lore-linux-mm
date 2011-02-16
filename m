Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C77E58D0039
	for <linux-mm@kvack.org>; Wed, 16 Feb 2011 05:13:31 -0500 (EST)
Date: Wed, 16 Feb 2011 11:13:01 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: vmscan: Stop reclaim/compaction earlier due to
 insufficient progress if !__GFP_REPEAT
Message-ID: <20110216101301.GT5935@random.random>
References: <20110209154606.GJ27110@cmpxchg.org>
 <20110209164656.GA1063@csn.ul.ie>
 <20110209182846.GN3347@random.random>
 <20110210102109.GB17873@csn.ul.ie>
 <20110210124838.GU3347@random.random>
 <20110210133323.GH17873@csn.ul.ie>
 <20110210141447.GW3347@random.random>
 <20110210145813.GK17873@csn.ul.ie>
 <20110216095048.GA4473@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110216095048.GA4473@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Kent Overstreet <kent.overstreet@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Feb 16, 2011 at 09:50:49AM +0000, Mel Gorman wrote:
> The mean allocation times for THP allocations are also slightly reduced.
> The maximum latency was slightly increased as predicted by the comments due
> to reclaim/compaction breaking early. However, workloads care more about the
> latency of lower-order allocations than THP so it's an acceptable trade-off.
> Please consider merging for 2.6.38.

Full agreement. I'm currently dealing with latency issues (nothing
major! but still not nice to see a reproducible regression, even if a
small one only visible in the benchmark) with compaction and jumbo
frames. This won't be enough to close them completely though because I
didn't backport the change to vmscan.c and should_continue_reclaim (I
backported all the other compaction improvements though, so this
practically is the only missing bit). I also suspected the e1000
driver, that sets the NAPI latency to bulk_latency when it uses jumbo
frames, so I wonder if it could be that with compaction we get more
jumbo frames and the latency then gets reduced by the driver as side
effect. Not sure yet.

I like the above because it's less likely to give us compaction issues
with jumbo frames when I add should_continue_reclaim on top. It seems
anonymous memory allocation are orders of magnitude more long lived
than jumbo frames could ever be, so at this point I'm not even
entirely certain it's ok to enable compaction at all for jumbo
frames. But I still like the above regardless of my current issue
(just because of the young bits going nuked in one go the lumpy hammer
way, even if it actually increases latency a bit for THP allocations).

One issue with compaction for jumbo frames, is the potentially very
long loop, for the scan in isolated_migratepages. I added a counter to
break the loop after 1024 pages scanned. This is extreme but this is a
debug patch for now, I also did if (retval == bulk_latency) reval =
low_latency in the e1000* drivers to see if it makes a difference. If
any of the two will help I will track down how much each change
contributes to lowering the network latency to pre-compaction
levels. It may very well be only a compaction issue, or only a driver
issue, I don't know yet (the latter less likely because this very
compaction loop spikes at the top of oprofile output, but maybe that
only affects throughput and the driver is to blame for the latency
reduction... this is what I'm going to find pretty soon). Also this
isolate_migratepages loop I think needs a cond_resched() (I didn't add
that yet ;). 1024 pages scanned is too few, I just want to see how it
behaves with an extremely permissive setting. I'll let you know when I
come to some more reliable conclusion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
