Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id CE54B6B004D
	for <linux-mm@kvack.org>; Thu, 10 May 2012 20:34:30 -0400 (EDT)
Message-ID: <4FAC5EA1.5040201@kernel.org>
Date: Fri, 11 May 2012 09:34:41 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: is there a "lru_cache_add_anon_tail"?
References: <66ea94b0-2e40-44d1-9621-05f2a8257298@default>
In-Reply-To: <66ea94b0-2e40-44d1-9621-05f2a8257298@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-mm@kvack.org

On 05/11/2012 01:13 AM, Dan Magenheimer wrote:

> (Still working on allowing zcache to "evict" swap pages...)
> 
> Apologies if I got head/tail reversed as used by the
> lru queues... the "directional sense" of the queues is
> not obvious so I'll describe using different terminology...
> 
> If I have an anon page and I would like to add it to
> the "reclaim soonest" end of the queue instead of the
> "most recently used so don't reclaim it for a long time"
> end of the queue, does an equivalent function similar to
> lru_cache_add_anon(page) exist?


Nope. 

> 
> In other words, I want this dirty anon page to be
> swapped out ASAP.


Why do you want to do that at the cost of ignoring of LRU ordering?

> 
> If no such function exists, can anyone more familiar
> with the VM LRU queues suggest the code for
> this function "lru_cache_add_anon_XXX(page)?
> Also what would be the proper text for XXX?


tail

> 
> I have some (experimental) code now to use it so
> could iterate/debug with any suggested code.  The
> calling snippet is:
> 
> 	__set_page_locked(new_page);
> 	SetPageSwapBacked(new_page);
> 	ret = __add_to_swap_cache(new_page, entry);
> 	if (likely(!ret)) {
> 		radix_tree_preload_end();
> 		lru_cache_add_anon_XXX(new_page)
> 		if (frontswap_get_page(new_page) = 0)
> 			SetPageUptodate(new_page);
> 		unlock_page(new_page);
> 
> This works using a call to the existing lru_cache_add_anon
> but new_page doesn't get swapped out for a long time.


Yes. it's to add the page to "most recently used so don't reclaim it for a long time" in your terms.
Adding new lru_cache_add_anon_tail isn't difficult but we need justification why we should do.

> 
> Thanks for any help/suggestions!
> Dan
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=ilto:"dont@kvack.org"> email@kvack.org </a>
> 

qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
