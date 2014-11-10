Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 8BB2E82BEF
	for <linux-mm@kvack.org>; Mon, 10 Nov 2014 01:46:47 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id fp1so7260961pdb.13
        for <linux-mm@kvack.org>; Sun, 09 Nov 2014 22:46:47 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id to5si15772442pac.7.2014.11.09.22.46.45
        for <linux-mm@kvack.org>;
        Sun, 09 Nov 2014 22:46:46 -0800 (PST)
Date: Mon, 10 Nov 2014 17:46:40 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [rfc patch] mm: vmscan: invoke slab shrinkers for each lruvec
Message-ID: <20141110064640.GO23575@dastard>
References: <1415317828-19390-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1415317828-19390-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Nov 06, 2014 at 06:50:28PM -0500, Johannes Weiner wrote:
> The slab shrinkers currently rely on the reclaim code providing an
> ad-hoc concept of NUMA nodes that doesn't really exist: for all
> scanned zones and lruvecs, the nodes and available LRU pages are
> summed up, only to have the shrinkers then again walk that nodemask
> when scanning slab caches.  This duplication will only get worse and
> more expensive once the shrinkers become aware of cgroups.

As i said previously, it's not an "ad-hoc concept". It's exactly the
same NUMA abstraction that the VM presents to anyone who wants to
control memory allocation locality. i.e. node IDs and node masks.

> Instead, invoke the shrinkers for each lruvec scanned - which is
> either the zone level, or in case of cgroups, the subset of a zone's
> pages that is charged to the scanned memcg.  The number of eligible
> LRU pages is naturally available at that level - it is even more
> accurate than simply looking at the global state and the number of
> available swap pages, as get_scan_count() considers many other factors
> when deciding which LRU pages to consider.
> 
> This invokes the shrinkers more often and with smaller page and scan
> counts, but the ratios remain the same, and the shrinkers themselves
> do not add significantly to the existing per-lruvec cost.

That goes in the opposite direction is which we've found filesystem
shrinkers operate most effectively. i.e. larger batches with less
frequent reclaim callouts tend to result in more consistent
performance because shrinkers take locks and do IO that other
application operations get stuck behind (shrink_batch exists
for this reason ;).

>
> This integrates the slab shrinking nicely into the reclaim logic.  Not
> just conceptually, but it also allows kswapd, the direct reclaim code,
> and zone reclaim to get rid of their ad-hoc custom slab shrinking.
> 
> Lastly, this facilitates making the shrinkers cgroup-aware without a
> fantastic amount code and runtime work duplication, and consolidation 
> will make hierarchy walk optimizations easier later on.

It still makes callers have to care about internal VM metrics
to calculate how much work they should do. Callers should be able to
pass in a measure of how much work the shrinker should do (e.g. as
a percentage of cache size). Even the VM can use this - it can take
it's scanned/pages variables and use them to calculate the
percentage of caches to free, and the shrinker loop can then be
completely free of any relationship to the LRU page reclaim
implementation.....

e.g. drop_caches() should just be able to call "shrink_slab_all()"
and not have to care about nodes, batch sizes, detect when caches
are empty, etc. Similarly shake_page() only wants
"shrink_slab_node_nr()" to free a small amount of objects from the
node it cares about each time.

i.e. we should be writing helpers to remove shrinker implementation
quirks from callers, not driving more of the quirks into external
callers...

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  drivers/staging/android/ashmem.c |   1 -
>  fs/drop_caches.c                 |  15 ++--
>  include/linux/shrinker.h         |   2 -
>  mm/memory-failure.c              |   3 +-
>  mm/vmscan.c                      | 164 +++++++++++++--------------------------
>  5 files changed, 63 insertions(+), 122 deletions(-)
> 
> I put this together as a result of the discussion with Vladimir about
> memcg-aware slab shrinkers this morning.
> 
> This might need some tuning, but it definitely looks like the right
> thing to do conceptually.  I'm currently playing with various slab-
> and memcg-heavy workloads (many numa nodes + many cgroups = many
> shrinker invocations) but so far the numbers look okay.
> 
> It would be great if other people could weigh in, and possibly also
> expose it to their favorite filesystem and reclaim stress tests.

Causes substantial increase in performance variability on inode
intensive benchmarks. On my standard fsmark benchmark, I see file
creates sit at around 250,000/sec, but there's several second long
dips to about 50,000/sec co-inciding with the inode cache being
trimmed by several million inodes. Looking more deeply, this is due
to memory pressure driving inode writeback - we're reclaiming inodes
that haven't yet been written to disk, and so by reclaiming the
inode cache slab more frequently it's driving larger peaks of IO
and blocking ongoing filesystem operations more frequently.

My initial thoughts are that this correlates with the above comments
I made about frequency of shrinker calls and batch sizes, so I
suspect that the aggregation of shrinker-based reclaim work is
necessary to minimise the interference that recalim causes at the
filesystem level...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
