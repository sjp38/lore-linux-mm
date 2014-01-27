Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id D2C006B003C
	for <linux-mm@kvack.org>; Sun, 26 Jan 2014 22:53:04 -0500 (EST)
Received: by mail-ob0-f180.google.com with SMTP id wp4so5787808obc.25
        for <linux-mm@kvack.org>; Sun, 26 Jan 2014 19:53:04 -0800 (PST)
Received: from g4t0017.houston.hp.com (g4t0017.houston.hp.com. [15.201.24.20])
        by mx.google.com with ESMTPS id tk7si3656200obc.42.2014.01.26.19.53.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 26 Jan 2014 19:53:03 -0800 (PST)
From: Davidlohr Bueso <davidlohr@hp.com>
Subject: [PATCH 6/8] mm, hugetlb: remove vma_has_reserves
Date: Sun, 26 Jan 2014 19:52:24 -0800
Message-Id: <1390794746-16755-7-git-send-email-davidlohr@hp.com>
In-Reply-To: <1390794746-16755-1-git-send-email-davidlohr@hp.com>
References: <1390794746-16755-1-git-send-email-davidlohr@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com
Cc: riel@redhat.com, mgorman@suse.de, mhocko@suse.cz, aneesh.kumar@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, hughd@google.com, david@gibson.dropbear.id.au, js1304@gmail.com, liwanp@linux.vnet.ibm.com, n-horiguchi@ah.jp.nec.com, dhillf@gmail.com, rientjes@google.com, davidlohr@hp.com, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

vma_has_reserves() can be substituted by using return value of
vma_needs_reservation(). If chg returned by vma_needs_reservation()
is 0, it means that vma has reserves. Otherwise, it means that vma don't
have reserves and need a hugepage outside of reserve pool. This definition
is perfectly same as vma_has_reserves(), so remove vma_has_reserves().

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
---
 mm/hugetlb.c | 46 +++++++++-------------------------------------
 1 file changed, 9 insertions(+), 37 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 541cceb..83bc161 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -469,39 +469,6 @@ void reset_vma_resv_huge_pages(struct vm_area_struct *vma)
 		vma->vm_private_data = (void *)0;
 }
 
-/* Returns true if the VMA has associated reserve pages */
-static int vma_has_reserves(struct vm_area_struct *vma, long chg)
-{
-	if (vma->vm_flags & VM_NORESERVE) {
-		/*
-		 * This address is already reserved by other process(chg == 0),
-		 * so, we should decrement reserved count. Without decrementing,
-		 * reserve count remains after releasing inode, because this
-		 * allocated page will go into page cache and is regarded as
-		 * coming from reserved pool in releasing step.  Currently, we
-		 * don't have any other solution to deal with this situation
-		 * properly, so add work-around here.
-		 */
-		if (vma->vm_flags & VM_MAYSHARE && chg == 0)
-			return 1;
-		else
-			return 0;
-	}
-
-	/* Shared mappings always use reserves */
-	if (vma->vm_flags & VM_MAYSHARE)
-		return 1;
-
-	/*
-	 * Only the process that called mmap() has reserves for
-	 * private mappings.
-	 */
-	if (is_vma_resv_set(vma, HPAGE_RESV_OWNER))
-		return 1;
-
-	return 0;
-}
-
 static void enqueue_huge_page(struct hstate *h, struct page *page)
 {
 	int nid = page_to_nid(page);
@@ -555,10 +522,11 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
 	/*
 	 * A child process with MAP_PRIVATE mappings created by their parent
 	 * have no page reserves. This check ensures that reservations are
-	 * not "stolen". The child may still get SIGKILLed
+	 * not "stolen". The child may still get SIGKILLed.
+	 * chg represents whether current user has a reserved hugepages or not,
+	 * so that we can use it to ensure that reservations are not "stolen".
 	 */
-	if (!vma_has_reserves(vma, chg) &&
-			h->free_huge_pages - h->resv_huge_pages == 0)
+	if (chg && h->free_huge_pages - h->resv_huge_pages == 0)
 		goto err;
 
 	/* If reserves cannot be used, ensure enough pages are in the pool */
@@ -577,7 +545,11 @@ retry_cpuset:
 			if (page) {
 				if (avoid_reserve)
 					break;
-				if (!vma_has_reserves(vma, chg))
+				/*
+				 * chg means whether current user allocates
+				 * a hugepage on the reserved pool or not
+				 */
+				if (chg)
 					break;
 
 				SetPagePrivate(page);
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
