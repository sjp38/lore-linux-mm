Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 8E8896B0070
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 05:33:26 -0400 (EDT)
Received: by wifx6 with SMTP id x6so40982971wif.0
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 02:33:26 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d7si16736435wjn.85.2015.06.10.02.33.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Jun 2015 02:33:19 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 0/6] Assorted compaction cleanups and optimizations
Date: Wed, 10 Jun 2015 11:32:28 +0200
Message-Id: <1433928754-966-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rik van Riel <riel@redhat.com>

This series is partly the cleanups that were posted as part of the RFC for
changing initial scanning positions [1] and partly new relatively simple
scanner optimizations (yes, they are still possible). I've resumed working
on the bigger scanner changes, but that will take a while, so no point in
delaying these smaller patches.

The interesting patches are 4 and 5, and somewhat patch 6. In 4, skipping of
compound pages in single iteration is improved for migration scanner, so it
works also for !PageLRU compound pages such as hugetlbfs, slab etc. Patch 5
introduces this kind of skipping in the free scanner. The trick is that we
can read compound_order() without any protection, if we are careful to filter
out values larger than MAX_ORDER. The only danger is that we skip too much.
The same trick was already used for reading the freepage order in the migrate
scanner.

Patch 6 avoids some rescanning when compaction restarts from cached scanner
positions, but the benefits are small enough to be lost in the noise.

To demonstrate improvements of Patches 4 and 5 I've run stress-highalloc from
mmtests, set to simulate THP allocations (including __GFP_COMP) on a 4GB system
where 1GB was occupied by hugetlbfs pages. I'll include just the relevant
stats:

                               Patch 3     Patch 4     Patch 5     Patch 6

Compaction stalls                 7523        7529        7515        7495
Compaction success                 323         304         322         289
Compaction failures               7200        7224        7192        7206
Page migrate success            247778      264395      240737      248956
Page migrate failure             15358       33184       21621       23657
Compaction pages isolated       906928      980192      909983      958044
Compaction migrate scanned     2005277     1692805     1498800     1750952
Compaction free scanned       13255284    11539986     9011276     9703018
Compaction cost                    288         305         277         289

With 5 iterations per patch, the results are still noisy, but we can see that
Patch 4 does reduce migrate_scanned by 15% thanks to skipping the hugetlbfs
pages at once. Interestingly, free_scanned is also reduced and I have no idea
why. Patch 5 further reduces free_scanned as expected, by 15%. Other stats
are unaffected modulo noise. Patch 6 looks like a regression but I believe it's
just the noise. I've verified that compaction now restarts from the exact pfns
it left off, using tracepoints.

[1] https://lkml.org/lkml/2015/1/19/158

Vlastimil Babka (6):
  mm, compaction: more robust check for scanners meeting
  mm, compaction: simplify handling restart position in free pages
    scanner
  mm, compaction: encapsulate resetting cached scanner positions
  mm, compaction: always skip compound pages by order in migrate scanner
  mm, compaction: skip compound pages by order in free scanner
  mm, compaction: decouple updating pageblock_skip and cached pfn

 mm/compaction.c | 188 ++++++++++++++++++++++++++++++++++----------------------
 1 file changed, 115 insertions(+), 73 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
