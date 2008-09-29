Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m8TK5OF4013615
	for <linux-mm@kvack.org>; Mon, 29 Sep 2008 16:05:24 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8TK5NQQ098610
	for <linux-mm@kvack.org>; Mon, 29 Sep 2008 16:05:23 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8TK5Jkl023048
	for <linux-mm@kvack.org>; Mon, 29 Sep 2008 16:05:23 -0400
Date: Mon, 29 Sep 2008 13:05:09 -0700
From: Gary Hade <garyhade@us.ibm.com>
Subject: [PATCH] mm: show node to memory section relationship with symlinks
	in sysfs
Message-ID: <20080929200509.GC21255@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Badari Pulavarty <pbadari@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>, Gary Hade <garyhade@us.ibm.com>, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Nish Aravamudan <nish.aravamudan@gmail.com>
List-ID: <linux-mm.kvack.org>

Show node to memory section relationship with symlinks in sysfs

Add /sys/devices/system/node/nodeX/memoryY symlinks for all
the memory sections located on nodeX.  For example:
/sys/devices/system/node/node1/memory135 -> ../../memory/memory135
indicates that memory section 135 resides on node1.

Successfully tested with 2.6.27-rc7 source on 2-node x86_64,
2-node ppc64, and 2-node ia64 systems.

Also revises documentation to cover this change as well as updating
Documentation/ABI/testing/sysfs-devices-memory to include descriptions
of memory hotremove files 'phys_device', 'phys_index', and 'state'
that were previously not described there.

Supersedes the "mm: show memory section to node relationship in sysfs"
patch posted on 05 Sept 2008 which created node ID containing 'node'
files in /sys/devices/system/memory/memoryX instead of symlinks.
Changed from files to symlinks due to feedback that symlinks were
more consistent with the sysfs way.

Signed-off-by: Gary Hade <garyhade@us.ibm.com>
Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>

---
 Documentation/ABI/testing/sysfs-devices-memory |   51 ++++++++++++
 Documentation/memory-hotplug.txt               |   16 +++
 drivers/base/memory.c                          |   10 ++
 drivers/base/node.c                            |   61 +++++++++++++++
 include/linux/memory.h                         |    4 
 include/linux/node.h                           |   11 ++
 6 files changed, 146 insertions(+), 7 deletions(-)

Index: linux-2.6.27-rc5/Documentation/ABI/testing/sysfs-devices-memory
===================================================================
--- linux-2.6.27-rc5.orig/Documentation/ABI/testing/sysfs-devices-memory	2008-09-24 13:19:23.000000000 -0700
+++ linux-2.6.27-rc5/Documentation/ABI/testing/sysfs-devices-memory	2008-09-25 13:36:41.000000000 -0700
@@ -6,7 +6,6 @@
 		internal state of the kernel memory blocks. Files could be
 		added or removed dynamically to represent hot-add/remove
 		operations.
-
 Users:		hotplug memory add/remove tools
 		https://w3.opensource.ibm.com/projects/powerpc-utils/
 
@@ -19,6 +18,56 @@
 		This is useful for a user-level agent to determine
 		identify removable sections of the memory before attempting
 		potentially expensive hot-remove memory operation
+Users:		hotplug memory remove tools
+		https://w3.opensource.ibm.com/projects/powerpc-utils/
+
+What:		/sys/devices/system/memory/memoryX/phys_device
+Date:		September 2008
+Contact:	Badari Pulavarty <pbadari@us.ibm.com>
+Description:
+		The file /sys/devices/system/memory/memoryX/phys_device
+		is read-only and is designed to show the name of physical
+		memory device.  Implementation is currently incomplete.
 
+What:		/sys/devices/system/memory/memoryX/phys_index
+Date:		September 2008
+Contact:	Badari Pulavarty <pbadari@us.ibm.com>
+Description:
+		The file /sys/devices/system/memory/memoryX/phys_index
+		is read-only and contains the section ID in hexadecimal
+		which is equivalent to decimal X contained in the
+		memory section directory name.
+
+What:		/sys/devices/system/memory/memoryX/state
+Date:		September 2008
+Contact:	Badari Pulavarty <pbadari@us.ibm.com>
+Description:
+		The file /sys/devices/system/memory/memoryX/state
+		is read-write.  When read, it's contents show the
+		online/offline state of the memory section.  When written,
+		root can toggle the the online/offline state of a removable
+		memory section (see removable file description above)
+		using the following commands.
+		# echo online > /sys/devices/system/memory/memoryX/state
+		# echo offline > /sys/devices/system/memory/memoryX/state
+
+		For example, if /sys/devices/system/memory/memory22/removable
+		contains a value of 1 and
+		/sys/devices/system/memory/memory22/state contains the
+		string "online" the following command can be executed by
+		by root to offline that section.
+		# echo offline > /sys/devices/system/memory/memory22/state
 Users:		hotplug memory remove tools
 		https://w3.opensource.ibm.com/projects/powerpc-utils/
+
+What:		/sys/devices/system/node/nodeX/memoryY
+Date:		September 2008
+Contact:	Gary Hade <garyhade@us.ibm.com>
+Description:
+		When CONFIG_NUMA is enabled
+		/sys/devices/system/node/nodeX/memoryY is a symbolic link that
+		points to the corresponding /sys/devices/system/memory/memoryY
+		memory section directory.  For example, the following symbolic
+		link is created for memory section 9 on node0.
+		/sys/devices/system/node/node0/memory9 -> ../../memory/memory9
+
Index: linux-2.6.27-rc5/Documentation/memory-hotplug.txt
===================================================================
--- linux-2.6.27-rc5.orig/Documentation/memory-hotplug.txt	2008-09-24 13:19:23.000000000 -0700
+++ linux-2.6.27-rc5/Documentation/memory-hotplug.txt	2008-09-25 13:36:58.000000000 -0700
@@ -124,7 +124,7 @@
     This option can be kernel module too.
 
 --------------------------------
-3 sysfs files for memory hotplug
+4 sysfs files for memory hotplug
 --------------------------------
 All sections have their device information under /sys/devices/system/memory as
 
@@ -138,11 +138,12 @@
 (0x100000000 / 1Gib = 4)
 This device covers address range [0x100000000 ... 0x140000000)
 
-Under each section, you can see 3 files.
+Under each section, you can see 4 files.
 
 /sys/devices/system/memory/memoryXXX/phys_index
 /sys/devices/system/memory/memoryXXX/phys_device
 /sys/devices/system/memory/memoryXXX/state
+/sys/devices/system/memory/memoryXXX/removable
 
 'phys_index' : read-only and contains section id, same as XXX.
 'state'      : read-write
@@ -150,10 +151,20 @@
                at write: user can specify "online", "offline" command
 'phys_device': read-only: designed to show the name of physical memory device.
                This is not well implemented now.
+'removable'  : read-only: contains an integer value indicating
+               whether the memory section is removable or not
+               removable.  A value of 1 indicates that the memory
+               section is removable and a value of 0 indicates that
+               it is not removable.
 
 NOTE:
   These directories/files appear after physical memory hotplug phase.
 
+If CONFIG_NUMA is specified the
+/sys/devices/system/memory/memoryXXX memory section
+directories can also be accessed via symbolic links located in
+the /sys/devices/system/node/node* directories.  For example:
+/sys/devices/system/node/node0/memory9 -> ../../memory/memory9
 
 --------------------------------
 4. Physical memory hot-add phase
@@ -365,7 +376,6 @@
   - allowing memory hot-add to ZONE_MOVABLE. maybe we need some switch like
     sysctl or new control file.
   - showing memory section and physical device relationship.
-  - showing memory section and node relationship (maybe good for NUMA)
   - showing memory section is under ZONE_MOVABLE or not
   - test and make it better memory offlining.
   - support HugeTLB page migration and offlining.
Index: linux-2.6.27-rc5/drivers/base/memory.c
===================================================================
--- linux-2.6.27-rc5.orig/drivers/base/memory.c	2008-09-24 13:19:23.000000000 -0700
+++ linux-2.6.27-rc5/drivers/base/memory.c	2008-09-24 13:19:29.000000000 -0700
@@ -368,6 +368,13 @@
 		ret = mem_create_simple_file(mem, phys_device);
 	if (!ret)
 		ret = mem_create_simple_file(mem, removable);
+	if (!ret) {
+		ret = register_mem_sect_under_node(mem);
+		if (ret == -EFAULT) {
+			/* expected during boot if node not registered yet */
+			ret = 0;
+		}
+	}
 
 	return ret;
 }
@@ -380,7 +387,7 @@
  *
  * This could be made generic for all sysdev classes.
  */
-static struct memory_block *find_memory_block(struct mem_section *section)
+struct memory_block *find_memory_block(struct mem_section *section)
 {
 	struct kobject *kobj;
 	struct sys_device *sysdev;
@@ -409,6 +416,7 @@
 	struct memory_block *mem;
 
 	mem = find_memory_block(section);
+	unregister_mem_sect_under_node(mem);
 	mem_remove_simple_file(mem, phys_index);
 	mem_remove_simple_file(mem, state);
 	mem_remove_simple_file(mem, phys_device);
Index: linux-2.6.27-rc5/drivers/base/node.c
===================================================================
--- linux-2.6.27-rc5.orig/drivers/base/node.c	2008-09-24 13:19:23.000000000 -0700
+++ linux-2.6.27-rc5/drivers/base/node.c	2008-09-25 13:36:00.000000000 -0700
@@ -6,6 +6,7 @@
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/mm.h>
+#include <linux/memory.h>
 #include <linux/node.h>
 #include <linux/hugetlb.h>
 #include <linux/cpumask.h>
@@ -225,6 +226,63 @@
 	return 0;
 }
 
+#ifdef CONFIG_MEMORY_HOTPLUG_SPARSE
+int register_mem_sect_under_node(struct memory_block *mem_blk)
+{
+	unsigned int nid;
+
+	if (!mem_blk)
+		return -EFAULT;
+	nid = section_nr_to_nid(mem_blk->phys_index);
+	if (!node_online(nid))
+		return 0;
+	return sysfs_create_link_nowarn(&node_devices[nid].sysdev.kobj,
+		&mem_blk->sysdev.kobj, kobject_name(&mem_blk->sysdev.kobj));
+}
+
+int unregister_mem_sect_under_node(struct memory_block *mem_blk)
+{
+	unsigned int nid;
+
+	if (!mem_blk)
+		return -EFAULT;
+	nid = section_nr_to_nid(mem_blk->phys_index);
+	if (!node_online(nid))
+		return 0;
+	sysfs_remove_link(&node_devices[nid].sysdev.kobj,
+			 kobject_name(&mem_blk->sysdev.kobj));
+	return 0;
+}
+
+static int link_mem_sections(int nid)
+{
+	unsigned long start_pfn = NODE_DATA(nid)->node_start_pfn;
+	unsigned long end_pfn = start_pfn + NODE_DATA(nid)->node_spanned_pages;
+	unsigned long pfn;
+	int err = 0;
+
+	for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
+		unsigned long section_nr = pfn_to_section_nr(pfn);
+		struct mem_section *mem_sect;
+		struct memory_block *mem_blk;
+		int ret;
+
+		if (!present_section_nr(section_nr))
+			continue;
+		if (pfn_to_nid(pfn) != nid)
+			continue;
+		mem_sect = __nr_to_section(section_nr);
+		mem_blk = find_memory_block(mem_sect);
+		ret = register_mem_sect_under_node(mem_blk);
+		if (!err)
+			err = ret;
+	}
+	return err;
+}
+#else
+static int link_mem_sections(int nid) { return 0; }
+#endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
+
 int register_one_node(int nid)
 {
 	int error = 0;
@@ -244,6 +302,9 @@
 			if (cpu_to_node(cpu) == nid)
 				register_cpu_under_node(cpu, nid);
 		}
+
+		/* link memory sections under this node */
+		error = link_mem_sections(nid);
 	}
 
 	return error;
Index: linux-2.6.27-rc5/include/linux/memory.h
===================================================================
--- linux-2.6.27-rc5.orig/include/linux/memory.h	2008-09-24 13:19:23.000000000 -0700
+++ linux-2.6.27-rc5/include/linux/memory.h	2008-09-24 13:19:29.000000000 -0700
@@ -84,9 +84,9 @@
 extern int memory_dev_init(void);
 extern int remove_memory_block(unsigned long, struct mem_section *, int);
 extern int memory_notify(unsigned long val, void *v);
+extern struct memory_block *find_memory_block(struct mem_section *);
 #define CONFIG_MEM_BLOCK_SIZE	(PAGES_PER_SECTION<<PAGE_SHIFT)
-
-
+#define section_nr_to_nid(section_nr) pfn_to_nid(section_nr_to_pfn(section_nr))
 #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
 
 #ifdef CONFIG_MEMORY_HOTPLUG
Index: linux-2.6.27-rc5/include/linux/node.h
===================================================================
--- linux-2.6.27-rc5.orig/include/linux/node.h	2008-09-24 13:19:23.000000000 -0700
+++ linux-2.6.27-rc5/include/linux/node.h	2008-09-24 13:19:29.000000000 -0700
@@ -26,6 +26,7 @@
 	struct sys_device	sysdev;
 };
 
+struct memory_block;
 extern struct node node_devices[];
 
 extern int register_node(struct node *, int, struct node *);
@@ -35,6 +36,8 @@
 extern void unregister_one_node(int nid);
 extern int register_cpu_under_node(unsigned int cpu, unsigned int nid);
 extern int unregister_cpu_under_node(unsigned int cpu, unsigned int nid);
+extern int register_mem_sect_under_node(struct memory_block *mem_blk);
+extern int unregister_mem_sect_under_node(struct memory_block *mem_blk);
 #else
 static inline int register_one_node(int nid)
 {
@@ -52,6 +55,14 @@
 {
 	return 0;
 }
+static inline int register_mem_sect_under_node(struct memory_block *mem_blk)
+{
+	return 0;
+}
+static inline int unregister_mem_sect_under_node(struct memory_block *mem_blk)
+{
+	return 0;
+}
 #endif
 
 #define to_node(sys_device) container_of(sys_device, struct node, sysdev)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
