Message-ID: <45BDE76E.6020109@shadowen.org>
Date: Mon, 29 Jan 2007 12:24:14 +0000
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] Lumpy Reclaim V3
References: <exportbomb.1165424343@pinky> <20061211152907.f44cdd94.akpm@osdl.org>
In-Reply-To: <20061211152907.f44cdd94.akpm@osdl.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Wed, 6 Dec 2006 16:59:04 +0000
> Andy Whitcroft <apw@shadowen.org> wrote:
>
>> This is a repost of the lumpy reclaim patch set.  This is
>> basically unchanged from the last post, other than being rebased
>> to 2.6.19-rc2-mm2.
>
> The patch sequencing appeared to be designed to make the code hard to
> review, so I clumped them all into a single diff:
>
>>
>>  /*
>> + * Attempt to remove the specified page from its LRU.  Only take this
>> + * page if it is of the appropriate PageActive status.  Pages which
>> + * are being freed elsewhere are also ignored.
>> + *
>> + * @page:	page to consider
>> + * @active:	active/inactive flag only take pages of this type
>
> I dunno who started adding these @'s into non-kernel-doc comments.  I'll
> un-add them.
>
>> + * returns 0 on success, -ve errno on failure.
>> + */
>> +int __isolate_lru_page(struct page *page, int active)
>> +{
>> +	int ret = -EINVAL;
>> +
>> +	if (PageLRU(page) && (PageActive(page) == active)) {
>
> We hope that all architectures remember that test_bit returns 0 or
> 1.  We got that wrong a few years back.  What we do now is rather
> un-C-like.  And potentially inefficient.  Hopefully the compiler usually
> sorts it out though.

With the code as it is in this patch this is safe as there is an
uncommented assumption that the active parameter is actually also the
return from a call to PageActive and therefore should be comparible
regardless of value.  However, as you also point out elsewhere we are in
fact looking that active value up every time we spin the search loop,
firstly doing it loads more than required, and second potentially when
unlucky actually picking the wrong value from a page in transition and
doing bad things.  Thus we will be moving to being explicit at the
isolate_lru_pages level, at which point there will be risk here.  We
will need to coax each of these to booleans before comparison.

>
>
>> +		ret = -EBUSY;
>> +		if (likely(get_page_unless_zero(page))) {
>> +			/*
>> +			 * Be careful not to clear PageLRU until after we're
>> +			 * sure the page is not being freed elsewhere -- the
>> +			 * page release code relies on it.
>> +			 */
>> +			ClearPageLRU(page);
>> +			ret = 0;
>> +		}
>> +	}
>> +
>> +	return ret;
>> +}
>> +
>> +/*
>>   * zone->lru_lock is heavily contended.  Some of the functions that
>>   * shrink the lists perform better by taking out a batch of pages
>>   * and working on them outside the LRU lock.
>> @@ -621,33 +653,71 @@ keep:
>>   */
>>  static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>>  		struct list_head *src, struct list_head *dst,
>> -		unsigned long *scanned)
>> +		unsigned long *scanned, int order)
>>  {
>>  	unsigned long nr_taken = 0;
>> -	struct page *page;
>> -	unsigned long scan;
>> +	struct page *page, *tmp;
>
> "tmp" isn't a very good identifier.
>
>> +	unsigned long scan, pfn, end_pfn, page_pfn;
>
> One declaration per line is preferred.  This gives you room for a brief
> comment, where appropriate.

All true, I've folded your cleanups into the base code, they are clearly
better.

>
>
>> +		/*
>> +		 * Attempt to take all pages in the order aligned region
>> +		 * surrounding the tag page.  Only take those pages of
>> +		 * the same active state as that tag page.
>> +		 */
>> +		zone_id = page_zone_id(page);
>> +		page_pfn = __page_to_pfn(page);
>> +		pfn = page_pfn & ~((1 << order) - 1);
>
> Is this always true?  It assumes that the absolute value of the starting
> pfn of each zone is a multiple of MAX_ORDER (doesn't it?) I don't see any
> reason per-se why that has to be true (although it might be).

Yes this is always true, the buddy guarentees that the struct pages are
valid and present out to MAX_ORDER around any known valid page.  The
zone boundary _may_ (rarely) not be MAX_ORDER aligned, but thats ok as
we will detect that below when we check for the page_zone_id matching
the cursor page's zone_id; should it not bail.

I've added some commentary about the assumptions on which we are relying
here.

> hm, I guess it has to be true, else hugetlb pages wouldn't work too well.

Well its mostly true, but if you remember the zone rounding patches we
decided the check was so cheap as we can simply can compare the zone ids
on the pages which is in the page_flags which we are touching anyhow.

The code below (.+9) maintains this check for this situation.  I've
added commentry to the code to say what its for.

>
>> +		end_pfn = pfn + (1 << order);
>> +		for (; pfn < end_pfn; pfn++) {
>> +			if (unlikely(pfn == page_pfn))
>> +				continue;
>> +			if (unlikely(!pfn_valid(pfn)))
>> +				break;
>> +
>> +			tmp = __pfn_to_page(pfn);
>> +			if (unlikely(page_zone_id(tmp) != zone_id))
>> +				continue;
>> +			scan++;
>> +			switch (__isolate_lru_page(tmp, active)) {
>> +			case 0:
>> +				list_move(&tmp->lru, dst);
>> +				nr_taken++;
>> +				break;
>> +
>> +			case -EBUSY:
>> +				/* else it is being freed elsewhere */
>> +				list_move(&tmp->lru, src);
>> +			default:
>> +				break;
>> +			}
>> +		}
>
> I think each of those
>
> 			if (expr)
> 				continue;
>
> statements would benefit from a nice comment explaining why.

Yes, I've added commentary for each of these, they seem obvious the day
you write them, and not a month later.

>
>
> This physical-scan part of the function will skip pages which happen to be
> on *src.  I guess that won't matter much, once the sytem has been up for a
> while and the LRU is nicely scrambled.
>
>
> If this function is passed a list of 32 pages, and order=4, I think it
will
> go and give us as many as 512 pages on *dst?  A check of nr_taken might be
> needed.

If we ask to scan 32 pages we may scan more pages should 1<<order be
greater than 32.  However, if we are not going to scan at least 1 block
at the order we requested then there is no point even in starting.  We
would not be in direct reclaim (which is the only way order may be
non-0) so we really do want any scan to be at least 1 block else its a
no-op and should be stopped early -- at least that seems sane?

> The patch is pretty simple, isn't it?
>
> I guess a shortcoming is that it doesn't address the situation where
> GFP_ATOMIC network rx is trying to allocate order-2 pages for large skbs,
> but kswapd doesn't know that.  AFACIT nobody will actually run the
nice new
> code in this quite common scenario.
>

That is an issue.  Will see what we can do about that.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
