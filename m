Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id C256F6B0032
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 12:39:05 -0400 (EDT)
Date: Mon, 22 Jul 2013 12:38:36 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/2] mm: page_alloc: avoid slowpath for more than
 MAX_ORDER allocation.
Message-ID: <20130722163836.GD715@cmpxchg.org>
References: <1374492762-17735-1-git-send-email-pintu.k@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1374492762-17735-1-git-send-email-pintu.k@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pintu Kumar <pintu.k@samsung.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, jiang.liu@huawei.com, minchan@kernel.org, cody@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cpgs@samsung.com, pintu_agarwal@yahoo.com

Hi Pintu,

On Mon, Jul 22, 2013 at 05:02:42PM +0530, Pintu Kumar wrote:
> It was observed that if order is passed as more than MAX_ORDER
> allocation in __alloc_pages_nodemask, it will unnecessarily go to
> slowpath and then return failure.
> Since we know that more than MAX_ORDER will anyways fail, we can
> avoid slowpath by returning failure in nodemask itself.
> 
> Signed-off-by: Pintu Kumar <pintu.k@samsung.com>
> ---
>  mm/page_alloc.c |    4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 202ab58..6d38e75 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1564,6 +1564,10 @@ __setup("fail_page_alloc=", setup_fail_page_alloc);
>  
>  static bool should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
>  {
> +	if (order >= MAX_ORDER) {
> +		WARN_ON(!(gfp_mask & __GFP_NOWARN));
> +		return false;
> +	}

I don't see how this solves what you describe (should return true?)

It would also not be a good place to put performance optimization,
because this function is only called as part of a debugging mechanism
that is usually disabled.

Lastly, order >= MAX_ORDER is not supported by the page allocator, and
we do not want to punish 99.999% of all legitimate page allocations in
the fast path in order to catch an unlikely situation like this.
Having the check only in the slowpath is a good thing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
