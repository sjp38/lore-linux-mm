Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 995416B02C3
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 16:58:45 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id i192so76223274pgc.11
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 13:58:45 -0700 (PDT)
Received: from mail-pg0-x22f.google.com (mail-pg0-x22f.google.com. [2607:f8b0:400e:c05::22f])
        by mx.google.com with ESMTPS id p2si2905935pgc.67.2017.08.09.13.58.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Aug 2017 13:58:44 -0700 (PDT)
Received: by mail-pg0-x22f.google.com with SMTP id u5so32697960pgn.0
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 13:58:44 -0700 (PDT)
Date: Wed, 9 Aug 2017 13:58:42 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH 0/6] proactive kcompactd
In-Reply-To: <20170727160701.9245-1-vbabka@suse.cz>
Message-ID: <alpine.DEB.2.10.1708091353500.1218@chino.kir.corp.google.com>
References: <20170727160701.9245-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>

On Thu, 27 Jul 2017, Vlastimil Babka wrote:

> As we discussed at last LSF/MM [1], the goal here is to shift more compaction
> work to kcompactd, which currently just makes a single high-order page
> available and then goes to sleep. The last patch, evolved from the initial RFC
> [2] does this by recording for each order > 0 how many allocations would have
> potentially be able to skip direct compaction, if the memory wasn't fragmented.
> Kcompactd then tries to compact as long as it takes to make that many
> allocations satisfiable. This approach avoids any hooks in allocator fast
> paths. There are more details to this, see the last patch.
> 

I think I would have liked to have seen "less proactive" :)

Kcompactd currently has the problem that it is MIGRATE_SYNC_LIGHT so it 
continues until it can defragment memory.  On a host with 128GB of memory 
and 100GB of it sitting in a hugetlb pool, we constantly get kcompactd 
wakeups for order-2 memory allocation.  The stats are pretty bad:

compact_migrate_scanned 2931254031294 
compact_free_scanned    102707804816705 
compact_isolated        1309145254 

0.0012% of memory scanned is ever actually isolated.  We constantly see 
very high cpu for compaction_alloc() because kcompactd is almost always 
running in the background and iterating most memory completely needlessly 
(define needless as 0.0012% of memory scanned being isolated).

vm.extfrag_threshold isn't a solution to the problem because it sees 
memory as being free in the 28GB of memory remaining and isolates/migrates 
even if order-2 memory will not become available, so it would need to be 
set at >850 for it to prevent compaction.  If memory is freed from the 
hugetlb pool we would need to adjust the threshold at runtime.  (Why is 
kcompactd setting ignore_skip_hint, again?)

I think we need to look at making kcompactd do less work on each wakeup, 
perhaps by not forcing full scans of memory with MIGRATE_SYNC_LIGHT and 
defer compaction for longer if most scanning is completely pointless.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
