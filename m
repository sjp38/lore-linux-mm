Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id AE2C96B000E
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 02:33:49 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id g63-v6so9960796pfc.9
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 23:33:49 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id v202-v6si1081311pgb.96.2018.10.16.23.33.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Oct 2018 23:33:48 -0700 (PDT)
From: Aaron Lu <aaron.lu@intel.com>
Subject: [RFC v4 PATCH 5/5] mm/can_skip_merge(): make it more aggressive to attempt cluster alloc/free
Date: Wed, 17 Oct 2018 14:33:30 +0800
Message-Id: <20181017063330.15384-6-aaron.lu@intel.com>
In-Reply-To: <20181017063330.15384-1-aaron.lu@intel.com>
References: <20181017063330.15384-1-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>, Tariq Toukan <tariqt@mellanox.com>, Jesper Dangaard Brouer <brouer@redhat.com>

After system runs a long time, it's easy for a zone to have no
suitable high order page available and that will stop cluster alloc
and free in current implementation due to compact_considered > 0.

To make it favour order0 alloc/free, relax the condition to only
disallow cluster alloc/free when problem would occur, e.g. when
compaction is in progress.

Signed-off-by: Aaron Lu <aaron.lu@intel.com>
---
 mm/internal.h | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index fb4e8f7976e5..309a3f43e613 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -538,10 +538,6 @@ void try_to_merge_page(struct page *page);
 #ifdef CONFIG_COMPACTION
 static inline bool can_skip_merge(struct zone *zone, int order)
 {
-	/* Compaction has failed in this zone, we shouldn't skip merging */
-	if (zone->compact_considered)
-		return false;
-
 	/* Only consider no_merge for order 0 pages */
 	if (order)
 		return false;
-- 
2.17.2
