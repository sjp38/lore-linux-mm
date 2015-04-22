Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id B78B26B0032
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 09:35:35 -0400 (EDT)
Received: by qcpm10 with SMTP id m10so92971114qcp.3
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 06:35:35 -0700 (PDT)
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com. [32.97.110.150])
        by mx.google.com with ESMTPS id f53si5048342qge.68.2015.04.22.06.35.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Apr 2015 06:35:33 -0700 (PDT)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 22 Apr 2015 07:35:32 -0600
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id BE9A41FF0021
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 07:26:41 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b03cxnp08028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3MDZCXp38994006
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 06:35:12 -0700
Received: from d03av05.boulder.ibm.com (localhost [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3MDZUNN014637
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 07:35:30 -0600
Date: Wed, 22 Apr 2015 06:35:29 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Interacting with coherent memory on external devices
Message-ID: <20150422133529.GA16012@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20150421214445.GA29093@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1504211839120.6294@gentwo.org>
 <20150422000538.GB6046@gmail.com>
 <alpine.DEB.2.11.1504211942040.6294@gentwo.org>
 <1429664486.27410.83.camel@kernel.crashing.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1429664486.27410.83.camel@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Christoph Lameter <cl@linux.com>, Jerome Glisse <j.glisse@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Wed, Apr 22, 2015 at 11:01:26AM +1000, Benjamin Herrenschmidt wrote:
> On Tue, 2015-04-21 at 19:50 -0500, Christoph Lameter wrote:
> 
> > With a filesystem the migration can be controlled by the application. It
> > can copy stuff whenever it wants to.Having the OS do that behind my back
> > is not something that feels safe and secure.
> 
> But this is not something the user wants. The filesystem model is
> completely the wrong model for us.
> 
> This is fundamentally the same model as memory migrating between NUMA
> nodes except that one of these is a co-processor with its local memory.
> 
> You want to malloc() some stuff or get a pointer provided by an app to
> your library and be able to farm that job out to the co-processor. No
> filesystem in the picture here.

I updated the document based on feedback thus far, and a big "thank you"
to everyone!  Diffs below, followed by the full document.

							Thanx, Paul

------------------------------------------------------------------------

diff --git a/DeviceMem.txt b/DeviceMem.txt
index e2d65d585f03..cdedf2ee96e9 100644
--- a/DeviceMem.txt
+++ b/DeviceMem.txt
@@ -48,6 +48,25 @@
 	The purpose of this document is to explore how this access
 	and migration can be provided for within the Linux kernel.
 
+
+USE CASES
+
+	o	GPGPU matrix operations, from Jerome Glisse.
+		https://lkml.org/lkml/2015/4/21/898
+
+		Suppose that you have an application that uses a
+		scientific library to do matrix computations, and that
+		this application simply calls malloc() and give the
+		resulting pointer to the library function.  If the GPGPU
+		has coherent access to system memory (and vice versa),
+		it would help performance and application compatibility
+		to be able to transparently migrate the malloc()ed
+		memory to and from the GPGPU's memory without requiring
+		changes to the application.
+
+	o	(More here for CAPI.)
+
+
 REQUIREMENTS
 
 	1.	It should be possible to remove a given CCAD device
@@ -132,6 +151,9 @@ POTENTIAL IDEAS
 	4.	Your idea here!
 
 
+The following sections cover AutoNUMA, use of memory zones, and DAX.
+
+
 AUTONUMA
 
 	The Linux kernel's autonuma facility supports migrating both
@@ -178,6 +200,10 @@ AUTONUMA
 	the memory would be temporarily inaccessible -- which could be
 	a fatal surprise to that kernel subsystem.
 
+	Jerome Glisse suggests that usermode hints are quite important,
+	and perhaps should replace any AutoNUMA measurements.
+
+
 MEMORY ZONE
 
 	One way to avoid the problem of random kernel subsystems using
@@ -206,3 +232,26 @@ MEMORY ZONE
 	Also, because large NUMA systems will sometimes interleave the
 	addresses of blocks of physical memory and device memory,
 	support for discontiguous interleaved zones will be required.
+
+
+DAX
+
+	DAX is a mechanism for providing direct-memory access to
+	high-speed non-volatile (AKA "persistent") memory.  Good
+	introductions to DAX may be found in the following LWN
+	articles:
+
+		https://lwn.net/Articles/591779/
+		https://lwn.net/Articles/610174/
+
+	DAX provides filesystem-level access to persistent memory.
+	One important CCAD use case is allowing a legacy application
+	to pass memory from malloc() to a CCAD device, and having
+	the allocated memory migrate as needed.  DAX does not seem to
+	support this use case.
+
+
+ACKNOWLEDGMENTS
+
+	Updates to this document include feedback from Christoph Lameter
+	and Jerome Glisse.

------------------------------------------------------------------------

           COHERENT ON-DEVICE MEMORY: ACCESS AND MIGRATION
                         Ben Herrenschmidt
                   (As told to Paul E. McKenney)

	Special-purpose hardware becoming more prevalent, and some of this
	hardware allows for tight interaction with CPU-based processing.
	For example, IBM's coherent accelerator processor interface
	(CAPI) will allow this sort of device to be constructed,
	and it is likely that GPGPUs will need similar capabilities.
	(See http://www-304.ibm.com/webapp/set2/sas/f/capi/home.html for a
	high-level description of CAPI.)  Let's call these cache-coherent
	accelerator devices (CCAD for short, which should at least
	motivate someone to come up with something better).

	This document covers devices with the following properties:

	1.	The device is cache-coherent, in other words, the device's
		memory has all the characteristics of system memory from
		the viewpoint of CPUs and other devices accessing it.

	2.	The device provides local memory that it has high-bandwidth
		low-latency access to, but the device can also access
		normal system memory.

	3.	The device shares system page tables, so that it can
		transparently access userspace virtual memory, regardless
		of whether this virtual memory maps to normal system
		memory or to memory local to the device.

	Although such a device will provide CPU's with cache-coherent
	access to on-device memory, the resulting memory latency is
	expected to be slower than the normal memory that is tightly
	coupled to the CPUs.  Nevertheless, data that is only occasionally
	accessed by CPUs should be stored in the device's memory.
	On the other hand, data that is accessed rarely by the device but
	frequently by the CPUs should be stored in normal system memory.

	Of course, some workloads will have predictable access patterns
	that allow data to be optimally placed up front.  However, other
	workloads will have less-predictable access patterns, and these
	workloads can benefit from automatic migration of data between
	device memory and system memory as access patterns change.
	Furthermore, some devices will provide special hardware that
	collects access statistics that can be used to determine whether
	or not a given page of memory should be migrated, and if so,
	to where.

	The purpose of this document is to explore how this access
	and migration can be provided for within the Linux kernel.


USE CASES

	o	GPGPU matrix operations, from Jerome Glisse.
		https://lkml.org/lkml/2015/4/21/898

		Suppose that you have an application that uses a
		scientific library to do matrix computations, and that
		this application simply calls malloc() and give the
		resulting pointer to the library function.  If the GPGPU
		has coherent access to system memory (and vice versa),
		it would help performance and application compatibility
		to be able to transparently migrate the malloc()ed
		memory to and from the GPGPU's memory without requiring
		changes to the application.

	o	(More here for CAPI.)


REQUIREMENTS

	1.	It should be possible to remove a given CCAD device
		from service, for example, to reset it, to download
		updated firmware, or to change its functionality.
		This results in the following additional requirements:

		a.	It should be possible to migrate all data away
			from the device's memory at any time.

		b.	Normal memory allocation should avoid using the
			device's memory, as this would interfere
			with the needed migration.  It may nevertheless
			be desirable to use the device's memory
			if system memory is exhausted, however, in some
			cases, even this "emergency" use is best avoided.
			In fact, a good solution will provide some means
			for avoiding this for those cases where it is
			necessary to evacuate memory when offlining the
			device.

	2.	Memory can be either explicitly or implicitly allocated
		from the CCAD device's memory.	(Both usermode and kernel
		allocation required.)

		Please note that implicit allocation will need to be
		avoided in a number of use cases.  The reason for this
		is that random kernel allocations might be pinned into
		memory, which could conflict with requirement (1) above,
		and might furthermore fragment the device's memory.

	3.	The device's memory is treated like normal system
		memory by the Linux kernel, for example, each page has a
		"struct page" associate with it.  (In contrast, the
		traditional approach has used special-purpose OS mechanisms
		to manage the device's memory, and this memory was treated
		as MMIO space by the kernel.)

	4.	The system's normal tuning mechanism may be used to
		tune allocation locality, migration, and so on, as
		required to match performance and functional requirements.


POTENTIAL IDEAS

	It is only reasonable to ask whether CCAD devices can simply
	use the HMM patch that has recently been proposed to allow
	migration between system and device memory via page faults.
	Although this works well for devices whose local MMU can contain
	mappings different from that of the system MMU, the HMM patch
	is still working with MMIO space that gets special treatment.
	The HMM patch does not (yet) provide the full transparency that
	would allow the device memory to be treated in the same way as
	system memory.	Something more is therefore required, for example,
	one or more of the following:

	1.	Model the CCAD device's memory as a memory-only NUMA node
		with a very large distance metric.  This allows use of
		the existing mechanisms for choosing where to satisfy
		explicit allocations and where to target migrations.
		
	2.	Cover the memory with a CMA to prevent non-migratable
		pinned data from being placed in the CCAD device's memory.
		It would also permit the driver to perform dedicated
		physically contiguous allocations as needed.

	3.	Add a new ZONE_EXTERNAL zone for all CCAD-like devices.
		Note that this would likely require support for
		discontinuous zones in order to support large NUMA
		systems, in which each node has a single block of the
		overall physical address space.  In such systems, the
		physical address ranges of normal system memory would
		be interleaved with those of device memory.

		This would also require some sort of
		migration infrastructure to be added, as autonuma would
		not apply.  However, this approach has the advantage
		of preventing allocations in these regions, at least
		unless those allocations have been explicitly flagged
		to go there.

	4.	Your idea here!


The following sections cover AutoNUMA, use of memory zones, and DAX.


AUTONUMA

	The Linux kernel's autonuma facility supports migrating both
	memory and processes to promote NUMA memory locality.  It was
	accepted into 3.13 and is available in RHEL 7.0 and SLES 12.
	It is enabled by the Kconfig variable CONFIG_NUMA_BALANCING.

	This approach uses a kernel thread "knuma_scand" that periodically
	marks pages inaccessible.  The page-fault handler notes any
	mismatches between the NUMA node that the process is running on
	and the NUMA node on which the page resides.

	http://lwn.net/Articles/488709/
	https://www.kernel.org/pub/linux/kernel/people/andrea/autonuma/autonuma_bench-20120530.pdf

	It will be necessary to set up the CCAD device's memory as
	a very distant NUMA node, and the architecture-specific
	__numa_distance() function can be used for this purpose.
	There is a RECLAIM_DISTANCE macro that can be set by the
	architecture to prevent reclaiming from nodes that are too
	far away.  Some experimentation would be required to determine
	the combination of values for the various distance macros.

	This approach needs some way to pull in data from the hardware
	on access patterns.  Aneesh Kk Veetil is prototyping an approach
	based on Power 8 hardware counters.  This data will need to be
	plugged into the migration algorithm, which is currently based
	on collecting information from page faults.

	Finally, the contiguous memory allocator (CMA, see
	http://lwn.net/Articles/486301/) is needed in order to prevent
	the kernel from placing non-migratable allocations in the CCAD
	device's memory.  This would need to be of type MIGRATE_CMA to
	ensure that all memory taken from that range be migratable.

	The result would be that the kernel would allocate only migratable
	pages within the CCAD device's memory, and even then only if
	memory was otherwise exhausted.  Normal CONFIG_NUMA_BALANCING
	migration could be brought to bear, possibly enhanced with
	information from hardware counters.  One remaining issue is that
	there is no way to absolutely prevent random kernel subsystems
	from allocating the CCAD device's memory, which could cause
	failures should the device need to reset itself, in which case
	the memory would be temporarily inaccessible -- which could be
	a fatal surprise to that kernel subsystem.

	Jerome Glisse suggests that usermode hints are quite important,
	and perhaps should replace any AutoNUMA measurements.


MEMORY ZONE

	One way to avoid the problem of random kernel subsystems using
	the CAPI device's memory is to create a new memory zone for
	this purpose.  This would add something like ZONE_DEVMEM to the
	current set that includes ZONE_DMA, ZONE_NORMAL, and ZONE_MOVABLE.
	Currently, there are a maximum of four zones, so this limit must
	either be increased or kernels built with ZONE_DEVMEM must avoid
	having more than one of ZONE_DMA, ZONE_DMA32, and ZONE_HIGHMEM.

	This approach requires that migration be implemented on the side,
	as the CONFIG_NUMA_BALANCING will not help here (unless I am
	missing something).  One advantage of this situation is that
	hardware locality measurements could be incorporated from the
	beginning.  Another advantage is that random kernel subsystems
	and user programs would not get CAPI device memory unless they
	explicitly requested it.

	Code would be needed at boot time to place the CAPI device
	memory into ZONE_DEVMEM, perhaps involving changes to
	mem_init() and paging_init().

	In addition, an appropriate GFP_DEVMEM would be needed, along
	with code in various paths to handle it appropriately.

	Also, because large NUMA systems will sometimes interleave the
	addresses of blocks of physical memory and device memory,
	support for discontiguous interleaved zones will be required.


DAX

	DAX is a mechanism for providing direct-memory access to
	high-speed non-volatile (AKA "persistent") memory.  Good
	introductions to DAX may be found in the following LWN
	articles:

		https://lwn.net/Articles/591779/
		https://lwn.net/Articles/610174/

	DAX provides filesystem-level access to persistent memory.
	One important CCAD use case is allowing a legacy application
	to pass memory from malloc() to a CCAD device, and having
	the allocated memory migrate as needed.  DAX does not seem to
	support this use case.


ACKNOWLEDGMENTS

	Updates to this document include feedback from Christoph Lameter
	and Jerome Glisse.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
