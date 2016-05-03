Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CA2406B025E
	for <linux-mm@kvack.org>; Tue,  3 May 2016 17:01:40 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 77so63127497pfz.3
        for <linux-mm@kvack.org>; Tue, 03 May 2016 14:01:40 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id l27si364670pfj.18.2016.05.03.14.01.39
        for <linux-mm@kvack.org>;
        Tue, 03 May 2016 14:01:39 -0700 (PDT)
Message-ID: <1462309298.21143.9.camel@linux.intel.com>
Subject: [PATCH 2/7] mm: Group the processing of anonymous pages to be
 swapped in shrink_page_list
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Tue, 03 May 2016 14:01:38 -0700
In-Reply-To: <cover.1462306228.git.tim.c.chen@linux.intel.com>
References: <cover.1462306228.git.tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>
Cc: "Kirill A.Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <andi@firstfloor.org>, Aaron Lu <aaron.lu@intel.com>, Huang Ying <ying.huang@intel.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

This is a clean up patch to reorganize the processing of anonymous
pages in shrink_page_list.

We delay the processing of swapping anonymous pages in shrink_page_list
and put them together on a separate list.A A This prepares for batching
of pages to be swapped.A A The processing of the list of anonymous pages
to be swapped is consolidated in the function shrink_anon_page_list.

Functionally, there is no change in the logic of how pages are processed,
just the order of processing of the anonymous pages and file mapped
pages in shrink_page_list.

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
A mm/vmscan.c | 82 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++----
A 1 file changed, 77 insertions(+), 5 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5542005..132ba02 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1083,6 +1083,58 @@ static void pg_finish(struct page *page,
A 	}
A }
A 
+static unsigned long shrink_anon_page_list(struct list_head *page_list,
+	struct zone *zone,
+	struct scan_control *sc,
+	struct list_head *swap_pages,
+	struct list_head *ret_pages,
+	struct list_head *free_pages,
+	enum ttu_flags ttu_flags,
+	int *pgactivate,
+	int n,
+	bool clean)
+{
+	unsigned long nr_reclaimed = 0;
+	enum pg_result pg_dispose;
+
+	while (n > 0) {
+		struct page *page;
+		int swap_ret = SWAP_SUCCESS;
+
+		--n;
+		if (list_empty(swap_pages))
+		A A A A A A A return nr_reclaimed;
+
+		page = lru_to_page(swap_pages);
+
+		list_del(&page->lru);
+
+		/*
+		* Anonymous process memory has backing store?
+		* Try to allocate it some swap space here.
+		*/
+
+		if (!add_to_swap(page, page_list)) {
+			pg_finish(page, PG_ACTIVATE_LOCKED, swap_ret, &nr_reclaimed,
+					pgactivate, ret_pages, free_pages);
+			continue;
+		}
+
+		if (clean)
+			pg_dispose = handle_pgout(page_list, zone, sc, ttu_flags,
+				PAGEREF_RECLAIM_CLEAN, true, true, &swap_ret, page);
+		else
+			pg_dispose = handle_pgout(page_list, zone, sc, ttu_flags,
+				PAGEREF_RECLAIM, true, true, &swap_ret, page);
+
+		pg_finish(page, pg_dispose, swap_ret, &nr_reclaimed,
+				pgactivate, ret_pages, free_pages);
+	}
+	return nr_reclaimed;
+}
+
+
+
A /*
A  * shrink_page_list() returns the number of reclaimed pages
A  */
@@ -1099,6 +1151,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
A {
A 	LIST_HEAD(ret_pages);
A 	LIST_HEAD(free_pages);
+	LIST_HEAD(swap_pages);
+	LIST_HEAD(swap_pages_clean);
A 	int pgactivate = 0;
A 	unsigned long nr_unqueued_dirty = 0;
A 	unsigned long nr_dirty = 0;
@@ -1106,6 +1160,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
A 	unsigned long nr_reclaimed = 0;
A 	unsigned long nr_writeback = 0;
A 	unsigned long nr_immediate = 0;
+	unsigned long nr_swap = 0;
+	unsigned long nr_swap_clean = 0;
A 
A 	cond_resched();
A 
@@ -1271,12 +1327,17 @@ static unsigned long shrink_page_list(struct list_head *page_list,
A 				pg_dispose = PG_KEEP_LOCKED;
A 				goto finish;
A 			}
-			if (!add_to_swap(page, page_list)) {
-				pg_dispose = PG_ACTIVATE_LOCKED;
-				goto finish;
+			if (references == PAGEREF_RECLAIM_CLEAN) {
+				list_add(&page->lru, &swap_pages_clean);
+				++nr_swap_clean;
+			} else {
+				list_add(&page->lru, &swap_pages);
+				++nr_swap;
A 			}
-			lazyfree = true;
-			may_enter_fs = 1;
+
+			pg_dispose = PG_NEXT;
+			goto finish;
+
A 		}
A 
A 		pg_dispose = handle_pgout(page_list, zone, sc, ttu_flags,
@@ -1288,6 +1349,17 @@ finish:
A 
A 	}
A 
+	nr_reclaimed += shrink_anon_page_list(page_list, zone, sc,
+						&swap_pages_clean, &ret_pages,
+						&free_pages, ttu_flags,
+						&pgactivate, nr_swap_clean,
+						true);
+	nr_reclaimed += shrink_anon_page_list(page_list, zone, sc,
+						&swap_pages, &ret_pages,
+						&free_pages, ttu_flags,
+						&pgactivate, nr_swap,
+						false);
+
A 	mem_cgroup_uncharge_list(&free_pages);
A 	try_to_unmap_flush();
A 	free_hot_cold_page_list(&free_pages, true);
--A 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
