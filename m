Received: from titus.gormenghast (216-99-201-239.dial.spiritone.com [216.99.201.239])
	by franka.aracnet.com (8.12.5/8.12.5) with ESMTP id g8B4Vxv5013817
	for <linux-mm@kvack.org>; Tue, 10 Sep 2002 21:32:02 -0700
Received: from [10.10.2.3] (fuchsia.gormenghast [10.10.2.3])
	by titus.gormenghast (8.12.3/8.12.3/Debian -4) with ESMTP id g8B4Xh5c018758
	for <linux-mm@kvack.org>; Tue, 10 Sep 2002 21:33:43 -0700
Date: Tue, 10 Sep 2002 21:31:54 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Reply-To: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: [RFC] patch to move lmem_map for each node onto their own nodes
Message-ID: <442355984.1031693514@[10.10.2.3]>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

64 bit arches find this easy, but it's not so simple on
32 bit arches ... mem_maps need to be in permanent KVA,
and all of ZONE_NORMAL is on node 0. Thus this patch 
creates a window between the top of ZONE_NORMAL and the
start of the highmem window (max_low_pfn ... highstart_pfn)
and remaps some memory stolen from the other nodes into
that window.

Adds set_pmd_pfn which does the remapping work, and a couple
of functions to discontigmem.c which calculate the required
space and lower max_low_pfn by reserve_pages.

Comments, flamage, abuse? I'll submit it if you don't ... ;-)

Martin.

diff -urN -X /home/mbligh/.diff.exclude 39-clean-numa/arch/i386/mm/discontig.c 40-numamap/arch/i386/mm/discontig.c
--- 39-clean-numa/arch/i386/mm/discontig.c	Fri Sep  6 23:03:19 2002
+++ 40-numamap/arch/i386/mm/discontig.c	Tue Sep 10 17:04:11 2002
@@ -1,5 +1,6 @@
 /*
- * Written by: Patricia Gaughen, IBM Corporation
+ * Written by: Patricia Gaughen <gone@us.ibm.com>, IBM Corporation
+ * August 2002: added remote node KVA remap - Martin J. Bligh 
  *
  * Copyright (C) 2002, IBM Corp.
  *
@@ -19,8 +20,6 @@
  * You should have received a copy of the GNU General Public License
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
- *
- * Send feedback to <gone@us.ibm.com>
  */
 
 #include <linux/config.h>
@@ -113,35 +112,98 @@
 	}
 }
 
+#define LARGE_PAGE_BYTES (PTRS_PER_PTE * PAGE_SIZE)
+
+unsigned long node_remap_start_pfn[MAX_NUMNODES];
+unsigned long node_remap_size[MAX_NUMNODES];
+unsigned long node_remap_offset[MAX_NUMNODES];
+void *node_remap_start_vaddr[MAX_NUMNODES];
+extern void set_pmd_pfn(unsigned long vaddr, unsigned long pfn, pgprot_t flags);
+
+void __init remap_numa_kva(void)
+{
+	void *vaddr;
+	unsigned long pfn;
+	int node;
+
+	for (node = 1; node < numnodes; ++node) {
+		for (pfn=0; pfn < node_remap_size[node]; pfn += PTRS_PER_PTE) {
+			vaddr = node_remap_start_vaddr[node]+(pfn<<PAGE_SHIFT);
+			set_pmd_pfn((ulong) vaddr, 
+				node_remap_start_pfn[node] + pfn, 
+				PAGE_KERNEL_LARGE);
+		}
+	}
+}
+
+static unsigned long calculate_numa_remap_pages(void)
+{
+	int nid;
+	unsigned long size, reserve_pages = 0;
+
+	for (nid = 1; nid < numnodes; nid++) {
+		/* calculate the size of the mem_map needed in bytes */
+		size = (node_end_pfn[nid] - node_start_pfn[nid] + 1) 
+			* sizeof(struct page);
+		/* convert size to large (pmd size) pages, rounding up */
+		size = (size + LARGE_PAGE_BYTES - 1) / LARGE_PAGE_BYTES;
+		/* now the roundup is correct, convert to PAGE_SIZE pages */
+		size = size * PTRS_PER_PTE;
+		printk("Reserving %ld pages of KVA for lmem_map of node %d\n",
+				size, nid);
+		node_remap_size[nid] = size;
+		reserve_pages += size;
+		node_remap_offset[nid] = reserve_pages;
+		printk("Shrinking node %d from %ld pages to %ld pages\n",
+			nid, node_end_pfn[nid], node_end_pfn[nid] - size);
+		node_end_pfn[nid] -= size;
+		node_remap_start_pfn[nid] = node_end_pfn[nid];
+	}
+	printk("Reserving total of %ld pages for numa KVA remap\n",
+			reserve_pages);
+	return reserve_pages;
+}
+
 unsigned long __init setup_memory(void)
 {
 	int nid;
 	unsigned long bootmap_size, system_start_pfn, system_max_low_pfn;
+	unsigned long reserve_pages;
 
 	get_memcfg_numa();
+	reserve_pages = calculate_numa_remap_pages();
 
-	/*
-	 * partially used pages are not usable - thus
-	 * we are rounding upwards:
-	 */
+	/* partially used pages are not usable - thus round upwards */
 	system_start_pfn = min_low_pfn = PFN_UP(__pa(&_end));
 
 	find_max_pfn();
 	system_max_low_pfn = max_low_pfn = find_max_low_pfn();
-
 #ifdef CONFIG_HIGHMEM
-		highstart_pfn = highend_pfn = max_pfn;
-		if (max_pfn > system_max_low_pfn) {
-			highstart_pfn = system_max_low_pfn;
-		}
-		printk(KERN_NOTICE "%ldMB HIGHMEM available.\n",
-		       pages_to_mb(highend_pfn - highstart_pfn));
+	highstart_pfn = highend_pfn = max_pfn;
+	if (max_pfn > system_max_low_pfn)
+		highstart_pfn = system_max_low_pfn;
+	printk(KERN_NOTICE "%ldMB HIGHMEM available.\n",
+	       pages_to_mb(highend_pfn - highstart_pfn));
 #endif
+	system_max_low_pfn = max_low_pfn = max_low_pfn - reserve_pages;
 	printk(KERN_NOTICE "%ldMB LOWMEM available.\n",
 			pages_to_mb(system_max_low_pfn));
-	
-	for (nid = 0; nid < numnodes; nid++)
+	printk("min_low_pfn = %ld, max_low_pfn = %ld, highstart_pfn = %ld\n", 
+			min_low_pfn, max_low_pfn, highstart_pfn);
+
+	printk("Low memory ends at vaddr %08lx\n",
+			(ulong) pfn_to_kaddr(max_low_pfn));
+	for (nid = 0; nid < numnodes; nid++) {
 		allocate_pgdat(nid);
+		node_remap_start_vaddr[nid] = pfn_to_kaddr(
+			highstart_pfn - node_remap_offset[nid]);
+		printk ("node %d will remap to vaddr %08lx - %08lx\n", nid,
+			(ulong) node_remap_start_vaddr[nid],
+			(ulong) pfn_to_kaddr(highstart_pfn
+			    - node_remap_offset[nid] + node_remap_size[nid]));
+	}
+	printk("High memory starts at vaddr %08lx\n",
+			(ulong) pfn_to_kaddr(highstart_pfn));
 	for (nid = 0; nid < numnodes; nid++)
 		find_max_pfn_node(nid);
 
@@ -244,7 +306,18 @@
 #endif
 			}
 		}
-		free_area_init_node(nid, NODE_DATA(nid), 0, zones_size, start, 0);
+		/*
+		 * We let the lmem_map for node 0 be allocated from the
+		 * normal bootmem allocator, but other nodes come from the
+		 * remapped KVA area - mbligh
+		 */
+		if (nid)
+			free_area_init_node(nid, NODE_DATA(nid), 
+				node_remap_start_vaddr[nid], zones_size, 
+				start, 0);
+		else
+			free_area_init_node(nid, NODE_DATA(nid), 0, 
+				zones_size, start, 0);
 	}
 	return;
 }
diff -urN -X /home/mbligh/.diff.exclude 39-clean-numa/arch/i386/mm/init.c 40-numamap/arch/i386/mm/init.c
--- 39-clean-numa/arch/i386/mm/init.c	Fri Sep  6 23:03:19 2002
+++ 40-numamap/arch/i386/mm/init.c	Tue Sep 10 17:09:14 2002
@@ -245,6 +245,12 @@
 
 unsigned long __PAGE_KERNEL = _PAGE_KERNEL;
 
+#ifndef CONFIG_DISCONTIGMEM
+#define remap_numa_kva() do {} while (0)
+#else
+extern void __init remap_numa_kva(void);
+#endif
+
 static void __init pagetable_init (void)
 {
 	unsigned long vaddr;
@@ -269,6 +275,7 @@
 	}
 
 	kernel_physical_mapping_init(pgd_base);
+	remap_numa_kva();
 
 	/*
 	 * Fixed mappings, only the page table structure has to be
@@ -449,7 +456,11 @@
 
 	set_max_mapnr_init();
 
+#ifdef CONFIG_HIGHMEM
+	high_memory = (void *) __va(highstart_pfn * PAGE_SIZE);
+#else
 	high_memory = (void *) __va(max_low_pfn * PAGE_SIZE);
+#endif
 
 	/* clear the zero-page */
 	memset(empty_zero_page, 0, PAGE_SIZE);
diff -urN -X /home/mbligh/.diff.exclude 39-clean-numa/arch/i386/mm/pgtable.c 40-numamap/arch/i386/mm/pgtable.c
--- 39-clean-numa/arch/i386/mm/pgtable.c	Fri Sep  6 23:03:19 2002
+++ 40-numamap/arch/i386/mm/pgtable.c	Sat Sep  7 12:48:21 2002
@@ -84,6 +84,39 @@
 	__flush_tlb_one(vaddr);
 }
 
+/*
+ * Associate a large virtual page frame with a given physical page frame 
+ * and protection flags for that frame. pfn is for the base of the page,
+ * vaddr is what the page gets mapped to - both must be properly aligned. 
+ * The pmd must already be instantiated. Assumes PAE mode.
+ */ 
+void set_pmd_pfn(unsigned long vaddr, unsigned long pfn, pgprot_t flags)
+{
+	pgd_t *pgd;
+	pmd_t *pmd;
+
+	if (vaddr & (PMD_SIZE-1)) {		/* vaddr is misaligned */
+		printk ("set_pmd_pfn: vaddr misaligned\n");
+		return; /* BUG(); */
+	}
+	if (pfn & (PTRS_PER_PTE-1)) {		/* pfn is misaligned */
+		printk ("set_pmd_pfn: pfn misaligned\n");
+		return; /* BUG(); */
+	}
+	pgd = swapper_pg_dir + __pgd_offset(vaddr);
+	if (pgd_none(*pgd)) {
+		printk ("set_pmd_pfn: pgd_none\n");
+		return; /* BUG(); */
+	}
+	pmd = pmd_offset(pgd, vaddr);
+	set_pmd(pmd, pfn_pmd(pfn, flags));
+	/*
+	 * It's enough to flush this one mapping.
+	 * (PGE mappings get flushed as well)
+	 */
+	__flush_tlb_one(vaddr);
+}
+
 void __set_fixmap (enum fixed_addresses idx, unsigned long phys, pgprot_t flags)
 {
 	unsigned long address = __fix_to_virt(idx);
diff -urN -X /home/mbligh/.diff.exclude 39-clean-numa/include/asm-i386/page.h 40-numamap/include/asm-i386/page.h
--- 39-clean-numa/include/asm-i386/page.h	Fri Sep  6 23:03:19 2002
+++ 40-numamap/include/asm-i386/page.h	Sat Sep  7 12:48:21 2002
@@ -142,6 +142,7 @@
 #define MAXMEM			((unsigned long)(-PAGE_OFFSET-VMALLOC_RESERVE))
 #define __pa(x)			((unsigned long)(x)-PAGE_OFFSET)
 #define __va(x)			((void *)((unsigned long)(x)+PAGE_OFFSET))
+#define pfn_to_kaddr(pfn)      __va((pfn) << PAGE_SHIFT)
 #ifndef CONFIG_DISCONTIGMEM
 #define pfn_to_page(pfn)	(mem_map + (pfn))
 #define page_to_pfn(page)	((unsigned long)((page) - mem_map))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
