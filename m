Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id B48E16B0278
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 20:00:44 -0500 (EST)
Received: by wmec201 with SMTP id c201so190941020wme.0
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 17:00:44 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id cc7si957314wjc.74.2015.12.07.17.00.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Dec 2015 17:00:43 -0800 (PST)
Date: Mon, 7 Dec 2015 17:00:41 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/compaction: restore COMPACT_CLUSTER_MAX to 32
Message-Id: <20151207170041.c470d362915ae1b42a8a4ef8@linux-foundation.org>
In-Reply-To: <1449115900-20112-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1449115900-20112-1-git-send-email-iamjoonsoo.kim@lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Thu,  3 Dec 2015 13:11:40 +0900 Joonsoo Kim <js1304@gmail.com> wrote:

> Until now, COMPACT_CLUSTER_MAX is defined as SWAP_CLUSTER_MAX.
> Commit ("mm: increase SWAP_CLUSTER_MAX to batch TLB flushes")
> changes SWAP_CLUSTER_MAX from 32 to 256 to improve tlb flush performance
> so COMPACT_CLUSTER_MAX is also changed to 256.

"mm: increase SWAP_CLUSTER_MAX to batch TLB flushes" has been in limbo
for quite a while.  Because it has been unclear whether the patch's
benefits exceed its costs+risks.

We should make a decision here - either do the appropriate testing or
drop the patch.


> But, it has
> no justification on compaction-side and I think that loss is more than
> benefit.
> 
> One example is that migration scanner would isolates and migrates
> too many pages unnecessarily with 256 COMPACT_CLUSTER_MAX. It may be
> enough to migrate 4 pages in order to make order-2 page, but, now,
> compaction will migrate 256 pages.
> 
> To reduce this unneeded overhead, this patch restores
> COMPACT_CLUSTER_MAX to 32.
> 
> ...
>
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -155,7 +155,7 @@ enum {
>  };
>  
>  #define SWAP_CLUSTER_MAX 256UL
> -#define COMPACT_CLUSTER_MAX SWAP_CLUSTER_MAX
> +#define COMPACT_CLUSTER_MAX 32UL
>  
>  /*
>   * Ratio between zone->managed_pages and the "gap" that above the per-zone

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
