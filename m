Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 3E83E8D0080
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 23:46:07 -0500 (EST)
Message-Id: <20101117021000.916235444@intel.com>
References: <20101117020759.016741414@intel.com>
Date: Wed, 17 Nov 2010 10:08:06 +0800
From: shaohui.zheng@intel.com
Subject: [7/8,v3] NUMA Hotplug Emulator: extend memory probe interface to support NUMA
Content-Disposition: inline; filename=007-hotplug-emulator-extend-memory-probe-interface-to-support-numa.patch
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, Dave Hansen <dave@linux.vnet.ibm.com>, Shaohui Zheng <shaohui.zheng@intel.com>, Haicheng Li <haicheng.li@intel.com>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

Extend memory probe interface to support an extra paramter nid,
the reserved memory can be added into this node if node exists.

Add a memory section(128M) to node 3(boots with mem=1024m)

	echo 0x40000000,3 > memory/probe

And more we make it friendly, it is possible to add memory to do

	echo 3g > memory/probe
	echo 1024m,3 > memory/probe

It maintains backwards compatibility.

Another format suggested by Dave Hansen:

	echo physical_address=0x40000000 numa_node=3 > memory/probe

it is more explicit to show meaning of the parameters.

CC: Dave Hansen <dave@linux.vnet.ibm.com>
Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
Signed-off-by: Haicheng Li <haicheng.li@intel.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
Index: linux-hpe4/Documentation/ABI/testing/sysfs-devices-memory
===================================================================
--- linux-hpe4.orig/Documentation/ABI/testing/sysfs-devices-memory	2010-11-17 09:00:50.653461798 +0800
+++ linux-hpe4/Documentation/ABI/testing/sysfs-devices-memory	2010-11-17 09:01:10.262838849 +0800
@@ -60,6 +60,23 @@
 Users:		hotplug memory remove tools
 		http://www.ibm.com/developerworks/wikis/display/LinuxP/powerpc-utils
 
+What:		/sys/devices/system/memory/probe
+Date:		Nov 2010
+Contact:	Linux Memory Management list <linux-mm@kvack.org>
+Description:
+		memory probe interface is for memory hotplug emulation. it is a software
+		interface to test memory hotplug. We provide the start address and numa
+		nodes id, it will add a memory section to the specified node.
+
+		Add a memory section(128M) to node 3(boots with mem=1024m)
+			echo 0x40000000,3 > memory/probe
+
+		A more friendly method
+			echo 3g > memory/probe
+			echo 1024m,3 > memory/probe
+
+		Another format suggested by Dave Hansen:
+			echo physical_address=0x40000000 numa_node=3 > memory/probe
 
 What:		/sys/devices/system/memoryX/nodeY
 Date:		October 2009
Index: linux-hpe4/arch/x86/Kconfig
===================================================================
--- linux-hpe4.orig/arch/x86/Kconfig	2010-11-17 09:00:50.673463029 +0800
+++ linux-hpe4/arch/x86/Kconfig	2010-11-17 09:01:10.282838829 +0800
@@ -1276,10 +1276,6 @@
 	def_bool y
 	depends on ARCH_SPARSEMEM_ENABLE
 
-config ARCH_MEMORY_PROBE
-	def_bool X86_64
-	depends on MEMORY_HOTPLUG
-
 config ILLEGAL_POINTER_VALUE
        hex
        default 0 if X86_32
Index: linux-hpe4/drivers/base/memory.c
===================================================================
--- linux-hpe4.orig/drivers/base/memory.c	2010-11-17 09:00:50.673463029 +0800
+++ linux-hpe4/drivers/base/memory.c	2010-11-17 09:01:10.302838792 +0800
@@ -329,6 +329,9 @@
  * will not need to do it from userspace.  The fake hot-add code
  * as well as ppc64 will do all of their discovery in userspace
  * and will require this interface.
+ *
+ * Parameter format 1: physical_address,numa_node
+ * Parameter format 2: physical_address=0x40000000 numa_node=3
  */
 #ifdef CONFIG_ARCH_MEMORY_PROBE
 static ssize_t
@@ -336,13 +339,53 @@
 		   const char *buf, size_t count)
 {
 	u64 phys_addr;
-	int nid;
+	int nid = 0;
 	int ret;
+	char *p = NULL, *q = NULL;
+	/* format: physical_address=0x40000000 numa_node=3 */
+	p = strchr(buf, '=');
+	if (p != NULL) {
+		*p = '\0';
+		q = strchr(buf, ' ');
+		if (q == NULL) {
+			if (strcmp(buf, "physical_address") != 0)
+				ret = -EPERM;
+			else
+				phys_addr = memparse(p+1, NULL);
+		} else {
+			*q++ = '\0';
+			p = strchr(q, '=');
+			if (strcmp(buf, "physical_address") == 0)
+				phys_addr = memparse(p+1, NULL);
+			if (strcmp(buf, "numa_node") == 0)
+				nid = simple_strtoul(p+1, NULL, 0);
+			if (strcmp(q, "physical_address") == 0)
+				phys_addr = memparse(p+1, NULL);
+			if (strcmp(q, "numa_node") == 0)
+				nid = simple_strtoul(p+1, NULL, 0);
+		}
+	} else { /* physical_address,numa_node */
+		p = strchr(buf, ',');
+		if (p != NULL && strlen(p+1) > 0) {
+			/* nid specified */
+			*p++ = '\0';
+			nid = simple_strtoul(p, NULL, 0);
+			phys_addr = memparse(buf, NULL);
+		} else {
+			phys_addr = memparse(buf, NULL);
+			nid = memory_add_physaddr_to_nid(phys_addr);
+		}
+	}
 
-	phys_addr = simple_strtoull(buf, NULL, 0);
-
-	nid = memory_add_physaddr_to_nid(phys_addr);
-	ret = add_memory(nid, phys_addr, PAGES_PER_SECTION << PAGE_SHIFT);
+	if (nid < 0 || nid > nr_node_ids - 1) {
+		printk(KERN_ERR "Invalid node id %d(0<=nid<%d).\n", nid, nr_node_ids);
+		ret = -EPERM;
+	} else {
+		printk(KERN_INFO "Add a memory section to node: %d.\n", nid);
+		ret = add_memory(nid, phys_addr, PAGES_PER_SECTION << PAGE_SHIFT);
+		if (ret)
+			count = ret;
+	}
 
 	if (ret)
 		count = ret;
Index: linux-hpe4/mm/Kconfig
===================================================================
--- linux-hpe4.orig/mm/Kconfig	2010-11-17 09:01:10.212839478 +0800
+++ linux-hpe4/mm/Kconfig	2010-11-17 09:01:10.302838792 +0800
@@ -173,6 +173,17 @@
 	  is for cpu hot-add/hot-remove to specified node in software method.
 	  This is for debuging and testing purpose
 
+config ARCH_MEMORY_PROBE
+	def_bool y
+	bool "Memory hotplug emulation"
+	depends on NUMA_HOTPLUG_EMU
+	---help---
+	  Enable memory hotplug emulation. Reserve memory with grub parameter
+	  "mem=N"(such as mem=1024M), where N is the initial memory size, the
+	  rest physical memory will be removed from e820 table; the memory probe
+	  interface is for memory hot-add to specified node in software method.
+	  This is for debuging and testing purpose
+
 #
 # If we have space for more page flags then we can enable additional
 # optimizations and functionality.

-- 
Thanks & Regards,
Shaohui


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
