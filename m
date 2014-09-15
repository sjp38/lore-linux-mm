Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 7B7BB6B0035
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 01:21:44 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id z10so5318575pdj.34
        for <linux-mm@kvack.org>; Sun, 14 Sep 2014 22:21:44 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id cg2si20826499pad.34.2014.09.14.22.21.42
        for <linux-mm@kvack.org>;
        Sun, 14 Sep 2014 22:21:43 -0700 (PDT)
Date: Mon, 15 Sep 2014 14:21:51 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC] Free the reserved memblock when free cma pages
Message-ID: <20140915052151.GI2160@bbox>
References: <35FD53F367049845BC99AC72306C23D103CDBFBFB016@CNBJMBX05.corpusers.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <35FD53F367049845BC99AC72306C23D103CDBFBFB016@CNBJMBX05.corpusers.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: "'mhocko@suse.cz'" <mhocko@suse.cz>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'akpm@linux-foundation.org'" <akpm@linux-foundation.org>, "mm-commits@vger.kernel.org" <mm-commits@vger.kernel.org>, "hughd@google.com" <hughd@google.com>, "b.zolnierkie@samsung.com" <b.zolnierkie@samsung.com>

Hello,

On Tue, Sep 09, 2014 at 02:13:58PM +0800, Wang, Yalin wrote:
> This patch add memblock_free to also free the reserved memblock,
> so that the cma pages are not marked as reserved memory in
> /sys/kernel/debug/memblock/reserved debug file
> 
> Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
> ---
>  mm/cma.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/cma.c b/mm/cma.c
> index c17751c..f3ec756 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -114,6 +114,8 @@ static int __init cma_activate_area(struct cma *cma)
>  				goto err;
>  		}
>  		init_cma_reserved_pageblock(pfn_to_page(base_pfn));
> +		memblock_free(__pfn_to_phys(base_pfn),
> +				pageblock_nr_pages * PAGE_SIZE);

Nitpick:

Couldn't we add memblock_free into init_cma_reserved_pageblock?
Because it should be pair with ClearPageReserved, I think.

In addition, please add description on memory reserve part
in cma_declare_contiguous.

>  	} while (--i);
>  
>  	mutex_init(&cma->lock);
> -- 
> 2.1.0
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
