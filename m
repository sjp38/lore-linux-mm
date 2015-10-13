Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id E5EFE6B0253
	for <linux-mm@kvack.org>; Tue, 13 Oct 2015 03:28:45 -0400 (EDT)
Received: by lbbk10 with SMTP id k10so9301257lbb.0
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 00:28:45 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k1si1263871lbd.96.2015.10.13.00.28.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 Oct 2015 00:28:44 -0700 (PDT)
Subject: Re: [PATCH v2] thp: use is_zero_pfn only after pte_present check
References: <1444703918-16597-1-git-send-email-minchan@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <561CB297.9080600@suse.cz>
Date: Tue, 13 Oct 2015 09:28:23 +0200
MIME-Version: 1.0
In-Reply-To: <1444703918-16597-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 10/13/2015 04:38 AM, Minchan Kim wrote:
> Use is_zero_pfn on pteval only after pte_present check on pteval
> (It might be better idea to introduce is_zero_pte where checks
> pte_present first). Otherwise, it could work with swap or
> migration entry and if pte_pfn's result is equal to zero_pfn
> by chance, we lose user's data in __collapse_huge_page_copy.
> So if you're luck, the application is segfaulted and finally you
> could see below message when the application is exit.
>
> BUG: Bad rss-counter state mm:ffff88007f099300 idx:2 val:3
>
> Cc: <stable@vger.kernel.org>

More specific:
Cc: <stable@vger.kernel.org> # 4.1+
Fixes: ca0984caa823 ("mm: incorporate zero pages into transparent huge 
pages")

> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
> Hello Greg,
>
> This patch should go to -stable but when you will apply it
> after merging of linus tree, it will be surely conflicted due
> to userfaultfd part.
>
> I want to know how to handle it.
>
> Thanks.
>
>   mm/huge_memory.c | 3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 4b06b8db9df2..bbac913f96bc 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2206,7 +2206,8 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
>   	for (_pte = pte; _pte < pte+HPAGE_PMD_NR;
>   	     _pte++, address += PAGE_SIZE) {
>   		pte_t pteval = *_pte;
> -		if (pte_none(pteval) || is_zero_pfn(pte_pfn(pteval))) {
> +		if (pte_none(pteval) || (pte_present(pteval) &&
> +				is_zero_pfn(pte_pfn(pteval)))) {
>   			if (!userfaultfd_armed(vma) &&
>   			    ++none_or_zero <= khugepaged_max_ptes_none)
>   				continue;
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
