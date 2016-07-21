Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id CFAAD828FF
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 04:19:57 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id u25so144030055ioi.1
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 01:19:57 -0700 (PDT)
Received: from out4439.biz.mail.alibaba.com (out4439.biz.mail.alibaba.com. [47.88.44.39])
        by mx.google.com with ESMTP id f66si1254564ite.10.2016.07.21.01.19.55
        for <linux-mm@kvack.org>;
        Thu, 21 Jul 2016 01:19:57 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <003701d1e328$202ca9d0$6085fd70$@alibaba-inc.com>
In-Reply-To: <003701d1e328$202ca9d0$6085fd70$@alibaba-inc.com>
Subject: Re: + mm-hugetlb-fix-race-when-migrate-pages.patch added to -mm tree
Date: Thu, 21 Jul 2016 16:19:42 +0800
Message-ID: <003801d1e328$a24c2030$e6e46090$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: 'zhongjiang' <zhongjiang@huawei.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

> 
> From b1e9b3214f1859fdf7d134cdcb56f5871933539c Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Thu, 21 Jul 2016 09:28:13 +0200
> Subject: [PATCH] mm, hugetlb: fix huge_pte_alloc BUG_ON
> 
> Zhong Jiang has reported a BUG_ON from huge_pte_alloc hitting when he
> runs his database load with memory online and offline running in
> parallel. The reason is that huge_pmd_share might detect a shared pmd
> which is currently migrated and so it has migration pte which is
> !pte_huge.
> 
> There doesn't seem to be any easy way to prevent from the race and in
> fact seeing the migration swap entry is not harmful. Both callers of
> huge_pte_alloc are prepared to handle them. copy_hugetlb_page_range
> will copy the swap entry and make it COW if needed. hugetlb_fault will
> back off and so the page fault is retries if the page is still under
> migration and waits for its completion in hugetlb_fault.
> 
> That means that the BUG_ON is wrong and we should update it. Let's
> simply check that all present ptes are pte_huge instead.
> 
> Reported-by: zhongjiang <zhongjiang@huawei.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

>  mm/hugetlb.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 34379d653aa3..31dd2b8b86b3 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -4303,7 +4303,7 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
>  				pte = (pte_t *)pmd_alloc(mm, pud, addr);
>  		}
>  	}
> -	BUG_ON(pte && !pte_none(*pte) && !pte_huge(*pte));
> +	BUG_ON(pte && pte_present(*pte) && !pte_huge(*pte));
> 
>  	return pte;
>  }
> --
> 2.8.1
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
