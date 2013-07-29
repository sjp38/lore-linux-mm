Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 520CA6B0078
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 01:32:26 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 16/18] mm, hugetlb: return a reserved page to a reserved pool if failed
Date: Mon, 29 Jul 2013 14:32:07 +0900
Message-Id: <1375075929-6119-17-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1375075929-6119-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1375075929-6119-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

If we fail with a reserved page, just calling put_page() is not sufficient,
because put_page() invoke free_huge_page() at last step and it doesn't
know whether a page comes from a reserved pool or not. So it doesn't do
anything related to reserved count. This makes reserve count lower
than how we need, because reserve count already decrease in
dequeue_huge_page_vma(). This patch fix this situation.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index bb8a45f..6a9ec69 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -649,6 +649,34 @@ struct hstate *size_to_hstate(unsigned long size)
 	return NULL;
 }
 
+static void put_huge_page(struct page *page, int use_reserve)
+{
+	struct hstate *h = page_hstate(page);
+	struct hugepage_subpool *spool =
+		(struct hugepage_subpool *)page_private(page);
+
+	if (!use_reserve) {
+		put_page(page);
+		return;
+	}
+
+	if (!put_page_testzero(page))
+		return;
+
+	set_page_private(page, 0);
+	page->mapping = NULL;
+	BUG_ON(page_count(page));
+	BUG_ON(page_mapcount(page));
+
+	spin_lock(&hugetlb_lock);
+	hugetlb_cgroup_uncharge_page(hstate_index(h),
+				     pages_per_huge_page(h), page);
+	enqueue_huge_page(h, page);
+	h->resv_huge_pages++;
+	spin_unlock(&hugetlb_lock);
+	hugepage_subpool_put_pages(spool, 1);
+}
+
 static void free_huge_page(struct page *page)
 {
 	/*
@@ -2625,7 +2653,7 @@ retry_avoidcopy:
 	spin_unlock(&mm->page_table_lock);
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 
-	page_cache_release(new_page);
+	put_huge_page(new_page, use_reserve);
 out_old_page:
 	page_cache_release(old_page);
 out_lock:
@@ -2725,7 +2753,7 @@ retry:
 
 			err = add_to_page_cache(page, mapping, idx, GFP_KERNEL);
 			if (err) {
-				put_page(page);
+				put_huge_page(page, use_reserve);
 				if (err == -EEXIST)
 					goto retry;
 				goto out;
@@ -2798,7 +2826,7 @@ backout:
 	spin_unlock(&mm->page_table_lock);
 backout_unlocked:
 	unlock_page(page);
-	put_page(page);
+	put_huge_page(page, use_reserve);
 	goto out;
 }
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
