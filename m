Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 90C0E6B0266
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 17:53:05 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id o23so1838015pll.0
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 14:53:05 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id l13-v6si29485562pls.222.2018.11.14.14.53.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 14:53:04 -0800 (PST)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCH 3/7] doc/vm: New documentation for memory performance
Date: Wed, 14 Nov 2018 15:49:16 -0700
Message-Id: <20181114224921.12123-4-keith.busch@intel.com>
In-Reply-To: <20181114224921.12123-2-keith.busch@intel.com>
References: <20181114224921.12123-2-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>

Platforms may provide system memory where some physical address ranges
perform differently than others. These heterogeneous memory attributes are
common to the node that provides the memory and exported by the kernel.

Add new documentation providing a brief overview of such systems and
the attributes the kernel makes available to aid applications wishing
to query this information.

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 Documentation/vm/numaperf.rst | 71 +++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 71 insertions(+)
 create mode 100644 Documentation/vm/numaperf.rst

diff --git a/Documentation/vm/numaperf.rst b/Documentation/vm/numaperf.rst
new file mode 100644
index 000000000000..5a3ecaff5474
--- /dev/null
+++ b/Documentation/vm/numaperf.rst
@@ -0,0 +1,71 @@
+.. _numaperf:
+
+================
+NUMA Performance
+================
+
+Some platforms may have multiple types of memory attached to a single
+CPU. These disparate memory ranges share some characteristics, such as
+CPU cache coherence, but may have different performance. For example,
+different media types and buses affect bandwidth and latency.
+
+A system supporting such heterogeneous memory groups each memory type
+under different "nodes" based on similar CPU locality and performance
+characteristics.  Some memory may share the same node as a CPU, and
+others are provided as memory-only nodes. While memory only nodes do not
+provide CPUs, they may still be local to one or more compute nodes. The
+following diagram shows one such example of two compute noes with local
+memory and a memory only node for each of compute node:
+
+ +------------------+     +------------------+
+ | Compute Node 0   +-----+ Compute Node 1   |
+ | Local Node0 Mem  |     | Local Node1 Mem  |
+ +--------+---------+     +--------+---------+
+          |                        |
+ +--------+---------+     +--------+---------+
+ | Slower Node2 Mem |     | Slower Node3 Mem |
+ +------------------+     +--------+---------+
+
+A "memory initiator" is a node containing one or more devices such as
+CPUs or separate memory I/O devices that can initiate memory requests. A
+"memory target" is a node containing one or more CPU-accessible physical
+address ranges.
+
+When multiple memory initiators exist, accessing the same memory
+target may not perform the same as each other. The highest performing
+initiator to a given target is considered to be one of that target's
+local initiators.
+
+To aid applications matching memory targets with their initiators,
+the kernel provide symlinks to each other like the following example::
+
+	# ls -l /sys/devices/system/node/nodeX/initiator*
+	/sys/devices/system/node/nodeX/targetY -> ../nodeY
+
+	# ls -l /sys/devices/system/node/nodeY/target*
+	/sys/devices/system/node/nodeY/initiatorX -> ../nodeX
+
+Applications may wish to consider which node they want their memory to
+be allocated from based on the nodes performance characteristics. If
+the system provides these attributes, the kernel exports them under the
+node sysfs hierarchy by appending the initiator_access directory under
+the node as follows::
+
+	/sys/devices/system/node/nodeY/initiator_access/
+
+The kernel does not provide performance attributes for non-local memory
+initiators. The performance characteristics the kernel provides for
+the local initiators are exported are as follows::
+
+	# tree /sys/devices/system/node/nodeY/initiator_access
+	/sys/devices/system/node/nodeY/initiator_access
+	|-- read_bandwidth
+	|-- read_latency
+	|-- write_bandwidth
+	`-- write_latency
+
+The bandwidth attributes are provided in MiB/second.
+
+The latency attributes are provided in nanoseconds.
+
+See also: https://www.uefi.org/sites/default/files/resources/ACPI_6_2.pdf
-- 
2.14.4
