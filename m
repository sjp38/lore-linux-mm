Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 44B116B0032
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 05:27:25 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so4347733wib.1
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 02:27:24 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pl7si792690wic.103.2015.06.11.02.27.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 11 Jun 2015 02:27:23 -0700 (PDT)
Message-ID: <55795477.90808@suse.cz>
Date: Thu, 11 Jun 2015 11:27:19 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCHv6 33/36] migrate_pages: try to split pages on qeueuing
References: <1433351167-125878-1-git-send-email-kirill.shutemov@linux.intel.com> <1433351167-125878-34-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1433351167-125878-34-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/03/2015 07:06 PM, Kirill A. Shutemov wrote:
> We are not able to migrate THPs. It means it's not enough to split only
> PMD on migration -- we need to split compound page under it too.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>   mm/mempolicy.c | 37 +++++++++++++++++++++++++++++++++----
>   1 file changed, 33 insertions(+), 4 deletions(-)
>
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 528f6c467cf1..0b1499c2f890 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -489,14 +489,31 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
>   	struct page *page;
>   	struct queue_pages *qp = walk->private;
>   	unsigned long flags = qp->flags;
> -	int nid;
> +	int nid, ret;
>   	pte_t *pte;
>   	spinlock_t *ptl;
>
> -	split_huge_pmd(vma, pmd, addr);
> -	if (pmd_trans_unstable(pmd))
> -		return 0;
> +	if (pmd_trans_huge(*pmd)) {
> +		ptl = pmd_lock(walk->mm, pmd);
> +		if (pmd_trans_huge(*pmd)) {
> +			page = pmd_page(*pmd);
> +			if (is_huge_zero_page(page)) {
> +				spin_unlock(ptl);
> +				split_huge_pmd(vma, pmd, addr);
> +			} else {
> +				get_page(page);
> +				spin_unlock(ptl);
> +				lock_page(page);
> +				ret = split_huge_page(page);
> +				unlock_page(page);
> +				put_page(page);
> +				if (ret)
> +					return 0;
> +			}
> +		}
> +	}
>
> +retry:
>   	pte = pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
>   	for (; addr != end; pte++, addr += PAGE_SIZE) {
>   		if (!pte_present(*pte))
> @@ -513,6 +530,18 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
>   		nid = page_to_nid(page);
>   		if (node_isset(nid, *qp->nmask) == !!(flags & MPOL_MF_INVERT))
>   			continue;
> +		if (PageTail(page) && PageAnon(page)) {

Hm, can it really happen that we stumble upon THP tail page here, 
without first stumbling upon it in the previous hunk above? If so, when?

> +			get_page(page);
> +			pte_unmap_unlock(pte - 1, ptl);
> +			lock_page(page);
> +			ret = split_huge_page(page);
> +			unlock_page(page);
> +			put_page(page);
> +			/* Failed to split -- skip. */
> +			if (ret)
> +				continue;
> +			goto retry;
> +		}
>
>   		if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
>   			migrate_page_add(page, qp->pagelist, flags);
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
