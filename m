Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 652AC8D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 10:20:07 -0400 (EDT)
From: "Zhang, Yang Z" <yang.z.zhang@intel.com>
Date: Thu, 31 Mar 2011 22:19:58 +0800
Subject: [PATCH 3/7,v10] NUMA Hotplug Emulator: Add node hotplug emulation
Message-ID: <749B9D3DBF0F054390025D9EAFF47F224A3D6C3C@shsmsx501.ccr.corp.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "haicheng.li@linux.intel.com" <haicheng.li@linux.intel.com>, "lethal@linux-sh.org" <lethal@linux-sh.org>, "Kleen, Andi" <andi.kleen@intel.com>, "dave@linux.vnet.ibm.com" <dave@linux.vnet.ibm.com>, "gregkh@suse.de" <gregkh@suse.de>, "mingo@elte.hu" <mingo@elte.hu>, "lenb@kernel.org" <lenb@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "yinghai@kernel.org" <yinghai@kernel.org>, "Li, Xin" <xin.li@intel.com>

From: David Rientjes <rientjes@google.com>

Add an interface to allow new nodes to be added when performing memory
hot-add.  This provides a convenient interface to test memory hotplug
notifier callbacks and surrounding hotplug code when new nodes are
onlined without actually having a machine with such hotpluggable SRAT
entries.

This adds a new debugfs interface at /sys/kernel/debug/node_hotplug/add_nod=
e
that behaves in a similar way to the memory hot-add "probe" interface.
Its format is size@start, where "size" is the size of the new node to be
added and "start" is the physical address of the new memory.

The new node id is a currently offline, but possible, node.  The bit must
be set in node_possible_map so that nr_node_ids is sized appropriately.

For emulation on x86, for example, it would be possible to set aside
memory for hotplugged nodes (say, anything above 2G) and to add an
additional four nodes as being possible on boot with

        mem=3D2G numa=3Dpossible=3D4

and then creating a new 128M node at runtime:

        # echo 128M@0x80000000 > /sys/kernel/debug/node_hotplug/add_node
        On node 1 totalpages: 0
        init_memory_mapping: 0000000080000000-0000000088000000
         0080000000 - 0088000000 page 2M
Once the new node has been added, its memory can be onlined.  If this
memory represents memory section 16, for example:

        # echo online > /sys/devices/system/memory/memory16/state
        Built 2 zonelists in Node order, mobility grouping on.  Total pages=
: 514846
        Policy zone: Normal
 [ The memory section(s) mapped to a particular node are visible via
   /sys/kernel/debug/node_hotplug/node1, in this example. ]

The new node is now hotplugged and ready for testing.

CC: Haicheng Li <haicheng.li@intel.com>
CC: Greg KH <gregkh@suse.de>
Signed-off-by: David Rientjes <rientjes@google.com>
Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
Signed-off-by: Yang Zhang <yang.z.zhang@Intel.com>
---
 Documentation/memory-hotplug.txt |   24 ++++++++++++++
 arch/x86/mm/numa_emulation.c     |    4 +-
 mm/memory_hotplug.c              |   63 ++++++++++++++++++++++++++++++++++=
++++
 3 files changed, 89 insertions(+), 2 deletions(-)

diff --git a/Documentation/memory-hotplug.txt linux-hpe4/Documentation/memo=
ry-hotplug.txt
index 8f485d7..bc8c99e 100644
--- a/Documentation/memory-hotplug.txt
+++ linux-hpe4/Documentation/memory-hotplug.txt
@@ -18,6 +18,7 @@ be changed often.
 4. Physical memory hot-add phase
   4.1 Hardware(Firmware) Support
   4.2 Notify memory hot-add event by hand
+  4.3 Node hotplug emulation
 5. Logical Memory hot-add phase
   5.1. State of memory
   5.2. How to online memory
@@ -230,6 +231,29 @@ current implementation). You'll have to online memory =
by yourself.
 Please see "How to online memory" in this text.


+4.3 Node hotplug emulation
+------------
+With debugfs, it is possible to test node hotplug by assigning the newly
+added memory to a new node id when using a different interface with a simi=
lar
+behavior to "probe" described in section 4.2.  If a node id is possible
+(there are bits in /sys/devices/system/memory/possible that are not online=
),
+then it may be used to emulate a newly added node as the result of memory
+hotplug by using the debugfs "add_node" interface.
+
+The add_node interface is located at "node_hotplug/add_node" at the debugf=
s
+mount point.
+
+You can create a new node of a specified size starting at the physical
+address of new memory by
+
+% echo size@start_address_of_new_memory > /sys/kernel/debug/node_hotplug/a=
dd_node
+
+Where "size" can be represented in megabytes or gigabytes (for example,
+"128M" or "1G").  The minumum size is that of a memory section.
+
+Once the new node has been added, it is possible to online the memory by
+toggling the "state" of its memory section(s) as described in section 5.1.
+

 ------------------------------
 5. Logical Memory hot-add phase
diff --git a/arch/x86/mm/numa_emulation.c linux-hpe4/arch/x86/mm/numa_emula=
tion.c
index c2309e5..5f822b5 100644
--- a/arch/x86/mm/numa_emulation.c
+++ linux-hpe4/arch/x86/mm/numa_emulation.c
@@ -9,8 +9,8 @@

 #include "numa_internal.h"

-static int emu_nid_to_phys[MAX_NUMNODES] __cpuinitdata;
-static char *emu_cmdline __initdata;
+int emu_nid_to_phys[MAX_NUMNODES] __cpuinitdata;
+char *emu_cmdline __initdata;

 void __init numa_emu_cmdline(char *str)
 {
diff --git a/mm/memory_hotplug.c linux-hpe4/mm/memory_hotplug.c
index 321fc74..f0be4b4 100644
--- a/mm/memory_hotplug.c
+++ linux-hpe4/mm/memory_hotplug.c
@@ -934,3 +934,66 @@ int remove_memory(u64 start, u64 size)
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 EXPORT_SYMBOL_GPL(remove_memory);
+
+#ifdef CONFIG_DEBUG_FS
+#include <linux/debugfs.h>
+
+static struct dentry *node_hp_debug_root;
+extern char *emu_cmdline;
+extern int emu_nid_to_phys[MAX_NUMNODES];
+
+static ssize_t add_node_store(struct file *file, const char __user *buf,
+                               size_t count, loff_t *ppos)
+{
+       nodemask_t mask;
+       u64 start, size;
+       char buffer[64];
+       char *p;
+       int nid;
+       int ret;
+
+       memset(buffer, 0, sizeof(buffer));
+       if (count > sizeof(buffer) - 1)
+               count =3D sizeof(buffer) - 1;
+       if (copy_from_user(buffer, buf, count))
+               return -EFAULT;
+
+       size =3D memparse(buffer, &p);
+       if (size < (PAGES_PER_SECTION << PAGE_SHIFT))
+               return -EINVAL;
+       if (*p !=3D '@')
+               return -EINVAL;
+
+       start =3D simple_strtoull(p + 1, NULL, 0);
+
+       nodes_andnot(mask, node_possible_map, node_online_map);
+       nid =3D first_node(mask);
+       if (nid =3D=3D MAX_NUMNODES)
+               return -ENOMEM;
+       emu_nid_to_phys[nid] =3D nid;
+
+       ret =3D add_memory(nid, start, size);
+       return ret ? ret : count;
+}
+
+static const struct file_operations add_node_file_ops =3D {
+       .write          =3D add_node_store,
+       .llseek         =3D generic_file_llseek,
+};
+
+static int __init node_debug_init(void)
+{
+       if (!node_hp_debug_root)
+               node_hp_debug_root =3D debugfs_create_dir("node_hotplug", N=
ULL);
+       if (!node_hp_debug_root)
+               return -ENOMEM;
+
+       if (!debugfs_create_file("add_node", S_IWUSR, node_hp_debug_root,
+                       NULL, &add_node_file_ops))
+               return -ENOMEM;
+
+       return 0;
+}
+
+module_init(node_debug_init);
+#endif /* CONFIG_DEBUG_FS */
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
