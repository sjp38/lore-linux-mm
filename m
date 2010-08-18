Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 10BCF6B01F1
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 20:19:08 -0400 (EDT)
Date: Wed, 18 Aug 2010 08:18:42 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 1/9] HWPOISON, hugetlb: move PG_HWPoison bit check
Message-ID: <20100818001842.GC6928@localhost>
References: <1281432464-14833-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1281432464-14833-2-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1281432464-14833-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 10, 2010 at 05:27:36PM +0800, Naoya Horiguchi wrote:
> In order to handle metadatum correctly, we should check whether the hugepage
> we are going to access is HWPOISONed *before* incrementing mapcount,
> adding the hugepage into pagecache or constructing anon_vma.
> This patch also adds retry code when there is a race between
> alloc_huge_page() and memory failure.

This duplicates the PageHWPoison() test into 3 places without really
address any problem. For example, there are still _unavoidable_ races
between PageHWPoison() and add_to_page_cache().

What's the problem you are trying to resolve here? If there are
data structure corruption, we may need to do it in some other ways.

Thanks,
Fengguang


> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
> ---
>  mm/hugetlb.c |   34 +++++++++++++++++++++-------------
>  1 files changed, 21 insertions(+), 13 deletions(-)
> 
> diff --git linux-mce-hwpoison/mm/hugetlb.c linux-mce-hwpoison/mm/hugetlb.c
> index a26c24a..5c77a73 100644
> --- linux-mce-hwpoison/mm/hugetlb.c
> +++ linux-mce-hwpoison/mm/hugetlb.c
> @@ -2490,8 +2490,15 @@ retry:
>  			int err;
>  			struct inode *inode = mapping->host;
>  
> -			err = add_to_page_cache(page, mapping, idx, GFP_KERNEL);
> +			lock_page(page);
> +			if (unlikely(PageHWPoison(page))) {
> +				unlock_page(page);
> +				goto retry;
> +			}
> +			err = add_to_page_cache_locked(page, mapping,
> +						       idx, GFP_KERNEL);
>  			if (err) {
> +				unlock_page(page);
>  				put_page(page);
>  				if (err == -EEXIST)
>  					goto retry;
> @@ -2504,6 +2511,10 @@ retry:
>  			page_dup_rmap(page);
>  		} else {
>  			lock_page(page);
> +			if (unlikely(PageHWPoison(page))) {
> +				unlock_page(page);
> +				goto retry;
> +			}
>  			if (unlikely(anon_vma_prepare(vma))) {
>  				ret = VM_FAULT_OOM;
>  				goto backout_unlocked;
> @@ -2511,22 +2522,19 @@ retry:
>  			hugepage_add_new_anon_rmap(page, vma, address);
>  		}
>  	} else {
> +		/*
> +		 * If memory error occurs between mmap() and fault, some process
> +		 * don't have hwpoisoned swap entry for errored virtual address.
> +		 * So we need to block hugepage fault by PG_hwpoison bit check.
> +		 */
> +		if (unlikely(PageHWPoison(page))) {
> +			ret = VM_FAULT_HWPOISON;
> +			goto backout_unlocked;
> +		}
>  		page_dup_rmap(page);
>  	}
>  
>  	/*
> -	 * Since memory error handler replaces pte into hwpoison swap entry
> -	 * at the time of error handling, a process which reserved but not have
> -	 * the mapping to the error hugepage does not have hwpoison swap entry.
> -	 * So we need to block accesses from such a process by checking
> -	 * PG_hwpoison bit here.
> -	 */
> -	if (unlikely(PageHWPoison(page))) {
> -		ret = VM_FAULT_HWPOISON;
> -		goto backout_unlocked;
> -	}
> -
> -	/*
>  	 * If we are going to COW a private mapping later, we examine the
>  	 * pending reservations for this page now. This will ensure that
>  	 * any allocations necessary to record that reservation occur outside
> -- 
> 1.7.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
