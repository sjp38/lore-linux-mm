Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id EECF26B0261
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 07:18:08 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id p41so9160836lfi.0
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 04:18:08 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id f9si3926936wmg.96.2016.07.12.04.18.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Jul 2016 04:18:07 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id E352898CFB
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 11:18:06 +0000 (UTC)
Date: Tue, 12 Jul 2016 12:18:05 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 02/34] mm, vmscan: move lru_lock to the node
Message-ID: <20160712111805.GD9806@techsingularity.net>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-3-git-send-email-mgorman@techsingularity.net>
 <20160712110604.GA5981@350D>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160712110604.GA5981@350D>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 12, 2016 at 09:06:04PM +1000, Balbir Singh wrote:
> > diff --git a/Documentation/cgroup-v1/memory.txt b/Documentation/cgroup-v1/memory.txt
> > index b14abf217239..946e69103cdd 100644
> > --- a/Documentation/cgroup-v1/memory.txt
> > +++ b/Documentation/cgroup-v1/memory.txt
> > @@ -267,11 +267,11 @@ When oom event notifier is registered, event will be delivered.
> >     Other lock order is following:
> >     PG_locked.
> >     mm->page_table_lock
> > -       zone->lru_lock
> > +       zone_lru_lock
> 
> zone_lru_lock is a little confusing, can't we just call it
> node_lru_lock?
> 

It's a matter of perspective. People familiar with the VM already expect
a zone lock so will be looking for it. I can do a rename if you insist
but it may not actually help.

> > @@ -496,7 +496,6 @@ struct zone {
> >  	/* Write-intensive fields used by page reclaim */
> >  
> >  	/* Fields commonly accessed by the page reclaim scanner */
> > -	spinlock_t		lru_lock;
> >  	struct lruvec		lruvec;
> >  
> >  	/*
> > @@ -690,6 +689,9 @@ typedef struct pglist_data {
> >  	/* Number of pages migrated during the rate limiting time interval */
> >  	unsigned long numabalancing_migrate_nr_pages;
> >  #endif
> > +	/* Write-intensive fields used by page reclaim */
> > +	ZONE_PADDING(_pad1_)a
> 
> I thought this was to have zone->lock and zone->lru_lock in different
> cachelines, do we still need the padding here?
> 

The zone padding current keeps the page lock wait tables, page allocator
lists, compaction and vmstats on separate cache lines. They're still
fine.

The node padding may not be necessary. It currently ensures that zonelists
and numa balancing are separate from the LRU lock but there is no guarantee
the current arrangement is optimal. It would depend on both the kernel
config and the workload but it may be necessary in the future to split
node into read-mostly sections and then different write-intensive sections
similar to what has happened to struct zone in the past.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
