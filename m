Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5O25nKe021183
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Fri, 23 Jun 2006 22:05:49 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5O25NI4282588
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Fri, 23 Jun 2006 20:05:23 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5O25nPx015394
	for <linux-mm@kvack.org>; Fri, 23 Jun 2006 20:05:49 -0600
Subject: [RFC] Patch [2/4] x86_64 sparsmem add - implement arch_find_node
	in memory_hotplug code.
From: keith mannthey <kmannth@us.ibm.com>
Reply-To: kmannth@us.ibm.com
Content-Type: multipart/mixed; boundary="=-T1xJQ/DWxYPZ8SYr6pR5"
Date: Fri, 23 Jun 2006 19:05:48 -0700
Message-Id: <1151114748.7094.51.camel@keithlap>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lhms-devel <lhms-devel@lists.sourceforge.net>
Cc: linux-mm <linux-mm@kvack.org>, dave hansen <haveblue@us.ibm.com>, kame <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

--=-T1xJQ/DWxYPZ8SYr6pR5
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

  The current MEMORY_HOTPLUG code expects that the ACPI layer (for the
Intel space) will pass along the _PXM data (this is node locality data).
This is an optional field for the acpi namespace and one which Linux
should not require for hot-add memory. 

  This patch creates uses the arch_find_node function and wedges it into
the generic add_memory function.  When the acpi can't resolve the _PXM
data (as in my hardware event) it returns -1.  I build a check into
add_memory that looks for invalid data passes id < 0 and calls
arch_find_node.  
  
  I intend to implement an arch_find_node for i386 in the near
future.     


Signed-off-by:  Keith Mannthey <kmannth@us.ibm.com>

--=-T1xJQ/DWxYPZ8SYr6pR5
Content-Disposition: attachment; filename=patch-2.6.17-mm1-use_arch_find_node
Content-Type: text/x-patch; name=patch-2.6.17-mm1-use_arch_find_node; charset=UTF-8
Content-Transfer-Encoding: 7bit

diff -urN linux-2.6.17-mm1-orig/arch/x86_64/Kconfig linux-2.6.17-mm1/arch/x86_64/Kconfig
--- linux-2.6.17-mm1-orig/arch/x86_64/Kconfig	2006-06-23 16:12:00.000000000 -0400
+++ linux-2.6.17-mm1/arch/x86_64/Kconfig	2006-06-23 20:35:03.000000000 -0400
@@ -335,6 +335,10 @@
 	def_bool y
 	depends on MEMORY_HOTPLUG
 
+config ARCH_FIND_NODE
+	def_bool y
+	depends on MEMORY_HOTPLUG
+
 config ARCH_FLATMEM_ENABLE
 	def_bool y
 	depends on !NUMA
diff -urN linux-2.6.17-mm1-orig/include/linux/memory_hotplug.h linux-2.6.17-mm1/include/linux/memory_hotplug.h
--- linux-2.6.17-mm1-orig/include/linux/memory_hotplug.h	2006-06-23 16:12:09.000000000 -0400
+++ linux-2.6.17-mm1/include/linux/memory_hotplug.h	2006-06-23 20:35:03.000000000 -0400
@@ -132,7 +132,11 @@
 }
 #endif /* CONFIG_NUMA */
 #endif /* CONFIG_HAVE_ARCH_NODEDATA_EXTENSION */
-
+#ifdef CONFIG_ARCH_FIND_NODE
+	extern int arch_find_node(unsigned long, unsigned long);
+#else
+	static inline int arch_find_node(unsigned long a,  unsigned long b) {return 0;}
+#endif
 #else /* ! CONFIG_MEMORY_HOTPLUG */
 /*
  * Stub functions for when hotplug is off
diff -urN linux-2.6.17-mm1-orig/mm/memory_hotplug.c linux-2.6.17-mm1/mm/memory_hotplug.c
--- linux-2.6.17-mm1-orig/mm/memory_hotplug.c	2006-06-23 16:12:10.000000000 -0400
+++ linux-2.6.17-mm1/mm/memory_hotplug.c	2006-06-23 20:35:03.000000000 -0400
@@ -234,12 +234,17 @@
 
 
 
-int add_memory(int nid, u64 start, u64 size)
+int add_memory(int node, u64 start, u64 size)
 {
 	pg_data_t *pgdat = NULL;
 	int new_pgdat = 0;
-	int ret;
+	int ret,nid;
 
+	if (node < 0) 
+		nid = arch_find_node(start,size);
+	else
+		nid = node;
+	
 	if (!node_online(nid)) {
 		pgdat = hotadd_new_pgdat(nid, start);
 		if (!pgdat)

--=-T1xJQ/DWxYPZ8SYr6pR5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
