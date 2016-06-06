Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 90FC9828E1
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 15:51:25 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id k184so22828197wme.3
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 12:51:25 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id er5si28641923wjd.178.2016.06.06.12.51.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 12:51:24 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 08/10] mm: deactivations shouldn't bias the LRU balance
Date: Mon,  6 Jun 2016 15:48:34 -0400
Message-Id: <20160606194836.3624-9-hannes@cmpxchg.org>
In-Reply-To: <20160606194836.3624-1-hannes@cmpxchg.org>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

Operations like MADV_FREE, FADV_DONTNEED etc. currently move any
affected active pages to the inactive list to accelerate their reclaim
(good) but also steer page reclaim toward that LRU type, or away from
the other (bad).

The reason why this is undesirable is that such operations are not
part of the regular page aging cycle, and rather a fluke that doesn't
say much about the remaining pages on that list. They might all be in
heavy use. But once the chunk of easy victims has been purged, the VM
continues to apply elevated pressure on the remaining hot pages. The
other LRU, meanwhile, might have easily reclaimable pages, and there
was never a need to steer away from it in the first place.

As the previous patch outlined, we should focus on recording actually
observed cost to steer the balance rather than speculating about the
potential value of one LRU list over the other. In that spirit, leave
explicitely deactivated pages to the LRU algorithm to pick up, and let
rotations decide which list is the easiest to reclaim.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/swap.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index 645d21242324..ae07b469ddca 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -538,7 +538,6 @@ static void lru_deactivate_file_fn(struct page *page, struct lruvec *lruvec,
 
 	if (active)
 		__count_vm_event(PGDEACTIVATE);
-	lru_note_cost(lruvec, !file, hpage_nr_pages(page));
 }
 
 
@@ -546,7 +545,6 @@ static void lru_deactivate_fn(struct page *page, struct lruvec *lruvec,
 			    void *arg)
 {
 	if (PageLRU(page) && PageActive(page) && !PageUnevictable(page)) {
-		int file = page_is_file_cache(page);
 		int lru = page_lru_base_type(page);
 
 		del_page_from_lru_list(page, lruvec, lru + LRU_ACTIVE);
@@ -555,7 +553,6 @@ static void lru_deactivate_fn(struct page *page, struct lruvec *lruvec,
 		add_page_to_lru_list(page, lruvec, lru);
 
 		__count_vm_event(PGDEACTIVATE);
-		lru_note_cost(lruvec, !file, hpage_nr_pages(page));
 	}
 }
 
-- 
2.8.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
