Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 58BA78E00AC
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 18:21:53 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id l9so4955458plt.7
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 15:21:53 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id l81si23166521pfj.230.2019.01.24.15.21.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jan 2019 15:21:51 -0800 (PST)
Subject: [PATCH 0/5] [v4] Allow persistent memory to be used like normal RAM
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Thu, 24 Jan 2019 15:14:41 -0800
Message-Id: <20190124231441.37A4A305@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, dan.j.williams@intel.com, dave.jiang@intel.com, zwisler@kernel.org, vishal.l.verma@intel.com, thomas.lendacky@amd.com, akpm@linux-foundation.org, mhocko@suse.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, ying.huang@intel.com, fengguang.wu@intel.com, bp@suse.de, bhelgaas@google.com, baiyaowei@cmss.chinamobile.com, tiwai@suse.de, jglisse@redhat.com

v3 spurred a bunch of really good discussion.  Thanks to everybody
that made comments and suggestions!

I would still love some Acks on this from the folks on cc, even if it
is on just the patch touching your area.

Note: these are based on commit d2f33c19644 in:

	git://git.kernel.org/pub/scm/linux/kernel/git/djbw/nvdimm.git libnvdimm-pending

Changes since v3:
 * Move HMM-related resource warning instead of removing it
 * Use __request_resource() directly instead of devm.
 * Create a separate DAX_PMEM Kconfig option, complete with help text
 * Update patch descriptions and cover letter to give a better
   overview of use-cases and hardware where this might be useful.

Changes since v2:
 * Updates to dev_dax_kmem_probe() in patch 5:
   * Reject probes for devices with bad NUMA nodes.  Keeps slow
     memory from being added to node 0.
   * Use raw request_mem_region()
   * Add comments about permanent reservation
   * use dev_*() instead of printk's
 * Add references to nvdimm documentation in descriptions
 * Remove unneeded GPL export
 * Add Kconfig prompt and help text

Changes since v1:
 * Now based on git://git.kernel.org/pub/scm/linux/kernel/git/djbw/nvdimm.git
 * Use binding/unbinding from "dax bus" code
 * Move over to a "dax bus" driver from being an nvdimm driver

--

Persistent memory is cool.  But, currently, you have to rewrite
your applications to use it.  Wouldn't it be cool if you could
just have it show up in your system like normal RAM and get to
it like a slow blob of memory?  Well... have I got the patch
series for you!

== Background / Use Cases ==

Persistent Memory (aka Non-Volatile DIMMs / NVDIMMS) themselves
are described in detail in Documentation/nvdimm/nvdimm.txt.
However, this documentation focuses on actually using them as
storage.  This set is focused on using NVDIMMs as DRAM replacement.

This is intended for Intel-style NVDIMMs (aka. Intel Optane DC
persistent memory) NVDIMMs.  These DIMMs are physically persistent,
more akin to flash than traditional RAM.  They are also expected to
be more cost-effective than using RAM, which is why folks want this
set in the first place.

This set is not intended for RAM-based NVDIMMs.  Those are not
cost-effective vs. plain RAM, and this using them here would simply
be a waste.

But, why would you bother with this approach?  Intel itself [1]
has announced a hardware feature that does something very similar:
"Memory Mode" which turns DRAM into a cache in front of persistent
memory, which is then as a whole used as normal "RAM"?

Here are a few reasons:
1. The capacity of memory mode is the size of your persistent
   memory that you dedicate.  DRAM capacity is "lost" because it
   is used for cache.  With this, you get PMEM+DRAM capacity for
   memory.
2. DRAM acts as a cache with memory mode, and caches can lead to
   unpredictable latencies.  Since memory mode is all-or-nothing
   (either all your DRAM is used as cache or none is), your entire
   memory space is exposed to these unpredictable latencies.  This
   solution lets you guarantee DRAM latencies if you need them.
3. The new "tier" of memory is exposed to software.  That means
   that you can build tiered applications or infrastructure.  A
   cloud provider could sell cheaper VMs that use more PMEM and
   more expensive ones that use DRAM.  That's impossible with
   memory mode.

Don't take this as criticism of memory mode.  Memory mode is
awesome, and doesn't strictly require *any* software changes (we
have software changes proposed for optimizing it though).  It has
tons of other advantages over *this* approach.  Basically, we
believe that the approach in these patches is complementary to
memory mode and that both can live side-by-side in harmony.

== Patch Set Overview ==

This series adds a new "driver" to which pmem devices can be
attached.  Once attached, the memory "owned" by the device is
hot-added to the kernel and managed like any other memory.  On
systems with an HMAT (a new ACPI table), each socket (roughly)
will have a separate NUMA node for its persistent memory so
this newly-added memory can be selected by its unique NUMA
node.

== Testing Overview ==

Here's how I set up a system to test this thing:

1. Boot qemu with lots of memory: "-m 4096", for instance
2. Reserve 512MB of physical memory.  Reserving a spot a 2GB
   physical seems to work: memmap=512M!0x0000000080000000
   This will end up looking like a pmem device at boot.
3. When booted, convert fsdax device to "device dax":
	ndctl create-namespace -fe namespace0.0 -m dax
4. See patch 4 for instructions on binding the kmem driver
   to a device.
5. Now, online the new memory sections.  Perhaps:

grep ^MemTotal /proc/meminfo
for f in `grep -vl online /sys/devices/system/memory/*/state`; do
	echo $f: `cat $f`
	echo online_movable > $f
	grep ^MemTotal /proc/meminfo
done

1. https://itpeernetwork.intel.com/intel-optane-dc-persistent-memory-operating-modes/#gs.RKG7BeIu

Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Jiang <dave.jiang@intel.com>
Cc: Ross Zwisler <zwisler@kernel.org>
Cc: Vishal Verma <vishal.l.verma@intel.com>
Cc: Tom Lendacky <thomas.lendacky@amd.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: linux-nvdimm@lists.01.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: Huang Ying <ying.huang@intel.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>
Cc: Borislav Petkov <bp@suse.de>
Cc: Bjorn Helgaas <bhelgaas@google.com>
Cc: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Cc: Takashi Iwai <tiwai@suse.de>
Cc: Jerome Glisse <jglisse@redhat.com>
