Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id A61356B0032
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 05:31:20 -0400 (EDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 17 Jul 2013 19:15:52 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id E05A03578055
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 19:31:14 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6H9V5AT2359796
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 19:31:05 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6H9VD0f028146
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 19:31:14 +1000
Date: Wed, 17 Jul 2013 05:31:11 -0400
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 8/9] mm, hugetlb: remove decrement_hugepage_resv_vma()
Message-ID: <20130717093111.GB27397@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1373881967-16153-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1373881967-16153-9-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1373881967-16153-9-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

On Mon, Jul 15, 2013 at 06:52:46PM +0900, Joonsoo Kim wrote:
>Now, Checking condition of decrement_hugepage_resv_vma() and
>vma_has_reserves() is same, so we can clean-up this function with
>vma_has_reserves(). Additionally, decrement_hugepage_resv_vma() has only
>one call site, so we can remove function and embed it into
>dequeue_huge_page_vma() directly. This patch implement it.
>
>Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>index f6a7a4e..ed2d0af 100644
>--- a/mm/hugetlb.c
>+++ b/mm/hugetlb.c
>@@ -434,25 +434,6 @@ static int is_vma_resv_set(struct vm_area_struct *vma, unsigned long flag)
> 	return (get_vma_private_data(vma) & flag) != 0;
> }
>
>-/* Decrement the reserved pages in the hugepage pool by one */
>-static void decrement_hugepage_resv_vma(struct hstate *h,
>-			struct vm_area_struct *vma)
>-{
>-	if (vma->vm_flags & VM_NORESERVE)
>-		return;
>-
>-	if (vma->vm_flags & VM_MAYSHARE) {
>-		/* Shared mappings always use reserves */
>-		h->resv_huge_pages--;
>-	} else if (is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
>-		/*
>-		 * Only the process that called mmap() has reserves for
>-		 * private mappings.
>-		 */
>-		h->resv_huge_pages--;
>-	}
>-}
>-
> /* Reset counters to 0 and clear all HPAGE_RESV_* flags */
> void reset_vma_resv_huge_pages(struct vm_area_struct *vma)
> {
>@@ -466,10 +447,18 @@ static int vma_has_reserves(struct vm_area_struct *vma)
> {
> 	if (vma->vm_flags & VM_NORESERVE)
> 		return 0;
>+
>+	/* Shared mappings always use reserves */
> 	if (vma->vm_flags & VM_MAYSHARE)
> 		return 1;
>+
>+	/*
>+	 * Only the process that called mmap() has reserves for
>+	 * private mappings.
>+	 */
> 	if (is_vma_resv_set(vma, HPAGE_RESV_OWNER))
> 		return 1;
>+
> 	return 0;
> }
>
>@@ -564,8 +553,8 @@ retry_cpuset:
> 		if (cpuset_zone_allowed_softwall(zone, htlb_alloc_mask)) {
> 			page = dequeue_huge_page_node(h, zone_to_nid(zone));
> 			if (page) {
>-				if (!avoid_reserve)
>-					decrement_hugepage_resv_vma(h, vma);
>+				if (!avoid_reserve && vma_has_reserves(vma))
>+					h->resv_huge_pages--;
> 				break;
> 			}
> 		}
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
