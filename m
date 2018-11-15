Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id CA10B6B02F7
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 08:00:00 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id l200-v6so23505667ita.3
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 05:00:00 -0800 (PST)
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id z129-v6si15699023itd.109.2018.11.15.04.59.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 04:59:59 -0800 (PST)
Date: Thu, 15 Nov 2018 12:59:09 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
Subject: Re: [PATCH 3/7] doc/vm: New documentation for memory performance
Message-ID: <20181115125909.000067aa@huawei.com>
In-Reply-To: <20181114224921.12123-4-keith.busch@intel.com>
References: <20181114224921.12123-2-keith.busch@intel.com>
	<20181114224921.12123-4-keith.busch@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Wed, 14 Nov 2018 15:49:16 -0700
Keith Busch <keith.busch@intel.com> wrote:

> Platforms may provide system memory where some physical address ranges
> perform differently than others. These heterogeneous memory attributes are
> common to the node that provides the memory and exported by the kernel.
> 
> Add new documentation providing a brief overview of such systems and
> the attributes the kernel makes available to aid applications wishing
> to query this information.
> 
> Signed-off-by: Keith Busch <keith.busch@intel.com>
Hi Keith,

Good to see another attempt at this, particularly thinking about simplifying
what is provided to make it easier to use.

I need to have a bit of a think about how this maps onto more complex
topologies, but some initial comments / questions in the meantime.

> ---
>  Documentation/vm/numaperf.rst | 71 +++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 71 insertions(+)
>  create mode 100644 Documentation/vm/numaperf.rst
> 
> diff --git a/Documentation/vm/numaperf.rst b/Documentation/vm/numaperf.rst
> new file mode 100644
> index 000000000000..5a3ecaff5474
> --- /dev/null
> +++ b/Documentation/vm/numaperf.rst
> @@ -0,0 +1,71 @@
> +.. _numaperf:
> +
> +================
> +NUMA Performance
> +================
> +
> +Some platforms may have multiple types of memory attached to a single
> +CPU. These disparate memory ranges share some characteristics, such as
> +CPU cache coherence, but may have different performance. For example,
> +different media types and buses affect bandwidth and latency.
> +
> +A system supporting such heterogeneous memory groups each memory type
> +under different "nodes" based on similar CPU locality and performance
> +characteristics.

I think this statement should be more specific.  The requirement is that
it should have similar CPU locality and performance characteristics wrt
to every initiator in the system, not just the local one.

>  Some memory may share the same node as a CPU, and
> +others are provided as memory-only nodes. While memory only nodes do not
> +provide CPUs, they may still be local to one or more compute nodes. The
> +following diagram shows one such example of two compute noes with local
> +memory and a memory only node for each of compute node:
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
> +"memory target" is a node containing one or more CPU-accessible physical
> +address ranges.
> +
> +When multiple memory initiators exist, accessing the same memory
> +target may not perform the same as each other. 

When multiple initiators exist, they may not all show the same performance
when accessing a given memory target.

> The highest performing
> +initiator to a given target is considered to be one of that target's
> +local initiators.

One of, or the only?   Are we allowing a many to one mapping if several
initiators have the same performance but are in different nodes?

Also, what is your measure of performance, latency or bandwidth or some
combination of the two?

> +
> +To aid applications matching memory targets with their initiators,
> +the kernel provide symlinks to each other like the following example::
> +
> +	# ls -l /sys/devices/system/node/nodeX/initiator*
> +	/sys/devices/system/node/nodeX/targetY -> ../nodeY
ls on initiator* is giving targetY?

> +
> +	# ls -l /sys/devices/system/node/nodeY/target*
> +	/sys/devices/system/node/nodeY/initiatorX -> ../nodeX
> +

Just to check as I'm not clear, do we have self links when the 
memory and initiators are in the same node?

> +Applications may wish to consider which node they want their memory to
> +be allocated from based on the nodes performance characteristics. If
> +the system provides these attributes, the kernel exports them under the
> +node sysfs hierarchy by appending the initiator_access directory under
> +the node as follows::
> +
> +	/sys/devices/system/node/nodeY/initiator_access/
> +
> +The kernel does not provide performance attributes for non-local memory
> +initiators. The performance characteristics the kernel provides for
> +the local initiators are exported are as follows::
> +
> +	# tree /sys/devices/system/node/nodeY/initiator_access
> +	/sys/devices/system/node/nodeY/initiator_access
> +	|-- read_bandwidth
> +	|-- read_latency
> +	|-- write_bandwidth
> +	`-- write_latency
> +
> +The bandwidth attributes are provided in MiB/second.
> +
> +The latency attributes are provided in nanoseconds.
> +
> +See also: https://www.uefi.org/sites/default/files/resources/ACPI_6_2.pdf

My worry here is we are explicitly making an interface that is only ever
providing "local" node information, where local node is not the best
defined thing in the world for complex topologies.

I have no problem with that making a sensible starting point for providing
information userspace knows what to do with, just with an interface that
in of itself doesn't make that clear.

Perhaps something as simple as
/sys/devices/system/nodeY/local_initiatorX
/sys/devices/system/nodeX/local_targetY

That leaves us the option of coming along later and having a full listing
when a userspace requirement has become clear.  Another option would
be an exhaustive list of all initiator / memory pairs that exist, with
an additional sysfs file giving a list of those that are nearest
to avoid every userspace program having to do the search.

Thanks,

Jonathan
