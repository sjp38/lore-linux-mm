Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 644E06B0044
	for <linux-mm@kvack.org>; Thu, 15 Mar 2012 06:20:16 -0400 (EDT)
Date: Thu, 15 Mar 2012 10:20:11 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch] mm, coredump: fail allocations when coredumping instead
 of oom killing
Message-ID: <20120315102011.GD22384@suse.de>
References: <alpine.DEB.2.00.1203141914160.24180@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1203141914160.24180@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org

On Wed, Mar 14, 2012 at 07:15:10PM -0700, David Rientjes wrote:
> The size of coredump files is limited by RLIMIT_CORE, however, allocating
> large amounts of memory results in three negative consequences:
> 
>  - the coredumping process may be chosen for oom kill and quickly deplete
>    all memory reserves in oom conditions preventing further progress from
>    being made or tasks from exiting,
> 

Where is all the memory going?  A brief look at elf_core_dump() looks
fairly innocent.

o kmalloc for a header note
o kmalloc potentially for a short header
o dump_write() verifies access and calls f_op->write. I guess this could
  be doing a lot of allocations underneath, is this where all the memory
  is going?
o get_dump_page() underneath is pinning pages but it should not be
  allocating for the zero page and instead leaving a hole in the dump
  file. The pages it does allocate should be freed quickly but I
  recognise that it could cause a lot of paging activity if the
  information has to be retrieved from disk

I recognise that core dumping is potentially very heavy on the system so
is bringing all the data in from backing storage causing the problem?

>  - the coredumping process may cause other processes to be oom killed
>    without fault of their own as the result of a SIGSEGV, for example, in
>    the coredumping process, or
> 

Which is related to point 1

>  - the coredumping process may result in a livelock while writing to the
>    dump file if it needs memory to allocate while other threads are in
>    the exit path waiting on the coredumper to complete.
> 

I can see how this could happen within the filesystem doing block allocations
and the like. It looks from exec.c that the file is not opened O_DIRECT
so is it the case that the page cache backing the core file until the IO
is complete is really what is pushing the system OOM?

> This is fixed by implying __GFP_NORETRY in the page allocator for
> coredumping processes when reclaim has failed so the allocations fail and
> the process continues to exit.
> 

>From a page allocator perspective, this change looks fine but I'm concerned
about the functional change.

Does the change mean that core dumps may fail where previously they would
have succeeded even if the system churns a bit trying to write them out?
If so, should it be a tunable in like /proc/sys/kernel/core_mayoom that
defaults to 1? Alternatively, would it be better if there was an option
to synchronously write the core file and discard the page cache pages as
the dump is written? It would be slower but it might stress the system less.

> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/page_alloc.c |    4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2306,6 +2306,10 @@ rebalance:
>  		if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY)) {
>  			if (oom_killer_disabled)
>  				goto nopage;
> +			/* Coredumps can quickly deplete all memory reserves */
> +			if ((current->flags & PF_DUMPCORE) &&
> +			    !(gfp_mask & __GFP_NOFAIL))
> +				goto nopage;
>  			page = __alloc_pages_may_oom(gfp_mask, order,
>  					zonelist, high_zoneidx,
>  					nodemask, preferred_zone,

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
