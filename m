Date: Thu, 20 Sep 2007 11:26:47 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH] page->mapping clarification [1/3] base functions
In-Reply-To: <20070919164308.281f9960.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0709201120510.8801@schroedinger.engr.sgi.com>
References: <20070919164308.281f9960.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, ricknu-0@student.ltu.se
List-ID: <linux-mm.kvack.org>

On Wed, 19 Sep 2007, KAMEZAWA Hiroyuki wrote:

> Any comments are welcome.

I am still a bit confused as to what the benefit of this is.

> Following functions are added
> 
>  * page_mapping_cache() ... returns address space if a page is page cache
>  * page_mapping_anon()  ... returns anon_vma if a page is anonymous page.
>  * page_is_pagecache()  ... returns true if a page is page-cache.
>  * page_inode()         ... returns inode which a page-cache belongs to.
>  * is_page_consistent() ... returns true if a page is still valid page cache 

Ok this could make the code more readable.

> +/*
> + * On an anonymous page mapped into a user virtual memory area,
> + * page->mapping points to its anon_vma, not to a struct address_space;
> + * with the PAGE_MAPPING_ANON bit set to distinguish it.
> + *
> + * Please note that, confusingly, "page_mapping" refers to the inode
> + * address_space which maps the page from disk; whereas "page_mapped"
> + * refers to user virtual address space into which the page is mapped.
> + */
> +#define PAGE_MAPPING_ANON       1
> +
> +static inline bool PageAnon(struct page *page)

bool??? That is unusual?

> +static inline struct address_space *page_mapping_cache(struct page *page)
> +{
> +	if (!page->mapping || PageAnon(page))
> +		return NULL;
> +	return page->mapping;
> +}

That is confusing.

if (PageAnon(page))
	return NULL;
return page->mapping;


> +static inline struct address_space *page_mapping(struct page *page)
> +{
> +	struct address_space *mapping = page->mapping;
> +
> +	VM_BUG_ON(PageSlab(page));
> +	if (unlikely(PageSwapCache(page)))
> +		mapping = &swapper_space;
> +#ifdef CONFIG_SLUB
> +	else if (unlikely(PageSlab(page)))
> +		mapping = NULL;
> +#endif

The #ifdef does not exist in rc6-mm1. No need to reintroduce it.

> +static inline bool
> +is_page_consistent(struct page *page, struct address_space *mapping)
> +{
> +	struct address_space *check = page_mapping_cache(page);
> +	return (check == mapping);
> +}

Why do we need a special function? Why is it safer?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
