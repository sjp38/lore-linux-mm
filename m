Date: Sat, 23 Feb 2008 00:05:57 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 08/28] mm: system wide ALLOC_NO_WATERMARK
Message-Id: <20080223000557.82125b3c.akpm@linux-foundation.org>
In-Reply-To: <20080220150306.297640000@chello.nl>
References: <20080220144610.548202000@chello.nl>
	<20080220150306.297640000@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Wed, 20 Feb 2008 15:46:18 +0100 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> Change ALLOC_NO_WATERMARK page allocation such that the reserves are system
> wide - which they are per setup_per_zone_pages_min(), when we scrape the
> barrel, do it properly.
> 

The changelog is fairly incomprehensible.

>  mm/page_alloc.c |    6 ++++++
>  1 file changed, 6 insertions(+)
> 
> Index: linux-2.6/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.orig/mm/page_alloc.c
> +++ linux-2.6/mm/page_alloc.c
> @@ -1552,6 +1552,12 @@ restart:
>  rebalance:
>  	if (alloc_flags & ALLOC_NO_WATERMARKS) {
>  nofail_alloc:
> +		/*
> +		 * break out of mempolicy boundaries
> +		 */
> +		zonelist = NODE_DATA(numa_node_id())->node_zonelists +
> +			gfp_zone(gfp_mask);
> +
>  		/* go through the zonelist yet again, ignoring mins */
>  		page = get_page_from_freelist(gfp_mask, order, zonelist,
>  				ALLOC_NO_WATERMARKS);

As is the patch.  People who care about mempolicies will want a better
explanation, please, so they can check that we're not busting their stuff.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
