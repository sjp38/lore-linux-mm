Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id B660B6B0115
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 09:01:00 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp05.au.ibm.com (8.14.4/8.13.1) with ESMTP id p5TCsR6T032022
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 22:54:27 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5TD0hUW1331426
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 23:00:43 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5TD0htJ027264
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 23:00:43 +1000
Date: Wed, 29 Jun 2011 18:30:38 +0530
From: Ankita Garg <ankita@in.ibm.com>
Subject: Re: [PATCH 00/10] mm: Linux VM Infrastructure to support Memory
 Power Management
Message-ID: <20110629130038.GA7909@in.ibm.com>
Reply-To: Ankita Garg <ankita@in.ibm.com>
References: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org
Cc: svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org, Dave Hansen <dave@linux.vnet.ibm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Matthew Garrett <mjg59@srcf.ucam.org>, Arjan van de Ven <arjan@infradead.org>

Hi,

On Fri, May 27, 2011 at 06:01:28PM +0530, Ankita Garg wrote:
> Hi,
> 
> Modern systems offer higher CPU performance and large amount of memory in
> each generation in order to support application demands.  Memory subsystem has
> began to offer wide range of capabilities for managing power consumption,
> which is driving the need to relook at the way memory is managed by the
> operating system. Linux VM subsystem has sophisticated algorithms to
> optimally  manage the scarce resources for best overall system performance.
> Apart from the capacity and location of memory areas, the VM subsystem tracks
> special addressability restrictions in zones and relative distance from CPU as
> NUMA nodes if necessary. Power management capabilities in the memory subsystem
> and inclusion of different class of main memory like PCM, or non-volatile RAM,
> brings in new boundaries and attributes that needs to be tagged within the
> Linux VM subsystem for exploitation by the kernel and applications.
>

Below is the summary of the discussion we have had on this thread so
far, along with details of hardware capabilities and the VM requirements
to support memory power management.

Details of the hardware capabilities -

1) Dynamic Power Transition: The memory controller can have the ability
to automatically transition regions of memory into lower power states
when they are devoid of references for a pre-defined threshold amount of
time. Memory contents are preserved in the low power states and accessing
memory that is at a low power state takes a latency hit.

2) Dynamic Power Off: If a region is free/unallocated, the software can
indicate to the controller to completely turn off power to a certain
region. Memory contents are lost and hence the software has to be
absolutely sure about the usage statistics of the particular region. This
is a runtime capability, where the required amount of memory can be
powered 'ON' to match the workload demands.

3) Partial Array Self-Refresh (PASR): If a certain regions of memory is
free/unallocated, the software can indicate to the controller to not
refresh that region when the system goes to suspend-to-ram state and
thereby save standby power consumption.

Many embedded devices support one or more of the above capabilities.

Given the above capabilities, different levels of support is needed in
the OS, to exploit the hardware features. In general we need an artificial
threshold that guards against crossing over to the next region, along with
accurate statistics on how much memory is allocated in which region, so
that reclaim can target the regions with less pages and possibly evacuate
them.  Below are some details on potential approaches for each feature:

I) Dynamic Power Transition

The goal here is to ensure that as much as possible, on an idle system,
the memory references do not get spread across the entire RAM, a problem
similar to memory fragmentation. The proposed approach is as below:

1) One of the first things is to ensure that the memory allocations do
not spill over to more number of regions. Thus the allocator needs to
be aware of the address boundary of the different regions.

2) At the time of allocation, before spilling over allocations to the
next logical region, the allocator needs to make a best attempt to
reclaim some memory from within the existing region itself first. The
reclaim here needs to be in LRU order within the region.  However, if
it is ascertained that the reclaim would take a lot of time, like there
are quite a fe write-backs needed, then we can spill over to the next
memory region (just like our NUMA node allocation policy now).

II) Dynamic Power Off & PASR

The goal here is to ensure that as much as possible, on an idle system,
memory allocations are consolidated and most of the regions are kept
devoid of allocations.  The OS can then indicate to the controller to
turn off power to the specific regions. The requirements and proposed
approach is as below:

1) As mentioned above, one of the first things is to ensure that memory
is allocated sequentially across the regions and best effort is made to
allocate memory within a region, before going over to the next one.

2) Design OS callbacks to hardware, to track first page allocation and
last page deallocation, to better communicate to the hardware about
when to power on/off the region respectively. Alternatively, in the
absence of such notifications also, heuristics could be used to decide
on the threshold for the callbacks to decide when to trigger the power
related operation.

3) On some platforms like the Samsung Exynos 4210, while dynamic
power transition takes place at one granularity, dynamic power off is
performed at a different and a higher granularity. So, the OS needs
to be able to associate these regions into groups, to aid in making
allocation/deallocation/reclaim decisions.

Approaches -

Memory Regions

> 
>              -----------------------------
>              |N0 |N1 |N2 |N3 |.. |.. |Nn |   
>              -----------------------------   
>              / \ \
>             /   \  \
>            /     \   \
>  ------------    |  ------------
>  | Mem Rgn0 |    |  | Mem Rgn3 |             
>  ------------    |  ------------             
>     |            |         |
>     |      ------------    | ---------
>     |      | Mem Rgn1 |    ->| zones |
>     |      ------------      ---------
>     |          |     ---------
>     |          ----->| zones |
>     | ---------      ---------
>     ->| zones |
>       ---------
> 

(a) A data structure to capture the hardware memory region boundaries
and also enable grouping of certain regions together for the purpose of
higher order power saving operations.

(b) Enable gathering of accurate page allocation statistics on a
per-memory region granularity

(c) Allow memory to be allocated from within a hardware region first,
target easily reclaimable pages within the current region and only then
spill over to the other regions if memory pressure is high. In an empty
region, allocation will happen sequentially anyway, but need a mechanism
to do targeted reclaim in LRU order within a region, to keep allocations
from spreading easily to other regions.

(d) Targeted reclaims of memory from within a memory region when its
utilization (allocation) is very low. Once the utilization of a region
falls below a certain threshold, move the remaining pages to other active
(fairly utilized) regions and evacuate the underutilized ones. This
would basically consolidate all allocated memory into less number of
memory regions.

The proposed memory regions approach has the advantages of catering to
all of the above requirements, but has the disadvantage of fragmenting
zones in the system.

Alternative suggestions that came up:

- Hacking the buddy allocator to free up chunks of pages to exploit PASR

  The buddy allocator does not take any address boundary into account.
  However, one approach would be to keep the boundary information in a
  parallel data structure, and at the time of allocation, look hard for
  the pages belonging to a particular region.

- Using lumpy reclaim as a mechanism to free-up region sized and aligned
  pages from the buddy allocator, but will not help in shaping
  allocations

- The LRU reclaimer presently operates within a zone and does not take
  into account the physical addresses. One approach could be to extend it
  to reclaim the LRU pages within a given address range

- A balloon driver to offline contiguous chunks of pages. However, we
  would still need a mechanism to group sections that belong to the same
  region and also bias the allocations

- Modify the buddy allocator to be "picky" about when it lets you get
  access to the regions
 
-- 
Regards,
Ankita Garg (ankita@in.ibm.com)
Linux Technology Center
IBM India Systems & Technology Labs,
Bangalore, India

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
