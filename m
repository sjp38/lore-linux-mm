Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C598C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 18:29:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF096217D7
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 18:29:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF096217D7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 45B116B0003; Thu,  8 Aug 2019 14:29:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 430896B0006; Thu,  8 Aug 2019 14:29:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2FA0F6B0007; Thu,  8 Aug 2019 14:29:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id D44D46B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 14:29:50 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id f9so45509713wrq.14
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 11:29:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=DMKsmv2cBCIJYQLkMc9993AXiE3libtfLlDJll9ON10=;
        b=qIkwAcG2X7033R6H7BDjAIWPZPhb+lv077UM96nJl96hsHAsQL2J34HVQWNElJ9i0U
         HyEdGgO/Rwk5mGbl+Cwt+5dTjni7zfWFGs5iPjIJNeBIuBilOteTDr7VBJecCUD2ueSK
         bf0OLlNukLF/7vFr61i5TaAz3d8vaiZzq72iBS58ID1zlJbK6s+uKrofSggTJw+KtTrH
         MwHKZCQYYjl7u/2zfR5TVlTKqgZ8unbKLHTvKFmKpUyTfgNFeSXnBLXcKxpZJgWcJVu2
         p0MtQJkSwv60+ddlf6mEW/0wQLOFz3Pov0OdHE8j+BReSX0Tedyl+EUJpgvjrg8FKvH/
         Kwlw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.66 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAWYfv6t9fXzkukeNeSg8etPuon8KE/uYVyq0FkP5GUvOdEp7HZU
	fRrwwdQy0CpVsI3JxpIst+vt1tAtS/NmJYj2MIS69tPsCcKl8nStgWCbOtNa/urvTcMnmyum6wF
	V++TY1XHjPdKIHPuTzFGAn/hZQl81jL2XLqlLMi5MVmwXFT/5J5Bp8MfdKHxVfjSkgQ==
X-Received: by 2002:a7b:ce18:: with SMTP id m24mr5781370wmc.126.1565288990318;
        Thu, 08 Aug 2019 11:29:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwAu++vuSJ1RnYEI5ps8fIGw9c8dMKzvdezxexs78oMDT8lhs9yCBchpPI1gZPY1FW1yHUQ
X-Received: by 2002:a7b:ce18:: with SMTP id m24mr5781265wmc.126.1565288988861;
        Thu, 08 Aug 2019 11:29:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565288988; cv=none;
        d=google.com; s=arc-20160816;
        b=pp8IEgWZPin0MlugSN0HUZz7Xno8yooybSIyMbNc2jHxwsv9gzFrAzZNZexpUBQh9/
         jzDtnYuoWjLn6CP67nQ0+NMFornm1lvgv7RyhAt2YfV7tWCbO9PVRnJqHXJUdh5oI9HU
         yQMVIxES8XD0PnuRHcM4OYbkF11mtQi0Sr023j+UlnTMtL4gbw1OCbVEewps5tuMoBpo
         dYPqy1033TPoDt/9XJgIHfhKOMa/iL7ziQof08xmTkD8BJYzbHkdhUcwN4fzP+zZkPm5
         B4is/vB0bUXQTYFk+55ij+VJJI/ENh3RG2LaWej/BTzbfDpw4fqStCoJmumdd66xDhrA
         Ma8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=DMKsmv2cBCIJYQLkMc9993AXiE3libtfLlDJll9ON10=;
        b=Z/CaN80p52m7ps/oNJnWprfo6Jd9RNTBvO5yXADDM4xJ1sdfB83fgEnWooOWAeSTX3
         eWyf0PU8BtmRQ42v5e6gQQqgmHLR9Kqbx/83KuTXHfVLxwQtmdtyKugHgW52XVGPIbAz
         FgHVOnMuMU4A6MUmPzysyAk6Yb1rjI8TSQwj48FXHgie56z5q9LwS722SeOD6xa0Ihxs
         3TzAD7bZkoSd26oo2+JcQVC5+828w8b8a2TB2LfQ/RZEfzKB8Q0vqdXz8BoVNsgFxMec
         Qs9rlILVfs34kXLXQeck1rJDMS4HGLjTO7uwOLETkwqb/HYqr91jSLok8kcigd8I4mSu
         cKyA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.66 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp33.blacknight.com (outbound-smtp33.blacknight.com. [81.17.249.66])
        by mx.google.com with ESMTPS id o9si54154059wrm.7.2019.08.08.11.29.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 11:29:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.66 as permitted sender) client-ip=81.17.249.66;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.66 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (unknown [81.17.254.16])
	by outbound-smtp33.blacknight.com (Postfix) with ESMTPS id 6FCFED03CD
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 19:29:48 +0100 (IST)
Received: (qmail 30928 invoked from network); 8 Aug 2019 18:29:48 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[84.203.18.93])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 8 Aug 2019 18:29:48 -0000
Date: Thu, 8 Aug 2019 19:29:46 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Michal Hocko <mhocko@kernel.org>,
	linux-mm@kvack.org, linux-xfs@vger.kernel.org,
	Vlastimil Babka <vbabka@suse.cz>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: [PATCH] mm, vmscan: Do not special-case slab reclaim when watermarks
 are boosted
Message-ID: <20190808182946.GM2739@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

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
to an allocation "fragmentation event". The boosting was not intended to
target THP specifically and triggers even if THP is disabled. However,
with Dave's perfectly reasonable workload, fragmentation events can be
very common given the ratio of slab to page cache allocations so boosting
remains active for long periods of time.

As high-order allocations might use compaction and compaction cannot move
slab pages the decision was made in the commit to special-case kswapd
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
to tune or analyse.

This patch removes the special casing. The downside is that this is not a
universal performance win. Some benchmarks that depend on the residency
of data when rereading metadata may see a regression when slab reclaim
is restored to its original behaviour. Similarly, some benchmarks that
only read-once or write-once may perform better when page reclaim is too
aggressive. The primary upside is that slab shrinker is less surprising
(arguably more sane but that's a matter of opinion), behaves consistently
regardless of the fragmentation state of the system and properly obeys
VM sysctls.

A fsmark benchmark configuration was constructed similar to
what Dave reported and is codified by the mmtest configuration
config-io-fsmark-small-file-stream.  It was evaluated on a 1-socket machine
to avoid dealing with NUMA-related issues and the timing of reclaim. The
storage was an SSD Samsung Evo and a fresh trimmed XFS filesystem was
used for the test data.

This is not an exact replication of Dave's setup. The configuration
scales its parameters depending on the memory size of the SUT to behave
similarly across machines. The parameters mean the first sample reported
by fs_mark is using 50% of RAM which will barely be throttled and look
like a big outlier. Dave used fake NUMA to have multiple kswapd instances
which I didn't replicate.  Finally, the number of iterations differ from
Dave's test as the target disk was not large enough.  While not identical,
it should be representative.

fsmark
                                   5.3.0-rc3              5.3.0-rc3
                                     vanilla          shrinker-v1r1
Min       1-files/sec     4444.80 (   0.00%)     4765.60 (   7.22%)
1st-qrtle 1-files/sec     5005.10 (   0.00%)     5091.70 (   1.73%)
2nd-qrtle 1-files/sec     4917.80 (   0.00%)     4855.60 (  -1.26%)
3rd-qrtle 1-files/sec     4667.40 (   0.00%)     4831.20 (   3.51%)
Max-1     1-files/sec    11421.50 (   0.00%)     9999.30 ( -12.45%)
Max-5     1-files/sec    11421.50 (   0.00%)     9999.30 ( -12.45%)
Max-10    1-files/sec    11421.50 (   0.00%)     9999.30 ( -12.45%)
Max-90    1-files/sec     4649.60 (   0.00%)     4780.70 (   2.82%)
Max-95    1-files/sec     4491.00 (   0.00%)     4768.20 (   6.17%)
Max-99    1-files/sec     4491.00 (   0.00%)     4768.20 (   6.17%)
Max       1-files/sec    11421.50 (   0.00%)     9999.30 ( -12.45%)
Hmean     1-files/sec     5004.75 (   0.00%)     5075.96 (   1.42%)
Stddev    1-files/sec     1778.70 (   0.00%)     1369.66 (  23.00%)
CoeffVar  1-files/sec       33.70 (   0.00%)       26.05 (  22.71%)
BHmean-99 1-files/sec     5053.72 (   0.00%)     5101.52 (   0.95%)
BHmean-95 1-files/sec     5053.72 (   0.00%)     5101.52 (   0.95%)
BHmean-90 1-files/sec     5107.05 (   0.00%)     5131.41 (   0.48%)
BHmean-75 1-files/sec     5208.45 (   0.00%)     5206.68 (  -0.03%)
BHmean-50 1-files/sec     5405.53 (   0.00%)     5381.62 (  -0.44%)
BHmean-25 1-files/sec     6179.75 (   0.00%)     6095.14 (  -1.37%)

                   5.3.0-rc3   5.3.0-rc3
                     vanillashrinker-v1r1
Duration User         501.82      497.29
Duration System      4401.44     4424.08
Duration Elapsed     8124.76     8358.05

This is showing a slight skew for the max result representing a
large outlier for the 1st, 2nd and 3rd quartile are similar indicating
that the bulk of the results show little difference. Note that an
earlier version of the fsmark configuration showed a regression but
that included more samples taken while memory was still filling.

Note that the elapsed time is higher. Part of this is that the
configuration included time to delete all the test files when the test
completes -- the test automation handles the possibility of testing fsmark
with multiple thread counts. Without the patch, many of these objects
would be memory resident which is part of what the patch is addressing.

There are other important observations that justify the patch.

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
   The vanille kernel has periods with no scan activity and then relatively
   massive spikes.

4. Without the patch, kswapd scan rates are very variable. With the patch,
   the scan rates remain quite stead.

4. Overall vmstats are closer to normal expectations

	                                5.3.0-rc3      5.3.0-rc3
	                                  vanilla  shrinker-v1r1
    Ops Direct pages scanned             99388.00      328410.00
    Ops Kswapd pages scanned          45382917.00    33451026.00
    Ops Kswapd pages reclaimed        30869570.00    25239655.00
    Ops Direct pages reclaimed           74131.00        5830.00
    Ops Kswapd efficiency %                 68.02          75.45
    Ops Kswapd velocity                   5585.75        4002.25
    Ops Page reclaim immediate         1179721.00      430927.00
    Ops Slabs scanned                 62367361.00    73581394.00
    Ops Direct inode steals               2103.00        1002.00
    Ops Kswapd inode steals             570180.00     5183206.00

	o Vanilla kernel is hitting direct reclaim more frequently,
	  not very much in absolute terms but the fact the patch
	  reduces it is interesting
	o "Page reclaim immediate" in the vanilla kernel indicates
	  dirty pages are being encountered at the tail of the LRU.
	  This is generally bad and means in this case that the LRU
	  is not long enough for dirty pages to be cleaned by the
	  background flush in time. This is much reduced by the
	  patch.
	o With the patch, kswapd is reclaiming 10 times more slab
	  pages than with the vanilla kernel. This is indicative
	  of the watermark boosting over-protecting slab

A more complete set of tests were run that were part of the basis
for introducing boosting and while there are some differences, they
are well within tolerances.

Bottom line, the special casing kswapd to avoid slab behaviour is
unpredictable and can lead to abnormal results for normal workloads. This
patch restores the expected behaviour that slab and page cache is
balanced consistently for a workload with a steady allocation ratio of
slab/pagecache pages. It also means that if there are workloads that
favour the preservation of slab over pagecache that it can be tuned via
vm.vfs_cache_pressure where as the vanilla kernel effectively ignores
the parameter when boosting is active.

Fixes: 1c30844d2dfe ("mm: reclaim small amounts of memory when an external fragmentation event occurs")
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Reviewed-by: Dave Chinner <dchinner@redhat.com>
Cc: stable@vger.kernel.org # v5.0+
---
 mm/vmscan.c | 13 ++-----------
 1 file changed, 2 insertions(+), 11 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index dbdc46a84f63..c77d1e3761a7 100644
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
+			shrink_slab(sc->gfp_mask, pgdat->node_id, memcg,
+					sc->priority);
 
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

