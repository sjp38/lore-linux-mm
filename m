Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id 9D0F06B0031
	for <linux-mm@kvack.org>; Wed,  4 Jun 2014 02:41:35 -0400 (EDT)
Received: by mail-qa0-f49.google.com with SMTP id cm18so6243171qab.8
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 23:41:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id ld10si2195427qcb.28.2014.06.03.23.41.34
        for <linux-mm@kvack.org>;
        Tue, 03 Jun 2014 23:41:34 -0700 (PDT)
Message-ID: <538ebf9e.4af1e50a.4cd6.231aSMTPIN_ADDED_BROKEN@mx.google.com>
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2] HWPOISON: Fix the handling path of the victimized page frame that belong to non-LUR
Date: Wed,  4 Jun 2014 02:41:01 -0400
In-Reply-To: <1401860898-11486-1-git-send-email-slaoub@gmail.com>
References: <1401860898-11486-1-git-send-email-slaoub@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Yucong <slaoub@gmail.com>
Cc: ak@linux.intel.com, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org

On Wed, Jun 04, 2014 at 01:48:18PM +0800, Chen Yucong wrote:
> Until now, the kernel has the same policy to handle victimized page frames that
> belong to kernel-space(reserved/slab-subsystem) or non-LRU(unknown page state).
> In other word, the result of handling either of these victimized page frames is
> (IGNORED | FAILED), and the return value of memory_failure() is -EBUSY.
> 
> This patch is to avoid that memory_failure() returns very soon due to the "true"
> value of (!PageLRU(p)), and it also ensures that action_result() can report more
> precise information("reserved kernel",  "kernel slab", and "unknown page state")
> instead of "non LRU", especially for memory errors which are detected by memory-scrubbing.
> 
> Changes since v1: http://www.spinics.net/lists/linux-mm/msg74044.html
>   - Call goto just after if (hwpoison_filter(p)) block, and jump directly to just 
>     before the code determining the page_state, as suggested by Naoya Horiguchi.
> 
> Signed-off-by: Chen Yucong <slaoub@gmail.com>

Looks good to me, thanks!

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  mm/memory-failure.c |    9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index e3154d9..1340b30 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -862,7 +862,7 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
>  	struct page *hpage = *hpagep;
>  	struct page *ppage;
>  
> -	if (PageReserved(p) || PageSlab(p))
> +	if (PageReserved(p) || PageSlab(p) || !PageLRU(p))
>  		return SWAP_SUCCESS;
>  
>  	/*
> @@ -1126,9 +1126,6 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
>  					action_result(pfn, "free buddy, 2nd try", DELAYED);
>  				return 0;
>  			}
> -			action_result(pfn, "non LRU", IGNORED);
> -			put_page(p);
> -			return -EBUSY;
>  		}
>  	}
>  
> @@ -1161,6 +1158,9 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
>  		return 0;
>  	}
>  
> +	if (!PageHuge(p) && !PageTransTail(p) && !PageLRU(p))
> +		goto identify_page_state;
> +
>  	/*
>  	 * For error on the tail page, we should set PG_hwpoison
>  	 * on the head page to show that the hugepage is hwpoisoned
> @@ -1210,6 +1210,7 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
>  		goto out;
>  	}
>  
> +identify_page_state:
>  	res = -EBUSY;
>  	/*
>  	 * The first check uses the current page flags which may not have any
> -- 
> 1.7.10.4
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
