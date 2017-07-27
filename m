Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A41E36B04B6
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 12:07:14 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id m80so8664543wmd.4
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 09:07:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x73si11454163wma.0.2017.07.27.09.07.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Jul 2017 09:07:13 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 3/6] mm, kswapd: reset kswapd's order to 0 when it fails to reclaim enough
Date: Thu, 27 Jul 2017 18:06:58 +0200
Message-Id: <20170727160701.9245-4-vbabka@suse.cz>
In-Reply-To: <20170727160701.9245-1-vbabka@suse.cz>
References: <20170727160701.9245-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

For high-order allocations, kswapd will either manage to create the free page
by reclaim itself, or reclaim just enough to let compaction proceed, set its
order to 0 (so that watermark checks don't look for high-order pages anymore)
and goes to sleep while waking up kcompactd.

This doesn't work as expected in case when kswapd cannot reclaim compact_gap()
worth of pages (nor balance the node by itself) even at highest priority. Then
it won't go to sleep and wake up kcompactd. This patch fixes this corner case
by setting sc.order to 0 in such case.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/vmscan.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index ae897a85e7f3..a3f914c88dea 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3340,6 +3340,14 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 	if (!sc.nr_reclaimed)
 		pgdat->kswapd_failures++;
 
+	/*
+	 * Even at highest priority, we could not reclaim enough to balance
+	 * the zone or reclaim over compact_gap() (see kswapd_shrink_node())
+	 * so we better give up now and wake up kcompactd instead.
+	 */
+	if (sc.order > 0 && sc.priority == 0)
+		sc.order = 0;
+
 out:
 	snapshot_refaults(NULL, pgdat);
 	/*
-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
