Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 8CAF56B00F6
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 19:07:05 -0400 (EDT)
Date: Thu, 22 Mar 2012 16:07:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm, coredump: fail allocations when coredumping instead
 of oom killing
Message-Id: <20120322160703.dbcf52a8.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1203191723470.3609@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1203141914160.24180@chino.kir.corp.google.com>
	<20120315102011.GD22384@suse.de>
	<alpine.DEB.2.00.1203151433380.14978@chino.kir.corp.google.com>
	<20120319145245.7efb0cd4.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1203191723470.3609@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org

On Mon, 19 Mar 2012 17:46:47 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Mon, 19 Mar 2012, Andrew Morton wrote:
> 
> > > Yup, this is the one.  We only currently see this when a memcg is at its 
> > > limit and there are other threads that are trying to exit that are blocked 
> > > on a coredumper that can no longer get memory.  dump_write() calling 
> > > ->write() (ext4 in this case) causes a livelock when 
> > > add_to_page_cache_locked() tries to charge the soon-to-be-added pagecache 
> > > to the coredumper's memcg that is oom and calls 
> > > mem_cgroup_charge_common().  That allows the oom, but the oom killer will 
> > > find the other threads that are exiting and choose to be a no-op to avoid 
> > > needlessly killing threads.  The coredumper only has PF_DUMPCORE and not 
> > > PF_EXITING so it doesn't get immediately killed.
> > 
> > I don't understand the description of the livelock.  Does
> > add_to_page_cache_locked() succeed, or fail?  What does "allows the
> > oom" mean?
> > 
> 
> Sorry if it wasn't clear.  The coredumper calling into 
> add_to_page_cache_locked() calls the oom killer because the memcg is oom 
> (and would call the global oom killer if the entire system were oom).  The 
> oom killer, both memcg and global, doesn't do anything because it sees 
> eligible threads with PF_EXITING set.  This logic has existed for several 
> years to avoid needlessly oom killing additional threads when others are 
> already in the process of exiting and freeing their memory.  Those 
> PF_EXITING threads, however, are blocked on the coredumper to exit in 
> exit_mm(), so they'll never actually exit.  Thus, the coredumper must make 
> forward progress for anything to actually exit and the oom killer is 
> useless.
> 
> In this condition, there are a few options:
> 
>  - give the coredumper access to memory reserves and allow it to allocate,
>    essentially oom killing it,
> 
>  - fail coredumper memory allocations because of the oom condition and 
>    allow the threads blocked on it to exit, or
> 
>  - implement an oom killer timeout that would kill additional threads if 
>    we repeatedly call into it without making forward progress over a small 
>    period of time.
> 
> The first and last, in my opinion, are non-starters because it allows a 
> complete depletion of memory reserves if the coredumper is chosen and then 
> nothing is guaranteed to be able to ever exit.

Why does option 1 lead to reserve exhaustion?  If we have a zillion
simultaneous core dumps?

>  This patch implements the 
> middle option where we do our best effort to allow the coredump to be 
> successful (we even try direct reclaim before failing) but choose to fail 
> before calling into the oom killer and causing a livelock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
