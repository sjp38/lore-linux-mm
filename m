Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 3C9A86B0007
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 02:26:30 -0500 (EST)
Message-ID: <510627F2.7010500@huawei.com>
Date: Mon, 28 Jan 2013 15:25:38 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: clean up soft_offline_page()
References: <1359176531-12583-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1359176531-12583-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Tony Luck <tony.luck@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Jiang Liu <jiang.liu@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2013/1/26 13:02, Naoya Horiguchi wrote:

> Currently soft_offline_page() is hard to maintain because it has many
> return points and goto statements. All of this mess come from get_any_page().
> This function should only get page refcount as the name implies, but it does
> some page isolating actions like SetPageHWPoison() and dequeuing hugepage.
> This patch corrects it and introduces some internal subroutines to make
> soft offlining code more readable and maintainable.
> 
> ChangeLog v2:
>   - receive returned value from __soft_offline_page and soft_offline_huge_page
>   - place __soft_offline_page after soft_offline_page to reduce the diff
>   - rebased onto mmotm-2013-01-23-17-04
>   - add comment on double checks of PageHWpoison
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  mm/memory-failure.c | 154 ++++++++++++++++++++++++++++------------------------
>  1 file changed, 83 insertions(+), 71 deletions(-)
> 
> diff --git mmotm-2013-01-23-17-04.orig/mm/memory-failure.c mmotm-2013-01-23-17-04/mm/memory-failure.c
> index c95e19a..302625b 100644
> --- mmotm-2013-01-23-17-04.orig/mm/memory-failure.c
> +++ mmotm-2013-01-23-17-04/mm/memory-failure.c
> @@ -1368,7 +1368,7 @@ static struct page *new_page(struct page *p, unsigned long private, int **x)
>   * that is not free, and 1 for any other page type.
>   * For 1 the page is returned with increased page count, otherwise not.
>   */
> -static int get_any_page(struct page *p, unsigned long pfn, int flags)
> +static int __get_any_page(struct page *p, unsigned long pfn, int flags)
>  {
>  	int ret;
>  
> @@ -1393,11 +1393,9 @@ static int get_any_page(struct page *p, unsigned long pfn, int flags)
>  	if (!get_page_unless_zero(compound_head(p))) {
>  		if (PageHuge(p)) {
>  			pr_info("%s: %#lx free huge page\n", __func__, pfn);
> -			ret = dequeue_hwpoisoned_huge_page(compound_head(p));
> +			ret = 0;
>  		} else if (is_free_buddy_page(p)) {
>  			pr_info("%s: %#lx free buddy page\n", __func__, pfn);
> -			/* Set hwpoison bit while page is still isolated */
> -			SetPageHWPoison(p);
>  			ret = 0;
>  		} else {
>  			pr_info("%s: %#lx: unknown zero refcount page type %lx\n",
> @@ -1413,42 +1411,62 @@ static int get_any_page(struct page *p, unsigned long pfn, int flags)
>  	return ret;
>  }
>  
> +static int get_any_page(struct page *page, unsigned long pfn, int flags)
> +{
> +	int ret = __get_any_page(page, pfn, flags);
> +
> +	if (ret == 1 && !PageHuge(page) && !PageLRU(page)) {
> +		/*
> +		 * Try to free it.
> +		 */
> +		put_page(page);
> +		shake_page(page, 1);
> +
> +		/*
> +		 * Did it turn free?
> +		 */
> +		ret = __get_any_page(page, pfn, 0);
> +		if (!PageLRU(page)) {
> +			pr_info("soft_offline: %#lx: unknown non LRU page type %lx\n",
> +				pfn, page->flags);
> +			return -EIO;
> +		}
> +	}
> +	return ret;
> +}
> +
>  static int soft_offline_huge_page(struct page *page, int flags)
>  {
>  	int ret;
>  	unsigned long pfn = page_to_pfn(page);
>  	struct page *hpage = compound_head(page);
>  
> +	/*
> +	 * This double-check of PageHWPoison is to avoid the race with
> +	 * memory_failure(). See also comment in __soft_offline_page().
> +	 */
> +	lock_page(hpage);
>  	if (PageHWPoison(hpage)) {
> +		unlock_page(hpage);
> +		put_page(hpage);
>  		pr_info("soft offline: %#lx hugepage already poisoned\n", pfn);
> -		ret = -EBUSY;
> -		goto out;
> +		return -EBUSY;
>  	}
> -
> -	ret = get_any_page(page, pfn, flags);
> -	if (ret < 0)
> -		goto out;
> -	if (ret == 0)
> -		goto done;
> +	unlock_page(hpage);
>  
>  	/* Keep page count to indicate a given hugepage is isolated. */
>  	ret = migrate_huge_page(hpage, new_page, MPOL_MF_MOVE_ALL, false,
>  				MIGRATE_SYNC);
>  	put_page(hpage);
> -	if (ret) {
> +	if (ret)
>  		pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
>  			pfn, ret, page->flags);
> -		goto out;
> -	}
> -done:
>  	/* keep elevated page count for bad page */
> -	atomic_long_add(1 << compound_trans_order(hpage), &num_poisoned_pages);
> -	set_page_hwpoison_huge_page(hpage);
> -	dequeue_hwpoisoned_huge_page(hpage);

Hi Naoya,

Does num_poisoned_pages be added when soft_offline_huge_page? I mean the in-use huge pages.

Thanks,
Xishi Qiu

> -out:
>  	return ret;
>  }
>  
> +static int __soft_offline_page(struct page *page, int flags);
> +
>  /**
>   * soft_offline_page - Soft offline a page.
>   * @page: page to offline
> @@ -1477,62 +1495,60 @@ int soft_offline_page(struct page *page, int flags)
>  	unsigned long pfn = page_to_pfn(page);
>  	struct page *hpage = compound_trans_head(page);
>  
> -	if (PageHuge(page)) {
> -		ret = soft_offline_huge_page(page, flags);
> -		goto out;
> +	if (PageHWPoison(page)) {
> +		pr_info("soft offline: %#lx page already poisoned\n", pfn);
> +		return -EBUSY;
>  	}
> -	if (PageTransHuge(hpage)) {
> +	if (!PageHuge(page) && PageTransHuge(hpage)) {
>  		if (PageAnon(hpage) && unlikely(split_huge_page(hpage))) {
>  			pr_info("soft offline: %#lx: failed to split THP\n",
>  				pfn);
> -			ret = -EBUSY;
> -			goto out;
> +			return -EBUSY;
>  		}
>  	}
>  
> -	if (PageHWPoison(page)) {
> -		pr_info("soft offline: %#lx page already poisoned\n", pfn);
> -		ret = -EBUSY;
> -		goto out;
> -	}
> -
>  	ret = get_any_page(page, pfn, flags);
>  	if (ret < 0)
> -		goto out;
> -	if (ret == 0)
> -		goto done;
> -
> -	/*
> -	 * Page cache page we can handle?
> -	 */
> -	if (!PageLRU(page)) {
> -		/*
> -		 * Try to free it.
> -		 */
> -		put_page(page);
> -		shake_page(page, 1);
> -
> -		/*
> -		 * Did it turn free?
> -		 */
> -		ret = get_any_page(page, pfn, 0);
> -		if (ret < 0)
> -			goto out;
> -		if (ret == 0)
> -			goto done;
> -	}
> -	if (!PageLRU(page)) {
> -		pr_info("soft_offline: %#lx: unknown non LRU page type %lx\n",
> -			pfn, page->flags);
> -		ret = -EIO;
> -		goto out;
> +		return ret;
> +	if (ret) { /* for in-use pages */
> +		if (PageHuge(page))
> +			ret = soft_offline_huge_page(page, flags);
> +		else
> +			ret = __soft_offline_page(page, flags);
> +	} else { /* for free pages */
> +		if (PageHuge(page)) {
> +			set_page_hwpoison_huge_page(hpage);
> +			dequeue_hwpoisoned_huge_page(hpage);
> +			atomic_long_add(1 << compound_trans_order(hpage),
> +					&num_poisoned_pages);
> +		} else {
> +			SetPageHWPoison(page);
> +			atomic_long_inc(&num_poisoned_pages);
> +		}
>  	}
> +	/* keep elevated page count for bad page */
> +	return ret;
> +}
> +
> +static int __soft_offline_page(struct page *page, int flags)
> +{
> +	int ret;
> +	unsigned long pfn = page_to_pfn(page);
>  
>  	/*
> -	 * Synchronized using the page lock with memory_failure()
> +	 * Check PageHWPoison again inside page lock because PageHWPoison
> +	 * is set by memory_failure() outside page lock. Note that
> +	 * memory_failure() also double-checks PageHWPoison inside page lock,
> +	 * so there's no race between soft_offline_page() and memory_failure().
>  	 */
>  	lock_page(page);
>  	wait_on_page_writeback(page);
> +	if (PageHWPoison(page)) {
> +		unlock_page(page);
> +		put_page(page);
> +		pr_info("soft offline: %#lx page already poisoned\n", pfn);
> +		return -EBUSY;
> +	}
>  	/*
>  	 * Try to invalidate first. This should work for
>  	 * non dirty unmapped page cache pages.
> @@ -1545,9 +1561,10 @@ int soft_offline_page(struct page *page, int flags)
>  	 */
>  	if (ret == 1) {
>  		put_page(page);
> -		ret = 0;
>  		pr_info("soft_offline: %#lx: invalidated\n", pfn);
> -		goto done;
> +		SetPageHWPoison(page);
> +		atomic_long_inc(&num_poisoned_pages);
> +		return 0;
>  	}
>  
>  	/*
> @@ -1575,18 +1592,13 @@ int soft_offline_page(struct page *page, int flags)
>  				pfn, ret, page->flags);
>  			if (ret > 0)
>  				ret = -EIO;
> +		} else {
> +			SetPageHWPoison(page);
> +			atomic_long_inc(&num_poisoned_pages);
>  		}
>  	} else {
>  		pr_info("soft offline: %#lx: isolation failed: %d, page count %d, type %lx\n",
>  			pfn, ret, page_count(page), page->flags);
>  	}
> -	if (ret)
> -		goto out;
> -
> -done:
> -	/* keep elevated page count for bad page */
> -	atomic_long_inc(&num_poisoned_pages);
> -	SetPageHWPoison(page);
> -out:
>  	return ret;
>  }



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
