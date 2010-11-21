Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 900CC6B0085
	for <linux-mm@kvack.org>; Sat, 20 Nov 2010 21:28:48 -0500 (EST)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id oAL2SilE005027
	for <linux-mm@kvack.org>; Sat, 20 Nov 2010 18:28:44 -0800
Received: from gxk6 (gxk6.prod.google.com [10.202.11.6])
	by wpaz33.hot.corp.google.com with ESMTP id oAL2Sgv9001662
	for <linux-mm@kvack.org>; Sat, 20 Nov 2010 18:28:43 -0800
Received: by gxk6 with SMTP id 6so4308461gxk.37
        for <linux-mm@kvack.org>; Sat, 20 Nov 2010 18:28:42 -0800 (PST)
Date: Sat, 20 Nov 2010 18:28:38 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch 2/2] mm: add node hotplug emulation
In-Reply-To: <alpine.DEB.2.00.1011201826140.12889@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1011201827540.12889@chino.kir.corp.google.com>
References: <20101117020759.016741414@intel.com> <20101117021000.568681101@intel.com> <alpine.DEB.2.00.1011162359160.17408@chino.kir.corp.google.com> <20101117075128.GA30254@shaohui> <alpine.DEB.2.00.1011171304060.10254@chino.kir.corp.google.com>
 <20101118041407.GA2408@shaohui> <20101118062715.GD17539@linux-sh.org> <20101118052750.GD2408@shaohui> <alpine.DEB.2.00.1011181321470.26680@chino.kir.corp.google.com> <20101119003225.GB3327@shaohui> <alpine.DEB.2.00.1011201645230.10618@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1011201826140.12889@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@suse.de>
Cc: Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Shaohui Zheng <shaohui.zheng@intel.com>, Paul Mundt <lethal@linux-sh.org>, Andi Kleen <ak@linux.intel.com>, Yinghai Lu <yinghai@kernel.org>, Haicheng Li <haicheng.li@intel.com>, Randy Dunlap <randy.dunlap@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>


Add an interface to allow new nodes to be added when performing memory
hot-add.  This provides a convenient interface to test memory hotplug
notifier callbacks and surrounding hotplug code when new nodes are
onlined without actually having a machine with such hotpluggable SRAT
entries.

This adds a new interface at /sys/devices/system/memory/add_node that
behaves in a similar way to the memory hot-add "probe" interface.  Its
format is size@start, where "size" is the size of the new node to be
added and "start" is the physical address of the new memory.

The new node id is a currently offline, but possible, node.  The bit must
be set in node_possible_map so that nr_node_ids is sized appropriately.

For emulation on x86, for example, it would be possible to set aside
memory for hotplugged nodes (say, anything above 2G) and to add an
additional three nodes as being possible on boot with

	mem=2G numa=possible=3

and then creating a new 128M node at runtime:

	# echo 128M@0x80000000 > /sys/devices/system/memory/add_node
	On node 1 totalpages: 0
	init_memory_mapping: 0000000080000000-0000000088000000
	 0080000000 - 0088000000 page 2M

Once the new node has been added, its memory can be onlined.  If this
memory represents memory section 16, for example:

	# echo online > /sys/devices/system/memory/memory16/state
	Built 2 zonelists in Node order, mobility grouping on.  Total pages: 514846
	Policy zone: Normal

 [ The memory section(s) mapped to a particular node are visible via
   /sys/devices/system/node/node1, in this example. ]

The new node is now hotplugged and ready for testing.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 Documentation/memory-hotplug.txt |   24 ++++++++++++++++++++++++
 drivers/base/memory.c            |   36 +++++++++++++++++++++++++++++++++++-
 2 files changed, 59 insertions(+), 1 deletions(-)

diff --git a/Documentation/memory-hotplug.txt b/Documentation/memory-hotplug.txt
--- a/Documentation/memory-hotplug.txt
+++ b/Documentation/memory-hotplug.txt
@@ -18,6 +18,7 @@ be changed often.
 4. Physical memory hot-add phase
   4.1 Hardware(Firmware) Support
   4.2 Notify memory hot-add event by hand
+  4.3 Node hotplug emulation
 5. Logical Memory hot-add phase
   5.1. State of memory
   5.2. How to online memory
@@ -215,6 +216,29 @@ current implementation). You'll have to online memory by yourself.
 Please see "How to online memory" in this text.
 
 
+4.3 Node hotplug emulation
+------------
+It is possible to test node hotplug by assigning the newly added memory to a
+new node id when using a different interface with a similar behavior to
+"probe" described in section 4.2.  If a node id is possible (there are bits
+in /sys/devices/system/memory/possible that are not online), then it may be
+used to emulate a newly added node as the result of memory hotplug by using
+the "add_node" interface.
+
+The add_node interface is located at
+/sys/devices/system/memory/add_node
+
+You can create a new node of a specified size starting at the physical
+address of new memory by
+
+% echo size@start_address_of_new_memory > /sys/devices/system/memory/add_node
+
+Where "size" can be represented in megabytes or gigabytes (for example,
+"128M" or "1G").  The minumum size is that of a memory section.
+
+Once the new node has been added, it is possible to online the memory by
+toggling the "state" of its memory section(s) as described in section 5.1.
+
 
 ------------------------------
 5. Logical Memory hot-add phase
diff --git a/drivers/base/memory.c b/drivers/base/memory.c
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -353,10 +353,44 @@ memory_probe_store(struct class *class, struct class_attribute *attr,
 }
 static CLASS_ATTR(probe, S_IWUSR, NULL, memory_probe_store);
 
+static ssize_t
+memory_add_node_store(struct class *class, struct class_attribute *attr,
+		      const char *buf, size_t count)
+{
+	nodemask_t mask;
+	u64 start, size;
+	char *p;
+	int nid;
+	int ret;
+
+	size = memparse(buf, &p);
+	if (size < (PAGES_PER_SECTION << PAGE_SHIFT))
+		return -EINVAL;
+	if (*p != '@')
+		return -EINVAL;
+
+	start = simple_strtoull(p + 1, NULL, 0);
+
+	nodes_andnot(mask, node_possible_map, node_online_map);
+	nid = first_node(mask);
+	if (nid == MAX_NUMNODES)
+		return -EINVAL;
+
+	ret = add_memory(nid, start, size);
+	return ret ? ret : count;
+}
+static CLASS_ATTR(add_node, S_IWUSR, NULL, memory_add_node_store);
+
 static int memory_probe_init(void)
 {
-	return sysfs_create_file(&memory_sysdev_class.kset.kobj,
+	int err;
+
+	err = sysfs_create_file(&memory_sysdev_class.kset.kobj,
 				&class_attr_probe.attr);
+	if (err)
+		return err;
+	return sysfs_create_file(&memory_sysdev_class.kset.kobj,
+				&class_attr_add_node.attr);
 }
 #else
 static inline int memory_probe_init(void)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
