Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9704D6B025F
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 20:52:46 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ao6so1969044pac.2
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 17:52:46 -0700 (PDT)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id bc14si6423945pac.238.2016.06.20.17.52.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jun 2016 17:52:45 -0700 (PDT)
Received: by mail-pf0-x22d.google.com with SMTP id h14so456716pfe.1
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 17:52:45 -0700 (PDT)
Date: Mon, 20 Jun 2016 17:52:43 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3] mm/compaction: remove unnecessary order check in
 direct compact path
In-Reply-To: <1466044956-3690-1-git-send-email-opensource.ganesh@gmail.com>
Message-ID: <alpine.DEB.2.10.1606201749110.133174@chino.kir.corp.google.com>
References: <1466044956-3690-1-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, vbabka@suse.cz, iamjoonsoo.kim@lge.com, mhocko@suse.com, mina86@mina86.com, minchan@kernel.org, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, izumi.taku@jp.fujitsu.com, hannes@cmpxchg.org, khandual@linux.vnet.ibm.com, bsingharora@gmail.com

On Thu, 16 Jun 2016, Ganesh Mahendran wrote:

> diff --git a/mm/compaction.c b/mm/compaction.c
> index fbb7b38..dcfaf57 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1686,12 +1686,16 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
>  
>  	*contended = COMPACT_CONTENDED_NONE;
>  
> -	/* Check if the GFP flags allow compaction */
> +	/*
> +	 * Check if this is an order-0 request and
> +	 * if the GFP flags allow compaction.
> +	 */

This seems obvious.

>  	if (!order || !may_enter_fs || !may_perform_io)
>  		return COMPACT_SKIPPED;
>  
>  	trace_mm_compaction_try_to_compact_pages(order, gfp_mask, mode);
>  
> +	current->flags |= PF_MEMALLOC;
>  	/* Compact each zone in the list */
>  	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx,
>  								ac->nodemask) {
> @@ -1768,6 +1772,7 @@ break_loop:
>  		all_zones_contended = 0;
>  		break;
>  	}
> +	current->flags &= ~PF_MEMALLOC;
>  
>  	/*
>  	 * If at least one zone wasn't deferred or skipped, we report if all

Compaction don't touch task_struct flags and PF_MEMALLOC is flag used 
primarily by the page allocator, moving this to try_to_compact_pages() 
doesn't make sense.

You could remove the !order check in try_to_compact_pages(), but I don't 
think it offers anything substantial.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
