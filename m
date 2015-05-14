Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 43E586B006E
	for <linux-mm@kvack.org>; Thu, 14 May 2015 10:12:35 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so18421280wic.0
        for <linux-mm@kvack.org>; Thu, 14 May 2015 07:12:34 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id es2si14553165wib.45.2015.05.14.07.12.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 14 May 2015 07:12:33 -0700 (PDT)
Message-ID: <5554AD4D.9040000@suse.cz>
Date: Thu, 14 May 2015 16:12:29 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCHv5 01/28] mm, proc: adjust PSS calculation
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com> <1429823043-157133-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1429823043-157133-2-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
> With new refcounting all subpages of the compound page are not nessessary
> have the same mapcount. We need to take into account mapcount of every
> sub-page.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

(some nitpicks below)

> ---
>   fs/proc/task_mmu.c | 43 ++++++++++++++++++++++---------------------
>   1 file changed, 22 insertions(+), 21 deletions(-)
>
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 956b75d61809..95bc384ee3f7 100644
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
> +	int i, nr = compound ? hpage_nr_pages(page) : 1;

Why not just HPAGE_PMD_NR instead of hpage_nr_pages(page)? We already 
came here through a pmd mapping. Even if the page stopped being a 
hugepage meanwhile (I'm not sure if any locking prevents that or not?), 
it would be more accurate to continue assuming it's a hugepage, 
otherwise we account only the base page (formerly head) and skip the 511 
formerly tail pages?

Also, is there some shortcut way to tell us that we are the only one 
mapping the whole compound page, and nobody has any base pages, so we 
don't need to loop on each tail page? I guess not under the new design, 
right...

> +	unsigned long size = nr * PAGE_SIZE;
>
>   	if (PageAnon(page))
>   		mss->anonymous += size;
> @@ -460,23 +461,23 @@ static void smaps_account(struct mem_size_stats *mss, struct page *page,
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
> -		if (dirty || PageDirty(page))
> -			mss->private_dirty += size;
> -		else
> -			mss->private_clean += size;
> -		mss->pss += (u64)size << PSS_SHIFT;
> +	for (i = 0; i < nr; i++) {
> +		int mapcount = page_mapcount(page + i);
> +
> +		if (mapcount >= 2) {
> +			if (dirty || PageDirty(page + i))
> +				mss->shared_dirty += PAGE_SIZE;
> +			else
> +				mss->shared_clean += PAGE_SIZE;
> +			mss->pss += (PAGE_SIZE << PSS_SHIFT) / mapcount;
> +		} else {
> +			if (dirty || PageDirty(page + i))
> +				mss->private_dirty += PAGE_SIZE;
> +			else
> +				mss->private_clean += PAGE_SIZE;
> +			mss->pss += PAGE_SIZE << PSS_SHIFT;
> +		}

That's 3 instances of "page + i", why not just use page and do a page++ 
in the for loop?

>   	}
>   }
>
> @@ -500,7 +501,8 @@ static void smaps_pte_entry(pte_t *pte, unsigned long addr,
>
>   	if (!page)
>   		return;
> -	smaps_account(mss, page, PAGE_SIZE, pte_young(*pte), pte_dirty(*pte));
> +
> +	smaps_account(mss, page, false, pte_young(*pte), pte_dirty(*pte));
>   }
>
>   #ifdef CONFIG_TRANSPARENT_HUGEPAGE
> @@ -516,8 +518,7 @@ static void smaps_pmd_entry(pmd_t *pmd, unsigned long addr,
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
