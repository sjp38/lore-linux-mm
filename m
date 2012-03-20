Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id CD2986B011F
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 20:46:50 -0400 (EDT)
Received: by dadv6 with SMTP id v6so13346383dad.14
        for <linux-mm@kvack.org>; Mon, 19 Mar 2012 17:46:49 -0700 (PDT)
Date: Mon, 19 Mar 2012 17:46:47 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, coredump: fail allocations when coredumping instead
 of oom killing
In-Reply-To: <20120319145245.7efb0cd4.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1203191723470.3609@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1203141914160.24180@chino.kir.corp.google.com> <20120315102011.GD22384@suse.de> <alpine.DEB.2.00.1203151433380.14978@chino.kir.corp.google.com> <20120319145245.7efb0cd4.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org

On Mon, 19 Mar 2012, Andrew Morton wrote:

> > Yup, this is the one.  We only currently see this when a memcg is at its 
> > limit and there are other threads that are trying to exit that are blocked 
> > on a coredumper that can no longer get memory.  dump_write() calling 
> > ->write() (ext4 in this case) causes a livelock when 
> > add_to_page_cache_locked() tries to charge the soon-to-be-added pagecache 
> > to the coredumper's memcg that is oom and calls 
> > mem_cgroup_charge_common().  That allows the oom, but the oom killer will 
> > find the other threads that are exiting and choose to be a no-op to avoid 
> > needlessly killing threads.  The coredumper only has PF_DUMPCORE and not 
> > PF_EXITING so it doesn't get immediately killed.
> 
> I don't understand the description of the livelock.  Does
> add_to_page_cache_locked() succeed, or fail?  What does "allows the
> oom" mean?
> 

Sorry if it wasn't clear.  The coredumper calling into 
add_to_page_cache_locked() calls the oom killer because the memcg is oom 
(and would call the global oom killer if the entire system were oom).  The 
oom killer, both memcg and global, doesn't do anything because it sees 
eligible threads with PF_EXITING set.  This logic has existed for several 
years to avoid needlessly oom killing additional threads when others are 
already in the process of exiting and freeing their memory.  Those 
PF_EXITING threads, however, are blocked on the coredumper to exit in 
exit_mm(), so they'll never actually exit.  Thus, the coredumper must make 
forward progress for anything to actually exit and the oom killer is 
useless.

In this condition, there are a few options:

 - give the coredumper access to memory reserves and allow it to allocate,
   essentially oom killing it,

 - fail coredumper memory allocations because of the oom condition and 
   allow the threads blocked on it to exit, or

 - implement an oom killer timeout that would kill additional threads if 
   we repeatedly call into it without making forward progress over a small 
   period of time.

The first and last, in my opinion, are non-starters because it allows a 
complete depletion of memory reserves if the coredumper is chosen and then 
nothing is guaranteed to be able to ever exit.  This patch implements the 
middle option where we do our best effort to allow the coredump to be 
successful (we even try direct reclaim before failing) but choose to fail 
before calling into the oom killer and causing a livelock.

> AFAICT, dumping core should only require the allocation of 2-3
> unreclaimable pages at any one time.  That's if reclaim is working
> properly.  So I'd have thought that permitting the core-dumper to
> allocate those pages would cause everything to run to completion
> nicely.
> 

If there's nothing to reclaim (more obvious when running in a memcg) then 
we prohibit the allocation and livelock in the presence of PF_EXITING 
threads that are waiting on the coredump; there's nothing that allows 
those allocations in the kernel to succeed currently.  If we can guarantee 
that the call to ->write() allocates 2-3 pages at most then we could 
perhaps get away with doing something like

	if (current->flags & PF_DUMPCORE) {
		set_thread_flag(TIF_MEMDIE);
		return 0;
	}

in the oom killer like we allow for fatal_signal_pending() right now.  I 
chose to be more conservative, however, because the amount of memory it 
allocates is filesystem dependent and may deplete all memory reserves.

> Relatedly, RLIMIT_CORE shouldn't affect this?  The core dumper only
> really needs to pin a single pagecache page: the one into which it is
> presently copying data.
> 

It's filesystem dependent, the VM doesn't safeguard against a livelock of 
the memcg and the system without this patch.  But even with one page the 
vulnerability still exists.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
