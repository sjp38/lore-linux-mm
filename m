From: Magnus Damm <magnus@valinux.co.jp>
Message-Id: <20051110090925.8083.45887.sendpatchset@cherry.local>
In-Reply-To: <20051110090920.8083.54147.sendpatchset@cherry.local>
References: <20051110090920.8083.54147.sendpatchset@cherry.local>
Subject: [PATCH 01/05] NUMA: Generic code
Date: Thu, 10 Nov 2005 18:08:08 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Magnus Damm <magnus@valinux.co.jp>, pj@sgi.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

Generic CONFIG_NUMA_EMU code.

This patch adds generic NUMA emulation code to the kernel. The code provides 
the architectures with functions that calculate the size of emulated nodes,
together with configuration stuff such as Kconfig and kernel command line code.

Signed-off-by: Magnus Damm <magnus@valinux.co.jp>
---

 include/linux/numa.h  |   25 +++++++++-
 mm/Kconfig            |   17 +++++++
 mm/Makefile           |    1
 mm/numa_emu.c         |  118 ++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 159 insertions(+), 2 deletions(-)

--- from-0001/include/linux/numa.h
+++ to-work/include/linux/numa.h	2005-11-09 11:50:03.000000000 +0900
@@ -2,15 +2,36 @@
 #define _LINUX_NUMA_H
 
 #include <linux/config.h>
+#include <linux/init.h>
 
 #ifndef CONFIG_FLATMEM
 #include <asm/numnodes.h>
 #endif
 
-#ifndef NODES_SHIFT
-#define NODES_SHIFT     0
+#ifndef NODES_SHIFT_HW
+#define NODES_SHIFT_HW     0
 #endif
 
+#ifdef CONFIG_NUMA_EMU
+#define NODES_SHIFT_EMU CONFIG_NUMA_EMU_SHIFT
+/* in mm/numa_emu.c */
+void numa_emu_setup(char *opt);
+int __init numa_emu_new(int nid, 
+			unsigned long real_start, unsigned long real_end, 
+			unsigned long *emu_start, unsigned long *emu_end);
+int __init numa_emu_shrink(int nid, int new_nodes, 
+			   unsigned long real_start, unsigned long real_end,
+			   unsigned long *emu_start, unsigned long *emu_end);
+/* arch-specific */
+void __init numa_emu_setup_nid(int real_nid);
+#else
+#define NODES_SHIFT_EMU 0
+static inline void numa_emu_setup_nid(int real_nid) {}
+static inline void numa_emu_setup(char *opt) {}
+#endif
+
+#define NODES_SHIFT     (NODES_SHIFT_HW + NODES_SHIFT_EMU)
+
 #define MAX_NUMNODES    (1 << NODES_SHIFT)
 
 #endif /* _LINUX_NUMA_H */
--- from-0002/mm/Kconfig
+++ to-work/mm/Kconfig	2005-11-09 11:50:03.000000000 +0900
@@ -77,6 +77,23 @@ config FLAT_NODE_MEM_MAP
 	def_bool y
 	depends on !SPARSEMEM
 
+config NUMA_EMU
+	bool "NUMA Memory Nodes Emulation"
+	select NUMA
+	depends on ARCH_NUMA_EMU_ENABLE
+	default n
+	help
+	  Enable NUMA emulation. Each node will be split into several virtual
+	  nodes when booted with "numa=fake=N", where N is the number of nodes.
+
+config NUMA_EMU_SHIFT
+	int "Maximum shift number of emulated nodes, per real node (1-8)"
+	range 1 8
+	depends on NUMA_EMU
+	default "3"
+	help
+	  This value controls the maximum number of emulated NUMA nodes.
+
 #
 # Both the NUMA code and DISCONTIGMEM use arrays of pg_data_t's
 # to represent different areas of memory.  This variable allows
--- from-0002/mm/Makefile
+++ to-work/mm/Makefile	2005-11-09 11:50:03.000000000 +0900
@@ -16,6 +16,7 @@ obj-$(CONFIG_SWAP)	+= page_io.o swap_sta
 obj-$(CONFIG_SWAP_PREFETCH) += swap_prefetch.o
 obj-$(CONFIG_HUGETLBFS)	+= hugetlb.o
 obj-$(CONFIG_NUMA) 	+= mempolicy.o
+obj-$(CONFIG_NUMA_EMU) 	+= numa_emu.o
 obj-$(CONFIG_SPARSEMEM)	+= sparse.o
 obj-$(CONFIG_SHMEM) += shmem.o
 obj-$(CONFIG_TINY_SHMEM) += tiny-shmem.o
--- /dev/null
+++ to-work/mm/numa_emu.c	2005-11-09 11:50:04.000000000 +0900
@@ -0,0 +1,118 @@
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/cache.h>
+#include <linux/mm.h>
+#include <linux/numa.h>
+#include <linux/nodemask.h>
+
+extern unsigned long node_start_pfn[MAX_NUMNODES] __read_mostly;
+extern unsigned long node_end_pfn[MAX_NUMNODES] __read_mostly;
+
+int numa_fake __initdata = 0;
+
+void __init numa_emu_setup(char *opt)
+{
+	int max_emu = 1 << CONFIG_NUMA_EMU_SHIFT;
+
+	if (!memcmp(opt, "fake=", 5) && (*(opt + 5))) {
+		numa_fake = simple_strtoul(opt + 5, NULL, 0);
+		numa_fake = min(numa_fake, max_emu);
+		printk("fake numa nodes = %d/%d\n", numa_fake, max_emu);
+       }
+}
+
+unsigned long __init numa_emu_node_size(unsigned long real_size, int last)
+{
+	unsigned long node_size;
+	unsigned long shift;
+
+	if (numa_fake == 0)
+		return 0;
+
+	node_size = real_size / numa_fake;
+
+	if (node_size == 0)
+		return 0;
+
+	shift = 1;
+	while ((1 << shift) <= node_size)
+		shift++;
+
+	shift--;
+
+	node_size = 1 << shift;
+
+#ifdef CONFIG_SPARSEMEM
+	if (node_size * PAGE_SIZE < (1UL << SECTION_SIZE_BITS))
+		return 0;
+#else
+#warning FIXME: Perform similar check for non-sparsemem!
+#endif
+
+	if (last)
+		node_size = real_size - (node_size * (numa_fake - 1));
+
+	return node_size;
+}
+
+int __init numa_emu_new(int nid, 
+			unsigned long real_start, unsigned long real_end, 
+			unsigned long *emu_start, unsigned long *emu_end)
+{
+	int fake_nr = nid >> NODES_SHIFT_HW;
+	unsigned long node_size;
+
+	/* only setup amount of nodes passed on cmdline */
+
+	if (fake_nr >= numa_fake) 
+		return -1;
+
+	node_size = numa_emu_node_size(real_end - real_start, 0);
+
+	if (!node_size)
+		return -1;
+
+	*emu_start = real_start + (fake_nr * node_size);
+
+	if (fake_nr == (numa_fake - 1)) {
+		node_size = numa_emu_node_size(real_end - real_start, 1);
+
+		if (!node_size)
+			return -1;
+
+	}
+
+	*emu_end = *emu_start + node_size;
+	
+	printk("configuring fake node nr %u: pfn %lu - %lu\n", 
+	       nid, *emu_start, *emu_end);
+
+	return 0;
+}
+
+int __init numa_emu_shrink(int nid, int new_nodes, 
+			   unsigned long real_start, unsigned long real_end,
+			   unsigned long *emu_start, unsigned long *emu_end)
+{
+	unsigned long node_size;
+
+	if (numa_fake != (new_nodes + 1))  
+		return -1;
+
+	node_size = numa_emu_node_size(real_end - real_start, 0);
+
+	if (!node_size)
+		return -1;
+
+	*emu_start = real_start;
+	*emu_end = real_start + node_size;
+	
+	printk("configuring real node nr %u: pfn %lu - %lu\n", 
+	       nid, *emu_start, *emu_end);
+
+	printk("NUMA - emulation, adding %u emulated node(s) to node %u\n",
+	       new_nodes, nid);
+
+	return 0;
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
