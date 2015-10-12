Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 06E156B0254
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 06:13:23 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so44166522wic.1
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 03:13:22 -0700 (PDT)
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com. [209.85.212.175])
        by mx.google.com with ESMTPS id y2si14935687wib.45.2015.10.12.03.13.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Oct 2015 03:13:22 -0700 (PDT)
Received: by wicgb1 with SMTP id gb1so142702514wic.1
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 03:13:21 -0700 (PDT)
Date: Mon, 12 Oct 2015 13:13:20 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] thp: use is_zero_pfn after pte_present check
Message-ID: <20151012101320.GB2544@node>
References: <1444614856-18543-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1444614856-18543-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Oct 12, 2015 at 10:54:16AM +0900, Minchan Kim wrote:
> Use is_zero_pfn on pteval only after pte_present check on pteval
> (It might be better idea to introduce is_zero_pte where checks
> pte_present first). Otherwise, it could work with swap or
> migration entry and if pte_pfn's result is equal to zero_pfn
> by chance, we lose user's data in __collapse_huge_page_copy.
> So if you're luck, the application is segfaulted and finally you
> could see below message when the application is exit.
> 
> BUG: Bad rss-counter state mm:ffff88007f099300 idx:2 val:3

Did you acctually steped on the bug?
If yes it's subject for stable@, I think.

> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
> 
> I found this bug with MADV_FREE hard test. Sometime, I saw
> "Bad rss-counter" message with MM_SWAPENTS but it's really
> rare, once a day if I was luck or once in five days if I was
> unlucky so I am doing test still and just pass a few days but
> I hope it will fix the issue.
> 
>  mm/huge_memory.c | 12 +++++++++++-
>  1 file changed, 11 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 4b06b8db9df2..349590aa4533 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2665,15 +2665,25 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
>  	for (_address = address, _pte = pte; _pte < pte+HPAGE_PMD_NR;
>  	     _pte++, _address += PAGE_SIZE) {
>  		pte_t pteval = *_pte;
> -		if (pte_none(pteval) || is_zero_pfn(pte_pfn(pteval))) {
> +		if (pte_none(pteval)) {

In -mm tree we have is_swap_pte() check before this point in
khugepaged_scan_pmd()

Also, what about similar pattern in __collapse_huge_page_isolate() and
__collapse_huge_page_copy()? Shouldn't they be fixed as well?

>  			if (!userfaultfd_armed(vma) &&
>  			    ++none_or_zero <= khugepaged_max_ptes_none)
>  				continue;
>  			else
>  				goto out_unmap;
>  		}
> +
>  		if (!pte_present(pteval))
>  			goto out_unmap;
> +
> +		if (is_zero_pfn(pte_pfn(pteval))) {
> +			if (!userfaultfd_armed(vma) &&
> +			    ++none_or_zero <= khugepaged_max_ptes_none)
> +				continue;
> +			else
> +				goto out_unmap;
> +		}
> +
>  		if (pte_write(pteval))
>  			writable = true;
>  
> -- 
> 1.9.1
> 

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
