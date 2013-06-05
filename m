Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 6F5056B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 08:34:05 -0400 (EDT)
Date: Wed, 5 Jun 2013 13:34:00 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Handling NUMA page migration
Message-ID: <20130605123400.GA1936@suse.de>
References: <201306040922.10235.frank.mehnert@oracle.com>
 <20130604115807.GF3672@sgi.com>
 <20130605101019.GA18242@suse.de>
 <201306051235.35678.frank.mehnert@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <201306051235.35678.frank.mehnert@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frank Mehnert <frank.mehnert@oracle.com>
Cc: Robin Holt <holt@sgi.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>

On Wed, Jun 05, 2013 at 12:35:35PM +0200, Frank Mehnert wrote:
> On Wednesday 05 June 2013 12:10:19 Mel Gorman wrote:
> > On Tue, Jun 04, 2013 at 06:58:07AM -0500, Robin Holt wrote:
> > > > B) 1. allocate memory with alloc_pages()
> > > > 
> > > >    2. SetPageReserved()
> > > >    3. vm_mmap() to allocate a userspace mapping
> > > >    4. vm_insert_page()
> > > >    5. vm_flags |= (VM_DONTEXPAND | VM_DONTDUMP)
> > > >    
> > > >       (resulting flags are VM_MIXEDMAP | VM_DONTDUMP | VM_DONTEXPAND |
> > > >       0xff)
> > > > 
> > > > At least the memory allocated like B) is affected by automatic NUMA
> > > > page migration. I'm not sure about A).
> > > > 
> > > > 1. How can I prevent automatic NUMA page migration on this memory?
> > > > 2. Can NUMA page migration also be handled on such kind of memory
> > > > without
> > > > 
> > > >    preventing migration?
> > 
> > Page migration does not expect a PageReserved && PageLRU page. The only
> > reserved check that is made by migration is for the zero page and that
> > happens in the syscall path for move_pages() which is not used by either
> > compaction or automatic balancing.
> > 
> > At some point you must have a driver that is setting PageReserved on
> > anonymous pages that is later encountered by automatic numa balancing
> > during a NUMA hinting fault.  I expect this is an out-of-tree driver or
> > a custom kernel of some sort. Memory should be pinned by elevating the
> > reference count of the page, not setting PageReserved.
> 
> Yes, this is ring 0 code from VirtualBox. The VBox ring 0 driver does the
> steps which are shown above. Setting PageReserved is not only for pinning
> but also for fork() protection.

Offhand I don't see what setting PageReserved on an LRU page has to do
with fork() protection. If the VMA should not be copied by fork then use
MADV_DONTFORK.

> I've tried to do get_page() as well but
> it did not help preventing the migration during NUMA balancing.
> 

I think you mean elevating the page count did not prevent the unmapping. The
elevated count should have prevented the actual migration but would not
prevent the unmapping.

> As I wrote, the code for allocating + mapping the memory assumes that
> the memory is finally pinned and will be never unmapped. That assumption
> might be wrong or wrong under certain/rare conditions. I would like to
> know these conditions and how we can prevent them from happening or how
> we can handle them correctly.

Memory compaction for THP allocations will break that assumption as
compaction ignores VM_LOCKED. I strongly suspect that if you did something
like move a process into a cpuset bound to another node that it would
also break. If a process like numad is running then it would probably
break virtualbox as well as it triggers migration from userspace. It is
a fragile assumption to make.

> > It's not particularly clear how you avoid hitting the same bug due to THP
> > and memory compaction to be honest but maybe your setup hits a steady
> > state that simply never hit the problem or it happens rarely and it was
> > not identified.
> 
> I'm currently using the stock Ubuntu 13.04 generic kernel (3.8.0-23),

and an out-of-tree driver which is what is hitting the problem.

A few of your options in order of estimated time to completion are;

1. Disable numa balancing within your driver or fail to start if it's
   running
2. Create a patch that adds a new NUMA_PTE_SCAN_IGNORE value for
   mm->first_nid (see includ/linux.mm_types.h). In sched/core/fair.c,
   add a check that first_nid == NUMA_PTE_SCAN_IGNORE should be ignored.
   Document that only virtualbox needs this and set it within your
   driver. This will not fix the compaction cases or numad using cpusets
   to migrate your processes though
3. When the driver affects a region, set mm->numa_next_reset and
   mm->numa_next_scan to large values to prevent the pages being unmapped.
   This would be very fragile, could break again in the future and is ugly
4. Add a check in change_pte_range() for the !prot_numa case to check
   PageReserved. This will prevent automatic numa balancing unmapping the
   page. Document that only virtualbox requires this.
5. Add a check in change_pte_range() for an elevated page count.
   Document that there is no point unmapping a page for a NUMA hinting
   fault that will only fail migration later anyway which is true albeit of
   marginal benefit. Then, in the vbox driver, elevate the page count, do
   away with the PageReserved trick, use MADV_DONTFORK to prevent copying
   at fork time.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
