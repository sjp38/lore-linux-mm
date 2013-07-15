Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id D2C786B00AD
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 05:52:50 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 1/9] mm, hugetlb: move up the code which check availability of free huge page
Date: Mon, 15 Jul 2013 18:52:39 +0900
Message-Id: <1373881967-16153-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1373881967-16153-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1373881967-16153-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

We don't need to proceede the processing if we don't have any usable
free huge page. So move this code up.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index e2bfbf7..d87f70b 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -539,10 +539,6 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
 	struct zoneref *z;
 	unsigned int cpuset_mems_cookie;
 
-retry_cpuset:
-	cpuset_mems_cookie = get_mems_allowed();
-	zonelist = huge_zonelist(vma, address,
-					htlb_alloc_mask, &mpol, &nodemask);
 	/*
 	 * A child process with MAP_PRIVATE mappings created by their parent
 	 * have no page reserves. This check ensures that reservations are
@@ -550,11 +546,16 @@ retry_cpuset:
 	 */
 	if (!vma_has_reserves(vma) &&
 			h->free_huge_pages - h->resv_huge_pages == 0)
-		goto err;
+		return NULL;
 
 	/* If reserves cannot be used, ensure enough pages are in the pool */
 	if (avoid_reserve && h->free_huge_pages - h->resv_huge_pages == 0)
-		goto err;
+		return NULL;
+
+retry_cpuset:
+	cpuset_mems_cookie = get_mems_allowed();
+	zonelist = huge_zonelist(vma, address,
+					htlb_alloc_mask, &mpol, &nodemask);
 
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 						MAX_NR_ZONES - 1, nodemask) {
@@ -572,10 +573,6 @@ retry_cpuset:
 	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
 		goto retry_cpuset;
 	return page;
-
-err:
-	mpol_cond_put(mpol);
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
