Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 60F486B005C
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 01:32:23 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 07/18] mm, hugetlb: pass has_reserve to dequeue_huge_page_vma()
Date: Mon, 29 Jul 2013 14:31:58 +0900
Message-Id: <1375075929-6119-8-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1375075929-6119-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1375075929-6119-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

We don't have to call vma_has_reserve() each time we need information.
Passing has_reserve unburden this effort.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ff46a2c..1426c03 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -572,7 +572,8 @@ static struct page *dequeue_huge_page_node(struct hstate *h, int nid)
 
 static struct page *dequeue_huge_page_vma(struct hstate *h,
 				struct vm_area_struct *vma,
-				unsigned long address, int avoid_reserve)
+				unsigned long address,
+				int has_reserve, int avoid_reserve)
 {
 	struct page *page = NULL;
 	struct mempolicy *mpol;
@@ -587,8 +588,7 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
 	 * have no page reserves. This check ensures that reservations are
 	 * not "stolen". The child may still get SIGKILLed
 	 */
-	if (!vma_has_reserves(h, vma, address) &&
-			h->free_huge_pages - h->resv_huge_pages == 0)
+	if (!has_reserve && h->free_huge_pages - h->resv_huge_pages == 0)
 		return NULL;
 
 	/* If reserves cannot be used, ensure enough pages are in the pool */
@@ -607,7 +607,7 @@ retry_cpuset:
 			if (page) {
 				if (avoid_reserve)
 					break;
-				if (!vma_has_reserves(h, vma, address))
+				if (!has_reserve)
 					break;
 
 				h->resv_huge_pages--;
@@ -1159,7 +1159,7 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 		return ERR_PTR(-ENOSPC);
 	}
 	spin_lock(&hugetlb_lock);
-	page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve);
+	page = dequeue_huge_page_vma(h, vma, addr, has_reserve, avoid_reserve);
 	if (!page) {
 		spin_unlock(&hugetlb_lock);
 		page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
