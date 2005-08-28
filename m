Subject: Re: [RFC][PATCH 0/6] CART Implementation
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20050828002519.GA26764@dmt.cnet>
References: <20050827215756.726585000@twins>
	 <20050828002519.GA26764@dmt.cnet>
Content-Type: text/plain
Date: Sun, 28 Aug 2005 10:03:30 +0200
Message-Id: <1125216210.20161.104.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 2005-08-27 at 21:25 -0300, Marcelo Tosatti wrote:

> 
> +/* This function selects the candidate and returns the corresponding
> + * struct page * or returns NULL in case no page can be freed.
> + */
> +struct page *__cart_replace(struct zone *zone)
> +{
> +	struct page *page;
> +	int referenced;
> +
> +	while (!list_empty(list_T2)) {
> +		page = list_entry(list_T2->next, struct page, lru);
> +
> +		if (!page_referenced(page, 0, 0))
> +			break;
> +
> +		del_page_from_inactive_list(zone, page);
> +		add_page_to_active_tail(zone, page);
> +		SetPageActive(page);
> +
> +		cart_q_inc(zone);
> +	}
> 
> If you find an unreferenced page in the T2 list you don't keep a reference 
> to it performing a search on the T1 list below? That looks bogus.

If the loop breaks (unreferenced page) the head page of T2 is the one.
All other pages are moved to the tail of T1, as per the Paper.

> Apart from that, both while (!list_empty(list_T2)) are problematic. If there
> are tons of referenced pages you simply loop, unlimited? 

No, max |T2| times, after that the list is simply empty. As for the
other loop, that can run the initial |T1| times until it encounteres the
first page put on the list by the previous loop, or untill it made a
full loop. page_referenced() clears the flag right?

> And what about 
> the lru lock required for dealing with page->lru ?

As the __ prefix in the name suggests it is run under zone->lru_lock.
I'll some comments.

> Look at the original algorithm: it grabs SWAP_CLUSTER_MAX pages from the inactive
> list, puts them into a CPU local list (on the stack), releases the lru lock, 
> and works on the isolated pages. You want something similar.

I do, look at patch 6 where I put this thing into action.
isolate_lru_pages() is modified to remove nr_to_scan = SWAP_CLUSTER_MAX
pages from the lists. From there on it is similar to the current code.

> As for testing, STP is really easy: 
> 
> http://www.osdl.org/lab_activities/kernel_testing/stp
> 
Thanks, I'll have a look.

Kind regards,

-- 
Peter Zijlstra <a.p.zijlstra@chello.nl>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
