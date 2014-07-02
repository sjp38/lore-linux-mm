Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id C586E6B0031
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 00:30:34 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so11664844pab.8
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 21:30:34 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id mk6si29026872pab.91.2014.07.01.21.30.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 01 Jul 2014 21:30:34 -0700 (PDT)
Received: by mail-pa0-f51.google.com with SMTP id hz1so11836062pad.10
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 21:30:33 -0700 (PDT)
Date: Tue, 1 Jul 2014 21:29:00 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: swap: avoid to writepage when a page is
 !PageSwapCache
In-Reply-To: <1404272573-24448-1-git-send-email-pingfank@linux.vnet.ibm.com>
Message-ID: <alpine.LSU.2.11.1407012101160.1009@eggly.anvils>
References: <1404272573-24448-1-git-send-email-pingfank@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liu Ping Fan <kernelfans@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Wed, 2 Jul 2014, Liu Ping Fan wrote:

> There is race between do_swap_page() and swap_writepage(), if
> do_swap_page() had deleted a page from swap cache, there is no need
> to write it. So changing the ret of try_to_free_swap() to make
> swap_writepage() aware of this scene.

Is this an inefficiency that you have noticed in practice,
or something that you think you spotted by code inspection?

I don't see how it can happen: all the places I know of that call
swap_writepage() (including vmscan.c's mapping->a_ops->writepage)
have not dropped page lock since setting or checking PageSwapCache,
and page lock is supposed to protect against deletion from swap cache.

Has that changed?  Please point out where.

> 
> Signed-off-by: Liu Ping Fan <pingfank@linux.vnet.ibm.com>
> ---
>  mm/swapfile.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 4c524f7..9d80671 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -910,7 +910,7 @@ int try_to_free_swap(struct page *page)
>  	VM_BUG_ON_PAGE(!PageLocked(page), page);
>  
>  	if (!PageSwapCache(page))
> -		return 0;
> +		return -1;

Previously it returned either 0 or 1, which is what __try_to_reclaim_swap()
says it returns; so better to stick to 0 or 1, unless you have good reason
to add a distinct value.

It's true that by the time __try_to_reclaim_swap() has got the page lock,
the page might have been removed from swap cache, and we could then treat
that as swap_was_freed (even though it was not freed by the caller).

But it's a very narrow window, and no great advantage to do so:
I don't think it's worth changing try_to_free_swap() semantics for,
but you could persuade us.

Hugh

>  	if (PageWriteback(page))
>  		return 0;
>  	if (page_swapcount(page))
> -- 
> 1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
