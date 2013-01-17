Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id DF7736B0006
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 17:22:40 -0500 (EST)
Date: Thu, 17 Jan 2013 14:22:38 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm: prevent to add a page to swap if may_writepage
 is unset
Message-Id: <20130117142238.e32c46d5.akpm@linux-foundation.org>
In-Reply-To: <20130117005314.GB18669@blaptop>
References: <1357712474-27595-1-git-send-email-minchan@kernel.org>
	<1357712474-27595-2-git-send-email-minchan@kernel.org>
	<20130116134155.18092f1a.akpm@linux-foundation.org>
	<20130117005314.GB18669@blaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Sonny Rao <sonnyrao@google.com>, Bryan Freed <bfreed@google.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

On Thu, 17 Jan 2013 09:53:14 +0900
Minchan Kim <minchan@kernel.org> wrote:

> Recently, Luigi reported there are lots of free swap space when
> OOM happens. It's easily reproduced on zram-over-swap, where
> many instance of memory hogs are running and laptop_mode is enabled.
> He said there was no problem when he disabled laptop_mode.
> 
> The problem when I investigate problem is following as.
> 
> Assumption for easy explanation: There are no page cache page in system
> because they all are already reclaimed.
> 
> 1. try_to_free_pages disable may_writepage when laptop_mode is enabled.
> 2. shrink_inactive_list isolates victim pages from inactive anon lru list.
> 3. shrink_page_list adds them to swapcache via add_to_swap but it doesn't
>    pageout because sc->may_writepage is 0 so the page is rotated back into
>    inactive anon lru list. The add_to_swap made the page Dirty by SetPageDirty
> 4. 3 couldn't reclaim any pages so do_try_to_free_pages increase priority and
>    retry reclaim with higher priority.
> 5. shrink_inactlive_list try to isolate victim pages from inactive anon lru list
>    but got failed because it try to isolate pages with ISOLATE_CLEAN mode but
>    inactive anon lru list is full of dirty pages by 3 so it just returns
>    without  any reclaim progress.
> 6. do_try_to_free_pages doesn't set may_write due to zero total_scanned.

s/may_write/may_writepage/

>    Because sc->nr_scanned is increased by shrink_page_list but we don't call
>    shrink_page_list in 5 due to short of isolated pages.

This is the bug, is it not?

In laptop mode, we still need to write out dirty swapcache at some
point.  An appropriate time to do this is when the scanning priority is
getting high.  But it seems that this ISOLATE_CLEAN->total_scanned
interaction is preventing that.

(An enhancement to laptop mode would be to opportunistically write out
dirty swapcache in or around laptop_mode_timer_fn()).

> Above loop is continued until OOM happens.
> The problem didn't happen before [1] was merged because old logic's isolatation
> in shrink_inactive_list was successful and tried to call shrink_page_list
> to pageout them but it still ends up failed to page out by may_writepage.
> But important point is that sc->nr_scanned was increased althoug we couldn't
> swap out them so do_try_to_free_pages could set may_writepages.
> So this patch need to go stable tree althoug it's a band-aid.
> Then, for latest linus tree, we should fix laptop_mode's fundamental
> problem.

Well.  Perhaps we can do that now.

> [1] f80c067[mm: zone_reclaim: make isolate_lru_page() filter-aware]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
