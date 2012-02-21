Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 585976B0083
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 03:40:29 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id DED8A3EE0BB
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 17:40:27 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C6D0845DE4F
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 17:40:27 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A1F0545DE4E
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 17:40:27 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D4D51DB803E
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 17:40:27 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3ACA31DB802F
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 17:40:27 +0900 (JST)
Date: Tue, 21 Feb 2012 17:38:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 5/10] mm/memcg: introduce page_relock_lruvec
Message-Id: <20120221173859.f57d00f5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1202201532170.23274@eggly.anvils>
References: <alpine.LSU.2.00.1202201518560.23274@eggly.anvils>
	<alpine.LSU.2.00.1202201532170.23274@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 20 Feb 2012 15:33:20 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> Delete the mem_cgroup_page_lruvec() which we just added, replacing
> it and nearby spin_lock_irq or spin_lock_irqsave of zone->lru_lock:
> in most places by page_lock_lruvec() or page_relock_lruvec() (the
> former being a simple case of the latter) or just by lock_lruvec().
> unlock_lruvec() does the spin_unlock_irqrestore for them all.
> 

Wow..removed ;)

> page_relock_lruvec() is born from that "pagezone" pattern in swap.c
> and vmscan.c, where we loop over an array of pages, switching lock
> whenever the zone changes: bearing in mind that if we were to refine
> that lock to per-memcg per-zone, then we would have to switch whenever
> the memcg changes too.
> 
> page_relock_lruvec(page, &lruvec) locates the right lruvec for page,
> unlocks the old lruvec if different (and not NULL), locks the new,
> and updates lruvec on return: so that we shall have just one routine
> to locate and lock the lruvec, whereas originally it got re-evaluated
> at different stages.  But I don't yet know how to satisfy sparse(1).
> 

Ok, I like page_relock_lruvec().



> There are some loops where we never change zone, and a non-memcg kernel
> would not change memcg: use no-op mem_cgroup_page_relock_lruvec() there.
> 
> In compaction's isolate_migratepages(), although we do know the zone,
> we don't know the lruvec in advance: allow for taking the lock later,
> and reorganize its cond_resched() lock-dropping accordingly.
> 
> page_relock_lruvec() (and its wrappers) is actually an _irqsave operation:
> there are a few cases in swap.c where it may be needed at interrupt time
> (to free or to rotate a page on I/O completion).  Ideally(?) we would use
> straightforward _irq disabling elsewhere, but the variants get confusing,
> and page_relock_lruvec() will itself grow more complicated in subsequent
> patches: so keep it simple for now with just the one irqsaver everywhere.
> 
> Passing an irqflags argument/pointer down several levels looks messy
> too, and I'm reluctant to add any more to the page reclaim stack: so
> save the irqflags alongside the lru_lock and restore them from there.
> 
> It's a little sad now to be including mm.h in swap.h to get page_zone();
> but I think that swap.h (despite its name) is the right place for these
> lru functions, and without those inlines the optimizer cannot do so
> well in the !MEM_RES_CTLR case.
> 
> (Is this an appropriate place to confess? that even at the end of the
> series, we're left with a small bug in putback_inactive_pages(), one
> that I've not yet decided is worth fixing: reclaim_stat there is from
> the lruvec on entry, but we might update stats after dropping its lock.
> And do zone->pages_scanned and zone->all_unreclaimable need locking?
> page_alloc.c thinks zone->lock, vmscan.c thought zone->lru_lock,
> and that weakens if we now split lru_lock by memcg.)
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

No perforamce impact by replacing spin_lock_irq()/spin_unlock_irq() to
spin_lock_irqsave() and spin_unlock_irqrestore() ?

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
