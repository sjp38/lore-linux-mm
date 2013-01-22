Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 319106B0004
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 19:09:56 -0500 (EST)
Date: Tue, 22 Jan 2013 09:09:54 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/2] mm: prevent to add a page to swap if may_writepage
 is unset
Message-ID: <20130122000954.GH3666@blaptop>
References: <1357712474-27595-1-git-send-email-minchan@kernel.org>
 <1357712474-27595-2-git-send-email-minchan@kernel.org>
 <20130116134155.18092f1a.akpm@linux-foundation.org>
 <20130117005314.GB18669@blaptop>
 <20130117142238.e32c46d5.akpm@linux-foundation.org>
 <20130117233641.GA31368@blaptop>
 <20130121015222.GA3666@blaptop>
 <50FD530A.6010500@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50FD530A.6010500@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Luigi Semenzato <semenzato@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Sonny Rao <sonnyrao@google.com>, Bryan Freed <bfreed@google.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>

On Mon, Jan 21, 2013 at 09:39:06AM -0500, Rik van Riel wrote:
> On 01/20/2013 08:52 PM, Minchan Kim wrote:
> 
> > From 94086dc7152359d052802c55c82ef19509fe8cce Mon Sep 17 00:00:00 2001
> >From: Minchan Kim <minchan@kernel.org>
> >Date: Mon, 21 Jan 2013 10:43:43 +0900
> >Subject: [PATCH] mm: Use up free swap space before reaching OOM kill
> >
> >Recently, Luigi reported there are lots of free swap space when
> >OOM happens. It's easily reproduced on zram-over-swap, where
> >many instance of memory hogs are running and laptop_mode is enabled.
> >He said there was no problem when he disabled laptop_mode.
> >The problem when I investigate problem is following as.
> >
> >Assumption for easy explanation: There are no page cache page in system
> >because they all are already reclaimed.
> >
> >1. try_to_free_pages disable may_writepage when laptop_mode is enabled.
> >2. shrink_inactive_list isolates victim pages from inactive anon lru list.
> >3. shrink_page_list adds them to swapcache via add_to_swap but it doesn't
> >    pageout because sc->may_writepage is 0 so the page is rotated back into
> >    inactive anon lru list. The add_to_swap made the page Dirty by SetPageDirty.
> >4. 3 couldn't reclaim any pages so do_try_to_free_pages increase priority and
> >    retry reclaim with higher priority.
> >5. shrink_inactlive_list try to isolate victim pages from inactive anon lru list
> >    but got failed because it try to isolate pages with ISOLATE_CLEAN mode but
> >    inactive anon lru list is full of dirty pages by 3 so it just returns
> >    without  any reclaim progress.
> >6. do_try_to_free_pages doesn't set may_writepage due to zero total_scanned.
> >    Because sc->nr_scanned is increased by shrink_page_list but we don't call
> >    shrink_page_list in 5 due to short of isolated pages.
> >
> >Above loop is continued until OOM happens.
> >The problem didn't happen before [1] was merged because old logic's
> >isolatation in shrink_inactive_list was successful and tried to call
> >shrink_page_list to pageout them but it still ends up failed to page out
> >by may_writepage. But important point is that sc->nr_scanned was increased
> >although we couldn't swap out them so do_try_to_free_pages could set
> >may_writepages.
> >
> >Since [1] was introduced, it's not a good idea any more to depends on
> >only the number of scanned pages for setting may_writepage. So this patch
> >adds new trigger point of setting may_writepage as below DEF_PRIOIRTY - 2
> >which is used to show the significant memory pressure in VM so it's good
> >fit for our purpose which would be better to lose power saving or clickety
> >rather than OOM killing.
> >
> >[1] f80c067[mm: zone_reclaim: make isolate_lru_page() filter-aware]
> >
> >Reported-by: Luigi Semenzato <semenzato@google.com>
> >Signed-off-by: Minchan Kim <minchan@kernel.org>
> 
> Your patch is a nice simplification.  I am ok with the
> change, provided it works for Luigi :)

Thanks, Rik.

Oops, I missed to Ccing Luigi. Add him again.
Luigi, Could you test this patch?
Thanks for your endless effort.

> 
> Acked-by: Rik van Riel <riel@redhat.com>
> 
> 
> -- 
> All rights reversed
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
