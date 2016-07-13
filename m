Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C423B6B025E
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 01:50:15 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e189so73987894pfa.2
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 22:50:15 -0700 (PDT)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id z62si2181548pfb.179.2016.07.12.22.50.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 22:50:14 -0700 (PDT)
Received: by mail-pa0-x242.google.com with SMTP id ib6so2381551pad.3
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 22:50:14 -0700 (PDT)
Date: Wed, 13 Jul 2016 15:50:39 +1000
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [PATCH 02/34] mm, vmscan: move lru_lock to the node
Message-ID: <20160713055039.GA23860@350D>
Reply-To: bsingharora@gmail.com
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-3-git-send-email-mgorman@techsingularity.net>
 <20160712110604.GA5981@350D>
 <20160712111805.GD9806@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160712111805.GD9806@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Balbir Singh <bsingharora@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 12, 2016 at 12:18:05PM +0100, Mel Gorman wrote:
> On Tue, Jul 12, 2016 at 09:06:04PM +1000, Balbir Singh wrote:
> > > diff --git a/Documentation/cgroup-v1/memory.txt b/Documentation/cgroup-v1/memory.txt
> > > index b14abf217239..946e69103cdd 100644
> > > --- a/Documentation/cgroup-v1/memory.txt
> > > +++ b/Documentation/cgroup-v1/memory.txt
> > > @@ -267,11 +267,11 @@ When oom event notifier is registered, event will be delivered.
> > >     Other lock order is following:
> > >     PG_locked.
> > >     mm->page_table_lock
> > > -       zone->lru_lock
> > > +       zone_lru_lock
> > 
> > zone_lru_lock is a little confusing, can't we just call it
> > node_lru_lock?
> > 
> 
> It's a matter of perspective. People familiar with the VM already expect
> a zone lock so will be looking for it. I can do a rename if you insist
> but it may not actually help.

I don't want to insist, but zone_ in the name can be confusing, as to
leading us to think that the lru_lock is still in the zone

If the rest of the reviewers are fine with, we don't need to rename

> 
> > > @@ -496,7 +496,6 @@ struct zone {
> > >  	/* Write-intensive fields used by page reclaim */
> > >  
> > >  	/* Fields commonly accessed by the page reclaim scanner */
> > > -	spinlock_t		lru_lock;
> > >  	struct lruvec		lruvec;
> > >  
> > >  	/*
> > > @@ -690,6 +689,9 @@ typedef struct pglist_data {
> > >  	/* Number of pages migrated during the rate limiting time interval */
> > >  	unsigned long numabalancing_migrate_nr_pages;
> > >  #endif
> > > +	/* Write-intensive fields used by page reclaim */
> > > +	ZONE_PADDING(_pad1_)a
> > 
> > I thought this was to have zone->lock and zone->lru_lock in different
> > cachelines, do we still need the padding here?
> > 
> 
> The zone padding current keeps the page lock wait tables, page allocator
> lists, compaction and vmstats on separate cache lines. They're still
> fine.
> 
> The node padding may not be necessary. It currently ensures that zonelists
> and numa balancing are separate from the LRU lock but there is no guarantee
> the current arrangement is optimal. It would depend on both the kernel
> config and the workload but it may be necessary in the future to split
> node into read-mostly sections and then different write-intensive sections
> similar to what has happened to struct zone in the past.
>

Fair enough

Balbir Singh. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
