From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: Fw: [PATCH] Add alloc_pages_exact() and free_pages_exact()
Date: Wed, 25 Jun 2008 11:39:50 +1000
References: <20080624135750.0c59c6b9.akpm@linux-foundation.org>
In-Reply-To: <20080624135750.0c59c6b9.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200806251139.51142.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Timur Tabi <timur@freescale.com>
List-ID: <linux-mm.kvack.org>

On Wednesday 25 June 2008 06:57, Andrew Morton wrote:
> I'm applying this.

Fine. And IIRC there are one or two places around the kernel that
could be converted to use it. Why not just have a node id
argument and call it alloc_pages_node_exact? so Christoph doesn't
have to do it himself ;)

Maybe you could also say that __GFP_COMPOUND cannot be used, and
that the returned pages are "split" (work the same way as N
indivudually allocated order-0 pages WRT refcounting).


> Begin forwarded message:
>
> Date: Tue, 24 Jun 2008 11:40:49 -0500
> From: Timur Tabi <timur@freescale.com>
> To: linux-kernel@vger.kernel.org, andi@firstfloor.org,
> randy.dunlap@oracle.com, corbet@lwn.net, torvalds@linux-foundation.org
> Subject: [PATCH] Add alloc_pages_exact() and free_pages_exact()
>
>
> alloc_pages_exact() is similar to alloc_pages(), except that it allocates
> the minimum number of pages to fulfill the request.  This is useful if you
> want to allocate a very large buffer that is slightly larger than an
> even power-of-two number of pages.  In that case, alloc_pages() will waste
> a lot of memory.
>
> Signed-off-by: Timur Tabi <timur@freescale.com>
> ---
>
> I have a video driver that wants to allocate a 5MB buffer.  alloc_pages()
> will waste 3MB of physically-contiguous memory.  Therefore, I would
> like to see alloc_pages_exact() added to 2.6.27.
>
> Please note that I am not a Linux VM expert.  I wrote these functions based
> on guidance from Andi Kleen.  I have no familiarity with NUMA, so I don't
> know how to handle that.  Any and all suggestions are welcome.
>
>  include/linux/gfp.h |    3 ++
>  mm/page_alloc.c     |   53
> +++++++++++++++++++++++++++++++++++++++++++++++++++ 2 files changed, 56
> insertions(+), 0 deletions(-)
>
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index b414be3..1054801 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -215,6 +215,9 @@ extern struct page *alloc_page_vma(gfp_t gfp_mask,
>  extern unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order);
>  extern unsigned long get_zeroed_page(gfp_t gfp_mask);
>
> +void *alloc_pages_exact(size_t size, gfp_t gfp_mask);
> +void free_pages_exact(void *virt, size_t size);
> +
>  #define __get_free_page(gfp_mask) \
>  		__get_free_pages((gfp_mask),0)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 2f55295..08bf9d7 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1711,6 +1711,59 @@ void free_pages(unsigned long addr, unsigned int
> order)
>
>  EXPORT_SYMBOL(free_pages);
>
> +/**
> + * alloc_pages_exact - allocate an exact number physically-contiguous
> pages. + * @size: the number of bytes to allocate
> + * @gfp_mask: GFP flags for the allocation
> + *
> + * This function is similar to alloc_pages(), except that it allocates the
> + * minimum number of pages to satisfy the request.  alloc_pages() can only
> + * allocate memory in power-of-two pages.
> + *
> + * This function is also limited by MAX_ORDER.
> + *
> + * Memory allocated by this function must be released by
> free_pages_exact(). + */
> +void *alloc_pages_exact(size_t size, gfp_t gfp_mask)
> +{
> +	unsigned int order = get_order(size);
> +	unsigned long addr;
> +
> +	addr = __get_free_pages(gfp_mask, order);
> +	if (addr) {
> +		unsigned long alloc_end = addr + (PAGE_SIZE << order);
> +		unsigned long used = addr + PAGE_ALIGN(size);
> +
> +		split_page(virt_to_page(addr), order);
> +		while (used < alloc_end) {
> +			free_page(used);
> +			used += PAGE_SIZE;
> +		}
> +	}
> +
> +	return (void *)addr;
> +}
> +EXPORT_SYMBOL(alloc_pages_exact);
> +
> +/**
> + * free_pages_exact - release memory allocated via alloc_pages_exact()
> + * @virt: the value returned by alloc_pages_exact.
> + * @size: size of allocation, same value as passed to alloc_pages_exact().
> + *
> + * Release the memory allocated by a previous call to alloc_pages_exact.
> + */
> +void free_pages_exact(void *virt, size_t size)
> +{
> +	unsigned long addr = (unsigned long)virt;
> +	unsigned long end = addr + PAGE_ALIGN(size);
> +
> +	while (addr < end) {
> +		free_page(addr);
> +		addr += PAGE_SIZE;
> +	}
> +}
> +EXPORT_SYMBOL(free_pages_exact);
> +
>  static unsigned int nr_free_zone_pages(int offset)
>  {
>  	struct zoneref *z;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
