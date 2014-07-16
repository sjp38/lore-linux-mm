Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 5B3E26B00BB
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 12:28:14 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id m15so1185465wgh.15
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 09:28:13 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id yu4si24574391wjc.111.2014.07.16.09.28.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 16 Jul 2014 09:28:10 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: memcontrol: rewrite charge API fix - hugetlb charging
Date: Wed, 16 Jul 2014 12:28:00 -0400
Message-Id: <1405528080-2975-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Naoya-san reports that hugetlb pages now get charged as file cache,
which wreaks all kinds of havoc during migration, uncharge etc.

The file-specific charge path used to filter PageCompound(), but it
wasn't commented and so it got lost when unifying the charge paths.

We can't add PageCompound() back into a unified charge path because of
THP, so filter huge pages directly in add_to_page_cache().

Reported-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/filemap.c | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 114cd89c1cc2..c088ac01e856 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -31,6 +31,7 @@
 #include <linux/security.h>
 #include <linux/cpuset.h>
 #include <linux/hardirq.h> /* for BUG_ON(!in_atomic()) only */
+#include <linux/hugetlb.h>
 #include <linux/memcontrol.h>
 #include <linux/cleancache.h>
 #include <linux/rmap.h>
@@ -560,19 +561,24 @@ static int __add_to_page_cache_locked(struct page *page,
 				      pgoff_t offset, gfp_t gfp_mask,
 				      void **shadowp)
 {
+	int huge = PageHuge(page);
 	struct mem_cgroup *memcg;
 	int error;
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(PageSwapBacked(page), page);
 
-	error = mem_cgroup_try_charge(page, current->mm, gfp_mask, &memcg);
-	if (error)
-		return error;
+	if (!huge) {
+		error = mem_cgroup_try_charge(page, current->mm,
+					      gfp_mask, &memcg);
+		if (error)
+			return error;
+	}
 
 	error = radix_tree_maybe_preload(gfp_mask & ~__GFP_HIGHMEM);
 	if (error) {
-		mem_cgroup_cancel_charge(page, memcg);
+		if (!huge)
+			mem_cgroup_cancel_charge(page, memcg);
 		return error;
 	}
 
@@ -587,14 +593,16 @@ static int __add_to_page_cache_locked(struct page *page,
 		goto err_insert;
 	__inc_zone_page_state(page, NR_FILE_PAGES);
 	spin_unlock_irq(&mapping->tree_lock);
-	mem_cgroup_commit_charge(page, memcg, false);
+	if (!huge)
+		mem_cgroup_commit_charge(page, memcg, false);
 	trace_mm_filemap_add_to_page_cache(page);
 	return 0;
 err_insert:
 	page->mapping = NULL;
 	/* Leave page->index set: truncation relies upon it */
 	spin_unlock_irq(&mapping->tree_lock);
-	mem_cgroup_cancel_charge(page, memcg);
+	if (!huge)
+		mem_cgroup_cancel_charge(page, memcg);
 	page_cache_release(page);
 	return error;
 }
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
