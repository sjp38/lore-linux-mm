Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 160E26B006C
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 08:29:23 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so14943893wib.1
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 05:29:22 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ba3si11123248wjc.86.2015.06.09.05.29.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Jun 2015 05:29:21 -0700 (PDT)
Message-ID: <5576DC1D.6010800@suse.cz>
Date: Tue, 09 Jun 2015 14:29:17 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCHv6 01/36] mm, proc: adjust PSS calculation
References: <1433351167-125878-1-git-send-email-kirill.shutemov@linux.intel.com> <1433351167-125878-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1433351167-125878-2-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/03/2015 07:05 PM, Kirill A. Shutemov wrote:
> With new refcounting all subpages of the compound page are not nessessary
> have the same mapcount. We need to take into account mapcount of every
> sub-page.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>
> Acked-by: Jerome Marchand <jmarchan@redhat.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>   fs/proc/task_mmu.c | 48 +++++++++++++++++++++++++++++++-----------------
>   1 file changed, 31 insertions(+), 17 deletions(-)
>
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 58be92e11939..f9b285761bc0 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -449,9 +449,10 @@ struct mem_size_stats {
>   };
>
>   static void smaps_account(struct mem_size_stats *mss, struct page *page,
> -		unsigned long size, bool young, bool dirty)
> +		bool compound, bool young, bool dirty)
>   {
> -	int mapcount;
> +	int i, nr = compound ? HPAGE_PMD_NR : 1;
> +	unsigned long size = nr * PAGE_SIZE;
>
>   	if (PageAnon(page))
>   		mss->anonymous += size;
> @@ -460,23 +461,36 @@ static void smaps_account(struct mem_size_stats *mss, struct page *page,
>   	/* Accumulate the size in pages that have been accessed. */
>   	if (young || PageReferenced(page))
>   		mss->referenced += size;
> -	mapcount = page_mapcount(page);
> -	if (mapcount >= 2) {
> -		u64 pss_delta;
>
> -		if (dirty || PageDirty(page))
> -			mss->shared_dirty += size;
> -		else
> -			mss->shared_clean += size;
> -		pss_delta = (u64)size << PSS_SHIFT;
> -		do_div(pss_delta, mapcount);
> -		mss->pss += pss_delta;
> -	} else {
> +	/*
> +	 * page_count(page) == 1 guarantees the page is mapped exactly once.
> +	 * If any subpage of the compound page mapped with PTE it would elevate
> +	 * page_count().
> +	 */
> +	if (page_count(page) == 1) {
>   		if (dirty || PageDirty(page))
>   			mss->private_dirty += size;
>   		else
>   			mss->private_clean += size;
> -		mss->pss += (u64)size << PSS_SHIFT;

Deleting the line above was a mistake, right?

> +		return;
> +	}
> +
> +	for (i = 0; i < nr; i++, page++) {
> +		int mapcount = page_mapcount(page);
> +
> +		if (mapcount >= 2) {
> +			if (dirty || PageDirty(page))
> +				mss->shared_dirty += PAGE_SIZE;
> +			else
> +				mss->shared_clean += PAGE_SIZE;
> +			mss->pss += (PAGE_SIZE << PSS_SHIFT) / mapcount;
> +		} else {
> +			if (dirty || PageDirty(page))
> +				mss->private_dirty += PAGE_SIZE;
> +			else
> +				mss->private_clean += PAGE_SIZE;
> +			mss->pss += PAGE_SIZE << PSS_SHIFT;
> +		}
>   	}
>   }
>
> @@ -500,7 +514,8 @@ static void smaps_pte_entry(pte_t *pte, unsigned long addr,
>
>   	if (!page)
>   		return;
> -	smaps_account(mss, page, PAGE_SIZE, pte_young(*pte), pte_dirty(*pte));
> +
> +	smaps_account(mss, page, false, pte_young(*pte), pte_dirty(*pte));
>   }
>
>   #ifdef CONFIG_TRANSPARENT_HUGEPAGE
> @@ -516,8 +531,7 @@ static void smaps_pmd_entry(pmd_t *pmd, unsigned long addr,
>   	if (IS_ERR_OR_NULL(page))
>   		return;
>   	mss->anonymous_thp += HPAGE_PMD_SIZE;
> -	smaps_account(mss, page, HPAGE_PMD_SIZE,
> -			pmd_young(*pmd), pmd_dirty(*pmd));
> +	smaps_account(mss, page, true, pmd_young(*pmd), pmd_dirty(*pmd));
>   }
>   #else
>   static void smaps_pmd_entry(pmd_t *pmd, unsigned long addr,
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
