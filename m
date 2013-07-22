Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id B2D476B0032
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 16:14:49 -0400 (EDT)
Date: Mon, 22 Jul 2013 16:14:40 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 1/3] mm: vmscan: fix numa reclaim balance problem in
 kswapd
Message-ID: <20130722201439.GF715@cmpxchg.org>
References: <1374267325-22865-1-git-send-email-hannes@cmpxchg.org>
 <1374267325-22865-2-git-send-email-hannes@cmpxchg.org>
 <51ED8C37.5020306@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51ED8C37.5020306@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 22, 2013 at 03:47:03PM -0400, Rik van Riel wrote:
> On 07/19/2013 04:55 PM, Johannes Weiner wrote:
> >When the page allocator fails to get a page from all zones in its
> >given zonelist, it wakes up the per-node kswapds for all zones that
> >are at their low watermark.
> >
> >However, with a system under load and the free page counters being
> >per-cpu approximations, the observed counter value in a zone can
> >fluctuate enough that the allocation fails but the kswapd wakeup is
> >also skipped while the zone is still really close to the low
> >watermark.
> >
> >When one node misses a wakeup like this, it won't be aged before all
> >the other node's zones are down to their low watermarks again.  And
> >skipping a full aging cycle is an obvious fairness problem.
> >
> >Kswapd runs until the high watermarks are restored, so it should also
> >be woken when the high watermarks are not met.  This ages nodes more
> >equally and creates a safety margin for the page counter fluctuation.
> >
> >By using zone_balanced(), it will now check, in addition to the
> >watermark, if compaction requires more order-0 pages to create a
> >higher order page.
> >
> >Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> This patch alone looks like it could have the effect of increasing
> the pressure on the first zone in the zonelist, keeping its free
> memory above the low watermark essentially forever, without having
> the allocator fall back to other zones.
> 
> However, your third patch fixes that problem, and missed wakeups
> would still hurt, so...

The kswapd wakeups happen in the slowpath, after the fastpath tried
all zones in the zonelist, not just the first one.

With the problem fixed in #3, the slowpath is rarely entered (even
when kswapds should be woken).  From that point of view, the effects
of #1 are further improved by #3, but #1 on its own does not worsen
the situation.

> Reviewed-by: Rik van Riel <riel@redhat.com>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
