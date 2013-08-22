Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id C99286B0034
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 16:13:38 -0400 (EDT)
Date: Thu, 22 Aug 2013 16:13:21 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1377202401-mrb1wzdx-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1377164907-24801-6-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1377164907-24801-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1377164907-24801-6-git-send-email-liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 6/6] mm/hwpoison: centralize set PG_hwpoison flag and
 increase num_poisoned_pages
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Aug 22, 2013 at 05:48:27PM +0800, Wanpeng Li wrote:
> soft_offline_page will invoke __soft_offline_page for in-use normal pages 
> and soft_offline_huge_page for in-use hugetlbfs pages. Both of them will 
> done the same effort as for soft offline free pages set PG_hwpoison, increase 
> num_poisoned_pages etc, this patch centralize do them in soft_offline_page.
> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> ---
>  mm/memory-failure.c | 16 ++++------------
>  1 file changed, 4 insertions(+), 12 deletions(-)
> 
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 0a52571..3226de1 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1486,15 +1486,9 @@ static int soft_offline_huge_page(struct page *page, int flags)
>  	ret = migrate_huge_page(hpage, new_page, MPOL_MF_MOVE_ALL,
>  				MIGRATE_SYNC);
>  	put_page(hpage);
> -	if (ret) {
> +	if (ret)
>  		pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
>  			pfn, ret, page->flags);
> -	} else {
> -		set_page_hwpoison_huge_page(hpage);
> -		dequeue_hwpoisoned_huge_page(hpage);
> -		atomic_long_add(1 << compound_order(hpage),
> -				&num_poisoned_pages);
> -	}
>  	return ret;
>  }
>  
> @@ -1530,8 +1524,6 @@ static int __soft_offline_page(struct page *page, int flags)
>  	if (ret == 1) {
>  		put_page(page);
>  		pr_info("soft_offline: %#lx: invalidated\n", pfn);
> -		SetPageHWPoison(page);
> -		atomic_long_inc(&num_poisoned_pages);
>  		return 0;
>  	}
>  
> @@ -1572,11 +1564,9 @@ static int __soft_offline_page(struct page *page, int flags)
>  				lru_add_drain_all();
>  			if (!is_free_buddy_page(page))
>  				drain_all_pages();
> -			SetPageHWPoison(page);
>  			if (!is_free_buddy_page(page))
>  				pr_info("soft offline: %#lx: page leaked\n",
>  					pfn);
> -			atomic_long_inc(&num_poisoned_pages);
>  		}
>  	} else {
>  		pr_info("soft offline: %#lx: isolation failed: %d, page count %d, type %lx\n",

This change does not simply clean up code, but affects the behavior.
This memory leak check should come after SetPageHWPoison().

Thanks,
Naoya Horiguchi

> @@ -1633,7 +1623,9 @@ int soft_offline_page(struct page *page, int flags)
>  			ret = soft_offline_huge_page(page, flags);
>  		else
>  			ret = __soft_offline_page(page, flags);
> -	} else { /* for free pages */
> +	}
> +
> +	if (!ret) {
>  		if (PageHuge(page)) {
>  			set_page_hwpoison_huge_page(hpage);
>  			dequeue_hwpoisoned_huge_page(hpage);
> -- 
> 1.8.1.2
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
