Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id D13C06B0033
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 04:36:38 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 02/10] mm, hugetlb: remove err label in dequeue_huge_page_vma()
Date: Mon, 22 Jul 2013 17:36:23 +0900
Message-Id: <1374482191-3500-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1374482191-3500-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1374482191-3500-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

This label is not needed now, because there is no error handling
except returing NULL.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index fc4988c..d87f70b 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -546,11 +546,11 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
 	 */
 	if (!vma_has_reserves(vma) &&
 			h->free_huge_pages - h->resv_huge_pages == 0)
-		goto err;
+		return NULL;
 
 	/* If reserves cannot be used, ensure enough pages are in the pool */
 	if (avoid_reserve && h->free_huge_pages - h->resv_huge_pages == 0)
-		goto err;
+		return NULL;
 
 retry_cpuset:
 	cpuset_mems_cookie = get_mems_allowed();
@@ -573,9 +573,6 @@ retry_cpuset:
 	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
 		goto retry_cpuset;
 	return page;
-
-err:
-	return NULL;
 }
 
 static void update_and_free_page(struct hstate *h, struct page *page)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
