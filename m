Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
        by fgwmail7.fujitsu.co.jp (Fujitsu Gateway)
        with ESMTP id k28DfSpm010439 for <linux-mm@kvack.org>; Wed, 8 Mar 2006 22:41:28 +0900
        (envelope-from y-goto@jp.fujitsu.com)
Received: from s13.gw.fujitsu.co.jp by m3.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id k28DfR0Y027818 for <linux-mm@kvack.org>; Wed, 8 Mar 2006 22:41:27 +0900
	(envelope-from y-goto@jp.fujitsu.com)
Received: from s13.gw.fujitsu.co.jp (s13 [127.0.0.1])
	by s13.gw.fujitsu.co.jp (Postfix) with ESMTP id 3470E1CC104
	for <linux-mm@kvack.org>; Wed,  8 Mar 2006 22:41:27 +0900 (JST)
Received: from ml4.s.css.fujitsu.com (ml4.s.css.fujitsu.com [10.23.4.194])
	by s13.gw.fujitsu.co.jp (Postfix) with ESMTP id A90461CC100
	for <linux-mm@kvack.org>; Wed,  8 Mar 2006 22:41:26 +0900 (JST)
Date: Wed, 08 Mar 2006 22:41:26 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [PATCH: 003/017](RFC) Memory hotplug for new nodes v.3.(get node id at probe memory)
Message-Id: <20060308212646.0028.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, Joel Schopp <jschopp@austin.ibm.com>, Dave Hansen <haveblue@us.ibm.com>
Cc: linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

When CONFIG_NUMA && CONFIG_ARCH_MEMORY_PROBE, nid should be defined
before calling add_memory_node(nid, start, size).

Each arch , which supports CONFIG_NUMA && ARCH_MEMORY_PROBE, should
define arch_nid_probe(paddr);

Powerpc has nice function. X86_64 has not.....

Note:
If memory is hot-plugged by firmware, there is another *good* information
like pxm.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

Index: pgdat6/arch/powerpc/mm/mem.c
===================================================================
--- pgdat6.orig/arch/powerpc/mm/mem.c	2006-03-06 19:34:53.000000000 +0900
+++ pgdat6/arch/powerpc/mm/mem.c	2006-03-06 19:39:51.000000000 +0900
@@ -114,6 +114,11 @@ void online_page(struct page *page)
 	num_physpages++;
 }
 
+int __devinit arch_nid_probe(u64 start)
+{
+	return hot_add_scn_to_nid(start);
+}
+
 int __devinit arch_add_memory(int nid, u64 start, u64 size)
 {
 	struct pglist_data *pgdata;
Index: pgdat6/include/linux/memory_hotplug.h
===================================================================
--- pgdat6.orig/include/linux/memory_hotplug.h	2006-03-06 19:34:47.000000000 +0900
+++ pgdat6/include/linux/memory_hotplug.h	2006-03-06 19:40:57.000000000 +0900
@@ -63,6 +63,15 @@ extern int online_pages(unsigned long, u
 /* reasonably generic interface to expand the physical pages in a zone  */
 extern int __add_pages(struct zone *zone, unsigned long start_pfn,
 	unsigned long nr_pages);
+#if defined(CONFIG_NUMA) && defined(CONFIG_ARCH_MEMORY_PROBE)
+extern int arch_nid_probe(u64 start);
+#else
+static inline int arch_nid_probe(u64 start)
+{
+	return 0;
+}
+#endif
+
 #else /* ! CONFIG_MEMORY_HOTPLUG */
 /*
  * Stub functions for when hotplug is off
Index: pgdat6/drivers/base/memory.c
===================================================================
--- pgdat6.orig/drivers/base/memory.c	2006-03-06 19:16:37.000000000 +0900
+++ pgdat6/drivers/base/memory.c	2006-03-06 19:39:51.000000000 +0900
@@ -310,7 +310,8 @@ memory_probe_store(struct class *class, 
 
 	phys_addr = simple_strtoull(buf, NULL, 0);
 
-	ret = add_memory(phys_addr, PAGES_PER_SECTION << PAGE_SHIFT);
+	ret = add_memory_node(arch_nid_probe(phys_addr),
+			 phys_addr, PAGES_PER_SECTION << PAGE_SHIFT);
 
 	if (ret)
 		count = ret;
Index: pgdat6/arch/x86_64/mm/init.c
===================================================================
--- pgdat6.orig/arch/x86_64/mm/init.c	2006-03-06 19:34:53.000000000 +0900
+++ pgdat6/arch/x86_64/mm/init.c	2006-03-06 19:39:51.000000000 +0900
@@ -493,6 +493,11 @@ void online_page(struct page *page)
 	num_physpages++;
 }
 
+int arch_nid_probe(u64 start)
+{
+	return 0;
+}
+
 int arch_add_memory(int nid, u64 start, u64 size)
 {
 	struct pglist_data *pgdat = NODE_DATA(nid);

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
