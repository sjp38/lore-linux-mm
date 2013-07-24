From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 04/10] mm, hugetlb: clean-up alloc_huge_page()
Date: Wed, 24 Jul 2013 09:09:16 +0800
Message-ID: <38810.0505494096$1374628176@news.gmane.org>
References: <1374482191-3500-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1374482191-3500-5-git-send-email-iamjoonsoo.kim@lge.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1V1na2-0004SN-4C
	for glkm-linux-mm-2@m.gmane.org; Wed, 24 Jul 2013 03:09:26 +0200
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 83E8D6B0031
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 21:09:23 -0400 (EDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 24 Jul 2013 06:34:06 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id AF022E0055
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 06:39:18 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6O19EI340566842
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 06:39:14 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6O19HU0024151
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 11:09:17 +1000
Content-Disposition: inline
In-Reply-To: <1374482191-3500-5-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, Jul 22, 2013 at 05:36:25PM +0900, Joonsoo Kim wrote:
>We can unify some codes for succeed allocation.
>This makes code more readable.
>There is no functional difference.
>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
>diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>index d21a33a..83edd17 100644
>--- a/mm/hugetlb.c
>+++ b/mm/hugetlb.c
>@@ -1146,12 +1146,7 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
> 	}
> 	spin_lock(&hugetlb_lock);
> 	page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve);
>-	if (page) {
>-		/* update page cgroup details */
>-		hugetlb_cgroup_commit_charge(idx, pages_per_huge_page(h),
>-					     h_cg, page);
>-		spin_unlock(&hugetlb_lock);
>-	} else {
>+	if (!page) {
> 		spin_unlock(&hugetlb_lock);
> 		page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
> 		if (!page) {
>@@ -1162,11 +1157,11 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
> 			return ERR_PTR(-ENOSPC);
> 		}
> 		spin_lock(&hugetlb_lock);
>-		hugetlb_cgroup_commit_charge(idx, pages_per_huge_page(h),
>-					     h_cg, page);
> 		list_move(&page->lru, &h->hugepage_activelist);
>-		spin_unlock(&hugetlb_lock);
>+		/* Fall through */
> 	}
>+	hugetlb_cgroup_commit_charge(idx, pages_per_huge_page(h), h_cg, page);
>+	spin_unlock(&hugetlb_lock);
>
> 	set_page_private(page, (unsigned long)spool);
>
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
