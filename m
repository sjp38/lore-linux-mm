Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 112CB6B0262
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 05:00:03 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id d19so63785765lfb.0
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 02:00:03 -0700 (PDT)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.16])
        by mx.google.com with ESMTPS id y15si10915296wmd.12.2016.04.15.02.00.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 02:00:01 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id 74A621C198A
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 10:00:01 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 03/28] mm, page_alloc: Reduce branches in zone_statistics
Date: Fri, 15 Apr 2016 09:58:55 +0100
Message-Id: <1460710760-32601-4-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

zone_statistics has more branches than it really needs to take an
unlikely GFP flag into account. Reduce the number and annotate
the unlikely flag.

The performance difference on a page allocator microbenchmark is;

                                           4.6.0-rc2                  4.6.0-rc2
                                    nocompound-v1r10           statbranch-v1r10
Min      alloc-odr0-1               417.00 (  0.00%)           419.00 ( -0.48%)
Min      alloc-odr0-2               308.00 (  0.00%)           305.00 (  0.97%)
Min      alloc-odr0-4               253.00 (  0.00%)           250.00 (  1.19%)
Min      alloc-odr0-8               221.00 (  0.00%)           219.00 (  0.90%)
Min      alloc-odr0-16              205.00 (  0.00%)           203.00 (  0.98%)
Min      alloc-odr0-32              199.00 (  0.00%)           195.00 (  2.01%)
Min      alloc-odr0-64              193.00 (  0.00%)           191.00 (  1.04%)
Min      alloc-odr0-128             191.00 (  0.00%)           189.00 (  1.05%)
Min      alloc-odr0-256             200.00 (  0.00%)           198.00 (  1.00%)
Min      alloc-odr0-512             212.00 (  0.00%)           210.00 (  0.94%)
Min      alloc-odr0-1024            219.00 (  0.00%)           216.00 (  1.37%)
Min      alloc-odr0-2048            225.00 (  0.00%)           221.00 (  1.78%)
Min      alloc-odr0-4096            231.00 (  0.00%)           227.00 (  1.73%)
Min      alloc-odr0-8192            234.00 (  0.00%)           232.00 (  0.85%)
Min      alloc-odr0-16384           234.00 (  0.00%)           232.00 (  0.85%)

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/vmstat.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 5e4300482897..2e58ead9bcf5 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -581,17 +581,21 @@ void drain_zonestat(struct zone *zone, struct per_cpu_pageset *pset)
  */
 void zone_statistics(struct zone *preferred_zone, struct zone *z, gfp_t flags)
 {
-	if (z->zone_pgdat == preferred_zone->zone_pgdat) {
+	int local_nid = numa_node_id();
+	enum zone_stat_item local_stat = NUMA_LOCAL;
+
+	if (unlikely(flags & __GFP_OTHER_NODE)) {
+		local_stat = NUMA_OTHER;
+		local_nid = preferred_zone->node;
+	}
+
+	if (z->node == local_nid) {
 		__inc_zone_state(z, NUMA_HIT);
+		__inc_zone_state(z, local_stat);
 	} else {
 		__inc_zone_state(z, NUMA_MISS);
 		__inc_zone_state(preferred_zone, NUMA_FOREIGN);
 	}
-	if (z->node == ((flags & __GFP_OTHER_NODE) ?
-			preferred_zone->node : numa_node_id()))
-		__inc_zone_state(z, NUMA_LOCAL);
-	else
-		__inc_zone_state(z, NUMA_OTHER);
 }
 
 /*
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
