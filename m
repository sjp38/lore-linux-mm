Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id D627E6B0005
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 19:32:52 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id r21-v6so2940844ioc.18
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 16:32:52 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id n14-v6si2027870ion.1.2018.04.18.16.32.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 18 Apr 2018 16:32:50 -0700 (PDT)
From: Randy Dunlap <rdunlap@infradead.org>
Subject: [PATCH v3 12/14] mm: Improve struct page documentation
References: <20180418184912.2851-1-willy@infradead.org>
 <20180418184912.2851-13-willy@infradead.org>
Message-ID: <f8606c8e-8fa6-da3d-676e-8ae36bae1ce7@infradead.org>
Date: Wed, 18 Apr 2018 16:32:27 -0700
MIME-Version: 1.0
In-Reply-To: <20180418184912.2851-13-willy@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

On 04/18/18 11:49, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> Rewrite the documentation to describe what you can use in struct
> page rather than what you can't.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> ---
>  include/linux/mm_types.h | 40 +++++++++++++++++++---------------------
>  1 file changed, 19 insertions(+), 21 deletions(-)
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 080ea97ad444..13c25b16913d 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -33,29 +33,27 @@ struct hmm;
>   * it to keep track of whatever it is we are using the page for at the
>   * moment. Note that we have no way to track which tasks are using
>   * a page, though if it is a pagecache page, rmap structures can tell us
> - * who is mapping it. If you allocate the page using alloc_pages(), you
> - * can use some of the space in struct page for your own purposes.
> + * who is mapping it.
>   *
> - * Pages that were once in the page cache may be found under the RCU lock
> - * even after they have been recycled to a different purpose.  The page
> - * cache reads and writes some of the fields in struct page to pin the
> - * page before checking that it's still in the page cache.  It is vital
> - * that all users of struct page:
> - * 1. Use the first word as PageFlags.
> - * 2. Clear or preserve bit 0 of page->compound_head.  It is used as
> - *    PageTail for compound pages, and the page cache must not see false
> - *    positives.  Some users put a pointer here (guaranteed to be at least
> - *    4-byte aligned), other users avoid using the field altogether.
> - * 3. page->_refcount must either not be used, or must be used in such a
> - *    way that other CPUs temporarily incrementing and then decrementing the
> - *    refcount does not cause problems.  On receiving the page from
> - *    alloc_pages(), the refcount will be positive.
> - * 4. Either preserve page->_mapcount or restore it to -1 before freeing it.
> + * If you allocate the page using alloc_pages(), you can use some of the
> + * space in struct page for your own purposes.  The five words in the first

Using "first union" here...

> + * union are available, except for bit 0 of the first word which must be
> + * kept clear.  Many users use this word to store a pointer to an object
> + * which is guaranteed to be aligned.  If you use the same storage as
> + * page->mapping, you must restore it to NULL before freeing the page.
>   *
> - * If you allocate pages of order > 0, you can use the fields in the struct
> - * page associated with each page, but bear in mind that the pages may have
> - * been inserted individually into the page cache, so you must use the above
> - * four fields in a compatible way for each struct page.
> + * If your page will not be mapped to userspace, you can also use the 4
> + * bytes in the second union, but you must call page_mapcount_reset()

and "second union" here bother me, but it looks like they are anonymous.

I'm concerned about someone other than you modifying struct page at some
later time.  If these unions were named (and you could use that name here
instead of "first" or "second"), then there would be less chance for that
next person to miss modifying that comment or it just becoming stale.


Reviewed-by: Randy Dunlap <rdunlap@infradead.org>

> + * before freeing it.
> + *
> + * If you want to use the refcount field, it must be used in such a way
> + * that other CPUs temporarily incrementing and then decrementing the
> + * refcount does not cause problems.  On receiving the page from
> + * alloc_pages(), the refcount will be positive.
> + *
> + * If you allocate pages of order > 0, you can use some of the fields
> + * in each subpage, but you may need to restore some of their values
> + * afterwards.
>   *
>   * SLUB uses cmpxchg_double() to atomically update its freelist and
>   * counters.  That requires that freelist & counters be adjacent and

-- 
~Randy
