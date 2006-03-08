Received: from m7.gw.fujitsu.co.jp ([10.0.50.77])
        by fgwmail6.fujitsu.co.jp (Fujitsu Gateway)
        with ESMTP id k28DfMc0013928 for <linux-mm@kvack.org>; Wed, 8 Mar 2006 22:41:22 +0900
        (envelope-from y-goto@jp.fujitsu.com)
Received: from s2.gw.fujitsu.co.jp by m7.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id k28DfKWg022556 for <linux-mm@kvack.org>; Wed, 8 Mar 2006 22:41:20 +0900
	(envelope-from y-goto@jp.fujitsu.com)
Received: from s2.gw.fujitsu.co.jp (s2 [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B6F434E00A5
	for <linux-mm@kvack.org>; Wed,  8 Mar 2006 22:41:20 +0900 (JST)
Received: from ml6.s.css.fujitsu.com (ml6.s.css.fujitsu.com [10.23.4.196])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BDC444E00A8
	for <linux-mm@kvack.org>; Wed,  8 Mar 2006 22:41:19 +0900 (JST)
Date: Wed, 08 Mar 2006 22:41:19 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [PATCH: 002/017](RFC) Memory hotplug for new nodes v.3. (change name old add_memory() to arch_add_memory()) 
Message-Id: <20060308212547.0026.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, Joel Schopp <jschopp@austin.ibm.com>, Dave Hansen <haveblue@us.ibm.com>
Cc: linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

This patch changes name of old add_memory() to arch_add_memory.
and use node id to get pgdat for the node at NODE_DATA().

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

Index: pgdat6/arch/i386/mm/init.c
===================================================================
--- pgdat6.orig/arch/i386/mm/init.c	2006-03-06 19:16:38.000000000 +0900
+++ pgdat6/arch/i386/mm/init.c	2006-03-06 19:34:53.000000000 +0900
@@ -652,7 +652,7 @@ void __init mem_init(void)
  * memory to the highmem for now.
  */
 #ifndef CONFIG_NEED_MULTIPLE_NODES
-int add_memory(u64 start, u64 size)
+int arch_add_memory(int nid, u64 start, u64 size)
 {
 	struct pglist_data *pgdata = &contig_page_data;
 	struct zone *zone = pgdata->node_zones + MAX_NR_ZONES-1;
Index: pgdat6/arch/ia64/mm/init.c
===================================================================
--- pgdat6.orig/arch/ia64/mm/init.c	2006-03-06 19:16:38.000000000 +0900
+++ pgdat6/arch/ia64/mm/init.c	2006-03-06 19:34:53.000000000 +0900
@@ -646,7 +646,7 @@ void online_page(struct page *page)
 	num_physpages++;
 }
 
-int add_memory(u64 start, u64 size)
+int arch_add_memory(int nid, u64 start, u64 size)
 {
 	pg_data_t *pgdat;
 	struct zone *zone;
@@ -654,7 +654,7 @@ int add_memory(u64 start, u64 size)
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	int ret;
 
-	pgdat = NODE_DATA(0);
+	pgdat = NODE_DATA(nid);
 
 	zone = pgdat->node_zones + ZONE_NORMAL;
 	ret = __add_pages(zone, start_pfn, nr_pages);
Index: pgdat6/arch/powerpc/mm/mem.c
===================================================================
--- pgdat6.orig/arch/powerpc/mm/mem.c	2006-03-06 19:16:38.000000000 +0900
+++ pgdat6/arch/powerpc/mm/mem.c	2006-03-06 19:34:53.000000000 +0900
@@ -114,15 +114,13 @@ void online_page(struct page *page)
 	num_physpages++;
 }
 
-int __devinit add_memory(u64 start, u64 size)
+int __devinit arch_add_memory(int nid, u64 start, u64 size)
 {
 	struct pglist_data *pgdata;
 	struct zone *zone;
-	int nid;
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 
-	nid = hot_add_scn_to_nid(start);
 	pgdata = NODE_DATA(nid);
 
 	start = __va(start);
Index: pgdat6/arch/x86_64/mm/init.c
===================================================================
--- pgdat6.orig/arch/x86_64/mm/init.c	2006-03-06 19:16:38.000000000 +0900
+++ pgdat6/arch/x86_64/mm/init.c	2006-03-06 19:34:53.000000000 +0900
@@ -493,9 +493,9 @@ void online_page(struct page *page)
 	num_physpages++;
 }
 
-int add_memory(u64 start, u64 size)
+int arch_add_memory(int nid, u64 start, u64 size)
 {
-	struct pglist_data *pgdat = NODE_DATA(0);
+	struct pglist_data *pgdat = NODE_DATA(nid);
 	struct zone *zone = pgdat->node_zones + MAX_NR_ZONES-2;
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
