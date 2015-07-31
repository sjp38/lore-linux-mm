Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id BBB056B0256
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 11:28:27 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so36769013wib.1
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 08:28:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dj6si6091717wib.22.2015.07.31.08.28.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 31 Jul 2015 08:28:25 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 0/5] Assorted compaction cleanups and optimizations
Date: Fri, 31 Jul 2015 17:28:02 +0200
Message-Id: <1438356487-7082-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rik van Riel <riel@redhat.com>

v2 changes:
 - dropped Patch 6 as adjusting to Joonsoo's objection would be too
   complicated and the results didn't justify it
 - don't check for compound order > 0 in patches 4 and 5 as suggested by
   Michal Nazarewicz. Negative values are handled by converting to unsinged
   int, the pfn calculations work fine with 0 and it's unlikely to see 0
   due to a race when we just checked PageCompound().

This series is partly the cleanups that were posted as part of the RFC for
changing initial scanning positions [1] and partly new relatively simple
scanner optimizations (yes, they are still possible). I've resumed working
on the bigger scanner changes, but that will take a while, so no point in
delaying these smaller patches.

The interesting patches are 4 and 5. In 4, skipping of compound pages in single
iteration is improved for migration scanner, so it works also for !PageLRU
compound pages such as hugetlbfs, slab etc. Patch 5 introduces this kind of
skipping in the free scanner. The trick is that we can read compound_order()
without any protection, if we are careful to filter out values larger than
MAX_ORDER. The only danger is that we skip too much.  The same trick was
already used for reading the freepage order in the migrate scanner.

To demonstrate improvements of Patches 4 and 5 I've run stress-highalloc from
mmtests, set to simulate THP allocations (including __GFP_COMP) on a 4GB system
where 1GB was occupied by hugetlbfs pages. I'll include just the relevant
stats:

                               Patch 3     Patch 4     Patch 5

Compaction stalls                 7523        7529        7515
Compaction success                 323         304         322
Compaction failures               7200        7224        7192
Page migrate success            247778      264395      240737
Page migrate failure             15358       33184       21621
Compaction pages isolated       906928      980192      909983
Compaction migrate scanned     2005277     1692805     1498800
Compaction free scanned       13255284    11539986     9011276
Compaction cost                    288         305         277

With 5 iterations per patch, the results are still noisy, but we can see that
Patch 4 does reduce migrate_scanned by 15% thanks to skipping the hugetlbfs
pages at once. Interestingly, free_scanned is also reduced and I have no idea
why. Patch 5 further reduces free_scanned as expected, by 15%. Other stats
are unaffected modulo noise.

[1] https://lkml.org/lkml/2015/1/19/158


Vlastimil Babka (5):
  mm, compaction: more robust check for scanners meeting
  mm, compaction: simplify handling restart position in free pages
    scanner
  mm, compaction: encapsulate resetting cached scanner positions
  mm, compaction: always skip compound pages by order in migrate scanner
  mm, compaction: skip compound pages by order in free scanner

 mm/compaction.c | 134 ++++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 86 insertions(+), 48 deletions(-)

-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
