Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3528B800D8
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 02:25:43 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 82so5258542pfs.8
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 23:25:43 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id s1si1204868pgc.791.2018.01.24.23.25.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jan 2018 23:25:41 -0800 (PST)
Date: Thu, 25 Jan 2018 15:25:55 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: [PATCH v2 2/2] free_pcppages_bulk: prefetch buddy while not holding
 lock
Message-ID: <20180125072555.GB27678@intel.com>
References: <20180124023050.20097-1-aaron.lu@intel.com>
 <20180124023050.20097-2-aaron.lu@intel.com>
 <20180124164344.lca63gjn7mefuiac@techsingularity.net>
 <148a42d8-8306-2f2f-7f7c-86bc118f8ccd@intel.com>
 <20180124181921.vnivr32q72ey7p5i@techsingularity.net>
 <525a20be-dea9-ed54-ca8e-8c4bc5e8a04f@intel.com>
 <20180124211228.3k7tuuji7a7mvyh2@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180124211228.3k7tuuji7a7mvyh2@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>

When a page is freed back to the global pool, its buddy will be checked
to see if it's possible to do a merge. This requires accessing buddy's
page structure and that access could take a long time if it's cache cold.

This patch adds a prefetch to the to-be-freed page's buddy outside of
zone->lock in hope of accessing buddy's page structure later under
zone->lock will be faster. Since we *always* do buddy merging and check
an order-0 page's buddy to try to merge it when it goes into the main
allocator, the cacheline will always come in, i.e. the prefetched data
will never be unused.

In the meantime, there is the concern of a prefetch potentially evicting
existing cachelines. This can be true for L1D cache since it is not huge.
Considering the prefetch instruction used is prefetchnta, which will only
store the date in L2 for "Pentium 4 and Intel Xeon processors" according
to Intel's "Instruction Manual Set" document, it is not likely to cause
cache pollution. Other architectures may have this cache pollution problem
though.

There is also some additional instruction overhead, namely calculating
buddy pfn twice. Since the calculation is a XOR on two local variables,
it's expected in many cases that cycles spent will be offset by reduced
memory latency later. This is especially true for NUMA machines where multiple
CPUs are contending on zone->lock and the most time consuming part under
zone->lock is the wait of 'struct page' cacheline of the to-be-freed pages
and their buddies.

Test with will-it-scale/page_fault1 full load:

kernel      Broadwell(2S)  Skylake(2S)   Broadwell(4S)  Skylake(4S)
v4.15-rc4   9037332        8000124       13642741       15728686
patch1/2    9608786 +6.3%  8368915 +4.6% 14042169 +2.9% 17433559 +10.8%
this patch 10462292 +8.9%  8602889 +2.8% 14802073 +5.4% 17624575 +1.1%

Note: this patch's performance improvement percent is against patch1/2.

Please also note the actual benefit of this patch will be workload/CPU
dependant.

[changelog stole from Dave Hansen and Mel Gorman's comments]
https://lkml.org/lkml/2018/1/24/551
Suggested-by: Ying Huang <ying.huang@intel.com>
Signed-off-by: Aaron Lu <aaron.lu@intel.com>
---
v2:
update changelog according to Dave Hansen and Mel Gorman's comments.
Add more comments in code to explain why prefetch is done as requested
by Mel Gorman.

 mm/page_alloc.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c9e5ded39b16..6566a4b5b124 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1138,6 +1138,9 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			batch_free = count;
 
 		do {
+			unsigned long pfn, buddy_pfn;
+			struct page *buddy;
+
 			page = list_last_entry(list, struct page, lru);
 			/* must delete as __free_one_page list manipulates */
 			list_del(&page->lru);
@@ -1146,6 +1149,18 @@ static void free_pcppages_bulk(struct zone *zone, int count,
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
