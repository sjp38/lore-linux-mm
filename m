Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 849BC6B0253
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 03:39:02 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id p129so26097897wmp.3
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 00:39:02 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a203si2878059wme.4.2016.07.20.00.39.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Jul 2016 00:39:01 -0700 (PDT)
Date: Wed, 20 Jul 2016 09:38:59 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] mm/hugetlb: fix race when migrate pages
Message-ID: <20160720073859.GE11249@dhcp22.suse.cz>
References: <1468935958-21810-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1468935958-21810-1-git-send-email-zhongjiang@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>
Cc: vbabka@suse.cz, qiuxishi@huawei.com, akpm@linux-foundation.org, linux-mm@kvack.org, Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

[CC Mike and Naoya]
On Tue 19-07-16 21:45:58, zhongjiang wrote:
> From: zhong jiang <zhongjiang@huawei.com>
> 
> I hit the following code in huge_pte_alloc when run the database and
> online-offline memory in the system.
> 
> BUG_ON(pte && !pte_none(*pte) && !pte_huge(*pte));
> 
> when pmd share function enable, we may be obtain a shared pmd entry.
> due to ongoing offline memory , the pmd entry points to the page will
> turn into migrate condition. therefore, the bug will come up.
> 
> The patch fix it by checking the pmd entry when we obtain the lock.
> if the shared pmd entry points to page is under migration. we should
> allocate a new pmd entry.

I am still not 100% sure this is correct. Does huge_pte_lockptr work
properly for the migration swapentry? If yes and we populate the pud
with a migration entry then is it really bad/harmful (other than hitting
the BUG_ON which might be update to handle that case)? This might be a
stupid question, sorry about that, but I have really problem to grasp
the whole issue properly and the changelog didn't help me much. I would
really appreciate some clarification here. The pmd sharing code is clear
as mud and adding new tweaks there doesn't sound like it would make it
more clear.

Also is the hwpoison check really needed?

> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> ---
>  mm/hugetlb.c | 9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 6384dfd..797db55 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -4213,7 +4213,7 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
>  	struct vm_area_struct *svma;
>  	unsigned long saddr;
>  	pte_t *spte = NULL;
> -	pte_t *pte;
> +	pte_t *pte, entry;
>  	spinlock_t *ptl;
>  
>  	if (!vma_shareable(vma, addr))
> @@ -4240,6 +4240,11 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
>  
>  	ptl = huge_pte_lockptr(hstate_vma(vma), mm, spte);
>  	spin_lock(ptl);
> +	entry = huge_ptep_get(spte);
> +	if (is_hugetlb_entry_migration(entry) ||
> +			is_hugetlb_entry_hwpoisoned(entry)) {
> +		goto out_unlock;
> +	}
>  	if (pud_none(*pud)) {
>  		pud_populate(mm, pud,
>  				(pmd_t *)((unsigned long)spte & PAGE_MASK));
> @@ -4247,6 +4252,8 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
>  		put_page(virt_to_page(spte));
>  		mm_dec_nr_pmds(mm);
>  	}
> +
> +out_unlock:
>  	spin_unlock(ptl);
>  out:
>  	pte = (pte_t *)pmd_alloc(mm, pud, addr);
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
