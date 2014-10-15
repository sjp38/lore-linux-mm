Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id D6EDC6B0069
	for <linux-mm@kvack.org>; Wed, 15 Oct 2014 18:32:14 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id w10so2025133pde.28
        for <linux-mm@kvack.org>; Wed, 15 Oct 2014 15:32:14 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id hp1si6277197pad.153.2014.10.15.15.32.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Oct 2014 15:32:13 -0700 (PDT)
Date: Wed, 15 Oct 2014 15:32:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/5] mm, compaction: simplify deferred compaction
Message-Id: <20141015153212.7b9029c8bb8e9c1b8736181d@linux-foundation.org>
In-Reply-To: <1412696019-21761-3-git-send-email-vbabka@suse.cz>
References: <1412696019-21761-1-git-send-email-vbabka@suse.cz>
	<1412696019-21761-3-git-send-email-vbabka@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

On Tue,  7 Oct 2014 17:33:36 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:

> Since commit ("mm, compaction: defer each zone individually instead of
> preferred zone"), compaction is deferred for each zone where sync direct
> compaction fails, and reset where it succeeds. However, it was observed
> that for DMA zone compaction often appeared to succeed while subsequent
> allocation attempt would not, due to different outcome of watermark check.
> In order to properly defer compaction in this zone, the candidate zone has
> to be passed back to __alloc_pages_direct_compact() and compaction deferred
> in the zone after the allocation attempt fails.
> 
> The large source of mismatch between watermark check in compaction and
> allocation was the lack of alloc_flags and classzone_idx values in compaction,
> which has been fixed in the previous patch. So with this problem fixed, we
> can simplify the code by removing the candidate_zone parameter and deferring
> in __alloc_pages_direct_compact().
> 
> After this patch, the compaction activity during stress-highalloc benchmark is
> still somewhat increased, but it's negligible compared to the increase that
> occurred without the better watermark checking. This suggests that it is still
> possible to apparently succeed in compaction but fail to allocate, possibly
> due to parallel allocation activity.
> 
> ...
>
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -33,8 +33,7 @@ extern int fragmentation_index(struct zone *zone, unsigned int order);
>  extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
>  			int order, gfp_t gfp_mask, nodemask_t *mask,
>  			enum migrate_mode mode, int *contended,
> -			int alloc_flags, int classzone_idx,
> -			struct zone **candidate_zone);
> +			int alloc_flags, int classzone_idx);
>  extern void compact_pgdat(pg_data_t *pgdat, int order);
>  extern void reset_isolation_suitable(pg_data_t *pgdat);
>  extern unsigned long compaction_suitable(struct zone *zone, int order,
> @@ -105,8 +104,7 @@ static inline bool compaction_restarting(struct zone *zone, int order)
>  static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
>  			int order, gfp_t gfp_mask, nodemask_t *nodemask,
>  			enum migrate_mode mode, int *contended,
> -			int alloc_flags, int classzone_idx,
> -			struct zone **candidate_zone)
> +			int alloc_flags, int classzone_idx);
>  {
>  	return COMPACT_CONTINUE;
>  }

--- a/include/linux/compaction.h~mm-compaction-simplify-deferred-compaction-fix
+++ a/include/linux/compaction.h
@@ -104,7 +104,7 @@ static inline bool compaction_restarting
 static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *nodemask,
 			enum migrate_mode mode, int *contended,
-			int alloc_flags, int classzone_idx);
+			int alloc_flags, int classzone_idx)
 {
 	return COMPACT_CONTINUE;
 }

It clearly wasn't tested with this config.  Please do so and let us
know the result?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
