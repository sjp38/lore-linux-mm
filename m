Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id A33DD6B0036
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 01:28:29 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 8/9] mm, hugetlb: remove decrement_hugepage_resv_vma()
Date: Mon, 29 Jul 2013 14:28:20 +0900
Message-Id: <1375075701-5998-9-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1375075701-5998-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1375075701-5998-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Now, Checking condition of decrement_hugepage_resv_vma() and
vma_has_reserves() is same, so we can clean-up this function with
vma_has_reserves(). Additionally, decrement_hugepage_resv_vma() has only
one call site, so we can remove function and embed it into
dequeue_huge_page_vma() directly. This patch implement it.

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ca15854..4b1b043 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -434,25 +434,6 @@ static int is_vma_resv_set(struct vm_area_struct *vma, unsigned long flag)
 	return (get_vma_private_data(vma) & flag) != 0;
 }
 
-/* Decrement the reserved pages in the hugepage pool by one */
-static void decrement_hugepage_resv_vma(struct hstate *h,
-			struct vm_area_struct *vma)
-{
-	if (vma->vm_flags & VM_NORESERVE)
-		return;
-
-	if (vma->vm_flags & VM_MAYSHARE) {
-		/* Shared mappings always use reserves */
-		h->resv_huge_pages--;
-	} else if (is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
-		/*
-		 * Only the process that called mmap() has reserves for
-		 * private mappings.
-		 */
-		h->resv_huge_pages--;
-	}
-}
-
 /* Reset counters to 0 and clear all HPAGE_RESV_* flags */
 void reset_vma_resv_huge_pages(struct vm_area_struct *vma)
 {
@@ -466,10 +447,18 @@ static int vma_has_reserves(struct vm_area_struct *vma)
 {
 	if (vma->vm_flags & VM_NORESERVE)
 		return 0;
+
+	/* Shared mappings always use reserves */
 	if (vma->vm_flags & VM_MAYSHARE)
 		return 1;
+
+	/*
+	 * Only the process that called mmap() has reserves for
+	 * private mappings.
+	 */
 	if (is_vma_resv_set(vma, HPAGE_RESV_OWNER))
 		return 1;
+
 	return 0;
 }
 
@@ -564,8 +553,8 @@ retry_cpuset:
 		if (cpuset_zone_allowed_softwall(zone, htlb_alloc_mask)) {
 			page = dequeue_huge_page_node(h, zone_to_nid(zone));
 			if (page) {
-				if (!avoid_reserve)
-					decrement_hugepage_resv_vma(h, vma);
+				if (!avoid_reserve && vma_has_reserves(vma))
+					h->resv_huge_pages--;
 				break;
 			}
 		}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
