Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 7344D6B006E
	for <linux-mm@kvack.org>; Fri, 15 May 2015 08:59:16 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so61306380wic.0
        for <linux-mm@kvack.org>; Fri, 15 May 2015 05:59:16 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y14si3604438wiv.47.2015.05.15.05.59.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 15 May 2015 05:59:15 -0700 (PDT)
Message-ID: <5555EDA1.60202@suse.cz>
Date: Fri, 15 May 2015 14:59:13 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCHv5 08/28] khugepaged: ignore pmd tables with THP mapped
 with ptes
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com> <1429823043-157133-9-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1429823043-157133-9-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
> Prepare khugepaged to see compound pages mapped with pte. For now we
> won't collapse the pmd table with such pte.
>
> khugepaged is subject for future rework wrt new refcounting.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   mm/huge_memory.c | 6 +++++-
>   1 file changed, 5 insertions(+), 1 deletion(-)
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index fa3d4f78b716..ffc30e4462c1 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2653,6 +2653,11 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
>   		page = vm_normal_page(vma, _address, pteval);
>   		if (unlikely(!page))
>   			goto out_unmap;
> +
> +		/* TODO: teach khugepaged to collapse THP mapped with pte */
> +		if (PageCompound(page))
> +			goto out_unmap;
> +
>   		/*
>   		 * Record which node the original page is from and save this
>   		 * information to khugepaged_node_load[].
> @@ -2663,7 +2668,6 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
>   		if (khugepaged_scan_abort(node))
>   			goto out_unmap;
>   		khugepaged_node_load[node]++;
> -		VM_BUG_ON_PAGE(PageCompound(page), page);
>   		if (!PageLRU(page) || PageLocked(page) || !PageAnon(page))
>   			goto out_unmap;
>   		/*
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
