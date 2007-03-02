Message-ID: <45E846AF.1050703@shadowen.org>
Date: Fri, 02 Mar 2007 15:45:51 +0000
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] Lumpy Reclaim V3
References: <exportbomb.1172604830@kernel> <96f80944962593738d72a803797dbddc@kernel> <Pine.LNX.4.64.0702281008330.21257@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0702281008330.21257@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Tue, 27 Feb 2007, Andy Whitcroft wrote:
> 
>> +static int __isolate_lru_page(struct page *page, int active)
>> +{
>> +	int ret = -EINVAL;
>> +
>> +	if (PageLRU(page) && (PageActive(page) == active)) {
>> +		ret = -EBUSY;
>> +		if (likely(get_page_unless_zero(page))) {
>> +			/*
>> +			 * Be careful not to clear PageLRU until after we're
>> +			 * sure the page is not being freed elsewhere -- the
>> +			 * page release code relies on it.
>> +			 */
>> +			ClearPageLRU(page);
>> +			ret = 0;
> 
> Is that really necessary? PageLRU is clear when a page is freed right? 
> And clearing PageLRU requires the zone->lru_lock since we have to move it 
> off the LRU.

Although the PageLRU is stable as we have the zone->lru_lock we cannot
take the page off the LRU unless we can take a reference to it
preventing it from being released.  The page release code relies on the
the caller who takes the reference count to zero having exclusive access
to the page to release it.  To prevent a race with
put_page/__page_cache_release we cannot touch the page once its count
drops to zero, which occurs before the PageLRU is cleared.  PageLRU
being sampled outside the zone->lru_lock in that path to avoid taking
the lock if not required.

> 
>> -			ClearPageLRU(page);
>> -			target = dst;
>> +		active = PageActive(page);
> 
> Why are we saving the active state? Page cannot be moved between LRUs 
> while we hold the lru lock anyways.

This is used later in the function for comparison against all of the
other pages in the 'order' sized area rooted about the target page.  Its
mearly an optimisation.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
