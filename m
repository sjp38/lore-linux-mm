Date: Fri, 17 Mar 2006 17:21:38 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [PATCH: 008/017]Memory hotplug for new nodes v.4.(allocate pgdat for ia64)
Message-Id: <20060317163324.C647.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a patch to allocate pgdat and per node data area for ia64.
The size for them can be calculated by compute_pernodesize().

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

 arch/ia64/mm/discontig.c |   16 ++++++++++++++--
 1 files changed, 14 insertions(+), 2 deletions(-)

Index: pgdat8/arch/ia64/mm/discontig.c
===================================================================
--- pgdat8.orig/arch/ia64/mm/discontig.c	2006-03-16 21:20:31.251828760 +0900
+++ pgdat8/arch/ia64/mm/discontig.c	2006-03-16 21:21:25.615109344 +0900
@@ -100,7 +100,7 @@ static int __init build_node_maps(unsign
  * acpi_boot_init() (which builds the node_to_cpu_mask array) hasn't been
  * called yet.  Note that node 0 will also count all non-existent cpus.
  */
-static int __init early_nr_cpus_node(int node)
+static int __meminit early_nr_cpus_node(int node)
 {
 	int cpu, n = 0;
 
@@ -115,7 +115,7 @@ static int __init early_nr_cpus_node(int
  * compute_pernodesize - compute size of pernode data
  * @node: the node id.
  */
-static unsigned long __init compute_pernodesize(int node)
+static unsigned long __meminit compute_pernodesize(int node)
 {
 	unsigned long pernodesize = 0, cpus;
 
@@ -728,6 +728,18 @@ void __init paging_init(void)
 	zero_page_memmap_ptr = virt_to_page(ia64_imva(empty_zero_page));
 }
 
+pg_data_t *arch_alloc_nodedata(int nid)
+{
+	unsigned long size = compute_pernodesize(nid);
+
+	return kzalloc(size, GFP_KERNEL);
+}
+
+void arch_free_nodedata(pg_data_t *pgdat)
+{
+	kfree(pgdat);
+}
+
 void arch_refresh_nodedata(int update_node, pg_data_t *update_pgdat)
 {
 	pgdat_list[update_node] = update_pgdat;

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
