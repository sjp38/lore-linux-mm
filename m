Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 3CA5C6B0031
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 01:32:21 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 01/18] mm, hugetlb: protect reserved pages when softofflining requests the pages
Date: Mon, 29 Jul 2013 14:31:52 +0900
Message-Id: <1375075929-6119-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1375075929-6119-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1375075929-6119-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

alloc_huge_page_node() use dequeue_huge_page_node() without
any validation check, so it can steal reserved page unconditionally.
To fix it, check the number of free_huge_page in alloc_huge_page_node().

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 6782b41..d971233 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -935,10 +935,11 @@ static struct page *alloc_buddy_huge_page(struct hstate *h, int nid)
  */
 struct page *alloc_huge_page_node(struct hstate *h, int nid)
 {
-	struct page *page;
+	struct page *page = NULL;
 
 	spin_lock(&hugetlb_lock);
-	page = dequeue_huge_page_node(h, nid);
+	if (h->free_huge_pages - h->resv_huge_pages > 0)
+		page = dequeue_huge_page_node(h, nid);
 	spin_unlock(&hugetlb_lock);
 
 	if (!page)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
