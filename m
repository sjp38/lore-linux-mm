Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 966CF6B0092
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 03:43:11 -0500 (EST)
Date: Tue, 25 Jan 2011 09:42:35 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm: clear pages_scanned only if draining a pcp adds
 pages to the buddy allocator
Message-ID: <20110125084235.GC2217@cmpxchg.org>
References: <alpine.DEB.2.00.1101231457130.966@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1101231457130.966@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jan 23, 2011 at 02:58:39PM -0800, David Rientjes wrote:
> 0e093d99763e (writeback: do not sleep on the congestion queue if there
> are no congested BDIs or if significant congestion is not being
> encountered in the current zone) uncovered a livelock in the page
> allocator that resulted in tasks infinitely looping trying to find memory
> and kswapd running at 100% cpu.
> 
> The issue occurs because drain_all_pages() is called immediately
> following direct reclaim when no memory is freed and try_to_free_pages()
> returns non-zero because all zones in the zonelist do not have their
> all_unreclaimable flag set.
> 
> When draining the per-cpu pagesets back to the buddy allocator for each
> zone, the zone->pages_scanned counter is cleared to avoid erroneously
> setting zone->all_unreclaimable later.  The problem is that no pages may
> actually be drained and, thus, the unreclaimable logic never fails direct
> reclaim so the oom killer may be invoked.
> 
> This apparently only manifested after wait_iff_congested() was introduced
> and the zone was full of anonymous memory that would not congest the
> backing store.  The page allocator would infinitely loop if there were no
> other tasks waiting to be scheduled and clear zone->pages_scanned because
> of drain_all_pages() as the result of this change before kswapd could
> scan enough pages to trigger the reclaim logic.  Additionally, with every
> loop of the page allocator and in the reclaim path, kswapd would be
> kicked and would end up running at 100% cpu.  In this scenario, current
> and kswapd are all running continuously with kswapd incrementing
> zone->pages_scanned and current clearing it.
> 
> The problem is even more pronounced when current swaps some of its memory
> to swap cache and the reclaimable logic then considers all active
> anonymous memory in the all_unreclaimable logic, which requires a much
> higher zone->pages_scanned value for try_to_free_pages() to return zero
> that is never attainable in this scenario.
> 
> Before wait_iff_congested(), the page allocator would incur an
> unconditional timeout and allow kswapd to elevate zone->pages_scanned to
> a level that the oom killer would be called the next time it loops.
> 
> The fix is to only attempt to drain pcp pages if there is actually a
> quantity to be drained.  The unconditional clearing of
> zone->pages_scanned in free_pcppages_bulk() need not be changed since
> other callers already ensure that draining will occur.  This patch
> ensures that free_pcppages_bulk() will actually free memory before
> calling into it from drain_all_pages() so zone->pages_scanned is only
> cleared if appropriate.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
