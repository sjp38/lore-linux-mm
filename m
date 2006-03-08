Received: from m7.gw.fujitsu.co.jp ([10.0.50.77])
        by fgwmail5.fujitsu.co.jp (Fujitsu Gateway)
        with ESMTP id k28DhDUJ007399 for <linux-mm@kvack.org>; Wed, 8 Mar 2006 22:43:13 +0900
        (envelope-from y-goto@jp.fujitsu.com)
Received: from s2.gw.fujitsu.co.jp by m7.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id k28DhDWg023680 for <linux-mm@kvack.org>; Wed, 8 Mar 2006 22:43:13 +0900
	(envelope-from y-goto@jp.fujitsu.com)
Received: from s2.gw.fujitsu.co.jp (s2 [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1EB3E4E00AD
	for <linux-mm@kvack.org>; Wed,  8 Mar 2006 22:43:13 +0900 (JST)
Received: from ml6.s.css.fujitsu.com (ml6.s.css.fujitsu.com [10.23.4.196])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id AC0CE4E00AA
	for <linux-mm@kvack.org>; Wed,  8 Mar 2006 22:43:12 +0900 (JST)
Date: Wed, 08 Mar 2006 22:43:12 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [PATCH: 017/017](RFC) Memory hotplug for new nodes v.3. (arch_register_node() for ia64)
Message-Id: <20060308214141.0044.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, Joel Schopp <jschopp@austin.ibm.com>, Dave Hansen <haveblue@us.ibm.com>
Cc: linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

This is to create sysfs file for new node.
It adds arch specific functions 'arch_register_node()'
and 'arch_unregister_node()' to IA64 to call the generic
function 'register_node()' and 'unregister_node()' respectively.

(Each arch defines like sysfs_nodes[] to describe its nodes
 topology. I'm not sure they can be merged as generic code.)

Signed-off-by: Keiichiro Tokunaga <tokuanga.keiich@jp.fujitsu.com>
Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

Index: pgdat6/arch/ia64/kernel/topology.c
===================================================================
--- pgdat6.orig/arch/ia64/kernel/topology.c	2006-03-06 18:25:31.000000000 +0900
+++ pgdat6/arch/ia64/kernel/topology.c	2006-03-06 18:26:33.000000000 +0900
@@ -65,6 +65,21 @@ EXPORT_SYMBOL(arch_register_cpu);
 EXPORT_SYMBOL(arch_unregister_cpu);
 #endif /*CONFIG_HOTPLUG_CPU*/
 
+#ifdef CONFIG_NUMA
+int arch_register_node(int num)
+{
+	if (sysfs_nodes[num].sysdev.id == num)
+		return 0;
+
+	return register_node(&sysfs_nodes[num], num, 0);
+}
+
+void arch_unregister_node(int num)
+{
+	unregister_node(&sysfs_nodes[num]);
+	sysfs_nodes[num].sysdev.id = -1;
+}
+#endif
 
 static int __init topology_init(void)
 {
Index: pgdat6/include/asm-ia64/numa.h
===================================================================
--- pgdat6.orig/include/asm-ia64/numa.h	2006-03-06 18:24:01.000000000 +0900
+++ pgdat6/include/asm-ia64/numa.h	2006-03-06 18:26:33.000000000 +0900
@@ -23,6 +23,9 @@
 
 #include <asm/mmzone.h>
 
+extern int arch_register_node(int num);
+extern void arch_unregister_node(int num);
+
 extern u8 cpu_to_node_map[NR_CPUS] __cacheline_aligned;
 extern cpumask_t node_to_cpu_mask[MAX_NUMNODES] __cacheline_aligned;
 

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
