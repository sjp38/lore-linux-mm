Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id D8757900015
	for <linux-mm@kvack.org>; Tue, 21 Apr 2015 16:31:31 -0400 (EDT)
Received: by qcyk17 with SMTP id k17so82633045qcy.1
        for <linux-mm@kvack.org>; Tue, 21 Apr 2015 13:31:31 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j90si3019162qgd.49.2015.04.21.13.31.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Apr 2015 13:31:30 -0700 (PDT)
Message-ID: <5536B386.4050808@redhat.com>
Date: Tue, 21 Apr 2015 16:31:02 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/6] mm: Defer TLB flush after unmap as long as possible
References: <1429612880-21415-1-git-send-email-mgorman@suse.de> <1429612880-21415-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1429612880-21415-4-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>
Cc: Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On 04/21/2015 06:41 AM, Mel Gorman wrote:
> If a PTE is unmapped and it's dirty then it was writable recently. Due
> to deferred TLB flushing, it's best to assume a writable TLB cache entry
> exists. With that assumption, the TLB must be flushed before any IO can
> start or the page is freed to avoid lost writes or data corruption. Prior
> to this patch, such PFNs were simply flushed immediately. In this patch,
> the caller is informed that such entries potentially exist and it's up to
> the caller to flush before pages are freed or IO can start.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

> @@ -1450,10 +1455,11 @@ static int page_not_mapped(struct page *page)
>   * page, used in the pageout path.  Caller must hold the page lock.
>   * Return values are:
>   *
> - * SWAP_SUCCESS	- we succeeded in removing all mappings
> - * SWAP_AGAIN	- we missed a mapping, try again later
> - * SWAP_FAIL	- the page is unswappable
> - * SWAP_MLOCK	- page is mlocked.
> + * SWAP_SUCCESS	       - we succeeded in removing all mappings
> + * SWAP_SUCCESS_CACHED - Like SWAP_SUCCESS but a writable TLB entry may exist
> + * SWAP_AGAIN	       - we missed a mapping, try again later
> + * SWAP_FAIL	       - the page is unswappable
> + * SWAP_MLOCK	       - page is mlocked.
>   */
>  int try_to_unmap(struct page *page, enum ttu_flags flags)
>  {
> @@ -1481,7 +1487,8 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
>  	ret = rmap_walk(page, &rwc);
>  
>  	if (ret != SWAP_MLOCK && !page_mapped(page))
> -		ret = SWAP_SUCCESS;
> +		ret = (ret == SWAP_AGAIN_CACHED) ? SWAP_SUCCESS_CACHED : SWAP_SUCCESS;
> +
>  	return ret;
>  }

This wants a big fat comment explaining why SWAP_AGAIN_CACHED is turned
into SWAP_SUCCESS_CACHED.

I think I understand why this is happening, but I am not sure how to
explain it...

> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 12ec298087b6..0ad3f435afdd 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -860,6 +860,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  	unsigned long nr_reclaimed = 0;
>  	unsigned long nr_writeback = 0;
>  	unsigned long nr_immediate = 0;
> +	bool tlb_flush_required = false;
>  
>  	cond_resched();
>  
> @@ -1032,6 +1033,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  				goto keep_locked;
>  			case SWAP_MLOCK:
>  				goto cull_mlocked;
> +			case SWAP_SUCCESS_CACHED:
> +				/* Must flush before free, fall through */
> +				tlb_flush_required = true;
>  			case SWAP_SUCCESS:
>  				; /* try to free the page below */
>  			}
> @@ -1176,7 +1180,8 @@ keep:
>  	}
>  
>  	mem_cgroup_uncharge_list(&free_pages);
> -	try_to_unmap_flush();
> +	if (tlb_flush_required)
> +		try_to_unmap_flush();
>  	free_hot_cold_page_list(&free_pages, true);

Don't we have to flush the TLB before calling pageout() on the page?

In other words, we would also have to batch up calls to pageout(), if
we want to do batched TLB flushing.

This could be accomplished by putting the SWAP_SUCCESS_CACHED pages on
a special list, instead of calling pageout() on them immediately, and
then calling pageout() on all the pages on that list after the batch
flush.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
