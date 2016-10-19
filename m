Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2FEA16B0069
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 06:36:19 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id z54so17438108qtz.0
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 03:36:19 -0700 (PDT)
Received: from mail-qk0-f193.google.com (mail-qk0-f193.google.com. [209.85.220.193])
        by mx.google.com with ESMTPS id o71si20878256qka.310.2016.10.19.03.36.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 03:36:18 -0700 (PDT)
Received: by mail-qk0-f193.google.com with SMTP id f128so1483588qkb.0
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 03:36:18 -0700 (PDT)
Date: Wed, 19 Oct 2016 12:36:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, compaction: fix NR_ISOLATED_* stats for pfn based
 migration
Message-ID: <20161019103616.GG7517@dhcp22.suse.cz>
References: <20161019080240.9682-1-mhocko@kernel.org>
 <2e4d79f9-74e5-5085-4037-caa9c1cb43e4@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2e4d79f9-74e5-5085-4037-caa9c1cb43e4@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, "ming.ling" <ming.ling@spreadtrum.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 19-10-16 11:39:36, Vlastimil Babka wrote:
> On 10/19/2016 10:02 AM, Michal Hocko wrote:
> > From: Ming Ling <ming.ling@spreadtrum.com>
> > 
> > Since bda807d44454 ("mm: migrate: support non-lru movable page
> > migration") isolate_migratepages_block) can isolate !PageLRU pages which
> > would acct_isolated account as NR_ISOLATED_*. Accounting these non-lru
> > pages NR_ISOLATED_{ANON,FILE} doesn't make any sense and it can misguide
> > heuristics based on those counters such as pgdat_reclaimable_pages resp.
> > too_many_isolated which would lead to unexpected stalls during the
> > direct reclaim without any good reason. Note that
> > __alloc_contig_migrate_range can isolate a lot of pages at once.
> > 
> > On mobile devices such as 512M ram android Phone, it may use a big zram
> > swap. In some cases zram(zsmalloc) uses too many non-lru but migratedable
> > pages, such as:
> > 
> >       MemTotal: 468148 kB
> >       Normal free:5620kB
> >       Free swap:4736kB
> >       Total swap:409596kB
> >       ZRAM: 164616kB(zsmalloc non-lru pages)
> >       active_anon:60700kB
> >       inactive_anon:60744kB
> >       active_file:34420kB
> >       inactive_file:37532kB
> > 
> > Fix this by only accounting lru pages to NR_ISOLATED_* in
> > isolate_migratepages_block right after they were isolated and we still
> > know they were on LRU. Drop acct_isolated because it is called after the
> > fact and we've lost that information. Batching per-cpu counter doesn't
> > make much improvement anyway. Also make sure that we uncharge only LRU
> > pages when putting them back on the LRU in putback_movable_pages resp.
> > when unmap_and_move migrates the page.
> 
> [mhocko@suse.com: replace acct_isolated() with direct counting]
> ?

Why not. I just considered this patch more as a rework of the original
than an incremental fix. But whatever...
 
> Indeed much better than before. IIRC I've personally introduced one or two
> bugs involving acct_isolated() (lack of) usage :) Thanks.

Yeah, it was subtle as hell.

> > Fixes: bda807d44454 ("mm: migrate: support non-lru movable page migration")
> > Acked-by: Minchan Kim <minchan@kernel.org>
> > Signed-off-by: Ming Ling <ming.ling@spreadtrum.com>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
