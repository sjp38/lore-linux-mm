Message-ID: <46E99B48.6050106@student.ltu.se>
Date: Thu, 13 Sep 2007 22:19:20 +0200
From: Richard Knutsson <ricknu-0@student.ltu.se>
MIME-Version: 1.0
Subject: Re: [PATCH] add page->mapping handling interface [1/35] interface
 definitions
References: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com> <20070910184239.e1f705c9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070910184239.e1f705c9.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
>  - changes page->mapping from address_space* to unsigned long
>  - add page_mapping_anon() function.
>  - add linux/page-cache.h
>  - add page_inode() function
>  - add page_is_pagecache() function
>  - add pagecaceh_consisten() function for pagecache consistency test.
>  - expoterd swapper_space. inline function page_mapping() refers this.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> ---
>  include/linux/fs.h         |    1 +
>  include/linux/mm.h         |   20 +++++++++++++++++---
>  include/linux/mm_types.h   |    2 +-
>  include/linux/page-cache.h |   39 +++++++++++++++++++++++++++++++++++++++
>  mm/swap_state.c            |    2 ++
>  5 files changed, 60 insertions(+), 4 deletions(-)
>
> Index: test-2.6.23-rc4-mm1/include/linux/page-cache.h
> ===================================================================
> --- /dev/null
> +++ test-2.6.23-rc4-mm1/include/linux/page-cache.h
> @@ -0,0 +1,39 @@
> +/*
> + * For interface definitions between memory management and file systems.
> + * - This file defines small interface functions for handling page cache.
> + */
> +
> +#ifndef _LINUX_PAGECACHE_H
> +#define _LINUX_PAGECACHE_H
> +
> +#include <linux/mm.h>
> +/* page_mapping_xxx() function is defined in mm.h */
> +
> +static inline int page_is_pagecache(struct page *page)
>   
Why return it as an 'int' instead of 'bool'?
> +{
> +	if (!page->mapping || (page->mapping & PAGE_MAPPING_ANON))
> +		return 0;
> +	return 1;
> +}
>   
Not easier with 'return page->mapping && (page->mapping & 
PAGE_MAPPING_ANON) == 0;'?
> +
> +/*
> + * Return an inode this page belongs to
> + */
> +
> +static inline struct inode *page_inode(struct page *page)
> +{
> +	if (!page_is_pagecache(page))
> +		return NULL;
> +	return page_mapping_cache(page)->host;
> +}
> +
> +/*
> + * Test a page is a page-cache of an address_space.
> + */
> +static inline int
> +pagecache_consistent(struct page *page, struct address_space *as)
> +{
> +	return (page_mapping(page) == as);
> +}
> +
> +#endif
<snip>
> Index: test-2.6.23-rc4-mm1/include/linux/mm.h
> ===================================================================
> --- test-2.6.23-rc4-mm1.orig/include/linux/mm.h
> +++ test-2.6.23-rc4-mm1/include/linux/mm.h
> @@ -563,7 +563,7 @@ void page_address_init(void);
>  extern struct address_space swapper_space;
>  static inline struct address_space *page_mapping(struct page *page)
>  {
> -	struct address_space *mapping = page->mapping;
> +	struct address_space *mapping = (struct address_space *)page->mapping;
>  
>  	VM_BUG_ON(PageSlab(page));
>  	if (unlikely(PageSwapCache(page)))
> @@ -579,7 +579,21 @@ static inline struct address_space *page
>  
>  static inline int PageAnon(struct page *page)
>   
Change to bool? Then "you" can also remove the '!!' from:
mm/memory.c:483:                rss[!!PageAnon(page)]++;
>  {
> -	return ((unsigned long)page->mapping & PAGE_MAPPING_ANON) != 0;
> +	return (page->mapping & PAGE_MAPPING_ANON) != 0;
> +}
> +
>   
<snip>

If you don't mind bool(eans) (for some reason), I can/will check out the 
rest.

Richard Knutsson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
