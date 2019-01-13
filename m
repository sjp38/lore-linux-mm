Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id D3C048E0002
	for <linux-mm@kvack.org>; Sun, 13 Jan 2019 06:42:43 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id a2so11150987pgt.11
        for <linux-mm@kvack.org>; Sun, 13 Jan 2019 03:42:43 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id a13si20797596pgb.412.2019.01.13.03.42.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 13 Jan 2019 03:42:41 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id x0DBY9ig072009
	for <linux-mm@kvack.org>; Sun, 13 Jan 2019 06:42:40 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2pyxb3sbag-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 13 Jan 2019 06:42:40 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Sun, 13 Jan 2019 11:42:38 -0000
Date: Sun, 13 Jan 2019 13:42:30 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCHv3 13/13] doc/mm: New documentation for memory performance
References: <20190109174341.19818-1-keith.busch@intel.com>
 <20190109174341.19818-14-keith.busch@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190109174341.19818-14-keith.busch@intel.com>
Message-Id: <20190113114230.GB8765@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

Hi Keith,

On Wed, Jan 09, 2019 at 10:43:41AM -0700, Keith Busch wrote:
> Platforms may provide system memory where some physical address ranges
> perform differently than others, or is side cached by the system.
> 
> Add documentation describing a high level overview of such systems and the
> perforamnce and caching attributes the kernel provides for applications
> wishing to query this information.
> 
> Signed-off-by: Keith Busch <keith.busch@intel.com>

There are a couple of nitpicks below, otherwise

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

> ---
>  Documentation/admin-guide/mm/numaperf.rst | 184 ++++++++++++++++++++++++++++++
>  1 file changed, 184 insertions(+)
>  create mode 100644 Documentation/admin-guide/mm/numaperf.rst
> 
> diff --git a/Documentation/admin-guide/mm/numaperf.rst b/Documentation/admin-guide/mm/numaperf.rst
> new file mode 100644
> index 000000000000..b6d99d7e0f57
> --- /dev/null
> +++ b/Documentation/admin-guide/mm/numaperf.rst
> @@ -0,0 +1,184 @@
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
> +type under different "nodes" based on similar CPU locality and performance
> +characteristics.  Some memory may share the same node as a CPU, and others
> +are provided as memory only nodes. While memory only nodes do not provide
> +CPUs, they may still be directly accessible, or local, to one or more
> +compute nodes. The following diagram shows one such example of two compute
> +noes with local memory and a memory only node for each of compute node:

   nodes

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

I'd rephrase the last sentence as:

A "memory target" is a node containing one or more physical address ranges
accessible from one or more memory initiators.

> +
> +When multiple memory initiators exist, they may not all have the same
> +performance when accessing a given memory target. Each initiator-target
> +pair may be organized into different ranked access classes to represent
> +this relationship. The highest performing initiator to a given target
> +is considered to be one of that target's local initiators, and given
> +the highest access class, 0. Any given target may have one or more
> +local initiators, and any given initiator may have multiple local
> +memory targets.
> +
> +To aid applications matching memory targets with their initiators, the
> +kernel provide symlinks to each other. The following example lists the

         ^ provides

> +relationship for the class "0" memory intiators and targets, which is
> +are the class of nodes with the highest performing access relationship::

  ^ "are" is excessive here

> +
> +	# symlinks -v /sys/devices/system/node/nodeX/class0/
> +	relative: /sys/devices/system/node/nodeX/class0/targetY -> ../../nodeY
> +
> +	# symlinks -v /sys/devices/system/node/nodeY/class0/
> +	relative: /sys/devices/system/node/nodeY/class0/initiatorX -> ../../nodeX
> +
> +The linked nodes will also have their node numbers set in the class's
> +mem_target and mem_initiator nodelist and nodemap entries. Following
> +the same example as above may look like the following::
> +
> +	# cat /sys/devices/system/node/nodeX/class0/target_nodelist
> +	Y
> +
> +	# cat /sys/devices/system/node/nodeY/class0/initiator_nodelist
> +	X
> +
> +An example showing how this may be used to run a particular task on CPUs
> +and memory using best class nodes for a particular PCI device can be done
> +using existing 'numactl' as follows::
> +
> +  # NODE=$(cat /sys/devices/pci:0000:00/.../numa_node)
> +  # numactl --membind=$(cat /sys/devices/node/node${NODE}/class0/target_nodelist) \
> +      --cpunodebind=$(cat /sys/devices/node/node${NODE}/class0/initiator_nodelist) \
> +      -- <some-program-to-execute>
> +
> +================
> +NUMA Performance
> +================
> +
> +Applications may wish to consider which node they want their memory to
> +be allocated from based on the node's performance characteristics. If
> +the system provides these attributes, the kernel exports them under the
> +node sysfs hierarchy by appending the attributes directory under the
> +memory node's class 0 initiators as follows::
> +
> +	/sys/devices/system/node/nodeY/class0/
> +
> +These attributes apply only to the memory initiator nodes that have the
> +same class access and are symlink under the class, and are set in the
> +initiators' nodelist.
> +
> +The performance characteristics the kernel provides for the local initiators
> +are exported are as follows::
> +
> +	# tree -P "read*|write*" /sys/devices/system/node/nodeY/class0/
> +	/sys/devices/system/node/nodeY/class0/
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
> +performance characteristics in order to provide large address space of
> +slower performing memory side-cached by a smaller higher performing
> +memory. The system physical addresses that initiators are aware of
> +is provided by the last memory level in the hierarchy. The system

   ^ are

> +meanwhile uses higher performing memory to transparently cache access
> +to progressively slower levels.
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
> +near memory cache if it is present. If it is not present, the system
> +accesses the next level of memory until there is either a hit in that
> +cache level, or it reaches far memory.
> +
> +An application does not need to know about caching attributes in order
> +to use the system. Software may optionally query the memory cache
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
> +Each cache level's directory provides its attributes. For example, the
> +following shows a single cache level and the attributes available for
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
> +========
> +See Also
> +========
> +.. [1] https://www.uefi.org/sites/default/files/resources/ACPI_6_2.pdf
> +       Section 5.2.27
> -- 
> 2.14.4
> 

-- 
Sincerely yours,
Mike.
