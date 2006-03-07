Message-ID: <440D0863.8070304@yahoo.com.au>
Date: Tue, 07 Mar 2006 15:13:23 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] avoid atomic op on page free
References: <200603070230.k272UVg18638@unix-os.sc.intel.com>
In-Reply-To: <200603070230.k272UVg18638@unix-os.sc.intel.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: Benjamin LaHaise <bcrl@linux.intel.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Chen, Kenneth W wrote:
> Nick Piggin wrote on Monday, March 06, 2006 6:05 PM
> 
>>My patches in -mm avoid the lru_lock and disabling/enabling interrupts
>>if the page is not on lru too, btw.
> 
> 
> Can you put the spin lock/unlock inside TestClearPageLRU()?  The
> difference is subtle though.
> 

That's the idea, but you just need to do a little bit more so as not to
introduce a race.

http://www.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.16-rc2/2.6.16-rc2-mm1/broken-out/mm-never-clearpagelru-released-pages.patch

> - Ken
> 
> 
> --- ./mm/swap.c.orig	2006-03-06 19:25:10.680967542 -0800
> +++ ./mm/swap.c	2006-03-06 19:27:02.334286487 -0800
> @@ -210,14 +210,16 @@ int lru_add_drain_all(void)
>  void fastcall __page_cache_release(struct page *page)
>  {
>  	unsigned long flags;
> -	struct zone *zone = page_zone(page);
> +	struct zone *zone;
>  
> -	spin_lock_irqsave(&zone->lru_lock, flags);
> -	if (TestClearPageLRU(page))
> +	if (TestClearPageLRU(page)) {
> +		zone = page_zone(page);
> +		spin_lock_irqsave(&zone->lru_lock, flags);
>  		del_page_from_lru(zone, page);
> -	if (page_count(page) != 0)
> -		page = NULL;
> -	spin_unlock_irqrestore(&zone->lru_lock, flags);
> +		if (page_count(page) != 0)
> +			page = NULL;
> +		spin_unlock_irqrestore(&zone->lru_lock, flags);
> +	}
>  	if (page)
>  		free_hot_page(page);
>  }
> 
> 


-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
