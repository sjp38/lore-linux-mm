Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 032596B0005
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 08:39:54 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id a4so209450972wme.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 05:39:53 -0800 (PST)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id 5si39645153wmw.30.2016.02.23.05.39.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 23 Feb 2016 05:39:52 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 44CE8989F4
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 13:39:52 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 1/1] mm: numa: Quickly fail allocations for NUMA balancing on full nodes
Date: Tue, 23 Feb 2016 13:39:51 +0000
Message-Id: <1456234791-31502-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

Commit 4167e9b2cf10 ("mm: remove GFP_THISNODE") removed the
GFP_THISNODE flag combination due to confusing semantics. It noted that
alloc_misplaced_dst_page() was one such user after changes made by commit
e97ca8e5b864 ("mm: fix GFP_THISNODE callers and clarify"). Unfortunately
when GFP_THISNODE was removed, users of alloc_misplaced_dst_page() started
waking kswapd and entering direct reclaim because the wrong GFP flags are
cleared. The consequence is that workloads that used to fit into memory
now get reclaimed which is addressed by this patch.

The problem can be demonstrated with "mutilate" that exercises memcached
which is software dedicated to memory object caching. The configuration
uses 80% of memory and is run 3 times for varying numbers of clients. The
results on a 4-socket NUMA box are

mutilate
                            4.4.0                 4.4.0
                          vanilla           numaswap-v1
Hmean    1      8394.71 (  0.00%)     8395.32 (  0.01%)
Hmean    4     30024.62 (  0.00%)    34513.54 ( 14.95%)
Hmean    7     32821.08 (  0.00%)    70542.96 (114.93%)
Hmean    12    55229.67 (  0.00%)    93866.34 ( 69.96%)
Hmean    21    39438.96 (  0.00%)    85749.21 (117.42%)
Hmean    30    37796.10 (  0.00%)    50231.49 ( 32.90%)
Hmean    47    18070.91 (  0.00%)    38530.13 (113.22%)

The metric is queries/second with the more the better. The results are way
outside of the noise and the reason for the improvement is obvious from
some of the vmstats

                                 4.4.0       4.4.0
                               vanillanumaswap-v1r1
Minor Faults                1929399272  2146148218
Major Faults                  19746529        3567
Swap Ins                      57307366        9913
Swap Outs                     50623229       17094
Allocation stalls                35909         443
DMA allocs                           0           0
DMA32 allocs                  72976349   170567396
Normal allocs               5306640898  5310651252
Movable allocs                       0           0
Direct pages scanned         404130893      799577
Kswapd pages scanned         160230174           0
Kswapd pages reclaimed        55928786           0
Direct pages reclaimed         1843936       41921
Page writes file                  2391           0
Page writes anon              50623229       17094

The vanilla kernel is swapping like crazy with large amounts of
direct reclaim and kswapd activity. The figures are aggregate but it's
known that the bad activity is throughout the entire test.

Note that simple streaming anon/file memory consumers also see this problem
but it's not as obvious. In those cases, kswapd is awake when it should
not be.

As there are at least two reclaim-related bugs out there, it's worth spelling
out the user-visible impact. This patch only addresses bugs related to
excessive reclaim on NUMA hardware when the working set is larger than a NUMA
node. There is a bug related to high kswapd CPU usage but the reports are
against laptops and other UMA hardware and is not addressed by this patch.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Cc: stable@vger.kernel.org # v4.1+
---
 mm/migrate.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 7890d0bb5e23..6d17e0ab42d4 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1578,7 +1578,7 @@ static struct page *alloc_misplaced_dst_page(struct page *page,
 					 (GFP_HIGHUSER_MOVABLE |
 					  __GFP_THISNODE | __GFP_NOMEMALLOC |
 					  __GFP_NORETRY | __GFP_NOWARN) &
-					 ~(__GFP_IO | __GFP_FS), 0);
+					 ~__GFP_RECLAIM, 0);
 
 	return newpage;
 }
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
