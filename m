Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 9634F6B0072
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 14:39:41 -0500 (EST)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Fri, 9 Nov 2012 05:35:48 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qA8JTATE60752064
	for <linux-mm@kvack.org>; Fri, 9 Nov 2012 06:29:11 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qA8JdQfT023212
	for <linux-mm@kvack.org>; Fri, 9 Nov 2012 06:39:26 +1100
Message-ID: <509C0A29.6060805@linux.vnet.ibm.com>
Date: Fri, 09 Nov 2012 01:08:17 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/8][Sorted-buddy] mm: Linux VM Infrastructure to
 support Memory Power Management
References: <20121106195026.6941.24662.stgit@srivatsabhat.in.ibm.com> <20121108180257.GC8218@suse.de>
In-Reply-To: <20121108180257.GC8218@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: akpm@linux-foundation.org, mjg59@srcf.ucam.org, paulmck@linux.vnet.ibm.com, dave@linux.vnet.ibm.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, arjan@linux.intel.com, kmpark@infradead.org, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/08/2012 11:32 PM, Mel Gorman wrote:
> On Wed, Nov 07, 2012 at 01:22:13AM +0530, Srivatsa S. Bhat wrote:
>> ------------------------------------------------------------
>>
>> Today memory subsystems are offer a wide range of capabilities for managing
>> memory power consumption. As a quick example, if a block of memory is not
>> referenced for a threshold amount of time, the memory controller can decide to
>> put that chunk into a low-power content-preserving state. And the next
>> reference to that memory chunk would bring it back to full power for read/write.
>> With this capability in place, it becomes important for the OS to understand
>> the boundaries of such power-manageable chunks of memory and to ensure that
>> references are consolidated to a minimum number of such memory power management
>> domains.
>>
> 
> How much power is saved?

Last year, Amit had evaluated the "Hierarchy" patchset on a Samsung Exynos (ARM)
board and reported that it could save up to 6.3% relative to total system power.
(This was when he allowed only 1 GB out of the total 2 GB RAM to enter low
power states).

Below is the link to his post, as mentioned in the references section in the
cover letter.
http://article.gmane.org/gmane.linux.kernel.mm/65935

Of course, the power savings depends on the characteristics of the particular
hardware memory subsystem used, and the amount of memory present in the system.

> 
>> ACPI 5.0 has introduced MPST tables (Memory Power State Tables) [5] so that
>> the firmware can expose information regarding the boundaries of such memory
>> power management domains to the OS in a standard way.
>>
> 
> I'm not familiar with the ACPI spec but is there support for parsing of
> MPST and interpreting the associated ACPI events?

Sorry I should have been clearer when I mentioned ACPI 5.0. I mentioned ACPI 5.0
just to make a point that support for getting the memory power management
boundaries from the firmware is not far away. I didn't mean to say that that's
the only target for memory power management. Like I mentioned above, last year
the power-savings benefit was measured on ARM boards. The aim of this patchset
is to propose and evaluate some of the core VM algorithms that we will need
to efficiently exploit the power management features offered by the memory
subsystems.

IOW, info regarding memory power domain boundaries made available by ACPI 5.0
or even just with some help from the bootloader on some platforms is only the
input to the VM subsystem to understand at what granularity it should manage
things. *How* it manages is the choice of the algorithm/design at the VM level,
which is what this patchset is trying to propose, by exploring several different
designs of doing it and its costs/benefits.

That's the reason I just hard-coded mem region size to 512 MB in this patchset
and focussed on the VM algorithm to explore what we can do, once we have that
size/boundary info.

> For example, if ACPI
> fires an event indicating that a memory power node is to enter a low
> state then presumably the OS should actively migrate pages away -- even
> if it's going into a state where the contents are still refreshed
> as exiting that state could take a long time.
> 

We are not really looking at ACPI event notifications here. All we expect from
the firmware (at a first level) is info regarding the boundaries, so that the
VM can be intelligent about how it consolidates references. Many of the memory
subsystems can do power-management automatically - like for example, if a
particular chunk of memory is not referenced for a given threshold time, it can
put it into low-power (content preserving) state without the OS telling it to
do it.

> I did not look closely at the patchset at all because it looked like the
> actual support to use it and measure the benefit is missing.
> 

Right, we are focussing on the core VM algorithms for now. The input (ACPI or
other methods) can come later and then we can measure the numbers.

>> How can Linux VM help memory power savings?
>>
>> o Consolidate memory allocations and/or references such that they are
>> not spread across the entire memory address space.  Basically area of memory
>> that is not being referenced, can reside in low power state.
>>
> 
> Which the series does not appear to do.
> 

Well, it influences page-allocation to be memory-region aware. So it does an
attempt to consolidate allocations (and thereby references). As I mentioned,
hardware transition to low-power state can be automatic. The VM must be
intelligent enough to help with that (or atleast smart enough not to disrupt
that!), by avoiding spreading across allocations everywhere.

>> o Support targeted memory reclaim, where certain areas of memory that can be
>> easily freed can be offlined, allowing those areas of memory to be put into
>> lower power states.
>>
> 
> Which the series does not appear to do judging from this;
> 

Yes, that is one of the items in the TODO list.

>   include/linux/mm.h     |   38 +++++++
>   include/linux/mmzone.h |   52 +++++++++
>   mm/compaction.c        |    8 +
>   mm/page_alloc.c        |  263 ++++++++++++++++++++++++++++++++++++++++++++----
>   mm/vmstat.c            |   59 ++++++++++-
> 
> This does not appear to be doing anything with reclaim and not enough with
> compaction to indicate that the series actively manages memory placement
> in response to ACPI events.
> 
> Further in section 5.2.21.4 the spec says that power node regions can
> overlap (but are not hierarchal for some reason) but have no gaps yet the
> structure you use to represent is assumes there can be gaps and there are
> no overlaps. Again, this is just glancing at the spec and a quick skim of
> the patches so maybe I missed something that explains why this structure
> is suitable.
>

Right, we might need a better way to handle the various possibilities of
the layout of memory regions in the hardware. But this initial RFC tried to
focus on what do we do with that info, inside the VM to aid with power
management.

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

As I mentioned, we are not really talking about reacting to ACPI events here.
The idea behind this patchset is to have efficient VM algorithms that can
shape memory references depending on power-management boundaries exposed by
the firmware. With that as the goal, I feel we should not even consider
migration as a first step - we should rather consider how to shape allocations
such that we can remain power-efficient right from the beginning and
throughout the runtime, without needing to migrate if possible. And this
patchset implements one of the designs that achieves that.
 
> For any of this to be worthwhile, low power states would need to be achieved
> for long periods of time because that migration is not free.
> 

Best to avoid migration as far as possible in the first place :-)

>> Memory Regions:
>> ---------------
>>
>> "Memory Regions" is a way of capturing the boundaries of power-managable
>> chunks of memory, within the MM subsystem.
>>
>> Short description of the "Sorted-buddy" design:
>> -----------------------------------------------
>>
>> In this design, the memory region boundaries are captured in a parallel
>> data-structure instead of fitting regions between nodes and zones in the
>> hierarchy. Further, the buddy allocator is altered, such that we maintain the
>> zones' freelists in region-sorted-order and thus do page allocation in the
>> order of increasing memory regions.
> 
> Implying that this sorting has to happen in the either the alloc or free
> fast path.
> 

Yep, I have moved it to the free path. The alloc path remains fast.

>> (The freelists need not be fully
>> address-sorted, they just need to be region-sorted. Patch 6 explains this
>> in more detail).
>>
>> The idea is to do page allocation in increasing order of memory regions
>> (within a zone) and perform page reclaim in the reverse order, as illustrated
>> below.
>>
>> ---------------------------- Increasing region number---------------------->
>>
>> Direction of allocation--->                         <---Direction of reclaim
>>
> 
> Compaction will work against this because it uses a PFN walker to isolate
> free pages and will ignore memory regions. If pageblocks were used, it
> could take that into account at least.
> 
>> The sorting logic (to maintain freelist pageblocks in region-sorted-order)
>> lies in the page-free path and not the page-allocation path and hence the
>> critical page allocation paths remain fast.
> 
> Page free can be a critical path for application performance as well.
> Think network buffer heavy alloc and freeing of buffers.
> 
> However, migratetype information is already looked up for THP so ideally
> power awareness would piggyback on it.
> 
>> Moreover, the heart of the page
>> allocation algorithm itself remains largely unchanged, and the region-related
>> data-structures are optimized to avoid unnecessary updates during the
>> page-allocator's runtime.
>>
>> Advantages of this design:
>> --------------------------
>> 1. No zone-fragmentation (IOW, we don't create more zones than necessary) and
>>    hence we avoid its associated problems (like too many zones, extra page
>>    reclaim threads, question of choosing watermarks etc).
>>    [This is an advantage over the "Hierarchy" design]
>>
>> 2. Performance overhead is expected to be low: Since we retain the simplicity
>>    of the algorithm in the page allocation path, page allocation can
>>    potentially remain as fast as it would be without memory regions. The
>>    overhead is pushed to the page-freeing paths which are not that critical.
>>
>>
>> Results:
>> =======
>>
>> Test setup:
>> -----------
>> This patchset applies cleanly on top of 3.7-rc3.
>>
>> x86 dual-socket quad core HT-enabled machine booted with mem=8G
>> Memory region size = 512 MB
>>
>> Functional testing:
>> -------------------
>>
>> Ran pagetest, a simple C program that allocates and touches a required number
>> of pages.
>>
>> Below is the statistics from the regions within ZONE_NORMAL, at various sizes
>> of allocations from pagetest.
>>
>> 	     Present pages   |	Free pages at various allocations        |
>> 			     |  start	|  512 MB  |  1024 MB | 2048 MB  |
>>   Region 0      16	     |   0      |    0     |     0    |    0     |
>>   Region 1      131072       |  87219   |  8066    |   7892   |  7387    |
>>   Region 2      131072       | 131072   |  79036   |     0    |    0     |
>>   Region 3      131072       | 131072   | 131072   |   79061  |    0     |
>>   Region 4      131072       | 131072   | 131072   |  131072  |    0     |
>>   Region 5      131072       | 131072   | 131072   |  131072  |  79051   |
>>   Region 6      131072       | 131072   | 131072   |  131072  |  131072  |
>>   Region 7      131072       | 131072   | 131072   |  131072  |  131072  |
>>   Region 8      131056       | 105475   | 105472   |  105472  |  105472  |
>>
>> This shows that page allocation occurs in the order of increasing region
>> numbers, as intended in this design.
>>
>> Performance impact:
>> -------------------
>>
>> Kernbench results didn't show much of a difference between the performance
>> of vanilla 3.7-rc3 and this patchset.
>>
>>
>> Todos:
>> =====
>>
>> 1. Memory-region aware page-reclamation:
>> ----------------------------------------
>>
>> We would like to do page reclaim in the reverse order of page allocation
>> within a zone, ie., in the order of decreasing region numbers.
>> To achieve that, while scanning lru pages to reclaim, we could potentially
>> look for pages belonging to higher regions (considering region boundaries)
>> or perhaps simply prefer pages of higher pfns (and skip lower pfns) as
>> reclaim candidates.
>>
> 
> This would disrupting LRU ordering and if those pages were recently
> allocated and you force a situation where swap has to be used then any
> saving in low memory will be lost by having to access the disk instead.
>

Right, we need to do it in a way that doesn't hurt performance or power-savings.
I definitely need to think more on this.. Any suggestions? 
 
>> 2. Compile-time exclusion of Memory Power Management, and extending the
>> support to also work with other features such as Mem cgroups, kexec etc.
>>  
> 
> Compile-time exclusion is pointless because it'll be always activated by
> distribution configs. Support for MPST should be detected at runtime and
> 
> 3. ACPI support to actually use this thing and validate the design is
>    compatible with the spec and actually works in hardware
> 

ACPI is not the only way to exploit this; other platforms (like ARM for example)
can expose info today with some help with the bootloader, and as mentioned
Amit already did a quick evaluation last year. So its not like we are totally
blocked on ACPI support in order to design the VM algorithms to manage memory
power-efficiently.

Thanks a lot for taking a look and for your invaluable feedback!

Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
