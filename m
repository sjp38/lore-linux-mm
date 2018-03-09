Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 91BF06B0007
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 03:23:40 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id g66so1303432pfj.11
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 00:23:40 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id v10-v6si469971plz.427.2018.03.09.00.23.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Mar 2018 00:23:39 -0800 (PST)
Date: Fri, 9 Mar 2018 16:24:31 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: [PATCH v4 3/3 update] mm/free_pcppages_bulk: prefetch buddy while
 not holding lock
Message-ID: <20180309082431.GB30868@intel.com>
References: <20180301062845.26038-1-aaron.lu@intel.com>
 <20180301062845.26038-4-aaron.lu@intel.com>
 <20180301160950.b561d6b8b561217bad511229@linux-foundation.org>
 <20180302082756.GC6356@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180302082756.GC6356@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, David Rientjes <rientjes@google.com>

On Fri, Mar 02, 2018 at 04:27:56PM +0800, Aaron Lu wrote:
> With this said, the count here could be pcp->count when pcp's pages
> need to be all drained and though pcp->count's default value is
> (6*pcp->batch)=186, user can increase that value through the above
> mentioned procfs interface and the resulting pcp->count could be too
> big for prefetch. Ying also mentioned this today and suggested adding
> an upper limit here to avoid prefetching too much. Perhaps just prefetch
> the last pcp->batch pages if count here > pcp->batch? Since pcp->batch
> has an upper limit, we won't need to worry prefetching too much.

The following patch adds an upper limit on prefetching, the upper limit
is set to pcp->batch since 1) it is the most likely value of input param
'count' in free_pcppages_bulk() and 2) it has an upper limit itself.

From: Aaron Lu <aaron.lu@intel.com>
Subject: [PATCH v4 3/3 update] mm/free_pcppages_bulk: prefetch buddy while not holding lock

When a page is freed back to the global pool, its buddy will be checked
to see if it's possible to do a merge. This requires accessing buddy's
page structure and that access could take a long time if it's cache cold.

This patch adds a prefetch to the to-be-freed page's buddy outside of
zone->lock in hope of accessing buddy's page structure later under
zone->lock will be faster. Since we *always* do buddy merging and check
an order-0 page's buddy to try to merge it when it goes into the main
allocator, the cacheline will always come in, i.e. the prefetched data
will never be unused.

Normally, the number of to-be-freed pages(i.e. count) equals to
pcp->batch (default=31 and has an upper limit of (PAGE_SHIFT * 8)=96 on
x86_64) but in the case of pcp's pages getting all drained, it will be
pcp->count which has an upper limit of pcp->high. pcp->high, although
has a default value of 186 (pcp->batch=31 * 6), can be changed by user
through /proc/sys/vm/percpu_pagelist_fraction and there is no software
upper limit so could be large, like several thousand. For this reason,
only the last pcp->batch number of page's buddy structure is prefetched
to avoid excessive prefetching. pcp-batch is used because:
1 most often, count == pcp->batch;
2 it has an upper limit itself so we won't prefetch excessively.

Considering the possible large value of pcp->high, it also makes
sense to free the last added page first for cache hot's reason.
That's where the change of list_add_tail() to list_add() comes in
as we will free them from head to tail one by one.

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
this patch 10180856 +6.8%  8506369 +2.3% 14756865 +4.9% 17325324 +3.9%
Note: this patch's performance improvement percent is against patch2/3.

(Changelog stolen from Dave Hansen and Mel Gorman's comments at
http://lkml.kernel.org/r/148a42d8-8306-2f2f-7f7c-86bc118f8ccd@intel.com)

Link: http://lkml.kernel.org/r/20180301062845.26038-4-aaron.lu@intel.com
Signed-off-by: Aaron Lu <aaron.lu@intel.com>
Suggested-by: Ying Huang <ying.huang@intel.com>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
---
 mm/page_alloc.c | 21 ++++++++++++++++++++-
 1 file changed, 20 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index dafdcdec9c1f..5f31f7bab583 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1141,6 +1141,9 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			batch_free = count;
 
 		do {
+			unsigned long pfn, buddy_pfn;
+			struct page *buddy;
+
 			page = list_last_entry(list, struct page, lru);
 			/* must delete to avoid corrupting pcp list */
 			list_del(&page->lru);
@@ -1149,7 +1152,23 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			if (bulkfree_pcp_prepare(page))
 				continue;
 
-			list_add_tail(&page->lru, &head);
+			list_add(&page->lru, &head);
+
+			/*
+			 * We are going to put the page back to the global
+			 * pool, prefetch its buddy to speed up later access
+			 * under zone->lock. It is believed the overhead of
+			 * an additional test and calculating buddy_pfn here
+			 * can be offset by reduced memory latency later. To
+			 * avoid excessive prefetching due to large count, only
+			 * prefetch buddy for the last pcp->batch nr of pages.
+			 */
+			if (count > pcp->batch)
+				continue;
+			pfn = page_to_pfn(page);
+			buddy_pfn = __find_buddy_pfn(pfn, 0);
+			buddy = page + (buddy_pfn - pfn);
+			prefetch(buddy);
 		} while (--count && --batch_free && !list_empty(list));
 	}
 
-- 
2.14.3
