Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C62A66B025F
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 09:23:55 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id l4so3964559wre.10
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 06:23:55 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h27si3827297ede.369.2017.11.30.06.23.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 30 Nov 2017 06:23:54 -0800 (PST)
Date: Thu, 30 Nov 2017 15:23:52 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: dd: page allocation failure: order:0,
 mode:0x1080020(GFP_ATOMIC), nodemask=(null)
Message-ID: <20171130142352.3iva2g5ygn4byh7r@dhcp22.suse.cz>
References: <20171130133840.6yz4774274e5scpi@wfg-t540p.sh.intel.com>
 <20171130135016.dfzj2s7ngz55tfws@dhcp22.suse.cz>
 <20171130140103.arapa4qphgtmjyqm@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171130140103.arapa4qphgtmjyqm@wfg-t540p.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, lkp@01.org

On Thu 30-11-17 22:01:03, Wu Fengguang wrote:
> On Thu, Nov 30, 2017 at 02:50:16PM +0100, Michal Hocko wrote:
> > On Thu 30-11-17 21:38:40, Wu Fengguang wrote:
> > > Hello,
> > > 
> > > It looks like a regression in 4.15.0-rc1 -- the test case simply run a
> > > set of parallel dd's and there seems no reason to run into memory problem.
> > > 
> > > It occurs in 1 out of 4 tests.
> > 
> > This is an atomic allocations. So the failure really depends on the
> > state of the free memory and that can vary between runs depending on
> > timing I guess. So I am not really sure this is a regression. But maybe
> > there is something reclaim related going on here.
> 
> Yes, it does depend on how the drivers rely on atomic allocations.
> I just wonder if any changes make the pressure more tight than before.
> It may not even be a MM change -- in theory drivers might also use atomic
> allocations more aggressively than before.
> 
[...]
> Attached the JSON format per-second vmstat records.
> It feels more readable than the raw dumps.

Well from a quick check it seems that there is just a legit memory
pressure where kswapd doesn't keep up with the allocation pace. If we
just check the overal kswapd reclaim efficiency
(proc-vmstat.pgsteal_kswapd/proc-vmstat.pgscan_kswapd)
13311631/1331957
then we are ~99% which means that kswad made a good work to reclaim and
didn't stumble over anything. We reclaim _a lot_ from the direct reclaim
context which means that kswapd doesn't keep up at all
(proc-vmstat.pgsteal_direct/proc-vmstat.pgscan_direct)
107767391/108058968 again ~99% but 8x the kswapd of what kswapd does.

If you look at diffs in pgsteal numbers, we are at 2M pages reclaimed
per second for the direct reclaim and ~200k p/s from kswapd. kswapd is
naturally slower as it is a single thread compared to many reclaimers
hitting the direct reclaim at once.

allocstall numbers show that this was not a single peak but rather a
continual direct reclaim storm, starting with dozens of direct reclaim
invocations per second reaching to hundres on zone Normal and even worse
on the movable zone where we are in thousands (just have a look at diffs
between respective numbres).

So from a quick look it really seems like a heavy memory pressure rather
than some reclaim defficiency to me.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
