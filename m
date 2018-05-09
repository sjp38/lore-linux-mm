Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 216AA6B04C3
	for <linux-mm@kvack.org>; Wed,  9 May 2018 04:53:39 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id n2-v6so19485715pgs.2
        for <linux-mm@kvack.org>; Wed, 09 May 2018 01:53:39 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id x1-v6si25257590plv.520.2018.05.09.01.53.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 May 2018 01:53:38 -0700 (PDT)
From: Aaron Lu <aaron.lu@intel.com>
Subject: [RFC v3 PATCH 5/5] mm/can_skip_merge(): make it more aggressive to attempt cluster alloc/free
Date: Wed,  9 May 2018 16:54:50 +0800
Message-Id: <20180509085450.3524-6-aaron.lu@intel.com>
In-Reply-To: <20180509085450.3524-1-aaron.lu@intel.com>
References: <20180509085450.3524-1-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>, Tariq Toukan <tariqt@mellanox.com>

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
index e3f209f8fb39..521aa4d8f3c1 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -552,10 +552,6 @@ void try_to_merge_page(struct page *page);
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
2.14.3
