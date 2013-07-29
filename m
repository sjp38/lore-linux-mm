Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 981606B003C
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 01:28:29 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 9/9] mm, hugetlb: decrement reserve count if VM_NORESERVE alloc page cache
Date: Mon, 29 Jul 2013 14:28:21 +0900
Message-Id: <1375075701-5998-10-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1375075701-5998-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1375075701-5998-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

If a vma with VM_NORESERVE allocate a new page for page cache, we should
check whether this area is reserved or not. If this address is
already reserved by other process(in case of chg == 0), we should
decrement reserve count, because this allocated page will go into page
cache and currently, there is no way to know that this page comes from
reserved pool or not when releasing inode. This may introduce
over-counting problem to reserved count. With following example code,
you can easily reproduce this situation.

Assume 2MB, nr_hugepages = 100

        size = 20 * MB;
        flag = MAP_SHARED;
        p = mmap(NULL, size, PROT_READ|PROT_WRITE, flag, fd, 0);
        if (p == MAP_FAILED) {
                fprintf(stderr, "mmap() failed: %s\n", strerror(errno));
                return -1;
        }

        flag = MAP_SHARED | MAP_NORESERVE;
        q = mmap(NULL, size, PROT_READ|PROT_WRITE, flag, fd, 0);
        if (q == MAP_FAILED) {
                fprintf(stderr, "mmap() failed: %s\n", strerror(errno));
        }
        q[0] = 'c';

After finish the program, run 'cat /proc/meminfo'.
You can see below result.

HugePages_Free:      100
HugePages_Rsvd:        1

To fix this, we should check our mapping type and tracked region.
If our mapping is VM_NORESERVE, VM_MAYSHARE and chg is 0, this imply
that current allocated page will go into page cache which is already
reserved region when mapping is created. In this case, we should decrease
reserve count. As implementing above, this patch solve the problem.

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 4b1b043..b3b8252 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -443,10 +443,23 @@ void reset_vma_resv_huge_pages(struct vm_area_struct *vma)
 }
 
 /* Returns true if the VMA has associated reserve pages */
-static int vma_has_reserves(struct vm_area_struct *vma)
+static int vma_has_reserves(struct vm_area_struct *vma, long chg)
 {
-	if (vma->vm_flags & VM_NORESERVE)
-		return 0;
+	if (vma->vm_flags & VM_NORESERVE) {
+		/*
+		 * This address is already reserved by other process(chg == 0),
+		 * so, we should decreament reserved count. Without
+		 * decreamenting, reserve count is remained after releasing
+		 * inode, because this allocated page will go into page cache
+		 * and is regarded as coming from reserved pool in releasing
+		 * step. Currently, we don't have any other solution to deal
+		 * with this situation properly, so add work-around here.
+		 */
+		if (vma->vm_flags & VM_MAYSHARE && chg == 0)
+			return 1;
+		else
+			return 0;
+	}
 
 	/* Shared mappings always use reserves */
 	if (vma->vm_flags & VM_MAYSHARE)
@@ -520,7 +533,8 @@ static struct page *dequeue_huge_page_node(struct hstate *h, int nid)
 
 static struct page *dequeue_huge_page_vma(struct hstate *h,
 				struct vm_area_struct *vma,
-				unsigned long address, int avoid_reserve)
+				unsigned long address, int avoid_reserve,
+				long chg)
 {
 	struct page *page = NULL;
 	struct mempolicy *mpol;
@@ -535,7 +549,7 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
 	 * have no page reserves. This check ensures that reservations are
 	 * not "stolen". The child may still get SIGKILLed
 	 */
-	if (!vma_has_reserves(vma) &&
+	if (!vma_has_reserves(vma, chg) &&
 			h->free_huge_pages - h->resv_huge_pages == 0)
 		goto err;
 
@@ -553,8 +567,12 @@ retry_cpuset:
 		if (cpuset_zone_allowed_softwall(zone, htlb_alloc_mask)) {
 			page = dequeue_huge_page_node(h, zone_to_nid(zone));
 			if (page) {
-				if (!avoid_reserve && vma_has_reserves(vma))
-					h->resv_huge_pages--;
+				if (avoid_reserve)
+					break;
+				if (!vma_has_reserves(vma, chg))
+					break;
+
+				h->resv_huge_pages--;
 				break;
 			}
 		}
@@ -1138,7 +1156,7 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 		return ERR_PTR(-ENOSPC);
 	}
 	spin_lock(&hugetlb_lock);
-	page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve);
+	page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve, chg);
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
