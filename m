Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2EFE56B0069
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 07:27:31 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 144so102538159pfv.5
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 04:27:31 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id e11si15890134plj.306.2016.11.25.04.27.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Nov 2016 04:27:30 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAPCP2B1017551
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 07:27:29 -0500
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26xn9ar4dq-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 07:27:29 -0500
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 25 Nov 2016 22:27:27 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 0E3452BB005A
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 23:27:25 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAPCRPBo50593962
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 23:27:25 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAPCRO3L018736
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 23:27:24 +1100
Subject: Re: [PATCH v2 10/12] mm: mempolicy: mbind and migrate_pages support
 thp migration
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1478561517-4317-11-git-send-email-n-horiguchi@ah.jp.nec.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 25 Nov 2016 17:57:20 +0530
MIME-Version: 1.0
In-Reply-To: <1478561517-4317-11-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <58382E28.9060706@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On 11/08/2016 05:01 AM, Naoya Horiguchi wrote:
> This patch enables thp migration for mbind(2) and migrate_pages(2).
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
> ChangeLog v1 -> v2:
> - support pte-mapped and doubly-mapped thp
> ---
>  mm/mempolicy.c | 108 +++++++++++++++++++++++++++++++++++++++++----------------
>  1 file changed, 79 insertions(+), 29 deletions(-)
> 
> diff --git v4.9-rc2-mmotm-2016-10-27-18-27/mm/mempolicy.c v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/mempolicy.c
> index 77d0668..96507ee 100644
> --- v4.9-rc2-mmotm-2016-10-27-18-27/mm/mempolicy.c
> +++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/mempolicy.c
> @@ -94,6 +94,7 @@
>  #include <linux/mm_inline.h>
>  #include <linux/mmu_notifier.h>
>  #include <linux/printk.h>
> +#include <linux/swapops.h>
>  
>  #include <asm/tlbflush.h>
>  #include <asm/uaccess.h>
> @@ -486,6 +487,49 @@ static inline bool queue_pages_node_check(struct page *page,
>  	return node_isset(nid, *qp->nmask) == !!(flags & MPOL_MF_INVERT);
>  }
>  
> +static int queue_pages_pmd(pmd_t *pmd, spinlock_t *ptl, unsigned long addr,
> +				unsigned long end, struct mm_walk *walk)
> +{
> +	int ret = 0;
> +	struct page *page;
> +	struct queue_pages *qp = walk->private;
> +	unsigned long flags;
> +
> +	if (unlikely(is_pmd_migration_entry(*pmd))) {
> +		ret = 1;
> +		goto unlock;
> +	}
> +	page = pmd_page(*pmd);
> +	if (is_huge_zero_page(page)) {
> +		spin_unlock(ptl);
> +		__split_huge_pmd(walk->vma, pmd, addr, false, NULL);
> +		goto out;
> +	}
> +	if (!thp_migration_supported()) {
> +		get_page(page);
> +		spin_unlock(ptl);
> +		lock_page(page);
> +		ret = split_huge_page(page);
> +		unlock_page(page);
> +		put_page(page);
> +		goto out;
> +	}
> +	if (queue_pages_node_check(page, qp)) {
> +		ret = 1;
> +		goto unlock;
> +	}
> +
> +	ret = 1;
> +	flags = qp->flags;
> +	/* go to thp migration */
> +	if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
> +		migrate_page_add(page, qp->pagelist, flags);
> +unlock:
> +	spin_unlock(ptl);
> +out:
> +	return ret;
> +}
> +
>  /*
>   * Scan through pages checking if pages follow certain conditions,
>   * and move them to the pagelist if they do.
> @@ -497,30 +541,15 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
>  	struct page *page;
>  	struct queue_pages *qp = walk->private;
>  	unsigned long flags = qp->flags;
> -	int nid, ret;
> +	int ret;
>  	pte_t *pte;
>  	spinlock_t *ptl;
>  
> -	if (pmd_trans_huge(*pmd)) {
> -		ptl = pmd_lock(walk->mm, pmd);
> -		if (pmd_trans_huge(*pmd)) {
> -			page = pmd_page(*pmd);
> -			if (is_huge_zero_page(page)) {
> -				spin_unlock(ptl);
> -				__split_huge_pmd(vma, pmd, addr, false, NULL);
> -			} else {
> -				get_page(page);
> -				spin_unlock(ptl);
> -				lock_page(page);
> -				ret = split_huge_page(page);
> -				unlock_page(page);
> -				put_page(page);
> -				if (ret)
> -					return 0;
> -			}
> -		} else {
> -			spin_unlock(ptl);
> -		}
> +	ptl = pmd_trans_huge_lock(pmd, vma);
> +	if (ptl) {
> +		ret = queue_pages_pmd(pmd, ptl, addr, end, walk);
> +		if (ret)
> +			return 0;
>  	}

I wonder if we should introduce pte_entry function along with pmd_entry
function as we are first looking for trans huge PMDs either for direct
addition into the migration list or splitting it before looking for PTEs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
