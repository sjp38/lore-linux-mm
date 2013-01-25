Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 74ED36B0002
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 03:07:53 -0500 (EST)
Received: by mail-ia0-f178.google.com with SMTP id y26so155321iab.37
        for <linux-mm@kvack.org>; Fri, 25 Jan 2013 00:07:52 -0800 (PST)
Message-ID: <1359101268.16101.3.camel@kernel>
Subject: Re: [patch 3/3 v2]swap: add per-partition lock for swapfile
From: Simon Jeons <simon.jeons@gmail.com>
Date: Fri, 25 Jan 2013 02:07:48 -0600
In-Reply-To: <20130122150726.9d94c198.akpm@linux-foundation.org>
References: <20130122023028.GC12293@kernel.org>
	 <20130122150726.9d94c198.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shaohua Li <shli@kernel.org>, linux-mm@kvack.org, hughd@google.com, riel@redhat.com, minchan@kernel.org

On Tue, 2013-01-22 at 15:07 -0800, Andrew Morton wrote:
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

Hi Andrew,

I see you have already merge the patch, several questions, forgive me if
some are silly.

> > nr_swap_pages is an atomic now, it can be changed without swap_lock. In theory,
> > it's possible get_swap_page() finds no swap pages but actually there are free
> > swap pages. But sounds not a big problem.

When can this happen?

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

Why check it when get_swap_page() is called instead of other places?

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
> 
> Do you have any performance testing results for this patch?
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
