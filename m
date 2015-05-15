Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 289816B006E
	for <linux-mm@kvack.org>; Fri, 15 May 2015 08:46:52 -0400 (EDT)
Received: by wicnf17 with SMTP id nf17so135695708wic.1
        for <linux-mm@kvack.org>; Fri, 15 May 2015 05:46:51 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id on6si3582955wic.8.2015.05.15.05.46.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 15 May 2015 05:46:50 -0700 (PDT)
Message-ID: <5555EAB8.5060401@suse.cz>
Date: Fri, 15 May 2015 14:46:48 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCHv5 06/28] mm: handle PTE-mapped tail pages in gerneric
 fast gup implementaiton
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com> <1429823043-157133-7-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1429823043-157133-7-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
> With new refcounting we are going to see THP tail pages mapped with PTE.
> Generic fast GUP rely on page_cache_get_speculative() to obtain
> reference on page. page_cache_get_speculative() always fails on tail
> pages, because ->_count on tail pages is always zero.
>
> Let's handle tail pages in gup_pte_range().
>
> New split_huge_page() will rely on migration entries to freeze page's
> counts. Recheck PTE value after page_cache_get_speculative() on head
> page should be enough to serialize against split.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   mm/gup.c | 8 +++++---
>   1 file changed, 5 insertions(+), 3 deletions(-)
>
> diff --git a/mm/gup.c b/mm/gup.c
> index ebdb39b3e820..eaeeae15006b 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -1051,7 +1051,7 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
>   		 * for an example see gup_get_pte in arch/x86/mm/gup.c
>   		 */
>   		pte_t pte = READ_ONCE(*ptep);
> -		struct page *page;
> +		struct page *head, *page;
>
>   		/*
>   		 * Similar to the PMD case below, NUMA hinting must take slow
> @@ -1063,15 +1063,17 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
>
>   		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
>   		page = pte_page(pte);
> +		head = compound_head(page);
>
> -		if (!page_cache_get_speculative(page))
> +		if (!page_cache_get_speculative(head))
>   			goto pte_unmap;
>
>   		if (unlikely(pte_val(pte) != pte_val(*ptep))) {
> -			put_page(page);
> +			put_page(head);
>   			goto pte_unmap;
>   		}
>
> +		VM_BUG_ON_PAGE(compound_head(page) != head, page);
>   		pages[*nr] = page;
>   		(*nr)++;
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
