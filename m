Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 61FAF6B0253
	for <linux-mm@kvack.org>; Thu, 21 Sep 2017 16:49:39 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 11so13525010pge.4
        for <linux-mm@kvack.org>; Thu, 21 Sep 2017 13:49:39 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id z190si1510103pgd.390.2017.09.21.13.49.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Sep 2017 13:49:38 -0700 (PDT)
From: Shaohua Li <shli@kernel.org>
Subject: [PATCH 2/2] mm: fix data corruption caused by lazyfree page
Date: Thu, 21 Sep 2017 13:27:11 -0700
Message-Id: <cb93061c24ba9287767d87e8da6d7249c39908f0.1506024100.git.shli@fb.com>
In-Reply-To: <cover.1506024100.git.shli@fb.com>
References: <cover.1506024100.git.shli@fb.com>
In-Reply-To: <cover.1506024100.git.shli@fb.com>
References: <cover.1506024100.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Artem Savkov <asavkov@redhat.com>, Kernel-team@fb.com, Shaohua Li <shli@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>

From: Shaohua Li <shli@fb.com>

MADV_FREE clears pte dirty bit and then marks the page lazyfree (clear
SwapBacked). There is no lock to prevent the page is added to swap cache
between these two steps by page reclaim. If page reclaim finds such
page, it will simply add the page to swap cache without pageout the page
to swap because the page is marked as clean. Next time, page fault will
read data from the swap slot which doesn't have the original data, so we
have a data corruption. To fix issue, we mark the page dirty and pageout
the page.

However, we shouldn't dirty all pages which is clean and in swap cache.
swapin page is swap cache and clean too. So we only dirty page which is
added into swap cache in page reclaim, which shouldn't be swapin page.
Normal anonymous pages should be dirty already.

Reported-and-tested-y: Artem Savkov <asavkov@redhat.com>
Fix: 802a3a92ad7a(mm: reclaim MADV_FREE pages)
Signed-off-by: Shaohua Li <shli@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/vmscan.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index d811c81..820ee8d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -980,6 +980,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		int may_enter_fs;
 		enum page_references references = PAGEREF_RECLAIM_CLEAN;
 		bool dirty, writeback;
+		bool new_swap_page = false;
 
 		cond_resched();
 
@@ -1165,6 +1166,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 
 				/* Adding to swap updated mapping */
 				mapping = page_mapping(page);
+				new_swap_page = true;
 			}
 		} else if (unlikely(PageTransHuge(page))) {
 			/* Split file THP */
@@ -1185,6 +1187,16 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				nr_unmap_fail++;
 				goto activate_locked;
 			}
+
+			/*
+			 * MADV_FREE clear pte dirty bit, but not yet clear
+			 * SwapBacked for a page. We can't directly free the
+			 * page because we already set swap entry in pte. The
+			 * check guarantees this is such page and not a clean
+			 * swapin page
+			 */
+			if (!PageDirty(page) && new_swap_page)
+				set_page_dirty(page);
 		}
 
 		if (PageDirty(page)) {
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
