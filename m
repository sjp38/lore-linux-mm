Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id C0F8E6B0038
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 08:52:50 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id n189so140729693qke.0
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 05:52:50 -0700 (PDT)
Received: from mail-qk0-f194.google.com (mail-qk0-f194.google.com. [209.85.220.194])
        by mx.google.com with ESMTPS id f29si20906670qte.33.2016.10.18.05.52.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Oct 2016 05:52:50 -0700 (PDT)
Received: by mail-qk0-f194.google.com with SMTP id n189so16729603qke.1
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 05:52:50 -0700 (PDT)
Date: Tue, 18 Oct 2016 14:52:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: exclude isolated non-lru pages from
 NR_ISOLATED_ANON or NR_ISOLATED_FILE.
Message-ID: <20161018125247.GI12092@dhcp22.suse.cz>
References: <20161014113044.GB6063@dhcp22.suse.cz>
 <20161014134604.GA2179@blaptop>
 <20161014135334.GF6063@dhcp22.suse.cz>
 <20161014144448.GA2899@blaptop>
 <20161014150355.GH6063@dhcp22.suse.cz>
 <20161014152633.GA3157@blaptop>
 <20161015071044.GC9949@dhcp22.suse.cz>
 <20161016230618.GB9196@bbox>
 <20161017084244.GF23322@dhcp22.suse.cz>
 <20161018062950.GA18818@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161018062950.GA18818@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Ling <ming.ling@spreadtrum.com>
Cc: Minchan Kim <minchan@kernel.org>, akpm@linux-foundation.org, mgorman@techsingularity.net, vbabka@suse.cz, hannes@cmpxchg.org, baiyaowei@cmss.chinamobile.com, iamjoonsoo.kim@lge.com, rientjes@google.com, hughd@google.com, kirill.shutemov@linux.intel.com, riel@redhat.com, mgorman@suse.de, aquini@redhat.com, corbet@lwn.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, orson.zhai@spreadtrum.com, geng.ren@spreadtrum.com, chunyan.zhang@spreadtrum.com, zhizhou.tian@spreadtrum.com, yuming.han@spreadtrum.com, xiajing@spreadst.com

On Tue 18-10-16 15:29:50, Minchan Kim wrote:
> On Mon, Oct 17, 2016 at 10:42:45AM +0200, Michal Hocko wrote:
[...]
> > Sure, what do you think about the following? I haven't marked it for
> > stable because there was no bug report for it AFAIU.
> > ---
> > From 3b2bd4486f36ada9f6dc86d3946855281455ba9f Mon Sep 17 00:00:00 2001
> > From: Ming Ling <ming.ling@spreadtrum.com>
> > Date: Mon, 17 Oct 2016 10:26:50 +0200
> > Subject: [PATCH] mm, compaction: fix NR_ISOLATED_* stats for pfn based
> >  migration
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
> > 
> > Fixes: bda807d44454 ("mm: migrate: support non-lru movable page migration")
> > Signed-off-by: Ming Ling <ming.ling@spreadtrum.com>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Acked-by: Minchan Kim <minchan@kernel.org>
> 
> with folding other fix patch you posted.

Thanks.

Ming, are you OK with this patch? Can I post it to Andrew?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
