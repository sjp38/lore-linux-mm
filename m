Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 1D77B6B00A3
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 05:16:30 -0400 (EDT)
Date: Mon, 15 Jul 2013 11:16:21 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 7/7] mm: compaction: add compaction to zone_reclaim_mode
Message-ID: <20130715091621.GQ4081@redhat.com>
References: <1370445037-24144-1-git-send-email-aarcange@redhat.com>
 <1370445037-24144-8-git-send-email-aarcange@redhat.com>
 <20130606100503.GH1936@suse.de>
 <20130711160216.GA30320@redhat.com>
 <51DFF5FD.8040007@gmail.com>
 <20130712160149.GB4524@redhat.com>
 <51E0900E.9080504@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51E0900E.9080504@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hush Bensen <hush.bensen@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>

On Sat, Jul 13, 2013 at 07:23:58AM +0800, Hush Bensen wrote:
> Do you mean your patch done this fair? There is target zone shrink as 
> you mentiond in the vanilla kernel, however, your patch also done target 
> compaction/reclaim, is this fair?

It's still not fair, zone_reclaim_mode cannot be (modulo major rework
at least) as its whole point is to reclaim memory from the local node
indefinitely, even if there's plenty of "free" or "reclaimable" memory
in remote nodes.

But waking kswapd before all nodes are below the low wmark probably
would make it even less fair than it is now, or at least it wouldn't
provide a fariness increase.

The idea of allowing allocations in the min-low wmark range is that
the "low" wmark would be restored soon anyway at the next
zone_reclaim() invocation, and the zone_reclaim will still behave
synchronous (like direct reclaim) without ever waking kswapd,
regardless if we stop at the low or at the min. But if we stop at the
"low" we're more susceptible to parallel allocation jitters as the
jitter-error margin then becomes:

		.nr_to_reclaim = max(nr_pages, SWAP_CLUSTER_MAX),

which is just 1 single high order page in case of (1<<order) >=
SWAP_CLUSTER_MAX. While if we use the "min" wmark after a successful
zone_reclaim(zone) to decide if to allocate from the zone (the one
passed to zone_reclaim, we may have more margin for allocation jitters
in other CPUs of the same node, or interrupts.

So this again is connected to altering the wmark calculation for high
order pages in the previous patch (which also is intended to allow
having more than 1 THP page in the low-min wmark range). We don't need
many, too many is just a waste of CPU, but a few more than 1
significantly improves the NUMA locality on first allocation if all
CPUs in the node are allocating memory at the same time. I also
trimmed down to zero the high order page requirement for the min
wmark, as we don't need to guarantee hugepage availability for
PF_MEMALLOC (which avoids useless compaction work).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
