Date: Wed, 25 Apr 2007 12:20:51 +0100
Subject: Re: [RFC 05/16] Variable Order Page Cache: Add functions to establish sizes
Message-ID: <20070425112051.GD19942@skynet.ie>
References: <20070423064845.5458.2190.sendpatchset@schroedinger.engr.sgi.com> <20070423064911.5458.40889.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20070423064911.5458.40889.sendpatchset@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, William Lee Irwin III <wli@holomorphy.com>, Jens Axboe <jens.axboe@oracle.com>, David Chinner <dgc@sgi.com>, Badari Pulavarty <pbadari@gmail.com>, Adam Litke <aglitke@gmail.com>, Avi Kivity <avi@argo.co.il>, Dave Hansen <hansendc@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On (22/04/07 23:49), Christoph Lameter didst pronounce:
> Variable Order Page Cache: Add functions to establish sizes
> 
> We use the macros PAGE_CACHE_SIZE PAGE_CACHE_SHIFT PAGE_CACHE_MASK
> and PAGE_CACHE_ALIGN in various places in the kernel. These are now
> the base page size but we do not have a means to calculating these
> values for higher order pages.
> 
> Provide these functions. An address_space pointer must be passed
> to them. Also add a set of extended functions that will be used
> to consolidate the hand crafted shifts and adds in use right
> now for the page cache.
> 
> New function			Related base page constant
> ---------------------------------------------------
> page_cache_shift(a)		PAGE_CACHE_SHIFT
> page_cache_size(a)		PAGE_CACHE_SIZE
> page_cache_mask(a)		PAGE_CACHE_MASK
> page_cache_index(a, pos)	Calculate page number from position
> page_cache_next(addr, pos)	Page number of next page
> page_cache_offset(a, pos)	Calculate offset into a page
> page_cache_pos(a, index, offset)
> 				Form position based on page number
> 				and an offset.

These all need comments in the source, particularly page_cache_index() so
that it is clear that the index is "number of compound pages", not number
of base pages. With the name as-is, it could be either.  page_cache_offset()
requires similar mental gymnastics to understand without some sort of comment.

The comments will help break people away from page == base page mental
models.

> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> ---
>  include/linux/pagemap.h |   42 ++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 42 insertions(+)
> 
> Index: linux-2.6.21-rc7/include/linux/pagemap.h
> ===================================================================
> --- linux-2.6.21-rc7.orig/include/linux/pagemap.h	2007-04-22 17:30:50.000000000 -0700
> +++ linux-2.6.21-rc7/include/linux/pagemap.h	2007-04-22 19:44:12.000000000 -0700
> @@ -62,6 +62,48 @@ static inline void set_mapping_order(str
>  #define PAGE_CACHE_MASK		PAGE_MASK
>  #define PAGE_CACHE_ALIGN(addr)	(((addr)+PAGE_CACHE_SIZE-1)&PAGE_CACHE_MASK)
>  
> +static inline int page_cache_shift(struct address_space *a)
> +{
> +	return a->order + PAGE_SHIFT;
> +}
> +
> +static inline unsigned int page_cache_size(struct address_space *a)
> +{
> +	return PAGE_SIZE << a->order;
> +}
> +
> +static inline loff_t page_cache_mask(struct address_space *a)
> +{
> +	return (loff_t)PAGE_MASK << a->order;
> +}
> +
> +static inline unsigned int page_cache_offset(struct address_space *a,
> +		loff_t pos)
> +{
> +	return pos & ~(PAGE_MASK << a->order);
> +}
> +
> +static inline pgoff_t page_cache_index(struct address_space *a,
> +		loff_t pos)
> +{
> +	return pos >> page_cache_shift(a);
> +}

Like that needs peering at without a comment.

> +
> +/*
> + * Index of the page starting on or after the given position.
> + */
> +static inline pgoff_t page_cache_next(struct address_space *a,
> +		loff_t pos)
> +{
> +	return page_cache_index(a, pos + page_cache_size(a) - 1);
> +}
> +

Would help if "Index of the page" read as "Index of the compound page" with
an additional note saying that the compound page size will be a base page
in the majority of cases. Otherwise, someone unfamiliar with this idea will
wonder what's wrong with page++.

> +static inline loff_t page_cache_pos(struct address_space *a,
> +		pgoff_t index, unsigned long offset)
> +{
> +	return ((loff_t)index << page_cache_shift(a)) + offset;
> +}
> +
>  #define page_cache_get(page)		get_page(page)
>  #define page_cache_release(page)	put_page(page)
>  void release_pages(struct page **pages, int nr, int cold);

-- 
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
