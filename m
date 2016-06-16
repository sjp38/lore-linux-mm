Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6337F6B025F
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 07:32:30 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id g13so86622882ioj.3
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 04:32:30 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id j192si20657317oib.1.2016.06.16.04.32.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Jun 2016 04:32:29 -0700 (PDT)
Message-ID: <57628DE2.1090501@huawei.com>
Date: Thu, 16 Jun 2016 19:30:42 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix account pmd page to the process
References: <1466076175-23444-1-git-send-email-zhongjiang@huawei.com>
In-Reply-To: <1466076175-23444-1-git-send-email-zhongjiang@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com
Cc: Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2016/6/16 19:22, zhongjiang wrote:
> From: zhong jiang <zhongjiang@huawei.com>
>
> when a process acquire a pmd table shared by other process, we
> increase the account to current process. otherwise, a race result
> in other tasks have set the pud entry. so it no need to increase it.
>
> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> ---
>  mm/hugetlb.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
>
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 19d0d08..3b025c5 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -4189,10 +4189,9 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
>  	if (pud_none(*pud)) {
>  		pud_populate(mm, pud,
>  				(pmd_t *)((unsigned long)spte & PAGE_MASK));
> -	} else {
> +	} else 
>  		put_page(virt_to_page(spte));
> -		mm_inc_nr_pmds(mm);
> -	}
> +
>  	spin_unlock(ptl);
>  out:
>  	pte = (pte_t *)pmd_alloc(mm, pud, addr);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
