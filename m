Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 878C56B0069
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 23:16:10 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id h24so41839516pfh.0
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 20:16:10 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e23si502111pga.305.2016.10.20.20.16.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Oct 2016 20:16:09 -0700 (PDT)
Date: Thu, 20 Oct 2016 20:16:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, compaction: fix NR_ISOLATED_* stats for pfn based
 migration
Message-Id: <20161020201606.2da29e792856a03a0da0adb2@linux-foundation.org>
In-Reply-To: <20161019080240.9682-1-mhocko@kernel.org>
References: <20161019080240.9682-1-mhocko@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "ming.ling" <ming.ling@spreadtrum.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Wed, 19 Oct 2016 10:02:40 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> Since bda807d44454 ("mm: migrate: support non-lru movable page
> migration") isolate_migratepages_block) can isolate !PageLRU pages which
> would acct_isolated account as NR_ISOLATED_*. Accounting these non-lru
> pages NR_ISOLATED_{ANON,FILE} doesn't make any sense and it can misguide
> heuristics based on those counters such as pgdat_reclaimable_pages resp.
> too_many_isolated which would lead to unexpected stalls during the
> direct reclaim without any good reason. Note that
> __alloc_contig_migrate_range can isolate a lot of pages at once.
> 
> On mobile devices such as 512M ram android Phone, it may use a big zram
> swap. In some cases zram(zsmalloc) uses too many non-lru but migratedable
> pages, such as:
> 
>       MemTotal: 468148 kB
>       Normal free:5620kB
>       Free swap:4736kB
>       Total swap:409596kB
>       ZRAM: 164616kB(zsmalloc non-lru pages)
>       active_anon:60700kB
>       inactive_anon:60744kB
>       active_file:34420kB
>       inactive_file:37532kB
> 
> Fix this by only accounting lru pages to NR_ISOLATED_* in
> isolate_migratepages_block right after they were isolated and we still
> know they were on LRU. Drop acct_isolated because it is called after the
> fact and we've lost that information. Batching per-cpu counter doesn't
> make much improvement anyway. Also make sure that we uncharge only LRU
> pages when putting them back on the LRU in putback_movable_pages resp.
> when unmap_and_move migrates the page.

It isn't worth backporting into 4.8.x?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
