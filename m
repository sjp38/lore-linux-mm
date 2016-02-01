Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 8257A6B0253
	for <linux-mm@kvack.org>; Mon,  1 Feb 2016 08:03:33 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id p63so69304741wmp.1
        for <linux-mm@kvack.org>; Mon, 01 Feb 2016 05:03:33 -0800 (PST)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id av4si39753101wjc.234.2016.02.01.05.03.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Feb 2016 05:03:32 -0800 (PST)
Received: by mail-wm0-x22b.google.com with SMTP id r129so69368496wmr.0
        for <linux-mm@kvack.org>; Mon, 01 Feb 2016 05:03:32 -0800 (PST)
Date: Mon, 1 Feb 2016 15:03:29 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: Fix(?) memory leak in copy_huge_pmd()
Message-ID: <20160201130328.GA29337@node.shutemov.name>
References: <1454242929-18164-1-git-send-email-matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1454242929-18164-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org

On Sun, Jan 31, 2016 at 11:22:09PM +1100, Matthew Wilcox wrote:
> We allocate a pgtable but do not attach it to anything if the PMD is in
> a DAX VMA, causing it to leak.
> 
> We certainly try to not free pgtables associated with the huge zero page
> if the zero page is in a DAX VMA, so I think this is the right solution.
> This needs to be properly audited.
> 
> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
> ---
>  mm/huge_memory.c | 17 ++++++++++-------
>  1 file changed, 10 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 4b9f2cb..1632e02 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -889,7 +889,8 @@ static bool set_huge_zero_page(pgtable_t pgtable, struct mm_struct *mm,
>  		return false;
>  	entry = mk_pmd(zero_page, vma->vm_page_prot);
>  	entry = pmd_mkhuge(entry);
> -	pgtable_trans_huge_deposit(mm, pmd, pgtable);
> +	if (pgtable)
> +		pgtable_trans_huge_deposit(mm, pmd, pgtable);
>  	set_pmd_at(mm, haddr, pmd, entry);
>  	atomic_long_inc(&mm->nr_ptes);
>  	return true;
> @@ -1176,13 +1177,15 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>  	spinlock_t *dst_ptl, *src_ptl;
>  	struct page *src_page;
>  	pmd_t pmd;
> -	pgtable_t pgtable;
> +	pgtable_t pgtable = NULL;
>  	int ret;
>  
> -	ret = -ENOMEM;
> -	pgtable = pte_alloc_one(dst_mm, addr);
> -	if (unlikely(!pgtable))
> -		goto out;
> +	if (!vma_is_dax(vma)) {
> +		ret = -ENOMEM;
> +		pgtable = pte_alloc_one(dst_mm, addr);
> +		if (unlikely(!pgtable))
> +			goto out;
> +	}
>  
>  	dst_ptl = pmd_lock(dst_mm, dst_pmd);
>  	src_ptl = pmd_lockptr(src_mm, src_pmd);
> @@ -1213,7 +1216,7 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>  		goto out_unlock;
>  	}
>  
> -	if (pmd_trans_huge(pmd)) {
> +	if (!vma_is_dax(vma)) {

Why? It looks equivalent in this situation, no?

Otherwise:

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

>  		/* thp accounting separate from pmd_devmap accounting */
>  		src_page = pmd_page(pmd);
>  		VM_BUG_ON_PAGE(!PageHead(src_page), src_page);
> -- 
> 2.7.0.rc3
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
