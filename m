Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70264C32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 20:56:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F77D2173C
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 20:56:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F77D2173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C1AB16B0003; Wed,  7 Aug 2019 16:56:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BCCCB6B0006; Wed,  7 Aug 2019 16:56:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A6CC56B0007; Wed,  7 Aug 2019 16:56:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4F5DA6B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 16:56:20 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id e8so43961684wrw.15
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 13:56:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Zw8yXbuc98YfhV7oY7CJ8BrFZpWnQLErvc6qdb484aY=;
        b=hZZ8E+x+tsBkAb3KIsU4m5JKvDF+J/Ybjh7qtLPaur4gAWEB7NePYpRKrECGN7WLsV
         k7i10vhi8pMz65f5X4tjAah3V5a0O8wZQ5V3tDC+M9eaEsUjhcdtmkVanSFTKSqwSScz
         glHFWsDi054fsCwBsqn6l4vPet4yHrL4SdxmwETv+QZGST8+O5GRODk5nfktMnI6CQ7n
         BkxUTFkXcl4Q3edSgHfQUaffcuWGmVrTNLxi6VjA5N9kUhXZ688SSB1jY249mYJ6aSkK
         dDUbId6KcH1FKEoOa0dq+tueyx+cvAFRFeJQ+r5NwRjjoHB49LY6tqjMpMlFVD9o4XHT
         iBSw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.8 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAVA0t0KMC56UePCrGtBqqzeZYVwauSk8sjNWDvzmAK0y1/EZmWB
	59nvX5zqGt58CoMn9SdqvmtyZDaXOAdKZE4gbYppboo2e7Bd3PRHiG7BmRatE/xfW8pH6l59pGh
	lT7WCpZSkfehROF8M/MliZ4c07RdcnFLw15oBfptiV6PpuuBclKrZWyC9vLD+HInvGQ==
X-Received: by 2002:a1c:f018:: with SMTP id a24mr225950wmb.66.1565211379722;
        Wed, 07 Aug 2019 13:56:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxlg89QQJk+xR5fm5Ye7mAqPmIFppQf5Y6JKnLFjqGjz6lVhke4Kyg5TTTcRYKmKfWDpKwX
X-Received: by 2002:a1c:f018:: with SMTP id a24mr225887wmb.66.1565211378305;
        Wed, 07 Aug 2019 13:56:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565211378; cv=none;
        d=google.com; s=arc-20160816;
        b=CoTptSI+i2DPEogGvNNz9E5F/c92IOwSUScBUuON0DUxeFiXjgubd4RXTpucKfyqH1
         GY8AmOY1Tbm86pi6WLnnpSKx1wlQtGGMYXZXIRNCzzR65NXNythJ4C6/eZInkm/PQFXu
         xeLuT1ZV9wvsx54XpS1s1qt41ktC3x069A7zDHWAEQt9nhk/TWPMhji89hyOywqhC8Ha
         9Jbv55ohZTHkAZVqZVLtsIFAuuu/r1CmaKRPC/ZU9ybPuKIi1SVEx3jGJ2MHzaLtgxYn
         ZNjfVdPZnhug4KezLZ1v4D/6R49u+PYsq3pCytbrMk2k6Yf3dN1WUCqjhOIOusAWuRsq
         N7BQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Zw8yXbuc98YfhV7oY7CJ8BrFZpWnQLErvc6qdb484aY=;
        b=iw6dSMmTZkQej9ooIxQOvXs/UAWFbMipZNfBmJ6+wpBSkL0cbwgZAYQhiyUDYM3n2y
         Vq3QcPdjI/q/QOnU9cs3A7XyoMVssINK59yPR4vxLVglQ211xpLIGZ4zj61r6GM9JSoF
         mCSNNrGclo8nyvKzOCFuivuT7dq62JxxgdS4U7bxIfe6BzwsVdSBx8h1VAKSku54oFpw
         CjH8hoYQ8QUvyP5C4PPusVqaR6hETdqms5aJgKj+lq+YhvMs7ZJTcNiyhBxn8XPU7VqI
         YO1G7V0WTel00o8vZRfhnRlaJoR/VZudBkXrZUBZIxyBNQHrukuDkfKofuDmRIUQFXQf
         2jqg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.8 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id e11si137380wma.7.2019.08.07.13.56.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 13:56:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.8 as permitted sender) client-ip=81.17.249.8;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.8 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id C49BE987FF
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 21:56:17 +0100 (IST)
Received: (qmail 29367 invoked from network); 7 Aug 2019 20:56:17 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[84.203.18.93])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 7 Aug 2019 20:56:17 -0000
Date: Wed, 7 Aug 2019 21:56:15 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Dave Chinner <david@fromorbit.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org,
	linux-xfs@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [PATCH] [Regression, v5.0] mm: boosted kswapd reclaim b0rks
 system cache balance
Message-ID: <20190807205615.GI2739@techsingularity.net>
References: <20190807091858.2857-1-david@fromorbit.com>
 <20190807093056.GS11812@dhcp22.suse.cz>
 <20190807150316.GL2708@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190807150316.GL2708@suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 07, 2019 at 04:03:16PM +0100, Mel Gorman wrote:
> <SNIP>
>
> On that basis, it may justify ripping out the may_shrinkslab logic
> everywhere. The downside is that some microbenchmarks will notice.
> Specifically IO benchmarks that fill memory and reread (particularly
> rereading the metadata via any inode operation) may show reduced
> results. Such benchmarks can be strongly affected by whether the inode
> information is still memory resident and watermark boosting reduces
> the changes the data is still resident in memory. Technically still a
> regression but a tunable one.
> 
> Hence the following "it builds" patch that has zero supporting data on
> whether it's a good idea or not.
> 

This is a more complete version of the same patch that summaries the
problem and includes data from my own testing

---8<---
mm, vmscan: Do not special-case slab reclaim when watermarks are boosted

Dave Chinner reported a problem pointing a finger at commit
1c30844d2dfe ("mm: reclaim small amounts of memory when an
external fragmentation event occurs"). The report is extensive (see
https://lore.kernel.org/linux-mm/20190807091858.2857-1-david@fromorbit.com/)
and it's worth recording the most relevant parts (colorful language and
typos included).

	When running a simple, steady state 4kB file creation test to
	simulate extracting tarballs larger than memory full of small
	files into the filesystem, I noticed that once memory fills up
	the cache balance goes to hell.

	The workload is creating one dirty cached inode for every dirty
	page, both of which should require a single IO each to clean and
	reclaim, and creation of inodes is throttled by the rate at which
	dirty writeback runs at (via balance dirty pages). Hence the ingest
	rate of new cached inodes and page cache pages is identical and
	steady. As a result, memory reclaim should quickly find a steady
	balance between page cache and inode caches.

	The moment memory fills, the page cache is reclaimed at a much
	faster rate than the inode cache, and evidence suggests taht
	the inode cache shrinker is not being called when large batches
	of pages are being reclaimed. In roughly the same time period
	that it takes to fill memory with 50% pages and 50% slab caches,
	memory reclaim reduces the page cache down to just dirty pages
	and slab caches fill the entirity of memory.

	The LRU is largely full of dirty pages, and we're getting spikes
	of random writeback from memory reclaim so it's all going to shit.
	Behaviour never recovers, the page cache remains pinned at just
	dirty pages, and nothing I could tune would make any difference.
	vfs_cache_pressure makes no difference - I would it up so high
	it should trim the entire inode caches in a singel pass, yet it
	didn't do anything. It was clear from tracing and live telemetry
	that the shrinkers were pretty much not running except when
	there was absolutely no memory free at all, and then they did
	the minimum necessary to free memory to make progress.

	So I went looking at the code, trying to find places where pages
	got reclaimed and the shrinkers weren't called. There's only one
	- kswapd doing boosted reclaim as per commit 1c30844d2dfe ("mm:
	reclaim small amounts of memory when an external fragmentation
	event occurs").

The watermark boosting introduced by the commit is triggered in response
to an allocation "fragmentation event". The boosting was not intended
to target THP specifically.  However, with Dave's perfectly reasonable
workload, fragmentation events can be very common given the ratio of slab
to page cache allocations so boosting remains active for long periods
of time.

As high-order allocations typically use compaction and compaction cannot
move slab pages the decision was made in the commit to special-case kswapd
when watermarks are boosted -- kswapd avoids reclaiming slab as reclaiming
slab does not directly help compaction.

As Dave notes, this decision means that slab can be artificially protected
for long periods of time and messes up the balance with slab and page
caches.

Removing the special casing can still indirectly help fragmentation by
avoiding fragmentation-causing events due to slab allocation as pages
from a slab pageblock will have some slab objects freed.  Furthermore,
with the special casing, reclaim behaviour is unpredictable as kswapd
sometimes examines slab and sometimes does not in a manner that is tricky
to tune against and tricky to analyse.

This patch removes the special casing. The downside is that this is
not a universal performance win. Some benchmarks that depend on the
residency of data when rereading metadata may see a regression when
slab reclaim is restored to its original behaviour. Similarly, some
benchmarks that only read-once or write-once may perform better when page
reclaim is too aggressive. The primary upside is that slab shrinker is
less surprising (arguably more sane but that's a matter of opinion) and
behaves consistently regardless of the fragmentation state of the system.

A fsmark benchmark configuration was constructed similar to
what Dave reported and is codified by the mmtest configuration
config-io-fsmark-small-file-stream.  It was evaluated on a 1-socket machine
to avoid dealing with NUMA-related issues and the timing of reclaim. The
storage was an SSD Samsung Evo and a fresh XFS filesystem was used for
the test data.

It is likely that the test configuration is not a proper match for Dave's
test as the results are different in terms of performance. However, my
configuration reports fsmark performance every 10% of memory worth of
files and I suspect Dave's configuration reported Files/sec when memory
was already full. THP was enabled for mine, disabled for Dave's and
probably a whole load of other methodology differences that rarely
get recorded properly.

fsmark
                                   5.3.0-rc3              5.3.0-rc3
                                     vanilla          shrinker-v1r1
Min       1-files/sec     5181.70 (   0.00%)     3204.20 ( -38.16%)
1st-qrtle 1-files/sec    14877.10 (   0.00%)     6596.90 ( -55.66%)
2nd-qrtle 1-files/sec     6521.30 (   0.00%)     5707.80 ( -12.47%)
3rd-qrtle 1-files/sec     5614.30 (   0.00%)     5363.80 (  -4.46%)
Max-1     1-files/sec    18463.00 (   0.00%)    18479.90 (   0.09%)
Max-5     1-files/sec    18028.40 (   0.00%)    17829.00 (  -1.11%)
Max-10    1-files/sec    17502.70 (   0.00%)    17080.90 (  -2.41%)
Max-90    1-files/sec     5438.80 (   0.00%)     5106.60 (  -6.11%)
Max-95    1-files/sec     5390.30 (   0.00%)     5020.40 (  -6.86%)
Max-99    1-files/sec     5271.20 (   0.00%)     3376.20 ( -35.95%)
Max       1-files/sec    18463.00 (   0.00%)    18479.90 (   0.09%)
Hmean     1-files/sec     7459.11 (   0.00%)     6249.49 ( -16.22%)
Stddev    1-files/sec     4733.16 (   0.00%)     4362.10 (   7.84%)
CoeffVar  1-files/sec       51.66 (   0.00%)       57.49 ( -11.29%)
BHmean-99 1-files/sec     7515.09 (   0.00%)     6351.81 ( -15.48%)
BHmean-95 1-files/sec     7625.39 (   0.00%)     6486.09 ( -14.94%)
BHmean-90 1-files/sec     7803.19 (   0.00%)     6588.61 ( -15.57%)
BHmean-75 1-files/sec     8518.74 (   0.00%)     6954.25 ( -18.37%)
BHmean-50 1-files/sec    10953.31 (   0.00%)     8017.89 ( -26.80%)
BHmean-25 1-files/sec    16732.38 (   0.00%)    11739.65 ( -29.84%)

                   5.3.0-rc3   5.3.0-rc3
                     vanillashrinker-v1r1
Duration User          77.29       89.09
Duration System      1097.13     1332.86
Duration Elapsed     2014.14     2596.39

This is showing that fsmark runs slower as a result of this patch but
there are other important observations that justify the patch.

1. With the vanilla kernel, the number of dirty pages in the system
   is very low for much of the test. With this patch, dirty pages
   is generally kept at 10% which matches vm.dirty_background_ratio
   which is normal expected historical behaviour.

2. With the vanilla kernel, the ratio of Slab/Pagecache is close to
   0.95 for much of the test i.e. Slab is being left alone and dominating
   memory consumption. With the patch applied, the ratio varies between
   0.35 and 0.45 with the bulk of the measured ratios roughly half way
   between those values. This is a different balance to what Dave reported
   but it was at least consistent.

3. Slabs are scanned throughout the entire test with the patch applied.
   The vanille kernel has long periods with no scan activity and then
   relatively massive spikes.

4. Overall vmstats are closer to normal expectations

	                                5.3.0-rc3      5.3.0-rc3
	                                  vanilla  shrinker-v1r1
	Direct pages scanned             60308.00        5226.00
	Kswapd pages scanned          18316110.00    12295574.00
	Kswapd pages reclaimed        13121037.00     7280152.00
	Direct pages reclaimed           11817.00        5226.00
	Kswapd efficiency %                 71.64          59.21
	Kswapd velocity                   9093.76        4735.64
	Direct efficiency %                 19.59         100.00
	Direct velocity                     29.94           2.01
	Page reclaim immediate          247921.00           0.00
	Slabs scanned                 16602344.00    29369536.00
	Direct inode steals               1574.00         800.00
	Kswapd inode steals             130033.00     3968788.00
	Kswapd skipped wait                  0.00           0.00

	o Vanilla kernel is hitting direct reclaim more frequently,
	  not very much in absolute terms but the fact the patch
	  reduces it is interesting
	o "Page reclaim immediate" in the vanilla kernel indicates
	  dirty pages are being encountered at the tail of the LRU.
	  This is generally bad and means in this case that the LRU
	  is not long enough for dirty pages to be cleaned by the
	  background flush in time. This is eliminated by the
	  patch
	o With the patch, kswapd is reclaiming 30 times more slab
	  pages than with the vanilla kernel. This is indicative
	  of the watermark boosting over-protecting slab

A more complete set of tests is being run but the bottom line is that
special casing kswapd to avoid slab behaviour is unpredictable and can
lead to abnormal results for normal workloads. This patch restores the
expected behaviour that slab and page cache is balanced consistently for
a workload with a steady allocation ratio of slab/pagecache pages.

Fixes: 1c30844d2dfe ("mm: reclaim small amounts of memory when an external fragmentation event occurs")
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/vmscan.c | 13 ++-----------
 1 file changed, 2 insertions(+), 11 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index dbdc46a84f63..6051a9007150 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -88,9 +88,6 @@ struct scan_control {
 	/* Can pages be swapped as part of reclaim? */
 	unsigned int may_swap:1;
 
-	/* e.g. boosted watermark reclaim leaves slabs alone */
-	unsigned int may_shrinkslab:1;
-
 	/*
 	 * Cgroups are not reclaimed below their configured memory.low,
 	 * unless we threaten to OOM. If any cgroups are skipped due to
@@ -2714,10 +2711,8 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 			shrink_node_memcg(pgdat, memcg, sc, &lru_pages);
 			node_lru_pages += lru_pages;
 
-			if (sc->may_shrinkslab) {
-				shrink_slab(sc->gfp_mask, pgdat->node_id,
-				    memcg, sc->priority);
-			}
+			shrink_slab(sc->gfp_mask, pgdat->node_id,
+			    memcg, sc->priority);
 
 			/* Record the group's reclaim efficiency */
 			vmpressure(sc->gfp_mask, memcg, false,
@@ -3194,7 +3189,6 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 		.may_writepage = !laptop_mode,
 		.may_unmap = 1,
 		.may_swap = 1,
-		.may_shrinkslab = 1,
 	};
 
 	/*
@@ -3238,7 +3232,6 @@ unsigned long mem_cgroup_shrink_node(struct mem_cgroup *memcg,
 		.may_unmap = 1,
 		.reclaim_idx = MAX_NR_ZONES - 1,
 		.may_swap = !noswap,
-		.may_shrinkslab = 1,
 	};
 	unsigned long lru_pages;
 
@@ -3286,7 +3279,6 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 		.may_writepage = !laptop_mode,
 		.may_unmap = 1,
 		.may_swap = may_swap,
-		.may_shrinkslab = 1,
 	};
 
 	set_task_reclaim_state(current, &sc.reclaim_state);
@@ -3598,7 +3590,6 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 		 */
 		sc.may_writepage = !laptop_mode && !nr_boost_reclaim;
 		sc.may_swap = !nr_boost_reclaim;
-		sc.may_shrinkslab = !nr_boost_reclaim;
 
 		/*
 		 * Do some background aging of the anon list, to give

