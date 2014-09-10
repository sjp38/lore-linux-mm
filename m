Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 549E36B0036
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 04:18:20 -0400 (EDT)
Received: by mail-wg0-f52.google.com with SMTP id x13so4517795wgg.35
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 01:18:19 -0700 (PDT)
Received: from mail-wi0-x229.google.com (mail-wi0-x229.google.com [2a00:1450:400c:c05::229])
        by mx.google.com with ESMTPS id br7si1453004wib.34.2014.09.10.01.18.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 01:18:18 -0700 (PDT)
Received: by mail-wi0-f169.google.com with SMTP id cc10so562172wib.4
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 01:18:18 -0700 (PDT)
Date: Wed, 10 Sep 2014 10:18:16 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC] Free the reserved memblock when free cma pages
Message-ID: <20140910081816.GA25219@dhcp22.suse.cz>
References: <35FD53F367049845BC99AC72306C23D103CDBFBFB016@CNBJMBX05.corpusers.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <35FD53F367049845BC99AC72306C23D103CDBFBFB016@CNBJMBX05.corpusers.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'akpm@linux-foundation.org'" <akpm@linux-foundation.org>, "mm-commits@vger.kernel.org" <mm-commits@vger.kernel.org>, "hughd@google.com" <hughd@google.com>, "b.zolnierkie@samsung.com" <b.zolnierkie@samsung.com>

On Tue 09-09-14 14:13:58, Wang, Yalin wrote:
> This patch add memblock_free to also free the reserved memblock,
> so that the cma pages are not marked as reserved memory in
> /sys/kernel/debug/memblock/reserved debug file

Why and is this even correct? init_cma_reserved_pageblock seems to be
doing __ClearPageReserved on each page in the page block.

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
>  	} while (--i);
>  
>  	mutex_init(&cma->lock);
> -- 
> 2.1.0

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
