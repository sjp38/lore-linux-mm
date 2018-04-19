Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 961316B0005
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 05:04:27 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id c56-v6so4461062wrc.5
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 02:04:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g78si2536439wmc.162.2018.04.19.02.04.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Apr 2018 02:04:26 -0700 (PDT)
Subject: Re: [PATCH v3 02/14] mm: Split page_type out from _mapcount
References: <20180418184912.2851-1-willy@infradead.org>
 <20180418184912.2851-3-willy@infradead.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <dba1674f-6126-8cce-4730-24d69e594c97@suse.cz>
Date: Thu, 19 Apr 2018 11:04:23 +0200
MIME-Version: 1.0
In-Reply-To: <20180418184912.2851-3-willy@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>

On 04/18/2018 08:49 PM, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> We're already using a union of many fields here, so stop abusing the
> _mapcount and make page_type its own field.  That implies renaming some
> of the machinery that creates PageBuddy, PageBalloon and PageKmemcg;
> bring back the PG_buddy, PG_balloon and PG_kmemcg names.
> 
> As suggested by Kirill, make page_type a bitmask.  Because it starts out
> life as -1 (thanks to sharing the storage with _mapcount), setting a
> page flag means clearing the appropriate bit.  This gives us space for
> probably twenty or so extra bits (depending how paranoid we want to be
> about _mapcount underflow).
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  include/linux/mm_types.h   | 13 ++++++-----
>  include/linux/page-flags.h | 45 ++++++++++++++++++++++----------------
>  kernel/crash_core.c        |  1 +
>  mm/page_alloc.c            | 13 +++++------
>  scripts/tags.sh            |  6 ++---
>  5 files changed, 43 insertions(+), 35 deletions(-)

...

> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index e34a27727b9a..8c25b28a35aa 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -642,49 +642,56 @@ PAGEFLAG_FALSE(DoubleMap)
>  #endif
>  
>  /*
> - * For pages that are never mapped to userspace, page->mapcount may be
> - * used for storing extra information about page type. Any value used
> - * for this purpose must be <= -2, but it's better start not too close
> - * to -2 so that an underflow of the page_mapcount() won't be mistaken
> - * for a special page.
> + * For pages that are never mapped to userspace (and aren't PageSlab),
> + * page_type may be used.  Because it is initialised to -1, we invert the
> + * sense of the bit, so __SetPageFoo *clears* the bit used for PageFoo, and
> + * __ClearPageFoo *sets* the bit used for PageFoo.  We reserve a few high and
> + * low bits so that an underflow or overflow of page_mapcount() won't be
> + * mistaken for a page type value.
>   */
> -#define PAGE_MAPCOUNT_OPS(uname, lname)					\
> +
> +#define PAGE_TYPE_BASE	0xf0000000
> +/* Reserve		0x0000007f to catch underflows of page_mapcount */
> +#define PG_buddy	0x00000080
> +#define PG_balloon	0x00000100
> +#define PG_kmemcg	0x00000200
> +
> +#define PageType(page, flag)						\
> +	((page->page_type & (PAGE_TYPE_BASE | flag)) == PAGE_TYPE_BASE)
> +
> +#define PAGE_TYPE_OPS(uname, lname)					\
>  static __always_inline int Page##uname(struct page *page)		\
>  {									\
> -	return atomic_read(&page->_mapcount) ==				\
> -				PAGE_##lname##_MAPCOUNT_VALUE;		\
> +	return PageType(page, PG_##lname);				\
>  }									\
>  static __always_inline void __SetPage##uname(struct page *page)		\
>  {									\
> -	VM_BUG_ON_PAGE(atomic_read(&page->_mapcount) != -1, page);	\
> -	atomic_set(&page->_mapcount, PAGE_##lname##_MAPCOUNT_VALUE);	\
> +	VM_BUG_ON_PAGE(!PageType(page, 0), page);			\

I think this debug test does less than you expect? IIUC you want to
check that no type is yet set, but this will only trigger if something
cleared one of the bits in top 0xf byte of PAGE_TYPE_BASE?
Just keep the comparison to -1 then?
