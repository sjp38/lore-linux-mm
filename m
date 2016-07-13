Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 80CFE6B0253
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 09:16:01 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id x83so34840110wma.2
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 06:16:01 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 16si27936786wmb.72.2016.07.13.06.16.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 06:16:00 -0700 (PDT)
Date: Wed, 13 Jul 2016 09:15:55 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/4] mm, page_alloc: fix dirtyable highmem calculation
Message-ID: <20160713131555.GE9905@cmpxchg.org>
References: <1468404004-5085-1-git-send-email-mgorman@techsingularity.net>
 <1468404004-5085-4-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1468404004-5085-4-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 13, 2016 at 11:00:03AM +0100, Mel Gorman wrote:
> From: Minchan Kim <minchan@kernel.org>
> 
> Note from Mel: This may optionally be considered a fix to the mmotm patch
> 	mm-page_alloc-consider-dirtyable-memory-in-terms-of-nodes.patch
> 	but if so, please preserve credit for Minchan.
> 
> When I tested vmscale in mmtest in 32bit, I found the benchmark was slow
> down 0.5 times.
> 
>                 base        node
>                    1    global-1
> User           12.98       16.04
> System        147.61      166.42
> Elapsed        26.48       38.08
> 
> With vmstat, I found IO wait avg is much increased compared to base.
> 
> The reason was highmem_dirtyable_memory accumulates free pages and
> highmem_file_pages from HIGHMEM to MOVABLE zones which was wrong. With
> that, dirth_thresh in throtlle_vm_write is always 0 so that it calls
> congestion_wait frequently if writeback starts.
> 
> With this patch, it is much recovered.
> 
>                 base        node          fi
>                    1    global-1         fix
> User           12.98       16.04       13.78
> System        147.61      166.42      143.92
> Elapsed        26.48       38.08       29.64
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
