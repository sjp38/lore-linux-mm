Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5L5h5i9027065
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 01:43:05 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5L5h4oB289864
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 01:43:05 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5L5h4G0012058
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 01:43:04 -0400
Subject: [RFC] patch [1/1] x86_64 numa aware sparsemem add_memory
	functinality
From: keith mannthey <kmannth@us.ibm.com>
Reply-To: kmannth@us.ibm.com
Content-Type: multipart/mixed; boundary="=-orRQoZpxGayT23uVlKAV"
Date: Tue, 20 Jun 2006 22:43:01 -0700
Message-Id: <1150868581.8518.28.camel@keithlap>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lhms-devel <lhms-devel@lists.sourceforge.net>
Cc: linux-mm <linux-mm@kvack.org>, konrad <darnok@us.ibm.com>, Prarit Bhargava--redhat <prarit@redhat.com>, ak@suse.de
List-ID: <linux-mm.kvack.org>

--=-orRQoZpxGayT23uVlKAV
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hello all,
  This patch is an attempt to add a numa ware add_memory functionality
to x86_64 using CONFIG_SPARSEMEM.  The add memory function today just
grabs the pgdat from node 0 and adds the memory there.  On a numa system
this is functional but not optimal/correct. 

  The SRAT can expose future memory locality.  This information is
already tracked by the nodes_add data structure (it keeps the
memory/node locality information) from the SRAT code.  The code in
srat.c is built around RESERVE_HOTADD.  This patch is a little subtle in
the way it uses the existing code for use with sparsemem.  Perhaps
acpi_numa_memory_affinity_init needs a larger refactor to fit both
RESERVE_HOTADD and sparsemem.  

  This patch still hotadd_percent as a flag to the whole srat parsing
code to disable and contain broken bios.  It's functionality is retained
and an on off switch to sparsemem hot-add.  Without changing the safety
mechanisms build into the current SRAT code I have provided a path for
the sparsemem hot-add path to get to the nodes_add data for use at
runtime. 

  This is a 1st run at the patch, it works with 2.6.17

Signed-off-by:  Keith Mannthey <kmannth@us.ibm.com>

--=-orRQoZpxGayT23uVlKAV
Content-Disposition: attachment; filename=patch-2.6.17-nodes-add-v1.patch
Content-Type: text/x-patch; name=patch-2.6.17-nodes-add-v1.patch; charset=UTF-8
Content-Transfer-Encoding: 7bit

diff -urN linux-2.6.17/arch/x86_64/mm/init.c linux-2.6.17-work/arch/x86_64/mm/init.c
--- linux-2.6.17/arch/x86_64/mm/init.c	2006-06-17 21:49:35.000000000 -0400
+++ linux-2.6.17-work/arch/x86_64/mm/init.c	2006-06-20 21:41:30.000000000 -0400
@@ -553,7 +553,7 @@
  */
 int add_memory(u64 start, u64 size)
 {
-	struct pglist_data *pgdat = NODE_DATA(0);
+	struct pglist_data *pgdat = NODE_DATA(new_memory_to_node(start,start+size));
 	struct zone *zone = pgdat->node_zones + MAX_NR_ZONES-2;
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
diff -urN linux-2.6.17/arch/x86_64/mm/srat.c linux-2.6.17-work/arch/x86_64/mm/srat.c
--- linux-2.6.17/arch/x86_64/mm/srat.c	2006-06-20 20:25:33.000000000 -0400
+++ linux-2.6.17-work/arch/x86_64/mm/srat.c	2006-06-20 21:44:54.000000000 -0400
@@ -32,10 +32,10 @@
 static nodemask_t nodes_parsed __initdata;
 static nodemask_t nodes_found __initdata;
 static struct bootnode nodes[MAX_NUMNODES] __initdata;
-static struct bootnode nodes_add[MAX_NUMNODES] __initdata;
+static struct bootnode nodes_add[MAX_NUMNODES];
 static int found_add_area __initdata;
 int hotadd_percent __initdata = 0;
-#ifndef RESERVE_HOTADD 
+#if !defined(RESERVE_HOTADD) && !defined(CONFIG_MEMORY_HOTPLUG)
 #define hotadd_percent 0	/* Ignore all settings */
 #endif
 static u8 pxm2node[256] = { [0 ... 255] = 0xff };
@@ -219,9 +219,9 @@
 	allocated += mem;
 	return 1;
 }
-
+#endif
 /*
- * It is fine to add this area to the nodes data it will be used later
+ * It is fine to add this area to the nodes_add data it will be used later
  * This code supports one contigious hot add area per node.
  */
 static int reserve_hotadd(int node, unsigned long start, unsigned long end)
@@ -247,15 +247,14 @@
 		printk(KERN_ERR "SRAT: Hotplug area has existing memory\n");
 		return -1;
 	}
-
+#ifdef RESERVE_HOTADD
 	if (!hotadd_enough_memory(&nodes_add[node]))  {
 		printk(KERN_ERR "SRAT: Hotplug area too large\n");
 		return -1;
 	}
-
+#endif 
 	/* Looks good */
 
- 	found_add_area = 1;
 	if (nd->start == nd->end) {
  		nd->start = start;
  		nd->end = end;
@@ -273,14 +272,16 @@
 			printk(KERN_ERR "SRAT: Hotplug zone not continuous. Partly ignored\n");
  	}
 
- 	if ((nd->end >> PAGE_SHIFT) > end_pfn)
- 		end_pfn = nd->end >> PAGE_SHIFT;
-
 	if (changed)
 	 	printk(KERN_INFO "SRAT: hot plug zone found %Lx - %Lx\n", nd->start, nd->end);
+#ifdef RESERVE_HOTADD	
+ 	found_add_area = 1;
+	if ((nd->end >> PAGE_SHIFT) > end_pfn)
+ 		end_pfn = nd->end >> PAGE_SHIFT;
 	return 0;
+#endif 
+	return -1;
 }
-#endif
 
 /* Callback for parsing of the Proximity Domain <-> Memory Area mappings */
 void __init
@@ -338,7 +339,6 @@
 	printk(KERN_INFO "SRAT: Node %u PXM %u %Lx-%Lx\n", node, pxm,
 	       nd->start, nd->end);
 
-#ifdef RESERVE_HOTADD
  	if (ma->flags.hot_pluggable && reserve_hotadd(node, start, end) < 0) {
 		/* Ignore hotadd region. Undo damage */
 		printk(KERN_NOTICE "SRAT: Hotplug region ignored\n");
@@ -346,7 +346,6 @@
 		if ((nd->start | nd->end) == 0)
 			node_clear(node, nodes_parsed);
 	}
-#endif
 }
 
 /* Sanity check to catch more bad SRATs (they are amazingly common).
@@ -479,5 +478,15 @@
 	index = acpi_slit->localities * node_to_pxm(a);
 	return acpi_slit->entry[index + node_to_pxm(b)];
 }
-
 EXPORT_SYMBOL(__node_distance);
+
+int new_memory_to_node(unsigned long start, unsigned long end) {
+	int i,ret;
+	ret=0;
+	for_each_node(i){
+		if (nodes_add[i].start <= start && nodes_add[i].end >= end)
+			ret = i;		
+	}
+	return ret;
+}
+EXPORT_SYMBOL(new_memory_to_node);

--=-orRQoZpxGayT23uVlKAV--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
