Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id 8E89E6B0031
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 17:27:32 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id q59so7297588wes.7
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 14:27:31 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id kj7si843210wjc.22.2014.06.03.14.27.29
        for <linux-mm@kvack.org>;
        Tue, 03 Jun 2014 14:27:30 -0700 (PDT)
Message-ID: <538e3dc2.a7cac20a.48a8.6a20SMTPIN_ADDED_BROKEN@mx.google.com>
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] HWPOISON: Fix the handling path of the victimized page frame that belong to non-LUR
Date: Tue,  3 Jun 2014 17:27:15 -0400
In-Reply-To: <1401780582-9477-1-git-send-email-slaoub@gmail.com>
References: <1401780582-9477-1-git-send-email-slaoub@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Yucong <slaoub@gmail.com>
Cc: ak@linux.intel.com, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Tue, Jun 03, 2014 at 03:29:42PM +0800, Chen Yucong wrote:
> Until now, the kernel has the same policy to handle victimized page frames that
> belong to kernel-space(reserved/slab-subsystem) or non-LRU(unknown page state).
> In other word, the result of handling either of these victimized page frames is
> (IGNORED | FAILED), and the return value of memory_failure() is -EBUSY.
> 
> This patch is to avoid that memory_failure() returns very soon due to the "true"
> value of (!PageLRU(p)), and it also ensures that action_result() can report more
> precise information("reserved kernel",  "kernel slab", and "unknown page state")
> instead of "non LRU", especially for memory errors which are detected by memory-scrubbing.

Yes, this fixes the poor messaging.

> Signed-off-by: Chen Yucong <slaoub@gmail.com>
> ---
>  mm/memory-failure.c |    5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)
> 
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index e3154d9..39daadc 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -862,7 +862,7 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
>  	struct page *hpage = *hpagep;
>  	struct page *ppage;
>  
> -	if (PageReserved(p) || PageSlab(p))
> +	if (PageReserved(p) || PageSlab(p) || !PageLRU(p))
>  		return SWAP_SUCCESS;

I don't think that this check never becomes true in the original code, because
we return immediately before coming to this point for !PageLRU as you said.

But I think this is still useful because error handling code is permitted to
fail error containment and in such case it's supposed to leave error pages.
So keeping this false positive is better than stopping here with VM_BUG_ON()
or running unmapping code for kernel page and triggering some unexpected bug.
It makes sure that this function works as intended even for accidental input.

So in summary I agree with this change although it's not run (with my suggestion
below.)

>  	/*
> @@ -1126,9 +1126,6 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
>  					action_result(pfn, "free buddy, 2nd try", DELAYED);
>  				return 0;
>  			}
> -			action_result(pfn, "non LRU", IGNORED);
> -			put_page(p);
> -			return -EBUSY;

Not only removing these lines, you had better also call goto just after
if (hwpoison_filter(p)) block, and jump directly to just before the code
determining the page_state.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
