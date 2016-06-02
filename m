Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9EB816B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 11:51:54 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id o70so26117195lfg.1
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 08:51:54 -0700 (PDT)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id 99si540153lfr.277.2016.06.02.08.51.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jun 2016 08:51:53 -0700 (PDT)
Received: by mail-lf0-x244.google.com with SMTP id 65so5546284lfq.1
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 08:51:52 -0700 (PDT)
Date: Thu, 2 Jun 2016 18:51:50 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [BUG/REGRESSION] THP: broken page count after commit aa88b68c
Message-ID: <20160602155149.GB8493@node.shutemov.name>
References: <20160602172141.75c006a9@thinkpad>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160602172141.75c006a9@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christian Borntraeger <borntraeger@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

On Thu, Jun 02, 2016 at 05:21:41PM +0200, Gerald Schaefer wrote:
> Christian Borntraeger reported a kernel panic after corrupt page counts,
> and it turned out to be a regression introduced with commit aa88b68c
> "thp: keep huge zero page pinned until tlb flush", at least on s390.
> 
> put_huge_zero_page() was moved over from zap_huge_pmd() to release_pages(),
> and it was replaced by tlb_remove_page(). However, release_pages() might
> not always be triggered by (the arch-specific) tlb_remove_page().
> 
> On s390 we call free_page_and_swap_cache() from tlb_remove_page(), and not
> tlb_flush_mmu() -> free_pages_and_swap_cache() like the generic version,
> because we don't use the MMU-gather logic. Although both functions have very
> similar names, they are doing very unsimilar things, in particular
> free_page_xxx is just doing a put_page(), while free_pages_xxx calls
> release_pages().
> 
> This of course results in very harmful put_page()s on the huge zero page,
> on architectures where tlb_remove_page() is implemented in this way. It
> seems to affect only s390 and sh, but sh doesn't have THP support, so
> the problem (currently) probably only exists on s390.
> 
> The following quick hack fixed the issue:
> 
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 0d457e7..c99463a 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -252,7 +252,10 @@ static inline void free_swap_cache(struct page *page)
>  void free_page_and_swap_cache(struct page *page)
>  {
>  	free_swap_cache(page);
> -	put_page(page);
> +	if (is_huge_zero_page(page))
> +		put_huge_zero_page();
> +	else
> +		put_page(page);
>  }
>  
>  /*

The fix looks good to me.

> But of course there might be a better solution, and there still are some
> questions left:
> - Why does free_page_xxx() behave so differently from free_pages_xxx()?

I don't see it behave too deiferently. It just try to batch freeing to
lower locking overhead.

> - Would it be OK to implement free_page_xxx() by calling free_pages_xxx()
>   with nr = 1, similar to free_page() vs. free_pages()?
> - Would it be OK to replace the put_page() in free_page_xxx() with a call
>   to release_pages() with nr = 1?

release_pages() somewhat suboptimal for nr=1. I guess we can fix this with
shortcut to put_page() at start of release_page() if nr == 1.

> - Would it be better to fix this in the arch-specific tlb_remove_page(),
>   by calling free_pages_xxx() with nr = 1 instead of free_page_xxx()?
> 
> Regards,
> Gerald
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
