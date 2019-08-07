Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18BCBC433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 15:03:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE9D121BF2
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 15:03:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE9D121BF2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 730126B0008; Wed,  7 Aug 2019 11:03:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E08C6B000A; Wed,  7 Aug 2019 11:03:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A9D26B000C; Wed,  7 Aug 2019 11:03:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0BBB16B0008
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 11:03:22 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d27so56323029eda.9
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 08:03:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=FtU1yk4qb3OKy6rZUt25Aap3Qbq8Nbypo+xEHB95J80=;
        b=hIky2SWXJyEgQyO8xhsNLTkR5WEdkAxL0X7bI/jhD0VyeF3v5nlmVteM7Q3xhlj9qV
         O7UgdtwKOWwl53yfoA3exvxbIa/6uCK48taZGoovS0A1StwYb0FtmEolpboPeZ6tPXx0
         uRqx23xmNDqjxzMIxDP8Kq5xr6R9lQrwVF5jTk1k9qtpGq1bpv9wxdoujNjGbqJd1gvo
         +XCadJWxA9252W2JaY0OMdHsE2r/xDt3qHN+Xau1u+vKSA4qzLkutMNfmjawpFRhxvR3
         9OYPD6/Q1U7k90pQq8YuVkF125sKZxD9ZTVrmOzXzHpoBFfQiUKuSJP40+vSWFXI1FBX
         zS7w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Gm-Message-State: APjAAAWMucLWcVRc+SO4BjMw312g2ONfq5rcHcYyZ64cFUaOazv8t5se
	IhwIudsygN9tHM5tcZEEKNMgCswaDbcwYDr7tUmv1fNhuQoc5KR/2Qfn64G6skS9+VgFaGWV9Oc
	td46igu4Rz6HYOoUlJCIAd0M9zR1+B0+y3DN3BBgJyweSsaNPNP7aHQR+jSBUA2ndHQ==
X-Received: by 2002:a17:906:2ecc:: with SMTP id s12mr8781723eji.110.1565190201555;
        Wed, 07 Aug 2019 08:03:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxaFtZqA3OPILkUBXeQwn1byObS77EfdBIC/1QsxcXXfSLODM/rXi687VEqsVUtQTqMX918
X-Received: by 2002:a17:906:2ecc:: with SMTP id s12mr8781625eji.110.1565190200474;
        Wed, 07 Aug 2019 08:03:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565190200; cv=none;
        d=google.com; s=arc-20160816;
        b=TowcTN6wk4bl3oueYc2nqgJdVrIlCES/5nyU4c95dAP04PYf32rh/11mohsyJW1Y25
         ZKTej1AQz4AfX/x9/Uot31Q3AlGprTIKD4ao2jREtZBxJL0/znLov21lIHmv79mLYJI0
         csNm2Pe+Ym28fB1/o19H86pVqRhs0qLdeFSdUayKAO+gLpwfC/Lpi304DtV2ayBgv16L
         8gGLCpTKuAsbsNxHmolJMz+a7ZMPYrNEftb6huLo2025rf2I64E12TQMcT5yGxpHtTXl
         P0VFkKNJlfMnkPi3Fzotvv5IYBh2CLFXRNIA5P/zS6U8N+XT7fGTQ9Yt7wS8lDPermC0
         7HNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=FtU1yk4qb3OKy6rZUt25Aap3Qbq8Nbypo+xEHB95J80=;
        b=Tu33KVPxKaoOKkpUCDAp7U7NSWdrlLadUKqQu3GKNiMubteZav+PyzIzXV2sGhqASs
         qQu/2dbT+C04PtX56aprruD3pIKk8MqxlWctG5s3WogU3wht7wTNkax2nQEiivrehn2Q
         XLWtddFEkhUavY1EHa+IbetTE2g4UuQ4gpHjWGZPAN6vDzVOOCA8XiPLVKOGgrO4P1RH
         IarMpB/yqQOq9trPGQuS/fTGJTBzP8Rpek/f4/nhmdi5MWijkg6VUIaMPDMwfGul8T9G
         tR4ntUq8eLlcPiRWHlTNNvaaT64VDTCFQLb0E+J+tcu0CFLnMUMUA6zLU+AZBsDZQoqN
         Q4GA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gt25si28853119ejb.314.2019.08.07.08.03.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 08:03:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A90F5AFA7;
	Wed,  7 Aug 2019 15:03:19 +0000 (UTC)
Date: Wed, 7 Aug 2019 16:03:16 +0100
From: Mel Gorman <mgorman@suse.de>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org,
	linux-xfs@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [PATCH] [Regression, v5.0] mm: boosted kswapd reclaim b0rks
 system cache balance
Message-ID: <20190807150316.GL2708@suse.de>
References: <20190807091858.2857-1-david@fromorbit.com>
 <20190807093056.GS11812@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190807093056.GS11812@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 07, 2019 at 11:30:56AM +0200, Michal Hocko wrote:
> [Cc Mel and Vlastimil as it seems like fallout from 1c30844d2dfe2]
> 

More than likely.

> On Wed 07-08-19 19:18:58, Dave Chinner wrote:
> > From: Dave Chinner <dchinner@redhat.com>
> > 
> > When running a simple, steady state 4kB file creation test to
> > simulate extracting tarballs larger than memory full of small files
> > into the filesystem, I noticed that once memory fills up the cache
> > balance goes to hell.
> > 

Ok, I'm assuming you are using fsmark with -k to keep files around,
and -S0 to leave cleaning to the background flush, a number of files per
iteration to get regular reporting and a total number of iterations to
fill memory to hit what you're seeing. I've created a configuration that
should do this but it'll take a long time to run on a local test machine.

I'm not 100% certain I guessed right as to get fsmark reports while memory
fills, it would have to be fewer files so each iteration would have to
preserve files. If the number of files per iteration is large enough to
fill memory then the drop in files/sec is not visible from the fs_mark
output (or we are using different versions). I guess you could just be
calculating average files/sec over the entire run based on elapsed time.

> > The workload is creating one dirty cached inode for every dirty
> > page, both of which should require a single IO each to clean and
> > reclaim, and creation of inodes is throttled by the rate at which
> > dirty writeback runs at (via balance dirty pages). Hence the ingest
> > rate of new cached inodes and page cache pages is identical and
> > steady. As a result, memory reclaim should quickly find a steady
> > balance between page cache and inode caches.
> > 
> > It doesn't.
> > 
> > The moment memory fills, the page cache is reclaimed at a much
> > faster rate than the inode cache, and evidence suggests taht the
> > inode cache shrinker is not being called when large batches of pages
> > are being reclaimed. In roughly the same time period that it takes
> > to fill memory with 50% pages and 50% slab caches, memory reclaim
> > reduces the page cache down to just dirty pages and slab caches fill
> > the entirity of memory.
> > 
> > At the point where the page cache is reduced to just the dirty
> > pages, there is a clear change in write IO patterns. Up to this
> > point it has been running at a steady 1500 write IOPS for ~200MB/s
> > of write throughtput (data, journal and metadata).

As observed by iostat -x or something else? Sum of r/s and w/s would
approximate iops but not the breakdown of whether it is data, journal
or metadata writes. The rest can be inferred from a blktrace but I would
prefer to replicate your setup as close as possible. If you're not using
fs_mark to report Files/sec, are you simply monitoring df -i over time?

> > <SNIP additional detail on fs_mark output>
> > <SNIP additional detail on monitoring meminfo over time>
> > <SNIP observations on dirty handling>

All understood.

> > So I went looking at the code, trying to find places where pages got
> > reclaimed and the shrinkers weren't called. There's only one -
> > kswapd doing boosted reclaim as per commit 1c30844d2dfe ("mm: reclaim
> > small amounts of memory when an external fragmentation event
> > occurs"). I'm not even using THP or allocating huge pages, so this
> > code should not be active or having any effect onmemory reclaim at
> > all, yet the majority of reclaim is being done with "boost" and so
> > it's not reclaiming slab caches at all. It will only free clean
> > pages from the LRU.
> > 
> > And so when we do run out memory, it switches to normal reclaim,
> > which hits dirty pages on the LRU and does some shrinker work, too,
> > but then appears to switch back to boosted reclaim one watermarks
> > are reached.
> > 
> > The patch below restores page cache vs inode cache balance for this
> > steady state workload. It balances out at about 40% page cache, 60%
> > slab cache, and sustained performance is 10-15% higher than without
> > this patch because the IO patterns remain in control of dirty
> > writeback and the filesystem, not kswapd.
> > 
> > Performance with boosted reclaim also running shrinkers over the
> > same steady state portion of the test as above.
> > 

The boosting was not intended to target THP specifically -- it was meant
to help recover early from any fragmentation-related event for any user
that might need it. Hence, it's not tied to THP but even with THP
disabled, the boosting will still take effect.

One band-aid would be to disable watermark boosting entirely when THP is
disabled but that feels wrong. However, I would be interested in hearing
if sysctl vm.watermark_boost_factor=0 has the same effect as your patch.

The intention behind avoiding slab reclaim from kswapd context is that the
boost is due to a fragmentation-causing event. Compaction cannot move slab
pages so reclaiming them in response to fragmentation does not directly
help. However, it can indirectly help by avoiding fragmentation-causing
events due to slab allocation like inodes and also mean that reclaim
behaviour is not special cased.

On that basis, it may justify ripping out the may_shrinkslab logic
everywhere. The downside is that some microbenchmarks will notice.
Specifically IO benchmarks that fill memory and reread (particularly
rereading the metadata via any inode operation) may show reduced
results. Such benchmarks can be strongly affected by whether the inode
information is still memory resident and watermark boosting reduces
the changes the data is still resident in memory. Technically still a
regression but a tunable one.

Hence the following "it builds" patch that has zero supporting data on
whether it's a good idea or not.

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

-- 
Mel Gorman
SUSE Labs

