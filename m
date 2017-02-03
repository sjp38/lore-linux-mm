Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 885036B0033
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 18:33:27 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id d123so40824707pfd.0
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 15:33:27 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id q2si22034063pga.211.2017.02.03.15.33.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Feb 2017 15:33:26 -0800 (PST)
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v13NX18U005177
	for <linux-mm@kvack.org>; Fri, 3 Feb 2017 15:33:26 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 28d272r8qh-2
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 03 Feb 2017 15:33:26 -0800
Received: from facebook.com (2401:db00:21:603d:face:0:19:0)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 27d883aeea6911e6b0e724be05956610-f0df8a50 for <linux-mm@kvack.org>;	Fri, 03
 Feb 2017 15:33:24 -0800
From: Shaohua Li <shli@fb.com>
Subject: [PATCH V2 1/7] mm: don't assume anonymous pages have SwapBacked flag
Date: Fri, 3 Feb 2017 15:33:17 -0800
Message-ID: <5f73795b14f18dec9aa2d995b60467e374a4d906.1486163864.git.shli@fb.com>
In-Reply-To: <cover.1486163864.git.shli@fb.com>
References: <cover.1486163864.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Kernel-team@fb.com, danielmicay@gmail.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

There are a few places the code assumes anonymous pages should have
SwapBacked flag set. MADV_FREE pages are anonymous pages but we are
going to add them to LRU_INACTIVE_FILE list and clear SwapBacked flag
for them. The assumption doesn't hold any more, so fix them.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Shaohua Li <shli@fb.com>
---
 mm/huge_memory.c | 1 -
 mm/khugepaged.c  | 8 +++-----
 mm/migrate.c     | 3 ++-
 mm/rmap.c        | 3 ++-
 4 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 40bd376..ecf569d 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2118,7 +2118,6 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 
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
index 87f4d0f..eb76f87 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1963,7 +1963,8 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 
 	/* Prepare a page as a migration target */
 	__SetPageLocked(new_page);
-	__SetPageSwapBacked(new_page);
+	if (PageSwapBacked(page))
+		__SetPageSwapBacked(new_page);
 
 	/* anon mapping, we can simply copy page->mapping to the new page: */
 	new_page->mapping = page->mapping;
diff --git a/mm/rmap.c b/mm/rmap.c
index c48e9c1..c8d6204 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1546,7 +1546,8 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		 * Store the swap location in the pte.
 		 * See handle_pte_fault() ...
 		 */
-		VM_BUG_ON_PAGE(!PageSwapCache(page), page);
+		VM_BUG_ON_PAGE(!PageSwapCache(page) && PageSwapBacked(page),
+			page);
 
 		if (!PageDirty(page) && (flags & TTU_LZFREE)) {
 			/* It's a freeable page by MADV_FREE */
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
