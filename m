Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6F31D6B0008
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 08:52:56 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id l1so5626031pga.1
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 05:52:56 -0800 (PST)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id n4si5394527pgn.235.2018.02.26.05.52.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 05:52:55 -0800 (PST)
From: Aaron Lu <aaron.lu@intel.com>
Subject: [PATCH v3 3/3] mm/free_pcppages_bulk: prefetch buddy while not holding lock
Date: Mon, 26 Feb 2018 21:53:46 +0800
Message-Id: <20180226135346.7208-4-aaron.lu@intel.com>
In-Reply-To: <20180226135346.7208-1-aaron.lu@intel.com>
References: <20180226135346.7208-1-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>

When a page is freed back to the global pool, its buddy will be checked
to see if it's possible to do a merge. This requires accessing buddy's
page structure and that access could take a long time if it's cache cold.

This patch adds a prefetch to the to-be-freed page's buddy outside of
zone->lock in hope of accessing buddy's page structure later under
zone->lock will be faster. Since we *always* do buddy merging and check
an order-0 page's buddy to try to merge it when it goes into the main
allocator, the cacheline will always come in, i.e. the prefetched data
will never be unused.

In the meantime, there are two concerns:
1 the prefetch could potentially evict existing cachelines, especially
  for L1D cache since it is not huge;
2 there is some additional instruction overhead, namely calculating
  buddy pfn twice.

For 1, it's hard to say, this microbenchmark though shows good result but
the actual benefit of this patch will be workload/CPU dependant;
For 2, since the calculation is a XOR on two local variables, it's expected
in many cases that cycles spent will be offset by reduced memory latency
later. This is especially true for NUMA machines where multiple CPUs are
contending on zone->lock and the most time consuming part under zone->lock
is the wait of 'struct page' cacheline of the to-be-freed pages and their
buddies.

Test with will-it-scale/page_fault1 full load:

kernel      Broadwell(2S)  Skylake(2S)   Broadwell(4S)  Skylake(4S)
v4.16-rc2+  9034215        7971818       13667135       15677465
patch2/3    9536374 +5.6%  8314710 +4.3% 14070408 +3.0% 16675866 +6.4%
this patch 10338868 +8.4%  8544477 +2.8% 14839808 +5.5% 17155464 +2.9%
Note: this patch's performance improvement percent is against patch2/3.

[changelog stole from Dave Hansen and Mel Gorman's comments]
https://lkml.org/lkml/2018/1/24/551
Suggested-by: Ying Huang <ying.huang@intel.com>
Signed-off-by: Aaron Lu <aaron.lu@intel.com>
---
 mm/page_alloc.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 35576da0a6c9..dc3b89894f2c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1142,6 +1142,9 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			batch_free = count;
 
 		do {
+			unsigned long pfn, buddy_pfn;
+			struct page *buddy;
+
 			page = list_last_entry(list, struct page, lru);
 			/* must delete as __free_one_page list manipulates */
 			list_del(&page->lru);
@@ -1150,6 +1153,18 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 				continue;
 
 			list_add_tail(&page->lru, &head);
+
+			/*
+			 * We are going to put the page back to the global
+			 * pool, prefetch its buddy to speed up later access
+			 * under zone->lock. It is believed the overhead of
+			 * calculating buddy_pfn here can be offset by reduced
+			 * memory latency later.
+			 */
+			pfn = page_to_pfn(page);
+			buddy_pfn = __find_buddy_pfn(pfn, 0);
+			buddy = page + (buddy_pfn - pfn);
+			prefetch(buddy);
 		} while (--count && --batch_free && !list_empty(list));
 	}
 
-- 
2.14.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
