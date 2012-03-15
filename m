Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id C8E7B6B0044
	for <linux-mm@kvack.org>; Thu, 15 Mar 2012 17:47:53 -0400 (EDT)
Received: by iajr24 with SMTP id r24so6169324iaj.14
        for <linux-mm@kvack.org>; Thu, 15 Mar 2012 14:47:52 -0700 (PDT)
Date: Thu, 15 Mar 2012 14:47:50 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, coredump: fail allocations when coredumping instead
 of oom killing
In-Reply-To: <20120315102011.GD22384@suse.de>
Message-ID: <alpine.DEB.2.00.1203151433380.14978@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1203141914160.24180@chino.kir.corp.google.com> <20120315102011.GD22384@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org

On Thu, 15 Mar 2012, Mel Gorman wrote:

> Where is all the memory going?  A brief look at elf_core_dump() looks
> fairly innocent.
> 
> o kmalloc for a header note
> o kmalloc potentially for a short header
> o dump_write() verifies access and calls f_op->write. I guess this could
>   be doing a lot of allocations underneath, is this where all the memory
>   is going?

Yup, this is the one.  We only currently see this when a memcg is at its 
limit and there are other threads that are trying to exit that are blocked 
on a coredumper that can no longer get memory.  dump_write() calling 
->write() (ext4 in this case) causes a livelock when 
add_to_page_cache_locked() tries to charge the soon-to-be-added pagecache 
to the coredumper's memcg that is oom and calls 
mem_cgroup_charge_common().  That allows the oom, but the oom killer will 
find the other threads that are exiting and choose to be a no-op to avoid 
needlessly killing threads.  The coredumper only has PF_DUMPCORE and not 
PF_EXITING so it doesn't get immediately killed.

So we have a decision to either immediately oom kill the coredumper or 
just fail its allocations and exit since this code does seem to have good 
error handling.  If RLIMIT_CORE is relatively small, it's not a problem to 
kill the coredumper and give it access to memory reserves.  We don't want 
to take that chance, however, since memcg allows all charges to be 
bypassed for threads that have been oom killed and have access to memory 
reserves with their TIF_MEMDIE bit set.  In the worst case, when 
RLIMIT_CORE is high or even unlimited, this could quickly cause a system 
oom condition and then we'd be stuck again because the oom killer finds an 
eligible thread with TIF_MEMDIE and all memory reserves have been 
depleted.

> Does the change mean that core dumps may fail where previously they would
> have succeeded even if the system churns a bit trying to write them out?

We haven't seen this in system-wide oom conditions but it shouldn't be 
unlike the memcg case where we completely livelock because all threads are 
waiting for the coredumper to exit and no memory is being freed.  Unless 
the hard limit is increased (or memory hotplugged in the system-wide oom 
condition), this consistely results in a livelock.  With the system-wide 
oom condition it's more likely that another thread can exit that is not 
going to block on waiting for the coredumper to exit and free memory, but 
it's not guaranteed and this patch fixes the memcg case as well.

> If so, should it be a tunable in like /proc/sys/kernel/core_mayoom that
> defaults to 1? Alternatively, would it be better if there was an option
> to synchronously write the core file and discard the page cache pages as
> the dump is written? It would be slower but it might stress the system less.
> 

I didn't think of adding a sysctl because all of its allocations are 
already GFP_KERNEL and are in a killable context where the oom killer 
already could decide to kill something; the problem is that it chooses not 
to do so because it sees threads that are PF_EXITING and defers, but in 
this case that will never happen because for them to fully exit and free 
its memory would require (perhaps a ton of) memory for the coredumper.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
