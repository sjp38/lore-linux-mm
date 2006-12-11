Date: Mon, 11 Dec 2006 15:29:07 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 0/4] Lumpy Reclaim V3
Message-Id: <20061211152907.f44cdd94.akpm@osdl.org>
In-Reply-To: <exportbomb.1165424343@pinky>
References: <exportbomb.1165424343@pinky>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 6 Dec 2006 16:59:04 +0000
Andy Whitcroft <apw@shadowen.org> wrote:

> This is a repost of the lumpy reclaim patch set.  This is
> basically unchanged from the last post, other than being rebased
> to 2.6.19-rc2-mm2.

The patch sequencing appeared to be designed to make the code hard to
review, so I clumped them all into a single diff:

>  
>  /*
> + * Attempt to remove the specified page from its LRU.  Only take this
> + * page if it is of the appropriate PageActive status.  Pages which
> + * are being freed elsewhere are also ignored.
> + *
> + * @page:	page to consider
> + * @active:	active/inactive flag only take pages of this type

I dunno who started adding these @'s into non-kernel-doc comments.  I'll
un-add them.

> + * returns 0 on success, -ve errno on failure.
> + */
> +int __isolate_lru_page(struct page *page, int active)
> +{
> +	int ret = -EINVAL;
> +
> +	if (PageLRU(page) && (PageActive(page) == active)) {

We hope that all architectures remember that test_bit returns 0 or
1.  We got that wrong a few years back.  What we do now is rather
un-C-like.  And potentially inefficient.  Hopefully the compiler usually
sorts it out though.


> +		ret = -EBUSY;
> +		if (likely(get_page_unless_zero(page))) {
> +			/*
> +			 * Be careful not to clear PageLRU until after we're
> +			 * sure the page is not being freed elsewhere -- the
> +			 * page release code relies on it.
> +			 */
> +			ClearPageLRU(page);
> +			ret = 0;
> +		}
> +	}
> +
> +	return ret;
> +}
> +
> +/*
>   * zone->lru_lock is heavily contended.  Some of the functions that
>   * shrink the lists perform better by taking out a batch of pages
>   * and working on them outside the LRU lock.
> @@ -621,33 +653,71 @@ keep:
>   */
>  static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  		struct list_head *src, struct list_head *dst,
> -		unsigned long *scanned)
> +		unsigned long *scanned, int order)
>  {
>  	unsigned long nr_taken = 0;
> -	struct page *page;
> -	unsigned long scan;
> +	struct page *page, *tmp;

"tmp" isn't a very good identifier.

> +	unsigned long scan, pfn, end_pfn, page_pfn;

One declaration per line is preferred.  This gives you room for a brief
comment, where appropriate.


> +		/*
> +		 * Attempt to take all pages in the order aligned region
> +		 * surrounding the tag page.  Only take those pages of
> +		 * the same active state as that tag page.
> +		 */
> +		zone_id = page_zone_id(page);
> +		page_pfn = __page_to_pfn(page);
> +		pfn = page_pfn & ~((1 << order) - 1);

Is this always true?  It assumes that the absolute value of the starting
pfn of each zone is a multiple of MAX_ORDER (doesn't it?) I don't see any
reason per-se why that has to be true (although it might be).

hm, I guess it has to be true, else hugetlb pages wouldn't work too well.

> +		end_pfn = pfn + (1 << order);
> +		for (; pfn < end_pfn; pfn++) {
> +			if (unlikely(pfn == page_pfn))
> +				continue;
> +			if (unlikely(!pfn_valid(pfn)))
> +				break;
> +
> +			tmp = __pfn_to_page(pfn);
> +			if (unlikely(page_zone_id(tmp) != zone_id))
> +				continue;
> +			scan++;
> +			switch (__isolate_lru_page(tmp, active)) {
> +			case 0:
> +				list_move(&tmp->lru, dst);
> +				nr_taken++;
> +				break;
> +
> +			case -EBUSY:
> +				/* else it is being freed elsewhere */
> +				list_move(&tmp->lru, src);
> +			default:
> +				break;
> +			}
> +		}

I think each of those

			if (expr)
				continue;

statements would benefit from a nice comment explaining why.


This physical-scan part of the function will skip pages which happen to be
on *src.  I guess that won't matter much, once the sytem has been up for a
while and the LRU is nicely scrambled.


If this function is passed a list of 32 pages, and order=4, I think it will
go and give us as many as 512 pages on *dst?  A check of nr_taken might be
needed.


The patch is pretty simple, isn't it?

I guess a shortcoming is that it doesn't address the situation where
GFP_ATOMIC network rx is trying to allocate order-2 pages for large skbs,
but kswapd doesn't know that.  AFACIT nobody will actually run the nice new
code in this quite common scenario.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
