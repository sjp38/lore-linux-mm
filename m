Date: Tue, 02 May 2006 20:35:58 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch 003/003] pgdat allocation and update for ia64 of memory hotplug.(allocate pgdat and per node data)
In-Reply-To: <20060502201614.CF14.Y-GOTO@jp.fujitsu.com>
References: <20060502201614.CF14.Y-GOTO@jp.fujitsu.com>
Message-Id: <20060502203414.CF1C.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, "Luck, Tony" <tony.luck@intel.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a patch to allocate pgdat and per node data area for ia64.
The size for them can be calculated by compute_pernodesize().

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

 arch/ia64/mm/discontig.c       |   16 ++++++++++++++--
 include/linux/memory_hotplug.h |    9 ++-------
 2 files changed, 16 insertions(+), 9 deletions(-)

Index: pgdat12/arch/ia64/mm/discontig.c
===================================================================
--- pgdat12.orig/arch/ia64/mm/discontig.c	2006-04-28 10:31:49.000000000 +0900
+++ pgdat12/arch/ia64/mm/discontig.c	2006-04-28 10:32:31.000000000 +0900
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
 
@@ -792,6 +792,18 @@ void __init paging_init(void)
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
Index: pgdat12/include/linux/memory_hotplug.h
===================================================================
--- pgdat12.orig/include/linux/memory_hotplug.h	2006-04-28 10:31:49.000000000 +0900
+++ pgdat12/include/linux/memory_hotplug.h	2006-04-28 10:33:17.000000000 +0900
@@ -84,13 +84,8 @@ static inline int memofy_add_physaddr_to
  * Now, arch_free_nodedata() is just defined for error path of node_hot_add.
  *
  */
-static inline pg_data_t *arch_alloc_nodedata(int nid)
-{
-	return NULL;
-}
-static inline void arch_free_nodedata(pg_data_t *pgdat)
-{
-}
+extern pg_data_t *arch_alloc_nodedata(int nid);
+extern void arch_free_nodedata(pg_data_t *pgdat);
 extern void arch_refresh_nodedata(int nid, pg_data_t *pgdat);
 
 #else /* CONFIG_HAVE_ARCH_NODEDATA_EXTENSION */

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
