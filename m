Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 063B76B002B
	for <linux-mm@kvack.org>; Fri,  9 Nov 2012 00:15:26 -0500 (EST)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <svaidy@linux.vnet.ibm.com>;
	Fri, 9 Nov 2012 10:45:23 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qA95FH2v55967932
	for <linux-mm@kvack.org>; Fri, 9 Nov 2012 10:45:17 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qA95FGuo000717
	for <linux-mm@kvack.org>; Fri, 9 Nov 2012 16:15:17 +1100
Date: Fri, 9 Nov 2012 10:44:16 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 0/8][Sorted-buddy] mm: Linux VM Infrastructure to
 support Memory Power Management
Message-ID: <20121109051247.GA499@dirshya.in.ibm.com>
Reply-To: svaidy@linux.vnet.ibm.com
References: <20121106195026.6941.24662.stgit@srivatsabhat.in.ibm.com>
 <20121108180257.GC8218@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20121108180257.GC8218@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, akpm@linux-foundation.org, mjg59@srcf.ucam.org, paulmck@linux.vnet.ibm.com, dave@linux.vnet.ibm.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, arjan@linux.intel.com, kmpark@infradead.org, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, amit.kachhap@linaro.org, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

* Mel Gorman <mgorman@suse.de> [2012-11-08 18:02:57]:

> On Wed, Nov 07, 2012 at 01:22:13AM +0530, Srivatsa S. Bhat wrote:
> > ------------------------------------------------------------

Hi Mel,

Thanks for detailed review and comments.  The goal of this patch
series is to brainstorm on ideas that enable Linux VM to record and
exploit memory region boundaries.

The first approach that we had last year (hierarchy) has more runtime
overhead.  This approach of sorted-buddy was one of the alternative
discussed earlier and we are trying to find out if simple requirements
of biasing memory allocations can be achieved with this approach.

Smart reclaim based on this approach is a key piece we still need to
design.  Ideas from compaction will certainly help.

> > Today memory subsystems are offer a wide range of capabilities for managing
> > memory power consumption. As a quick example, if a block of memory is not
> > referenced for a threshold amount of time, the memory controller can decide to
> > put that chunk into a low-power content-preserving state. And the next
> > reference to that memory chunk would bring it back to full power for read/write.
> > With this capability in place, it becomes important for the OS to understand
> > the boundaries of such power-manageable chunks of memory and to ensure that
> > references are consolidated to a minimum number of such memory power management
> > domains.
> > 
> 
> How much power is saved?

On embedded platform the savings could be around 5% as discussed in
the earlier thread: http://article.gmane.org/gmane.linux.kernel.mm/65935

On larger servers with large amounts of memory the savings could be
more.  We do not yet have all the pieces together to evaluate.

> > ACPI 5.0 has introduced MPST tables (Memory Power State Tables) [5] so that
> > the firmware can expose information regarding the boundaries of such memory
> > power management domains to the OS in a standard way.
> > 
> 
> I'm not familiar with the ACPI spec but is there support for parsing of
> MPST and interpreting the associated ACPI events? For example, if ACPI
> fires an event indicating that a memory power node is to enter a low
> state then presumably the OS should actively migrate pages away -- even
> if it's going into a state where the contents are still refreshed
> as exiting that state could take a long time.
> 
> I did not look closely at the patchset at all because it looked like the
> actual support to use it and measure the benefit is missing.

Correct.  The platform interface part is not included in this patch
set mainly because there is not much design required there.  Each
platform can have code to collect the memory region boundaries from
BIOS/firmware and load it into the Linux VM.  The goal of this patch
is to brainstorm on the idea of hos core VM should used the region
information.
 
> > How can Linux VM help memory power savings?
> > 
> > o Consolidate memory allocations and/or references such that they are
> > not spread across the entire memory address space.  Basically area of memory
> > that is not being referenced, can reside in low power state.
> > 
> 
> Which the series does not appear to do.

Correct.  We need to design the correct reclaim strategy for this to
work.  However having buddy list sorted by region address could get us
one step closer to shaping the allocations.

> > o Support targeted memory reclaim, where certain areas of memory that can be
> > easily freed can be offlined, allowing those areas of memory to be put into
> > lower power states.
> > 
> 
> Which the series does not appear to do judging from this;
> 
>   include/linux/mm.h     |   38 +++++++
>   include/linux/mmzone.h |   52 +++++++++
>   mm/compaction.c        |    8 +
>   mm/page_alloc.c        |  263 ++++++++++++++++++++++++++++++++++++++++++++----
>   mm/vmstat.c            |   59 ++++++++++-
> 
> This does not appear to be doing anything with reclaim and not enough with
> compaction to indicate that the series actively manages memory placement
> in response to ACPI events.

Correct.  Evaluating different ideas for reclaim will be next step
before getting into the platform interface parts.

> Further in section 5.2.21.4 the spec says that power node regions can
> overlap (but are not hierarchal for some reason) but have no gaps yet the
> structure you use to represent is assumes there can be gaps and there are
> no overlaps. Again, this is just glancing at the spec and a quick skim of
> the patches so maybe I missed something that explains why this structure
> is suitable.

This patch is roughly based on the idea that ACPI MPST will give us
memory region boundaries.  It is not designed to implement all options
defined in the spec.  We have taken a general case of regions do not
overlap while memory addresses itself can be discontinuous.

> It seems to me that superficially the VM implementation for the support
> would have
> 
> a) Involved a tree that managed the overlapping regions (even if it's
>    not hierarchal it feels more sensible) and picked the highest-power-state
>    common denominator in the tree. This would only be allocated if support
>    for MPST is available.
> b) Leave memory allocations and reclaim as they are in the active state.
> c) Use a "sticky" migrate list MIGRATE_LOWPOWER for regions that are in lower
>    power but still usable with a latency penalty. This might be a single
>    migrate type but could also be a parallel set of free_area called
>    free_area_lowpower that is only used when free_area is depleted and in
>    the very slow path of the allocator.
> d) Use memory hot-remove for power states where the refresh rates were
>    not constant
> 
> and only did anything expensive in response to an ACPI event -- none of
> the fast paths should be touched.
> 
> When transitioning to the low power state, memory should be migrated in
> a vaguely similar fashion to what CMA does. For low-power, migration
> failure is acceptable. If contents are not preserved, ACPI needs to know
> if the migration failed because it cannot enter that power state.
> 
> For any of this to be worthwhile, low power states would need to be achieved
> for long periods of time because that migration is not free.

In this patch series we are assuming the simple case of hardware
managing the actual power states and OS facilitates them by keeping
the allocations in less number of memory regions.  As we keep
allocations and references low to a regions, it becomes case (c)
above.  We are addressing only a small subset of the above list.

> > Memory Regions:
> > ---------------
> > 
> > "Memory Regions" is a way of capturing the boundaries of power-managable
> > chunks of memory, within the MM subsystem.
> > 
> > Short description of the "Sorted-buddy" design:
> > -----------------------------------------------
> > 
> > In this design, the memory region boundaries are captured in a parallel
> > data-structure instead of fitting regions between nodes and zones in the
> > hierarchy. Further, the buddy allocator is altered, such that we maintain the
> > zones' freelists in region-sorted-order and thus do page allocation in the
> > order of increasing memory regions.
> 
> Implying that this sorting has to happen in the either the alloc or free
> fast path.

Yes, in the free path. This optimization can be actually be delayed in
the free fast path and completely avoided if our memory is full and we
are doing direct reclaim during allocations.

> > (The freelists need not be fully
> > address-sorted, they just need to be region-sorted. Patch 6 explains this
> > in more detail).
> > 
> > The idea is to do page allocation in increasing order of memory regions
> > (within a zone) and perform page reclaim in the reverse order, as illustrated
> > below.
> > 
> > ---------------------------- Increasing region number---------------------->
> > 
> > Direction of allocation--->                         <---Direction of reclaim
> > 
> 
> Compaction will work against this because it uses a PFN walker to isolate
> free pages and will ignore memory regions. If pageblocks were used, it
> could take that into account at least.
> 
> > The sorting logic (to maintain freelist pageblocks in region-sorted-order)
> > lies in the page-free path and not the page-allocation path and hence the
> > critical page allocation paths remain fast.
> 
> Page free can be a critical path for application performance as well.
> Think network buffer heavy alloc and freeing of buffers.
> 
> However, migratetype information is already looked up for THP so ideally
> power awareness would piggyback on it.
> 
> > Moreover, the heart of the page
> > allocation algorithm itself remains largely unchanged, and the region-related
> > data-structures are optimized to avoid unnecessary updates during the
> > page-allocator's runtime.
> > 
> > Advantages of this design:
> > --------------------------
> > 1. No zone-fragmentation (IOW, we don't create more zones than necessary) and
> >    hence we avoid its associated problems (like too many zones, extra page
> >    reclaim threads, question of choosing watermarks etc).
> >    [This is an advantage over the "Hierarchy" design]
> > 
> > 2. Performance overhead is expected to be low: Since we retain the simplicity
> >    of the algorithm in the page allocation path, page allocation can
> >    potentially remain as fast as it would be without memory regions. The
> >    overhead is pushed to the page-freeing paths which are not that critical.
> > 
> > 
> > Results:
> > =======
> > 
> > Test setup:
> > -----------
> > This patchset applies cleanly on top of 3.7-rc3.
> > 
> > x86 dual-socket quad core HT-enabled machine booted with mem=8G
> > Memory region size = 512 MB
> > 
> > Functional testing:
> > -------------------
> > 
> > Ran pagetest, a simple C program that allocates and touches a required number
> > of pages.
> > 
> > Below is the statistics from the regions within ZONE_NORMAL, at various sizes
> > of allocations from pagetest.
> > 
> > 	     Present pages   |	Free pages at various allocations        |
> > 			     |  start	|  512 MB  |  1024 MB | 2048 MB  |
> >   Region 0      16	     |   0      |    0     |     0    |    0     |
> >   Region 1      131072       |  87219   |  8066    |   7892   |  7387    |
> >   Region 2      131072       | 131072   |  79036   |     0    |    0     |
> >   Region 3      131072       | 131072   | 131072   |   79061  |    0     |
> >   Region 4      131072       | 131072   | 131072   |  131072  |    0     |
> >   Region 5      131072       | 131072   | 131072   |  131072  |  79051   |
> >   Region 6      131072       | 131072   | 131072   |  131072  |  131072  |
> >   Region 7      131072       | 131072   | 131072   |  131072  |  131072  |
> >   Region 8      131056       | 105475   | 105472   |  105472  |  105472  |
> > 
> > This shows that page allocation occurs in the order of increasing region
> > numbers, as intended in this design.
> > 
> > Performance impact:
> > -------------------
> > 
> > Kernbench results didn't show much of a difference between the performance
> > of vanilla 3.7-rc3 and this patchset.
> > 
> > 
> > Todos:
> > =====
> > 
> > 1. Memory-region aware page-reclamation:
> > ----------------------------------------
> > 
> > We would like to do page reclaim in the reverse order of page allocation
> > within a zone, ie., in the order of decreasing region numbers.
> > To achieve that, while scanning lru pages to reclaim, we could potentially
> > look for pages belonging to higher regions (considering region boundaries)
> > or perhaps simply prefer pages of higher pfns (and skip lower pfns) as
> > reclaim candidates.
> > 
> 
> This would disrupting LRU ordering and if those pages were recently
> allocated and you force a situation where swap has to be used then any
> saving in low memory will be lost by having to access the disk instead.
> 
> > 2. Compile-time exclusion of Memory Power Management, and extending the
> > support to also work with other features such as Mem cgroups, kexec etc.
> >  
> 
> Compile-time exclusion is pointless because it'll be always activated by
> distribution configs. Support for MPST should be detected at runtime and
> 
> 3. ACPI support to actually use this thing and validate the design is
>    compatible with the spec and actually works in hardware

This is required to actually evaluate power saving benefit once we
have candidate implementations in the VM.

At this point we want to look at overheads of having region
infrastructure in VM and how does that trade off in terms of
requirements that we can meet.

The first goal is to have memory allocations fill as few regions as
possible when system's memory usage is significantly lower.  Next we
would like VM to actively move pages around to cooperate with platform
memory power saving features like notifications or policy changes.

--Vaidy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
