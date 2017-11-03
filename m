Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 954C46B0038
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 03:46:38 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id f66so2067321oib.1
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 00:46:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t76sor1974745oie.63.2017.11.03.00.46.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 03 Nov 2017 00:46:32 -0700 (PDT)
Date: Fri, 3 Nov 2017 00:46:18 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/2] shmem: drop lru_add_drain_all from
 shmem_wait_for_pins
In-Reply-To: <20171102093613.3616-2-mhocko@kernel.org>
Message-ID: <alpine.LSU.2.11.1711030004260.4821@eggly.anvils>
References: <20171102093613.3616-1-mhocko@kernel.org> <20171102093613.3616-2-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, David Herrmann <dh.herrmann@gmail.com>, Hugh Dickins <hughd@google.com>

On Thu, 2 Nov 2017, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> syzkaller has reported the following lockdep splat
> ======================================================
> WARNING: possible circular locking dependency detected
> 4.13.0-next-20170911+ #19 Not tainted
> ------------------------------------------------------
> syz-executor5/6914 is trying to acquire lock:
>   (cpu_hotplug_lock.rw_sem){++++}, at: [<ffffffff818c1b3e>] get_online_cpus  include/linux/cpu.h:126 [inline]
>   (cpu_hotplug_lock.rw_sem){++++}, at: [<ffffffff818c1b3e>] lru_add_drain_all+0xe/0x20 mm/swap.c:729
> 
> but task is already holding lock:
>   (&sb->s_type->i_mutex_key#9){++++}, at: [<ffffffff818fbef7>] inode_lock include/linux/fs.h:712 [inline]
>   (&sb->s_type->i_mutex_key#9){++++}, at: [<ffffffff818fbef7>] shmem_add_seals+0x197/0x1060 mm/shmem.c:2768
> 
> more details [1] and dependencies explained [2]. The problem seems to be
> the usage of lru_add_drain_all from shmem_wait_for_pins. While the lock
> dependency is subtle as hell and we might want to make lru_add_drain_all
> less dependent on the hotplug locks the usage of lru_add_drain_all seems
> dubious here. The whole function cares only about radix tree tags, page
> count and page mapcount. None of those are touched from the draining
> context. So it doesn't make much sense to drain pcp caches. Moreover
> this looks like a wrong thing to do because it basically induces
> unpredictable latency to the call because draining is not for free
> (especially on larger machines with many cpus).
> 
> Let's simply drop the call to lru_add_drain_all to address both issues.
> 
> [1] http://lkml.kernel.org/r/089e0825eec8955c1f055c83d476@google.com
> [2] http://lkml.kernel.org/r/http://lkml.kernel.org/r/20171030151009.ip4k7nwan7muouca@hirez.programming.kicks-ass.net
> 
> Cc: David Herrmann <dh.herrmann@gmail.com>
> Cc: Hugh Dickins <hughd@google.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

NAK.  shmem_wait_for_pins() is waiting for temporary pins on the pages
to go away, and using lru_add_drain_all() in the usual way, to lower
the refcount of pages temporarily pinned in a pagevec somewhere.  Page
count is touched by draining pagevecs: I'm surprised to see you say
that it isn't - or have pagevec page references been eliminated by
a recent commit that I missed?

I hope your other patch, or another cpu hotplug locking fix, can deal
with this.  If not, I might be forced to spend some hours understanding
the story that lockdep is telling us there - you're probably way ahead
of me on that.  Maybe a separate inode lock initializer for shmem
inodes would offer a way out.

Hugh

> ---
>  mm/shmem.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/mm/shmem.c b/mm/shmem.c
> index d6947d21f66c..e784f311d4ed 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -2668,9 +2668,7 @@ static int shmem_wait_for_pins(struct address_space *mapping)
>  		if (!radix_tree_tagged(&mapping->page_tree, SHMEM_TAG_PINNED))
>  			break;
>  
> -		if (!scan)
> -			lru_add_drain_all();
> -		else if (schedule_timeout_killable((HZ << scan) / 200))
> +		if (scan && schedule_timeout_killable((HZ << scan) / 200))
>  			scan = LAST_SCAN;
>  
>  		start = 0;
> -- 
> 2.14.2
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
