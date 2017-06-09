Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id C4AAD6B0279
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 14:13:17 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id m57so25802383qta.9
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 11:13:17 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e19sor1046563qkj.4.2017.06.09.11.13.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Jun 2017 11:13:16 -0700 (PDT)
Subject: Re: [PATCH v5] mm: huge-vmap: fail gracefully on unexpected huge vmap
 mappings
References: <20170609082226.26152-1-ard.biesheuvel@linaro.org>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <d58379fe-9e18-8e58-0f77-24d09a02fc05@redhat.com>
Date: Fri, 9 Jun 2017 11:13:12 -0700
MIME-Version: 1.0
In-Reply-To: <20170609082226.26152-1-ard.biesheuvel@linaro.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mhocko@suse.com, zhongjiang@huawei.com, mark.rutland@arm.com, linux-arm-kernel@lists.infradead.org, dave.hansen@intel.com

On 06/09/2017 01:22 AM, Ard Biesheuvel wrote:
> Existing code that uses vmalloc_to_page() may assume that any
> address for which is_vmalloc_addr() returns true may be passed
> into vmalloc_to_page() to retrieve the associated struct page.
> 
> This is not un unreasonable assumption to make, but on architectures
> that have CONFIG_HAVE_ARCH_HUGE_VMAP=y, it no longer holds, and we
> need to ensure that vmalloc_to_page() does not go off into the weeds
> trying to dereference huge PUDs or PMDs as table entries.
> 
> Given that vmalloc() and vmap() themselves never create huge
> mappings or deal with compound pages at all, there is no correct
> answer in this case, so return NULL instead, and issue a warning.
> 
> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>

Reviewed-by: Laura Abbott <labbott@redhat.com>

> ---
> v5: - fix typo
> 
> v4: - use pud_bad/pmd_bad instead of pud_huge/pmd_huge, which don't require
>       changes to hugetlb.h, and give us what we need on all architectures
>     - move WARN_ON_ONCE() calls out of conditionals
>     - add explanatory comment
> 
>  mm/vmalloc.c | 15 +++++++++++++--
>  1 file changed, 13 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 34a1c3e46ed7..0fcd371266a4 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -287,10 +287,21 @@ struct page *vmalloc_to_page(const void *vmalloc_addr)
>  	if (p4d_none(*p4d))
>  		return NULL;
>  	pud = pud_offset(p4d, addr);
> -	if (pud_none(*pud))
> +
> +	/*
> +	 * Don't dereference bad PUD or PMD (below) entries. This will also
> +	 * identify huge mappings, which we may encounter on architectures
> +	 * that define CONFIG_HAVE_ARCH_HUGE_VMAP=y. Such regions will be
> +	 * identified as vmalloc addresses by is_vmalloc_addr(), but are
> +	 * not [unambiguously] associated with a struct page, so there is
> +	 * no correct value to return for them.
> +	 */
> +	WARN_ON_ONCE(pud_bad(*pud));
> +	if (pud_none(*pud) || pud_bad(*pud))
>  		return NULL;
>  	pmd = pmd_offset(pud, addr);
> -	if (pmd_none(*pmd))
> +	WARN_ON_ONCE(pmd_bad(*pmd));
> +	if (pmd_none(*pmd) || pmd_bad(*pmd))
>  		return NULL;
>  
>  	ptep = pte_offset_map(pmd, addr);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
