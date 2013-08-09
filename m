Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 4D45A6B006C
	for <linux-mm@kvack.org>; Fri,  9 Aug 2013 05:27:16 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 16/20] mm, hugetlb: move down outside_reserve check
Date: Fri,  9 Aug 2013 18:26:34 +0900
Message-Id: <1376040398-11212-17-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Just move down outside_reserve check and don't check
vma_need_reservation() when outside_resever is true. It is slightly
optimized implementation.

This makes code more readable.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 24de2ca..2372f75 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2499,7 +2499,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct page *old_page, *new_page;
 	int outside_reserve = 0;
 	long chg;
-	bool use_reserve;
+	bool use_reserve = false;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
 
@@ -2514,6 +2514,11 @@ retry_avoidcopy:
 		return 0;
 	}
 
+	page_cache_get(old_page);
+
+	/* Drop page_table_lock as buddy allocator may be called */
+	spin_unlock(&mm->page_table_lock);
+
 	/*
 	 * If the process that created a MAP_PRIVATE mapping is about to
 	 * perform a COW due to a shared page count, attempt to satisfy
@@ -2527,19 +2532,17 @@ retry_avoidcopy:
 			old_page != pagecache_page)
 		outside_reserve = 1;
 
-	page_cache_get(old_page);
-
-	/* Drop page_table_lock as buddy allocator may be called */
-	spin_unlock(&mm->page_table_lock);
-	chg = vma_needs_reservation(h, vma, address);
-	if (chg == -ENOMEM) {
-		page_cache_release(old_page);
+	if (!outside_reserve) {
+		chg = vma_needs_reservation(h, vma, address);
+		if (chg == -ENOMEM) {
+			page_cache_release(old_page);
 
-		/* Caller expects lock to be held */
-		spin_lock(&mm->page_table_lock);
-		return VM_FAULT_OOM;
+			/* Caller expects lock to be held */
+			spin_lock(&mm->page_table_lock);
+			return VM_FAULT_OOM;
+		}
+		use_reserve = !chg;
 	}
-	use_reserve = !chg && !outside_reserve;
 
 	new_page = alloc_huge_page(vma, address, use_reserve);
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
