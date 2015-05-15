Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 1A86F6B0032
	for <linux-mm@kvack.org>; Fri, 15 May 2015 09:10:24 -0400 (EDT)
Received: by wicnf17 with SMTP id nf17so136507322wic.1
        for <linux-mm@kvack.org>; Fri, 15 May 2015 06:10:23 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w4si2743459wjx.25.2015.05.15.06.10.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 15 May 2015 06:10:22 -0700 (PDT)
Message-ID: <5555F03D.3010309@suse.cz>
Date: Fri, 15 May 2015 15:10:21 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCHv5 10/28] mm, vmstats: new THP splitting event
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com> <1429823043-157133-11-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1429823043-157133-11-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
> The patch replaces THP_SPLIT with tree events: THP_SPLIT_PAGE,
> THP_SPLIT_PAGE_FAILT and THP_SPLIT_PMD. It reflects the fact that we
> are going to be able split PMD without the compound page and that
> split_huge_page() can fail.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Acked-by: Christoph Lameter <cl@linux.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   include/linux/vm_event_item.h | 4 +++-
>   mm/huge_memory.c              | 2 +-
>   mm/vmstat.c                   | 4 +++-
>   3 files changed, 7 insertions(+), 3 deletions(-)
>
> diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
> index 2b1cef88b827..3261bfe2156a 100644
> --- a/include/linux/vm_event_item.h
> +++ b/include/linux/vm_event_item.h
> @@ -69,7 +69,9 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
>   		THP_FAULT_FALLBACK,
>   		THP_COLLAPSE_ALLOC,
>   		THP_COLLAPSE_ALLOC_FAILED,
> -		THP_SPLIT,
> +		THP_SPLIT_PAGE,
> +		THP_SPLIT_PAGE_FAILED,
> +		THP_SPLIT_PMD,
>   		THP_ZERO_PAGE_ALLOC,
>   		THP_ZERO_PAGE_ALLOC_FAILED,
>   #endif
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index ccbfacf07160..be6d0e0f5050 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1961,7 +1961,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>
>   	BUG_ON(!PageSwapBacked(page));
>   	__split_huge_page(page, anon_vma, list);
> -	count_vm_event(THP_SPLIT);
> +	count_vm_event(THP_SPLIT_PAGE);
>
>   	BUG_ON(PageCompound(page));
>   out_unlock:
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 1fd0886a389f..e1c87425fe11 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -821,7 +821,9 @@ const char * const vmstat_text[] = {
>   	"thp_fault_fallback",
>   	"thp_collapse_alloc",
>   	"thp_collapse_alloc_failed",
> -	"thp_split",
> +	"thp_split_page",
> +	"thp_split_page_failed",
> +	"thp_split_pmd",
>   	"thp_zero_page_alloc",
>   	"thp_zero_page_alloc_failed",
>   #endif
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
