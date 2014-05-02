Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 2C7FC6B0038
	for <linux-mm@kvack.org>; Fri,  2 May 2014 16:29:38 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id bj1so5946219pad.15
        for <linux-mm@kvack.org>; Fri, 02 May 2014 13:29:37 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id fd9si10771pad.265.2014.05.02.13.29.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 02 May 2014 13:29:36 -0700 (PDT)
Received: by mail-pa0-f46.google.com with SMTP id kx10so3203088pab.19
        for <linux-mm@kvack.org>; Fri, 02 May 2014 13:29:36 -0700 (PDT)
Date: Fri, 2 May 2014 13:29:33 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2 4/4] mm, thp: do not perform sync compaction on
 pagefault
In-Reply-To: <20140502115834.GR23991@suse.de>
Message-ID: <alpine.DEB.2.02.1405021319350.24195@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com> <alpine.DEB.2.02.1405011434140.23898@chino.kir.corp.google.com> <alpine.DEB.2.02.1405011435210.23898@chino.kir.corp.google.com> <20140502102231.GQ23991@suse.de>
 <alpine.DEB.2.02.1405020402500.19297@chino.kir.corp.google.com> <20140502115834.GR23991@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 2 May 2014, Mel Gorman wrote:

> > The page locks I'm referring to is the lock_page() in __unmap_and_move() 
> > that gets called for sync compaction after the migrate_pages() iteration 
> > makes a few passes and unsuccessfully grabs it.  This becomes a forced 
> > migration since __unmap_and_move() returns -EAGAIN when the trylock fails.
> > 
> 
> Can that be fixed then instead of disabling it entirely?
> 

We could return -EAGAIN when the trylock_page() fails for 
MIGRATE_SYNC_LIGHT.  It would become a forced migration but we ignore that 
currently for MIGRATE_ASYNC, and I could extend it to be ignored for 
MIGRATE_SYNC_LIGHT as well.

> > We have perf profiles from one workload in particular that shows 
> > contention on i_mmap_mutex (anon isn't interesting since the vast majority 
> > of memory on this workload [120GB on a 128GB machine] is has a gup pin and 
> > doesn't get isolated because of 119d6d59dcc0 ("mm, compaction: avoid 
> > isolating pinned pages")) between cpus all doing memory compaction trying 
> > to fault thp memory.
> > 
> 
> Abort SYNC_LIGHT compaction if the mutex is contended.
> 

Yeah, I have patches for that as well but we're waiting to see if they are 
actually needed when sync compaction is disabled for thp.  If we aren't 
actually going to disable it entirely, then I can revive those patches if 
the contention becomes such an issue.

> > That's one example that we've seen, but the fact remains that at times 
> > sync compaction will iterate the entire 128GB machine and not allow an 
> > order-9 page to be allocated and there's nothing to preempt it like the 
> > need_resched() or lock contention checks that async compaction has. 
> 
> Make compact_control->sync the same enum field and check for contention
> on the async/sync_light case but leave it for sync if compacting via the
> proc interface?
> 

Ok, that certainly can be done, I wasn't sure you would be happy with such 
a change.  I'm not sure there's so much of a difference between the new 
compact_control->sync == MIGRATE_ASYNC and == MIGRATE_SYNC_LIGHT now, 
though.  Would it make sense to remove MIGRATE_SYNC_LIGHT entirely from 
the page allocator, i.e. remove sync_migration entirely, and just retry 
with a second call to compaction before failing instead? 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
