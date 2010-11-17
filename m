Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7CF748D0080
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 23:45:38 -0500 (EST)
Message-Id: <20101117021000.568681101@intel.com>
References: <20101117020759.016741414@intel.com>
Date: Wed, 17 Nov 2010 10:08:01 +0800
From: shaohui.zheng@intel.com
Subject: [2/8,v3] NUMA Hotplug Emulator: infrastructure of NUMA hotplug emulation
Content-Disposition: inline; filename=002-hotplug-emulator-x86-infrastructure-of-node-hotplug-emulation.patch
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, Yinghai Lu <yinghai@kernel.org>, Haicheng Li <haicheng.li@intel.com>, Shaohui Zheng <shaohui.zheng@intel.com>
List-ID: <linux-mm.kvack.org>

From: Haicheng Li <haicheng.li@intel.com>

NUMA hotplug emulator introduces a new node state N_HIDDEN to
identify the fake offlined node. It firstly hides RAM via E820
table and then emulates fake offlined nodes with the hidden RAM.

After system bootup, user is able to hotplug-add these offlined
nodes, which is just similar to a real hardware hotplug behavior.

Using boot option "numa=hide=N*size" to fake offlined nodes:
	- N is the number of hidden nodes
	- size is the memory size (in MB) per hidden node.

OPEN: Kernel might use part of hidden memory region as RAM buffer,
      now emulator directly hide 128M extra space to workaround
      this issue.  Any better way to avoid this conflict?

CC: Yinghai Lu <yinghai@kernel.org>
Signed-off-by: Haicheng Li <haicheng.li@intel.com>
Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
---
Index: linux-hpe4/arch/x86/include/asm/numa_64.h
===================================================================
--- linux-hpe4.orig/arch/x86/include/asm/numa_64.h	2010-11-15 17:13:02.453461462 +0800
+++ linux-hpe4/arch/x86/include/asm/numa_64.h	2010-11-15 17:13:07.093461818 +0800
@@ -37,7 +37,7 @@
 extern void __cpuinit numa_add_cpu(int cpu);
 extern void __cpuinit numa_remove_cpu(int cpu);
 
-#ifdef CONFIG_NUMA_EMU
+#if defined(CONFIG_NUMA_EMU) || defined(CONFIG_NODE_HOTPLUG_EMU)
 #define FAKE_NODE_MIN_SIZE	((u64)64 << 20)
 #define FAKE_NODE_MIN_HASH_MASK	(~(FAKE_NODE_MIN_SIZE - 1UL))
 #endif /* CONFIG_NUMA_EMU */
Index: linux-hpe4/arch/x86/mm/numa_64.c
===================================================================
--- linux-hpe4.orig/arch/x86/mm/numa_64.c	2010-11-15 17:13:02.463461371 +0800
+++ linux-hpe4/arch/x86/mm/numa_64.c	2010-11-15 17:21:05.510961676 +0800
@@ -304,6 +304,123 @@
 	}
 }
 
+#ifdef CONFIG_NODE_HOTPLUG_EMU
+static char *hp_cmdline __initdata;
+static struct bootnode *hidden_nodes;
+static u64 hp_start;
+static long hidden_num, hp_size;
+static u64 nodes_size[MAX_NUMNODES] __initdata;
+
+int hotadd_hidden_nodes(int nid)
+{
+	int ret;
+
+	if (!node_hidden(nid))
+		return -EINVAL;
+
+	ret = add_memory(nid, hidden_nodes[nid].start,
+			 hidden_nodes[nid].end - hidden_nodes[nid].start);
+	if (!ret) {
+		node_clear_hidden(nid);
+		return 0;
+	} else {
+		return -EEXIST;
+	}
+}
+
+/* parse the comand line for numa=hide */
+static long __init parse_hide_nodes(char *hp_cmdline)
+{
+	int coef = 1, nid = 0;
+	u64 size = 0;
+	long total = 0;
+	char buf[512], *p;
+
+	/* parse numa=hide command-line */
+	hidden_num = 0;
+	p = buf;
+	while (1) {
+		if (*hp_cmdline == ',' || *hp_cmdline == '\0') {
+			*p = '\0';
+			size = simple_strtoul(buf, NULL, 0);
+			printk(KERN_ERR "size: %dM buf:%s coef: %d.\n", (int)size, buf, coef);
+			if (!((size<<20) & FAKE_NODE_MIN_HASH_MASK))
+				printk(KERN_ERR "%d M is less than minimum node size, ignore it.\n", (int)size);
+
+			size <<= 20;
+			/* Round down to nearest FAKE_NODE_MIN_SIZE. */
+			size &= FAKE_NODE_MIN_HASH_MASK;
+
+			if (size) {
+				int i;
+				total += size * coef;
+				for (i = 0; i < coef; i++)
+					nodes_size[nid++] = size;
+				hidden_num += coef;
+			}
+
+			coef = 1;
+			p = buf;
+			if (*hp_cmdline  == '\0')
+				break;
+			hp_cmdline++;
+		} else if (*hp_cmdline ==  '*') {
+			*p++ = '\0';
+			coef = simple_strtoul(buf, NULL, 0);
+			p = buf;
+			hp_cmdline++;
+		} else if (!isdigit(*hp_cmdline)) {
+			break;
+		}
+
+		*p++ = *hp_cmdline++;
+	}
+
+	return total;
+}
+
+static void __init numa_hide_nodes(void)
+{
+	hp_size = parse_hide_nodes(hp_cmdline);
+
+	hp_start = e820_hide_mem(hp_size);
+	if (hp_start <= 0) {
+		printk(KERN_ERR "Hide too much memory, disable node hotplug emualtion.");
+		hidden_num = 0;
+		return;
+	}
+
+	/* leave 128M space for possible RAM buffer usage later
+	 any other better way to avoid this conflict?*/
+
+	e820_hide_mem(128*1024*1024);
+}
+
+static void __init numa_hotplug_emulation(void)
+{
+	int i, num_nodes = 0, nid;
+
+	for_each_online_node(i)
+		if (i > num_nodes)
+			num_nodes = i;
+
+	i = num_nodes + hidden_num;
+	if (!hidden_nodes) {
+		hidden_nodes = alloc_bootmem(sizeof(struct bootnode) * i);
+		memset(hidden_nodes, 0, sizeof(struct bootnode) * i);
+	}
+
+	nid = num_nodes + 1;
+	for (i = 0; i < hidden_num; i++) {
+		node_set(nid, node_possible_map);
+		hidden_nodes[nid].start = hp_start;
+		hidden_nodes[nid].end = hp_start + (nodes_size[i]);
+		hp_start = hidden_nodes[nid].end;
+		node_set_hidden(nid++);
+	}
+}
+#endif /* CONFIG_NODE_HOTPLUG_EMU */
+
 #ifdef CONFIG_NUMA_EMU
 /* Numa emulation */
 static struct bootnode nodes[MAX_NUMNODES] __initdata;
@@ -658,7 +775,7 @@
 
 #ifdef CONFIG_NUMA_EMU
 	if (cmdline && !numa_emulation(start_pfn, last_pfn, acpi, k8))
-		return;
+		goto done;
 	nodes_clear(node_possible_map);
 	nodes_clear(node_online_map);
 #endif
@@ -666,14 +783,14 @@
 #ifdef CONFIG_ACPI_NUMA
 	if (!numa_off && acpi && !acpi_scan_nodes(start_pfn << PAGE_SHIFT,
 						  last_pfn << PAGE_SHIFT))
-		return;
+		goto done;
 	nodes_clear(node_possible_map);
 	nodes_clear(node_online_map);
 #endif
 
 #ifdef CONFIG_K8_NUMA
 	if (!numa_off && k8 && !k8_scan_nodes())
-		return;
+		goto done;
 	nodes_clear(node_possible_map);
 	nodes_clear(node_online_map);
 #endif
@@ -693,6 +810,13 @@
 		numa_set_node(i, 0);
 	e820_register_active_regions(0, start_pfn, last_pfn);
 	setup_node_bootmem(0, start_pfn << PAGE_SHIFT, last_pfn << PAGE_SHIFT);
+
+done:
+#ifdef CONFIG_NODE_HOTPLUG_EMU
+	if (hidden_num)
+		numa_hotplug_emulation();
+#endif
+	return;
 }
 
 unsigned long __init numa_free_all_bootmem(void)
@@ -720,6 +844,12 @@
 	if (!strncmp(opt, "fake=", 5))
 		cmdline = opt + 5;
 #endif
+#ifdef CONFIG_NODE_HOTPLUG_EMU
+	if (!strncmp(opt, "hide=", 5)) {
+		hp_cmdline = opt + 5;
+		numa_hide_nodes();
+	}
+#endif
 #ifdef CONFIG_ACPI_NUMA
 	if (!strncmp(opt, "noacpi", 6))
 		acpi_numa = -1;
Index: linux-hpe4/include/linux/nodemask.h
===================================================================
--- linux-hpe4.orig/include/linux/nodemask.h	2010-11-15 17:13:02.463461371 +0800
+++ linux-hpe4/include/linux/nodemask.h	2010-11-15 17:13:07.093461818 +0800
@@ -371,6 +371,10 @@
  */
 enum node_states {
 	N_POSSIBLE,		/* The node could become online at some point */
+#ifdef CONFIG_NODE_HOTPLUG_EMU
+	N_HIDDEN,		/* The node is hidden at booting time, could be
+				 * onlined in run time */
+#endif
 	N_ONLINE,		/* The node is online */
 	N_NORMAL_MEMORY,	/* The node has regular memory */
 #ifdef CONFIG_HIGHMEM
@@ -470,6 +474,13 @@
 #define node_online(node)	node_state((node), N_ONLINE)
 #define node_possible(node)	node_state((node), N_POSSIBLE)
 
+#ifdef CONFIG_NODE_HOTPLUG_EMU
+#define node_set_hidden(node)	   node_set_state((node), N_HIDDEN)
+#define node_clear_hidden(node)	   node_clear_state((node), N_HIDDEN)
+#define node_hidden(node)	node_state((node), N_HIDDEN)
+extern int hotadd_hidden_nodes(int nid);
+#endif
+
 #define for_each_node(node)	   for_each_node_state(node, N_POSSIBLE)
 #define for_each_online_node(node) for_each_node_state(node, N_ONLINE)
 

-- 
Thanks & Regards,
Shaohui


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
