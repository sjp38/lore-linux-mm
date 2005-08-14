Subject: Re: Zoned CART
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20050812230825.GB11168@dmt.cnet>
References: <1123857429.14899.59.camel@twins>
	 <42FCC359.20200@andrew.cmu.edu>  <20050812230825.GB11168@dmt.cnet>
Content-Type: text/plain
Date: Sun, 14 Aug 2005 20:31:05 +0200
Message-Id: <1124044265.30836.32.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Rahul Iyer <rni@andrew.cmu.edu>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2005-08-12 at 20:08 -0300, Marcelo Tosatti wrote:

> +/* The replace function. This function serches the active and longterm
> +lists and looks for a candidate for replacement. This function selects
> +the candidate and returns the corresponding structpage or returns
> +NULL in case no page can be freed. The *where argument is used to
> +indicate the parent list of the page so that, in case it cannot be
> +written back, it can be placed back on the correct list */ 
> +struct page *replace(struct zone *zone, int *where)
> 
> +	list = list->next;
> +	while (list !=&zone->active_longterm) {
> +		page = list_entry(list, struct page, lru);
> +
> +		if (!PageReferenced(page))
> +			break;
> +		
> +		ClearPageReferenced(page);
> +		del_page_from_active_longterm(zone, page);
> +		add_page_to_active_list_tail(zone, page);
> 
> This sounds odd. If a page is referenced you remove it from the longterm list
> "unpromoting" it to the active list? Shouldnt be the other way around?

This is correct, the longterm list (T2) is essentially a FIFO. All it
does is delay the re-evaluation of the page.

-- 
Peter Zijlstra <a.p.zijlstra@chello.nl>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
