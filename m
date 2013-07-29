Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id CED896B0073
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 01:32:24 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 11/18] mm, hugetlb: move down outside_reserve check
Date: Mon, 29 Jul 2013 14:32:02 +0900
Message-Id: <1375075929-6119-12-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1375075929-6119-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1375075929-6119-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Just move down outsider_reserve check.
This makes code more readable.

There is no functional change.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 5f31ca5..94173e0 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2530,20 +2530,6 @@ retry_avoidcopy:
 		return 0;
 	}
 
-	/*
-	 * If the process that created a MAP_PRIVATE mapping is about to
-	 * perform a COW due to a shared page count, attempt to satisfy
-	 * the allocation without using the existing reserves. The pagecache
-	 * page is used to determine if the reserve at this address was
-	 * consumed or not. If reserves were used, a partial faulted mapping
-	 * at the time of fork() could consume its reserves on COW instead
-	 * of the full address range.
-	 */
-	if (!(vma->vm_flags & VM_MAYSHARE) &&
-			is_vma_resv_set(vma, HPAGE_RESV_OWNER) &&
-			old_page != pagecache_page)
-		outside_reserve = 1;
-
 	page_cache_get(old_page);
 
 	/* Drop page_table_lock as buddy allocator may be called */
@@ -2557,6 +2543,20 @@ retry_avoidcopy:
 		spin_lock(&mm->page_table_lock);
 		return VM_FAULT_OOM;
 	}
+
+	/*
+	 * If the process that created a MAP_PRIVATE mapping is about to
+	 * perform a COW due to a shared page count, attempt to satisfy
+	 * the allocation without using the existing reserves. The pagecache
+	 * page is used to determine if the reserve at this address was
+	 * consumed or not. If reserves were used, a partial faulted mapping
+	 * at the time of fork() could consume its reserves on COW instead
+	 * of the full address range.
+	 */
+	if (!(vma->vm_flags & VM_MAYSHARE) &&
+			is_vma_resv_set(vma, HPAGE_RESV_OWNER) &&
+			old_page != pagecache_page)
+		outside_reserve = 1;
 	use_reserve = use_reserve && !outside_reserve;
 
 	new_page = alloc_huge_page(vma, address, use_reserve);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
