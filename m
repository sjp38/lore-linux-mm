Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id BA01F6B0038
	for <linux-mm@kvack.org>; Mon,  4 May 2015 17:52:09 -0400 (EDT)
Received: by lbbqq2 with SMTP id qq2so114844578lbb.3
        for <linux-mm@kvack.org>; Mon, 04 May 2015 14:52:09 -0700 (PDT)
Received: from r00tworld.com (r00tworld.com. [212.85.137.150])
        by mx.google.com with ESMTPS id x1si10920980lag.88.2015.05.04.14.52.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 04 May 2015 14:52:08 -0700 (PDT)
From: "PaX Team" <pageexec@freemail.hu>
Date: Mon, 04 May 2015 23:50:14 +0200
MIME-Version: 1.0
Subject: Re: [PATCH v2 4/4] mm: Add debug code for SANITIZE_FREED_PAGES
Reply-to: pageexec@freemail.hu
Message-ID: <5547E996.16766.8008534@pageexec.freemail.hu>
In-reply-to: <1430774218-5311-5-git-send-email-anisse@astier.eu>
References: <1430774218-5311-1-git-send-email-anisse@astier.eu>, <1430774218-5311-5-git-send-email-anisse@astier.eu>
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7BIT
Content-description: Mail message body
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anisse Astier <anisse@astier.eu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Brad Spengler <spender@grsecurity.net>, Kees Cook <keescook@chromium.org>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 4 May 2015 at 23:16, Anisse Astier wrote:

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index c29e3a0..ba8aa25 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -975,6 +975,31 @@ static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
>  		for (i = 0; i < (1 << order); i++)
>  			clear_highpage(page + i);
>  #endif
> +#ifdef CONFIG_SANITIZE_FREED_PAGES_DEBUG
> +	for (i = 0; i < (1 << order); i++) {
> +		struct page *p = page + i;
> +		int j;
> +		bool err = false;
> +		void *kaddr = kmap_atomic(p);
> +
> +		for (j = 0; j < PAGE_SIZE; j++) {

did you mean to use memchr_inv(kaddr, 0, PAGE_SIZE) instead? ;)

> +			if (((char *)kaddr)[j] != 0) {
> +				pr_err("page %p is not zero on alloc! %s\n",
> +						page_address(p), (gfp_flags &
> +							__GFP_ZERO) ?
> +						"fixing." : "");
> +				if (gfp_flags & __GFP_ZERO) {
> +					err = true;
> +					kunmap_atomic(kaddr);
> +					clear_highpage(p);
> +				}
> +				break;
> +			}
> +		}
> +		if (!err)
> +			kunmap_atomic(kaddr);
> +	}
> +#endif
>  
>  	if (order && (gfp_flags & __GFP_COMP))
>  		prep_compound_page(page, order);
> -- 
> 1.9.3
> 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
