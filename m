Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 780E76B0032
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 08:42:31 -0400 (EDT)
Received: by iget9 with SMTP id t9so103495534ige.1
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 05:42:31 -0700 (PDT)
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com. [32.97.110.158])
        by mx.google.com with ESMTPS id jq4si4460984icc.10.2015.04.22.05.42.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Apr 2015 05:42:30 -0700 (PDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 22 Apr 2015 06:42:30 -0600
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 9F88F1FF0021
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 06:33:37 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b03cxnp07028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3MCeU0Q27852962
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 05:40:30 -0700
Received: from d03av05.boulder.ibm.com (localhost [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3MCgQJg014699
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 06:42:26 -0600
Date: Wed, 22 Apr 2015 05:42:24 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Interacting with coherent memory on external devices
Message-ID: <20150422124224.GS5561@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20150421214445.GA29093@linux.vnet.ibm.com>
 <20150421234606.GA6046@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150421234606.GA6046@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Tue, Apr 21, 2015 at 07:46:07PM -0400, Jerome Glisse wrote:
> On Tue, Apr 21, 2015 at 02:44:45PM -0700, Paul E. McKenney wrote:
> > Hello!
> > 
> > We have some interest in hardware on devices that is cache-coherent
> > with main memory, and in migrating memory between host memory and
> > device memory.  We believe that we might not be the only ones looking
> > ahead to hardware like this, so please see below for a draft of some
> > approaches that we have been thinking of.
> > 
> > Thoughts?
> 
> I have posted several time a patchset just for doing that, i am sure
> Ben did see it. Search for HMM. I am about to repost it in next couple
> weeks.

Looking forward to seeing it!  As you note below, we are not trying
to replace HMM, but rather to build upon it.

> > ------------------------------------------------------------------------
> > 
> >            COHERENT ON-DEVICE MEMORY: ACCESS AND MIGRATION
> >                          Ben Herrenschmidt
> >                    (As told to Paul E. McKenney)
> > 
> > 	Special-purpose hardware becoming more prevalent, and some of this
> > 	hardware allows for tight interaction with CPU-based processing.
> > 	For example, IBM's coherent accelerator processor interface
> > 	(CAPI) will allow this sort of device to be constructed,
> > 	and it is likely that GPGPUs will need similar capabilities.
> > 	(See http://www-304.ibm.com/webapp/set2/sas/f/capi/home.html for a
> > 	high-level description of CAPI.)  Let's call these cache-coherent
> > 	accelerator devices (CCAD for short, which should at least
> > 	motivate someone to come up with something better).
> > 
> > 	This document covers devices with the following properties:
> > 
> > 	1.	The device is cache-coherent, in other words, the device's
> > 		memory has all the characteristics of system memory from
> > 		the viewpoint of CPUs and other devices accessing it.
> > 
> > 	2.	The device provides local memory that it has high-bandwidth
> > 		low-latency access to, but the device can also access
> > 		normal system memory.
> > 
> > 	3.	The device shares system page tables, so that it can
> > 		transparently access userspace virtual memory, regardless
> > 		of whether this virtual memory maps to normal system
> > 		memory or to memory local to the device.
> > 
> > 	Although such a device will provide CPU's with cache-coherent
> > 	access to on-device memory, the resulting memory latency is
> > 	expected to be slower than the normal memory that is tightly
> > 	coupled to the CPUs.  Nevertheless, data that is only occasionally
> > 	accessed by CPUs should be stored in the device's memory.
> > 	On the other hand, data that is accessed rarely by the device but
> > 	frequently by the CPUs should be stored in normal system memory.
> > 
> > 	Of course, some workloads will have predictable access patterns
> > 	that allow data to be optimally placed up front.  However, other
> > 	workloads will have less-predictable access patterns, and these
> > 	workloads can benefit from automatic migration of data between
> > 	device memory and system memory as access patterns change.
> > 	Furthermore, some devices will provide special hardware that
> > 	collects access statistics that can be used to determine whether
> > 	or not a given page of memory should be migrated, and if so,
> > 	to where.
> > 
> > 	The purpose of this document is to explore how this access
> > 	and migration can be provided for within the Linux kernel.
> 
> All of the above is the exact requisit for hardware that want to use
> HMM.
> 
> > 
> > REQUIREMENTS
> > 
> > 	1.	It should be possible to remove a given CCAD device
> > 		from service, for example, to reset it, to download
> > 		updated firmware, or to change its functionality.
> > 		This results in the following additional requirements:
> > 
> > 		a.	It should be possible to migrate all data away
> > 			from the device's memory at any time.
> > 
> > 		b.	Normal memory allocation should avoid using the
> > 			device's memory, as this would interfere
> > 			with the needed migration.  It may nevertheless
> > 			be desirable to use the device's memory
> > 			if system memory is exhausted, however, in some
> > 			cases, even this "emergency" use is best avoided.
> > 			In fact, a good solution will provide some means
> > 			for avoiding this for those cases where it is
> > 			necessary to evacuate memory when offlining the
> > 			device.
> > 
> > 	2.	Memory can be either explicitly or implicitly allocated
> > 		from the CCAD device's memory.	(Both usermode and kernel
> > 		allocation required.)
> > 
> > 		Please note that implicit allocation will need to be
> > 		avoided in a number of use cases.  The reason for this
> > 		is that random kernel allocations might be pinned into
> > 		memory, which could conflict with requirement (1) above,
> > 		and might furthermore fragment the device's memory.
> > 
> > 	3.	The device's memory is treated like normal system
> > 		memory by the Linux kernel, for example, each page has a
> > 		"struct page" associate with it.  (In contrast, the
> > 		traditional approach has used special-purpose OS mechanisms
> > 		to manage the device's memory, and this memory was treated
> > 		as MMIO space by the kernel.)
> > 
> > 	4.	The system's normal tuning mechanism may be used to
> > 		tune allocation locality, migration, and so on, as
> > 		required to match performance and functional requirements.
> 
> Ok here you diverge substantially from HMM design, HMM is intended for
> platform where the device memory is not necessarily (and unlikely) to
> be visible by the CPU (x86 IOMMU PCI bar size are all the keywords here).

Yep!  ;-)

> For this reason in HMM there is no intention to expose the device memory
> as some memory useable by the CPU and thus no intention to create struct
> page for it.
> 
> That being said commenting on your idea i would say that normal memory
> allocation should never use the device memory unless the allocation
> happens due to a device page fault and the device driver request it.

For many use case, agreed.  Perhaps even for all use cases.

> Moreover even if you go down the lets add a struct page for this remote
> memory, it will not work with file backed page in the DAX case.

At a first glance, I agree that DAX's filesystems seem not to be
helping here.  Christoph might have other thoughts.

> > POTENTIAL IDEAS
> > 
> > 	It is only reasonable to ask whether CCAD devices can simply
> > 	use the HMM patch that has recently been proposed to allow
> > 	migration between system and device memory via page faults.
> > 	Although this works well for devices whose local MMU can contain
> > 	mappings different from that of the system MMU, the HMM patch
> > 	is still working with MMIO space that gets special treatment.
> > 	The HMM patch does not (yet) provide the full transparency that
> > 	would allow the device memory to be treated in the same way as
> > 	system memory.	Something more is therefore required, for example,
> > 	one or more of the following:
> > 
> > 	1.	Model the CCAD device's memory as a memory-only NUMA node
> > 		with a very large distance metric.  This allows use of
> > 		the existing mechanisms for choosing where to satisfy
> > 		explicit allocations and where to target migrations.
> > 		
> > 	2.	Cover the memory with a CMA to prevent non-migratable
> > 		pinned data from being placed in the CCAD device's memory.
> > 		It would also permit the driver to perform dedicated
> > 		physically contiguous allocations as needed.
> > 
> > 	3.	Add a new ZONE_EXTERNAL zone for all CCAD-like devices.
> > 		Note that this would likely require support for
> > 		discontinuous zones in order to support large NUMA
> > 		systems, in which each node has a single block of the
> > 		overall physical address space.  In such systems, the
> > 		physical address ranges of normal system memory would
> > 		be interleaved with those of device memory.
> > 
> > 		This would also require some sort of
> > 		migration infrastructure to be added, as autonuma would
> > 		not apply.  However, this approach has the advantage
> > 		of preventing allocations in these regions, at least
> > 		unless those allocations have been explicitly flagged
> > 		to go there.
> > 
> > 	4.	Your idea here!
> 
> Well AUTONUMA is interesting if you collect informations from the device
> on what memory the device is accessing the most. But even then i am not
> convince that actually collecting hint from userspace isn't more efficient.
> 
> Often the userspace library/program that leverage the GPU knows better
> what will be the memory access pattern and can make better decissions.

The argument over which of hardware measurements and usermode hints
should prevail has been going on for the better part of two decades,
in various contexts.  ;-)

> In any case i think you definitly need the new special zone to block any
> kernel allocation from using the device memory. Device memory should
> solely be use on request from the process/device driver. I also think
> this is does not block doing something like AUTONUMA on top, probably
> with slight modification to the autonuma code to become aware of this
> new kind of node.

Agreed, there are important use cases where you don't want random
allocations in device memory, for example, cases where you might
need to remove or reset the device at runtime.


> > AUTONUMA
> > 
> > 	The Linux kernel's autonuma facility supports migrating both
> > 	memory and processes to promote NUMA memory locality.  It was
> > 	accepted into 3.13 and is available in RHEL 7.0 and SLES 12.
> > 	It is enabled by the Kconfig variable CONFIG_NUMA_BALANCING.
> > 
> > 	This approach uses a kernel thread "knuma_scand" that periodically
> > 	marks pages inaccessible.  The page-fault handler notes any
> > 	mismatches between the NUMA node that the process is running on
> > 	and the NUMA node on which the page resides.
> > 
> > 	http://lwn.net/Articles/488709/
> > 	https://www.kernel.org/pub/linux/kernel/people/andrea/autonuma/autonuma_bench-20120530.pdf
> > 
> > 	It will be necessary to set up the CCAD device's memory as
> > 	a very distant NUMA node, and the architecture-specific
> > 	__numa_distance() function can be used for this purpose.
> > 	There is a RECLAIM_DISTANCE macro that can be set by the
> > 	architecture to prevent reclaiming from nodes that are too
> > 	far away.  Some experimentation would be required to determine
> > 	the combination of values for the various distance macros.
> > 
> > 	This approach needs some way to pull in data from the hardware
> > 	on access patterns.  Aneesh Kk Veetil is prototyping an approach
> > 	based on Power 8 hardware counters.  This data will need to be
> > 	plugged into the migration algorithm, which is currently based
> > 	on collecting information from page faults.
> > 
> > 	Finally, the contiguous memory allocator (CMA, see
> > 	http://lwn.net/Articles/486301/) is needed in order to prevent
> > 	the kernel from placing non-migratable allocations in the CCAD
> > 	device's memory.  This would need to be of type MIGRATE_CMA to
> > 	ensure that all memory taken from that range be migratable.
> > 
> > 	The result would be that the kernel would allocate only migratable
> > 	pages within the CCAD device's memory, and even then only if
> > 	memory was otherwise exhausted.  Normal CONFIG_NUMA_BALANCING
> > 	migration could be brought to bear, possibly enhanced with
> > 	information from hardware counters.  One remaining issue is that
> > 	there is no way to absolutely prevent random kernel subsystems
> > 	from allocating the CCAD device's memory, which could cause
> > 	failures should the device need to reset itself, in which case
> > 	the memory would be temporarily inaccessible -- which could be
> > 	a fatal surprise to that kernel subsystem.
> > 
> > MEMORY ZONE
> > 
> > 	One way to avoid the problem of random kernel subsystems using
> > 	the CAPI device's memory is to create a new memory zone for
> > 	this purpose.  This would add something like ZONE_DEVMEM to the
> > 	current set that includes ZONE_DMA, ZONE_NORMAL, and ZONE_MOVABLE.
> > 	Currently, there are a maximum of four zones, so this limit must
> > 	either be increased or kernels built with ZONE_DEVMEM must avoid
> > 	having more than one of ZONE_DMA, ZONE_DMA32, and ZONE_HIGHMEM.
> > 
> > 	This approach requires that migration be implemented on the side,
> > 	as the CONFIG_NUMA_BALANCING will not help here (unless I am
> > 	missing something).  One advantage of this situation is that
> > 	hardware locality measurements could be incorporated from the
> > 	beginning.  Another advantage is that random kernel subsystems
> > 	and user programs would not get CAPI device memory unless they
> > 	explicitly requested it.
> > 
> > 	Code would be needed at boot time to place the CAPI device
> > 	memory into ZONE_DEVMEM, perhaps involving changes to
> > 	mem_init() and paging_init().
> > 
> > 	In addition, an appropriate GFP_DEVMEM would be needed, along
> > 	with code in various paths to handle it appropriately.
> > 
> > 	Also, because large NUMA systems will sometimes interleave the
> > 	addresses of blocks of physical memory and device memory,
> > 	support for discontiguous interleaved zones will be required.
> 
> 
> Zone and numa node should be orthogonal in my mind, even if most of the
> different zone (DMA, DMA32, NORMAL) always endup being on the same node.
> Zone is really the outcome of some "old" hardware restriction (32bits
> brave old world). So zone most likely require some work to face reality
> of today world. While existing zone need to keep their definition base
> on physical address, the zone code should not care about that, effectively
> allowing zone that have several different chunk of physical address range.
> I also believe that persistant memory might have same kind of requirement
> so you might be able to piggy back on any work they might have to do, or
> at least work i believe they need to do.
> 
> But i have not look into all that code much and i might just be dreaming
> about how the world should be and some subtle details is likely escaping
> me.

I believe that some substantial changes to zones would be required.  So it
might be that some other approach would be better.  But until we come
up with an alternative, I am thinking along the lines of changes to zones.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
