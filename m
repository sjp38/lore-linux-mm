Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 9D8EF6B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 17:36:22 -0400 (EDT)
Received: by igbhj9 with SMTP id hj9so25582050igb.1
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 14:36:22 -0700 (PDT)
Received: from mail-ie0-x229.google.com (mail-ie0-x229.google.com. [2607:f8b0:4001:c03::229])
        by mx.google.com with ESMTPS id l92si10380532ioi.71.2015.04.24.14.36.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Apr 2015 14:36:22 -0700 (PDT)
Received: by iebrs15 with SMTP id rs15so93071556ieb.3
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 14:36:22 -0700 (PDT)
Date: Fri, 24 Apr 2015 14:36:19 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mm/page_alloc.c: cleanup obsolete KM_USER*
In-Reply-To: <1429909549-11726-2-git-send-email-anisse@astier.eu>
Message-ID: <alpine.DEB.2.10.1504241434040.2456@chino.kir.corp.google.com>
References: <1429909549-11726-1-git-send-email-anisse@astier.eu> <1429909549-11726-2-git-send-email-anisse@astier.eu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anisse Astier <anisse@astier.eu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Kees Cook <keescook@chromium.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 24 Apr 2015, Anisse Astier wrote:

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ebffa0e..05fcec9 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -380,16 +380,10 @@ void prep_compound_page(struct page *page, unsigned long order)
>  	}
>  }
>  
> -static inline void prep_zero_page(struct page *page, unsigned int order,
> -							gfp_t gfp_flags)
> +static inline void zero_pages(struct page *page, unsigned int order)
>  {
>  	int i;
>  
> -	/*
> -	 * clear_highpage() will use KM_USER0, so it's a bug to use __GFP_ZERO
> -	 * and __GFP_HIGHMEM from hard or soft interrupt context.
> -	 */
> -	VM_BUG_ON((gfp_flags & __GFP_HIGHMEM) && in_interrupt());
>  	for (i = 0; i < (1 << order); i++)
>  		clear_highpage(page + i);
>  }
> @@ -975,7 +969,7 @@ static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
>  	kasan_alloc_pages(page, order);
>  
>  	if (gfp_flags & __GFP_ZERO)
> -		prep_zero_page(page, order, gfp_flags);
> +		zero_pages(page, order);
>  
>  	if (order && (gfp_flags & __GFP_COMP))
>  		prep_compound_page(page, order);

No objection to removing the VM_BUG_ON() here, but I'm not sure that we 
need an inline function to do this and to add additional callers in your 
next patch.  Why can't we just remove the helper entirely and do the 
iteration in prep_new_page()?  We iterate pages all the time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
