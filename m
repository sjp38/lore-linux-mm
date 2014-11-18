Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 433946B0038
	for <linux-mm@kvack.org>; Tue, 18 Nov 2014 17:30:31 -0500 (EST)
Received: by mail-qg0-f52.google.com with SMTP id a108so6243935qge.39
        for <linux-mm@kvack.org>; Tue, 18 Nov 2014 14:30:31 -0800 (PST)
Received: from relay.variantweb.net ([104.131.199.242])
        by mx.google.com with ESMTP id g5si8428444qab.87.2014.11.18.14.29.39
        for <linux-mm@kvack.org>;
        Tue, 18 Nov 2014 14:30:09 -0800 (PST)
Received: from mail (unknown [10.42.10.20])
	by relay.variantweb.net (Postfix) with ESMTP id 9778810138E
	for <linux-mm@kvack.org>; Tue, 18 Nov 2014 17:29:35 -0500 (EST)
Date: Tue, 18 Nov 2014 16:29:36 -0600
From: Seth Jennings <sjennings@variantweb.net>
Subject: Re: [PATCH] mm: frontswap: invalidate expired data on a dup-store
 failure
Message-ID: <20141118222936.GB20945@cerebellum.variantweb.net>
References: <000001d0030d$0505aaa0$0f10ffe0$%yang@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000001d0030d$0505aaa0$0f10ffe0$%yang@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: konrad.wilk@oracle.com, 'Andrew Morton' <akpm@linux-foundation.org>, 'Dan Streetman' <ddstreet@ieee.org>, 'Minchan Kim' <minchan@kernel.org>, 'Bob Liu' <bob.liu@oracle.com>, xfishcoder@gmail.com, 'Weijie Yang' <weijie.yang.kh@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Nov 18, 2014 at 04:51:36PM +0800, Weijie Yang wrote:
> If a frontswap dup-store failed, it should invalidate the expired page
> in the backend, or it could trigger some data corruption issue.
> Such as:
> 1. use zswap as the frontswap backend with writeback feature
> 2. store a swap page(version_1) to entry A, success
> 3. dup-store a newer page(version_2) to the same entry A, fail
> 4. use __swap_writepage() write version_2 page to swapfile, success
> 5. zswap do shrink, writeback version_1 page to swapfile
> 6. version_2 page is overwrited by version_1, data corrupt.

Good catch!

> 
> This patch fixes this issue by invalidating expired data immediately
> when meet a dup-store failure.
> 
> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
> ---
>  mm/frontswap.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/frontswap.c b/mm/frontswap.c
> index c30eec5..f2a3571 100644
> --- a/mm/frontswap.c
> +++ b/mm/frontswap.c
> @@ -244,8 +244,10 @@ int __frontswap_store(struct page *page)
>  		  the (older) page from frontswap
>  		 */
>  		inc_frontswap_failed_stores();
> -		if (dup)
> +		if (dup) {
>  			__frontswap_clear(sis, offset);
> +			frontswap_ops->invalidate_page(type, offset);

Looking at __frontswap_invalidate_page(), should we do
inc_frontswap_invalidates() too?  If so, maybe we should just call
__frontswap_invalidate_page().

Thanks,
Seth

> +		}
>  	}
>  	if (frontswap_writethrough_enabled)
>  		/* report failure so swap also writes to swap device */
> -- 
> 1.7.0.4
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
