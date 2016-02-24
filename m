Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id E87846B0253
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 18:02:34 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id g62so4203925wme.1
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 15:02:34 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v71si501929wmd.18.2016.02.24.15.02.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Feb 2016 15:02:34 -0800 (PST)
Date: Wed, 24 Feb 2016 15:02:31 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: limit direct reclaim for higher order allocations
Message-Id: <20160224150231.7dac6dc8c7dd9078db83eea4@linux-foundation.org>
In-Reply-To: <20160224163850.3d7eb56c@annuminas.surriel.com>
References: <20160224163850.3d7eb56c@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, hannes@cmpxchg.org, vbabka@suse.cz, mgorman@suse.de, linux-mm@kvack.org

On Wed, 24 Feb 2016 16:38:50 -0500 Rik van Riel <riel@redhat.com> wrote:

> For multi page allocations smaller than PAGE_ALLOC_COSTLY_ORDER,
> the kernel will do direct reclaim if compaction failed for any
> reason. This worked fine when Linux systems had 128MB RAM, but
> on my 24GB system I frequently see higher order allocations
> free up over 3GB of memory, pushing all kinds of things into
> swap, and slowing down applications.

hm.  Seems a pretty obvious flaw - why didn't we notice+fix it earlier?

> It would be much better to limit the amount of reclaim done,
> rather than cause excessive pageout activity.
> 
> When enough memory is free to do compaction for the highest order
> allocation possible, bail out of the direct page reclaim code.
> 
> On smaller systems, this may be enough to obtain contiguous
> free memory areas to satisfy small allocations, continuing our
> strategy of relying on luck occasionally. On larger systems,
> relying on luck like that has not been working for years.
> 

It would be nice to see some solid testing results on real-world
workloads?

(patch retained for linux-mm)

> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index fc62546096f9..8dd15d514761 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2584,20 +2584,17 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>  				continue;	/* Let kswapd poll it */
>  
>  			/*
> -			 * If we already have plenty of memory free for
> -			 * compaction in this zone, don't free any more.
> -			 * Even though compaction is invoked for any
> -			 * non-zero order, only frequent costly order
> -			 * reclamation is disruptive enough to become a
> -			 * noticeable problem, like transparent huge
> -			 * page allocations.
> +			 * For higher order allocations, free enough memory
> +			 * to be able to do compaction for the largest possible
> +			 * allocation. On smaller systems, this may be enough
> +			 * that smaller allocations can skip compaction, if
> +			 * enough adjacent pages get freed.
>  			 */
> -			if (IS_ENABLED(CONFIG_COMPACTION) &&
> -			    sc->order > PAGE_ALLOC_COSTLY_ORDER &&
> +			if (IS_ENABLED(CONFIG_COMPACTION) && sc->order &&
>  			    zonelist_zone_idx(z) <= requested_highidx &&
> -			    compaction_ready(zone, sc->order)) {
> +			    compaction_ready(zone, MAX_ORDER)) {
>  				sc->compaction_ready = true;
> -				continue;
> +				return true;
>  			}
>  
>  			/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
