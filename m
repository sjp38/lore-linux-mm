Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A98DC6B0263
	for <linux-mm@kvack.org>; Tue,  3 May 2016 17:02:28 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 203so63277309pfy.2
        for <linux-mm@kvack.org>; Tue, 03 May 2016 14:02:28 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id gm2si308209pac.213.2016.05.03.14.02.27
        for <linux-mm@kvack.org>;
        Tue, 03 May 2016 14:02:27 -0700 (PDT)
Message-ID: <1462309346.21143.11.camel@linux.intel.com>
Subject: [PATCH 4/7] mm: Shrink page list batch allocates swap slots for
 page swapping
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Tue, 03 May 2016 14:02:26 -0700
In-Reply-To: <cover.1462306228.git.tim.c.chen@linux.intel.com>
References: <cover.1462306228.git.tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>
Cc: "Kirill A.Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <andi@firstfloor.org>, Aaron Lu <aaron.lu@intel.com>, Huang Ying <ying.huang@intel.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

In shrink page list, we take advantage bulk allocation of swap entries
with the new get_swap_pages function. This reduces contention on a
swap device's swap_info lock. When the memory is low and the system is
actively trying to reclaim memory, both direct reclaim path and kswapd
contends on this lock when they access the same swap partition.

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
A mm/vmscan.c | 63 ++++++++++++++++++++++++++++++++++++++++---------------------
A 1 file changed, 42 insertions(+), 21 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index e36d8a7..310e2b2 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1096,38 +1096,59 @@ static unsigned long shrink_anon_page_list(struct list_head *page_list,
A {
A 	unsigned long nr_reclaimed = 0;
A 	enum pg_result pg_dispose;
+	swp_entry_t swp_entries[SWAP_BATCH];
+	struct page *page;
+	int m, i, k;
A 
A 	while (n > 0) {
-		struct page *page;
A 		int swap_ret = SWAP_SUCCESS;
A 
-		--n;
-		if (list_empty(swap_pages))
-		A A A A A A A return nr_reclaimed;
+		m = get_swap_pages(n, swp_entries);
+		if (!m)
+			goto no_swap_slots;
+		n -= m;
+		for (i = 0; i < m; ++i) {
+			if (list_empty(swap_pages)) {
+				/* free any leftover swap slots */
+				for (k = i; k < m; ++k)
+					swapcache_free(swp_entries[k]);
+				return nr_reclaimed;
+			}
+			page = lru_to_page(swap_pages);
A 
-		page = lru_to_page(swap_pages);
+			list_del(&page->lru);
A 
-		list_del(&page->lru);
+			/*
+			* Anonymous process memory has backing store?
+			* Try to allocate it some swap space here.
+			*/
+
+			if (!add_to_swap(page, page_list, NULL)) {
+				pg_finish(page, PG_ACTIVATE_LOCKED, swap_ret,
+						&nr_reclaimed, pgactivate,
+						ret_pages, free_pages);
+				continue;
+			}
A 
-		/*
-		* Anonymous process memory has backing store?
-		* Try to allocate it some swap space here.
-		*/
+			if (clean)
+				pg_dispose = handle_pgout(page_list, zone, sc,
+						ttu_flags, PAGEREF_RECLAIM_CLEAN,
+						true, true, &swap_ret, page);
+			else
+				pg_dispose = handle_pgout(page_list, zone, sc,
+						ttu_flags, PAGEREF_RECLAIM,
+						true, true, &swap_ret, page);
A 
-		if (!add_to_swap(page, page_list, NULL)) {
-			pg_finish(page, PG_ACTIVATE_LOCKED, swap_ret, &nr_reclaimed,
+			pg_finish(page, pg_dispose, swap_ret, &nr_reclaimed,
A 					pgactivate, ret_pages, free_pages);
-			continue;
A 		}
+	}
+	return nr_reclaimed;
A 
-		if (clean)
-			pg_dispose = handle_pgout(page_list, zone, sc, ttu_flags,
-				PAGEREF_RECLAIM_CLEAN, true, true, &swap_ret, page);
-		else
-			pg_dispose = handle_pgout(page_list, zone, sc, ttu_flags,
-				PAGEREF_RECLAIM, true, true, &swap_ret, page);
-
-		pg_finish(page, pg_dispose, swap_ret, &nr_reclaimed,
+no_swap_slots:
+	while (!list_empty(swap_pages)) {
+		page = lru_to_page(swap_pages);
+		pg_finish(page, PG_ACTIVATE_LOCKED, 0, &nr_reclaimed,
A 				pgactivate, ret_pages, free_pages);
A 	}
A 	return nr_reclaimed;
--A 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
