Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2E9CD6B0253
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 09:28:03 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id r144so52234239wme.0
        for <linux-mm@kvack.org>; Fri, 27 Jan 2017 06:28:03 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g20si6121206wrd.211.2017.01.27.06.28.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 27 Jan 2017 06:28:01 -0800 (PST)
Date: Fri, 27 Jan 2017 14:27:56 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 3/5] mm: vmscan: remove old flusher wakeup from direct
 reclaim path
Message-ID: <20170127142756.bk6px3urilprlayl@suse.de>
References: <20170123181641.23938-1-hannes@cmpxchg.org>
 <20170123181641.23938-4-hannes@cmpxchg.org>
 <20170126100509.gbf6rxao6gsmqyq3@suse.de>
 <20170126185027.GB30636@cmpxchg.org>
 <20170127120101.GA4148@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170127120101.GA4148@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Jan 27, 2017 at 01:01:01PM +0100, Michal Hocko wrote:
> On Thu 26-01-17 13:50:27, Johannes Weiner wrote:
> > On Thu, Jan 26, 2017 at 10:05:09AM +0000, Mel Gorman wrote:
> > > On Mon, Jan 23, 2017 at 01:16:39PM -0500, Johannes Weiner wrote:
> > > > Direct reclaim has been replaced by kswapd reclaim in pretty much all
> > > > common memory pressure situations, so this code most likely doesn't
> > > > accomplish the described effect anymore. The previous patch wakes up
> > > > flushers for all reclaimers when we encounter dirty pages at the tail
> > > > end of the LRU. Remove the crufty old direct reclaim invocation.
> > > > 
> > > > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > > 
> > > In general I like this. I worried first that if kswapd is blocked
> > > writing pages that it won't reach the wakeup_flusher_threads but the
> > > previous patch handles it.
> > > 
> > > Now though, it occurs to me with the last patch that we always writeout
> > > the world when flushing threads. This may not be a great idea. Consider
> > > for example if there is a heavy writer of short-lived tmp files. In such a
> > > case, it is possible for the files to be truncated before they even hit the
> > > disk. However, if there are multiple "writeout the world" calls, these may
> > > now be hitting the disk. Furthermore, multiplle kswapd and direct reclaimers
> > > could all be requested to writeout the world and each request unplugs.
> > > 
> > > Is it possible to maintain the property of writing back pages relative
> > > to the numbers of pages scanned or have you determined already that it's
> > > not necessary?
> > 
> > That's what I started out with - waking the flushers for nr_taken. I
> > was using a silly test case that wrote < dirty background limit and
> > then allocated a burst of anon memory. When the dirty data is linear,
> > the bigger IO requests are beneficial. They don't exhaust struct
> > request (like kswapd 4k IO routinely does, and SWAP_CLUSTER_MAX is
> > only 32), and they require less frequent plugging.
> > 
> > Force-flushing temporary files under memory pressure is a concern -
> > although the most recently dirtied files would get queued last, giving
> > them still some time to get truncated - but I'm wary about splitting
> > the flush requests too aggressively when we DO sustain throngs of
> > dirty pages hitting the reclaim scanners.
> 
> I think the above would be helpful in the changelog for future
> reference.
> 

Agreed. I backported the series to 4.10-rc5 with one minor conflict and
ran a couple of tests on it. Mix of read/write random workload didn't show
anything interesting. Write-only database didn't show much difference in
performance but there were slight reductions in IO -- probably in the noise.

simoop did show big differences although not as big as I expected. This
is Chris Mason's workload that similate the VM activity of hadoop. I
won't go through the full details but over the samples measured during
an hour it reported

                                         4.10.0-rc5            4.10.0-rc5
                                            vanilla         johannes-v1r1
Amean    p50-Read             21346531.56 (  0.00%) 21697513.24 ( -1.64%)
Amean    p95-Read             24700518.40 (  0.00%) 25743268.98 ( -4.22%)
Amean    p99-Read             27959842.13 (  0.00%) 28963271.11 ( -3.59%)
Amean    p50-Write                1138.04 (  0.00%)      989.82 ( 13.02%)
Amean    p95-Write             1106643.48 (  0.00%)    12104.00 ( 98.91%)
Amean    p99-Write             1569213.22 (  0.00%)    36343.38 ( 97.68%)
Amean    p50-Allocation          85159.82 (  0.00%)    79120.70 (  7.09%)
Amean    p95-Allocation         204222.58 (  0.00%)   129018.43 ( 36.82%)
Amean    p99-Allocation         278070.04 (  0.00%)   183354.43 ( 34.06%)
Amean    final-p50-Read       21266432.00 (  0.00%) 21921792.00 ( -3.08%)
Amean    final-p95-Read       24870912.00 (  0.00%) 26116096.00 ( -5.01%)
Amean    final-p99-Read       28147712.00 (  0.00%) 29523968.00 ( -4.89%)
Amean    final-p50-Write          1130.00 (  0.00%)      977.00 ( 13.54%)
Amean    final-p95-Write       1033216.00 (  0.00%)     2980.00 ( 99.71%)
Amean    final-p99-Write       1517568.00 (  0.00%)    32672.00 ( 97.85%)
Amean    final-p50-Allocation    86656.00 (  0.00%)    78464.00 (  9.45%)
Amean    final-p95-Allocation   211712.00 (  0.00%)   116608.00 ( 44.92%)
Amean    final-p99-Allocation   287232.00 (  0.00%)   168704.00 ( 41.27%)

The latencies are actually completely horrific in comparison to 4.4 (and
4.10-rc5 is worse than 4.9 according to historical data for reasons I
haven't analysed yet).

Still, 95% of write latency (p95-write) is halved by the series and
allocation latency is way down. Direct reclaim activity is one fifth of
what it was according to vmstats. Kswapd activity is higher but this is not
necessarily surprising. Kswapd efficiency is unchanged at 99% (99% of pages
scanned were reclaimed) but direct reclaim efficiency went from 77% to 99%

In the vanilla kernel, 627MB of data was written back from reclaim
context. With the series, no data was written back. With or without the
patch, pages are being immediately reclaimed after writeback completes.
However, with the patch, only 1/8th of the pages are reclaimed like
this.

I expect you've done plenty of internal analysis but FWIW, I can confirm
for some basic tests that exercise this are and on one machine that it's
looking good and roughly matches my expectations.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
