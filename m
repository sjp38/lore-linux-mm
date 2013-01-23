Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id B30406B0005
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 19:41:14 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id fb10so4398098pad.16
        for <linux-mm@kvack.org>; Tue, 22 Jan 2013 16:41:14 -0800 (PST)
Date: Wed, 23 Jan 2013 08:40:57 +0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [patch 3/3 v2]swap: add per-partition lock for swapfile
Message-ID: <20130123004057.GA17418@kernel.org>
References: <20130122023028.GC12293@kernel.org>
 <20130122150726.9d94c198.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130122150726.9d94c198.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, hughd@google.com, riel@redhat.com, minchan@kernel.org

On Tue, Jan 22, 2013 at 03:07:26PM -0800, Andrew Morton wrote:
> On Tue, 22 Jan 2013 10:30:28 +0800
> Shaohua Li <shli@kernel.org> wrote:
> 
> > swap_lock is heavily contended when I test swap to 3 fast SSD (even slightly
> > slower than swap to 2 such SSD). The main contention comes from
> > swap_info_get(). This patch tries to fix the gap with adding a new
> > per-partition lock.
> > 
> > global data like nr_swapfiles, total_swap_pages, least_priority and swap_list are
> > still protected by swap_lock.
> > 
> > nr_swap_pages is an atomic now, it can be changed without swap_lock. In theory,
> > it's possible get_swap_page() finds no swap pages but actually there are free
> > swap pages. But sounds not a big problem.
> > 
> > accessing partition specific data (like scan_swap_map and so on) is only
> > protected by swap_info_struct.lock.
> > 
> > Changing swap_info_struct.flags need hold swap_lock and swap_info_struct.lock,
> > because scan_scan_map() will check it. read the flags is ok with either the
> > locks hold.
> > 
> > If both swap_lock and swap_info_struct.lock must be hold, we always hold the
> > former first to avoid deadlock.
> > 
> > swap_entry_free() can change swap_list. To delete that code, we add a new
> > highest_priority_index. Whenever get_swap_page() is called, we check it. If
> > it's valid, we use it.
> > 
> > It's a pitty get_swap_page() still holds swap_lock(). But in practice,
> > swap_lock() isn't heavily contended in my test with this patch (or I can say
> > there are other much more heavier bottlenecks like TLB flush). And BTW, looks
> > get_swap_page() doesn't really need the lock. We never free swap_info[] and we
> > check SWAP_WRITEOK flag. The only risk without the lock is we could swapout to
> > some low priority swap, but we can quickly recover after several rounds of
> > swap, so sounds not a big deal to me. But I'd prefer to fix this if it's a real
> 
> I had to move a few things around due to changes in
> drivers/staging/zcache/.

Thanks.

> Do you have any performance testing results for this patch?

Sorry, I forgot writing it down. Last patch improved the swapout speed from
1.7G/s to 2G/s, this one further improved the speed to 2.3G/s, so around 15%
improvement. It's multi-process test, so TLB flush isn't the biggest bottleneck
before the patches.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
