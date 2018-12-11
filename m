Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 13DBF8E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 01:45:15 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id a10so9969776plp.14
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 22:45:15 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id y73si10860891pgd.478.2018.12.10.22.45.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 22:45:13 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wBB6hVLr108031
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 01:45:12 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2pa79wa16f-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 01:45:12 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 11 Dec 2018 06:45:10 -0000
Date: Tue, 11 Dec 2018 08:45:03 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCHv2 12/12] doc/mm: New documentation for memory performance
References: <20181211010310.8551-1-keith.busch@intel.com>
 <20181211010310.8551-13-keith.busch@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181211010310.8551-13-keith.busch@intel.com>
Message-Id: <20181211064502.GB3302@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

Hi Keith,

Thanks for the docs! :)
Some nits below...

On Mon, Dec 10, 2018 at 06:03:10PM -0700, Keith Busch wrote:
> Platforms may provide system memory where some physical address ranges
> perform differently than others, or is side cached by the system.
> 
> Add documentation describing a high level overview of such systems and the
> performance and caching attributes the kernel provides for applications
> wishing to query this information.
> 
> Signed-off-by: Keith Busch <keith.busch@intel.com>
> ---
>  Documentation/admin-guide/mm/numaperf.rst | 171 ++++++++++++++++++++++++++++++
>  1 file changed, 171 insertions(+)
>  create mode 100644 Documentation/admin-guide/mm/numaperf.rst
> 
> diff --git a/Documentation/admin-guide/mm/numaperf.rst b/Documentation/admin-guide/mm/numaperf.rst
> new file mode 100644
> index 000000000000..846b3f991e7f
> --- /dev/null
> +++ b/Documentation/admin-guide/mm/numaperf.rst
> @@ -0,0 +1,171 @@
> +.. _numaperf:
> +
> +=============
> +NUMA Locality
> +=============
> +
> +Some platforms may have multiple types of memory attached to a single
> +CPU. These disparate memory ranges share some characteristics, such as
> +CPU cache coherence, but may have different performance. For example,
> +different media types and buses affect bandwidth and latency.
> +
> +A system supporting such heterogeneous memory by grouping each memory

Maybe "A system supports ..."?

> +type under different "nodes" based on similar CPU locality and performance
> +characteristics.  Some memory may share the same node as a CPU, and others
> +are provided as memory only nodes. While memory only nodes do not provide
> +CPUs, they may still be directly accessible, or local, to one or more
> +compute nodes. The following diagram shows one such example of two compute
> +noes with local memory and a memory only node for each of compute node:

                                                ^ attached to each ?
> +
> + +------------------+     +------------------+
> + | Compute Node 0   +-----+ Compute Node 1   |
> + | Local Node0 Mem  |     | Local Node1 Mem  |
> + +--------+---------+     +--------+---------+
> +          |                        |
> + +--------+---------+     +--------+---------+
> + | Slower Node2 Mem |     | Slower Node3 Mem |
> + +------------------+     +--------+---------+
> +
> +A "memory initiator" is a node containing one or more devices such as
> +CPUs or separate memory I/O devices that can initiate memory requests. A
> +"memory target" is a node containing one or more accessible physical
> +address ranges from one or more memory initiators.

Maybe "... one or more address ranges accessible from one or more memory
initiators"

> +
> +When multiple memory initiators exist, they may not all have the same
> +performance when accessing a given memory target. The highest performing
> +initiator to a given target is considered to be one of that target's
> +local initiators. Any given target may have one or more local initiators,
> +and any given initiator may have multiple local memory targets.
> +
> +To aid applications matching memory targets with their initiators,
> +the kernel provide symlinks to each other like the following example::

            ^ provides
> +
> +	# ls -l /sys/devices/system/node/nodeX/local_target*
> +	/sys/devices/system/node/nodeX/local_targetY -> ../nodeY
> +
> +	# ls -l /sys/devices/system/node/nodeY/local_initiator*
> +	/sys/devices/system/node/nodeY/local_initiatorX -> ../nodeX
> +
> +The linked nodes will also have their node number set in the local_mem
> +and local_cpu node list and maps.
> +
> +An example showing how this may be used to run a particular task on CPUs
> +and memory that are both local to a particular PCI device can be done
> +using existing 'numactl' as follows::
> +
> +  # NODE=$(cat /sys/devices/pci:0000:00/.../numa_node)
> +  # numactl --membind=$(cat /sys/devices/node/node${NODE}/local_mem_nodelist) \
> +      --cpunodebind=$(cat /sys/devices/node/node${NODE}/local_cpu_nodelist) \
> +      -- <some-program-to-execute>
> +
> +================
> +NUMA Performance
> +================
> +
> +Applications may wish to consider which node they want their memory to
> +be allocated from based on the node's performance characteristics. If the
> +system provides these attributes, the kernel exports them under the node
> +sysfs hierarchy by appending the local_initiator_access directory under
> +the memory node as follows::
> +
> +	/sys/devices/system/node/nodeY/local_initiator_access/
> +
> +The kernel does not provide performance attributes for non-local memory
> +initiators. These attributes apply only to the memory initiator nodes that
> +have a local_initiatorX link, or are set in the local_cpu_nodelist. A
> +memory initiator node is considered local to itself if it also is
> +a memory target and will be set it its node list and map, but won't
> +contain a symlink to itself.
> +
> +The performance characteristics the kernel provides for the local initiators
> +are exported are as follows::
> +
> +	# tree /sys/devices/system/node/nodeY/local_initiator_access
> +	/sys/devices/system/node/nodeY/local_initiator_access
> +	|-- read_bandwidth
> +	|-- read_latency
> +	|-- write_bandwidth
> +	`-- write_latency
> +
> +The bandwidth attributes are provided in MiB/second.
> +
> +The latency attributes are provided in nanoseconds.
> +
> +==========
> +NUMA Cache
> +==========
> +
> +System memory may be constructed in a hierarchy of elements with various
> +performance characteristics in order to provide large address space
> +of slower performing memory side-cached by a smaller higher performing
> +memory. The system physical addresses that initiators are aware of is
> +provided by the last memory level in the hierarchy, while the system uses
> +higher performing memory to transparently cache access to progressively
> +slower levels.
> +
> +The term "far memory" is used to denote the last level memory in the
> +hierarchy. Each increasing cache level provides higher performing
> +initiator access, and the term "near memory" represents the fastest
> +cache provided by the system.
> +
> +This numbering is different than CPU caches where the cache level (ex:
> +L1, L2, L3) uses a CPU centric view with each increased level is lower
> +performing. In contrast, the memory cache level is centric to the last
> +level memory, so the higher numbered cache level denotes memory nearer
> +to the CPU, and further from far memory.
> +
> +The memory side caches are not directly addressable by software. When
> +software accesses a system address, the system will return it from the

                                                      ^ satisfy the request

> +near memory cache if it is present. If it is not present, the system
> +accesses the next level of memory until there is either a hit in that
> +cache level, or it reaches far memory.
> +
> +An application does not need to know about caching attributes in order
> +to use the system, software may optionally query the memory cache
> +attributes in order to maximize the performance out of such a setup.
> +If the system provides a way for the kernel to discover this information,
> +for example with ACPI HMAT (Heterogeneous Memory Attribute Table),
> +the kernel will append these attributes to the NUMA node memory target.
> +
> +When the kernel first registers a memory cache with a node, the kernel
> +will create the following directory::
> +
> +	/sys/devices/system/node/nodeX/side_cache/
> +
> +If that directory is not present, the system either does not not provide
> +a memory side cache, or that information is not accessible to the kernel.
> +
> +The attributes for each level of cache is provided under its cache
> +level index::
> +
> +	/sys/devices/system/node/nodeX/side_cache/indexA/
> +	/sys/devices/system/node/nodeX/side_cache/indexB/
> +	/sys/devices/system/node/nodeX/side_cache/indexC/
> +
> +Each cache level's directory provides its attributes. For example,
> +the following is a single cache level and the attributes available for
> +software to query::
> +
> +	# tree sys/devices/system/node/node0/side_cache/
> +	/sys/devices/system/node/node0/side_cache/
> +	|-- index1
> +	|   |-- associativity
> +	|   |-- level
> +	|   |-- line_size
> +	|   |-- size
> +	|   `-- write_policy
> +
> +The "associativity" will be 0 if it is a direct-mapped cache, and non-zero
> +for any other indexed based, multi-way associativity.
> +
> +The "level" is the distance from the far memory, and matches the number
> +appended to its "index" directory.
> +
> +The "line_size" is the number of bytes accessed on a cache miss.
> +
> +The "size" is the number of bytes provided by this cache level.
> +
> +The "write_policy" will be 0 for write-back, and non-zero for
> +write-through caching.
> +
> +See also: https://www.uefi.org/sites/default/files/resources/ACPI_6_2.pdf

I'd suggest to reference relevant sections rather than entire 1K pages doc ;-)

> -- 
> 2.14.4
> 

-- 
Sincerely yours,
Mike.
