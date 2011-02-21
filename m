Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2B4E08D0039
	for <linux-mm@kvack.org>; Mon, 21 Feb 2011 03:30:04 -0500 (EST)
Date: Mon, 21 Feb 2011 09:29:52 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v6 1/3] deactivate invalidated pages
Message-ID: <20110221082952.GB25382@cmpxchg.org>
References: <cover.1298212517.git.minchan.kim@gmail.com>
 <5b1eeca414d39e77afdb9684eab36addd11520a1.1298212517.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5b1eeca414d39e77afdb9684eab36addd11520a1.1298212517.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Steven Barrett <damentz@liquorix.net>, Ben Gamari <bgamari.foss@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Sun, Feb 20, 2011 at 11:43:36PM +0900, Minchan Kim wrote:
> Recently, there are reported problem about thrashing.
> (http://marc.info/?l=rsync&m=128885034930933&w=2)
> It happens by backup workloads(ex, nightly rsync).
> That's because the workload makes just use-once pages
> and touches pages twice. It promotes the page into
> active list so that it results in working set page eviction.
> 
> Some app developer want to support POSIX_FADV_NOREUSE.
> But other OSes don't support it, either.
> (http://marc.info/?l=linux-mm&m=128928979512086&w=2)
> 
> By other approach, app developers use POSIX_FADV_DONTNEED.
> But it has a problem. If kernel meets page is writing
> during invalidate_mapping_pages, it can't work.
> It makes for application programmer to use it since they always
> have to sync data before calling fadivse(..POSIX_FADV_DONTNEED) to
> make sure the pages could be discardable. At last, they can't use
> deferred write of kernel so that they could see performance loss.
> (http://insights.oetiker.ch/linux/fadvise.html)
> 
> In fact, invalidation is very big hint to reclaimer.
> It means we don't use the page any more. So let's move
> the writing page into inactive list's head if we can't truncate
> it right now.
> 
> Why I move page to head of lru on this patch, Dirty/Writeback page
> would be flushed sooner or later. It can prevent writeout of pageout
> which is less effective than flusher's writeout.
> 
> Originally, I reused lru_demote of Peter with some change so added
> his Signed-off-by.
> 
> Reported-by: Ben Gamari <bgamari.foss@gmail.com>
> Signed-off-by: Peter Zijlstra <peterz@infradead.org>
> Acked-by: Rik van Riel <riel@redhat.com>
> Acked-by: Mel Gorman <mel@csn.ul.ie>
> Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Wu Fengguang <fengguang.wu@intel.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Nick Piggin <npiggin@kernel.dk>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
