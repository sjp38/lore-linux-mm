Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id EE1266B0253
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 09:00:02 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id k184so42177570wme.3
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 06:00:02 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id vu6si11976104wjb.28.2016.06.17.06.00.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 06:00:01 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id 187so16566529wmz.1
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 06:00:01 -0700 (PDT)
Date: Fri, 17 Jun 2016 15:00:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: fix account pmd page to the process
Message-ID: <20160617125959.GH21670@dhcp22.suse.cz>
References: <1466076971-24609-1-git-send-email-zhongjiang@huawei.com>
 <20160616154214.GA12284@dhcp22.suse.cz>
 <20160616154324.GN6836@dhcp22.suse.cz>
 <71df66ac-df29-9542-bfa9-7c94f374df5b@oracle.com>
 <20160616163119.GP6836@dhcp22.suse.cz>
 <bf76cc6c-a0da-98f9-4a89-0bb6161f5adf@oracle.com>
 <20160617122506.GC6534@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160617122506.GC6534@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, zhongjiang <zhongjiang@huawei.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 17-06-16 15:25:06, Kirill A. Shutemov wrote:
[...]
> >From fd22922e7b4664e83653a84331f0a95b985bff0c Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Fri, 17 Jun 2016 15:07:03 +0300
> Subject: [PATCH] hugetlb: fix nr_pmds accounting with shared page tables
> 
> We account HugeTLB's shared page table to all processes who share it.
> The accounting happens during huge_pmd_share().
> 
> If somebody populates pud entry under us, we should decrease pagetable's
> refcount and decrease nr_pmds of the process.
> 
> By mistake, I increase nr_pmds again in this case. :-/
> It will lead to "BUG: non-zero nr_pmds on freeing mm: 2" on process'
> exit.
> 
> Let's fix this by increasing nr_pmds only when we're sure that the page
> table will be used.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: zhongjiang <zhongjiang@huawei.com>
> Fixes: dc6c9a35b66b ("mm: account pmd page tables to the process")
> Cc: <stable@vger.kernel.org>        [4.0+]

Yes this patch is better. Is it worth backporting to stable though?
BUG message sounds scary but it is not a real BUG().

Acked-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/hugetlb.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index e197cd7080e6..ed6a537f0878 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -4216,7 +4216,6 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
>  		if (saddr) {
>  			spte = huge_pte_offset(svma->vm_mm, saddr);
>  			if (spte) {
> -				mm_inc_nr_pmds(mm);
>  				get_page(virt_to_page(spte));
>  				break;
>  			}
> @@ -4231,9 +4230,9 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
>  	if (pud_none(*pud)) {
>  		pud_populate(mm, pud,
>  				(pmd_t *)((unsigned long)spte & PAGE_MASK));
> +		mm_inc_nr_pmds(mm);
>  	} else {
>  		put_page(virt_to_page(spte));
> -		mm_inc_nr_pmds(mm);
>  	}
>  	spin_unlock(ptl);
>  out:
> -- 
>  Kirill A. Shutemov

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
