Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id D8B186B006E
	for <linux-mm@kvack.org>; Fri, 15 May 2015 05:15:04 -0400 (EDT)
Received: by wgbhc8 with SMTP id hc8so72238870wgb.3
        for <linux-mm@kvack.org>; Fri, 15 May 2015 02:15:04 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ei5si2631471wid.118.2015.05.15.02.15.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 15 May 2015 02:15:03 -0700 (PDT)
Message-ID: <5555B914.8050800@suse.cz>
Date: Fri, 15 May 2015 11:15:00 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCHv5 04/28] mm, thp: adjust conditions when we can reuse
 the page on WP fault
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com> <1429823043-157133-5-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1429823043-157133-5-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
> With new refcounting we will be able map the same compound page with
> PTEs and PMDs. It requires adjustment to conditions when we can reuse
> the page on write-protection fault.
>
> For PTE fault we can't reuse the page if it's part of huge page.
>
> For PMD we can only reuse the page if nobody else maps the huge page or
> it's part. We can do it by checking page_mapcount() on each sub-page,
> but it's expensive.
>
> The cheaper way is to check page_count() to be equal 1: every mapcount
> takes page reference, so this way we can guarantee, that the PMD is the
> only mapping.
>
> This approach can give false negative if somebody pinned the page, but
> that doesn't affect correctness.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

So couldn't the same trick be used in Patch 1 to avoid counting 
individual oder-0 pages?

> ---
>   include/linux/swap.h |  3 ++-
>   mm/huge_memory.c     | 12 +++++++++++-
>   mm/swapfile.c        |  3 +++
>   3 files changed, 16 insertions(+), 2 deletions(-)
>
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 0428e4c84e1d..17cdd6b9456b 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -524,7 +524,8 @@ static inline int page_swapcount(struct page *page)
>   	return 0;
>   }
>
> -#define reuse_swap_page(page)	(page_mapcount(page) == 1)
> +#define reuse_swap_page(page) \
> +	(!PageTransCompound(page) && page_mapcount(page) == 1)
>
>   static inline int try_to_free_swap(struct page *page)
>   {
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 534f353e12bf..fd8af5b9917f 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1103,7 +1103,17 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>
>   	page = pmd_page(orig_pmd);
>   	VM_BUG_ON_PAGE(!PageCompound(page) || !PageHead(page), page);
> -	if (page_mapcount(page) == 1) {
> +	/*
> +	 * We can only reuse the page if nobody else maps the huge page or it's
> +	 * part. We can do it by checking page_mapcount() on each sub-page, but
> +	 * it's expensive.
> +	 * The cheaper way is to check page_count() to be equal 1: every
> +	 * mapcount takes page reference reference, so this way we can
> +	 * guarantee, that the PMD is the only mapping.
> +	 * This can give false negative if somebody pinned the page, but that's
> +	 * fine.
> +	 */
> +	if (page_mapcount(page) == 1 && page_count(page) == 1) {
>   		pmd_t entry;
>   		entry = pmd_mkyoung(orig_pmd);
>   		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 6dd365d1c488..3cd5f188b996 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -887,6 +887,9 @@ int reuse_swap_page(struct page *page)
>   	VM_BUG_ON_PAGE(!PageLocked(page), page);
>   	if (unlikely(PageKsm(page)))
>   		return 0;
> +	/* The page is part of THP and cannot be reused */
> +	if (PageTransCompound(page))
> +		return 0;
>   	count = page_mapcount(page);
>   	if (count <= 1 && PageSwapCache(page)) {
>   		count += page_swapcount(page);
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
