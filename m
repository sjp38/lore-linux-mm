From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 5/8] mbind: add hugepage migration code to mbind()
Date: Wed, 24 Jul 2013 11:43:13 +0800
Message-ID: <29311.1358107582$1374637415@news.gmane.org>
References: <1374183272-10153-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1374183272-10153-6-git-send-email-n-horiguchi@ah.jp.nec.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1V1pz2-0002OU-85
	for glkm-linux-mm-2@m.gmane.org; Wed, 24 Jul 2013 05:43:24 +0200
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id DA4AF6B0033
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 23:43:21 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 24 Jul 2013 09:06:11 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 902243940058
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 09:13:11 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6O3i9YG35782776
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 09:14:09 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6O3hE6o013440
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 03:43:14 GMT
Content-Disposition: inline
In-Reply-To: <1374183272-10153-6-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu, Jul 18, 2013 at 05:34:29PM -0400, Naoya Horiguchi wrote:
>This patch extends do_mbind() to handle vma with VM_HUGETLB set.
>We will be able to migrate hugepage with mbind(2) after
>applying the enablement patch which comes later in this series.
>
>ChangeLog v3:
> - revert introducing migrate_movable_pages
> - added alloc_huge_page_noerr free from ERR_VALUE
>
>ChangeLog v2:
> - updated description and renamed patch title
>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>---
> include/linux/hugetlb.h |  3 +++
> mm/hugetlb.c            | 14 ++++++++++++++
> mm/mempolicy.c          |  4 +++-
> 3 files changed, 20 insertions(+), 1 deletion(-)
>
>diff --git v3.11-rc1.orig/include/linux/hugetlb.h v3.11-rc1/include/linux/hugetlb.h
>index 0b7a9e7..768ebbe 100644
>--- v3.11-rc1.orig/include/linux/hugetlb.h
>+++ v3.11-rc1/include/linux/hugetlb.h
>@@ -267,6 +267,8 @@ struct huge_bootmem_page {
> };
>
> struct page *alloc_huge_page_node(struct hstate *h, int nid);
>+struct page *alloc_huge_page_noerr(struct vm_area_struct *vma,
>+				unsigned long addr, int avoid_reserve);
>
> /* arch callback */
> int __init alloc_bootmem_huge_page(struct hstate *h);
>@@ -380,6 +382,7 @@ static inline pgoff_t basepage_index(struct page *page)
> #else	/* CONFIG_HUGETLB_PAGE */
> struct hstate {};
> #define alloc_huge_page_node(h, nid) NULL
>+#define alloc_huge_page_noerr(v, a, r) NULL
> #define alloc_bootmem_huge_page(h) NULL
> #define hstate_file(f) NULL
> #define hstate_sizelog(s) NULL
>diff --git v3.11-rc1.orig/mm/hugetlb.c v3.11-rc1/mm/hugetlb.c
>index 4c48a70..fab29a1 100644
>--- v3.11-rc1.orig/mm/hugetlb.c
>+++ v3.11-rc1/mm/hugetlb.c
>@@ -1195,6 +1195,20 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
> 	return page;
> }
>
>+/*
>+ * alloc_huge_page()'s wrapper which simply returns the page if allocation
>+ * succeeds, otherwise NULL. This function is called from new_vma_page(),
>+ * where no ERR_VALUE is expected to be returned.
>+ */
>+struct page *alloc_huge_page_noerr(struct vm_area_struct *vma,
>+				unsigned long addr, int avoid_reserve)
>+{
>+	struct page *page = alloc_huge_page(vma, addr, avoid_reserve);
>+	if (IS_ERR(page))
>+		page = NULL;
>+	return page;
>+}
>+
> int __weak alloc_bootmem_huge_page(struct hstate *h)
> {
> 	struct huge_bootmem_page *m;
>diff --git v3.11-rc1.orig/mm/mempolicy.c v3.11-rc1/mm/mempolicy.c
>index f3b65c0..d8ced3e 100644
>--- v3.11-rc1.orig/mm/mempolicy.c
>+++ v3.11-rc1/mm/mempolicy.c
>@@ -1180,6 +1180,8 @@ static struct page *new_vma_page(struct page *page, unsigned long private, int *
> 		vma = vma->vm_next;
> 	}
>
>+	if (PageHuge(page))
>+		return alloc_huge_page_noerr(vma, address, 1);
> 	/*
> 	 * if !vma, alloc_page_vma() will use task or system default policy
> 	 */
>@@ -1290,7 +1292,7 @@ static long do_mbind(unsigned long start, unsigned long len,
> 					(unsigned long)vma,
> 					MIGRATE_SYNC, MR_MEMPOLICY_MBIND);
> 			if (nr_failed)
>-				putback_lru_pages(&pagelist);
>+				putback_movable_pages(&pagelist);
> 		}
>
> 		if (nr_failed && (flags & MPOL_MF_STRICT))
>-- 
>1.8.3.1
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
