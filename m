Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 66E3B6B0038
	for <linux-mm@kvack.org>; Sun, 26 Apr 2015 16:12:28 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so106467987pac.1
        for <linux-mm@kvack.org>; Sun, 26 Apr 2015 13:12:28 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id ka1si26692052pbc.194.2015.04.26.13.12.27
        for <linux-mm@kvack.org>;
        Sun, 26 Apr 2015 13:12:27 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 2/2] mm/page_alloc.c: add config option to sanitize freed pages
References: <1429909549-11726-1-git-send-email-anisse@astier.eu>
	<1429909549-11726-3-git-send-email-anisse@astier.eu>
Date: Sun, 26 Apr 2015 13:12:26 -0700
In-Reply-To: <1429909549-11726-3-git-send-email-anisse@astier.eu> (Anisse
	Astier's message of "Fri, 24 Apr 2015 23:05:49 +0200")
Message-ID: <87tww2ejit.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anisse Astier <anisse@astier.eu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Kees Cook <keescook@chromium.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Anisse Astier <anisse@astier.eu> writes:
> +	  If unsure, say N.
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 05fcec9..c71440a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -803,6 +803,11 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
>  		debug_check_no_obj_freed(page_address(page),
>  					   PAGE_SIZE << order);
>  	}
> +
> +#ifdef CONFIG_SANITIZE_FREED_PAGES
> +	zero_pages(page, order);
> +#endif

And not removing the clear on __GFP_ZERO by remembering that?

That means all clears would be done twice. 

That patch is far too simple. Clearing is commonly the most
expensive kernel operation.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
