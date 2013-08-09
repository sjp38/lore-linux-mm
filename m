Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 7D94A6B003A
	for <linux-mm@kvack.org>; Fri,  9 Aug 2013 05:27:14 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 10/20] mm, hugetlb: remove resv_map_put()
Date: Fri,  9 Aug 2013 18:26:28 +0900
Message-Id: <1376040398-11212-11-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

In following patch, I change vma_resv_map() to return resv_map
for all case. This patch prepares it by removing resv_map_put() which
doesn't works properly with following change, because it works only for
HPAGE_RESV_OWNER's resv_map, not for all resv_maps.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 73034dd..869c3e0 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2212,15 +2212,6 @@ static void hugetlb_vm_op_open(struct vm_area_struct *vma)
 		kref_get(&resv->refs);
 }
 
-static void resv_map_put(struct vm_area_struct *vma)
-{
-	struct resv_map *resv = vma_resv_map(vma);
-
-	if (!resv)
-		return;
-	kref_put(&resv->refs, resv_map_release);
-}
-
 static void hugetlb_vm_op_close(struct vm_area_struct *vma)
 {
 	struct hstate *h = hstate_vma(vma);
@@ -2237,7 +2228,7 @@ static void hugetlb_vm_op_close(struct vm_area_struct *vma)
 		reserve = (end - start) -
 			region_count(resv, start, end);
 
-		resv_map_put(vma);
+		kref_put(&resv->refs, resv_map_release);
 
 		if (reserve) {
 			hugetlb_acct_memory(h, -reserve);
@@ -3164,8 +3155,8 @@ int hugetlb_reserve_pages(struct inode *inode,
 		region_add(resv_map, from, to);
 	return 0;
 out_err:
-	if (vma)
-		resv_map_put(vma);
+	if (vma && is_vma_resv_set(vma, HPAGE_RESV_OWNER))
+		kref_put(&resv_map->refs, resv_map_release);
 	return ret;
 }
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
