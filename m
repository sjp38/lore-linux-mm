Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 5F6956B0006
	for <linux-mm@kvack.org>; Thu,  7 Mar 2013 13:54:52 -0500 (EST)
Received: by mail-pb0-f46.google.com with SMTP id uo15so578284pbc.19
        for <linux-mm@kvack.org>; Thu, 07 Mar 2013 10:54:51 -0800 (PST)
Date: Thu, 7 Mar 2013 10:54:15 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: page_alloc: remove branch operation in
 free_pages_prepare()
In-Reply-To: <1362644480-18381-1-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.LNX.2.00.1303071050080.6087@eggly.anvils>
References: <1362644480-18381-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 7 Mar 2013, Joonsoo Kim wrote:

> When we found that the flag has a bit of PAGE_FLAGS_CHECK_AT_PREP,
> we reset the flag. If we always reset the flag, we can reduce one
> branch operation. So remove it.
> 
> Cc: Hugh Dickins <hughd@google.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

I don't object to this patch.  But certainly I would have written it
that way in order not to dirty a cacheline unnecessarily.  It may be
obvious to you that the cacheline in question is almost always already
dirty, and the branch almost always more expensive.  But I'll leave that
to you, and to those who know more about these subtle costs than I do.

Hugh

> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 8fcced7..778f2a9 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -614,8 +614,7 @@ static inline int free_pages_check(struct page *page)
>  		return 1;
>  	}
>  	page_nid_reset_last(page);
> -	if (page->flags & PAGE_FLAGS_CHECK_AT_PREP)
> -		page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
> +	page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
>  	return 0;
>  }
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
