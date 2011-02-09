Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EF09C8D0039
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 11:47:25 -0500 (EST)
Date: Wed, 9 Feb 2011 16:46:56 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch] vmscan: fix zone shrinking exit when scan work is done
Message-ID: <20110209164656.GA1063@csn.ul.ie>
References: <20110209154606.GJ27110@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110209154606.GJ27110@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Kent Overstreet <kent.overstreet@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Feb 09, 2011 at 04:46:06PM +0100, Johannes Weiner wrote:
> Hi,
> 
> I think this should fix the problem of processes getting stuck in
> reclaim that has been reported several times.

I don't think it's the only source but I'm basing this on seeing
constant looping in balance_pgdat() and calling congestion_wait() a few
weeks ago that I haven't rechecked since. However, this looks like a
real fix for a real problem.

> Kent actually
> single-stepped through this code and noted that it was never exiting
> shrink_zone(), which really narrowed it down a lot, considering the
> tons of nested loops from the allocator down to the list shrinking.
> 
> 	Hannes
> 
> ---
> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: vmscan: fix zone shrinking exit when scan work is done
> 
> '3e7d344 mm: vmscan: reclaim order-0 and use compaction instead of
> lumpy reclaim' introduced an indefinite loop in shrink_zone().
> 
> It meant to break out of this loop when no pages had been reclaimed
> and not a single page was even scanned.  The way it would detect the
> latter is by taking a snapshot of sc->nr_scanned at the beginning of
> the function and comparing it against the new sc->nr_scanned after the
> scan loop.  But it would re-iterate without updating that snapshot,
> looping forever if sc->nr_scanned changed at least once since
> shrink_zone() was invoked.
> 
> This is not the sole condition that would exit that loop, but it
> requires other processes to change the zone state, as the reclaimer
> that is stuck obviously can not anymore.
> 
> This is only happening for higher-order allocations, where reclaim is
> run back to back with compaction.
> 
> Reported-by: Michal Hocko <mhocko@suse.cz>
> Reported-by: Kent Overstreet <kent.overstreet@gmail.com>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Well spotted.

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
