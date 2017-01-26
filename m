Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 25AD96B0033
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 02:32:16 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 204so300550972pfx.1
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 23:32:16 -0800 (PST)
Received: from out4433.biz.mail.alibaba.com (out4433.biz.mail.alibaba.com. [47.88.44.33])
        by mx.google.com with ESMTP id h15si663607pln.257.2017.01.25.23.32.13
        for <linux-mm@kvack.org>;
        Wed, 25 Jan 2017 23:32:15 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170125182538.86249-1-kirill.shutemov@linux.intel.com> <20170125182538.86249-11-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170125182538.86249-11-kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv2 10/12] mm: convert page_mapped_in_vma() to page_vma_mapped_walk()
Date: Thu, 26 Jan 2017 15:31:58 +0800
Message-ID: <008e01d277a6$478dfd90$d6a9f8b0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>, 'Andrea Arcangeli' <aarcange@redhat.com>, 'Hugh Dickins' <hughd@google.com>, 'Rik van Riel' <riel@redhat.com>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org


On January 26, 2017 2:26 AM Kirill A. Shutemov wrote: 
> 
> For consistency, it worth converting all page_check_address() to
> page_vma_mapped_walk(), so we could drop the former.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

>  mm/page_vma_mapped.c | 30 ++++++++++++++++++++++++++++++
>  mm/rmap.c            | 26 --------------------------
>  2 files changed, 30 insertions(+), 26 deletions(-)
> 
> diff --git a/mm/page_vma_mapped.c b/mm/page_vma_mapped.c
> index 63168b4baf19..13929f2418b0 100644
> --- a/mm/page_vma_mapped.c
> +++ b/mm/page_vma_mapped.c
> @@ -179,3 +179,33 @@ next_pte:	do {
>  		}
>  	}
>  }
> +
> +/**
> + * page_mapped_in_vma - check whether a page is really mapped in a VMA
> + * @page: the page to test
> + * @vma: the VMA to test
> + *
> + * Returns 1 if the page is mapped into the page tables of the VMA, 0
> + * if the page is not mapped into the page tables of this VMA.  Only
> + * valid for normal file or anonymous VMAs.
> + */
> +int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma)
> +{
> +	struct page_vma_mapped_walk pvmw = {
> +		.page = page,
> +		.vma = vma,
> +		.flags = PVMW_SYNC,
> +	};
> +	unsigned long start, end;
> +
> +	start = __vma_address(page, vma);
> +	end = start + PAGE_SIZE * (hpage_nr_pages(page) - 1);
> +
> +	if (unlikely(end < vma->vm_start || start >= vma->vm_end))
> +		return 0;
> +	pvmw.address = max(start, vma->vm_start);

Nit: please see comment in the 05/12 patch in this series.

> +	if (!page_vma_mapped_walk(&pvmw))
> +		return 0;
> +	page_vma_mapped_walk_done(&pvmw);
> +	return 1;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
