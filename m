Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id A7ED46B004D
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 23:47:43 -0500 (EST)
Message-ID: <4EEACD69.6010509@redhat.com>
Date: Thu, 15 Dec 2011 23:47:37 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 11/11] mm: Isolate pages for immediate reclaim on their
 own LRU
References: <1323877293-15401-1-git-send-email-mgorman@suse.de> <1323877293-15401-12-git-send-email-mgorman@suse.de>
In-Reply-To: <1323877293-15401-12-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Dave Jones <davej@redhat.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Nai Xia <nai.xia@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/14/2011 10:41 AM, Mel Gorman wrote:
> It was observed that scan rates from direct reclaim during tests
> writing to both fast and slow storage were extraordinarily high. The
> problem was that while pages were being marked for immediate reclaim
> when writeback completed, the same pages were being encountered over
> and over again during LRU scanning.
>
> This patch isolates file-backed pages that are to be reclaimed when
> clean on their own LRU list.

The idea makes total sense to me.  This is very similar
to the inactive_laundry list in the early 2.4 kernel.

One potential issue is that the page cannot be moved
back to the active list by mark_page_accessed(), which
would have to be taught about the immediate LRU.

> @@ -255,24 +256,80 @@ static void pagevec_move_tail(struct pagevec *pvec)
>   }
>
>   /*
> + * Similar pair of functions to pagevec_move_tail except it is called when
> + * moving a page from the LRU_IMMEDIATE to one of the [in]active_[file|anon]
> + * lists
> + */
> +static void pagevec_putback_immediate_fn(struct page *page, void *arg)
> +{
> +	struct zone *zone = page_zone(page);
> +
> +	if (PageLRU(page)) {
> +		enum lru_list lru = page_lru(page);
> +		list_move(&page->lru,&zone->lru[lru].list);
> +	}
> +}

Should this not put the page at the reclaim end of the
inactive list, since we want to try evicting it?

> +	/*
> +	 * There is a potential race that if a page is set PageReclaim
> +	 * and moved to the LRU_IMMEDIATE list after writeback completed,
> +	 * it can be left on the LRU_IMMEDATE list with no way for
> +	 * reclaim to find it.
> +	 *
> +	 * This race should be very rare but count how often it happens.
> +	 * If it is a continual race, then it's very unsatisfactory as there
> +	 * is no guarantee that rotate_reclaimable_page() will be called
> +	 * to rescue these pages but finding them in page reclaim is also
> +	 * problematic due to the problem of deciding when the right time
> +	 * to scan this list is.
> +	 */

Would it be an idea for the pageout code to check whether the
page at the head of the LRU_IMMEDIATE list is freeable, and
then take that page?

Of course, that does mean adding a check to rotate_reclaimable_page
to make sure the page is still on the LRU_IMMEDIATE list, and did
not get moved by somebody else...

Also, it looks like your debugging check can trigger even when the
bug does not happen (on the last LRU_IMMEDIATE page), because you
decrement NR_IMMEDIATE before you get to this check.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
