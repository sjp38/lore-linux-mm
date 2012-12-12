Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 3992E6B006C
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 10:47:00 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH V4 1/3] MCE: fix an error of mce_bad_pages statistics
Date: Wed, 12 Dec 2012 10:46:23 -0500
Message-Id: <1355327183-4452-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <50C7FB7D.2060801@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: qiuxishi@huawei.com
Cc: wujianguo@huawei.com, jiang.liu@huawei.com, simon.jeons@gmail.com, Andrew Morton <akpm@linux-foundation.org>, bp@alien8.de, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, liwanp@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Dec 12, 2012 at 11:35:25AM +0800, Xishi Qiu wrote:
> Move poisoned page check at the beginning of the function in order to
> fix the error.

Thanks for the fix.
It works fine both on normal pages and hugepages in my testing.

Tested-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Just nitpick below ...

> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
> ---
>  mm/memory-failure.c |   38 +++++++++++++++++---------------------
>  1 files changed, 17 insertions(+), 21 deletions(-)
> 
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 8b20278..3a8b4b2 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1419,18 +1419,17 @@ static int soft_offline_huge_page(struct page *page, int flags)
>  	unsigned long pfn = page_to_pfn(page);
>  	struct page *hpage = compound_head(page);
> 
> +	if (PageHWPoison(hpage)) {
> +		pr_info("soft offline: %#lx hugepage already poisoned\n", pfn);
> +		return -EBUSY;
> +	}
> +
>  	ret = get_any_page(page, pfn, flags);
>  	if (ret < 0)
>  		return ret;
>  	if (ret == 0)
>  		goto done;
> 
> -	if (PageHWPoison(hpage)) {
> -		put_page(hpage);
> -		pr_info("soft offline: %#lx hugepage already poisoned\n", pfn);
> -		return -EBUSY;
> -	}
> -
>  	/* Keep page count to indicate a given hugepage is isolated. */
>  	ret = migrate_huge_page(hpage, new_page, MPOL_MF_MOVE_ALL, false,
>  				MIGRATE_SYNC);
> @@ -1441,12 +1440,11 @@ static int soft_offline_huge_page(struct page *page, int flags)
>  		return ret;
>  	}
>  done:
> -	if (!PageHWPoison(hpage))
> -		atomic_long_add(1 << compound_trans_order(hpage),
> -				&mce_bad_pages);
> +	/* keep elevated page count for bad page */
> +	atomic_long_add(1 << compound_trans_order(hpage), &mce_bad_pages);
>  	set_page_hwpoison_huge_page(hpage);
>  	dequeue_hwpoisoned_huge_page(hpage);
> -	/* keep elevated page count for bad page */
> +

I think this comment refers to "returning without decrementing page refcount",
and it's not about mce_bad_pages, so keeping the comment as it is seems good
for me.

>  	return ret;
>  }
> 
> @@ -1488,6 +1486,11 @@ int soft_offline_page(struct page *page, int flags)
>  		}
>  	}
> 
> +	if (PageHWPoison(page)) {
> +		pr_info("soft offline: %#lx page already poisoned\n", pfn);
> +		return -EBUSY;
> +	}
> +
>  	ret = get_any_page(page, pfn, flags);
>  	if (ret < 0)
>  		return ret;
> @@ -1519,19 +1522,11 @@ int soft_offline_page(struct page *page, int flags)
>  		return -EIO;
>  	}
> 
> -	lock_page(page);
> -	wait_on_page_writeback(page);
> -
>  	/*
>  	 * Synchronized using the page lock with memory_failure()
>  	 */
> -	if (PageHWPoison(page)) {
> -		unlock_page(page);
> -		put_page(page);
> -		pr_info("soft offline: %#lx page already poisoned\n", pfn);
> -		return -EBUSY;
> -	}
> -
> +	lock_page(page);
> +	wait_on_page_writeback(page);
>  	/*
>  	 * Try to invalidate first. This should work for
>  	 * non dirty unmapped page cache pages.
> @@ -1582,8 +1577,9 @@ int soft_offline_page(struct page *page, int flags)
>  		return ret;
> 
>  done:
> +	/* keep elevated page count for bad page */
>  	atomic_long_add(1, &mce_bad_pages);
>  	SetPageHWPoison(page);
> -	/* keep elevated page count for bad page */
> +
>  	return ret;
>  }

Ditto here.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
