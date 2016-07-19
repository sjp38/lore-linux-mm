Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D590B6B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 07:59:54 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r190so12343563wmr.0
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 04:59:54 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f9si19677914wmg.96.2016.07.19.04.59.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Jul 2016 04:59:53 -0700 (PDT)
Date: Tue, 19 Jul 2016 13:59:53 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm/hugetlb: fix race when migrate pages.
Message-ID: <20160719115952.GI9486@dhcp22.suse.cz>
References: <1468897140-43471-1-git-send-email-zhongjiang@huawei.com>
 <20160719091724.GD9490@dhcp22.suse.cz>
 <578DF872.3050507@huawei.com>
 <20160719111003.GG9486@dhcp22.suse.cz>
 <578E126A.7080001@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <578E126A.7080001@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, qiuxishi@huawei.com, linux-mm@kvack.org

On Tue 19-07-16 19:43:38, zhong jiang wrote:
[...]
>   diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 6384dfd..baba196 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -4213,7 +4213,7 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
>         struct vm_area_struct *svma;
>         unsigned long saddr;
>         pte_t *spte = NULL;
> -       pte_t *pte;
> +       pte_t *pte, entry;
>         spinlock_t *ptl;
> 
>         if (!vma_shareable(vma, addr))
> @@ -4240,6 +4240,11 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
> 
>         ptl = huge_pte_lockptr(hstate_vma(vma), mm, spte);
>         spin_lock(ptl);
> +       entry = huge_ptep_get(spte);
> +       if (is_hugetlb_entry_migration(entry) ||
> +                       is_hugetlb_entry_hwpoisoned(entry)) {
> +               goto end;
> +       }
>         if (pud_none(*pud)) {
>                 pud_populate(mm, pud,
>                                 (pmd_t *)((unsigned long)spte & PAGE_MASK));
> @@ -4247,6 +4252,7 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
>                 put_page(virt_to_page(spte));
>                 mm_dec_nr_pmds(mm);
>         }
> +end:

out_unlock:

would be more readable. Could you retest the patch, respin the changelog
to explain what, why and how to fix it and repost again, please?

>         spin_unlock(ptl);
>  out:
>         pte = (pte_t *)pmd_alloc(mm, pud, addr);
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
