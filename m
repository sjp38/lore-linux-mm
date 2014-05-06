Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id B4D946B00E2
	for <linux-mm@kvack.org>; Tue,  6 May 2014 04:55:21 -0400 (EDT)
Received: by mail-ee0-f42.google.com with SMTP id d49so2141172eek.1
        for <linux-mm@kvack.org>; Tue, 06 May 2014 01:55:21 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w48si12720084eel.356.2014.05.06.01.55.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 May 2014 01:55:20 -0700 (PDT)
Date: Tue, 6 May 2014 09:55:15 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch v2 4/4] mm, thp: do not perform sync compaction on
 pagefault
Message-ID: <20140506085515.GW23991@suse.de>
References: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1405011434140.23898@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1405011435210.23898@chino.kir.corp.google.com>
 <20140502102231.GQ23991@suse.de>
 <alpine.DEB.2.02.1405020402500.19297@chino.kir.corp.google.com>
 <20140502115834.GR23991@suse.de>
 <alpine.DEB.2.02.1405021319350.24195@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1405021319350.24195@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, May 02, 2014 at 01:29:33PM -0700, David Rientjes wrote:
> On Fri, 2 May 2014, Mel Gorman wrote:
> 
> > > The page locks I'm referring to is the lock_page() in __unmap_and_move() 
> > > that gets called for sync compaction after the migrate_pages() iteration 
> > > makes a few passes and unsuccessfully grabs it.  This becomes a forced 
> > > migration since __unmap_and_move() returns -EAGAIN when the trylock fails.
> > > 
> > 
> > Can that be fixed then instead of disabling it entirely?
> > 
> 
> We could return -EAGAIN when the trylock_page() fails for 
> MIGRATE_SYNC_LIGHT.  It would become a forced migration but we ignore that 
> currently for MIGRATE_ASYNC, and I could extend it to be ignored for 
> MIGRATE_SYNC_LIGHT as well.
> 
> > > We have perf profiles from one workload in particular that shows 
> > > contention on i_mmap_mutex (anon isn't interesting since the vast majority 
> > > of memory on this workload [120GB on a 128GB machine] is has a gup pin and 
> > > doesn't get isolated because of 119d6d59dcc0 ("mm, compaction: avoid 
> > > isolating pinned pages")) between cpus all doing memory compaction trying 
> > > to fault thp memory.
> > > 
> > 
> > Abort SYNC_LIGHT compaction if the mutex is contended.
> > 
> 
> Yeah, I have patches for that as well but we're waiting to see if they are 
> actually needed when sync compaction is disabled for thp.  If we aren't 
> actually going to disable it entirely, then I can revive those patches if 
> the contention becomes such an issue.
> 
> > > That's one example that we've seen, but the fact remains that at times 
> > > sync compaction will iterate the entire 128GB machine and not allow an 
> > > order-9 page to be allocated and there's nothing to preempt it like the 
> > > need_resched() or lock contention checks that async compaction has. 
> > 
> > Make compact_control->sync the same enum field and check for contention
> > on the async/sync_light case but leave it for sync if compacting via the
> > proc interface?
> > 
> 
> Ok, that certainly can be done, I wasn't sure you would be happy with such 
> a change. 

I'm not super-keen as the success rates are already very poor for allocations
under pressure. It's something Vlastimil is working on so it may be possible
to get some of the success rates back. It has always been the case that
compaction should not severely impact overall performance as THP gains
must offset compaction. While I'm not happy to reduce the success rates
further I do not think we should leave a known performance impact on
128G machines wait on Vlastimil's series.

Vlastimil, what do you think?

> I'm not sure there's so much of a difference between the new 
> compact_control->sync == MIGRATE_ASYNC and == MIGRATE_SYNC_LIGHT now, 
> though.  Would it make sense to remove MIGRATE_SYNC_LIGHT entirely from 
> the page allocator, i.e. remove sync_migration entirely, and just retry 
> with a second call to compaction before failing instead? 

Would it be possible if only khugepaged entered SYNC_LIGHT migration and
kswapd and direct THP allocations used only MIGRATE_ASYNC? That would
allow khugepaged to continue locking pages and buffers in a slow path
while still not allowing it to issue IO or wait on writeback. It would
also give a chance for Vlastimil's series to shake out a bit without him
having to reintroduce SYNC_LIGHT as part of that series.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
