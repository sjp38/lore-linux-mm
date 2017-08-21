Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8054F280310
	for <linux-mm@kvack.org>; Mon, 21 Aug 2017 10:10:25 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id y44so27573614wrd.13
        for <linux-mm@kvack.org>; Mon, 21 Aug 2017 07:10:25 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 94si5639263edq.89.2017.08.21.07.10.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 21 Aug 2017 07:10:23 -0700 (PDT)
Date: Mon, 21 Aug 2017 10:10:14 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH 0/6] proactive kcompactd
Message-ID: <20170821141014.GC1371@cmpxchg.org>
References: <20170727160701.9245-1-vbabka@suse.cz>
 <alpine.DEB.2.10.1708091353500.1218@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1708091353500.1218@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>

On Wed, Aug 09, 2017 at 01:58:42PM -0700, David Rientjes wrote:
> On Thu, 27 Jul 2017, Vlastimil Babka wrote:
> 
> > As we discussed at last LSF/MM [1], the goal here is to shift more compaction
> > work to kcompactd, which currently just makes a single high-order page
> > available and then goes to sleep. The last patch, evolved from the initial RFC
> > [2] does this by recording for each order > 0 how many allocations would have
> > potentially be able to skip direct compaction, if the memory wasn't fragmented.
> > Kcompactd then tries to compact as long as it takes to make that many
> > allocations satisfiable. This approach avoids any hooks in allocator fast
> > paths. There are more details to this, see the last patch.
> > 
> 
> I think I would have liked to have seen "less proactive" :)
> 
> Kcompactd currently has the problem that it is MIGRATE_SYNC_LIGHT so it 
> continues until it can defragment memory.  On a host with 128GB of memory 
> and 100GB of it sitting in a hugetlb pool, we constantly get kcompactd 
> wakeups for order-2 memory allocation.  The stats are pretty bad:
> 
> compact_migrate_scanned 2931254031294 
> compact_free_scanned    102707804816705 
> compact_isolated        1309145254 
> 
> 0.0012% of memory scanned is ever actually isolated.  We constantly see 
> very high cpu for compaction_alloc() because kcompactd is almost always 
> running in the background and iterating most memory completely needlessly 
> (define needless as 0.0012% of memory scanned being isolated).

The free page scanner will inevitably wade through mostly used memory,
but 0.0012% is lower than what systems usually have free. I'm guessing
this is because of concurrent allocation & free cycles racing with the
scanner? There could also be an issue with how we do partial scans.

Anyway, we've also noticed scalability issues with the current scanner
on 128G and 256G machines. Even with a better efficiency - finding the
1% of free memory, that's still a ton of linear search space.

I've been toying around with the below patch. It adds a free page
bitmap, allowing the free scanner to quickly skip over the vast areas
of used memory. I don't have good data on skip-efficiency at higher
uptimes and the resulting fragmentation yet. The overhead added to the
page allocator is concerning, but I cannot think of a better way to
make the search more efficient. What do you guys think?

---
