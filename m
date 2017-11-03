Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id ECDE76B0038
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 04:24:21 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id p96so1165676wrb.12
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 01:24:21 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r12si4868026edb.481.2017.11.03.01.24.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Nov 2017 01:24:19 -0700 (PDT)
Date: Fri, 3 Nov 2017 09:24:17 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] shmem: drop lru_add_drain_all from
 shmem_wait_for_pins
Message-ID: <20171103082417.7rwns74txzzoyzyv@dhcp22.suse.cz>
References: <20171102093613.3616-1-mhocko@kernel.org>
 <20171102093613.3616-2-mhocko@kernel.org>
 <alpine.LSU.2.11.1711030004260.4821@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1711030004260.4821@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Herrmann <dh.herrmann@gmail.com>

On Fri 03-11-17 00:46:18, Hugh Dickins wrote:
> On Thu, 2 Nov 2017, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > syzkaller has reported the following lockdep splat
> > ======================================================
> > WARNING: possible circular locking dependency detected
> > 4.13.0-next-20170911+ #19 Not tainted
> > ------------------------------------------------------
> > syz-executor5/6914 is trying to acquire lock:
> >   (cpu_hotplug_lock.rw_sem){++++}, at: [<ffffffff818c1b3e>] get_online_cpus  include/linux/cpu.h:126 [inline]
> >   (cpu_hotplug_lock.rw_sem){++++}, at: [<ffffffff818c1b3e>] lru_add_drain_all+0xe/0x20 mm/swap.c:729
> > 
> > but task is already holding lock:
> >   (&sb->s_type->i_mutex_key#9){++++}, at: [<ffffffff818fbef7>] inode_lock include/linux/fs.h:712 [inline]
> >   (&sb->s_type->i_mutex_key#9){++++}, at: [<ffffffff818fbef7>] shmem_add_seals+0x197/0x1060 mm/shmem.c:2768
> > 
> > more details [1] and dependencies explained [2]. The problem seems to be
> > the usage of lru_add_drain_all from shmem_wait_for_pins. While the lock
> > dependency is subtle as hell and we might want to make lru_add_drain_all
> > less dependent on the hotplug locks the usage of lru_add_drain_all seems
> > dubious here. The whole function cares only about radix tree tags, page
> > count and page mapcount. None of those are touched from the draining
> > context. So it doesn't make much sense to drain pcp caches. Moreover
> > this looks like a wrong thing to do because it basically induces
> > unpredictable latency to the call because draining is not for free
> > (especially on larger machines with many cpus).
> > 
> > Let's simply drop the call to lru_add_drain_all to address both issues.
> > 
> > [1] http://lkml.kernel.org/r/089e0825eec8955c1f055c83d476@google.com
> > [2] http://lkml.kernel.org/r/http://lkml.kernel.org/r/20171030151009.ip4k7nwan7muouca@hirez.programming.kicks-ass.net
> > 
> > Cc: David Herrmann <dh.herrmann@gmail.com>
> > Cc: Hugh Dickins <hughd@google.com>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> NAK.  shmem_wait_for_pins() is waiting for temporary pins on the pages
> to go away, and using lru_add_drain_all() in the usual way, to lower
> the refcount of pages temporarily pinned in a pagevec somewhere.  Page
> count is touched by draining pagevecs: I'm surprised to see you say
> that it isn't - or have pagevec page references been eliminated by
> a recent commit that I missed?

I must be missing something here. __pagevec_lru_add_fn merely about
moving the page into the appropriate LRU list, pagevec_move_tail only
rotates, lru_deactivate_file_fn moves from active to inactive LRUs,
lru_lazyfree_fn moves from anon to file LRUs and activate_page_drain
just moves to the active list. None of those operations touch the page
count AFAICS. So I would agree that some pages might be pinned outside
of the LRU (lru_add_pvec) and thus unreclaimable but does this really
matter. Or what else I am missing?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
