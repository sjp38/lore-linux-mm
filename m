Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id D63086B0032
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 11:52:40 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id q10so6503561pdj.20
        for <linux-mm@kvack.org>; Wed, 14 Aug 2013 08:52:40 -0700 (PDT)
Date: Thu, 15 Aug 2013 00:52:29 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: skip the page buddy block instead of one page
Message-ID: <20130814155205.GA2706@gmail.com>
References: <520B0B75.4030708@huawei.com>
 <20130814085711.GK2296@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130814085711.GK2296@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, aquini@redhat.com, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi Mel,

On Wed, Aug 14, 2013 at 09:57:11AM +0100, Mel Gorman wrote:
> On Wed, Aug 14, 2013 at 12:45:41PM +0800, Xishi Qiu wrote:
> > A large free page buddy block will continue many times, so if the page 
> > is free, skip the whole page buddy block instead of one page.
> > 
> > Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> 
> page_order cannot be used unless zone->lock is held which is not held in
> this path. Acquiring the lock would prevent parallel allocations from the

Argh, I missed that. And it seems you already pointed it out long time ago
someone try to do same things if I remember correctly. :(
But let's think about it more.

It's always not right because CMA and memory-hotplug already isolated
free pages in the range to MIGRATE_ISOLATE right before starting migration
so we could use page_order safely in those contexts even if we don't hold
zone->lock.
 
In addition, it's likely to have many free pages in case of CMA because CMA
makes MIGRATE_CMA fallback of MIGRATE_MOVABLE to minimize number of migrations.
Even CMA area was full, it could have many free pages once driver who is
CMA area's owner releases the CMA area. So, the bigger CMA space is,
the bigger patch's benefit is. And it could help memory-hotplug, too.

Only problem is normal compaction. The worst case is just skipping
pageblock_nr_pages, for instace, 4M(of course, it depends on configuration).
but we can make the race window very small by dobule checking PageBuddy.
Still, it could make the race theoretically but I think it's really really
unlikely and still enhance compaction overhead withtout holding the lock.
Even if the race happens, normal compaction's customers(ex, THP) doesn't
have critical result and just fallback. So I think it isn't not bad tradeoff.
