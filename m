Date: Fri, 23 Aug 2002 16:09:43 -0700
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Cleanup i386 discontigmem [1/2]
Message-ID: <74990000.1030144183@flay>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This mainly changes the PLAT_MY_MACRO_IS_ALL_CAPS()
stuff to be normal_macro(), and takes out some unnecessary
redirection of function names. No functionality changes, nothing
touched outside i386 discontigmem ... just makes code readable.
Rumour has it that the PLAT_* stuff came from IRIX - I don't see
that as a good reason to make the Linux code unreadable.
Tested on 16-way NUMA-Q.

Please apply to your tree, and feed upwards ;-)

M.

----------------------

diff -urN -X /home/mbligh/.diff.exclude 2.5.31-22-pmd_populate/arch/i386/kernel/numaq.c 2.5.31-25-clean_plat/arch/i386/kernel/numaq.c
--- 2.5.31-22-pmd_populate/arch/i386/kernel/numaq.c	Fri Aug 16 11:26:20 2002
+++ 2.5.31-25-clean_plat/arch/i386/kernel/numaq.c	Wed Aug 21 17:36:48 2002
@@ -83,7 +83,7 @@
 #define MB_TO_ELEMENT(x) (x >> ELEMENT_REPRESENTS)
 #define PA_TO_MB(pa) (pa >> 20) 	/* assumption: a physical address is in bytes */
 
-int numaqpa_to_nid(u64 pa)
+int pa_to_nid(u64 pa)
 {
 	int nid;
 	
@@ -96,9 +96,9 @@
 	return nid;
 }
 
-int numaqpfn_to_nid(unsigned long pfn)
+int pfn_to_nid(unsigned long pfn)
 {
-	return numaqpa_to_nid(((u64)pfn) << PAGE_SHIFT);
+	return pa_to_nid(((u64)pfn) << PAGE_SHIFT);
 }
 
 /*
diff -urN -X /home/mbligh/.diff.exclude 2.5.31-22-pmd_populate/arch/i386/mm/discontig.c 2.5.31-25-clean_plat/arch/i386/mm/discontig.c
--- 2.5.31-22-pmd_populate/arch/i386/mm/discontig.c	Fri Aug 16 11:26:20 2002
+++ 2.5.31-25-clean_plat/arch/i386/mm/discontig.c	Fri Aug 23 11:56:48 2002
@@ -39,7 +39,7 @@
 	unsigned long max_pfn;
 };
 
-struct plat_pglist_data *plat_node_data[MAX_NUMNODES];
+struct pglist_data *node_data[MAX_NUMNODES];
 bootmem_data_t plat_node_bdata;
 struct pfns plat_node_bootpfns[MAX_NUMNODES];
 
@@ -74,8 +74,8 @@
 	}
 	plat_node_bootpfns[nid].max_pfn = end;
 
-	node_datasz = PFN_UP(sizeof(struct plat_pglist_data));
-	PLAT_NODE_DATA(nid) = (struct plat_pglist_data *)(__va(min_low_pfn << PAGE_SHIFT));
+	node_datasz = PFN_UP(sizeof(struct pglist_data));
+	NODE_DATA(nid) = (struct pglist_data *)(__va(min_low_pfn << PAGE_SHIFT));
 	min_low_pfn += node_datasz;
 }
 
@@ -289,7 +289,7 @@
 	num_physpages = highend_pfn;
 
 	for (nid = 0; nid < numnodes; nid++) {
-		lmax_mapnr = PLAT_NODE_DATA_STARTNR(nid) + PLAT_NODE_DATA_SIZE(nid);
+		lmax_mapnr = node_startnr(nid) + node_size(nid);
 		if (lmax_mapnr > max_mapnr) {
 			max_mapnr = lmax_mapnr;
 		}
diff -urN -X /home/mbligh/.diff.exclude 2.5.31-22-pmd_populate/include/asm-i386/mmzone.h 2.5.31-25-clean_plat/include/asm-i386/mmzone.h
--- 2.5.31-22-pmd_populate/include/asm-i386/mmzone.h	Fri Aug 16 11:26:20 2002
+++ 2.5.31-25-clean_plat/include/asm-i386/mmzone.h	Fri Aug 23 11:53:55 2002
@@ -11,8 +11,8 @@
 #ifdef CONFIG_X86_NUMAQ
 #include <asm/numaq.h>
 #else
-#define PHYSADDR_TO_NID(pa)	(0)
-#define PFN_TO_NID(pfn)		(0)
+#define pa_to_nid(pa)	(0)
+#define pfn_to_nid(pfn)		(0)
 #ifdef CONFIG_NUMA
 #define _cpu_to_node(cpu) 0
 #endif /* CONFIG_NUMA */
@@ -22,11 +22,7 @@
 #define numa_node_id() _cpu_to_node(smp_processor_id())
 #endif /* CONFIG_NUMA */
 
-struct plat_pglist_data {
-	pg_data_t	gendata;
-};
-
-extern struct plat_pglist_data *plat_node_data[];
+extern struct pglist_data *node_data[];
 
 /*
  * Following are macros that are specific to this numa platform.
@@ -48,12 +44,9 @@
 #define alloc_bootmem_low_pages_node(ignore, x) \
 	__alloc_bootmem_node(NODE_DATA(0), (x), PAGE_SIZE, 0)
 
-#define PLAT_NODE_DATA(n)		(plat_node_data[(n)])
-#define PLAT_NODE_DATA_STARTNR(n)	\
-	(PLAT_NODE_DATA(n)->gendata.node_start_mapnr)
-#define PLAT_NODE_DATA_SIZE(n)		(PLAT_NODE_DATA(n)->gendata.node_size)
-#define PLAT_NODE_DATA_LOCALNR(pfn, n) \
-	((pfn) - PLAT_NODE_DATA(n)->gendata.node_start_pfn)
+#define node_startnr(nid)	(node_data[nid]->node_start_mapnr)
+#define node_size(nid)		(node_data[nid]->node_size)
+#define node_localnr(pfn, nid)	((pfn) - node_data[nid]->node_start_pfn)
 
 /*
  * Following are macros that each numa implmentation must define.
@@ -62,39 +55,23 @@
 /*
  * Given a kernel address, find the home node of the underlying memory.
  */
-#define KVADDR_TO_NID(kaddr)	PHYSADDR_TO_NID(__pa(kaddr))
+#define kvaddr_to_nid(kaddr)	pa_to_nid(__pa(kaddr))
 
 /*
  * Return a pointer to the node data for node n.
  */
-#define NODE_DATA(n)	(&((PLAT_NODE_DATA(n))->gendata))
+#define NODE_DATA(nid)		(node_data[nid])
 
-/*
- * NODE_MEM_MAP gives the kaddr for the mem_map of the node.
- */
-#define NODE_MEM_MAP(nid)	(NODE_DATA(nid)->node_mem_map)
-
-/*
- * Given a kaddr, ADDR_TO_MAPBASE finds the owning node of the memory
- * and returns the the mem_map of that node.
- */
-#define ADDR_TO_MAPBASE(kaddr) \
-			NODE_MEM_MAP(KVADDR_TO_NID((unsigned long)(kaddr)))
-
-/*
- * Given a kaddr, LOCAL_BASE_ADDR finds the owning node of the memory
- * and returns the kaddr corresponding to first physical page in the
- * node's mem_map.
- */
-#define LOCAL_BASE_ADDR(kaddr)	((unsigned long)__va(NODE_DATA(KVADDR_TO_NID(kaddr))->node_start_pfn << PAGE_SHIFT))
+#define node_mem_map(nid)	(NODE_DATA(nid)->node_mem_map)
+#define node_start_pfn(nid)	(NODE_DATA(nid)->node_start_pfn)
 
-#define LOCAL_MAP_NR(kvaddr) \
-	(((unsigned long)(kvaddr)-LOCAL_BASE_ADDR(kvaddr)) >> PAGE_SHIFT)
+#define local_mapnr(kvaddr) \
+	( (__pa(kvaddr) >> PAGE_SHIFT) - node_start_pfn(kvaddr_to_nid(kvaddr)) )
 
-#define kern_addr_valid(kaddr)	test_bit(LOCAL_MAP_NR(kaddr), \
-					 NODE_DATA(KVADDR_TO_NID(kaddr))->valid_addr_bitmap)
+#define kern_addr_valid(kaddr)	test_bit(local_mapnr(kaddr), \
+		 NODE_DATA(kvaddr_to_nid(kaddr))->valid_addr_bitmap)
 
-#define pfn_to_page(pfn)	(NODE_MEM_MAP(PFN_TO_NID(pfn)) + PLAT_NODE_DATA_LOCALNR(pfn, PFN_TO_NID(pfn)))
+#define pfn_to_page(pfn)	(node_mem_map(pfn_to_nid(pfn)) + node_localnr(pfn, pfn_to_nid(pfn)))
 #define page_to_pfn(page)	((page - page_zone(page)->zone_mem_map) + page_zone(page)->zone_start_pfn)
 #define pmd_page(pmd)		(pfn_to_page(pmd_val(pmd) >> PAGE_SHIFT))
 #endif /* CONFIG_DISCONTIGMEM */
diff -urN -X /home/mbligh/.diff.exclude 2.5.31-22-pmd_populate/include/asm-i386/numaq.h 2.5.31-25-clean_plat/include/asm-i386/numaq.h
--- 2.5.31-22-pmd_populate/include/asm-i386/numaq.h	Fri Aug 16 11:26:20 2002
+++ 2.5.31-25-clean_plat/include/asm-i386/numaq.h	Wed Aug 21 17:34:21 2002
@@ -38,14 +38,12 @@
 #define MAX_ELEMENTS 256
 #define ELEMENT_REPRESENTS 8 /* 256 Mb */
 
-#define PHYSADDR_TO_NID(pa) numaqpa_to_nid(pa)
-#define PFN_TO_NID(pa) numaqpfn_to_nid(pa)
 #define MAX_NUMNODES		8
 #ifdef CONFIG_NUMA
 #define _cpu_to_node(cpu) (cpu_to_logical_apicid(cpu) >> 4)
 #endif /* CONFIG_NUMA */
-extern int numaqpa_to_nid(u64);
-extern int numaqpfn_to_nid(unsigned long);
+extern int pa_to_nid(u64);
+extern int pfn_to_nid(unsigned long);
 extern void get_memcfg_numaq(void);
 #define get_memcfg_numa() get_memcfg_numaq()
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
