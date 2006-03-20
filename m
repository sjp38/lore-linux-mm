Message-ID: <441E94FA.8070408@yahoo.com.au>
Date: Mon, 20 Mar 2006 22:41:46 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH][1/3] mm: swsusp shrink_all_memory tweaks
References: <200603200231.50666.kernel@kolivas.org>
In-Reply-To: <200603200231.50666.kernel@kolivas.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: linux list <linux-kernel@vger.kernel.org>, ck list <ck@vds.kolivas.org>, Andrew Morton <akpm@osdl.org>, Rafael Wysocki <rjw@sisk.pl>, Pavel Machek <pavel@ucw.cz>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Con Kolivas wrote:

> - 
> +
> +#define for_each_priority_reverse(priority)	\
> +	for (priority = DEF_PRIORITY;		\
> +		priority >= 0;			\
> +		priority--)
> +
>  /*
>   * This is the main entry point to direct page reclaim.
>   *
> @@ -979,7 +1010,7 @@ unsigned long try_to_free_pages(struct z
>  		lru_pages += zone->nr_active + zone->nr_inactive;
>  	}
>  
> -	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
> +	for_each_priority_reverse(priority) {
>  		sc.nr_mapped = read_page_state(nr_mapped);
>  		sc.nr_scanned = 0;
>  		if (!priority)

I still don't like this change. Apart from being harder to read in
my opinion, I don't believe there is a precedent for "consolidating"
simple for loops in the kernel, is there?

More complex loops get helpers, but they're made part of the wider
well-known kernel API.

Why does for_each_priority_reverse blow up when you pass it an unsigned
argument? What range has priority? What direction does the loop go in?
(_reverse postfix doesn't tell me, because it is going from low->high
priority so I would have thought that is going forward, or up)

You had to look in two places each time you wanted to know the answers.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
