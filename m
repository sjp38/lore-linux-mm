Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A17B7800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 21:30:34 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id q8so1737090pfh.12
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 18:30:34 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id r10si1416393pgd.329.2018.01.23.18.30.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jan 2018 18:30:33 -0800 (PST)
From: Aaron Lu <aaron.lu@intel.com>
Subject: [PATCH 2/2] free_pcppages_bulk: prefetch buddy while not holding lock
Date: Wed, 24 Jan 2018 10:30:50 +0800
Message-Id: <20180124023050.20097-2-aaron.lu@intel.com>
In-Reply-To: <20180124023050.20097-1-aaron.lu@intel.com>
References: <20180124023050.20097-1-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>

When a page is freed back to the global pool, its buddy will be checked
to see if it's possible to do a merge. This requires accessing buddy's
page structure and that access could take a long time if it's cache cold.

This patch adds a prefetch to the to-be-freed page's buddy outside of
zone->lock in hope of accessing buddy's page structure later under
zone->lock will be faster.

Test with will-it-scale/page_fault1 full load:

kernel      Broadwell(2S)  Skylake(2S)   Broadwell(4S)  Skylake(4S)
v4.15-rc4   9037332        8000124       13642741       15728686
patch1/2    9608786 +6.3%  8368915 +4.6% 14042169 +2.9% 17433559 +10.8%
this patch 10462292 +8.9%  8602889 +2.8% 14802073 +5.4% 17624575 +1.1%

Note: this patch's performance improvement percent is against patch1/2.

Suggested-by: Ying Huang <ying.huang@intel.com>
Signed-off-by: Aaron Lu <aaron.lu@intel.com>
---
 mm/page_alloc.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a076f754dac1..9ef084d41708 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1140,6 +1140,9 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			batch_free = count;
 
 		do {
+			unsigned long pfn, buddy_pfn;
+			struct page *buddy;
+
 			page = list_last_entry(list, struct page, lru);
 			/* must delete as __free_one_page list manipulates */
 			list_del(&page->lru);
@@ -1148,6 +1151,16 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 				continue;
 
 			list_add_tail(&page->lru, &head);
+
+			/*
+			 * We are going to put the page back to
+			 * the global pool, prefetch its buddy to
+			 * speed up later access under zone->lock.
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
