Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id C67D36B006C
	for <linux-mm@kvack.org>; Mon,  4 May 2015 17:52:10 -0400 (EDT)
Received: by layy10 with SMTP id y10so114141540lay.0
        for <linux-mm@kvack.org>; Mon, 04 May 2015 14:52:10 -0700 (PDT)
Received: from r00tworld.com (r00tworld.com. [212.85.137.150])
        by mx.google.com with ESMTPS id pz9si10927153lbb.92.2015.05.04.14.52.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 04 May 2015 14:52:08 -0700 (PDT)
From: "PaX Team" <pageexec@freemail.hu>
Date: Mon, 04 May 2015 23:50:14 +0200
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/4] mm/page_alloc.c: add config option to sanitize freed pages
Reply-to: pageexec@freemail.hu
Message-ID: <5547E996.30078.8008582@pageexec.freemail.hu>
In-reply-to: <1430774218-5311-3-git-send-email-anisse@astier.eu>
References: <1430774218-5311-1-git-send-email-anisse@astier.eu>, <1430774218-5311-3-git-send-email-anisse@astier.eu>
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7BIT
Content-description: Mail message body
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anisse Astier <anisse@astier.eu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Brad Spengler <spender@grsecurity.net>, Kees Cook <keescook@chromium.org>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 4 May 2015 at 23:16, Anisse Astier wrote:

> @@ -960,9 +966,15 @@ static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
>  	kernel_map_pages(page, 1 << order, 1);
>  	kasan_alloc_pages(page, order);
>  
> +#ifndef CONFIG_SANITIZE_FREED_PAGES
> +	/* SANITIZE_FREED_PAGES relies implicitly on the fact that pages are
> +	 * cleared before use, so we don't need gfp zero in the default case
> +	 * because all pages go through the free_pages_prepare code path when
> +	 * switching from bootmem to the default allocator */
>  	if (gfp_flags & __GFP_ZERO)
>  		for (i = 0; i < (1 << order); i++)
>  			clear_highpage(page + i);
> +#endif

this hunk should not be applied before the hibernation fix otherwise
bisect will break.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
