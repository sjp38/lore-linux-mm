Date: Thu, 31 Jul 2008 21:04:31 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [RFC:Patch: 008/008](memory hotplug) remove_pgdat() function
In-Reply-To: <20080731203549.2A3F.E1E9C6FF@jp.fujitsu.com>
References: <20080731203549.2A3F.E1E9C6FF@jp.fujitsu.com>
Message-Id: <20080731210326.2A51.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

remove_pgdat() is main code for pgdat removing.
remove_pgdat() should be called for node-hotremove, but nothing calls
it. Sysfs interface (or anything else?) will be necessary.

And current offline_pages() has to be update zonelist and N_HIGH_MEMORY
if there is no present_pages on the node, and stop kswapd().


Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>


---
 mm/memory_hotplug.c |   85 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 84 insertions(+), 1 deletion(-)

Index: current/mm/memory_hotplug.c
===================================================================
--- current.orig/mm/memory_hotplug.c	2008-07-29 22:17:24.000000000 +0900
+++ current/mm/memory_hotplug.c	2008-07-29 22:17:32.000000000 +0900
@@ -241,6 +241,82 @@ static int __add_section(struct zone *zo
 	return register_new_memory(__pfn_to_section(phys_start_pfn));
 }
 
+static int cpus_busy_on_node(int nid)
+{
+	cpumask_t tmp = node_to_cpumask(nid);
+	int cpu, ret;
+
+	for_each_cpu_mask(cpu, tmp) {
+		if (cpu_online(cpu)) {
+			printk(KERN_INFO "cpu %d is busy\n", cpu);
+			ret = 1 ;
+		}
+	}
+	return 0;
+}
+
+static int sections_busy_on_node(struct pglist_data *pgdat)
+{
+	unsigned long section_nr, num, i;
+	int ret = 0;
+
+	section_nr = pfn_to_section_nr(pgdat->node_start_pfn);
+	num = pfn_to_section_nr(pgdat->node_spanned_pages);
+
+	for (i = section_nr; i < num; i++) {
+		if (present_section_nr(i)) {
+			printk(KERN_INFO "section %ld is busy\n", i);
+			ret = 1;
+		}
+	}
+	return ret;
+}
+
+void free_pgdat(int offline_nid, struct pglist_data *pgdat)
+{
+	struct page *page = virt_to_page(pgdat);
+
+	arch_refresh_nodedata(offline_nid, NULL);
+
+	if (PageSlab(page)) {
+		/* This pgdat is allocated on other node via hot-add */
+		arch_free_nodedata(pgdat);
+		return;
+	}
+
+	if (offline_nid != page_to_nid(page)) {
+		/* This pgdat is allocated on other node as memoryless node */
+		put_page_bootmem(page);
+		return;
+	}
+
+	/*
+	 * Ok. This pgdat is same node of offlining node.
+	 * Don't free it. Because this area will be removed physically at
+	 * next step.
+	 */
+
+}
+
+int remove_pgdat(int nid)
+{
+	struct pglist_data *pgdat = NODE_DATA(nid);
+
+	if (cpus_busy_on_node(nid))
+		return -EBUSY;
+
+	if (sections_busy_on_node(pgdat))
+		return -EBUSY;
+
+	node_set_offline(nid);
+	synchronize_sched();
+	synchronize_srcu(&pgdat_remove_srcu);
+
+	free_pgdat(nid, pgdat);
+
+	return 0;
+}
+
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
 static int __remove_section(struct zone *zone, struct mem_section *ms)
 {
@@ -473,7 +549,6 @@ static void rollback_node_hotadd(int nid
 	return;
 }
 
-
 int add_memory(int nid, u64 start, u64 size)
 {
 	pg_data_t *pgdat = NULL;
@@ -842,6 +917,14 @@ repeat:
 	vm_total_pages = nr_free_pagecache_pages();
 	writeback_set_ratelimit();
 
+	if (zone->present_pages == 0)
+		build_all_zonelists();
+
+	if (zone->zone_pgdat->node_present_pages == 0) {
+		node_clear_state(node, N_HIGH_MEMORY);
+		kswapd_stop(node);
+	}
+
 	memory_notify(MEM_OFFLINE, &arg);
 	return 0;
 

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
