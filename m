Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 0C6FD6B0092
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 11:43:47 -0400 (EDT)
Date: Wed, 7 Aug 2013 16:43:43 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 6/9] mm: zone_reclaim: compaction: increase the high
 order pages in the watermarks
Message-ID: <20130807154343.GT2296@suse.de>
References: <1375459596-30061-1-git-send-email-aarcange@redhat.com>
 <1375459596-30061-7-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1375459596-30061-7-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hush Bensen <hush.bensen@gmail.com>

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
>  

Why pageblock_order? That thing depends on the huge page size of the
system in question so it'll vary between platforms and kernel configs.
It seems arbitrary but I suspect it happened to work well for THP
allocations on x86_64.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
