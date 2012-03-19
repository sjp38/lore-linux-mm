Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id A5E646B0112
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 17:52:47 -0400 (EDT)
Date: Mon, 19 Mar 2012 14:52:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm, coredump: fail allocations when coredumping instead
 of oom killing
Message-Id: <20120319145245.7efb0cd4.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1203151433380.14978@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1203141914160.24180@chino.kir.corp.google.com>
	<20120315102011.GD22384@suse.de>
	<alpine.DEB.2.00.1203151433380.14978@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org

On Thu, 15 Mar 2012 14:47:50 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Thu, 15 Mar 2012, Mel Gorman wrote:
> 
> > Where is all the memory going?  A brief look at elf_core_dump() looks
> > fairly innocent.
> > 
> > o kmalloc for a header note
> > o kmalloc potentially for a short header
> > o dump_write() verifies access and calls f_op->write. I guess this could
> >   be doing a lot of allocations underneath, is this where all the memory
> >   is going?
> 
> Yup, this is the one.  We only currently see this when a memcg is at its 
> limit and there are other threads that are trying to exit that are blocked 
> on a coredumper that can no longer get memory.  dump_write() calling 
> ->write() (ext4 in this case) causes a livelock when 
> add_to_page_cache_locked() tries to charge the soon-to-be-added pagecache 
> to the coredumper's memcg that is oom and calls 
> mem_cgroup_charge_common().  That allows the oom, but the oom killer will 
> find the other threads that are exiting and choose to be a no-op to avoid 
> needlessly killing threads.  The coredumper only has PF_DUMPCORE and not 
> PF_EXITING so it doesn't get immediately killed.

I don't understand the description of the livelock.  Does
add_to_page_cache_locked() succeed, or fail?  What does "allows the
oom" mean?

IOW, please have another attempt at explaining the livelock?

> So we have a decision to either immediately oom kill the coredumper or 
> just fail its allocations and exit since this code does seem to have good 
> error handling.  If RLIMIT_CORE is relatively small, it's not a problem to 
> kill the coredumper and give it access to memory reserves.  We don't want 
> to take that chance, however, since memcg allows all charges to be 
> bypassed for threads that have been oom killed and have access to memory 
> reserves with their TIF_MEMDIE bit set.  In the worst case, when 
> RLIMIT_CORE is high or even unlimited, this could quickly cause a system 
> oom condition and then we'd be stuck again because the oom killer finds an 
> eligible thread with TIF_MEMDIE and all memory reserves have been 
> depleted.

AFAICT, dumping core should only require the allocation of 2-3
unreclaimable pages at any one time.  That's if reclaim is working
properly.  So I'd have thought that permitting the core-dumper to
allocate those pages would cause everything to run to completion
nicely.

Relatedly, RLIMIT_CORE shouldn't affect this?  The core dumper only
really needs to pin a single pagecache page: the one into which it is
presently copying data.


My vague take on this patch is that we should instead try to let
everything run to completion, rather than failing allocations or
oom-killing anything.  But I don't yet understand the problem which the
patch is addressing...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
