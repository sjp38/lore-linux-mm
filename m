Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 89F086B025E
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 05:19:01 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id xy5so44024648wjc.0
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 02:19:01 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h10si4517434wjv.68.2016.12.02.02.19.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 02 Dec 2016 02:19:00 -0800 (PST)
Subject: Re: [PATCH] mm: alloc_contig: demote PFN busy message to debug level
References: <20161202095742.32449-1-l.stach@pengutronix.de>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <74234427-005f-609e-3f33-cdf9a739c1d2@suse.cz>
Date: Fri, 2 Dec 2016 11:18:55 +0100
MIME-Version: 1.0
In-Reply-To: <20161202095742.32449-1-l.stach@pengutronix.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lucas Stach <l.stach@pengutronix.de>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, kernel@pengutronix.de, patchwork-lst@pengutronix.de, Michal Hocko <mhocko@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, "Robin H. Johnson" <robbat2@gentoo.org>

On 12/02/2016 10:57 AM, Lucas Stach wrote:
> There are a lot of reasons why a PFN might be busy and unable to be isolated
> some of which can't really be avoided. This message is spamming the logs when
> a lot of CMA allocations are happening, causing isolation to happen quite
> frequently.

Is this related to Robin's report [1] or you have an independent case of 
lots of CMA allocations, and in which context are there?

> Demote the message to log level, as CMA will just retry the allocation, so
> there is no need to have this message in the logs. If someone is interested
> in the failing case, there is a tracepoint to track those failures properly.

I don't think we should just hide the issue like this, as getting high 
volume reports from this is also very likely associated with high 
overhead for the allocations. If it's the generic dma-cma context, like 
in [1] where it attempts CMA for order-0 allocations, we should first do 
something about that, before tweaking the logging.

[1] http://marc.info/?l=linux-mm&m=148053714627617&w=2

> Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
> ---
>  mm/page_alloc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 2b3bf6767d54..b2cfb4074f90 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7398,7 +7398,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
>
>  	/* Make sure the range is really isolated. */
>  	if (test_pages_isolated(outer_start, end, false)) {
> -		pr_info("%s: [%lx, %lx) PFNs busy\n",
> +		pr_debug("%s: [%lx, %lx) PFNs busy\n",
>  			__func__, outer_start, end);
>  		ret = -EBUSY;
>  		goto done;
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
