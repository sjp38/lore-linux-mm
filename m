Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 801366B0038
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 13:50:47 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id r54so2181866qtr.1
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 10:50:47 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id e87si2438294iod.84.2017.02.22.10.50.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Feb 2017 10:50:46 -0800 (PST)
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.20/8.16.0.20) with SMTP id v1MIiHnv013873
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 10:50:45 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0089730.ppops.net with ESMTP id 28sfwtr2qe-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 10:50:45 -0800
Received: from facebook.com (2401:db00:21:603d:face:0:19:0)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 d0cf513ef92f11e694520002c99331b0-d61faa00 for <linux-mm@kvack.org>;	Wed, 22
 Feb 2017 10:50:44 -0800
From: Shaohua Li <shli@fb.com>
Subject: [PATCH V4 1/6] mm: delete unnecessary TTU_* flags
Date: Wed, 22 Feb 2017 10:50:39 -0800
Message-ID: <6e99fbb58c019dac280dde73a96586c0eba880d0.1487788131.git.shli@fb.com>
In-Reply-To: <cover.1487788131.git.shli@fb.com>
References: <cover.1487788131.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kernel-team@fb.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

Johannes pointed out TTU_LZFREE is unnecessary. It's true because we
always have the flag set if we want to do an unmap. For cases we don't
do an unmap, the TTU_LZFREE part of code should never run.

Also the TTU_UNMAP is unnecessary. If no other flags set (for
example, TTU_MIGRATION), an unmap is implied.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Shaohua Li <shli@fb.com>
---
 include/linux/rmap.h |  2 --
 mm/memory-failure.c  |  2 +-
 mm/rmap.c            |  2 +-
 mm/vmscan.c          | 11 ++++-------
 4 files changed, 6 insertions(+), 11 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 8c89e90..e2cd8f9 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -83,10 +83,8 @@ struct anon_vma_chain {
 };
 
 enum ttu_flags {
-	TTU_UNMAP = 1,			/* unmap mode */
 	TTU_MIGRATION = 2,		/* migration mode */
 	TTU_MUNLOCK = 4,		/* munlock mode */
-	TTU_LZFREE = 8,			/* lazy free mode */
 	TTU_SPLIT_HUGE_PMD = 16,	/* split huge PMD if any */
 
 	TTU_IGNORE_MLOCK = (1 << 8),	/* ignore mlock */
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 3d0f2fd..b78d080 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -906,7 +906,7 @@ EXPORT_SYMBOL_GPL(get_hwpoison_page);
 static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
 				  int trapno, int flags, struct page **hpagep)
 {
-	enum ttu_flags ttu = TTU_UNMAP | TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS;
+	enum ttu_flags ttu = TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS;
 	struct address_space *mapping;
 	LIST_HEAD(tokill);
 	int ret;
diff --git a/mm/rmap.c b/mm/rmap.c
index 8774791..96eb85c 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1418,7 +1418,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			 */
 			VM_BUG_ON_PAGE(!PageSwapCache(page), page);
 
-			if (!PageDirty(page) && (flags & TTU_LZFREE)) {
+			if (!PageDirty(page)) {
 				/* It's a freeable page by MADV_FREE */
 				dec_mm_counter(mm, MM_ANONPAGES);
 				rp->lazyfreed++;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 26c3b40..68ea50d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -971,7 +971,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		int may_enter_fs;
 		enum page_references references = PAGEREF_RECLAIM_CLEAN;
 		bool dirty, writeback;
-		bool lazyfree = false;
 		int ret = SWAP_SUCCESS;
 
 		cond_resched();
@@ -1125,7 +1124,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				goto keep_locked;
 			if (!add_to_swap(page, page_list))
 				goto activate_locked;
-			lazyfree = true;
 			may_enter_fs = 1;
 
 			/* Adding to swap updated mapping */
@@ -1143,9 +1141,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 * processes. Try to unmap it here.
 		 */
 		if (page_mapped(page) && mapping) {
-			switch (ret = try_to_unmap(page, lazyfree ?
-				(ttu_flags | TTU_BATCH_FLUSH | TTU_LZFREE) :
-				(ttu_flags | TTU_BATCH_FLUSH))) {
+			switch (ret = try_to_unmap(page,
+				ttu_flags | TTU_BATCH_FLUSH)) {
 			case SWAP_FAIL:
 				nr_unmap_fail++;
 				goto activate_locked;
@@ -1353,7 +1350,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 	}
 
 	ret = shrink_page_list(&clean_pages, zone->zone_pgdat, &sc,
-			TTU_UNMAP|TTU_IGNORE_ACCESS, NULL, true);
+			TTU_IGNORE_ACCESS, NULL, true);
 	list_splice(&clean_pages, page_list);
 	mod_node_page_state(zone->zone_pgdat, NR_ISOLATED_FILE, -ret);
 	return ret;
@@ -1760,7 +1757,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	if (nr_taken == 0)
 		return 0;
 
-	nr_reclaimed = shrink_page_list(&page_list, pgdat, sc, TTU_UNMAP,
+	nr_reclaimed = shrink_page_list(&page_list, pgdat, sc, 0,
 				&stat, false);
 
 	spin_lock_irq(&pgdat->lru_lock);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
