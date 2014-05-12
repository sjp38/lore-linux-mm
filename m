Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 9267D6B0035
	for <linux-mm@kvack.org>; Mon, 12 May 2014 16:24:27 -0400 (EDT)
Received: by mail-ee0-f48.google.com with SMTP id e49so5008750eek.21
        for <linux-mm@kvack.org>; Mon, 12 May 2014 13:24:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id u49si11375187eef.142.2014.05.12.13.24.25
        for <linux-mm@kvack.org>;
        Mon, 12 May 2014 13:24:26 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] HWPOSION, hugetlb: lock_page/unlock_page does not match for handling a free hugepage
Date: Mon, 12 May 2014 16:24:07 -0400
Message-Id: <53712dfa.49620e0a.270a.14bdSMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <1399691674.29028.1.camel@cyc>
References: <1399691674.29028.1.camel@cyc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: slaoub@gmail.com
Cc: linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, ak@linux.intel.com, Andrew Morton <akpm@linux-foundation.org>

(Cced: Andrew)

On Sat, May 10, 2014 at 11:14:34AM +0800, Chen Yucong wrote:
> For handling a free hugepage in memory failure, the race will happen if
> another thread hwpoisoned this hugepage concurrently. So we need to
> check PageHWPoison instead of !PageHWPoison.
> 
> If hwpoison_filter(p) returns true or a race happens, then we need to
> unlock_page(hpage).
> 
> Signed-off-by: Chen Yucong <slaoub@gmail.com>
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

I tested this patch on latest linux-next, and confirmed that memory error
on a tail page of a free hugepage is properly handled.

Tested-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

And I think this patch should go into all recent stable trees, since this
bug exists since 2.6.36 (because of my patch, sorry.)

> ---
> mm/memory-failure.c |   15 ++++++++-------
> 1 file changed, 8 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 35ef28a..dbf8922 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1081,15 +1081,16 @@ int memory_failure(unsigned long pfn, int
> trapno, int flags)

This linebreak breaks patch format. I guess it's done by your email
client or copy and paste. If it's true, git-send-email might be helpful
to avoid such errors.

Thanks,
Naoya


>  			return 0;
>  		} else if (PageHuge(hpage)) {
>  			/*
> -			 * Check "just unpoisoned", "filter hit", and
> -			 * "race with other subpage."
> +			 * Check "filter hit" and "race with other subpage."
>  			 */
>  			lock_page(hpage);
> -			if (!PageHWPoison(hpage)
> -			    || (hwpoison_filter(p) && TestClearPageHWPoison(p))
> -			    || (p != hpage && TestSetPageHWPoison(hpage))) {
> -				atomic_long_sub(nr_pages, &num_poisoned_pages);
> -				return 0;
> +			if (PageHWPoison(hpage)) {
> +				if ((hwpoison_filter(p) && TestClearPageHWPoison(p))
> +				    || (p != hpage && TestSetPageHWPoison(hpage))) {
> +					atomic_long_sub(nr_pages, &num_poisoned_pages);
> +					unlock_page(hpage);
> +					return 0;
> +				}
>  			}
>  			set_page_hwpoison_huge_page(hpage);
>  			res = dequeue_hwpoisoned_huge_page(hpage);
> -- 
> 1.7.10.4
> 
> 
> 
> 
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
