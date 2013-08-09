Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 465AA6B003B
	for <linux-mm@kvack.org>; Fri,  9 Aug 2013 05:27:13 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 06/20] mm, hugetlb: return a reserved page to a reserved pool if failed
Date: Fri,  9 Aug 2013 18:26:24 +0900
Message-Id: <1376040398-11212-7-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com>
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
index 6c8eec2..3f834f1 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -572,6 +572,7 @@ retry_cpuset:
 				if (!vma_has_reserves(vma, chg))
 					break;
 
+				SetPagePrivate(page);
 				h->resv_huge_pages--;
 				break;
 			}
@@ -626,15 +627,20 @@ static void free_huge_page(struct page *page)
 	int nid = page_to_nid(page);
 	struct hugepage_subpool *spool =
 		(struct hugepage_subpool *)page_private(page);
+	bool restore_reserve;
 
 	set_page_private(page, 0);
 	page->mapping = NULL;
 	BUG_ON(page_count(page));
 	BUG_ON(page_mapcount(page));
+	restore_reserve = PagePrivate(page);
 
 	spin_lock(&hugetlb_lock);
 	hugetlb_cgroup_uncharge_page(hstate_index(h),
 				     pages_per_huge_page(h), page);
+	if (restore_reserve)
+		h->resv_huge_pages++;
+
 	if (h->surplus_huge_pages_node[nid] && huge_page_order(h) < MAX_ORDER) {
 		/* remove the page from active list */
 		list_del(&page->lru);
@@ -2616,6 +2622,8 @@ retry_avoidcopy:
 	spin_lock(&mm->page_table_lock);
 	ptep = huge_pte_offset(mm, address & huge_page_mask(h));
 	if (likely(pte_same(huge_ptep_get(ptep), pte))) {
+		ClearPagePrivate(new_page);
+
 		/* Break COW */
 		huge_ptep_clear_flush(vma, address, ptep);
 		set_huge_pte_at(mm, address, ptep,
@@ -2727,6 +2735,7 @@ retry:
 					goto retry;
 				goto out;
 			}
+			ClearPagePrivate(page);
 
 			spin_lock(&inode->i_lock);
 			inode->i_blocks += blocks_per_huge_page(h);
@@ -2773,8 +2782,10 @@ retry:
 	if (!huge_pte_none(huge_ptep_get(ptep)))
 		goto backout;
 
-	if (anon_rmap)
+	if (anon_rmap) {
+		ClearPagePrivate(page);
 		hugepage_add_new_anon_rmap(page, vma, address);
+	}
 	else
 		page_dup_rmap(page);
 	new_pte = make_huge_pte(vma, page, ((vma->vm_flags & VM_WRITE)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
