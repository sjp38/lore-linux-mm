Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B728028070C
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 16:57:18 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id b8so96706134pgn.10
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 13:57:18 -0700 (PDT)
Received: from mail-pg0-x229.google.com (mail-pg0-x229.google.com. [2607:f8b0:400e:c05::229])
        by mx.google.com with ESMTPS id o1si10237979pld.315.2017.08.22.13.57.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Aug 2017 13:57:16 -0700 (PDT)
Received: by mail-pg0-x229.google.com with SMTP id m133so37280075pga.5
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 13:57:16 -0700 (PDT)
Date: Tue, 22 Aug 2017 13:57:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH 0/6] proactive kcompactd
In-Reply-To: <20170821141014.GC1371@cmpxchg.org>
Message-ID: <alpine.DEB.2.10.1708221351510.45189@chino.kir.corp.google.com>
References: <20170727160701.9245-1-vbabka@suse.cz> <alpine.DEB.2.10.1708091353500.1218@chino.kir.corp.google.com> <20170821141014.GC1371@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>

On Mon, 21 Aug 2017, Johannes Weiner wrote:

> > I think I would have liked to have seen "less proactive" :)
> > 
> > Kcompactd currently has the problem that it is MIGRATE_SYNC_LIGHT so it 
> > continues until it can defragment memory.  On a host with 128GB of memory 
> > and 100GB of it sitting in a hugetlb pool, we constantly get kcompactd 
> > wakeups for order-2 memory allocation.  The stats are pretty bad:
> > 
> > compact_migrate_scanned 2931254031294 
> > compact_free_scanned    102707804816705 
> > compact_isolated        1309145254 
> > 
> > 0.0012% of memory scanned is ever actually isolated.  We constantly see 
> > very high cpu for compaction_alloc() because kcompactd is almost always 
> > running in the background and iterating most memory completely needlessly 
> > (define needless as 0.0012% of memory scanned being isolated).
> 
> The free page scanner will inevitably wade through mostly used memory,
> but 0.0012% is lower than what systems usually have free. I'm guessing
> this is because of concurrent allocation & free cycles racing with the
> scanner? There could also be an issue with how we do partial scans.
> 

More than 90% of this system's memory is in the hugetlbfs pool so the 
freeing scanner needlessly scans over it.  Because kcompactd does 
MIGRATE_SYNC_LIGHT compaction, it doesn't stop iterating until the 
allocation is successful at pgdat->kcompactd_max_order or the migration 
and freeing scanners meet.  This is normally all memory.

Because of MIGRATE_SYNC_LIGHT, kcompactd does respect deferred compaction 
and will avoid doing compaction at all for the next 
1 << COMPACT_MAX_DEFER_SHIFT wakeups, but while the rest of userspace not 
mapping hugetlbfs memory tries to fault thp, this happens almost nonstop 
at 100% of cpu.

Although this might not be a typical configuration, it can easily be used 
to demonstrate how inefficient kcompactd behaves under load when a small 
amount of memory is free or cannot be isolated because its pinned.  
vm.extfrag_threshold isn't an adequate solution.

> Anyway, we've also noticed scalability issues with the current scanner
> on 128G and 256G machines. Even with a better efficiency - finding the
> 1% of free memory, that's still a ton of linear search space.
> 

Agreed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
