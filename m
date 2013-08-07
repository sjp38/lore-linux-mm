Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id B6DC66B0092
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 11:42:06 -0400 (EDT)
Date: Wed, 7 Aug 2013 16:42:01 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 5/9] mm: compaction: don't require high order pages below
 min wmark
Message-ID: <20130807154201.GS2296@suse.de>
References: <1375459596-30061-1-git-send-email-aarcange@redhat.com>
 <1375459596-30061-6-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1375459596-30061-6-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hush Bensen <hush.bensen@gmail.com>

On Fri, Aug 02, 2013 at 06:06:32PM +0200, Andrea Arcangeli wrote:
> The min wmark should be satisfied with just 1 hugepage.

This depends on the size of the machine and if THP is enabled or not
(which adjusts min_free_kbytes).  I expect that it is generally true but
wonder how often it is true on something like ARM which does high-order
allocators for stack.

> And the other
> wmarks should be adjusted accordingly. We need to succeed the low
> wmark check if there's some significant amount of 0 order pages, but
> we don't need plenty of high order pages because the PF_MEMALLOC paths
> don't require those. Creating a ton of high order pages that cannot be
> allocated by the high order allocation paths (no PF_MEMALLOC) is quite
> wasteful because they can be splitted in lower order pages before
> anybody has a chance to allocate them.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  mm/page_alloc.c | 17 +++++++++++++++++
>  1 file changed, 17 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 092b30d..4401983 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1643,6 +1643,23 @@ static bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
>  
>  	if (free_pages - free_cma <= min + lowmem_reserve)
>  		return false;
> +	if (!order)
> +		return true;
> +
> +	/*
> +	 * Don't require any high order page under the min
> +	 * wmark. Invoking compaction to create lots of high order
> +	 * pages below the min wmark is wasteful because those
> +	 * hugepages cannot be allocated without PF_MEMALLOC and the
> +	 * PF_MEMALLOC paths must not depend on high order allocations
> +	 * to succeed.
> +	 */
> +	min = mark - z->watermark[WMARK_MIN];
> +	WARN_ON(min < 0);

It would be hard to hit but you may be able to trigger this warning if

process a			process b
read min watermark
				increase min_free_kbytes
__zone_watermark_ok




if (min < 0)
	return false;

?

> +	if (alloc_flags & ALLOC_HIGH)
> +		min -= min / 2;
> +	if (alloc_flags & ALLOC_HARDER)
> +		min -= min / 4;
>  	for (o = 0; o < order; o++) {
>  		/* At the next order, this order's pages become unavailable */
>  		free_pages -= z->free_area[o].nr_free << o;

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
