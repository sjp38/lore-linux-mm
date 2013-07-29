Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 620EF6B0071
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 01:32:26 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 15/18] mm, hugetlb: move up anon_vma_prepare()
Date: Mon, 29 Jul 2013 14:32:06 +0900
Message-Id: <1375075929-6119-16-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1375075929-6119-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1375075929-6119-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

If we fail with a allocated hugepage, it is hard to recover properly.
One such example is reserve count. We don't have any method to recover
reserve count. Although, I will introduce a function to recover reserve
count in following patch, it is better not to allocate a hugepage
as much as possible. So move up anon_vma_prepare() which can be failed
in OOM situation.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 683fd38..bb8a45f 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2536,6 +2536,15 @@ retry_avoidcopy:
 	/* Drop page_table_lock as buddy allocator may be called */
 	spin_unlock(&mm->page_table_lock);
 
+	/*
+	 * When the original hugepage is shared one, it does not have
+	 * anon_vma prepared.
+	 */
+	if (unlikely(anon_vma_prepare(vma))) {
+		ret = VM_FAULT_OOM;
+		goto out_old_page;
+	}
+
 	use_reserve = vma_has_reserves(h, vma, address);
 	if (use_reserve == -ENOMEM) {
 		ret = VM_FAULT_OOM;
@@ -2590,15 +2599,6 @@ retry_avoidcopy:
 		goto out_lock;
 	}
 
-	/*
-	 * When the original hugepage is shared one, it does not have
-	 * anon_vma prepared.
-	 */
-	if (unlikely(anon_vma_prepare(vma))) {
-		ret = VM_FAULT_OOM;
-		goto out_new_page;
-	}
-
 	copy_user_huge_page(new_page, old_page, address, vma,
 			    pages_per_huge_page(h));
 	__SetPageUptodate(new_page);
@@ -2625,7 +2625,6 @@ retry_avoidcopy:
 	spin_unlock(&mm->page_table_lock);
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 
-out_new_page:
 	page_cache_release(new_page);
 out_old_page:
 	page_cache_release(old_page);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
