Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8D6FB6B0253
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 11:41:04 -0400 (EDT)
Received: by qgew37 with SMTP id w37so13259437qge.0
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 08:41:04 -0700 (PDT)
Received: from mail-qg0-x22d.google.com (mail-qg0-x22d.google.com. [2607:f8b0:400d:c04::22d])
        by mx.google.com with ESMTPS id v3si1984597qkv.86.2015.10.09.08.41.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Oct 2015 08:41:03 -0700 (PDT)
Received: by qgew37 with SMTP id w37so13259031qge.0
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 08:41:03 -0700 (PDT)
Message-ID: <5617e00e.0c5b8c0a.2d0dd.3faa@mx.google.com>
Date: Fri, 09 Oct 2015 08:41:02 -0700 (PDT)
From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Subject: Re: [PATCH] mm: skip if required_kernelcore is larger than
 totalpages
In-Reply-To: <5615D311.5030908@huawei.com>
References: <5615D311.5030908@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tang Chen <tangchen@cn.fujitsu.com>, zhongjiang@huawei.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


On Thu, 8 Oct 2015 10:21:05 +0800
Xishi Qiu <qiuxishi@huawei.com> wrote:

> If kernelcore was not specified, or the kernelcore size is zero
> (required_movablecore >= totalpages), or the kernelcore size is larger

Why does required_movablecore become larger than totalpages, when the
kernelcore size is zero? I read the code but I could not find that you
mention.

Thanks,
Yasuaki Ishimatsu

> than totalpages, there is no ZONE_MOVABLE. We should fill the zone
> with both kernel memory and movable memory.
> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> ---
>  mm/page_alloc.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index af3c9bd..6a6da0d 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5674,8 +5674,11 @@ static void __init find_zone_movable_pfns_for_nodes(void)
>  		required_kernelcore = max(required_kernelcore, corepages);
>  	}
>  
> -	/* If kernelcore was not specified, there is no ZONE_MOVABLE */
> -	if (!required_kernelcore)
> +	/*
> +	 * If kernelcore was not specified or kernelcore size is larger
> +	 * than totalpages, there is no ZONE_MOVABLE.
> +	 */
> +	if (!required_kernelcore || required_kernelcore >= totalpages)
>  		goto out;
>  
>  	/* usable_startpfn is the lowest possible pfn ZONE_MOVABLE can be at */
> -- 
> 2.0.0
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
