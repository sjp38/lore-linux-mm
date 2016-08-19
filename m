Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 170786B0038
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 09:14:52 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id f14so128105163ioj.2
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 06:14:52 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0105.outbound.protection.outlook.com. [104.47.0.105])
        by mx.google.com with ESMTPS id g3si3984366oia.8.2016.08.19.06.14.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 19 Aug 2016 06:14:50 -0700 (PDT)
Subject: Re: [PATCH 1/1] soft_dirty: fix soft_dirty during THP split
References: <1471610515-30229-1-git-send-email-aarcange@redhat.com>
 <1471610515-30229-2-git-send-email-aarcange@redhat.com>
From: Pavel Emelyanov <xemul@virtuozzo.com>
Message-ID: <57B706E6.70507@virtuozzo.com>
Date: Fri, 19 Aug 2016 16:17:26 +0300
MIME-Version: 1.0
In-Reply-To: <1471610515-30229-2-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

On 08/19/2016 03:41 PM, Andrea Arcangeli wrote:
> Transfer the soft_dirty from pmd to pte during THP splits.
> 
> This fix avoids losing the soft_dirty bit and avoids userland memory
> corruption in the checkpoint.

Nasty :( Thanks for catching this!

> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Pavel Emelyanov <xemul@virtuozzo.com>

> ---
>  mm/huge_memory.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index b9570b5..cb95a83 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1512,7 +1512,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>  	struct page *page;
>  	pgtable_t pgtable;
>  	pmd_t _pmd;
> -	bool young, write, dirty;
> +	bool young, write, dirty, soft_dirty;
>  	unsigned long addr;
>  	int i;
>  
> @@ -1546,6 +1546,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>  	write = pmd_write(*pmd);
>  	young = pmd_young(*pmd);
>  	dirty = pmd_dirty(*pmd);
> +	soft_dirty = pmd_soft_dirty(*pmd);
>  
>  	pmdp_huge_split_prepare(vma, haddr, pmd);
>  	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
> @@ -1562,6 +1563,8 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>  			swp_entry_t swp_entry;
>  			swp_entry = make_migration_entry(page + i, write);
>  			entry = swp_entry_to_pte(swp_entry);
> +			if (soft_dirty)
> +				entry = pte_swp_mksoft_dirty(entry);
>  		} else {
>  			entry = mk_pte(page + i, vma->vm_page_prot);
>  			entry = maybe_mkwrite(entry, vma);
> @@ -1569,6 +1572,8 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>  				entry = pte_wrprotect(entry);
>  			if (!young)
>  				entry = pte_mkold(entry);
> +			if (soft_dirty)
> +				entry = pte_mksoft_dirty(entry);
>  		}
>  		if (dirty)
>  			SetPageDirty(page + i);
> .
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
