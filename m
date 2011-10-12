Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 74ED06B0073
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 06:00:11 -0400 (EDT)
Date: Wed, 12 Oct 2011 05:59:53 -0400
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [RFC PATCH] mm: thp: make swap configurable
Message-ID: <20111012095953.GB3160@redhat.com>
References: <1318255086-7393-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1318255086-7393-1-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: aarcange@redhat.com, linux-mm@kvack.org, akpm@linux-foundation.org, hannes@cmpxchg.org, riel@redhat.com

On Mon, Oct 10, 2011 at 09:58:06PM +0800, Bob Liu wrote:
> Currently THP do swap by default, user has no control of it.
> But some applications are swap sensitive, this patch add a boot param
> and sys file to make it configurable.

What's special about THP compared to regular-sized anon pages?

> @@ -155,10 +156,11 @@ int add_to_swap(struct page *page)
>  		return 0;
>  
>  	if (unlikely(PageTransHuge(page)))
> -		if (unlikely(split_huge_page(page))) {
> -			swapcache_free(entry, NULL);
> -			return 0;
> -		}
> +		if(!transparent_hugepage_swap_disable())
> +			if (unlikely(split_huge_page(page))) {
> +				swapcache_free(entry, NULL);
> +				return 0;
> +			}
>  
>  	/*
>  	 * Radix-tree node allocations from PF_MEMALLOC contexts could

That will just prevent the splitting and then add the huge page to the
swap cache, for which it is not prepared.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
