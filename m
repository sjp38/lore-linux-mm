Date: Fri, 23 Aug 2002 16:09:44 -0700
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Cleanup i386 discontigmem [2/2]
Message-ID: <75050000.1030144184@flay>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This mainly just rips out some magic extra structures in the boot time
code to determine node sizes, and counts in pages instead of bytes.
Oh, and I put the code that allocates pgdat into allocage_pgdat,
instead of find_max_pfn_node, which seems like an incongruous home
for it.

No functionality changes, nothing touched outside i386 discontigmem ... 
just makes code cleaner and more readable. Tested on 16-way NUMA-Q.

Please apply to your tree, and feed upwards ;-)

M.

------------------

diff -urN -X /home/mbligh/.diff.exclude 2.5.31-25-clean_plat/arch/i386/kernel/numaq.c 2.5.31-26-clean_boot/arch/i386/kernel/numaq.c
--- 2.5.31-25-clean_plat/arch/i386/kernel/numaq.c	Wed Aug 21 17:36:48 2002
+++ 2.5.31-26-clean_boot/arch/i386/kernel/numaq.c	Fri Aug 23 09:32:43 2002
@@ -29,8 +29,11 @@
 #include <linux/mmzone.h>
 #include <asm/numaq.h>
 
-u64 nodes_mem_start[MAX_NUMNODES];
-u64 nodes_mem_size[MAX_NUMNODES];
+/* These are needed before the pgdat's are created */
+unsigned long node_start_pfn[MAX_NUMNODES];
+unsigned long node_end_pfn[MAX_NUMNODES];
+
+#define	MB_TO_PAGES(addr) ((addr) << (20 - PAGE_SHIFT))
 
 /*
  * Function: smp_dump_qct()
@@ -46,17 +49,16 @@
 	struct sys_cfg_data *scd =
 		(struct sys_cfg_data *)__va(SYS_CFG_DATA_PRIV_ADDR);
 
-#define	MB_TO_B(addr) ((addr) << 20)
 	numnodes = 0;
 	for(node = 0; node < MAX_NUMNODES; node++) {
 		if(scd->quads_present31_0 & (1 << node)) {
 			numnodes++;
 			eq = &scd->eq[node];
-			/* Convert to bytes */
-			nodes_mem_start[node] = MB_TO_B((u64)eq->hi_shrd_mem_start -
-							(u64)eq->priv_mem_size);
-			nodes_mem_size[node] = MB_TO_B((u64)eq->hi_shrd_mem_size +
-						       (u64)eq->priv_mem_size);
+			/* Convert to pages */
+			node_start_pfn[node] = MB_TO_PAGES(
+				eq->hi_shrd_mem_start - eq->priv_mem_size);
+			node_end_pfn[node] = MB_TO_PAGES(
+				eq->hi_shrd_mem_start + eq->hi_shrd_mem_size);
 		}
 	}
 }
diff -urN -X /home/mbligh/.diff.exclude 2.5.31-25-clean_plat/arch/i386/mm/discontig.c 2.5.31-26-clean_boot/arch/i386/mm/discontig.c
--- 2.5.31-25-clean_plat/arch/i386/mm/discontig.c	Fri Aug 23 11:56:48 2002
+++ 2.5.31-26-clean_boot/arch/i386/mm/discontig.c	Fri Aug 23 11:57:09 2002
@@ -34,20 +34,14 @@
 #include <asm/e820.h>
 #include <asm/setup.h>
 
-struct pfns {
-	unsigned long start_pfn;
-	unsigned long max_pfn;
-};
-
 struct pglist_data *node_data[MAX_NUMNODES];
-bootmem_data_t plat_node_bdata;
-struct pfns plat_node_bootpfns[MAX_NUMNODES];
+bootmem_data_t node0_bdata;
 
 extern unsigned long find_max_low_pfn(void);
 extern void find_max_pfn(void);
 extern void one_highpage_init(struct page *, int, int);
 
-extern u64 nodes_mem_start[], nodes_mem_size[];
+extern unsigned long node_start_pfn[], node_end_pfn[];
 extern struct e820map e820;
 extern char _end;
 extern unsigned long highend_pfn, highstart_pfn;
@@ -60,22 +54,22 @@
  */
 static void __init find_max_pfn_node(int nid)
 {
-	unsigned long node_datasz;
-	unsigned long start, end;
-
-	start = plat_node_bootpfns[nid].start_pfn = PFN_UP(nodes_mem_start[nid]);
-	end = PFN_DOWN(nodes_mem_start[nid]) + PFN_DOWN(nodes_mem_size[nid]);
-
-	if (start >= end) {
+	if (node_start_pfn[nid] >= node_end_pfn[nid])
 		BUG();
-	}
-	if (end > max_pfn) {
-		end = max_pfn;
-	}
-	plat_node_bootpfns[nid].max_pfn = end;
+	if (node_end_pfn[nid] > max_pfn)
+		node_end_pfn[nid] = max_pfn;
+}
+
+/* 
+ * Allocate memory for the pg_data_t via a crude pre-bootmem method
+ * We ought to relocate these onto their own node later on during boot.
+ */
+static void __init allocate_pgdat(int nid)
+{
+	unsigned long node_datasz;
 
 	node_datasz = PFN_UP(sizeof(struct pglist_data));
-	NODE_DATA(nid) = (struct pglist_data *)(__va(min_low_pfn << PAGE_SHIFT));
+	NODE_DATA(nid) = (pg_data_t *)(__va(min_low_pfn << PAGE_SHIFT));
 	min_low_pfn += node_datasz;
 }
 
@@ -147,12 +141,11 @@
 			pages_to_mb(system_max_low_pfn));
 	
 	for (nid = 0; nid < numnodes; nid++)
-	{	
+		allocate_pgdat(nid);
+	for (nid = 0; nid < numnodes; nid++)
 		find_max_pfn_node(nid);
 
-	}
-
-	NODE_DATA(0)->bdata = &plat_node_bdata;
+	NODE_DATA(0)->bdata = &node0_bdata;
 
 	/*
 	 * Initialize the boot-time allocator (with low memory only):
@@ -231,8 +224,8 @@
 		unsigned int max_dma;
 
 		unsigned long low = max_low_pfn;
-		unsigned long high = plat_node_bootpfns[nid].max_pfn;
-		unsigned long start = plat_node_bootpfns[nid].start_pfn;
+		unsigned long start = node_start_pfn[nid];
+		unsigned long high = node_end_pfn[nid];
 		
 		max_dma = virt_to_phys((char *)MAX_DMA_ADDRESS) >> PAGE_SHIFT;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
