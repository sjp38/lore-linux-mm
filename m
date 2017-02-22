Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id E81C76B038B
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 13:50:48 -0500 (EST)
Received: by mail-yw0-f198.google.com with SMTP id 204so11187270ywo.6
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 10:50:48 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 203si2444378iti.26.2017.02.22.10.50.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Feb 2017 10:50:48 -0800 (PST)
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.20/8.16.0.20) with SMTP id v1MIkNvC001694
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 10:50:47 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 28scegrv1c-9
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 10:50:47 -0800
Received: from facebook.com (2401:db00:21:603d:face:0:19:0)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 d115aefef92f11e6ab8124be0593f280-908fca00 for <linux-mm@kvack.org>;	Wed, 22
 Feb 2017 10:50:45 -0800
From: Shaohua Li <shli@fb.com>
Subject: [PATCH V4 2/6] mm: don't assume anonymous pages have SwapBacked flag
Date: Wed, 22 Feb 2017 10:50:40 -0800
Message-ID: <d6ad5526bb152bb1576704cce517c12de9e6a479.1487788131.git.shli@fb.com>
In-Reply-To: <cover.1487788131.git.shli@fb.com>
References: <cover.1487788131.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kernel-team@fb.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

There are a few places the code assumes anonymous pages should have
SwapBacked flag set. MADV_FREE pages are anonymous pages but we are
going to add them to LRU_INACTIVE_FILE list and clear SwapBacked flag
for them. The assumption doesn't hold any more, so fix them.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Shaohua Li <shli@fb.com>
---
 mm/huge_memory.c | 1 -
 mm/khugepaged.c  | 8 +++-----
 mm/migrate.c     | 3 ++-
 mm/rmap.c        | 3 ++-
 4 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 7dda8d6..cf9fb46 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2361,7 +2361,6 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 
 	VM_BUG_ON_PAGE(is_huge_zero_page(page), page);
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
-	VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
 	VM_BUG_ON_PAGE(!PageCompound(page), page);
 
 	if (PageAnon(head)) {
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 34bce5c..a4b499f 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -481,8 +481,7 @@ void __khugepaged_exit(struct mm_struct *mm)
 
 static void release_pte_page(struct page *page)
 {
-	/* 0 stands for page_is_file_cache(page) == false */
-	dec_node_page_state(page, NR_ISOLATED_ANON + 0);
+	dec_node_page_state(page, NR_ISOLATED_ANON + page_is_file_cache(page));
 	unlock_page(page);
 	putback_lru_page(page);
 }
@@ -530,7 +529,6 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 
 		VM_BUG_ON_PAGE(PageCompound(page), page);
 		VM_BUG_ON_PAGE(!PageAnon(page), page);
-		VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
 
 		/*
 		 * We can do it before isolate_lru_page because the
@@ -577,8 +575,8 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 			result = SCAN_DEL_PAGE_LRU;
 			goto out;
 		}
-		/* 0 stands for page_is_file_cache(page) == false */
-		inc_node_page_state(page, NR_ISOLATED_ANON + 0);
+		inc_node_page_state(page,
+				NR_ISOLATED_ANON + page_is_file_cache(page));
 		VM_BUG_ON_PAGE(!PageLocked(page), page);
 		VM_BUG_ON_PAGE(PageLRU(page), page);
 
diff --git a/mm/migrate.c b/mm/migrate.c
index 2c63ac0..7c8df1f 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1943,7 +1943,8 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 
 	/* Prepare a page as a migration target */
 	__SetPageLocked(new_page);
-	__SetPageSwapBacked(new_page);
+	if (PageSwapBacked(page))
+		__SetPageSwapBacked(new_page);
 
 	/* anon mapping, we can simply copy page->mapping to the new page: */
 	new_page->mapping = page->mapping;
diff --git a/mm/rmap.c b/mm/rmap.c
index 96eb85c..c621088 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1416,7 +1416,8 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			 * Store the swap location in the pte.
 			 * See handle_pte_fault() ...
 			 */
-			VM_BUG_ON_PAGE(!PageSwapCache(page), page);
+			VM_BUG_ON_PAGE(!PageSwapCache(page) && PageSwapBacked(page),
+				page);
 
 			if (!PageDirty(page)) {
 				/* It's a freeable page by MADV_FREE */
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
