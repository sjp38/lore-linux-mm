Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id D57A86B0069
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 02:28:27 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id f134so20576633lfg.6
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 23:28:27 -0700 (PDT)
Received: from mail-lf0-f65.google.com (mail-lf0-f65.google.com. [209.85.215.65])
        by mx.google.com with ESMTPS id d140si536484lfd.27.2016.10.20.23.28.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Oct 2016 23:28:26 -0700 (PDT)
Received: by mail-lf0-f65.google.com with SMTP id b75so4136220lfg.3
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 23:28:26 -0700 (PDT)
Date: Fri, 21 Oct 2016 08:28:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, compaction: fix NR_ISOLATED_* stats for pfn based
 migration
Message-ID: <20161021062823.GA6045@dhcp22.suse.cz>
References: <20161019080240.9682-1-mhocko@kernel.org>
 <20161020201606.2da29e792856a03a0da0adb2@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161020201606.2da29e792856a03a0da0adb2@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "ming.ling" <ming.ling@spreadtrum.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 20-10-16 20:16:06, Andrew Morton wrote:
> On Wed, 19 Oct 2016 10:02:40 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> 
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
> It isn't worth backporting into 4.8.x?

To be honest, I don't know. AFAIK nobody has ever seen any real problem
yet. So this is a just-in-case fix.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
