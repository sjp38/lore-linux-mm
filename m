Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 12AF46B0035
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 10:25:44 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id hi5so3974655wib.17
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 07:25:44 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 14si1609861wjq.73.2014.03.13.07.25.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 13 Mar 2014 07:25:43 -0700 (PDT)
Date: Thu, 13 Mar 2014 14:25:40 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC][PATCH v2] mm/page_alloc: fix freeing of MIGRATE_RESERVE
 migratetype pages
Message-ID: <20140313142540.GQ10663@suse.de>
References: <42197912.c6v2hLDCey@amdc1032>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <42197912.c6v2hLDCey@amdc1032>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: Hugh Dickins <hughd@google.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Yong-Taek Lee <ytk.lee@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Feb 14, 2014 at 07:34:17PM +0100, Bartlomiej Zolnierkiewicz wrote:
> Pages allocated from MIGRATE_RESERVE migratetype pageblocks
> are not freed back to MIGRATE_RESERVE migratetype free
> lists in free_pcppages_bulk()->__free_one_page() if we got
> to free_pcppages_bulk() through drain_[zone_]pages().
> The freeing through free_hot_cold_page() is okay because
> freepage migratetype is set to pageblock migratetype before
> calling free_pcppages_bulk().  If pages of MIGRATE_RESERVE
> migratetype end up on the free lists of other migratetype
> whole Reserved pageblock may be later changed to the other
> migratetype in __rmqueue_fallback() and it will be never
> changed back to be a Reserved pageblock.  Fix the issue by
> preserving freepage migratetype as a pageblock migratetype
> (instead of overriding it to the requested migratetype)
> for MIGRATE_RESERVE migratetype pages in rmqueue_bulk().
> 
> The problem was introduced in v2.6.31 by commit ed0ae21
> ("page allocator: do not call get_pageblock_migratetype()
> more than necessary").
> 
> Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Reported-by: Yong-Taek Lee <ytk.lee@samsung.com>
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Hugh Dickins <hughd@google.com>

It's a pity about the unconditional pageblock lookup in that path but I
didn't see a better way around it so

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
