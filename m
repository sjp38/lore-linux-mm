Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6A11C6B000C
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 16:13:10 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id f9so1897849pgs.13
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 13:13:10 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g6-v6si7275931plt.212.2018.11.05.13.13.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 13:13:09 -0800 (PST)
Date: Mon, 5 Nov 2018 13:13:05 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] slab.h: Avoid using & for logical and of booleans
Message-Id: <20181105131305.574d85469f08a4b76592feb6@linux-foundation.org>
In-Reply-To: <20181105204000.129023-1-bvanassche@acm.org>
References: <20181105204000.129023-1-bvanassche@acm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart Van Assche <bvanassche@acm.org>
Cc: linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Christoph Lameter <cl@linux.com>, Roman Gushchin <guro@fb.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org

On Mon,  5 Nov 2018 12:40:00 -0800 Bart Van Assche <bvanassche@acm.org> wrote:

> This patch suppresses the following sparse warning:
> 
> ./include/linux/slab.h:332:43: warning: dubious: x & !y
> 
> ...
>
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -329,7 +329,7 @@ static __always_inline enum kmalloc_cache_type kmalloc_type(gfp_t flags)
>  	 * If an allocation is both __GFP_DMA and __GFP_RECLAIMABLE, return
>  	 * KMALLOC_DMA and effectively ignore __GFP_RECLAIMABLE
>  	 */
> -	return type_dma + (is_reclaimable & !is_dma) * KMALLOC_RECLAIM;
> +	return type_dma + is_reclaimable * !is_dma * KMALLOC_RECLAIM;
>  }
>  
>  /*

I suppose so.

That function seems too clever for its own good :(.  I wonder if these
branch-avoiding tricks are really worthwhile.
