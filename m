Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 507286B0031
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 12:08:45 -0400 (EDT)
Date: Tue, 6 Aug 2013 12:08:38 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 6/9] mm: zone_reclaim: compaction: increase the high
 order pages in the watermarks
Message-ID: <20130806160838.GI1845@cmpxchg.org>
References: <1375459596-30061-1-git-send-email-aarcange@redhat.com>
 <1375459596-30061-7-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375459596-30061-7-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hush Bensen <hush.bensen@gmail.com>

On Fri, Aug 02, 2013 at 06:06:33PM +0200, Andrea Arcangeli wrote:
> Prevent the scaling down to reduce the watermarks too much.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  mm/page_alloc.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 4401983..b32ecde 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1665,7 +1665,8 @@ static bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
>  		free_pages -= z->free_area[o].nr_free << o;
>  
>  		/* Require fewer higher order pages to be free */
> -		min >>= 1;
> +		if (o < (pageblock_order >> 2))
> +			min >>= 1;

Okay, bear with me here:

After an allocation, the watermark has to be met, all available pages
considered.  That is reasonable because we don't want to deadlock and
order-0 pages can be served from any page block.

Now say we have an order-2 allocation: in addition to the order-0 view
on the watermark, after the allocation a quarter of the watermark has
to be met with order-2 pages and up.  Okay, maybe we always want a few
< PAGE_ALLOC_COSTLY_ORDER pages at our disposal, who knows.

Then it kind of sizzles out towards higher order pages but it always
requires the remainder to be positive, i.e. at least one page at the
checked order available.  Only the actually requested order is not
checked, so for an order-9 we only make sure that we could serve at
least one order-8 page, maybe more depending on the zone size.

You're proposing to check at least for

  (watermark - min_watermark) >> (pageblock_order >> 2)

worth of order-8 pages instead.

How does any of this make any sense?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
