Date: Sat, 21 Apr 2007 01:24:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/3] lumpy: increase pressure at the end of the inactive
 list
Message-Id: <20070421012409.86e06f00.akpm@linux-foundation.org>
In-Reply-To: <6476c564e476b1038584ea2ed39f2b7e@pinky>
References: <exportbomb.1177081388@pinky>
	<6476c564e476b1038584ea2ed39f2b7e@pinky>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Fri, 20 Apr 2007 16:04:04 +0100 Andy Whitcroft <apw@shadowen.org> wrote:

> 
> Having selected an area at the end of the inactive list, reclaim is
> attempted for all LRU pages within that contiguous area.  Currently,
> any pages in this area found to still be active or referenced are
> rotated back to the active list as normal and the rest reclaimed.
> At low orders there is a reasonable likelyhood of finding contigious
> inactive areas for reclaim.  However when reclaiming at higher order
> there is a very low chance all pages in the area being inactive,
> unreferenced and therefore reclaimable.
> 
> This patch modifies behaviour when reclaiming at higher order
> (order >= 4).  All LRU pages within the target area are reclaimed,
> including both active and recently referenced pages.

um, OK, I guess.

Should we use smaller values of 4 if PAGE_SIZE > 4k?  I mean, users of the
page allocator usually request a number of bytes, not a number of pages. 
Order 3 allocations on 64k pagesize will be far less common than on 4k
pagesize, no?

And is there a relationship between this magic 4 and the magic 3 in
__alloc_pages()?  (Which has the same PAGE_SIZE problem, btw)



I must say that this is a pretty grotty-looking patch.


> [mel@csn.ul.ie: additionally apply pressure to referenced paged]
> Signed-off-by: Andy Whitcroft <apw@shadowen.org>
> Acked-by: Mel Gorman <mel@csn.ul.ie>
> ---
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 466435f..e5e77fb 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -472,7 +472,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  
>  		referenced = page_referenced(page, 1);
>  		/* In active use or really unfreeable?  Activate it. */
> -		if (referenced && page_mapping_inuse(page))
> +		if (sc->order <= 3 && referenced && page_mapping_inuse(page))

The oft-occurring magic "3" needs a #define.

> @@ -599,6 +599,7 @@ keep:
>   *
>   * returns 0 on success, -ve errno on failure.
>   */
> +#define ISOLATE_BOTH -1		/* Isolate both active and inactive pages. */
>  static int __isolate_lru_page(struct page *page, int active)
>  {
>  	int ret = -EINVAL;
> @@ -608,7 +609,8 @@ static int __isolate_lru_page(struct page *page, int active)
>  	 * dealing with comparible boolean values.  Take the logical not
>  	 * of each.
>  	 */
> -	if (PageLRU(page) && (!PageActive(page) == !active)) {
> +	if (PageLRU(page) && (active == ISOLATE_BOTH ||
> +					(!PageActive(page) == !active))) {

So we have a nice enumerated value but we only half-use it: sometimes we
implicitly assume that ISOLATE_BOTH has a non-zero value, which rather
takes away from the whole point of creating ISOLATE_BOTH in the first
place.

Cleaner to do:

#define ISOLATE_INACTIVE	0
#define ISOLATE_ACTIVE		1
#define ISOLATE_BOTH		2

	if (!PageLRU(page))
		return;			/* save a tabstop! */

	if (active != ISOLATE_BOTH) {
		if (PageActive(page) && active != ISOLATE_ACTIVE)
			return;
		if (!PageActive(page) && active != ISOLATE_INACTIVE)
			return;
	}

	<isolate the page>

or some such.  At present it is all very confused.


And the comment describing the `active' arg to __isolate_lru_page() needs
to be updated.

And the name `active' is now clearly inappropriate.  It needs to be renamed
`mode' or something.


>  		ret = -EBUSY;
>  		if (likely(get_page_unless_zero(page))) {
>  			/*
> @@ -729,6 +731,26 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  }
>  
>  /*
> + * deactivate_pages() is a helper for shrink_active_list(), it deactivates
> + * all active pages on the passed list.
> + */
> +static unsigned long deactivate_pages(struct list_head *page_list)

The phrase "deactivate a page" normally means "move it from the active list
to the inactive list".  But that isn't what this function does.  Something
like clear_active_flags(), maybe?

> +{
> +	int nr_active = 0;
> +	struct list_head *entry;
> +
> +	list_for_each(entry, page_list) {
> +		struct page *page = list_entry(entry, struct page, lru);

list_for_each_entry()?

> +		if (PageActive(page)) {
> +			ClearPageActive(page);
> +			nr_active++;
> +		}
> +	}
> +
> +	return nr_active;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
