Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 0F0C56B0035
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 10:38:05 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so1192339pbb.33
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 07:38:05 -0700 (PDT)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id po10si1567376pab.425.2014.03.13.07.38.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 13 Mar 2014 07:38:05 -0700 (PDT)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N2D00BQCPZDXN10@mailout1.samsung.com> for
 linux-mm@kvack.org; Thu, 13 Mar 2014 23:38:01 +0900 (KST)
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: Re: [RFC][PATCH v2] mm/page_alloc: fix freeing of MIGRATE_RESERVE
 migratetype pages
Date: Thu, 13 Mar 2014 15:37:46 +0100
Message-id: <3661570.lSOEkVGv4G@amdc1032>
In-reply-to: <20140313142540.GQ10663@suse.de>
References: <42197912.c6v2hLDCey@amdc1032> <20140313142540.GQ10663@suse.de>
MIME-version: 1.0
Content-transfer-encoding: 7Bit
Content-type: text/plain; charset=iso-8859-15
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Yong-Taek Lee <ytk.lee@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thursday, March 13, 2014 02:25:40 PM Mel Gorman wrote:
> On Fri, Feb 14, 2014 at 07:34:17PM +0100, Bartlomiej Zolnierkiewicz wrote:
> > Pages allocated from MIGRATE_RESERVE migratetype pageblocks
> > are not freed back to MIGRATE_RESERVE migratetype free
> > lists in free_pcppages_bulk()->__free_one_page() if we got
> > to free_pcppages_bulk() through drain_[zone_]pages().
> > The freeing through free_hot_cold_page() is okay because
> > freepage migratetype is set to pageblock migratetype before
> > calling free_pcppages_bulk().  If pages of MIGRATE_RESERVE
> > migratetype end up on the free lists of other migratetype
> > whole Reserved pageblock may be later changed to the other
> > migratetype in __rmqueue_fallback() and it will be never
> > changed back to be a Reserved pageblock.  Fix the issue by
> > preserving freepage migratetype as a pageblock migratetype
> > (instead of overriding it to the requested migratetype)
> > for MIGRATE_RESERVE migratetype pages in rmqueue_bulk().
> > 
> > The problem was introduced in v2.6.31 by commit ed0ae21
> > ("page allocator: do not call get_pageblock_migratetype()
> > more than necessary").
> > 
> > Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> > Reported-by: Yong-Taek Lee <ytk.lee@samsung.com>
> > Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> > Cc: Mel Gorman <mgorman@suse.de>
> > Cc: Hugh Dickins <hughd@google.com>
> 
> It's a pity about the unconditional pageblock lookup in that path but I
> didn't see a better way around it so
> 
> Acked-by: Mel Gorman <mgorman@suse.de>

Thanks but does that mean that v3 should be abandoned:

	https://lkml.org/lkml/2014/3/6/365

?

Best regards,
--
Bartlomiej Zolnierkiewicz
Samsung R&D Institute Poland
Samsung Electronics

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
