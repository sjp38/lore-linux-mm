Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C3C666B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 04:59:30 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id k126so928876wmd.5
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 01:59:30 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p76si5055237wrb.385.2017.12.19.01.59.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Dec 2017 01:59:29 -0800 (PST)
Date: Tue, 19 Dec 2017 10:59:27 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 7/8] mm: Document how to use struct page
Message-ID: <20171219095927.GF2787@dhcp22.suse.cz>
References: <20171216164425.8703-1-willy@infradead.org>
 <20171216164425.8703-8-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171216164425.8703-8-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Matthew Wilcox <mawilcox@microsoft.com>

On Sat 16-12-17 08:44:24, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> Be really explicit about what bits / bytes are reserved for users that
> want to store extra information about the pages they allocate.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

I think that struct page would benefit from more documentation. But this
looks good to me already. Hugetlb pages abuse some fields in page[1],
page_is_pfmemalloc is abusing index and there are probably more. It
would be great to have all those described at the single place. I will
update hugetlb part along with my recent patches which are in RFC right
now. Maybe a good project for somebody who wants to learn a lot about MM
and interaction with other subsystems (or maybe not ;))

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/mm_types.h | 23 ++++++++++++++++++++++-
>  1 file changed, 22 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 1a3ba1f1605d..a517d210f177 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -31,7 +31,28 @@ struct hmm;
>   * it to keep track of whatever it is we are using the page for at the
>   * moment. Note that we have no way to track which tasks are using
>   * a page, though if it is a pagecache page, rmap structures can tell us
> - * who is mapping it.
> + * who is mapping it. If you allocate the page using alloc_pages(), you
> + * can use some of the space in struct page for your own purposes.
> + *
> + * Pages that were once in the page cache may be found under the RCU lock
> + * even after they have been recycled to a different purpose.  The page cache
> + * will read and writes some of the fields in struct page to lock the page,
> + * then check that it's still in the page cache.  It is vital that all users
> + * of struct page:
> + * 1. Use the first word as PageFlags.
> + * 2. Clear or preserve bit 0 of page->compound_head.  It is used as
> + *    PageTail for compound pages, and the page cache must not see false
> + *    positives.  Some users put a pointer here (guaranteed to be at least
> + *    4-byte aligned), other users avoid using the word altogether.
> + * 3. page->_refcount must either not be used, or must be used in such a
> + *    way that other CPUs temporarily incrementing and then decrementing the
> + *    refcount does not cause problems.  On receiving the page from
> + *    alloc_pages(), the refcount will be positive.
> + *
> + * If you allocate pages of order > 0, you can use the fields in the struct
> + * page associated with each page, but bear in mind that the pages may have
> + * been inserted individually into the page cache, so you must use the above
> + * three fields in a compatible way for each struct page.
>   *
>   * SLUB uses cmpxchg_double() to atomically update its freelist and
>   * counters.  That requires that freelist & counters be adjacent and
> -- 
> 2.15.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
