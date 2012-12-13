Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 009326B0044
	for <linux-mm@kvack.org>; Thu, 13 Dec 2012 13:22:41 -0500 (EST)
Message-ID: <50CA1C91.604@redhat.com>
Date: Thu, 13 Dec 2012 13:21:05 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 2/2]swap: add per-partition lock for swapfile
References: <20121210012510.GB18570@kernel.org>
In-Reply-To: <20121210012510.GB18570@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, minchan@kernel.org

On 12/09/2012 08:25 PM, Shaohua Li wrote:
> swap_lock is heavily contended when I test swap to 3 fast SSD (even slightly
> slower than swap to 2 such SSD). The main contention comes from
> swap_info_get(). This patch tries to fix the gap with adding a new
> per-partition lock.
>
> global data like nr_swapfiles, total_swap_pages, least_priority and swap_list are
> still protected by swap_lock.
>
> nr_swap_pages is an atomic now, it can be changed without swap_lock. In theory,
> it's possible get_swap_page() finds no swap pages but actually there are free
> swap pages. But sounds not a big problem.
>
> accessing partition specific data (like scan_swap_map and so on) is only
> protected by swap_info_struct.lock.
>
> Changing swap_info_struct.flags need hold swap_lock and swap_info_struct.lock,
> because scan_scan_map() will check it. read the flags is ok with either the
> locks hold.
>
> If both swap_lock and swap_info_struct.lock must be hold, we always hold the
> former first to avoid deadlock.
>
> swap_entry_free() can change swap_list. To delete that code, we add a new
> highest_priority_index. Whenever get_swap_page() is called, we check it. If
> it's valid, we use it.
>
> It's a pitty get_swap_page() still holds swap_lock(). But in practice,
> swap_lock() isn't heavily contended in my test with this patch (or I can say
> there are other much more heavier bottlenecks like TLB flush). And BTW, looks
> get_swap_page() doesn't really need the lock. We never free swap_info[] and we
> check SWAP_WRITEOK flag. The only risk without the lock is we could swapout to
> some low priority swap, but we can quickly recover after several rounds of
> swap, so sounds not a big deal to me. But I'd prefer to fix this if it's a real
> problem.
>
> Signed-off-by: Shaohua Li <shli@fusionio.com>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
