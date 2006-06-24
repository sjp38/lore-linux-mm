Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5O25Hor017505
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Fri, 23 Jun 2006 22:05:17 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5O25Tb4172700
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Fri, 23 Jun 2006 20:05:29 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5O25GvM014035
	for <linux-mm@kvack.org>; Fri, 23 Jun 2006 20:05:16 -0600
Subject: [RFC] Patch [1/4] x86_64 sparsmem add- save nodes_add data for
	later
From: keith mannthey <kmannth@us.ibm.com>
Reply-To: kmannth@us.ibm.com
In-Reply-To: <1151082833.10877.13.camel@localhost.localdomain>
References: <1150868581.8518.28.camel@keithlap>
	 <1151082833.10877.13.camel@localhost.localdomain>
Content-Type: multipart/mixed; boundary="=-CrkB3hd0g3x1zjpaqsOk"
Date: Fri, 23 Jun 2006 19:05:15 -0700
Message-Id: <1151114715.7094.49.camel@keithlap>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lhms-devel <lhms-devel@lists.sourceforge.net>
Cc: linux-mm <linux-mm@kvack.org>, ak@suse.de, dave hansen <haveblue@us.ibm.com>, kame <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

--=-CrkB3hd0g3x1zjpaqsOk
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hello All,
  The following patch reserves the nodes_add data for use later.  It
retains the bulk of the hotadd_precent defense that is built into the
SRAT code. It is a little subtle but it gets the job done.  

  The code saves off the hot-add area ranges without extending the end
of memory.  It then creates arch_find_node which will be use in the next
patch.  

 arch_find_node is passed a memory range and it looks for a nodes_add
area it fits into.   If no area is found it returns 0.

 With this and the other 3 patches I can do SPARSEMEM x86_64 hot-add on
my hardware. (the first 2 patches are one I consider real the other 2
are more to point out issues)

 It is built against 2.6.17-mm1 x86_64 and the current memory_hotplug
work but should apply on any current srat.c

Signed-off-by:  Keith Mannthey <kmannth@us.ibm.com>


--=-CrkB3hd0g3x1zjpaqsOk
Content-Disposition: attachment; filename=patch-2.6.17-mm1-save_nodes_add
Content-Type: text/x-patch; name=patch-2.6.17-mm1-save_nodes_add; charset=UTF-8
Content-Transfer-Encoding: 7bit

diff -urN linux-2.6.17-mm1-orig/arch/x86_64/mm/srat.c linux-2.6.17-mm1/arch/x86_64/mm/srat.c
--- linux-2.6.17-mm1-orig/arch/x86_64/mm/srat.c	2006-06-23 16:12:00.000000000 -0400
+++ linux-2.6.17-mm1/arch/x86_64/mm/srat.c	2006-06-23 18:43:03.000000000 -0400
@@ -34,9 +34,6 @@
 static struct bootnode nodes_add[MAX_NUMNODES] __initdata;
 static int found_add_area __initdata;
 int hotadd_percent __initdata = 0;
-#ifndef RESERVE_HOTADD
-#define hotadd_percent 0	/* Ignore all settings */
-#endif
 
 /* Too small nodes confuse the VM badly. Usually they result
    from BIOS bugs. */
@@ -199,9 +196,9 @@
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
@@ -227,15 +224,14 @@
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
@@ -253,14 +249,16 @@
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
@@ -318,7 +316,6 @@
 	printk(KERN_INFO "SRAT: Node %u PXM %u %Lx-%Lx\n", node, pxm,
 	       nd->start, nd->end);
 
-#ifdef RESERVE_HOTADD
  	if (ma->flags.hot_pluggable && reserve_hotadd(node, start, end) < 0) {
 		/* Ignore hotadd region. Undo damage */
 		printk(KERN_NOTICE "SRAT: Hotplug region ignored\n");
@@ -326,7 +323,6 @@
 		if ((nd->start | nd->end) == 0)
 			node_clear(node, nodes_parsed);
 	}
-#endif
 }
 
 /* Sanity check to catch more bad SRATs (they are amazingly common).
@@ -450,3 +446,14 @@
 }
 
 EXPORT_SYMBOL(__node_distance);
+
+int arch_find_node(unsigned long start, unsigned long size) {
+	int i, ret = 0;
+	unsigned long end = start+size;
+
+	for_each_node(i){
+		if (nodes_add[i].start <= start && nodes_add[i].end >= end)
+			ret = i;
+	}
+	return ret;
+}

--=-CrkB3hd0g3x1zjpaqsOk--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
