Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id 982466B0035
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 23:16:15 -0500 (EST)
Received: by mail-ee0-f45.google.com with SMTP id d49so600637eek.18
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 20:16:14 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id 5si538760eei.144.2013.12.12.20.16.13
        for <linux-mm@kvack.org>;
        Thu, 12 Dec 2013 20:16:14 -0800 (PST)
Date: Thu, 12 Dec 2013 23:15:54 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1386908154-dn8w7si1-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <52AA80C4.3040109@huawei.com>
References: <52AA80C4.3040109@huawei.com>
Subject: Re: [PATCH] mm/memory-failure.c: recheck PageHuge() after hugetlb
 page migrate successfully
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andi Kleen <andi@firstfloor.org>, gong.chen@linux.intel.com, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Dec 13, 2013 at 11:36:36AM +0800, Jianguo Wu wrote:
> Changelog:
>  - Only set PageHWPoison on the error raw page if page is freed into buddy
> 
> After a successful hugetlb page migration by soft offline, the source page
> will either be freed into hugepage_freelists or buddy(over-commit page).
> If page is in buddy, page_hstate(page) will be NULL. It will hit a NULL
> pointer dereference in dequeue_hwpoisoned_huge_page().
> 
> [  890.677918] BUG: unable to handle kernel NULL pointer dereference at
>  0000000000000058
> [  890.685741] IP: [<ffffffff81163761>]
> dequeue_hwpoisoned_huge_page+0x131/0x1d0
> [  890.692861] PGD c23762067 PUD c24be2067 PMD 0
> [  890.697314] Oops: 0000 [#1] SMP
> 
> So check PageHuge(page) after call migrate_pages() successfully.
> 
> Tested-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: stable@vger.kernel.org
> Signed-off-by: Jianguo Wu <wujianguo@huawei.com>

Thanks!

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  mm/memory-failure.c |   14 ++++++++++----
>  1 files changed, 10 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index b7c1716..db08af9 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1505,10 +1505,16 @@ static int soft_offline_huge_page(struct page *page, int flags)
>  		if (ret > 0)
>  			ret = -EIO;
>  	} else {
> -		set_page_hwpoison_huge_page(hpage);
> -		dequeue_hwpoisoned_huge_page(hpage);
> -		atomic_long_add(1 << compound_order(hpage),
> -				&num_poisoned_pages);
> +		/* overcommit hugetlb page will be freed to buddy */
> +		if (PageHuge(page)) {
> +			set_page_hwpoison_huge_page(hpage);
> +			dequeue_hwpoisoned_huge_page(hpage);
> +			atomic_long_add(1 << compound_order(hpage),
> +					&num_poisoned_pages);
> +		} else {
> +			SetPageHWPoison(page);
> +			atomic_long_inc(&num_poisoned_pages);
> +		}
>  	}
>  	return ret;
>  }
> -- 
> 1.7.1
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
