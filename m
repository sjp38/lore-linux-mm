Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 27C496B0279
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 17:52:45 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id t75so15457482pgb.0
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 14:52:45 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id r9si736092pfe.5.2017.07.06.14.52.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jul 2017 14:52:43 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [RFC v2 0/5] surface heterogeneous memory performance information
Date: Thu,  6 Jul 2017 15:52:28 -0600
Message-Id: <20170706215233.11329-1-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>, "Box, David E" <david.e.box@intel.com>, "Kogut, Jaroslaw" <Jaroslaw.Kogut@intel.com>, "Lahtinen, Joonas" <joonas.lahtinen@intel.com>, "Moore, Robert" <robert.moore@intel.com>, "Nachimuthu, Murugasamy" <murugasamy.nachimuthu@intel.com>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "Schmauss, Erik" <erik.schmauss@intel.com>, "Verma, Vishal L" <vishal.l.verma@intel.com>, "Zheng, Lv" <lv.zheng@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jerome Glisse <jglisse@redhat.com>, Len Brown <lenb@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, devel@acpica.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

==== Quick Summary ====

Platforms in the very near future will have multiple types of memory
attached to a single CPU.  These disparate memory ranges will have some
characteristics in common, such as CPU cache coherence, but they can have
wide ranges of performance both in terms of latency and bandwidth.

For example, consider a system that contains persistent memory, standard
DDR memory and High Bandwidth Memory (HBM), all attached to the same CPU.
There could potentially be an order of magnitude or more difference in
performance between the slowest and fastest memory attached to that CPU.

With the current Linux code NUMA nodes are CPU-centric, so all the memory
attached to a given CPU will be lumped into the same NUMA node.  This makes
it very difficult for userspace applications to understand the performance
of different memory ranges on a given CPU.

We solve this issue by providing userspace with performance information on
individual memory ranges.  This performance information is exposed via
sysfs:

  # grep . mem_tgt2/* mem_tgt2/local_init/* 2>/dev/null
  mem_tgt2/firmware_id:1
  mem_tgt2/is_cached:0
  mem_tgt2/is_enabled:1
  mem_tgt2/is_isolated:0
  mem_tgt2/phys_addr_base:0x0
  mem_tgt2/phys_length_bytes:0x800000000
  mem_tgt2/local_init/read_bw_MBps:30720
  mem_tgt2/local_init/read_lat_nsec:100
  mem_tgt2/local_init/write_bw_MBps:30720
  mem_tgt2/local_init/write_lat_nsec:100

This allows applications to easily find the memory that they want to use.
We expect that the existing NUMA APIs will be enhanced to use this new
information so that applications can continue to use them to select their
desired memory.

This series is built upon acpica-1705:

https://github.com/zetalog/linux/commits/acpica-1705

And you can find a working tree here:

https://git.kernel.org/pub/scm/linux/kernel/git/zwisler/linux.git/log/?h=hmem_sysfs

==== Lots of Details ====

This patch set is only concerned with CPU-addressable memory types, not
on-device memory like what we have with Jerome Glisse's HMM series:

https://lwn.net/Articles/726691/

This patch set works by enabling the new Heterogeneous Memory Attribute
Table (HMAT) table, newly defined in ACPI 6.2. One major conceptual change
in ACPI 6.2 related to this work is that proximity domains no longer need
to contain a processor.  We can now have memory-only proximity domains,
which means that we can now have memory-only Linux NUMA nodes.

Here is an example configuration where we have a single processor, one
range of regular memory and one range of HBM:

  +---------------+   +----------------+
  | Processor     |   | Memory         |
  | prox domain 0 +---+ prox domain 1  |
  | NUMA node 1   |   | NUMA node 2    |
  +-------+-------+   +----------------+
          |
  +-------+----------+
  | HBM              |
  | prox domain 2    |
  | NUMA node 0      |
  +------------------+

This gives us one initiator (the processor) and two targets (the two memory
ranges).  Each of these three has its own ACPI proximity domain and
associated Linux NUMA node.  Note also that while there is a 1:1 mapping
from each proximity domain to each NUMA node, the numbers don't necessarily
match up.  Additionally we can have extra NUMA nodes that don't map back to
ACPI proximity domains.

The above configuration could also have the processor and one of the two
memory ranges sharing a proximity domain and NUMA node, but for the
purposes of the HMAT the two memory ranges will always need to be
separated.

The overall goal of this series and of the HMAT is to allow users to
identify memory using its performance characteristics.  This can broadly be
done in one of two ways:

Option 1: Provide the user with a way to map between proximity domains and
NUMA nodes and a way to access the HMAT directly (probably via
/sys/firmware/acpi/tables).  Then, through possibly a library and a daemon,
provide an API so that applications can either request information about
memory ranges, or request memory allocations that meet a given set of
performance characteristics.

Option 2: Provide the user with HMAT performance data directly in sysfs,
allowing applications to directly access it without the need for the
library and daemon.

The kernel work for option 1 is started by patches 1-3.  These just surface
the minimal amount of information in sysfs to allow userspace to map
between proximity domains and NUMA nodes so that the raw data in the HMAT
table can be understood.

Patches 4 and 5 enable option 2, adding performance information from the
HMAT to sysfs.  The second option is complicated by the amount of HMAT data
that could be present in very large systems, so in this series we only
surface performance information for local (initiator,target) pairings.  The
changelog for patch 5 discusses this in detail.

The naming collision between Jerome's "Heterogeneous Memory Management
(HMM)" and this "Heterogeneous Memory (HMEM)" series is unfortunate, but I
was trying to stick with the word "Heterogeneous" because of the naming of
the ACPI 6.2 Heterogeneous Memory Attribute Table table.  Suggestions for
better naming are welcome.

==== Next steps ====

There is still a lot of work to be done on this series, but the overall
goal of this RFC is to gather feedback on which of the two options we
should pursue, or whether some third option is preferred.  After that is
done and we have a solid direction we can add support for ACPI hot add,
test more complex configurations, etc.

So, for applications that need to differentiate between memory ranges based
on their performance, what option would work best for you?  Is the local
(initiator,target) performance provided by patch 5 enough, or do you
require performance information for all possible (initiator,target)
pairings?

If option 1 looks best, do we have ideas on what the userspace API would
look like?

What other things should we consider, or what needs do you have that aren't
being addressed?

---
Changes from previous RFC (https://lwn.net/Articles/724562/):

 - Allow multiple initiators to be local to a given memory target, as long
   as they all have the same performance characteristics. (Dan Williams)

 - A few small fixes to the ACPI parsing to allow for configurations I
   hadn't previously considered.

Ross Zwisler (5):
  acpi: add missing include in acpi_numa.h
  acpi: HMAT support in acpi_parse_entries_array()
  hmem: add heterogeneous memory sysfs support
  sysfs: add sysfs_add_group_link()
  hmem: add performance attributes

 MAINTAINERS                         |   5 +
 drivers/acpi/Kconfig                |   1 +
 drivers/acpi/Makefile               |   1 +
 drivers/acpi/hmem/Kconfig           |   7 +
 drivers/acpi/hmem/Makefile          |   2 +
 drivers/acpi/hmem/core.c            | 835 ++++++++++++++++++++++++++++++++++++
 drivers/acpi/hmem/hmem.h            |  64 +++
 drivers/acpi/hmem/initiator.c       |  61 +++
 drivers/acpi/hmem/perf_attributes.c |  56 +++
 drivers/acpi/hmem/target.c          |  97 +++++
 drivers/acpi/numa.c                 |   2 +-
 drivers/acpi/tables.c               |  52 ++-
 fs/sysfs/group.c                    |  30 +-
 include/acpi/acpi_numa.h            |   1 +
 include/linux/sysfs.h               |   2 +
 15 files changed, 1197 insertions(+), 19 deletions(-)
 create mode 100644 drivers/acpi/hmem/Kconfig
 create mode 100644 drivers/acpi/hmem/Makefile
 create mode 100644 drivers/acpi/hmem/core.c
 create mode 100644 drivers/acpi/hmem/hmem.h
 create mode 100644 drivers/acpi/hmem/initiator.c
 create mode 100644 drivers/acpi/hmem/perf_attributes.c
 create mode 100644 drivers/acpi/hmem/target.c

-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
