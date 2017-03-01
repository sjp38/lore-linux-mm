Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2992F6B0038
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 09:39:58 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id w189so13876479pfb.4
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 06:39:58 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 9si4767671pgp.58.2017.03.01.06.39.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Mar 2017 06:39:57 -0800 (PST)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH] mm, swap: Fix a race in free_swap_and_cache()
Date: Wed,  1 Mar 2017 22:38:09 +0800
Message-Id: <20170301143905.12846-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Tim Chen <tim.c.chen@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Huang Ying <ying.huang@intel.com>

Before using cluster lock in free_swap_and_cache(), the
swap_info_struct->lock will be held during freeing the swap entry and
acquiring page lock, so the page swap count will not change when
testing page information later.  But after using cluster lock, the
cluster lock (or swap_info_struct->lock) will be held only during
freeing the swap entry.  So before acquiring the page lock, the page
swap count may be changed in another thread.  If the page swap count
is not 0, we should not delete the page from the swap cache.  This is
fixed via checking page swap count again after acquiring the page
lock.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Tim Chen <tim.c.chen@intel.com>
---
 mm/swapfile.c | 25 ++++++++++++++++---------
 1 file changed, 16 insertions(+), 9 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index fadc6a1c0da0..5b67f8ce424c 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1109,6 +1109,18 @@ int page_swapcount(struct page *page)
 	return count;
 }
 
+static int swap_swapcount(struct swap_info_struct *si, swp_entry_t entry)
+{
+	int count = 0;
+	pgoff_t offset = swp_offset(entry);
+	struct swap_cluster_info *ci;
+
+	ci = lock_cluster_or_swap_info(si, offset);
+	count = swap_count(si->swap_map[offset]);
+	unlock_cluster_or_swap_info(si, ci);
+	return count;
+}
+
 /*
  * How many references to @entry are currently swapped out?
  * This does not give an exact answer when swap count is continued,
@@ -1117,17 +1129,11 @@ int page_swapcount(struct page *page)
 int __swp_swapcount(swp_entry_t entry)
 {
 	int count = 0;
-	pgoff_t offset;
 	struct swap_info_struct *si;
-	struct swap_cluster_info *ci;
 
 	si = __swap_info_get(entry);
-	if (si) {
-		offset = swp_offset(entry);
-		ci = lock_cluster_or_swap_info(si, offset);
-		count = swap_count(si->swap_map[offset]);
-		unlock_cluster_or_swap_info(si, ci);
-	}
+	if (si)
+		count = swap_swapcount(si, entry);
 	return count;
 }
 
@@ -1289,7 +1295,8 @@ int free_swap_and_cache(swp_entry_t entry)
 		 * Also recheck PageSwapCache now page is locked (above).
 		 */
 		if (PageSwapCache(page) && !PageWriteback(page) &&
-		    (!page_mapped(page) || mem_cgroup_swap_full(page))) {
+		    (!page_mapped(page) || mem_cgroup_swap_full(page)) &&
+		    !swap_swapcount(p, entry)) {
 			delete_from_swap_cache(page);
 			SetPageDirty(page);
 		}
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
