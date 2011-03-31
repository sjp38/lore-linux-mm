Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 6EEBE8D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 10:20:05 -0400 (EDT)
From: "Zhang, Yang Z" <yang.z.zhang@intel.com>
Date: Thu, 31 Mar 2011 22:16:51 +0800
Subject: [PATCH 1/7,v10] NUMA Hotplug Emulator: Documentation
Message-ID: <749B9D3DBF0F054390025D9EAFF47F224A3D6C39@shsmsx501.ccr.corp.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "haicheng.li@linux.intel.com" <haicheng.li@linux.intel.com>, "lethal@linux-sh.org" <lethal@linux-sh.org>, "Kleen, Andi" <andi.kleen@intel.com>, "dave@linux.vnet.ibm.com" <dave@linux.vnet.ibm.com>, "gregkh@suse.de" <gregkh@suse.de>, "mingo@elte.hu" <mingo@elte.hu>, "lenb@kernel.org" <lenb@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "yinghai@kernel.org" <yinghai@kernel.org>, "Li, Xin" <xin.li@intel.com>

add a text file Documentation/x86/x86_64/numa_hotplug_emulator.txt
to explain the usage for the hotplug emulator.

Reviewed-By: Randy Dunlap <randy.dunlap@oracle.com>
Signed-off-by: David Rientjes <rientjes@google.com>
Signed-off-by: Haicheng Li <haicheng.li@intel.com>
Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
Signed-off-by: Yang Zhang <yang.z.zhang@intel.com>
---
 Documentation/x86/x86_64/numa_hotplug_emulator.txt |  102 ++++++++++++++++=
++++
 1 files changed, 102 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/x86/x86_64/numa_hotplug_emulator.txt

diff --git a/Documentation/x86/x86_64/numa_hotplug_emulator.txt linux-hpe4/=
Documentation/x86/x86_64/numa_hotplug_emulator.txt
new file mode 100644
index 0000000..ca7cc42
--- /dev/null
+++ linux-hpe4/Documentation/x86/x86_64/numa_hotplug_emulator.txt
@@ -0,0 +1,102 @@
+NUMA Hotplug Emulator for x86_64
+---------------------------------------------------
+
+NUMA hotplug emulator is able to emulate NUMA Node Hotplug
+thru a pure software way. It intends to help people easily debug
+and test node/CPU/memory hotplug related stuff on a
+none-NUMA-hotplug-support machine, even a UMA machine and virtual
+environment.
+
+1) Node hotplug emulation:
+
+Adds a numa=3Dpossible=3D<N> command line option to set an additional N no=
des
+as being possible for memory hotplug.  This set of possible nodes
+control nr_node_ids and the sizes of several dynamically allocated node
+arrays.
+
+This allows memory hotplug to create new nodes for newly added memory
+rather than binding it to existing nodes.
+
+For emulation on x86, it would be possible to set aside memory for hotplug=
ged
+nodes (say, anything above 2G) and to add an additional four nodes as bein=
g
+possible on boot with
+
+       mem=3D2G numa=3Dpossible=3D4
+
+and then creating a new 128M node at runtime:
+
+       # echo 128M@0x80000000 > /sys/kernel/debug/node_hotplug/add_node
+       On node 1 totalpages: 0
+       init_memory_mapping: 0000000080000000-0000000088000000
+        0080000000 - 0088000000 page 2M
+
+Once the new node has been added, its memory can be onlined.  If this
+memory represents memory section 16, for example:
+
+       # echo online > /sys/devices/system/memory/memory16/state
+       Built 2 zonelists in Node order, mobility grouping on.  Total pages=
: 514846
+       Policy zone: Normal
+ [ The memory section(s) mapped to a particular node are visible via
+   /sys/devices/system/mem_hotplug/node1, in this example. ]
+
+2) CPU hotplug emulation:
+
+The emulator reserves CPUs thru grub parameter, the reserved CPUs can be
+hot-add/hot-remove in software method, it emulates the process of physical
+cpu hotplug.
+
+When hotplugging a CPU with emulator, we are using a logical CPU to emulat=
e the
+CPU socket hotplug process. For the CPU supported SMT, some logical CPUs a=
re in
+the same socket, but it may located in different NUMA node after we have
+emulator. We put the logical CPU into a fake CPU socket, and assign it a
+unique phys_proc_id. For the fake socket, we put one logical CPU in only.
+
+ - to hide CPUs
+       - Using boot option "maxcpus=3DN" hide CPUs
+         N is the number of CPUs to initialize; the reset will be hidden.
+       - Using boot option "cpu_hpe=3Don" to enable CPU hotplug emulation
+      when cpu_hpe is enabled, the rest CPUs will not be initialized
+
+ - to hot-add CPU to node
+       # echo node_id > /sys/devices/system/cpu/probe
+
+ - to hot-remove CPU
+       # echo cpu_id > /sys/devices/system/cpu/release
+
+3) Memory hotplug emulation:
+
+The emulator reserves memory before OS boots, the reserved memory region i=
s
+removed from e820 table. Each online node has an add_memory interface, and
+memory can be hot-added via the per-ndoe add_memory debugfs interface.
+
+The difficulty of Memory Release is well-known, we have no plan for it unt=
il
+now.
+
+ - reserve memory thru a kernel boot paramter
+       mem=3D1024m
+
+ - add a memory section to node 3
+    # echo 0x40000000 > /sys/kernel/debug/node_hotplug/node3/add_memory
+       OR
+    # echo 1024m > /sys/kernel/debug/node_hotplug/node3/add_memory
+
+4) Script for hotplug testing
+
+These scripts provides convenience when we hot-add memory/cpu in batch.
+
+- Online all memory sections:
+for m in /sys/devices/system/memory/memory*;
+do
+       echo online > $m/state;
+done
+
+- CPU Online:
+for c in /sys/devices/system/cpu/cpu*;
+do
+       echo 1 > $c/online;
+done
+
+- David Rientjes <rientjes@google.com>
+- Haicheng Li <haicheng.li@intel.com>
+- Shaohui Zheng <shaohui.zheng@intel.com>
+- Yang Zhang <yang.z.zhang@intel.com>
--
1.7.1.1
--
best regards
yang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
