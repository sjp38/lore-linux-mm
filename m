Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 0E46B6B0078
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 16:05:44 -0400 (EDT)
Message-ID: <1341605099.14051.23.camel@zaphod.localdomain>
Subject: Re: [RFC][PATCH 03/26] mm, mpol: add MPOL_MF_LAZY ...
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Date: Fri, 06 Jul 2012 16:04:59 -0400
In-Reply-To: <4FF7147B.1050001@redhat.com>
References: <20120316144028.036474157@chello.nl>
	 <20120316144240.307470041@chello.nl> <20120323115025.GE16573@suse.de>
	 <4FF7147B.1050001@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 2012-07-06 at 12:38 -0400, Rik van Riel wrote:
> On 03/23/2012 07:50 AM, Mel Gorman wrote:
> > On Fri, Mar 16, 2012 at 03:40:31PM +0100, Peter Zijlstra wrote:
> >> From: Lee Schermerhorn<Lee.Schermerhorn@hp.com>
> >>
> >> This patch adds another mbind() flag to request "lazy migration".
> >> The flag, MPOL_MF_LAZY, modifies MPOL_MF_MOVE* such that the selected
> >> pages are simply unmapped from the calling task's page table ['_MOVE]
> >> or from all referencing page tables [_MOVE_ALL].  Anon pages will first
> >> be added to the swap [or migration?] cache, if necessary.  The pages
> >> will be migrated in the fault path on "first touch", if the policy
> >> dictates at that time.
> >>
> >> <SNIP>
> >>
> >> @@ -950,6 +950,98 @@ static int unmap_and_move_huge_page(new_
> >>   }
> >>
> >>   /*
> >> + * Lazy migration:  just unmap pages, moving anon pages to swap cache, if
> >> + * necessary.  Migration will occur, if policy dictates, when a task faults
> >> + * an unmapped page back into its page table--i.e., on "first touch" after
> >> + * unmapping.  Note that migrate-on-fault only migrates pages whose mapping
> >> + * [e.g., file system] supplies a migratepage op, so we skip pages that
> >> + * wouldn't migrate on fault.
> >> + *
> >> + * Pages are placed back on the lru whether or not they were successfully
> >> + * unmapped.  Like migrate_pages().
> >> + *
> >> + * Unline migrate_pages(), this function is only called in the context of
> >> + * a task that is unmapping it's own pages while holding its map semaphore
> >> + * for write.
> >> + */
> >> +int migrate_pages_unmap_only(struct list_head *pagelist)
> >
> > I'm not properly reviewing these patches at the moment but am taking a
> > quick look as I play some catch up on linux-mm.
> >
> > I think it's worth pointing out that this potentially will confuse
> > reclaim. Lets say a process is being migrated to another node and it
> > gets unmapped like this then some heuristics will change.
> >
> > 1. If the page was referenced prior to the unmapping then it should be
> >     activated if the page reached the end of the LRU due to the checks
> >     in page_check_references(). If the process has been unmapped for
> >     migrate-on-fault, the pages will instead be reclaimed.
> >
> > 2. The heuristic that applies pressure to slab pages if pages are mapped
> >     is changed. Prior to migrate-on-fault sc->nr_scanned is incremented
> >     for mapped pages to increase the number of slab pages scanned to
> >     avoid swapping. During migrate-on-fault, this pressure is relieved
> >
> > 3. zone_reclaim_mode in default mode will reclaim pages it would
> >     previously have skipped over. It potentially will call shrink_zone more
> >     for the local node than falling back to other nodes because it thinks
> >     most pages are unmapped. This could lead to some trashing.
> >
> > It may not even be a major problem but it's worth thinking about. If it
> > is a problem, it will be necessary to account for migrate-on-fault pages
> > similar to mapped pages during reclaim.
> 
> I can see other serious issues with this approach:
> 
> 4. Putting a lot of pages in the swap cache ends up allocating
>     swap space. This means this NUMA migration scheme will only
>     work on systems that have a substantial amount of memory
>     represented by swap space. This is highly unlikely on systems
>     with memory in the TB range. On smaller systems, it could drive
>     the system out of memory (to the OOM killer), by "filling up"
>     the overflow swap with migration pages instead.
> 5. In the long run, we want the ability to migrate transparent
>     huge pages as one unit.  The reason is simple, the performance
>     penalty for running on the wrong NUMA node (10-20%) is on the
>     same order of magnitude as the performance penalty for running
>     with 4kB pages instead of 2MB pages (5-15%).
> 
>     Breaking up large pages into small ones, and having khugepaged
>     reconstitute them on a random NUMA node later on, will negate
>     the performance benefits of both NUMA placement and THP.
> 
> In short, while this approach made sense when Lee first proposed
> it several years ago (with smaller memory systems, and before Linux
> had transparent huge pages), I do not believe it is an acceptable
> approach to NUMA migration any more.
> 
> We really want something like PROT_NONE or PTE_NUMA page table
> (and page directory) entries, so we can avoid filling up swap
> space with migration pages and have the possibility of migrating
> transparent huge pages in one piece at some point.
> 
> In other words, NAK to this patch
> 

When I originally posted the "migrate on fault" series, I posted a
separate series with a "migration cache" to avoid the use of swap space
for lazy migration: http://markmail.org/message/xgvvrnn2nk4nsn2e.

The migration cache was originally implemented by Marcello Tosatti for
the old memory hotplug project:
http://marc.info/?l=linux-mm&m=109779128211239&w=4.

The idea is that you don't need swap space for lazy migration, just an
"address_space" where you can park an anon VMA's pte's while they're
"unmapped" to cause migration faults.  Based on a suggestion from
Christoph Lameter, I had tried to hide the migration cache behind the
swap cache interface to minimize changes mainly in do_swap_page and
vmscan/reclaim.  It seemed to work, but the difference in reference
count semantics for the mig cache -- entry removed when last pte
migrated/mapped -- makes coordination with exit teardown, uh, tricky.

Regards,
Lee



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
