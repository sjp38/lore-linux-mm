Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id AFCF36B0033
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 22:03:02 -0400 (EDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 18 Jul 2013 11:53:28 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 033AC357804E
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 12:02:54 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6I1lRfN55771298
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 11:47:28 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6I22pRG024101
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 12:02:52 +1000
Date: Wed, 17 Jul 2013 22:02:48 -0400
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 9/9] mm, hugetlb: decrement reserve count if VM_NORESERVE
 alloc page cache
Message-ID: <20130718020248.GA10133@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1373881967-16153-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1373881967-16153-10-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1373881967-16153-10-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

On Mon, Jul 15, 2013 at 06:52:47PM +0900, Joonsoo Kim wrote:
>If a vma with VM_NORESERVE allocate a new page for page cache, we should
>check whether this area is reserved or not. If this address is
>already reserved by other process(in case of chg == 0), we should
>decrement reserve count, because this allocated page will go into page
>cache and currently, there is no way to know that this page comes from
>reserved pool or not when releasing inode. This may introduce
>over-counting problem to reserved count. With following example code,
>you can easily reproduce this situation.
>
>        size = 20 * MB;
>        flag = MAP_SHARED;
>        p = mmap(NULL, size, PROT_READ|PROT_WRITE, flag, fd, 0);
>        if (p == MAP_FAILED) {
>                fprintf(stderr, "mmap() failed: %s\n", strerror(errno));
>                return -1;
>        }
>
>        flag = MAP_SHARED | MAP_NORESERVE;
>        q = mmap(NULL, size, PROT_READ|PROT_WRITE, flag, fd, 0);
>        if (q == MAP_FAILED) {
>                fprintf(stderr, "mmap() failed: %s\n", strerror(errno));
>        }
>        q[0] = 'c';
>
>This patch solve this problem.
>
>Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>

Looks good to me!

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>index ed2d0af..defb180 100644
>--- a/mm/hugetlb.c
>+++ b/mm/hugetlb.c
>@@ -443,10 +443,23 @@ void reset_vma_resv_huge_pages(struct vm_area_struct *vma)
> }
>
> /* Returns true if the VMA has associated reserve pages */
>-static int vma_has_reserves(struct vm_area_struct *vma)
>+static int vma_has_reserves(struct vm_area_struct *vma, long chg)
> {
>-	if (vma->vm_flags & VM_NORESERVE)
>-		return 0;
>+	if (vma->vm_flags & VM_NORESERVE) {
>+		/*
>+		 * This address is already reserved by other process(chg == 0),
>+		 * so, we should decreament reserved count. Without
>+		 * decreamenting, reserve count is remained after releasing
>+		 * inode, because this allocated page will go into page cache
>+		 * and is regarded as coming from reserved pool in releasing
>+		 * step. Currently, we don't have any other solution to deal
>+		 * with this situation properly, so add work-around here.
>+		 */
>+		if (vma->vm_flags & VM_MAYSHARE && chg == 0)
>+			return 1;
>+		else
>+			return 0;
>+	}
>
> 	/* Shared mappings always use reserves */
> 	if (vma->vm_flags & VM_MAYSHARE)
>@@ -520,7 +533,8 @@ static struct page *dequeue_huge_page_node(struct hstate *h, int nid)
>
> static struct page *dequeue_huge_page_vma(struct hstate *h,
> 				struct vm_area_struct *vma,
>-				unsigned long address, int avoid_reserve)
>+				unsigned long address, int avoid_reserve,
>+				long chg)
> {
> 	struct page *page = NULL;
> 	struct mempolicy *mpol;
>@@ -535,7 +549,7 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
> 	 * have no page reserves. This check ensures that reservations are
> 	 * not "stolen". The child may still get SIGKILLed
> 	 */
>-	if (!vma_has_reserves(vma) &&
>+	if (!vma_has_reserves(vma, chg) &&
> 			h->free_huge_pages - h->resv_huge_pages == 0)
> 		return NULL;
>
>@@ -553,8 +567,12 @@ retry_cpuset:
> 		if (cpuset_zone_allowed_softwall(zone, htlb_alloc_mask)) {
> 			page = dequeue_huge_page_node(h, zone_to_nid(zone));
> 			if (page) {
>-				if (!avoid_reserve && vma_has_reserves(vma))
>-					h->resv_huge_pages--;
>+				if (avoid_reserve)
>+					break;
>+				if (!vma_has_reserves(vma, chg))
>+					break;
>+
>+				h->resv_huge_pages--;
> 				break;
> 			}
> 		}
>@@ -1139,7 +1157,7 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
> 	}
>
> 	spin_lock(&hugetlb_lock);
>-	page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve);
>+	page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve, chg);
> 	if (!page) {
> 		spin_unlock(&hugetlb_lock);
> 		page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
>-- 
>1.7.9.5
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
