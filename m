Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f51.google.com (mail-bk0-f51.google.com [209.85.214.51])
	by kanga.kvack.org (Postfix) with ESMTP id 57B986B0069
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 06:03:35 -0500 (EST)
Received: by mail-bk0-f51.google.com with SMTP id 6so2479341bkj.38
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 03:03:34 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id ta6si6924746bkb.313.2013.11.26.03.03.34
        for <linux-mm@kvack.org>;
        Tue, 26 Nov 2013 03:03:34 -0800 (PST)
Date: Tue, 26 Nov 2013 11:03:30 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 5/5] mm: compaction: reset scanner positions immediately
 when they meet
Message-ID: <20131126110330.GJ5285@suse.de>
References: <1385389570-11393-1-git-send-email-vbabka@suse.cz>
 <1385389570-11393-6-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1385389570-11393-6-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>

On Mon, Nov 25, 2013 at 03:26:10PM +0100, Vlastimil Babka wrote:
> Compaction used to start its migrate and free page scaners at the zone's lowest
> and highest pfn, respectively. Later, caching was introduced to remember the
> scanners' progress across compaction attempts so that pageblocks are not
> re-scanned uselessly. Additionally, pageblocks where isolation failed are
> marked to be quickly skipped when encountered again in future compactions.
> 
> Currently, both the reset of cached pfn's and clearing of the pageblock skip
> information for a zone is done in __reset_isolation_suitable(). This function
> gets called when:
>  - compaction is restarting after being deferred
>  - compact_blockskip_flush flag is set in compact_finished() when the scanners
>    meet (and not again cleared when direct compaction succeeds in allocation)
>    and kswapd acts upon this flag before going to sleep
> 
> This behavior is suboptimal for several reasons:
>  - when direct sync compaction is called after async compaction fails (in the
>    allocation slowpath), it will effectively do nothing, unless kswapd
>    happens to process the compact_blockskip_flush flag meanwhile. This is racy
>    and goes against the purpose of sync compaction to more thoroughly retry
>    the compaction of a zone where async compaction has failed.
>    The restart-after-deferring path cannot help here as deferring happens only
>    after the sync compaction fails. It is also done only for the preferred
>    zone, while the compaction might be done for a fallback zone.
>  - the mechanism of marking pageblock to be skipped has little value since the
>    cached pfn's are reset only together with the pageblock skip flags. This
>    effectively limits pageblock skip usage to parallel compactions.
> 
> This patch changes compact_finished() so that cached pfn's are reset
> immediately when the scanners meet. Clearing pageblock skip flags is unchanged,
> as well as the other situations where cached pfn's are reset. This allows the
> sync-after-async compaction to retry pageblocks not marked as skipped, such as
> blocks !MIGRATE_MOVABLE blocks that async compactions now skips without
> marking them.
> 
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Rik van Riel <riel@redhat.com>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
