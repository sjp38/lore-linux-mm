Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: slablru for 2.5.32-mm1
Date: Wed, 28 Aug 2002 13:06:58 -0400
References: <200208261809.45568.tomlins@cam.org> <3D6AC0BB.FE65D5F7@zip.com.au>
In-Reply-To: <3D6AC0BB.FE65D5F7@zip.com.au>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200208281306.58776.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew

Here is slablru for 32-mm1.  This is based on a version ported to 31ish-mm1.  It should be
stable.  Its been booted as UP (32-mm1) and SMP on UP  (31ish-mm1 only) and works as expected.

A typical test cycle involved:
find / -name "*" > /dev/null
edit a large tif with the gimp
run dbench a few times with the dbench dir on tmpfs (trying to use gimp too)
run dbench a few times from a reiserfs dir (trying to use gimp too)
use the box for news/mail, atp-get update/upgrade etc, wait a few hours and repeat

31ish-mm1 survived a day of this, 32-mm1 is sending this message after one cycle.

Andrew, what do you thing about adding slablru to your experimental dir?  

There is also a version for virgin 2.5.32, anyone wanting it should email me - one big 
patch is eats enough bandwidth.

One interesting change in this version.  We only add the first page of a slab to the lru.  The 
reference bit setting logic for slabs has been modified to set the bit on the first page. 
Pagevec created a little bit of a problem for slablru.  How do we know the order of the
slab page when its being freed?   My solution is to use 3 bits in page->flags and save the
order there.  Then free_pages_ok was modified to take the order from page->flags.  This
was implement in a minimal fashion.  Think Wli is working on a more elaborate version of 
this - fleshed out, it could be used to support large pages in the vm.

Second topic.

I have also included an optimisation for vmscan.  I found that the current code would reduce 
the inactive list to almost nothing when applications create large numbers of active pages very
quickly run (ie. gimp loading and editing large 20m+ tiffs).  This reduces the problem.   Always
allowing nr_pages to be scanned caused the active list to be reduced to almost nothing when 
something like gimp exited and we had another task adding lots to the inactive list.  This
is fixed here too.  I do wonder if zone->refill_counter, as implemented, is a great idea.  Do
we really need/want to remember to scan the active list if it has massively decreased in size
because some app exited?  Maybe some sort of decay logic should be used...

Comments?
Ed Tomlinson

---------------
diff -Nru a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c	Tue Aug 27 09:59:26 2002
+++ b/mm/vmscan.c	Tue Aug 27 09:59:26 2002
@@ -492,11 +492,14 @@
 	 * active list.
 	 */
 	ratio = (unsigned long)nr_pages * zone->nr_active /
-				((zone->nr_inactive | 1) * 2);
-	atomic_add(ratio+1, &zone->refill_counter);
-	if (atomic_read(&zone->refill_counter) > SWAP_CLUSTER_MAX) {
+				((zone->nr_inactive | 1) * 2) + 1;
+	atomic_add(ratio, &zone->refill_counter);
+	max_scan = nr_pages < ratio ? nr_pages : ratio;
+	while ((atomic_read(&zone->refill_counter) > SWAP_CLUSTER_MAX) &&
+			(max_scan > 0)) {
 		atomic_sub(SWAP_CLUSTER_MAX, &zone->refill_counter);
 		refill_inactive_zone(zone, SWAP_CLUSTER_MAX);
+		max_scan -= SWAP_CLUSTER_MAX;
 	}
 
 	max_scan = zone->nr_inactive / priority;

---------------

---------------
# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.523   -> 1.524  
#	include/asm-generic/tlb.h	1.12    -> 1.13   
#	include/asm-s390x/tlb.h	1.3     -> 1.4    
#	 fs/jfs/jfs_umount.c	1.3     -> 1.4    
#	include/linux/kernel.h	1.19    -> 1.20   
#	include/asm-ppc/pgalloc.h	1.8     -> 1.9    
#	include/asm-ppc/hardirq.h	1.12    -> 1.13   
#	       fs/ext2/dir.c	1.15    -> 1.16   
#	include/asm-ppc/tlb.h	1.3     -> 1.4    
#	include/asm-ppc64/page.h	1.10    -> 1.11   
#	include/linux/pagemap.h	1.24    -> 1.25   
#	include/linux/mmzone.h	1.13    -> 1.14   
#	      kernel/ksyms.c	1.122   -> 1.123  
#	include/asm-cris/cache.h	1.1     -> 1.2    
#	include/asm-ia64/pgalloc.h	1.13    -> 1.14   
#	include/linux/swap.h	1.53    -> 1.54   
#	include/asm-arm/tlb.h	1.3     -> 1.4    
#	include/linux/buffer_head.h	1.26    -> 1.27   
#	include/linux/ext3_fs.h	1.7     -> 1.8    
#	include/asm-i386/cache.h	1.1     -> 1.2    
#	include/asm-ppc64/pgalloc.h	1.6     -> 1.7    
#	arch/alpha/mm/numa.c	1.5     -> 1.6    
#	  include/linux/mm.h	1.71    -> 1.72   
#	include/asm-i386/pgalloc.h	1.16    -> 1.17   
#	include/asm-mips64/mmzone.h	1.3     -> 1.4    
#	        mm/highmem.c	1.30    -> 1.31   
#	     mm/page_alloc.c	1.89    -> 1.90   
#	include/asm-s390/cache.h	1.3     -> 1.4    
#	include/asm-sparc/pgalloc.h	1.9     -> 1.10   
#	  arch/arm/mm/init.c	1.15    -> 1.16   
#	include/asm-ia64/spinlock.h	1.4     -> 1.5    
#	include/linux/ext3_jbd.h	1.4     -> 1.5    
#	    fs/ext3/Makefile	1.3     -> 1.4    
#	include/asm-i386/highmem.h	1.7     -> 1.8    
#	arch/i386/Config.help	1.12    -> 1.13   
#	include/linux/sched.h	1.84    -> 1.85   
#	include/linux/writeback.h	1.10    -> 1.11   
#	include/asm-ppc64/cache.h	1.3     -> 1.4    
#	 fs/driverfs/inode.c	1.48    -> 1.49   
#	 mm/page-writeback.c	1.32    -> 1.33   
#	    fs/smbfs/inode.c	1.27    -> 1.28   
#	include/asm-s390x/cache.h	1.3     -> 1.4    
#	         mm/vmscan.c	1.96    -> 1.97   
#	include/asm-x86_64/tlb.h	1.3     -> 1.4    
#	 fs/proc/proc_misc.c	1.34    -> 1.35   
#	include/asm-s390x/pgalloc.h	1.6     -> 1.7    
#	include/asm-parisc/cache.h	1.1     -> 1.2    
#	include/linux/page-flags.h	1.16    -> 1.17   
#	   fs/jfs/jfs_imap.c	1.9     -> 1.10   
#	include/asm-i386/page.h	1.15    -> 1.16   
#	arch/i386/kernel/Makefile	1.21    -> 1.22   
#	include/asm-sparc64/tlb.h	1.5     -> 1.6    
#	arch/sparc/mm/sun4c.c	1.16    -> 1.17   
#	 arch/i386/mm/init.c	1.23    -> 1.24   
#	      fs/minix/dir.c	1.11    -> 1.12   
#	          fs/mpage.c	1.13    -> 1.14   
#	include/asm-i386/spinlock.h	1.7     -> 1.8    
#	include/linux/preempt.h	1.5     -> 1.6    
#	    kernel/suspend.c	1.17    -> 1.18   
#	fs/jfs/jfs_metapage.c	1.15    -> 1.16   
#	 include/linux/gfp.h	1.2     -> 1.3    
#	  include/linux/fs.h	1.157   -> 1.158  
#	arch/i386/mm/Makefile	1.3     -> 1.4    
#	arch/mips64/sgi-ip27/ip27-memory.c	1.3     -> 1.4    
#	       fs/sysv/dir.c	1.12    -> 1.13   
#	include/asm-i386/semaphore.h	1.5     -> 1.6    
#	include/asm-alpha/pgtable.h	1.13    -> 1.14   
#	 arch/ppc/mm/fault.c	1.11    -> 1.12   
#	include/asm-i386/tlb.h	1.5     -> 1.6    
#	           mm/numa.c	1.8     -> 1.9    
#	include/linux/backing-dev.h	1.1     -> 1.2    
#	        mm/bootmem.c	1.11    -> 1.12   
#	include/asm-mips/cache.h	1.2     -> 1.3    
#	 arch/i386/config.in	1.46    -> 1.47   
#	include/linux/rwsem.h	1.8     -> 1.9    
#	 fs/reiserfs/inode.c	1.63    -> 1.64   
#	    fs/ramfs/inode.c	1.24    -> 1.25   
#	arch/sparc/mm/fault.c	1.8     -> 1.9    
#	        mm/filemap.c	1.127   -> 1.128  
#	include/asm-ppc64/tlb.h	1.2     -> 1.3    
#	          fs/namei.c	1.54    -> 1.55   
#	include/asm-alpha/mmzone.h	1.1     -> 1.2    
#	arch/sparc64/mm/init.c	1.33    -> 1.34   
#	          mm/msync.c	1.7     -> 1.8    
#	       fs/nfsd/vfs.c	1.36    -> 1.37   
#	           mm/swap.c	1.28    -> 1.29   
#	include/asm-alpha/cache.h	1.3     -> 1.4    
#	include/asm-m68k/sun3_pgalloc.h	1.6     -> 1.7    
#	include/asm-ia64/tlb.h	1.7     -> 1.8    
#	include/asm-i386/pci.h	1.15    -> 1.16   
#	          mm/shmem.c	1.70    -> 1.71   
#	include/asm-alpha/tlb.h	1.2     -> 1.3    
#	include/asm-sparc/tlb.h	1.2     -> 1.3    
#	include/asm-ppc/highmem.h	1.7     -> 1.8    
#	     mm/swap_state.c	1.41    -> 1.42   
#	          fs/super.c	1.82    -> 1.83   
#	      fs/fat/inode.c	1.42    -> 1.43   
#	include/asm-mips64/cache.h	1.2     -> 1.3    
#	include/asm-m68k/cache.h	1.2     -> 1.3    
#	      fs/jfs/super.c	1.21    -> 1.22   
#	 arch/cris/mm/init.c	1.9     -> 1.10   
#	include/asm-ia64/semaphore.h	1.4     -> 1.5    
#	      fs/affs/file.c	1.20    -> 1.21   
#	include/asm-i386/io.h	1.16    -> 1.17   
#	arch/i386/kernel/setup.c	1.59    -> 1.60   
#	     kernel/printk.c	1.13    -> 1.14   
#	include/linux/spinlock.h	1.18    -> 1.19   
#	include/asm-ia64/cache.h	1.3     -> 1.4    
#	   fs/fs-writeback.c	1.18    -> 1.19   
#	include/asm-sparc64/cache.h	1.3     -> 1.4    
#	 fs/jfs/jfs_logmgr.c	1.29    -> 1.30   
#	include/asm-x86_64/pgalloc.h	1.4     -> 1.5    
#	       kernel/acct.c	1.12    -> 1.13   
#	include/linux/rwsem-spinlock.h	1.7     -> 1.8    
#	drivers/block/loop.c	1.54    -> 1.55   
#	         fs/buffer.c	1.138   -> 1.139  
#	arch/sparc/mm/srmmu.c	1.19    -> 1.20   
#	     fs/ext3/namei.c	1.20    -> 1.21   
#	 fs/jfs/jfs_txnmgr.c	1.21    -> 1.22   
#	 fs/jffs/inode-v23.c	1.35    -> 1.36   
#	  drivers/block/rd.c	1.45    -> 1.46   
#	include/asm-s390/pgalloc.h	1.7     -> 1.8    
#	include/asm-i386/setup.h	1.1     -> 1.2    
#	include/asm-sparc/cache.h	1.2     -> 1.3    
#	       fs/nfs/file.c	1.17    -> 1.18   
#	        fs/Config.in	1.33    -> 1.34   
#	     fs/ext3/inode.c	1.32    -> 1.33   
#	include/asm-sh/cache.h	1.2     -> 1.3    
#	 fs/reiserfs/stree.c	1.31    -> 1.32   
#	include/asm-i386/pgtable.h	1.17    -> 1.18   
#	      fs/nfs/inode.c	1.47    -> 1.48   
#	drivers/scsi/scsi_scan.c	1.21    -> 1.22   
#	   arch/sh/mm/init.c	1.9     -> 1.10   
#	include/asm-s390/tlb.h	1.3     -> 1.4    
#	   fs/jfs/jfs_dmap.c	1.8     -> 1.9    
#	include/asm-x86_64/cache.h	1.1     -> 1.2    
#	include/linux/bootmem.h	1.2     -> 1.3    
#	     fs/smbfs/file.c	1.17    -> 1.18   
#	     fs/ext3/super.c	1.29    -> 1.30   
#	include/asm-arm/memory.h	1.4     -> 1.5    
#	           mm/rmap.c	1.10    -> 1.11   
#	include/asm-ppc64/mmzone.h	1.2     -> 1.3    
#	include/asm-m68k/tlb.h	1.3     -> 1.4    
#	include/asm-ppc/cache.h	1.5     -> 1.6    
#	drivers/net/ns83820.c	1.14    -> 1.15   
#	include/asm-mips64/pgtable.h	1.8     -> 1.9    
#	include/asm-arm/cache.h	1.1     -> 1.2    
#	include/linux/pagevec.h	1.2     -> 1.3    
#	          fs/inode.c	1.67    -> 1.68   
#	include/asm-sparc/highmem.h	1.4     -> 1.5    
#	     fs/jffs2/file.c	1.14    -> 1.15   
#	include/linux/dcache.h	1.14    -> 1.15   
#	include/asm-sparc/hardirq.h	1.5     -> 1.6    
#	arch/i386/mm/pgtable.c	1.2     -> 1.3    
#	include/asm-m68k/motorola_pgalloc.h	1.7     -> 1.8    
#	fs/reiserfs/tail_conversion.c	1.22    -> 1.23   
#	      fs/udf/inode.c	1.21    -> 1.22   
#	include/linux/cache.h	1.4     -> 1.5    
#	               (new)	        -> 1.1     fs/ext3/hash.c 
#	               (new)	        -> 1.1     include/asm-i386/max_numnodes.h
#	               (new)	        -> 1.1     include/asm-i386/mmzone.h
#	               (new)	        -> 1.1     include/asm-i386/numaq.h
#	               (new)	        -> 1.1     arch/i386/kernel/numaq.c
#	               (new)	        -> 1.1     arch/i386/mm/discontig.c
#	               (new)	        -> 1.1     include/linux/mm_inline.h
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 02/08/28	ed@oscar.et.ca	1.524
# 2.5.32-mm1
# --------------------------------------------
#
diff -Nru a/arch/alpha/mm/numa.c b/arch/alpha/mm/numa.c
--- a/arch/alpha/mm/numa.c	Wed Aug 28 07:37:36 2002
+++ b/arch/alpha/mm/numa.c	Wed Aug 28 07:37:36 2002
@@ -294,7 +294,7 @@
 			zones_size[ZONE_DMA] = dma_local_pfn;
 			zones_size[ZONE_NORMAL] = (end_pfn - start_pfn) - dma_local_pfn;
 		}
-		free_area_init_node(nid, NODE_DATA(nid), NULL, zones_size, start_pfn<<PAGE_SHIFT, NULL);
+		free_area_init_node(nid, NODE_DATA(nid), NULL, zones_size, start_pfn, NULL);
 		lmax_mapnr = PLAT_NODE_DATA_STARTNR(nid) + PLAT_NODE_DATA_SIZE(nid);
 		if (lmax_mapnr > max_mapnr) {
 			max_mapnr = lmax_mapnr;
@@ -371,7 +371,7 @@
 		totalram_pages += free_all_bootmem_node(NODE_DATA(nid));
 
 		lmem_map = NODE_MEM_MAP(nid);
-		pfn = NODE_DATA(nid)->node_start_paddr >> PAGE_SHIFT;
+		pfn = NODE_DATA(nid)->node_start_pfn;
 		for (i = 0; i < PLAT_NODE_DATA_SIZE(nid); i++, pfn++)
 			if (page_is_ram(pfn) && PageReserved(lmem_map+i))
 				reservedpages++;
diff -Nru a/arch/arm/mm/init.c b/arch/arm/mm/init.c
--- a/arch/arm/mm/init.c	Wed Aug 28 07:37:36 2002
+++ b/arch/arm/mm/init.c	Wed Aug 28 07:37:36 2002
@@ -512,7 +512,7 @@
 		arch_adjust_zones(node, zone_size, zhole_size);
 
 		free_area_init_node(node, pgdat, 0, zone_size,
-				bdata->node_boot_start, zhole_size);
+				bdata->node_boot_start >> PAGE_SHIFT, zhole_size);
 	}
 
 	/*
diff -Nru a/arch/cris/mm/init.c b/arch/cris/mm/init.c
--- a/arch/cris/mm/init.c	Wed Aug 28 07:37:37 2002
+++ b/arch/cris/mm/init.c	Wed Aug 28 07:37:37 2002
@@ -345,7 +345,7 @@
 	 * mem_map page array.
 	 */
 
-	free_area_init_node(0, 0, 0, zones_size, PAGE_OFFSET, 0);
+	free_area_init_node(0, 0, 0, zones_size, PAGE_OFFSET >> PAGE_SHIFT, 0);
 
 }
 
diff -Nru a/arch/i386/Config.help b/arch/i386/Config.help
--- a/arch/i386/Config.help	Wed Aug 28 07:37:36 2002
+++ b/arch/i386/Config.help	Wed Aug 28 07:37:36 2002
@@ -41,7 +41,7 @@
   486, 586, Pentiums, and various instruction-set-compatible chips by
   AMD, Cyrix, and others.
 
-CONFIG_MULTIQUAD
+CONFIG_X86_NUMAQ
   This option is used for getting Linux to run on a (IBM/Sequent) NUMA 
   multiquad box. This changes the way that processors are bootstrapped,
   and uses Clustered Logical APIC addressing mode instead of Flat Logical.
diff -Nru a/arch/i386/config.in b/arch/i386/config.in
--- a/arch/i386/config.in	Wed Aug 28 07:37:37 2002
+++ b/arch/i386/config.in	Wed Aug 28 07:37:37 2002
@@ -166,7 +166,22 @@
       define_bool CONFIG_X86_IO_APIC y
    fi
 else
-   bool 'Multiquad NUMA system' CONFIG_MULTIQUAD
+  bool 'Multi-node NUMA system support' CONFIG_X86_NUMA
+  if [ "$CONFIG_X86_NUMA" = "y" ]; then
+     #Platform Choices
+     bool 'Multiquad (IBM/Sequent) NUMAQ support' CONFIG_X86_NUMAQ
+     if [ "$CONFIG_X86_NUMAQ" = "y" ]; then
+        define_bool CONFIG_MULTIQUAD y
+     fi
+     # Common NUMA Features
+     if [ "$CONFIG_X86_NUMAQ" = "y" ]; then
+        bool 'Numa Memory Allocation Support' CONFIG_NUMA
+        if [ "$CONFIG_NUMA" = "y" ]; then
+           define_bool CONFIG_DISCONTIGMEM y
+           define_bool CONFIG_HAVE_ARCH_BOOTMEM_NODE y
+        fi
+     fi
+  fi
 fi
 
 bool 'Machine Check Exception' CONFIG_X86_MCE
diff -Nru a/arch/i386/kernel/Makefile b/arch/i386/kernel/Makefile
--- a/arch/i386/kernel/Makefile	Wed Aug 28 07:37:36 2002
+++ b/arch/i386/kernel/Makefile	Wed Aug 28 07:37:36 2002
@@ -25,6 +25,7 @@
 obj-$(CONFIG_X86_LOCAL_APIC)	+= mpparse.o apic.o nmi.o
 obj-$(CONFIG_X86_IO_APIC)	+= io_apic.o
 obj-$(CONFIG_SOFTWARE_SUSPEND)	+= suspend.o
+obj-$(CONFIG_X86_NUMAQ)		+= numaq.o
 ifdef CONFIG_VISWS
 obj-y += setup-visws.o
 obj-$(CONFIG_X86_VISWS_APIC)	+= visws_apic.o
diff -Nru a/arch/i386/kernel/numaq.c b/arch/i386/kernel/numaq.c
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/arch/i386/kernel/numaq.c	Wed Aug 28 07:37:38 2002
@@ -0,0 +1,145 @@
+/*
+ * Written by: Patricia Gaughen, IBM Corporation
+ *
+ * Copyright (C) 2002, IBM Corp.
+ *
+ * All rights reserved.          
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE, GOOD TITLE or
+ * NON INFRINGEMENT.  See the GNU General Public License for more
+ * details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ *
+ * Send feedback to <gone@us.ibm.com>
+ */
+
+#include <linux/config.h>
+#include <linux/mm.h>
+#include <linux/bootmem.h>
+#include <linux/mmzone.h>
+#include <asm/numaq.h>
+
+/* These are needed before the pgdat's are created */
+unsigned long node_start_pfn[MAX_NUMNODES];
+unsigned long node_end_pfn[MAX_NUMNODES];
+
+#define	MB_TO_PAGES(addr) ((addr) << (20 - PAGE_SHIFT))
+
+/*
+ * Function: smp_dump_qct()
+ *
+ * Description: gets memory layout from the quad config table.  This
+ * function also increments numnodes with the number of nodes (quads)
+ * present.
+ */
+static void __init smp_dump_qct(void)
+{
+	int node;
+	struct eachquadmem *eq;
+	struct sys_cfg_data *scd =
+		(struct sys_cfg_data *)__va(SYS_CFG_DATA_PRIV_ADDR);
+
+	numnodes = 0;
+	for(node = 0; node < MAX_NUMNODES; node++) {
+		if(scd->quads_present31_0 & (1 << node)) {
+			numnodes++;
+			eq = &scd->eq[node];
+			/* Convert to pages */
+			node_start_pfn[node] = MB_TO_PAGES(
+				eq->hi_shrd_mem_start - eq->priv_mem_size);
+			node_end_pfn[node] = MB_TO_PAGES(
+				eq->hi_shrd_mem_start + eq->hi_shrd_mem_size);
+		}
+	}
+}
+
+/*
+ * -----------------------------------------
+ *
+ * functions related to physnode_map
+ *
+ * -----------------------------------------
+ */
+/*
+ * physnode_map keeps track of the physical memory layout of the
+ * numaq nodes on a 256Mb break (each element of the array will
+ * represent 256Mb of memory and will be marked by the node id.  so,
+ * if the first gig is on node 0, and the second gig is on node 1
+ * physnode_map will contain:
+ * physnode_map[0-3] = 0;
+ * physnode_map[4-7] = 1;
+ * physnode_map[8- ] = -1;
+ */
+int physnode_map[MAX_ELEMENTS] = { [0 ... (MAX_ELEMENTS - 1)] = -1};
+
+#define MB_TO_ELEMENT(x) (x >> ELEMENT_REPRESENTS)
+#define PA_TO_MB(pa) (pa >> 20) 	/* assumption: a physical address is in bytes */
+
+int pa_to_nid(u64 pa)
+{
+	int nid;
+	
+	nid = physnode_map[MB_TO_ELEMENT(PA_TO_MB(pa))];
+
+	/* the physical address passed in is not in the map for the system */
+	if (nid == -1)
+		BUG();
+
+	return nid;
+}
+
+int pfn_to_nid(unsigned long pfn)
+{
+	return pa_to_nid(((u64)pfn) << PAGE_SHIFT);
+}
+
+/*
+ * for each node mark the regions
+ *        TOPOFMEM = hi_shrd_mem_start + hi_shrd_mem_size
+ *
+ * need to be very careful to not mark 1024+ as belonging
+ * to node 0. will want 1027 to show as belonging to node 1
+ * example:
+ *  TOPOFMEM = 1024
+ * 1024 >> 8 = 4 (subtract 1 for starting at 0]
+ * tmpvar = TOPOFMEM - 256 = 768
+ * 1024 >> 8 = 4 (subtract 1 for starting at 0]
+ * 
+ */
+static void __init initialize_physnode_map(void)
+{
+	int nid;
+	unsigned int topofmem, cur;
+	struct eachquadmem *eq;
+ 	struct sys_cfg_data *scd =
+		(struct sys_cfg_data *)__va(SYS_CFG_DATA_PRIV_ADDR);
+
+	
+	for(nid = 0; nid < numnodes; nid++) {
+		if(scd->quads_present31_0 & (1 << nid)) {
+			eq = &scd->eq[nid];
+			cur = eq->hi_shrd_mem_start;
+			topofmem = eq->hi_shrd_mem_start + eq->hi_shrd_mem_size;
+			while (cur < topofmem) {
+				physnode_map[cur >> 8] = nid;
+				cur += (ELEMENT_REPRESENTS - 1);
+			}
+		}
+	}
+}
+
+void __init get_memcfg_numaq(void)
+{
+	smp_dump_qct();
+	initialize_physnode_map();
+}
diff -Nru a/arch/i386/kernel/setup.c b/arch/i386/kernel/setup.c
--- a/arch/i386/kernel/setup.c	Wed Aug 28 07:37:37 2002
+++ b/arch/i386/kernel/setup.c	Wed Aug 28 07:37:37 2002
@@ -36,6 +36,7 @@
 #include <linux/highmem.h>
 #include <asm/e820.h>
 #include <asm/mpspec.h>
+#include <asm/setup.h>
 
 /*
  * Machine setup..
@@ -83,35 +84,10 @@
 
 unsigned long saved_videomode;
 
-/*
- * This is set up by the setup-routine at boot-time
- */
-#define PARAM	((unsigned char *)empty_zero_page)
-#define SCREEN_INFO (*(struct screen_info *) (PARAM+0))
-#define EXT_MEM_K (*(unsigned short *) (PARAM+2))
-#define ALT_MEM_K (*(unsigned long *) (PARAM+0x1e0))
-#define E820_MAP_NR (*(char*) (PARAM+E820NR))
-#define E820_MAP    ((struct e820entry *) (PARAM+E820MAP))
-#define APM_BIOS_INFO (*(struct apm_bios_info *) (PARAM+0x40))
-#define DRIVE_INFO (*(struct drive_info_struct *) (PARAM+0x80))
-#define SYS_DESC_TABLE (*(struct sys_desc_table_struct*)(PARAM+0xa0))
-#define MOUNT_ROOT_RDONLY (*(unsigned short *) (PARAM+0x1F2))
-#define RAMDISK_FLAGS (*(unsigned short *) (PARAM+0x1F8))
-#define VIDEO_MODE (*(unsigned short *) (PARAM+0x1FA))
-#define ORIG_ROOT_DEV (*(unsigned short *) (PARAM+0x1FC))
-#define AUX_DEVICE_INFO (*(unsigned char *) (PARAM+0x1FF))
-#define LOADER_TYPE (*(unsigned char *) (PARAM+0x210))
-#define KERNEL_START (*(unsigned long *) (PARAM+0x214))
-#define INITRD_START (*(unsigned long *) (PARAM+0x218))
-#define INITRD_SIZE (*(unsigned long *) (PARAM+0x21c))
-#define COMMAND_LINE ((char *) (PARAM+2048))
-#define COMMAND_LINE_SIZE 256
-
 #define RAMDISK_IMAGE_START_MASK  	0x07FF
 #define RAMDISK_PROMPT_FLAG		0x8000
 #define RAMDISK_LOAD_FLAG		0x4000	
 
-
 static char command_line[COMMAND_LINE_SIZE];
        char saved_command_line[COMMAND_LINE_SIZE];
 
@@ -592,72 +568,13 @@
 	}
 }
 
-void __init setup_arch(char **cmdline_p)
-{
-	unsigned long bootmap_size, low_mem_size;
-	unsigned long start_pfn, max_low_pfn;
-	int i;
-
-	early_cpu_init();
-
-#ifdef CONFIG_VISWS
-	visws_get_board_type_and_rev();
-#endif
-
- 	ROOT_DEV = ORIG_ROOT_DEV;
- 	drive_info = DRIVE_INFO;
- 	screen_info = SCREEN_INFO;
-	apm_info.bios = APM_BIOS_INFO;
-	saved_videomode = VIDEO_MODE;
-	printk("Video mode to be used for restore is %lx\n", saved_videomode);
-	if( SYS_DESC_TABLE.length != 0 ) {
-		MCA_bus = SYS_DESC_TABLE.table[3] &0x2;
-		machine_id = SYS_DESC_TABLE.table[0];
-		machine_submodel_id = SYS_DESC_TABLE.table[1];
-		BIOS_revision = SYS_DESC_TABLE.table[2];
-	}
-	aux_device_present = AUX_DEVICE_INFO;
-
-#ifdef CONFIG_BLK_DEV_RAM
-	rd_image_start = RAMDISK_FLAGS & RAMDISK_IMAGE_START_MASK;
-	rd_prompt = ((RAMDISK_FLAGS & RAMDISK_PROMPT_FLAG) != 0);
-	rd_doload = ((RAMDISK_FLAGS & RAMDISK_LOAD_FLAG) != 0);
-#endif
-	setup_memory_region();
-
-	if (!MOUNT_ROOT_RDONLY)
-		root_mountflags &= ~MS_RDONLY;
-	init_mm.start_code = (unsigned long) &_text;
-	init_mm.end_code = (unsigned long) &_etext;
-	init_mm.end_data = (unsigned long) &_edata;
-	init_mm.brk = (unsigned long) &_end;
-
-	code_resource.start = virt_to_phys(&_text);
-	code_resource.end = virt_to_phys(&_etext)-1;
-	data_resource.start = virt_to_phys(&_etext);
-	data_resource.end = virt_to_phys(&_edata)-1;
-
-	parse_mem_cmdline(cmdline_p);
-
-#define PFN_UP(x)	(((x) + PAGE_SIZE-1) >> PAGE_SHIFT)
-#define PFN_DOWN(x)	((x) >> PAGE_SHIFT)
-#define PFN_PHYS(x)	((x) << PAGE_SHIFT)
-
 /*
- * Reserved space for vmalloc and iomap - defined in asm/page.h
+ * Find the highest page frame number we have available
  */
-#define MAXMEM_PFN	PFN_DOWN(MAXMEM)
-#define MAX_NONPAE_PFN	(1 << 20)
-
-	/*
-	 * partially used pages are not usable - thus
-	 * we are rounding upwards:
-	 */
-	start_pfn = PFN_UP(__pa(&_end));
+void __init find_max_pfn(void)
+{
+	int i;
 
-	/*
-	 * Find the highest page frame number we have available
-	 */
 	max_pfn = 0;
 	for (i = 0; i < e820.nr_map; i++) {
 		unsigned long start, end;
@@ -671,10 +588,15 @@
 		if (end > max_pfn)
 			max_pfn = end;
 	}
+}
+
+/*
+ * Determine low and high memory ranges:
+ */
+unsigned long __init find_max_low_pfn(void)
+{
+	unsigned long max_low_pfn;
 
-	/*
-	 * Determine low and high memory ranges:
-	 */
 	max_low_pfn = max_pfn;
 	if (max_low_pfn > MAXMEM_PFN) {
 		if (highmem_pages == -1)
@@ -724,28 +646,20 @@
 			printk(KERN_ERR "ignoring highmem size on non-highmem kernel!\n");
 #endif
 	}
+	return max_low_pfn;
+}
 
-#ifdef CONFIG_HIGHMEM
-	highstart_pfn = highend_pfn = max_pfn;
-	if (max_pfn > max_low_pfn) {
-		highstart_pfn = max_low_pfn;
-	}
-	printk(KERN_NOTICE "%ldMB HIGHMEM available.\n",
-		pages_to_mb(highend_pfn - highstart_pfn));
-#endif
-	printk(KERN_NOTICE "%ldMB LOWMEM available.\n",
-			pages_to_mb(max_low_pfn));
-	/*
-	 * Initialize the boot-time allocator (with low memory only):
-	 */
-	bootmap_size = init_bootmem(start_pfn, max_low_pfn);
+#ifndef CONFIG_DISCONTIGMEM
+/*
+ * Register fully available low RAM pages with the bootmem allocator.
+ */
+static void __init register_bootmem_low_pages(unsigned long max_low_pfn)
+{
+	int i;
 
-	/*
-	 * Register fully available low RAM pages with the bootmem allocator.
-	 */
 	for (i = 0; i < e820.nr_map; i++) {
 		unsigned long curr_pfn, last_pfn, size;
- 		/*
+		/*
 		 * Reserve usable low memory
 		 */
 		if (e820.map[i].type != E820_RAM)
@@ -774,6 +688,39 @@
 		size = last_pfn - curr_pfn;
 		free_bootmem(PFN_PHYS(curr_pfn), PFN_PHYS(size));
 	}
+}
+
+static unsigned long __init setup_memory(void)
+{
+	unsigned long bootmap_size, start_pfn, max_low_pfn;
+
+	/*
+	 * partially used pages are not usable - thus
+	 * we are rounding upwards:
+	 */
+	start_pfn = PFN_UP(__pa(&_end));
+
+	find_max_pfn();
+
+	max_low_pfn = find_max_low_pfn();
+
+#ifdef CONFIG_HIGHMEM
+	highstart_pfn = highend_pfn = max_pfn;
+	if (max_pfn > max_low_pfn) {
+		highstart_pfn = max_low_pfn;
+	}
+	printk(KERN_NOTICE "%ldMB HIGHMEM available.\n",
+		pages_to_mb(highend_pfn - highstart_pfn));
+#endif
+	printk(KERN_NOTICE "%ldMB LOWMEM available.\n",
+			pages_to_mb(max_low_pfn));
+	/*
+	 * Initialize the boot-time allocator (with low memory only):
+	 */
+	bootmap_size = init_bootmem(start_pfn, max_low_pfn);
+
+	register_bootmem_low_pages(max_low_pfn);
+
 	/*
 	 * Reserve the bootmem bitmap itself as well. We do this in two
 	 * steps (first step was init_bootmem()) because this catches
@@ -809,6 +756,7 @@
 	 */
 	find_smp_config();
 #endif
+
 #ifdef CONFIG_BLK_DEV_INITRD
 	if (LOADER_TYPE && INITRD_START) {
 		if (INITRD_START + INITRD_SIZE <= (max_low_pfn << PAGE_SHIFT)) {
@@ -826,32 +774,21 @@
 		}
 	}
 #endif
+	return max_low_pfn;
+}
+#else
+extern unsigned long setup_memory(void);
+#endif /* !CONFIG_DISCONTIGMEM */
 
-	/*
-	 * NOTE: before this point _nobody_ is allowed to allocate
-	 * any memory using the bootmem allocator.
-	 */
-
-#ifdef CONFIG_SMP
-	smp_alloc_memory(); /* AP processor realmode stacks in low memory*/
-#endif
-	paging_init();
-#ifdef CONFIG_ACPI_BOOT
-	/*
-	 * Parse the ACPI tables for possible boot-time SMP configuration.
-	 */
-	acpi_boot_init(*cmdline_p);
-#endif
-#ifdef CONFIG_X86_LOCAL_APIC
-	if (smp_found_config)
-		get_smp_config();
-#endif
-
+/*
+ * Request address space for all standard RAM and ROM resources
+ * and also for regions reported as reserved by the e820.
+ */
+static void __init register_memory(unsigned long max_low_pfn)
+{
+	unsigned long low_mem_size;
+	int i;
 
-	/*
-	 * Request address space for all standard RAM and ROM resources
-	 * and also for regions reported as reserved by the e820.
-	 */
 	probe_roms();
 	for (i = 0; i < e820.nr_map; i++) {
 		struct resource *res;
@@ -888,6 +825,76 @@
 	low_mem_size = ((max_low_pfn << PAGE_SHIFT) + 0xfffff) & ~0xfffff;
 	if (low_mem_size > pci_mem_start)
 		pci_mem_start = low_mem_size;
+}
+
+void __init setup_arch(char **cmdline_p)
+{
+	unsigned long max_low_pfn;
+
+	early_cpu_init();
+
+#ifdef CONFIG_VISWS
+	visws_get_board_type_and_rev();
+#endif
+
+ 	ROOT_DEV = ORIG_ROOT_DEV;
+ 	drive_info = DRIVE_INFO;
+ 	screen_info = SCREEN_INFO;
+	apm_info.bios = APM_BIOS_INFO;
+	saved_videomode = VIDEO_MODE;
+	printk("Video mode to be used for restore is %lx\n", saved_videomode);
+	if( SYS_DESC_TABLE.length != 0 ) {
+		MCA_bus = SYS_DESC_TABLE.table[3] &0x2;
+		machine_id = SYS_DESC_TABLE.table[0];
+		machine_submodel_id = SYS_DESC_TABLE.table[1];
+		BIOS_revision = SYS_DESC_TABLE.table[2];
+	}
+	aux_device_present = AUX_DEVICE_INFO;
+
+#ifdef CONFIG_BLK_DEV_RAM
+	rd_image_start = RAMDISK_FLAGS & RAMDISK_IMAGE_START_MASK;
+	rd_prompt = ((RAMDISK_FLAGS & RAMDISK_PROMPT_FLAG) != 0);
+	rd_doload = ((RAMDISK_FLAGS & RAMDISK_LOAD_FLAG) != 0);
+#endif
+	setup_memory_region();
+
+	if (!MOUNT_ROOT_RDONLY)
+		root_mountflags &= ~MS_RDONLY;
+	init_mm.start_code = (unsigned long) &_text;
+	init_mm.end_code = (unsigned long) &_etext;
+	init_mm.end_data = (unsigned long) &_edata;
+	init_mm.brk = (unsigned long) &_end;
+
+	code_resource.start = virt_to_phys(&_text);
+	code_resource.end = virt_to_phys(&_etext)-1;
+	data_resource.start = virt_to_phys(&_etext);
+	data_resource.end = virt_to_phys(&_edata)-1;
+
+	parse_mem_cmdline(cmdline_p);
+
+	max_low_pfn = setup_memory();
+
+	/*
+	 * NOTE: before this point _nobody_ is allowed to allocate
+	 * any memory using the bootmem allocator.
+	 */
+
+#ifdef CONFIG_SMP
+	smp_alloc_memory(); /* AP processor realmode stacks in low memory*/
+#endif
+	paging_init();
+#ifdef CONFIG_ACPI_BOOT
+	/*
+	 * Parse the ACPI tables for possible boot-time SMP configuration.
+	 */
+	acpi_boot_init(*cmdline_p);
+#endif
+#ifdef CONFIG_X86_LOCAL_APIC
+	if (smp_found_config)
+		get_smp_config();
+#endif
+
+	register_memory(max_low_pfn);
 
 #ifdef CONFIG_VT
 #if defined(CONFIG_VGA_CONSOLE)
diff -Nru a/arch/i386/mm/Makefile b/arch/i386/mm/Makefile
--- a/arch/i386/mm/Makefile	Wed Aug 28 07:37:37 2002
+++ b/arch/i386/mm/Makefile	Wed Aug 28 07:37:37 2002
@@ -10,6 +10,7 @@
 O_TARGET := mm.o
 
 obj-y	 := init.o pgtable.o fault.o ioremap.o extable.o pageattr.o 
+obj-$(CONFIG_DISCONTIGMEM)	+= discontig.o
 export-objs := pageattr.o
 
 include $(TOPDIR)/Rules.make
diff -Nru a/arch/i386/mm/discontig.c b/arch/i386/mm/discontig.c
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/arch/i386/mm/discontig.c	Wed Aug 28 07:37:38 2002
@@ -0,0 +1,294 @@
+/*
+ * Written by: Patricia Gaughen, IBM Corporation
+ *
+ * Copyright (C) 2002, IBM Corp.
+ *
+ * All rights reserved.          
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE, GOOD TITLE or
+ * NON INFRINGEMENT.  See the GNU General Public License for more
+ * details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ *
+ * Send feedback to <gone@us.ibm.com>
+ */
+
+#include <linux/config.h>
+#include <linux/mm.h>
+#include <linux/bootmem.h>
+#include <linux/mmzone.h>
+#include <linux/highmem.h>
+#ifdef CONFIG_BLK_DEV_RAM
+#include <linux/blk.h>
+#endif
+#include <asm/e820.h>
+#include <asm/setup.h>
+
+struct pglist_data *node_data[MAX_NUMNODES];
+bootmem_data_t node0_bdata;
+
+extern unsigned long find_max_low_pfn(void);
+extern void find_max_pfn(void);
+extern void one_highpage_init(struct page *, int, int);
+
+extern unsigned long node_start_pfn[], node_end_pfn[];
+extern struct e820map e820;
+extern char _end;
+extern unsigned long highend_pfn, highstart_pfn;
+extern unsigned long max_low_pfn;
+extern unsigned long totalram_pages;
+extern unsigned long totalhigh_pages;
+
+/*
+ * Find the highest page frame number we have available for the node
+ */
+static void __init find_max_pfn_node(int nid)
+{
+	if (node_start_pfn[nid] >= node_end_pfn[nid])
+		BUG();
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
+
+	node_datasz = PFN_UP(sizeof(struct pglist_data));
+	NODE_DATA(nid) = (pg_data_t *)(__va(min_low_pfn << PAGE_SHIFT));
+	min_low_pfn += node_datasz;
+}
+
+/*
+ * Register fully available low RAM pages with the bootmem allocator.
+ */
+static void __init register_bootmem_low_pages(unsigned long system_max_low_pfn)
+{
+	int i;
+
+	for (i = 0; i < e820.nr_map; i++) {
+		unsigned long curr_pfn, last_pfn, size;
+		/*
+		 * Reserve usable low memory
+		 */
+		if (e820.map[i].type != E820_RAM)
+			continue;
+		/*
+		 * We are rounding up the start address of usable memory:
+		 */
+		curr_pfn = PFN_UP(e820.map[i].addr);
+		if (curr_pfn >= system_max_low_pfn)
+			continue;
+		/*
+		 * ... and at the end of the usable range downwards:
+		 */
+		last_pfn = PFN_DOWN(e820.map[i].addr + e820.map[i].size);
+
+		if (last_pfn > system_max_low_pfn)
+			last_pfn = system_max_low_pfn;
+
+		/*
+		 * .. finally, did all the rounding and playing
+		 * around just make the area go away?
+		 */
+		if (last_pfn <= curr_pfn)
+			continue;
+
+		size = last_pfn - curr_pfn;
+		free_bootmem_node(NODE_DATA(0), PFN_PHYS(curr_pfn), PFN_PHYS(size));
+	}
+}
+
+unsigned long __init setup_memory(void)
+{
+	int nid;
+	unsigned long bootmap_size, system_start_pfn, system_max_low_pfn;
+
+	get_memcfg_numa();
+
+	/*
+	 * partially used pages are not usable - thus
+	 * we are rounding upwards:
+	 */
+	system_start_pfn = min_low_pfn = PFN_UP(__pa(&_end));
+
+	find_max_pfn();
+	system_max_low_pfn = max_low_pfn = find_max_low_pfn();
+
+#ifdef CONFIG_HIGHMEM
+		highstart_pfn = highend_pfn = max_pfn;
+		if (max_pfn > system_max_low_pfn) {
+			highstart_pfn = system_max_low_pfn;
+		}
+		printk(KERN_NOTICE "%ldMB HIGHMEM available.\n",
+		       pages_to_mb(highend_pfn - highstart_pfn));
+#endif
+	printk(KERN_NOTICE "%ldMB LOWMEM available.\n",
+			pages_to_mb(system_max_low_pfn));
+	
+	for (nid = 0; nid < numnodes; nid++)
+		allocate_pgdat(nid);
+	for (nid = 0; nid < numnodes; nid++)
+		find_max_pfn_node(nid);
+
+	NODE_DATA(0)->bdata = &node0_bdata;
+
+	/*
+	 * Initialize the boot-time allocator (with low memory only):
+	 */
+	bootmap_size = init_bootmem_node(NODE_DATA(0), min_low_pfn, 0, system_max_low_pfn);
+
+	register_bootmem_low_pages(system_max_low_pfn);
+
+	/*
+	 * Reserve the bootmem bitmap itself as well. We do this in two
+	 * steps (first step was init_bootmem()) because this catches
+	 * the (very unlikely) case of us accidentally initializing the
+	 * bootmem allocator with an invalid RAM area.
+	 */
+	reserve_bootmem_node(NODE_DATA(0), HIGH_MEMORY, (PFN_PHYS(min_low_pfn) +
+		 bootmap_size + PAGE_SIZE-1) - (HIGH_MEMORY));
+
+	/*
+	 * reserve physical page 0 - it's a special BIOS page on many boxes,
+	 * enabling clean reboots, SMP operation, laptop functions.
+	 */
+	reserve_bootmem_node(NODE_DATA(0), 0, PAGE_SIZE);
+
+	/*
+	 * But first pinch a few for the stack/trampoline stuff
+	 * FIXME: Don't need the extra page at 4K, but need to fix
+	 * trampoline before removing it. (see the GDT stuff)
+	 */
+	reserve_bootmem_node(NODE_DATA(0), PAGE_SIZE, PAGE_SIZE);
+
+#ifdef CONFIG_ACPI_SLEEP
+	/*
+	 * Reserve low memory region for sleep support.
+	 */
+	acpi_reserve_bootmem();
+#endif
+
+	/*
+	 * Find and reserve possible boot-time SMP configuration:
+	 */
+	find_smp_config();
+
+	/*insert other nodes into pgdat_list*/
+	for (nid = 1; nid < numnodes; nid++){       
+		NODE_DATA(nid)->pgdat_next = pgdat_list;
+		pgdat_list = NODE_DATA(nid);
+	}
+       
+
+#ifdef CONFIG_BLK_DEV_INITRD
+	if (LOADER_TYPE && INITRD_START) {
+		if (INITRD_START + INITRD_SIZE <= (system_max_low_pfn << PAGE_SHIFT)) {
+			reserve_bootmem_node(NODE_DATA(0), INITRD_START, INITRD_SIZE);
+			initrd_start =
+				INITRD_START ? INITRD_START + PAGE_OFFSET : 0;
+			initrd_end = initrd_start+INITRD_SIZE;
+		}
+		else {
+			printk(KERN_ERR "initrd extends beyond end of memory "
+			    "(0x%08lx > 0x%08lx)\ndisabling initrd\n",
+			    INITRD_START + INITRD_SIZE,
+			    system_max_low_pfn << PAGE_SHIFT);
+			initrd_start = 0;
+		}
+	}
+#endif
+	return system_max_low_pfn;
+}
+
+void __init zone_sizes_init(void)
+{
+	int nid;
+
+	for (nid = 0; nid < numnodes; nid++) {
+		unsigned long zones_size[MAX_NR_ZONES] = {0, 0, 0};
+		unsigned int max_dma;
+
+		unsigned long low = max_low_pfn;
+		unsigned long start = node_start_pfn[nid];
+		unsigned long high = node_end_pfn[nid];
+		
+		max_dma = virt_to_phys((char *)MAX_DMA_ADDRESS) >> PAGE_SHIFT;
+
+		if (start > low) {
+#ifdef CONFIG_HIGHMEM
+		  zones_size[ZONE_HIGHMEM] = high - start;
+#endif
+		} else {
+			if (low < max_dma)
+				zones_size[ZONE_DMA] = low;
+			else {
+				zones_size[ZONE_DMA] = max_dma;
+				zones_size[ZONE_NORMAL] = low - max_dma;
+#ifdef CONFIG_HIGHMEM
+				zones_size[ZONE_HIGHMEM] = high - low;
+#endif
+			}
+		}
+		free_area_init_node(nid, NODE_DATA(nid), 0, zones_size, start, 0);
+	}
+	return;
+}
+
+void __init set_highmem_pages_init(int bad_ppro) 
+{
+#ifdef CONFIG_HIGHMEM
+	int nid;
+
+	for (nid = 0; nid < numnodes; nid++) {
+		unsigned long node_pfn, node_high_size, zone_start_pfn;
+		struct page * zone_mem_map;
+		
+		node_high_size = NODE_DATA(nid)->node_zones[ZONE_HIGHMEM].size;
+		zone_mem_map = NODE_DATA(nid)->node_zones[ZONE_HIGHMEM].zone_mem_map;
+		zone_start_pfn = NODE_DATA(nid)->node_zones[ZONE_HIGHMEM].zone_start_pfn;
+
+		printk("Initializing highpages for node %d\n", nid);
+		for (node_pfn = 0; node_pfn < node_high_size; node_pfn++) {
+			one_highpage_init((struct page *)(zone_mem_map + node_pfn),
+					  zone_start_pfn + node_pfn, bad_ppro);
+		}
+	}
+	totalram_pages += totalhigh_pages;
+#endif
+}
+
+void __init set_max_mapnr_init(void)
+{
+#ifdef CONFIG_HIGHMEM
+	unsigned long lmax_mapnr;
+	int nid;
+	
+	highmem_start_page = mem_map + NODE_DATA(0)->node_zones[ZONE_HIGHMEM].zone_start_mapnr;
+	num_physpages = highend_pfn;
+
+	for (nid = 0; nid < numnodes; nid++) {
+		lmax_mapnr = node_startnr(nid) + node_size(nid);
+		if (lmax_mapnr > max_mapnr) {
+			max_mapnr = lmax_mapnr;
+		}
+	}
+	
+#else
+	max_mapnr = num_physpages = max_low_pfn;
+#endif
+}
diff -Nru a/arch/i386/mm/init.c b/arch/i386/mm/init.c
--- a/arch/i386/mm/init.c	Wed Aug 28 07:37:36 2002
+++ b/arch/i386/mm/init.c	Wed Aug 28 07:37:36 2002
@@ -213,29 +213,34 @@
 	pkmap_page_table = pte;	
 }
 
+void __init one_highpage_init(struct page *page, int pfn, int bad_ppro)
+{
+	if (!page_is_ram(pfn)) {
+		SetPageReserved(page);
+		return;
+	}
+	if (bad_ppro && page_kills_ppro(pfn)) {
+		SetPageReserved(page);
+		return;
+	}
+	ClearPageReserved(page);
+	set_bit(PG_highmem, &page->flags);
+	atomic_set(&page->count, 1);
+	__free_page(page);
+	totalhigh_pages++;
+}
+
+#ifndef CONFIG_DISCONTIGMEM
 void __init set_highmem_pages_init(int bad_ppro) 
 {
 	int pfn;
-	for (pfn = highstart_pfn; pfn < highend_pfn; pfn++) {
-		struct page *page = mem_map + pfn;
-
-		if (!page_is_ram(pfn)) {
-			SetPageReserved(page);
-			continue;
-		}
-		if (bad_ppro && page_kills_ppro(pfn))
-		{
-			SetPageReserved(page);
-			continue;
-		}
-		ClearPageReserved(page);
-		set_bit(PG_highmem, &page->flags);
-		atomic_set(&page->count, 1);
-		__free_page(page);
-		totalhigh_pages++;
-	}
+	for (pfn = highstart_pfn; pfn < highend_pfn; pfn++)
+		one_highpage_init(pfn_to_page(pfn), pfn, bad_ppro);
 	totalram_pages += totalhigh_pages;
 }
+#else
+extern void set_highmem_pages_init(int);
+#endif /* !CONFIG_DISCONTIGMEM */
 
 #else
 #define kmap_init() do { } while (0)
@@ -309,6 +314,7 @@
 	flush_tlb_all();
 }
 
+#ifndef CONFIG_DISCONTIGMEM
 void __init zone_sizes_init(void)
 {
 	unsigned long zones_size[MAX_NR_ZONES] = {0, 0, 0};
@@ -329,6 +335,9 @@
 	}
 	free_area_init(zones_size);	
 }
+#else
+extern void zone_sizes_init(void);
+#endif /* !CONFIG_DISCONTIGMEM */
 
 /*
  * paging_init() sets up the page tables - note that the first 8MB are
@@ -405,7 +414,23 @@
 		printk("Ok.\n");
 	}
 }
-	
+
+#ifndef CONFIG_DISCONTIGMEM
+static void __init set_max_mapnr_init(void)
+{
+#ifdef CONFIG_HIGHMEM
+	highmem_start_page = pfn_to_page(highstart_pfn);
+	max_mapnr = num_physpages = highend_pfn;
+#else
+	max_mapnr = num_physpages = max_low_pfn;
+#endif
+}
+#define __free_all_bootmem() free_all_bootmem()
+#else
+#define __free_all_bootmem() free_all_bootmem_node(NODE_DATA(0))
+extern void set_max_mapnr_init(void);
+#endif /* !CONFIG_DISCONTIGMEM */
+
 void __init mem_init(void)
 {
 	extern int ppro_with_ram_bug(void);
@@ -418,26 +443,22 @@
 	
 	bad_ppro = ppro_with_ram_bug();
 
-#ifdef CONFIG_HIGHMEM
-	highmem_start_page = mem_map + highstart_pfn;
-	max_mapnr = num_physpages = highend_pfn;
-#else
-	max_mapnr = num_physpages = max_low_pfn;
-#endif
+	set_max_mapnr_init();
+
 	high_memory = (void *) __va(max_low_pfn * PAGE_SIZE);
 
 	/* clear the zero-page */
 	memset(empty_zero_page, 0, PAGE_SIZE);
 
 	/* this will put all low memory onto the freelists */
-	totalram_pages += free_all_bootmem();
+	totalram_pages += __free_all_bootmem();
 
 	reservedpages = 0;
 	for (tmp = 0; tmp < max_low_pfn; tmp++)
 		/*
 		 * Only count reserved RAM pages
 		 */
-		if (page_is_ram(tmp) && PageReserved(mem_map+tmp))
+		if (page_is_ram(tmp) && PageReserved(pfn_to_page(tmp)))
 			reservedpages++;
 
 	set_highmem_pages_init(bad_ppro);
diff -Nru a/arch/i386/mm/pgtable.c b/arch/i386/mm/pgtable.c
--- a/arch/i386/mm/pgtable.c	Wed Aug 28 07:37:38 2002
+++ b/arch/i386/mm/pgtable.c	Wed Aug 28 07:37:38 2002
@@ -22,24 +22,26 @@
 
 void show_mem(void)
 {
-	int i, total = 0, reserved = 0;
+	int pfn, total = 0, reserved = 0;
 	int shared = 0, cached = 0;
 	int highmem = 0;
+	struct page *page;
 
 	printk("Mem-info:\n");
 	show_free_areas();
 	printk("Free swap:       %6dkB\n",nr_swap_pages<<(PAGE_SHIFT-10));
-	i = max_mapnr;
-	while (i-- > 0) {
+	pfn = max_mapnr;
+	while (pfn-- > 0) {
+		page = pfn_to_page(pfn);
 		total++;
-		if (PageHighMem(mem_map+i))
+		if (PageHighMem(page))
 			highmem++;
-		if (PageReserved(mem_map+i))
+		if (PageReserved(page))
 			reserved++;
-		else if (PageSwapCache(mem_map+i))
+		else if (PageSwapCache(page))
 			cached++;
-		else if (page_count(mem_map+i))
-			shared += page_count(mem_map+i) - 1;
+		else if (page_count(page))
+			shared += page_count(page) - 1;
 	}
 	printk("%d pages of RAM\n", total);
 	printk("%d pages of HIGHMEM\n",highmem);
diff -Nru a/arch/mips64/sgi-ip27/ip27-memory.c b/arch/mips64/sgi-ip27/ip27-memory.c
--- a/arch/mips64/sgi-ip27/ip27-memory.c	Wed Aug 28 07:37:37 2002
+++ b/arch/mips64/sgi-ip27/ip27-memory.c	Wed Aug 28 07:37:37 2002
@@ -253,7 +253,7 @@
 
 		zones_size[ZONE_DMA] = end_pfn + 1 - start_pfn;
 		free_area_init_node(node, NODE_DATA(node), 0, zones_size, 
-						start_pfn << PAGE_SHIFT, 0);
+						start_pfn, 0);
 		if ((PLAT_NODE_DATA_STARTNR(node) + 
 					PLAT_NODE_DATA_SIZE(node)) > pagenr)
 			pagenr = PLAT_NODE_DATA_STARTNR(node) +
diff -Nru a/arch/ppc/mm/fault.c b/arch/ppc/mm/fault.c
--- a/arch/ppc/mm/fault.c	Wed Aug 28 07:37:37 2002
+++ b/arch/ppc/mm/fault.c	Wed Aug 28 07:37:37 2002
@@ -102,7 +102,7 @@
 #endif /* !CONFIG_4xx */
 #endif /* CONFIG_XMON || CONFIG_KGDB */
 
-	if (in_interrupt() || mm == NULL) {
+	if (in_atomic() || mm == NULL) {
 		bad_page_fault(regs, address, SIGSEGV);
 		return;
 	}
diff -Nru a/arch/sh/mm/init.c b/arch/sh/mm/init.c
--- a/arch/sh/mm/init.c	Wed Aug 28 07:37:37 2002
+++ b/arch/sh/mm/init.c	Wed Aug 28 07:37:37 2002
@@ -123,11 +123,11 @@
 			zones_size[ZONE_DMA] = max_dma - start_pfn;
 			zones_size[ZONE_NORMAL] = low - max_dma;
 		}
-		free_area_init_node(0, NODE_DATA(0), 0, zones_size, __MEMORY_START, 0);
+		free_area_init_node(0, NODE_DATA(0), 0, zones_size, __MEMORY_START >> PAGE_SHIFT, 0);
 #ifdef CONFIG_DISCONTIGMEM
 		zones_size[ZONE_DMA] = __MEMORY_SIZE_2ND >> PAGE_SHIFT;
 		zones_size[ZONE_NORMAL] = 0;
-		free_area_init_node(1, NODE_DATA(1), 0, zones_size, __MEMORY_START_2ND, 0);
+		free_area_init_node(1, NODE_DATA(1), 0, zones_size, __MEMORY_START_2ND >> PAGE_SHIFT, 0);
 #endif
  	}
 }
diff -Nru a/arch/sparc/mm/fault.c b/arch/sparc/mm/fault.c
--- a/arch/sparc/mm/fault.c	Wed Aug 28 07:37:37 2002
+++ b/arch/sparc/mm/fault.c	Wed Aug 28 07:37:37 2002
@@ -233,7 +233,7 @@
 	 * If we're in an interrupt or have no user
 	 * context, we must not take the fault..
 	 */
-        if (in_interrupt() || !mm)
+        if (in_atomic() || !mm)
                 goto no_context;
 
 	down_read(&mm->mmap_sem);
diff -Nru a/arch/sparc/mm/srmmu.c b/arch/sparc/mm/srmmu.c
--- a/arch/sparc/mm/srmmu.c	Wed Aug 28 07:37:37 2002
+++ b/arch/sparc/mm/srmmu.c	Wed Aug 28 07:37:37 2002
@@ -1311,7 +1311,7 @@
 		zholes_size[ZONE_HIGHMEM] = npages - calc_highpages();
 
 		free_area_init_node(0, NULL, NULL, zones_size,
-				    phys_base, zholes_size);
+				    phys_base >> PAGE_SHIFT, zholes_size);
 	}
 
 /* P3: easy to fix, todo. Current code is utterly broken, though. */
diff -Nru a/arch/sparc/mm/sun4c.c b/arch/sparc/mm/sun4c.c
--- a/arch/sparc/mm/sun4c.c	Wed Aug 28 07:37:36 2002
+++ b/arch/sparc/mm/sun4c.c	Wed Aug 28 07:37:36 2002
@@ -2074,7 +2074,7 @@
 		zholes_size[ZONE_HIGHMEM] = npages - calc_highpages();
 
 		free_area_init_node(0, NULL, NULL, zones_size,
-				    phys_base, zholes_size);
+				    phys_base >> PAGE_SHIFT, zholes_size);
 	}
 
 	cnt = 0;
diff -Nru a/arch/sparc64/mm/init.c b/arch/sparc64/mm/init.c
--- a/arch/sparc64/mm/init.c	Wed Aug 28 07:37:37 2002
+++ b/arch/sparc64/mm/init.c	Wed Aug 28 07:37:37 2002
@@ -1559,7 +1559,7 @@
 		zholes_size[ZONE_DMA] = npages - pages_avail;
 
 		free_area_init_node(0, NULL, NULL, zones_size,
-				    phys_base, zholes_size);
+				    phys_base >> PAGE_SHIFT, zholes_size);
 	}
 
 	device_scan();
diff -Nru a/drivers/block/loop.c b/drivers/block/loop.c
--- a/drivers/block/loop.c	Wed Aug 28 07:37:37 2002
+++ b/drivers/block/loop.c	Wed Aug 28 07:37:37 2002
@@ -210,8 +210,7 @@
 			goto fail;
 		if (aops->prepare_write(file, page, offset, offset+size))
 			goto unlock;
-		kaddr = page_address(page);
-		flush_dcache_page(page);
+		kaddr = kmap(page);
 		transfer_result = lo_do_transfer(lo, WRITE, kaddr + offset, data, size, IV);
 		if (transfer_result) {
 			/*
@@ -221,6 +220,8 @@
 			printk(KERN_ERR "loop: transfer error block %ld\n", index);
 			memset(kaddr + offset, 0, size);
 		}
+		flush_dcache_page(page);
+		kunmap(page);
 		if (aops->commit_write(file, page, offset, offset+size))
 			goto unlock;
 		if (transfer_result)
diff -Nru a/drivers/block/rd.c b/drivers/block/rd.c
--- a/drivers/block/rd.c	Wed Aug 28 07:37:37 2002
+++ b/drivers/block/rd.c	Wed Aug 28 07:37:37 2002
@@ -45,12 +45,14 @@
 #include <linux/config.h>
 #include <linux/string.h>
 #include <linux/slab.h>
-#include <asm/atomic.h>
+#include <linux/highmem.h>
 #include <linux/bio.h>
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/devfs_fs_kernel.h>
 #include <linux/buffer_head.h>		/* for invalidate_bdev() */
+#include <linux/backing-dev.h>
+
 #include <asm/uaccess.h>
 
 /*
@@ -73,10 +75,7 @@
 int initrd_below_start_ok;
 #endif
 
-/* Various static variables go here.  Most are used only in the RAM disk code.
- */
-
-static unsigned long rd_length[NUM_RAMDISKS];	/* Size of RAM disks in bytes   */
+static unsigned long rd_length[NUM_RAMDISKS];	/* Size of RAM disks in bytes */
 static int rd_kbsize[NUM_RAMDISKS];	/* Size in blocks of 1024 bytes */
 static devfs_handle_t devfs_handle;
 static struct block_device *rd_bdev[NUM_RAMDISKS];/* Protected device data */
@@ -87,7 +86,7 @@
  * architecture-specific setup routine (from the stored boot sector
  * information). 
  */
-int rd_size = CONFIG_BLK_DEV_RAM_SIZE;		/* Size of the RAM disks */
+
 /*
  * It would be very desiderable to have a soft-blocksize (that in the case
  * of the ramdisk driver is also the hardblocksize ;) of PAGE_SIZE because
@@ -101,68 +100,46 @@
  */
 int rd_blocksize = BLOCK_SIZE;			/* blocksize of the RAM disks */
 
+/* Size of the RAM disks */
+int rd_size = (CONFIG_BLK_DEV_RAM_SIZE + (PAGE_CACHE_SIZE >> 10) - 1) &
+			(PAGE_CACHE_MASK >> 10);
+
 /*
  * Copyright (C) 2000 Linus Torvalds.
  *               2000 Transmeta Corp.
  * aops copied from ramfs.
  */
-static int ramdisk_readpage(struct file *file, struct page * page)
-{
-	if (!PageUptodate(page)) {
-		memset(kmap(page), 0, PAGE_CACHE_SIZE);
-		kunmap(page);
-		flush_dcache_page(page);
-		SetPageUptodate(page);
-	}
-	unlock_page(page);
-	return 0;
-}
 
-static int ramdisk_prepare_write(struct file *file, struct page *page, unsigned offset, unsigned to)
+static void wipe_page(struct page *page)
 {
 	if (!PageUptodate(page)) {
-		void *addr = page_address(page);
-		memset(addr, 0, PAGE_CACHE_SIZE);
+		void *kaddr = kmap_atomic(page, KM_USER0);
+
+		memset(kaddr, 0, PAGE_CACHE_SIZE);
 		flush_dcache_page(page);
+		kunmap_atomic(kaddr, KM_USER0);
 		SetPageUptodate(page);
 	}
-	SetPageDirty(page);
-	return 0;
 }
 
-static int ramdisk_commit_write(struct file *file, struct page *page, unsigned offset, unsigned to)
+static int
+rd_blkdev_pagecache_IO(int rw, struct bio_vec *vec, sector_t sector, int minor)
 {
-	return 0;
-}
-
-static struct address_space_operations ramdisk_aops = {
-	readpage: ramdisk_readpage,
-	writepage: fail_writepage,
-	prepare_write: ramdisk_prepare_write,
-	commit_write: ramdisk_commit_write,
-};
-
-static int rd_blkdev_pagecache_IO(int rw, struct bio_vec *vec,
-				  sector_t sector, int minor)
-{
-	struct address_space * mapping;
+	struct address_space *mapping;
 	unsigned long index;
 	unsigned int vec_offset;
 	int offset, size, err;
 
 	err = 0;
 	mapping = rd_bdev[minor]->bd_inode->i_mapping;
-
 	index = sector >> (PAGE_CACHE_SHIFT - 9);
 	offset = (sector << 9) & ~PAGE_CACHE_MASK;
 	size = vec->bv_len;
 	vec_offset = vec->bv_offset;
 
 	do {
+		struct page *page;
 		int count;
-		struct page * page;
-		char * src, * dst;
-		int unlock = 0;
 
 		count = PAGE_CACHE_SIZE - offset;
 		if (count > size)
@@ -172,50 +149,39 @@
 		page = find_get_page(mapping, index);
 		if (!page) {
 			page = grab_cache_page(mapping, index);
-			err = -ENOMEM;
-			if (!page)
+			if (!page) {
+				err = -ENOMEM;
 				goto out;
-			err = 0;
-
-			if (!PageUptodate(page)) {
-				memset(kmap(page), 0, PAGE_CACHE_SIZE);
-				kunmap(page);
-				SetPageUptodate(page);
 			}
-
-			unlock = 1;
+			wipe_page(page);
+			set_page_dirty(page);
+			unlock_page(page);
 		}
-
-		index++;
-
-		if (rw == READ) {
-			src = kmap(page);
-			src += offset;
-			dst = kmap(vec->bv_page) + vec_offset;
-		} else {
-			dst = kmap(page);
-			dst += offset;
-			src = kmap(vec->bv_page) + vec_offset;
+		if (page != vec->bv_page || vec_offset != offset) {
+			if (rw == READ) {
+				char *src = kmap_atomic(page, KM_USER0);
+				char *dst = kmap_atomic(vec->bv_page, KM_USER1);
+
+				memcpy(dst + vec_offset, src + offset, count);
+				flush_dcache_page(vec->bv_page);
+				kunmap_atomic(src, KM_USER0);
+				kunmap_atomic(dst, KM_USER1);
+			} else {
+				char *src = kmap_atomic(vec->bv_page, KM_USER0);
+				char *dst = kmap_atomic(page, KM_USER1);
+
+				memcpy(dst + offset, src + vec_offset, count);
+				flush_dcache_page(page);
+				kunmap_atomic(vec->bv_page, KM_USER0);
+				kunmap_atomic(page, KM_USER1);
+			}
 		}
+		page_cache_release(page);
 		offset = 0;
 		vec_offset += count;
-
-		memcpy(dst, src, count);
-
-		kunmap(page);
-		kunmap(vec->bv_page);
-
-		if (rw == READ) {
-			flush_dcache_page(page);
-		} else {
-			SetPageDirty(page);
-		}
-		if (unlock)
-			unlock_page(page);
-		__free_page(page);
+		index++;
 	} while (size);
-
- out:
+out:
 	return err;
 }
 
@@ -243,42 +209,41 @@
  * 19-JAN-1998  Richard Gooch <rgooch@atnf.csiro.au>  Added devfs support
  *
  */
-static int rd_make_request(request_queue_t * q, struct bio *sbh)
+static int rd_make_request(request_queue_t * q, struct bio *bio)
 {
 	unsigned int minor;
 	unsigned long offset, len;
-	int rw = sbh->bi_rw;
+	int rw = bio->bi_rw;
 
-	minor = minor(to_kdev_t(sbh->bi_bdev->bd_dev));
+	minor = minor(to_kdev_t(bio->bi_bdev->bd_dev));
 
 	if (minor >= NUM_RAMDISKS)
 		goto fail;
 
-	offset = sbh->bi_sector << 9;
-	len = sbh->bi_size;
+	offset = bio->bi_sector << 9;
+	len = bio->bi_size;
 
 	if ((offset + len) > rd_length[minor])
 		goto fail;
 
-	if (rw==READA)
-		rw=READ;
-	if ((rw != READ) && (rw != WRITE)) {
-		printk(KERN_INFO "RAMDISK: bad command: %d\n", rw);
-		goto fail;
-	}
+	if (rw == READA)
+		rw = READ;
+	BUG_ON((rw != READ) && (rw != WRITE));
 
-	if (rd_blkdev_bio_IO(sbh, minor))
+	if (rd_blkdev_bio_IO(bio, minor))
 		goto fail;
 
-	set_bit(BIO_UPTODATE, &sbh->bi_flags);
-	sbh->bi_end_io(sbh);
+	set_bit(BIO_UPTODATE, &bio->bi_flags);
+	bio->bi_end_io(bio);
 	return 0;
  fail:
-	bio_io_error(sbh);
+	bio_io_error(bio);
 	return 0;
 } 
 
-static int rd_ioctl(struct inode *inode, struct file *file, unsigned int cmd, unsigned long arg)
+static int
+rd_ioctl(struct inode *inode, struct file *file,
+	unsigned int cmd, unsigned long arg)
 {
 	int error = -EINVAL;
 	unsigned int minor;
@@ -325,7 +290,6 @@
 	return count;
 }
 
-
 static int initrd_release(struct inode *inode,struct file *file)
 {
 	extern void free_initrd_mem(unsigned long, unsigned long);
@@ -343,14 +307,19 @@
 	return 0;
 }
 
-
 static struct file_operations initrd_fops = {
-	read:		initrd_read,
-	release:	initrd_release,
+	.read		= initrd_read,
+	.release	= initrd_release,
 };
 
 #endif
 
+struct address_space_operations ramdisk_aops;
+
+static struct backing_dev_info rd_backing_dev_info = {
+	.ra_pages	= 0,	/* No readahead */
+	.memory_backed	= 1,	/* Does not contribute to dirty memory */
+};
 
 static int rd_open(struct inode * inode, struct file * filp)
 {
@@ -375,21 +344,23 @@
 	 * Immunize device against invalidate_buffers() and prune_icache().
 	 */
 	if (rd_bdev[unit] == NULL) {
-		rd_bdev[unit] = bdget(kdev_t_to_nr(inode->i_rdev));
-		rd_bdev[unit]->bd_openers++;
-		rd_bdev[unit]->bd_block_size = rd_blocksize;
-		rd_bdev[unit]->bd_inode->i_mapping->a_ops = &ramdisk_aops;
-		rd_bdev[unit]->bd_inode->i_size = rd_length[unit];
-		rd_bdev[unit]->bd_queue = &blk_dev[MAJOR_NR].request_queue;
-	}
+		struct block_device *b = bdget(kdev_t_to_nr(inode->i_rdev));
 
+		rd_bdev[unit] = b;
+		b->bd_openers++;
+		b->bd_block_size = rd_blocksize;
+		b->bd_inode->i_mapping->a_ops = &ramdisk_aops;
+		b->bd_inode->i_mapping->backing_dev_info = &rd_backing_dev_info;
+		b->bd_inode->i_size = rd_length[unit];
+		b->bd_queue = &blk_dev[MAJOR_NR].request_queue;
+	}
 	return 0;
 }
 
 static struct block_device_operations rd_bd_op = {
-	owner:		THIS_MODULE,
-	open:		rd_open,
-	ioctl:		rd_ioctl,
+	.owner	= THIS_MODULE,
+	.open	= rd_open,
+	.ioctl	= rd_ioctl,
 };
 
 /* Before freeing the module, invalidate all of the protected buffers! */
@@ -411,6 +382,19 @@
 	blk_clear(MAJOR_NR);
 }
 
+/*
+ * If someone writes a ramdisk page with submit_bh(), we have a dirty page
+ * with clean buffers.  try_to_free_buffers() will then propagate the buffer
+ * cleanness up into page-cleaness and the VM will evict the page.
+ *
+ * To stop that happening, the ramdisk address_space has a ->releasepage()
+ * which always fails.
+ */
+static int fail_releasepage(struct page *page, int offset)
+{
+	return 0;
+}
+
 /* This is the registration and initialization section of the RAM disk driver */
 static int __init rd_init (void)
 {
@@ -422,6 +406,9 @@
 		       rd_blocksize);
 		rd_blocksize = BLOCK_SIZE;
 	}
+	ramdisk_aops = def_blk_aops;
+	ramdisk_aops.writepage = fail_writepage;
+	ramdisk_aops.releasepage = fail_releasepage;
 
 	if (register_blkdev(MAJOR_NR, "ramdisk", &rd_bd_op)) {
 		printk("RAMDISK: Could not get major %d", MAJOR_NR);
@@ -447,18 +434,18 @@
 
 #ifdef CONFIG_BLK_DEV_INITRD
 	/* We ought to separate initrd operations here */
-	register_disk(NULL, mk_kdev(MAJOR_NR,INITRD_MINOR), 1, &rd_bd_op, rd_size<<1);
+	register_disk(NULL, mk_kdev(MAJOR_NR,INITRD_MINOR),
+			1, &rd_bd_op, rd_size<<1);
 	devfs_register(devfs_handle, "initrd", DEVFS_FL_DEFAULT, MAJOR_NR,
 			INITRD_MINOR, S_IFBLK | S_IRUSR, &rd_bd_op, NULL);
 #endif
 
-	blk_size[MAJOR_NR] = rd_kbsize;		/* Size of the RAM disk in kB  */
+	blk_size[MAJOR_NR] = rd_kbsize;	/* Size of the RAM disk in kB  */
 
 	/* rd_size is given in kB */
 	printk("RAMDISK driver initialized: "
 	       "%d RAM disks of %dK size %d blocksize\n",
 	       NUM_RAMDISKS, rd_size, rd_blocksize);
-
 	return 0;
 }
 
@@ -487,9 +474,8 @@
 #endif
 
 /* options - modular */
-MODULE_PARM     (rd_size, "1i");
+MODULE_PARM(rd_size, "1i");
 MODULE_PARM_DESC(rd_size, "Size of each RAM disk in kbytes.");
 MODULE_PARM     (rd_blocksize, "i");
 MODULE_PARM_DESC(rd_blocksize, "Blocksize of each RAM disk in bytes.");
-
 MODULE_LICENSE("GPL");
diff -Nru a/drivers/net/ns83820.c b/drivers/net/ns83820.c
--- a/drivers/net/ns83820.c	Wed Aug 28 07:37:38 2002
+++ b/drivers/net/ns83820.c	Wed Aug 28 07:37:38 2002
@@ -1081,7 +1081,7 @@
 				   frag->page_offset,
 				   frag->size, PCI_DMA_TODEVICE);
 		dprintk("frag: buf=%08Lx  page=%08lx offset=%08lx\n",
-			(long long)buf, (long)(frag->page - mem_map),
+			(long long)buf, (long) page_to_pfn(frag->page),
 			frag->page_offset);
 		len = frag->size;
 		frag++;
diff -Nru a/drivers/scsi/scsi_scan.c b/drivers/scsi/scsi_scan.c
--- a/drivers/scsi/scsi_scan.c	Wed Aug 28 07:37:37 2002
+++ b/drivers/scsi/scsi_scan.c	Wed Aug 28 07:37:37 2002
@@ -1379,6 +1379,12 @@
 		printk(KERN_INFO "scsi: unknown device type %d\n", sdev->type);
 	}
 
+	/*
+	 * scsi_alloc_sdev did this, but do it again because we can now set
+	 * the bounce limit because the device type is known
+	 */
+	scsi_initialize_merge_fn(sdev);
+
 	sdev->random = (sdev->type == TYPE_TAPE) ? 0 : 1;
 
 	print_inquiry(inq_result);
diff -Nru a/fs/Config.in b/fs/Config.in
--- a/fs/Config.in	Wed Aug 28 07:37:37 2002
+++ b/fs/Config.in	Wed Aug 28 07:37:37 2002
@@ -32,6 +32,7 @@
 # dep_tristate '  Journal Block Device support (JBD for ext3)' CONFIG_JBD $CONFIG_EXT3_FS
 define_bool CONFIG_JBD $CONFIG_EXT3_FS
 dep_mbool '  JBD (ext3) debugging support' CONFIG_JBD_DEBUG $CONFIG_JBD
+dep_mbool '  Ext3 hashed index (htree) support' CONFIG_EXT3_INDEX $CONFIG_JBD
 
 # msdos file systems
 tristate 'DOS FAT fs support' CONFIG_FAT_FS
diff -Nru a/fs/affs/file.c b/fs/affs/file.c
--- a/fs/affs/file.c	Wed Aug 28 07:37:37 2002
+++ b/fs/affs/file.c	Wed Aug 28 07:37:37 2002
@@ -27,6 +27,7 @@
 #include <linux/fs.h>
 #include <linux/amigaffs.h>
 #include <linux/mm.h>
+#include <linux/highmem.h>
 #include <linux/pagemap.h>
 #include <linux/buffer_head.h>
 
@@ -518,6 +519,7 @@
 	pr_debug("AFFS: read_page(%u, %ld, %d, %d)\n", (u32)inode->i_ino, page->index, from, to);
 	if (from > to || to > PAGE_CACHE_SIZE)
 		BUG();
+	kmap(page);
 	data = page_address(page);
 	bsize = AFFS_SB(sb)->s_data_blksize;
 	tmp = (page->index << PAGE_CACHE_SHIFT) + from;
@@ -537,6 +539,8 @@
 		from += tmp;
 		boff = 0;
 	}
+	flush_dcache_page(page);
+	kunmap(page);
 	return 0;
 }
 
@@ -656,7 +660,11 @@
 			return err;
 	}
 	if (to < PAGE_CACHE_SIZE) {
-		memset(page_address(page) + to, 0, PAGE_CACHE_SIZE - to);
+		char *kaddr = kmap_atomic(page, KM_USER0);
+
+		memset(kaddr + to, 0, PAGE_CACHE_SIZE - to);
+		flush_dcache_page(page);
+		kunmap_atomic(kaddr, KM_USER0);
 		if (size > offset + to) {
 			if (size < offset + PAGE_CACHE_SIZE)
 				tmp = size & ~PAGE_CACHE_MASK;
diff -Nru a/fs/buffer.c b/fs/buffer.c
--- a/fs/buffer.c	Wed Aug 28 07:37:37 2002
+++ b/fs/buffer.c	Wed Aug 28 07:37:37 2002
@@ -22,6 +22,7 @@
 #include <linux/kernel.h>
 #include <linux/fs.h>
 #include <linux/mm.h>
+#include <linux/percpu.h>
 #include <linux/slab.h>
 #include <linux/smp_lock.h>
 #include <linux/blkdev.h>
@@ -307,10 +308,7 @@
 
 	/* We need to protect against concurrent writers.. */
 	down(&inode->i_sem);
-	ret = filemap_fdatawait(inode->i_mapping);
-	err = filemap_fdatawrite(inode->i_mapping);
-	if (!ret)
-		ret = err;
+	ret = filemap_fdatawrite(inode->i_mapping);
 	err = file->f_op->fsync(file, dentry, 0);
 	if (!ret)
 		ret = err;
@@ -345,10 +343,7 @@
 		goto out_putf;
 
 	down(&inode->i_sem);
-	ret = filemap_fdatawait(inode->i_mapping);
-	err = filemap_fdatawrite(inode->i_mapping);
-	if (!ret)
-		ret = err;
+	ret = filemap_fdatawrite(inode->i_mapping);
 	err = file->f_op->fsync(file, dentry, 1);
 	if (!ret)
 		ret = err;
@@ -396,14 +391,21 @@
 	head = page_buffers(page);
 	bh = head;
 	do {
-		if (bh->b_blocknr == block) {
+		if (bh->b_blocknr == block && buffer_mapped(bh)) {
 			ret = bh;
 			get_bh(bh);
 			goto out_unlock;
 		}
 		bh = bh->b_this_page;
 	} while (bh != head);
-	buffer_error();
+	/*
+	 * This path can happen if the page had some unmapped buffers, which
+	 * will have b_blocknr == -1.  When a ramdisk mapping's page was brought
+	 * partially uptodate by mkfs and unmap_underlying_metadata searches
+	 * for blocks in part of the page which wasn't touched by mkfs.
+	 *
+	 * buffer_error();
+	 */
 out_unlock:
 	spin_unlock(&bd_mapping->private_lock);
 	page_cache_release(page);
@@ -469,7 +471,7 @@
  */
 static void free_more_memory(void)
 {
-	zone_t *zone;
+	struct zone *zone;
 
 	zone = contig_page_data.node_zonelists[GFP_NOFS & GFP_ZONEMASK].zones[0];
 
@@ -1517,7 +1519,7 @@
  * @offset: the index of the truncation point
  *
  * block_invalidatepage() is called when all or part of the page has become
- * invalidatedby a truncate operation.
+ * invalidated by a truncate operation.
  *
  * block_invalidatepage() does not have to release all buffers, but it must
  * ensure that no dirty buffer is left outside @offset and that no I/O
@@ -1648,11 +1650,18 @@
  * the page lock, whoever dirtied the buffers may decide to clean them
  * again at any time.  We handle that by only looking at the buffer
  * state inside lock_buffer().
+ *
+ * If block_write_full_page() is called for regular writeback
+ * (called_for_sync() is false) then it will return -EAGAIN for a locked
+ * buffer.   This only can happen if someone has written the buffer directly,
+ * with submit_bh().  At the address_space level PageWriteback prevents this
+ * contention from occurring.
  */
 static int __block_write_full_page(struct inode *inode,
 			struct page *page, get_block_t *get_block)
 {
 	int err;
+	int ret = 0;
 	unsigned long block;
 	unsigned long last_block;
 	struct buffer_head *bh, *head;
@@ -1663,8 +1672,6 @@
 	last_block = (inode->i_size - 1) >> inode->i_blkbits;
 
 	if (!page_has_buffers(page)) {
-		if (S_ISBLK(inode->i_mode))
-			buffer_error();
 		if (!PageUptodate(page))
 			buffer_error();
 		create_empty_buffers(page, 1 << inode->i_blkbits,
@@ -1724,7 +1731,14 @@
 	do {
 		get_bh(bh);
 		if (buffer_mapped(bh) && buffer_dirty(bh)) {
-			lock_buffer(bh);
+			if (called_for_sync()) {
+				lock_buffer(bh);
+			} else {
+				if (test_set_buffer_locked(bh)) {
+					ret = -EAGAIN;
+					continue;
+				}
+			}
 			if (test_clear_buffer_dirty(bh)) {
 				if (!buffer_uptodate(bh))
 					buffer_error();
@@ -1733,8 +1747,7 @@
 				unlock_buffer(bh);
 			}
 		}
-		bh = bh->b_this_page;
-	} while (bh != head);
+	} while ((bh = bh->b_this_page) != head);
 
 	BUG_ON(PageWriteback(page));
 	SetPageWriteback(page);		/* Keeps try_to_free_buffers() away */
@@ -1774,7 +1787,10 @@
 			SetPageUptodate(page);
 		end_page_writeback(page);
 	}
+	if (err == 0)
+		return ret;
 	return err;
+
 recover:
 	/*
 	 * ENOSPC, or some other error.  We may already have added some
@@ -1786,7 +1802,8 @@
 	bh = head;
 	/* Recovery: lock and submit the mapped buffers */
 	do {
-		if (buffer_mapped(bh)) {
+		get_bh(bh);
+		if (buffer_mapped(bh) && buffer_dirty(bh)) {
 			lock_buffer(bh);
 			mark_buffer_async_write(bh);
 		} else {
@@ -1796,21 +1813,21 @@
 			 */
 			clear_buffer_dirty(bh);
 		}
-		bh = bh->b_this_page;
-	} while (bh != head);
+	} while ((bh = bh->b_this_page) != head);
+	SetPageError(page);
+	BUG_ON(PageWriteback(page));
+	SetPageWriteback(page);
+	unlock_page(page);
 	do {
 		struct buffer_head *next = bh->b_this_page;
 		if (buffer_async_write(bh)) {
-			set_buffer_uptodate(bh);
 			clear_buffer_dirty(bh);
 			submit_bh(WRITE, bh);
 			nr_underway++;
 		}
+		put_bh(bh);
 		bh = next;
 	} while (bh != head);
-	BUG_ON(PageWriteback(page));
-	SetPageWriteback(page);
-	unlock_page(page);
 	goto done;
 }
 
@@ -1822,7 +1839,6 @@
 	int err = 0;
 	unsigned blocksize, bbits;
 	struct buffer_head *bh, *head, *wait[2], **wait_bh=wait;
-	char *kaddr = kmap(page);
 
 	BUG_ON(!PageLocked(page));
 	BUG_ON(from > PAGE_CACHE_SIZE);
@@ -1863,13 +1879,19 @@
 					set_buffer_uptodate(bh);
 					continue;
 				}
-				if (block_end > to)
-					memset(kaddr+to, 0, block_end-to);
-				if (block_start < from)
-					memset(kaddr+block_start,
-						0, from-block_start);
-				if (block_end > to || block_start < from)
+				if (block_end > to || block_start < from) {
+					void *kaddr;
+
+					kaddr = kmap_atomic(page, KM_USER0);
+					if (block_end > to)
+						memset(kaddr+to, 0,
+							block_end-to);
+					if (block_start < from)
+						memset(kaddr+block_start,
+							0, from-block_start);
 					flush_dcache_page(page);
+					kunmap_atomic(kaddr, KM_USER0);
+				}
 				continue;
 			}
 		}
@@ -1908,10 +1930,14 @@
 		if (block_start >= to)
 			break;
 		if (buffer_new(bh)) {
+			void *kaddr;
+
 			clear_buffer_new(bh);
 			if (buffer_uptodate(bh))
 				buffer_error();
+			kaddr = kmap_atomic(page, KM_USER0);
 			memset(kaddr+block_start, 0, bh->b_size);
+			kunmap_atomic(kaddr, KM_USER0);
 			set_buffer_uptodate(bh);
 			mark_buffer_dirty(bh);
 		}
@@ -1997,9 +2023,10 @@
 					SetPageError(page);
 			}
 			if (!buffer_mapped(bh)) {
-				memset(kmap(page) + i*blocksize, 0, blocksize);
+				void *kaddr = kmap_atomic(page, KM_USER0);
+				memset(kaddr + i * blocksize, 0, blocksize);
 				flush_dcache_page(page);
-				kunmap(page);
+				kunmap_atomic(kaddr, KM_USER0);
 				set_buffer_uptodate(bh);
 				continue;
 			}
@@ -2107,7 +2134,7 @@
 	long status;
 	unsigned zerofrom;
 	unsigned blocksize = 1 << inode->i_blkbits;
-	char *kaddr;
+	void *kaddr;
 
 	while(page->index > (pgpos = *bytes>>PAGE_CACHE_SHIFT)) {
 		status = -ENOMEM;
@@ -2129,12 +2156,12 @@
 						PAGE_CACHE_SIZE, get_block);
 		if (status)
 			goto out_unmap;
-		kaddr = page_address(new_page);
+		kaddr = kmap_atomic(new_page, KM_USER0);
 		memset(kaddr+zerofrom, 0, PAGE_CACHE_SIZE-zerofrom);
 		flush_dcache_page(new_page);
+		kunmap_atomic(kaddr, KM_USER0);
 		__block_commit_write(inode, new_page,
 				zerofrom, PAGE_CACHE_SIZE);
-		kunmap(new_page);
 		unlock_page(new_page);
 		page_cache_release(new_page);
 	}
@@ -2159,21 +2186,20 @@
 	status = __block_prepare_write(inode, page, zerofrom, to, get_block);
 	if (status)
 		goto out1;
-	kaddr = page_address(page);
 	if (zerofrom < offset) {
+		kaddr = kmap_atomic(page, KM_USER0);
 		memset(kaddr+zerofrom, 0, offset-zerofrom);
 		flush_dcache_page(page);
+		kunmap_atomic(kaddr, KM_USER0);
 		__block_commit_write(inode, page, zerofrom, offset);
 	}
 	return 0;
 out1:
 	ClearPageUptodate(page);
-	kunmap(page);
 	return status;
 
 out_unmap:
 	ClearPageUptodate(new_page);
-	kunmap(new_page);
 	unlock_page(new_page);
 	page_cache_release(new_page);
 out:
@@ -2185,10 +2211,8 @@
 {
 	struct inode *inode = page->mapping->host;
 	int err = __block_prepare_write(inode, page, from, to, get_block);
-	if (err) {
+	if (err)
 		ClearPageUptodate(page);
-		kunmap(page);
-	}
 	return err;
 }
 
@@ -2196,7 +2220,6 @@
 {
 	struct inode *inode = page->mapping->host;
 	__block_commit_write(inode,page,from,to);
-	kunmap(page);
 	return 0;
 }
 
@@ -2206,7 +2229,6 @@
 	struct inode *inode = page->mapping->host;
 	loff_t pos = ((loff_t)page->index << PAGE_CACHE_SHIFT) + to;
 	__block_commit_write(inode,page,from,to);
-	kunmap(page);
 	if (pos > inode->i_size) {
 		inode->i_size = pos;
 		mark_inode_dirty(inode);
@@ -2223,6 +2245,7 @@
 	struct inode *inode = mapping->host;
 	struct page *page;
 	struct buffer_head *bh;
+	void *kaddr;
 	int err;
 
 	blocksize = 1 << inode->i_blkbits;
@@ -2275,9 +2298,10 @@
 			goto unlock;
 	}
 
-	memset(kmap(page) + offset, 0, length);
+	kaddr = kmap_atomic(page, KM_USER0);
+	memset(kaddr + offset, 0, length);
 	flush_dcache_page(page);
-	kunmap(page);
+	kunmap_atomic(kaddr, KM_USER0);
 
 	mark_buffer_dirty(bh);
 	err = 0;
@@ -2297,7 +2321,7 @@
 	struct inode * const inode = page->mapping->host;
 	const unsigned long end_index = inode->i_size >> PAGE_CACHE_SHIFT;
 	unsigned offset;
-	char *kaddr;
+	void *kaddr;
 
 	/* Is the page fully inside i_size? */
 	if (page->index < end_index)
@@ -2317,10 +2341,10 @@
 	 * the  page size, the remaining memory is zeroed when mapped, and
 	 * writes to that region are not written out to the file."
 	 */
-	kaddr = kmap(page);
+	kaddr = kmap_atomic(page, KM_USER0);
 	memset(kaddr + offset, 0, PAGE_CACHE_SIZE - offset);
 	flush_dcache_page(page);
-	kunmap(page);
+	kunmap_atomic(page, KM_USER0);
 	return __block_write_full_page(inode, page, get_block);
 }
 
@@ -2495,7 +2519,7 @@
 		 * This only applies in the rare case where try_to_free_buffers
 		 * succeeds but the page is not freed.
 		 */
-		ClearPageDirty(page);
+		clear_page_dirty(page);
 	}
 	spin_unlock(&mapping->private_lock);
 out:
@@ -2537,9 +2561,45 @@
 static kmem_cache_t *bh_cachep;
 static mempool_t *bh_mempool;
 
+/*
+ * Once the number of bh's in the machine exceeds this level, we start
+ * stripping them in writeback.
+ */
+static int max_buffer_heads;
+
+int buffer_heads_over_limit;
+
+struct bh_accounting {
+	int nr;			/* Number of live bh's */
+	int ratelimit;		/* Limit cacheline bouncing */
+};
+
+static DEFINE_PER_CPU(struct bh_accounting, bh_accounting) = {0, 0};
+
+static void recalc_bh_state(void)
+{
+	int i;
+	int tot = 0;
+
+	if (__get_cpu_var(bh_accounting).ratelimit++ < 4096)
+		return;
+	__get_cpu_var(bh_accounting).ratelimit = 0;
+	for (i = 0; i < NR_CPUS; i++) {
+		if (!cpu_possible(i))
+			continue;
+		tot += per_cpu(bh_accounting, i).nr;
+	}
+	buffer_heads_over_limit = (tot > max_buffer_heads);
+}
+	
 struct buffer_head *alloc_buffer_head(void)
 {
-	return mempool_alloc(bh_mempool, GFP_NOFS);
+	struct buffer_head *ret = mempool_alloc(bh_mempool, GFP_NOFS);
+	if (ret) {
+		__get_cpu_var(bh_accounting).nr++;
+		recalc_bh_state();
+	}
+	return ret;
 }
 EXPORT_SYMBOL(alloc_buffer_head);
 
@@ -2547,10 +2607,13 @@
 {
 	BUG_ON(!list_empty(&bh->b_assoc_buffers));
 	mempool_free(bh, bh_mempool);
+	__get_cpu_var(bh_accounting).nr--;
+	recalc_bh_state();
 }
 EXPORT_SYMBOL(free_buffer_head);
 
-static void init_buffer_head(void *data, kmem_cache_t *cachep, unsigned long flags)
+static void
+init_buffer_head(void *data, kmem_cache_t *cachep, unsigned long flags)
 {
 	if ((flags & (SLAB_CTOR_VERIFY|SLAB_CTOR_CONSTRUCTOR)) ==
 			    SLAB_CTOR_CONSTRUCTOR) {
@@ -2577,12 +2640,19 @@
 void __init buffer_init(void)
 {
 	int i;
+	int nrpages;
 
 	bh_cachep = kmem_cache_create("buffer_head",
 			sizeof(struct buffer_head), 0,
-			SLAB_HWCACHE_ALIGN, init_buffer_head, NULL);
+			0, init_buffer_head, NULL);
 	bh_mempool = mempool_create(MAX_UNUSED_BUFFERS, bh_mempool_alloc,
 				bh_mempool_free, NULL);
 	for (i = 0; i < ARRAY_SIZE(bh_wait_queue_heads); i++)
 		init_waitqueue_head(&bh_wait_queue_heads[i].wqh);
+
+	/*
+	 * Limit the bh occupancy to 10% of ZONE_NORMAL
+	 */
+	nrpages = (nr_free_buffer_pages() * 1) / 100;
+	max_buffer_heads = nrpages * (PAGE_SIZE / sizeof(struct buffer_head));
 }
diff -Nru a/fs/driverfs/inode.c b/fs/driverfs/inode.c
--- a/fs/driverfs/inode.c	Wed Aug 28 07:37:36 2002
+++ b/fs/driverfs/inode.c	Wed Aug 28 07:37:36 2002
@@ -32,6 +32,7 @@
 #include <linux/namei.h>
 #include <linux/module.h>
 #include <linux/slab.h>
+#include <linux/backing-dev.h>
 #include <linux/driverfs_fs.h>
 
 #include <asm/uaccess.h>
@@ -56,12 +57,19 @@
 static spinlock_t mount_lock = SPIN_LOCK_UNLOCKED;
 static int mount_count = 0;
 
+static struct backing_dev_info driverfs_backing_dev_info = {
+	.ra_pages	= 0,	/* No readahead */
+	.memory_backed	= 1,	/* Does not contribute to dirty memory */
+};
+
 static int driverfs_readpage(struct file *file, struct page * page)
 {
 	if (!PageUptodate(page)) {
-		memset(kmap(page), 0, PAGE_CACHE_SIZE);
-		kunmap(page);
+		void *kaddr = kmap_atomic(page, KM_USER0);
+
+		memset(kaddr, 0, PAGE_CACHE_SIZE);
 		flush_dcache_page(page);
+		kunmap_atomic(kaddr, KM_USER0);
 		SetPageUptodate(page);
 	}
 	unlock_page(page);
@@ -70,10 +78,12 @@
 
 static int driverfs_prepare_write(struct file *file, struct page *page, unsigned offset, unsigned to)
 {
-	void *addr = kmap(page);
 	if (!PageUptodate(page)) {
-		memset(addr, 0, PAGE_CACHE_SIZE);
+		void *kaddr = kmap_atomic(page, KM_USER0);
+
+		memset(kaddr, 0, PAGE_CACHE_SIZE);
 		flush_dcache_page(page);
+		kunmap_atomic(kaddr, KM_USER0);
 		SetPageUptodate(page);
 	}
 	return 0;
@@ -85,7 +95,6 @@
 	loff_t pos = ((loff_t)page->index << PAGE_CACHE_SHIFT) + to;
 
 	set_page_dirty(page);
-	kunmap(page);
 	if (pos > inode->i_size)
 		inode->i_size = pos;
 	return 0;
@@ -105,6 +114,7 @@
 		inode->i_rdev = NODEV;
 		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
 		inode->i_mapping->a_ops = &driverfs_aops;
+		inode->i_mapping->backing_dev_info = &driverfs_backing_dev_info;
 		switch (mode & S_IFMT) {
 		default:
 			init_special_inode(inode, mode, dev);
diff -Nru a/fs/ext2/dir.c b/fs/ext2/dir.c
--- a/fs/ext2/dir.c	Wed Aug 28 07:37:36 2002
+++ b/fs/ext2/dir.c	Wed Aug 28 07:37:36 2002
@@ -571,8 +571,8 @@
 	struct page *page = grab_cache_page(mapping, 0);
 	unsigned chunk_size = ext2_chunk_size(inode);
 	struct ext2_dir_entry_2 * de;
-	char *base;
 	int err;
+	void *kaddr;
 
 	if (!page)
 		return -ENOMEM;
@@ -581,22 +581,21 @@
 		unlock_page(page);
 		goto fail;
 	}
-	base = page_address(page);
-
-	de = (struct ext2_dir_entry_2 *) base;
+	kaddr = kmap_atomic(page, KM_USER0);
+	de = (struct ext2_dir_entry_2 *)kaddr;
 	de->name_len = 1;
 	de->rec_len = cpu_to_le16(EXT2_DIR_REC_LEN(1));
 	memcpy (de->name, ".\0\0", 4);
 	de->inode = cpu_to_le32(inode->i_ino);
 	ext2_set_de_type (de, inode);
 
-	de = (struct ext2_dir_entry_2 *) (base + EXT2_DIR_REC_LEN(1));
+	de = (struct ext2_dir_entry_2 *)(kaddr + EXT2_DIR_REC_LEN(1));
 	de->name_len = 2;
 	de->rec_len = cpu_to_le16(chunk_size - EXT2_DIR_REC_LEN(1));
 	de->inode = cpu_to_le32(parent->i_ino);
 	memcpy (de->name, "..\0", 4);
 	ext2_set_de_type (de, inode);
-
+	kunmap_atomic(kaddr, KM_USER0);
 	err = ext2_commit_chunk(page, 0, chunk_size);
 fail:
 	page_cache_release(page);
diff -Nru a/fs/ext3/Makefile b/fs/ext3/Makefile
--- a/fs/ext3/Makefile	Wed Aug 28 07:37:36 2002
+++ b/fs/ext3/Makefile	Wed Aug 28 07:37:36 2002
@@ -5,6 +5,6 @@
 obj-$(CONFIG_EXT3_FS) += ext3.o
 
 ext3-objs    := balloc.o bitmap.o dir.o file.o fsync.o ialloc.o inode.o \
-		ioctl.o namei.o super.o symlink.o
+		ioctl.o namei.o super.o symlink.o hash.o
 
 include $(TOPDIR)/Rules.make
diff -Nru a/fs/ext3/hash.c b/fs/ext3/hash.c
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/fs/ext3/hash.c	Wed Aug 28 07:37:38 2002
@@ -0,0 +1,117 @@
+/*
+ *  linux/fs/ext3/hash.c
+ *
+ * By Stephen C. Tweedie, 2002
+ * Copyright (C) 2002, Red Hat, Inc.
+ *
+ * This file is released under the GPL v2.
+ * 
+ * MD4 hash from drivers/char/random.c,
+ * Copyright Theodore Ts'o, 1994, 1995, 1996, 1997, 1998, 1999.  All
+ * rights reserved.
+ * 
+ *  Hash Tree Directory indexing porting
+ *  	Christopher Li, 2002
+ */
+
+#include <linux/fs.h>
+#include <linux/jbd.h>
+#include <linux/sched.h>
+#include <linux/ext3_fs.h>
+
+
+/* F, G and H are basic MD4 functions: selection, majority, parity */
+#define F(x, y, z) ((z) ^ ((x) & ((y) ^ (z))))
+#define G(x, y, z) (((x) & (y)) + (((x) ^ (y)) & (z)))
+#define H(x, y, z) ((x) ^ (y) ^ (z))
+
+/*
+ * The generic round function.  The application is so specific that
+ * we don't bother protecting all the arguments with parens, as is generally
+ * good macro practice, in favor of extra legibility.
+ * Rotation is separate from addition to prevent recomputation
+ */
+#define ROUND(f, a, b, c, d, x, s)	\
+	(a += f(b, c, d) + x, a = (a << s) | (a >> (32-s)))
+#define K1 0
+#define K2 013240474631UL
+#define K3 015666365641UL
+
+/*
+ * Basic cut-down MD4 transform.  Returns only 32 bits of result.
+ */
+static __u32 halfMD4Transform (__u32 buf[4], __u32 const in[8])
+{
+	__u32	a = buf[0], b = buf[1], c = buf[2], d = buf[3];
+
+	/* Round 1 */
+	ROUND(F, a, b, c, d, in[0] + K1,  3);
+	ROUND(F, d, a, b, c, in[1] + K1,  7);
+	ROUND(F, c, d, a, b, in[2] + K1, 11);
+	ROUND(F, b, c, d, a, in[3] + K1, 19);
+	ROUND(F, a, b, c, d, in[4] + K1,  3);
+	ROUND(F, d, a, b, c, in[5] + K1,  7);
+	ROUND(F, c, d, a, b, in[6] + K1, 11);
+	ROUND(F, b, c, d, a, in[7] + K1, 19);
+
+	/* Round 2 */
+	ROUND(G, a, b, c, d, in[1] + K2,  3);
+	ROUND(G, d, a, b, c, in[3] + K2,  5);
+	ROUND(G, c, d, a, b, in[5] + K2,  9);
+	ROUND(G, b, c, d, a, in[7] + K2, 13);
+	ROUND(G, a, b, c, d, in[0] + K2,  3);
+	ROUND(G, d, a, b, c, in[2] + K2,  5);
+	ROUND(G, c, d, a, b, in[4] + K2,  9);
+	ROUND(G, b, c, d, a, in[6] + K2, 13);
+
+	/* Round 3 */
+	ROUND(H, a, b, c, d, in[3] + K3,  3);
+	ROUND(H, d, a, b, c, in[7] + K3,  9);
+	ROUND(H, c, d, a, b, in[2] + K3, 11);
+	ROUND(H, b, c, d, a, in[6] + K3, 15);
+	ROUND(H, a, b, c, d, in[1] + K3,  3);
+	ROUND(H, d, a, b, c, in[5] + K3,  9);
+	ROUND(H, c, d, a, b, in[0] + K3, 11);
+	ROUND(H, b, c, d, a, in[4] + K3, 15);
+
+	/* Mix the new digest into the existing digest buffer (the
+	   version in random.c does not do this --- it uses a static
+	   digest seed for each hash. */
+
+	buf[0] += a, buf[1] += b, buf[2] += c, buf[3] += d;
+	
+	return buf[1] + b;	/* "most hashed" word */
+	/* Alternative: return sum of all words? */
+}
+
+
+__u32 ext3_make_halfMD4_hash(const char *p, int len)
+{
+	__u32 buf[4];
+	__u32 hash = 0;
+
+	/* Initial MD4 digest seed, from the MD4 docs: */
+	buf[0] = 0x67452301;
+	buf[1] = 0xefcdab89;
+	buf[2] = 0x98badcfe;
+	buf[3] = 0x10325476;
+	
+	while (len) {
+		if (len < 32) {
+			char pad_buffer[32];
+			/* Need to pad the input to 8 words for the hash */
+			memcpy(pad_buffer, p, len);
+			memset(pad_buffer+len, 0, 32-len);
+			hash = halfMD4Transform(buf, (__u32 *) pad_buffer);
+			break;
+		}
+		
+		hash = halfMD4Transform(buf, (__u32 *) p);
+		len -= 32;
+		p += 32;
+		continue;
+	}
+
+	return hash;
+}
+
diff -Nru a/fs/ext3/inode.c b/fs/ext3/inode.c
--- a/fs/ext3/inode.c	Wed Aug 28 07:37:37 2002
+++ b/fs/ext3/inode.c	Wed Aug 28 07:37:37 2002
@@ -734,9 +734,9 @@
  * The BKL may not be held on entry here.  Be sure to take it early.
  */
 
-static int ext3_get_block_handle(handle_t *handle, struct inode *inode, 
-				 sector_t iblock,
-				 struct buffer_head *bh_result, int create)
+static int
+ext3_get_block_handle(handle_t *handle, struct inode *inode, sector_t iblock,
+		struct buffer_head *bh_result, int create, int extend_disksize)
 {
 	int err = -EIO;
 	int offsets[4];
@@ -818,16 +818,17 @@
 	if (err)
 		goto cleanup;
 
-	new_size = inode->i_size;
-	/*
-	 * This is not racy against ext3_truncate's modification of i_disksize
-	 * because VM/VFS ensures that the file cannot be extended while
-	 * truncate is in progress.  It is racy between multiple parallel
-	 * instances of get_block, but we have the BKL.
-	 */
-	if (new_size > ei->i_disksize)
-		ei->i_disksize = new_size;
-
+	if (extend_disksize) {
+		/*
+		 * This is not racy against ext3_truncate's modification of
+		 * i_disksize because VM/VFS ensures that the file cannot be
+		 * extended while truncate is in progress.  It is racy between
+		 * multiple parallel instances of get_block, but we have BKL.
+		 */
+		new_size = inode->i_size;
+		if (new_size > ei->i_disksize)
+			ei->i_disksize = new_size;
+	}
 	set_buffer_new(bh_result);
 	goto got_it;
 
@@ -851,10 +852,43 @@
 		handle = ext3_journal_current_handle();
 		J_ASSERT(handle != 0);
 	}
-	ret = ext3_get_block_handle(handle, inode, iblock, bh_result, create);
+	ret = ext3_get_block_handle(handle, inode, iblock,
+				bh_result, create, 1);
 	return ret;
 }
 
+#define DIO_CREDITS (EXT3_RESERVE_TRANS_BLOCKS + 32)
+
+static int
+ext3_direct_io_get_blocks(struct inode *inode, sector_t iblock,
+		unsigned long max_blocks, struct buffer_head *bh_result,
+		int create)
+{
+	handle_t *handle = journal_current_handle();
+	int ret = 0;
+
+	lock_kernel();
+	if (handle && handle->h_buffer_credits <= EXT3_RESERVE_TRANS_BLOCKS) {
+		/*
+		 * Getting low on buffer credits...
+		 */
+		if (!ext3_journal_extend(handle, DIO_CREDITS)) {
+			/*
+			 * Couldn't extend the transaction.  Start a new one
+			 */
+			ret = ext3_journal_restart(handle, DIO_CREDITS);
+		}
+	}
+	if (ret == 0)
+		ret = ext3_get_block_handle(handle, inode, iblock,
+					bh_result, create, 0);
+	if (ret == 0)
+		bh_result->b_size = (1 << inode->i_blkbits);
+	unlock_kernel();
+	return ret;
+}
+
+
 /*
  * `handle' can be NULL if create is zero
  */
@@ -869,7 +903,7 @@
 	dummy.b_state = 0;
 	dummy.b_blocknr = -1000;
 	buffer_trace_init(&dummy.b_history);
-	*errp = ext3_get_block_handle(handle, inode, block, &dummy, create);
+	*errp = ext3_get_block_handle(handle, inode, block, &dummy, create, 1);
 	if (!*errp && buffer_mapped(&dummy)) {
 		struct buffer_head *bh;
 		bh = sb_getblk(inode->i_sb, dummy.b_blocknr);
@@ -1048,16 +1082,6 @@
 	if (ext3_should_journal_data(inode)) {
 		ret = walk_page_buffers(handle, page_buffers(page),
 				from, to, NULL, do_journal_get_write_access);
-		if (ret) {
-			/*
-			 * We're going to fail this prepare_write(),
-			 * so commit_write() will not be called.
-			 * We need to undo block_prepare_write()'s kmap().
-			 * AKPM: Do we need to clear PageUptodate?  I don't
-			 * think so.
-			 */
-			kunmap(page);
-		}
 	}
 prepare_write_failed:
 	if (ret)
@@ -1117,7 +1141,6 @@
 			from, to, &partial, commit_write_fn);
 		if (!partial)
 			SetPageUptodate(page);
-		kunmap(page);
 		if (pos > inode->i_size)
 			inode->i_size = pos;
 		EXT3_I(inode)->i_state |= EXT3_STATE_JDATA;
@@ -1128,17 +1151,8 @@
 		}
 		/* Be careful here if generic_commit_write becomes a
 		 * required invocation after block_prepare_write. */
-		if (ret == 0) {
+		if (ret == 0)
 			ret = generic_commit_write(file, page, from, to);
-		} else {
-			/*
-			 * block_prepare_write() was called, but we're not
-			 * going to call generic_commit_write().  So we
-			 * need to perform generic_commit_write()'s kunmap
-			 * by hand.
-			 */
-			kunmap(page);
-		}
 	}
 	if (inode->i_size > EXT3_I(inode)->i_disksize) {
 		EXT3_I(inode)->i_disksize = inode->i_size;
@@ -1344,10 +1358,11 @@
 
 	/*
 	 * We have to fail this writepage to avoid cross-fs transactions.
-	 * Put the page back on mapping->dirty_pages, but leave its buffer's
-	 * dirty state as-is.
+	 * Return EAGAIN so the caller will the page back on
+	 * mapping->dirty_pages.  The page's buffers' dirty state will be left
+	 * as-is.
 	 */
-	__set_page_dirty_nobuffers(page);
+	ret = -EAGAIN;
 	unlock_page(page);
 	return ret;
 }
@@ -1376,17 +1391,83 @@
 	return journal_try_to_free_buffers(journal, page, wait);
 }
 
+/*
+ * If the O_DIRECT write will extend the file then add this inode to the
+ * orphan list.  So recovery will truncate it back to the original size
+ * if the machine crashes during the write.
+ *
+ * If the O_DIRECT write is intantiating holes inside i_size and the machine
+ * crashes then stale disk data _may_ be exposed inside the file.
+ */
+static int ext3_direct_IO(int rw, struct inode *inode, char *buf,
+			loff_t offset, size_t count)
+{
+	struct ext3_inode_info *ei = EXT3_I(inode);
+	handle_t *handle = NULL;
+	int ret;
+	int orphan = 0;
+
+	if (rw == WRITE) {
+		loff_t final_size = offset + count;
+
+		lock_kernel();
+		handle = ext3_journal_start(inode, DIO_CREDITS);
+		unlock_kernel();
+		if (IS_ERR(handle)) {
+			ret = PTR_ERR(handle);
+			goto out;
+		}
+		if (final_size > inode->i_size) {
+			lock_kernel();
+			ret = ext3_orphan_add(handle, inode);
+			unlock_kernel();
+			if (ret)
+				goto out_stop;
+			orphan = 1;
+			ei->i_disksize = inode->i_size;
+		}
+	}
+
+	ret = generic_direct_IO(rw, inode, buf, offset,
+				count, ext3_direct_io_get_blocks);
+
+out_stop:
+	if (handle) {
+		int err;
+
+		lock_kernel();
+		if (orphan) 
+			ext3_orphan_del(handle, inode);
+		if (orphan && ret > 0) {
+			loff_t end = offset + ret;
+			if (end > inode->i_size) {
+				ei->i_disksize = end;
+				inode->i_size = end;
+				err = ext3_mark_inode_dirty(handle, inode);
+				if (!ret) 
+					ret = err;
+			}
+		}
+		err = ext3_journal_stop(handle, inode);
+		if (ret == 0)
+			ret = err;
+		unlock_kernel();
+	}
+out:
+	return ret;
+}
 
 struct address_space_operations ext3_aops = {
-	.readpage	= ext3_readpage,		/* BKL not held.  Don't need */
-	.readpages	= ext3_readpages,		/* BKL not held.  Don't need */
-	.writepage	= ext3_writepage,		/* BKL not held.  We take it */
+	.readpage	= ext3_readpage,	/* BKL not held.  Don't need */
+	.readpages	= ext3_readpages,	/* BKL not held.  Don't need */
+	.writepage	= ext3_writepage,	/* BKL not held.  We take it */
 	.sync_page	= block_sync_page,
 	.prepare_write	= ext3_prepare_write,	/* BKL not held.  We take it */
 	.commit_write	= ext3_commit_write,	/* BKL not held.  We take it */
 	.bmap		= ext3_bmap,		/* BKL held */
 	.invalidatepage	= ext3_invalidatepage,	/* BKL not held.  Don't need */
 	.releasepage	= ext3_releasepage,	/* BKL not held.  Don't need */
+	.direct_IO	= ext3_direct_IO,	/* BKL not held.  Don't need */
 };
 
 /* For writeback mode, we can use mpage_writepages() */
@@ -1405,9 +1486,9 @@
 }
 
 struct address_space_operations ext3_writeback_aops = {
-	.readpage	= ext3_readpage,		/* BKL not held.  Don't need */
-	.readpages	= ext3_readpages,		/* BKL not held.  Don't need */
-	.writepage	= ext3_writepage,		/* BKL not held.  We take it */
+	.readpage	= ext3_readpage,	/* BKL not held.  Don't need */
+	.readpages	= ext3_readpages,	/* BKL not held.  Don't need */
+	.writepage	= ext3_writepage,	/* BKL not held.  We take it */
 	.writepages	= ext3_writepages,	/* BKL not held.  Don't need */
 	.sync_page	= block_sync_page,
 	.prepare_write	= ext3_prepare_write,	/* BKL not held.  We take it */
@@ -1415,6 +1496,7 @@
 	.bmap		= ext3_bmap,		/* BKL held */
 	.invalidatepage	= ext3_invalidatepage,	/* BKL not held.  Don't need */
 	.releasepage	= ext3_releasepage,	/* BKL not held.  Don't need */
+	.direct_IO	= ext3_direct_IO,	/* BKL not held.  Don't need */
 };
 
 /*
@@ -1433,6 +1515,7 @@
 	struct page *page;
 	struct buffer_head *bh;
 	int err;
+	void *kaddr;
 
 	blocksize = inode->i_sb->s_blocksize;
 	length = offset & (blocksize - 1);
@@ -1488,10 +1571,11 @@
 		if (err)
 			goto unlock;
 	}
-	
-	memset(kmap(page) + offset, 0, length);
+
+	kaddr = kmap_atomic(page, KM_USER0);
+	memset(kaddr + offset, 0, length);
 	flush_dcache_page(page);
-	kunmap(page);
+	kunmap_atomic(kaddr, KM_USER0);
 
 	BUFFER_TRACE(bh, "zeroed end of block");
 
diff -Nru a/fs/ext3/namei.c b/fs/ext3/namei.c
--- a/fs/ext3/namei.c	Wed Aug 28 07:37:37 2002
+++ b/fs/ext3/namei.c	Wed Aug 28 07:37:37 2002
@@ -16,9 +16,14 @@
  *        David S. Miller (davem@caip.rutgers.edu), 1995
  *  Directory entry file type support and forward compatibility hooks
  *  	for B-tree directories by Theodore Ts'o (tytso@mit.edu), 1998
+ *  Hash Tree Directory indexing (c)
+ *  	Daniel Phillips, 2001
+ *  Hash Tree Directory indexing porting
+ *  	Christopher Li, 2002
  */
 
 #include <linux/fs.h>
+#include <linux/pagemap.h>
 #include <linux/jbd.h>
 #include <linux/time.h>
 #include <linux/ext3_fs.h>
@@ -39,6 +44,414 @@
 #define NAMEI_RA_SIZE        (NAMEI_RA_CHUNKS * NAMEI_RA_BLOCKS)
 #define NAMEI_RA_INDEX(c,b)  (((c) * NAMEI_RA_BLOCKS) + (b))
 
+static struct buffer_head *ext3_append(handle_t *handle,
+					struct inode *inode,
+					u32 *block, int *err)
+{
+	struct buffer_head *bh;
+
+	*block = inode->i_size >> inode->i_sb->s_blocksize_bits;
+
+	if ((bh = ext3_bread(handle, inode, *block, 1, err))) {
+		inode->i_size += inode->i_sb->s_blocksize;
+		EXT3_I(inode)->i_disksize = inode->i_size;
+		ext3_journal_get_write_access(handle,bh);
+	}
+	return bh;
+}
+
+#ifndef assert
+#define assert(test) J_ASSERT(test)
+#endif
+
+#ifndef swap
+#define swap(x, y) do { typeof(x) z = x; x = y; y = z; } while (0)
+#endif
+
+typedef struct { u32 v; } le_u32;
+typedef struct { u16 v; } le_u16;
+
+#define dxtrace_on(command) command
+#define dxtrace_off(command)
+#define dxtrace dxtrace_off
+
+struct fake_dirent
+{
+	/*le*/u32 inode;
+	/*le*/u16 rec_len;
+	u8 name_len;
+	u8 file_type;
+};
+
+struct dx_countlimit
+{
+	le_u16 limit;
+	le_u16 count;
+};
+
+struct dx_entry
+{
+	le_u32 hash;
+	le_u32 block;
+};
+
+/*
+ * dx_root_info is laid out so that if it should somehow get overlaid by a
+ * dirent the two low bits of the hash version will be zero.  Therefore, the
+ * hash version mod 4 should never be 0.  Sincerely, the paranoia department.
+ */
+
+struct dx_root
+{
+	struct fake_dirent dot;
+	char dot_name[4];
+	struct fake_dirent dotdot;
+	char dotdot_name[4];
+	struct dx_root_info
+	{
+		le_u32 reserved_zero;
+		u8 hash_version;
+		u8 info_length; /* 8 */
+		u8 indirect_levels;
+		u8 unused_flags;
+	}
+	info;
+	struct dx_entry	entries[0];
+};
+
+struct dx_node
+{
+	struct fake_dirent fake;
+	struct dx_entry	entries[0];
+};
+
+
+struct dx_frame
+{
+	struct buffer_head *bh;
+	struct dx_entry *entries;
+	struct dx_entry *at;
+};
+
+struct dx_map_entry
+{
+	u32 hash;
+	u32 offs;
+};
+
+typedef struct ext3_dir_entry_2 ext3_dirent;
+
+
+#ifdef CONFIG_EXT3_INDEX
+#if 0
+static inline unsigned dx_get_block (struct dx_entry *entry);
+static void dx_set_block (struct dx_entry *entry, unsigned value);
+static inline unsigned dx_get_hash (struct dx_entry *entry);
+static void dx_set_hash (struct dx_entry *entry, unsigned value);
+static unsigned dx_get_count (struct dx_entry *entries);
+static unsigned dx_get_limit (struct dx_entry *entries);
+static void dx_set_count (struct dx_entry *entries, unsigned value);
+static void dx_set_limit (struct dx_entry *entries, unsigned value);
+static unsigned dx_root_limit (struct inode *dir, unsigned infosize);
+static unsigned dx_node_limit (struct inode *dir);
+static struct dx_frame *dx_probe (struct inode *dir, u32 hash, struct dx_frame *frame);
+static void dx_release (struct dx_frame *frames);
+static int dx_make_map (ext3_dirent *de, int size, struct dx_map_entry map[]);
+static void dx_sort_map(struct dx_map_entry *map, unsigned count);
+static ext3_dirent *dx_copy_dirents (char *from, char *to,
+     struct dx_map_entry *map, int count);
+static void dx_insert_block (struct dx_frame *frame, u32 hash, u32 block);
+#endif
+/*
+ * Future: use high four bits of block for coalesce-on-delete flags
+ * Mask them off for now.
+ */
+
+static inline unsigned dx_get_block (struct dx_entry *entry)
+{
+	return le32_to_cpu(entry->block.v) & 0x00ffffff;
+}
+
+static inline void dx_set_block (struct dx_entry *entry, unsigned value)
+{
+	entry->block.v = cpu_to_le32(value);
+}
+
+static inline unsigned dx_get_hash (struct dx_entry *entry)
+{
+	return le32_to_cpu(entry->hash.v);
+}
+
+static inline void dx_set_hash (struct dx_entry *entry, unsigned value)
+{
+	entry->hash.v = cpu_to_le32(value);
+}
+
+static inline unsigned dx_get_count (struct dx_entry *entries)
+{
+	return le16_to_cpu(((struct dx_countlimit *) entries)->count.v);
+}
+
+static inline unsigned dx_get_limit (struct dx_entry *entries)
+{
+	return le16_to_cpu(((struct dx_countlimit *) entries)->limit.v);
+}
+
+static inline void dx_set_count (struct dx_entry *entries, unsigned value)
+{
+	((struct dx_countlimit *) entries)->count.v = cpu_to_le16(value);
+}
+
+static inline void dx_set_limit (struct dx_entry *entries, unsigned value)
+{
+	((struct dx_countlimit *) entries)->limit.v = cpu_to_le16(value);
+}
+
+static inline unsigned dx_root_limit (struct inode *dir, unsigned infosize)
+{
+	unsigned entry_space = dir->i_sb->s_blocksize - EXT3_DIR_REC_LEN(1) -
+		EXT3_DIR_REC_LEN(2) - infosize;
+	return 0? 20: entry_space / sizeof(struct dx_entry);
+}
+
+static inline unsigned dx_node_limit (struct inode *dir)
+{
+	unsigned entry_space = dir->i_sb->s_blocksize - EXT3_DIR_REC_LEN(0);
+	return 0? 22: entry_space / sizeof(struct dx_entry);
+}
+
+static inline __u32 dx_hash(const char *p, int len)
+{
+	return ext3_make_halfMD4_hash(p, len) & ~1UL;
+}
+
+/*
+ * Debug
+ */
+struct stats
+{ 
+	unsigned names;
+	unsigned space;
+	unsigned bcount;
+};
+
+static struct stats dx_show_leaf (ext3_dirent *de, int size, int show_names)
+{
+	unsigned names = 0, space = 0;
+	char *base = (char *) de;
+	printk("names: ");
+	while ((char *) de < base + size)
+	{
+		if (de->inode)
+		{
+			if (show_names)
+			{
+				int len = de->name_len;
+				char *name = de->name;
+				while (len--) printk("%c", *name++);
+				printk(":%x.%u ", dx_hash (de->name, de->name_len), ((char *) de - base));
+			}
+			space += EXT3_DIR_REC_LEN(de->name_len);
+	 		names++;
+		}
+		de = (ext3_dirent *) ((char *) de + le16_to_cpu(de->rec_len));
+	}
+	printk("(%i)\n", names);
+	return (struct stats) { names, space, 1 };
+}
+
+struct stats dx_show_entries (struct inode *dir, struct dx_entry *entries, int levels)
+{
+	unsigned blocksize = dir->i_sb->s_blocksize;
+	unsigned count = dx_get_count (entries), names = 0, space = 0, i;
+	unsigned bcount = 0;
+	struct buffer_head *bh;
+	int err;
+	printk("%i indexed blocks...\n", count);
+	for (i = 0; i < count; i++, entries++)
+	{
+		u32 block = dx_get_block(entries), hash = i? dx_get_hash(entries): 0;
+		u32 range = i < count - 1? (dx_get_hash(entries + 1) - hash): ~hash;
+		struct stats stats;
+		printk("%s%3u:%03u hash %8x/%8x ",levels?"":"   ", i, block, hash, range);
+		if (!(bh = ext3_bread (NULL,dir, block, 0,&err))) continue;
+		stats = levels?
+		   dx_show_entries (dir, ((struct dx_node *) bh->b_data)->entries, levels - 1):
+		   dx_show_leaf ((ext3_dirent *) bh->b_data, blocksize, 0);
+		names += stats.names;
+		space += stats.space;
+		bcount += stats.bcount;
+		brelse (bh);
+	}
+	if (bcount)
+		printk("%snames %u, fullness %u (%u%%)\n", levels?"":"   ",
+			names, space/bcount,(space/bcount)*100/blocksize);
+	return (struct stats) { names, space, bcount};
+}
+
+/*
+ * Probe for a directory leaf block to search
+ */
+
+static struct dx_frame *dx_probe (struct inode *dir, u32 hash, struct dx_frame *frame)
+{
+	unsigned count, indirect;
+	struct dx_entry *at, *entries, *p, *q, *m;
+	struct dx_root *root;
+	struct buffer_head *bh;
+	int err;
+	if (!(bh = ext3_bread (NULL,dir, 0, 0,&err)))
+		goto fail;
+	root = (struct dx_root *) bh->b_data;
+	if (root->info.hash_version != DX_HASH_HALF_MD4) {
+		ext3_warning(dir->i_sb, __FUNCTION__, 
+			     "Unrecognised inode hash code %d",
+			     root->info.hash_version);
+		goto fail;
+	}
+	
+	if (root->info.unused_flags & 1) {
+		ext3_warning(dir->i_sb, __FUNCTION__, 
+			     "Unimplemented inode hash flags: %#06x",
+			     root->info.unused_flags);
+		goto fail;
+	}
+	
+	if ((indirect = root->info.indirect_levels) > 1) {
+		ext3_warning(dir->i_sb, __FUNCTION__, 
+			     "Unimplemented inode hash depth: %#06x",
+			     root->info.indirect_levels);
+		goto fail;
+	}		
+
+	entries = (struct dx_entry *) (((char *) &root->info) + root->info.info_length);
+	assert (dx_get_limit(entries) == dx_root_limit(dir, root->info.info_length));
+	dxtrace (printk("Look up %x", hash));
+	while (1)
+	{
+		count = dx_get_count(entries);
+		assert (count && count <= dx_get_limit(entries));
+		p = entries + 1;
+		q = entries + count - 1;
+		while (p <= q)
+		{
+			m = p + (q - p)/2;
+			dxtrace(printk("."));
+			if (dx_get_hash(m) > hash)
+				q = m - 1;
+			else
+				p = m + 1;
+		}
+
+		if (0) // linear search cross check
+		{
+			unsigned n = count - 1;
+			at = entries;
+			while (n--)
+			{
+				dxtrace(printk(","));
+				if (dx_get_hash(++at) > hash)
+				{
+					at--;
+					break;
+				}
+			}
+			assert (at == p - 1);
+		}
+
+		at = p - 1;
+		dxtrace(printk(" %x->%u\n", at == entries? 0: dx_get_hash(at), dx_get_block(at)));
+		frame->bh = bh;
+		frame->entries = entries;
+		frame->at = at;
+		if (!indirect--) return frame;
+		if (!(bh = ext3_bread (NULL,dir, dx_get_block(at), 0,&err)))
+			goto fail2;
+		at = entries = ((struct dx_node *) bh->b_data)->entries;
+		assert (dx_get_limit(entries) == dx_node_limit (dir));
+		frame++;
+	}
+fail2:
+	brelse(frame->bh);
+fail:
+	return NULL;
+}
+
+static void dx_release (struct dx_frame *frames)
+{
+	if (((struct dx_root *) frames[0].bh->b_data)->info.indirect_levels)
+		brelse (frames[1].bh);
+	brelse (frames[0].bh);
+}
+
+/*
+ * Directory block splitting, compacting
+ */
+
+static int dx_make_map (ext3_dirent *de, int size, struct dx_map_entry map[])
+{
+	int count = 0;
+	char *base = (char *) de;
+	while ((char *) de < base + size)
+	{
+		map[count].hash = dx_hash (de->name, de->name_len);
+		map[count].offs = (u32) ((char *) de - base);
+		de = (ext3_dirent *) ((char *) de + le16_to_cpu(de->rec_len));
+		count++;
+	}
+	return count;
+}
+
+static void dx_sort_map (struct dx_map_entry *map, unsigned count)
+{
+        struct dx_map_entry *p, *q, *top = map + count - 1;
+        int more;
+        /* Combsort until bubble sort doesn't suck */
+        while (count > 2)
+	{
+                count = count*10/13;
+                if (count - 9 < 2) /* 9, 10 -> 11 */
+                        count = 11;
+                for (p = top, q = p - count; q >= map; p--, q--)
+                        if (p->hash < q->hash)
+                                swap(*p, *q);
+        }
+        /* Garden variety bubble sort */
+        do {
+                more = 0;
+                q = top;
+                while (q-- > map)
+		{
+                        if (q[1].hash >= q[0].hash)
+				continue;
+                        swap(*(q+1), *q);
+                        more = 1;
+		}
+	} while(more);
+}
+
+static void dx_insert_block(struct dx_frame *frame, u32 hash, u32 block)
+{
+	struct dx_entry *entries = frame->entries;
+	struct dx_entry *old = frame->at, *new = old + 1;
+	int count = dx_get_count(entries);
+
+	assert(count < dx_get_limit(entries));
+	assert(old < entries + count);
+	memmove(new + 1, new, (char *)(entries + count) - (char *)(new));
+	dx_set_hash(new, hash);
+	dx_set_block(new, block);
+	dx_set_count(entries, count + 1);
+}
+#endif
+
+
+static void ext3_update_dx_flag(struct inode *inode)
+{
+	if (!test_opt(inode->i_sb, INDEX))
+		EXT3_I(inode)->i_flags &= ~EXT3_INDEX_FL;
+}
+
 /*
  * NOTE! unlike strncmp, ext3_match returns 1 for success, 0 for failure.
  *
@@ -96,6 +509,15 @@
 }
 
 /*
+ * p is at least 6 bytes before the end of page
+ */
+static inline ext3_dirent *ext3_next_entry(ext3_dirent *p)
+{
+	return (ext3_dirent *)((char*)p + le16_to_cpu(p->rec_len));
+}
+
+
+/*
  *	ext3_find_entry()
  *
  * finds an entry in the specified directory with the wanted name. It
@@ -106,6 +528,8 @@
  * The returned buffer_head has ->b_count elevated.  The caller is expected
  * to brelse() it when appropriate.
  */
+
+	
 static struct buffer_head * ext3_find_entry (struct dentry *dentry,
 					struct ext3_dir_entry_2 ** res_dir)
 {
@@ -120,9 +544,78 @@
 	int num = 0;
 	int nblocks, i, err;
 	struct inode *dir = dentry->d_parent->d_inode;
-
+	int namelen;
+	const u8 *name;
+	unsigned blocksize;
+#ifdef CONFIG_EXT3_INDEX
+	ext3_dirent *de, *top;
+#endif
 	*res_dir = NULL;
 	sb = dir->i_sb;
+	blocksize = sb->s_blocksize;
+	namelen = dentry->d_name.len;
+	name = dentry->d_name.name;
+	if (namelen > EXT3_NAME_LEN)
+		return NULL;
+#ifdef CONFIG_EXT3_INDEX
+	if (ext3_dx && is_dx(dir)) {
+		u32 hash = dx_hash (name, namelen);
+		struct dx_frame frames[2], *frame;
+		if (!(frame = dx_probe (dir, hash, frames)))
+			return NULL;
+dxnext:
+		block = dx_get_block(frame->at);
+		if (!(bh = ext3_bread (NULL,dir, block, 0, &err)))
+			goto dxfail;
+		de = (ext3_dirent *) bh->b_data;
+		top = (ext3_dirent *) ((char *) de + blocksize -
+				EXT3_DIR_REC_LEN(0));
+		for (; de < top; de = ext3_next_entry(de))
+			if (ext3_match (namelen, name, de)) {
+				if (!ext3_check_dir_entry("ext3_find_entry",
+					  dir, de, bh,
+					  (block<<EXT3_BLOCK_SIZE_BITS(sb))
+					   +((char *)de - bh->b_data))) {
+					brelse (bh);
+					goto dxfail;
+				}
+				*res_dir = de;
+				goto dxfound;
+			}
+		brelse (bh);
+		/* Same hash continues in next block?  Search on. */
+		if (++(frame->at) == frame->entries + dx_get_count(frame->entries))
+		{
+			struct buffer_head *bh2;
+			if (frame == frames)
+				goto dxfail;
+			if (++(frames->at) == frames->entries + dx_get_count(frames->entries))
+				goto dxfail;
+			/* should omit read if not continued */
+			if (!(bh2 = ext3_bread (NULL, dir,
+						dx_get_block(frames->at),
+						0, &err)))
+				goto dxfail;
+			brelse (frame->bh);
+			frame->bh = bh2;
+			frame->at = frame->entries = ((struct dx_node *) bh2->b_data)->entries;
+			/* Subtle: the 0th entry has the count, find the hash in frame above */
+			if ((dx_get_hash(frames->at) & -2) == hash)
+				goto dxnext;
+			goto dxfail;
+		}
+		if ((dx_get_hash(frame->at) & -2) == hash)
+			goto dxnext;
+dxfail:
+		dxtrace(printk("%s not found\n", name));
+		dx_release (frames);
+		return NULL;
+dxfound:
+		dx_release (frames);
+		return bh;
+
+	}
+#endif
 
 	nblocks = dir->i_size >> EXT3_BLOCK_SIZE_BITS(sb);
 	start = EXT3_I(dir)->i_dir_start_lookup;
@@ -281,6 +774,88 @@
 		de->file_type = ext3_type_by_mode[(mode & S_IFMT)>>S_SHIFT];
 }
 
+#ifdef CONFIG_EXT3_INDEX
+static ext3_dirent *
+dx_copy_dirents (char *from, char *to, struct dx_map_entry *map, int count)
+{
+	unsigned rec_len = 0;
+
+	while (count--) {
+		ext3_dirent *de = (ext3_dirent *) (from + map->offs);
+		rec_len = EXT3_DIR_REC_LEN(de->name_len);
+		memcpy (to, de, rec_len);
+		((ext3_dirent *) to)->rec_len = rec_len;
+		to += rec_len;
+		map++;
+	}
+	return (ext3_dirent *) (to - rec_len);
+}
+
+static ext3_dirent *do_split(handle_t *handle, struct inode *dir,
+			struct buffer_head **bh,struct dx_frame *frame,
+			u32 hash, int *error)
+{
+	unsigned blocksize = dir->i_sb->s_blocksize;
+	unsigned count, continued;
+	struct buffer_head *bh2;
+	u32 newblock;
+	unsigned MAX_DX_MAP = PAGE_CACHE_SIZE/EXT3_DIR_REC_LEN(1) + 1;
+	u32 hash2;
+	struct dx_map_entry map[MAX_DX_MAP];
+	char *data1 = (*bh)->b_data, *data2, *data3;
+	unsigned split;
+	ext3_dirent *de, *de2;
+
+	bh2 = ext3_append (handle, dir, &newblock, error);
+	if (!(bh2))
+	{
+		brelse(*bh);
+		*bh = NULL;
+		return (ext3_dirent *)bh2;
+	}
+
+	BUFFER_TRACE(*bh, "get_write_access");
+	ext3_journal_get_write_access(handle, *bh);
+	BUFFER_TRACE(frame->bh, "get_write_access");
+	ext3_journal_get_write_access(handle, frame->bh);
+
+	data2 = bh2->b_data;
+
+	count = dx_make_map ((ext3_dirent *) data1, blocksize, map);
+	split = count/2; // need to adjust to actual middle
+	dx_sort_map (map, count);
+	hash2 = map[split].hash;
+	continued = hash2 == map[split - 1].hash;
+	dxtrace(printk("Split block %i at %x, %i/%i\n",
+		dx_get_block(frame->at), hash2, split, count-split));
+
+	/* Fancy dance to stay within two buffers */
+	de2 = dx_copy_dirents (data1, data2, map + split, count - split);
+	data3 = (char *) de2 + de2->rec_len;
+	de = dx_copy_dirents (data1, data3, map, split);
+	memcpy(data1, data3, (char *) de + de->rec_len - data3);
+	de = (ext3_dirent *) ((char *) de - data3 + data1); // relocate de
+	de->rec_len = cpu_to_le16(data1 + blocksize - (char *) de);
+	de2->rec_len = cpu_to_le16(data2 + blocksize - (char *) de2);
+	dxtrace(dx_show_leaf ((ext3_dirent *) data1, blocksize, 1));
+	dxtrace(dx_show_leaf ((ext3_dirent *) data2, blocksize, 1));
+
+	/* Which block gets the new entry? */
+	if (hash >= hash2)
+	{
+		swap(*bh, bh2);
+		de = de2;
+	}
+	dx_insert_block (frame, hash2 + continued, newblock);
+	ext3_journal_dirty_metadata (handle, bh2);
+	brelse (bh2);
+	ext3_journal_dirty_metadata (handle, frame->bh);
+	dxtrace(dx_show_index ("frame", frame->entries));
+	return de;
+}
+#endif
+
+
 /*
  *	ext3_add_entry()
  *
@@ -295,6 +870,7 @@
 /*
  * AKPM: the journalling code here looks wrong on the error paths
  */
+
 static int ext3_add_entry (handle_t *handle, struct dentry *dentry,
 	struct inode *inode)
 {
@@ -302,115 +878,283 @@
 	const char *name = dentry->d_name.name;
 	int namelen = dentry->d_name.len;
 	unsigned long offset;
-	unsigned short rec_len;
 	struct buffer_head * bh;
-	struct ext3_dir_entry_2 * de, * de1;
-	struct super_block * sb;
+	ext3_dirent *de;
+	struct super_block * sb = dir->i_sb;
 	int	retval;
+	unsigned short reclen = EXT3_DIR_REC_LEN(namelen);
 
-	sb = dir->i_sb;
+	unsigned blocksize = sb->s_blocksize;
+	unsigned nlen, rlen;
+	u32 block, blocks;
+	char *top;
 
 	if (!namelen)
 		return -EINVAL;
-	bh = ext3_bread (handle, dir, 0, 0, &retval);
-	if (!bh)
-		return retval;
-	rec_len = EXT3_DIR_REC_LEN(namelen);
-	offset = 0;
-	de = (struct ext3_dir_entry_2 *) bh->b_data;
-	while (1) {
-		if ((char *)de >= sb->s_blocksize + bh->b_data) {
-			brelse (bh);
-			bh = NULL;
-			bh = ext3_bread (handle, dir,
-				offset >> EXT3_BLOCK_SIZE_BITS(sb), 1, &retval);
-			if (!bh)
-				return retval;
-			if (dir->i_size <= offset) {
-				if (dir->i_size == 0) {
-					brelse(bh);
-					return -ENOENT;
+#ifdef CONFIG_EXT3_INDEX
+	if (ext3_dx && is_dx(dir)) {
+		struct dx_frame frames[2], *frame;
+		struct dx_entry *entries, *at;
+		u32 hash;
+		char *data1;
+
+		hash = dx_hash (name, namelen);
+		frame = dx_probe (dir, hash, frames); // do something if null
+		entries = frame->entries;
+		at = frame->at;
+
+		if (!(bh = ext3_bread (handle,dir, dx_get_block(frame->at), 0,&retval)))
+			goto dxfail1;
+
+		BUFFER_TRACE(bh, "get_write_access");
+		ext3_journal_get_write_access(handle, bh);
+
+		data1 = bh->b_data;
+		de = (ext3_dirent *) data1;
+		top = data1 + (0? 200: blocksize);
+		while ((char *) de < top)
+		{
+			/* FIXME: check EEXIST and dir */
+			nlen = EXT3_DIR_REC_LEN(de->name_len);
+			rlen = le16_to_cpu(de->rec_len);
+			if ((de->inode? rlen - nlen: rlen) >= reclen)
+				goto dx_add;
+			de = (ext3_dirent *) ((char *) de + rlen);
+		}
+		/* Block full, should compress but for now just split */
+		dxtrace(printk("using %u of %u node entries\n",
+			dx_get_count(entries), dx_get_limit(entries)));
+		/* Need to split index? */
+		if (dx_get_count(entries) == dx_get_limit(entries))
+		{
+			u32 newblock;
+			unsigned icount = dx_get_count(entries);
+			int levels = frame - frames;
+			struct dx_entry *entries2;
+			struct dx_node *node2;
+			struct buffer_head *bh2;
+			if (levels && dx_get_count(frames->entries) == dx_get_limit(frames->entries))
+				goto dxfull;
+			bh2 = ext3_append (handle, dir, &newblock, &retval);
+			if (!(bh2))
+				goto dxfail2;
+			node2 = (struct dx_node *)(bh2->b_data);
+			entries2 = node2->entries;
+			node2->fake.rec_len = cpu_to_le16(blocksize);
+			node2->fake.inode = 0;
+			BUFFER_TRACE(frame->bh, "get_write_access");
+			ext3_journal_get_write_access(handle, frame->bh);
+			if (levels)
+			{
+				unsigned icount1 = icount/2, icount2 = icount - icount1;
+				unsigned hash2 = dx_get_hash(entries + icount1);
+				dxtrace(printk("Split index %i/%i\n", icount1, icount2));
+				
+				BUFFER_TRACE(frame->bh, "get_write_access"); /* index root */
+				ext3_journal_get_write_access(handle, frames[0].bh);
+				
+				memcpy ((char *) entries2, (char *) (entries + icount1),
+					icount2 * sizeof(struct dx_entry));
+				dx_set_count (entries, icount1);
+				dx_set_count (entries2, icount2);
+				dx_set_limit (entries2, dx_node_limit(dir));
+
+				/* Which index block gets the new entry? */
+				if (at - entries >= icount1) {
+					frame->at = at = at - entries - icount1 + entries2;
+					frame->entries = entries = entries2;
+					swap(frame->bh, bh2);
 				}
-
-				ext3_debug ("creating next block\n");
-
-				BUFFER_TRACE(bh, "get_write_access");
-				ext3_journal_get_write_access(handle, bh);
-				de = (struct ext3_dir_entry_2 *) bh->b_data;
-				de->inode = 0;
-				de->rec_len = le16_to_cpu(sb->s_blocksize);
-				EXT3_I(dir)->i_disksize =
-					dir->i_size = offset + sb->s_blocksize;
-				EXT3_I(dir)->i_flags &= ~EXT3_INDEX_FL;
-				ext3_mark_inode_dirty(handle, dir);
+				dx_insert_block (frames + 0, hash2, newblock);
+				dxtrace(dx_show_index ("node", frames[1].entries));
+				dxtrace(dx_show_index ("node",
+					((struct dx_node *) bh2->b_data)->entries));
+				ext3_journal_dirty_metadata(handle, bh2);
+				brelse (bh2);
 			} else {
-
-				ext3_debug ("skipping to next block\n");
-
-				de = (struct ext3_dir_entry_2 *) bh->b_data;
+				dxtrace(printk("Creating second level index...\n"));
+				memcpy((char *) entries2, (char *) entries,
+					icount * sizeof(struct dx_entry));
+				dx_set_limit(entries2, dx_node_limit(dir));
+
+				/* Set up root */
+				dx_set_count(entries, 1);
+				dx_set_block(entries + 0, newblock);
+				((struct dx_root *) frames[0].bh->b_data)->info.indirect_levels = 1;
+
+				/* Add new access path frame */
+				frame = frames + 1;
+				frame->at = at = at - entries + entries2;
+				frame->entries = entries = entries2;
+				frame->bh = bh2;
+				ext3_journal_get_write_access(handle, frame->bh);
 			}
+			ext3_journal_dirty_metadata(handle, frames[0].bh);
 		}
-		if (!ext3_check_dir_entry ("ext3_add_entry", dir, de, bh,
-					   offset)) {
-			brelse (bh);
-			return -ENOENT;
-		}
-		if (ext3_match (namelen, name, de)) {
+		de = do_split(handle, dir, &bh, frame, hash, &retval);
+		dx_release (frames);
+		if (!(de))
+			goto fail;
+		nlen = EXT3_DIR_REC_LEN(de->name_len);
+		rlen = le16_to_cpu(de->rec_len);
+		goto add;
+
+dx_add:
+		dx_release (frames);
+		goto add;
+
+dxfull:
+		ext3_warning(sb, __FUNCTION__, "Directory index full!\n");
+		retval = -ENOSPC;
+dxfail2:
+		brelse(bh);
+dxfail1:
+		dx_release (frames);
+		goto fail1;
+	}
+#endif
+	blocks = dir->i_size >> sb->s_blocksize_bits;
+	for (block = 0, offset = 0; block < blocks; block++) {
+		bh = ext3_bread(handle, dir, block, 0, &retval);
+		if(!bh)
+			return retval;
+		de = (ext3_dirent *)bh->b_data;
+		top = bh->b_data + blocksize - reclen;
+		while ((char *) de <= top) {
+			if (!ext3_check_dir_entry("ext3_add_entry", dir, de,
+						  bh, offset)) {
+				brelse (bh);
+				return -EIO;
+			}
+			if (ext3_match (namelen, name, de)) {
 				brelse (bh);
 				return -EEXIST;
-		}
-		if ((le32_to_cpu(de->inode) == 0 &&
-				le16_to_cpu(de->rec_len) >= rec_len) ||
-		    (le16_to_cpu(de->rec_len) >=
-				EXT3_DIR_REC_LEN(de->name_len) + rec_len)) {
-			BUFFER_TRACE(bh, "get_write_access");
-			ext3_journal_get_write_access(handle, bh);
-			/* By now the buffer is marked for journaling */
-			offset += le16_to_cpu(de->rec_len);
-			if (le32_to_cpu(de->inode)) {
-				de1 = (struct ext3_dir_entry_2 *) ((char *) de +
-					EXT3_DIR_REC_LEN(de->name_len));
-				de1->rec_len =
-					cpu_to_le16(le16_to_cpu(de->rec_len) -
-					EXT3_DIR_REC_LEN(de->name_len));
-				de->rec_len = cpu_to_le16(
-						EXT3_DIR_REC_LEN(de->name_len));
-				de = de1;
 			}
-			de->file_type = EXT3_FT_UNKNOWN;
-			if (inode) {
-				de->inode = cpu_to_le32(inode->i_ino);
-				ext3_set_de_type(dir->i_sb, de, inode->i_mode);
-			} else
-				de->inode = 0;
-			de->name_len = namelen;
-			memcpy (de->name, name, namelen);
-			/*
-			 * XXX shouldn't update any times until successful
-			 * completion of syscall, but too many callers depend
-			 * on this.
-			 *
-			 * XXX similarly, too many callers depend on
-			 * ext3_new_inode() setting the times, but error
-			 * recovery deletes the inode, so the worst that can
-			 * happen is that the times are slightly out of date
-			 * and/or different from the directory change time.
-			 */
-			dir->i_mtime = dir->i_ctime = CURRENT_TIME;
-			EXT3_I(dir)->i_flags &= ~EXT3_INDEX_FL;
-			ext3_mark_inode_dirty(handle, dir);
-			dir->i_version = ++event;
-			BUFFER_TRACE(bh, "call ext3_journal_dirty_metadata");
-			ext3_journal_dirty_metadata(handle, bh);
+			nlen = EXT3_DIR_REC_LEN(de->name_len);
+			rlen = le16_to_cpu(de->rec_len);
+			if ((de->inode? rlen - nlen: rlen) >= reclen)
+				goto add;
+			de = (ext3_dirent *)((char *)de + rlen);
+			offset += rlen;
+		}
+#ifdef CONFIG_EXT3_INDEX
+		if (ext3_dx && blocks == 1 && test_opt(sb, INDEX))
+			goto dx_make_index;
+#endif
+		brelse(bh);
+	}
+	bh = ext3_append(handle, dir, &block, &retval);
+	if (!bh)
+		return retval;
+	de = (ext3_dirent *) bh->b_data;
+	de->inode = 0;
+	de->rec_len = cpu_to_le16(rlen = blocksize);
+	nlen = 0;
+	goto add;
+
+add:
+	BUFFER_TRACE(bh, "get_write_access");
+	ext3_journal_get_write_access(handle, bh);
+	/* By now the buffer is marked for journaling */
+	if (de->inode) {
+		ext3_dirent *de1 = (ext3_dirent *)((char *)de + nlen);
+		de1->rec_len = cpu_to_le16(rlen - nlen);
+		de->rec_len = cpu_to_le16(nlen);
+		de = de1;
+	}
+	de->file_type = EXT3_FT_UNKNOWN;
+	if (inode) {
+		de->inode = cpu_to_le32(inode->i_ino);
+		ext3_set_de_type(dir->i_sb, de, inode->i_mode);
+	} else
+		de->inode = 0;
+	de->name_len = namelen;
+	memcpy (de->name, name, namelen);
+	/*
+	 * XXX shouldn't update any times until successful
+	 * completion of syscall, but too many callers depend
+	 * on this.
+	 *
+	 * XXX similarly, too many callers depend on
+	 * ext3_new_inode() setting the times, but error
+	 * recovery deletes the inode, so the worst that can
+	 * happen is that the times are slightly out of date
+	 * and/or different from the directory change time.
+	 */
+	dir->i_mtime = dir->i_ctime = CURRENT_TIME;
+	ext3_update_dx_flag(dir);
+	ext3_mark_inode_dirty(handle, dir);
+	dir->i_version = ++event;
+	BUFFER_TRACE(bh, "call ext3_journal_dirty_metadata");
+	ext3_journal_dirty_metadata(handle, bh);
+	brelse(bh);
+	return 0;
+
+#ifdef CONFIG_EXT3_INDEX
+dx_make_index:
+	{
+		struct buffer_head *bh2;
+		struct dx_root *root;
+		struct dx_frame frames[2], *frame;
+		struct dx_entry *entries;
+		ext3_dirent *de2;
+		char *data1;
+		unsigned len;
+		u32 hash;
+		
+		dxtrace(printk("Creating index\n"));
+		ext3_journal_get_write_access(handle, bh);
+		root = (struct dx_root *) bh->b_data;
+		
+		EXT3_I(dir)->i_flags |= EXT3_INDEX_FL;
+		bh2 = ext3_append (handle, dir, &block, &retval);
+		if (!(bh2))
+		{
 			brelse(bh);
-			return 0;
+			return retval;
 		}
-		offset += le16_to_cpu(de->rec_len);
-		de = (struct ext3_dir_entry_2 *)
-			((char *) de + le16_to_cpu(de->rec_len));
+		data1 = bh2->b_data;
+
+		/* The 0th block becomes the root, move the dirents out */
+		de = (ext3_dirent *) &root->info;
+		len = ((char *) root) + blocksize - (char *) de;
+		memcpy (data1, de, len);
+		de = (ext3_dirent *) data1;
+		top = data1 + len;
+		while (((char *) de2=(char*)de+le16_to_cpu(de->rec_len)) < top)
+			de = de2;
+		de->rec_len = cpu_to_le16(data1 + blocksize - (char *) de);
+		/* Initialize the root; the dot dirents already exist */
+		de = (ext3_dirent *) (&root->dotdot);
+		de->rec_len = cpu_to_le16(blocksize - EXT3_DIR_REC_LEN(2));
+		memset (&root->info, 0, sizeof(root->info));
+		root->info.info_length = sizeof(root->info);
+		root->info.hash_version = DX_HASH_HALF_MD4;
+		entries = root->entries;
+		dx_set_block (entries, 1);
+		dx_set_count (entries, 1);
+		dx_set_limit (entries, dx_root_limit(dir, sizeof(root->info)));
+
+		/* Initialize as for dx_probe */
+		hash = dx_hash (name, namelen);
+		frame = frames;
+		frame->entries = entries;
+		frame->at = entries;
+		frame->bh = bh;
+		bh = bh2;
+		de = do_split(handle,dir, &bh, frame, hash, &retval);
+		dx_release (frames);
+		if (!(de))
+			return retval;
+		nlen = EXT3_DIR_REC_LEN(de->name_len);
+		rlen = le16_to_cpu(de->rec_len);
+		goto add;
 	}
-	brelse (bh);
-	return -ENOSPC;
+fail1:
+	return retval;
+fail:
+	return -ENOENT;
+#endif
 }
 
 /*
@@ -496,7 +1240,8 @@
 	int err;
 
 	lock_kernel();
-	handle = ext3_journal_start(dir, EXT3_DATA_TRANS_BLOCKS + 3);
+	handle = ext3_journal_start(dir, EXT3_DATA_TRANS_BLOCKS +
+					EXT3_INDEX_EXTRA_TRANS_BLOCKS + 3);
 	if (IS_ERR(handle)) {
 		unlock_kernel();
 		return PTR_ERR(handle);
@@ -530,7 +1275,8 @@
 	int err;
 
 	lock_kernel();
-	handle = ext3_journal_start(dir, EXT3_DATA_TRANS_BLOCKS + 3);
+	handle = ext3_journal_start(dir, EXT3_DATA_TRANS_BLOCKS +
+			 		EXT3_INDEX_EXTRA_TRANS_BLOCKS + 3);
 	if (IS_ERR(handle)) {
 		unlock_kernel();
 		return PTR_ERR(handle);
@@ -563,7 +1309,8 @@
 		return -EMLINK;
 
 	lock_kernel();
-	handle = ext3_journal_start(dir, EXT3_DATA_TRANS_BLOCKS + 3);
+	handle = ext3_journal_start(dir, EXT3_DATA_TRANS_BLOCKS +
+					EXT3_INDEX_EXTRA_TRANS_BLOCKS + 3);
 	if (IS_ERR(handle)) {
 		unlock_kernel();
 		return PTR_ERR(handle);
@@ -615,7 +1362,7 @@
 	if (err)
 		goto out_no_entry;
 	dir->i_nlink++;
-	EXT3_I(dir)->i_flags &= ~EXT3_INDEX_FL;
+	ext3_update_dx_flag(dir);
 	ext3_mark_inode_dirty(handle, dir);
 	d_instantiate(dentry, inode);
 out_stop:
@@ -894,7 +1641,7 @@
 	ext3_mark_inode_dirty(handle, inode);
 	dir->i_nlink--;
 	inode->i_ctime = dir->i_ctime = dir->i_mtime = CURRENT_TIME;
-	EXT3_I(dir)->i_flags &= ~EXT3_INDEX_FL;
+	ext3_update_dx_flag(dir);
 	ext3_mark_inode_dirty(handle, dir);
 
 end_rmdir:
@@ -944,7 +1691,7 @@
 	if (retval)
 		goto end_unlink;
 	dir->i_ctime = dir->i_mtime = CURRENT_TIME;
-	EXT3_I(dir)->i_flags &= ~EXT3_INDEX_FL;
+	ext3_update_dx_flag(dir);
 	ext3_mark_inode_dirty(handle, dir);
 	inode->i_nlink--;
 	if (!inode->i_nlink)
@@ -972,7 +1719,8 @@
 		return -ENAMETOOLONG;
 
 	lock_kernel();
-	handle = ext3_journal_start(dir, EXT3_DATA_TRANS_BLOCKS + 5);
+	handle = ext3_journal_start(dir, EXT3_DATA_TRANS_BLOCKS +
+			 		EXT3_INDEX_EXTRA_TRANS_BLOCKS + 5);
 	if (IS_ERR(handle)) {
 		unlock_kernel();
 		return PTR_ERR(handle);
@@ -1033,7 +1781,8 @@
 		return -EMLINK;
 	}
 
-	handle = ext3_journal_start(dir, EXT3_DATA_TRANS_BLOCKS);
+	handle = ext3_journal_start(dir, EXT3_DATA_TRANS_BLOCKS +
+					EXT3_INDEX_EXTRA_TRANS_BLOCKS);
 	if (IS_ERR(handle)) {
 		unlock_kernel();
 		return PTR_ERR(handle);
@@ -1073,7 +1822,8 @@
 	old_bh = new_bh = dir_bh = NULL;
 
 	lock_kernel();
-	handle = ext3_journal_start(old_dir, 2 * EXT3_DATA_TRANS_BLOCKS + 2);
+	handle = ext3_journal_start(old_dir, 2 * EXT3_DATA_TRANS_BLOCKS +
+			 		EXT3_INDEX_EXTRA_TRANS_BLOCKS + 2);
 	if (IS_ERR(handle)) {
 		unlock_kernel();
 		return PTR_ERR(handle);
@@ -1157,7 +1907,7 @@
 		new_inode->i_ctime = CURRENT_TIME;
 	}
 	old_dir->i_ctime = old_dir->i_mtime = CURRENT_TIME;
-	EXT3_I(old_dir)->i_flags &= ~EXT3_INDEX_FL;
+	ext3_update_dx_flag(old_dir);
 	if (dir_bh) {
 		BUFFER_TRACE(dir_bh, "get_write_access");
 		ext3_journal_get_write_access(handle, dir_bh);
@@ -1169,7 +1919,7 @@
 			new_inode->i_nlink--;
 		} else {
 			new_dir->i_nlink++;
-			EXT3_I(new_dir)->i_flags &= ~EXT3_INDEX_FL;
+			ext3_update_dx_flag(new_dir);
 			ext3_mark_inode_dirty(handle, new_dir);
 		}
 	}
diff -Nru a/fs/ext3/super.c b/fs/ext3/super.c
--- a/fs/ext3/super.c	Wed Aug 28 07:37:38 2002
+++ b/fs/ext3/super.c	Wed Aug 28 07:37:38 2002
@@ -443,12 +443,16 @@
 	return;
 }
 
-static kmem_cache_t * ext3_inode_cachep;
+static kmem_cache_t *ext3_inode_cachep;
 
+/*
+ * Called inside transaction, so use GFP_NOFS
+ */
 static struct inode *ext3_alloc_inode(struct super_block *sb)
 {
 	struct ext3_inode_info *ei;
-	ei = (struct ext3_inode_info *)kmem_cache_alloc(ext3_inode_cachep, SLAB_KERNEL);
+
+	ei = kmem_cache_alloc(ext3_inode_cachep, SLAB_NOFS);
 	if (!ei)
 		return NULL;
 	return &ei->vfs_inode;
@@ -579,6 +583,12 @@
 				       "EXT3 Check option not supported\n");
 #endif
 		}
+		else if (!strcmp (this_char, "index"))
+#ifdef CONFIG_EXT3_INDEX
+			set_opt (*mount_options, INDEX);
+#else
+			printk("EXT3 index option not supported\n");
+#endif
 		else if (!strcmp (this_char, "debug"))
 			set_opt (*mount_options, DEBUG);
 		else if (!strcmp (this_char, "errors")) {
@@ -757,6 +767,12 @@
 	es->s_mtime = cpu_to_le32(CURRENT_TIME);
 	ext3_update_dynamic_rev(sb);
 	EXT3_SET_INCOMPAT_FEATURE(sb, EXT3_FEATURE_INCOMPAT_RECOVER);
+
+	if (test_opt(sb, INDEX))
+		EXT3_SET_COMPAT_FEATURE(sb, EXT3_FEATURE_COMPAT_DIR_INDEX);
+	else if (EXT3_HAS_COMPAT_FEATURE(sb, EXT3_FEATURE_COMPAT_DIR_INDEX))
+		set_opt (EXT3_SB(sb)->s_mount_opt, INDEX);
+
 	ext3_commit_super (sb, es, 1);
 	if (test_opt (sb, DEBUG))
 		printk (KERN_INFO
@@ -767,6 +783,7 @@
 			EXT3_BLOCKS_PER_GROUP(sb),
 			EXT3_INODES_PER_GROUP(sb),
 			sbi->s_mount_opt);
+
 	printk(KERN_INFO "EXT3 FS " EXT3FS_VERSION ", " EXT3FS_DATE " on %s, ",
 				sb->s_id);
 	if (EXT3_SB(sb)->s_journal->j_inode == NULL) {
@@ -940,6 +957,7 @@
 		res = (512LL << 32) - (1 << bits);
 	return res;
 }
+
 
 static int ext3_fill_super (struct super_block *sb, void *data, int silent)
 {
diff -Nru a/fs/fat/inode.c b/fs/fat/inode.c
--- a/fs/fat/inode.c	Wed Aug 28 07:37:37 2002
+++ b/fs/fat/inode.c	Wed Aug 28 07:37:37 2002
@@ -982,11 +982,24 @@
 {
 	return block_read_full_page(page,fat_get_block);
 }
-static int fat_prepare_write(struct file *file, struct page *page, unsigned from, unsigned to)
+
+static int
+fat_prepare_write(struct file *file, struct page *page,
+			unsigned from, unsigned to)
 {
+	kmap(page);
 	return cont_prepare_write(page,from,to,fat_get_block,
 		&MSDOS_I(page->mapping->host)->mmu_private);
 }
+
+static int
+fat_commit_write(struct file *file, struct page *page,
+			unsigned from, unsigned to)
+{
+	kunmap(page);
+	return generic_commit_write(file, page, from, to);
+}
+
 static int _fat_bmap(struct address_space *mapping, long block)
 {
 	return generic_block_bmap(mapping,block,fat_get_block);
@@ -996,7 +1009,7 @@
 	writepage: fat_writepage,
 	sync_page: block_sync_page,
 	prepare_write: fat_prepare_write,
-	commit_write: generic_commit_write,
+	commit_write: fat_commit_write,
 	bmap: _fat_bmap
 };
 
diff -Nru a/fs/fs-writeback.c b/fs/fs-writeback.c
--- a/fs/fs-writeback.c	Wed Aug 28 07:37:37 2002
+++ b/fs/fs-writeback.c	Wed Aug 28 07:37:37 2002
@@ -134,8 +134,6 @@
 	struct address_space *mapping = inode->i_mapping;
 	struct super_block *sb = inode->i_sb;
 
-	list_move(&inode->i_list, &sb->s_locked_inodes);
-
 	BUG_ON(inode->i_state & I_LOCK);
 
 	/* Set I_LOCK, reset I_DIRTY */
@@ -163,12 +161,12 @@
 		if (inode->i_state & I_DIRTY) {		/* Redirtied */
 			list_add(&inode->i_list, &sb->s_dirty);
 		} else {
-			if (!list_empty(&mapping->dirty_pages)) {
+			if (!list_empty(&mapping->dirty_pages) ||
+					!list_empty(&mapping->io_pages)) {
 			 	/* Not a whole-file writeback */
 				mapping->dirtied_when = orig_dirtied_when;
 				inode->i_state |= I_DIRTY_PAGES;
-				list_add_tail(&inode->i_list,
-						&sb->s_dirty);
+				list_add_tail(&inode->i_list, &sb->s_dirty);
 			} else if (atomic_read(&inode->i_count)) {
 				list_add(&inode->i_list, &inode_in_use);
 			} else {
@@ -205,7 +203,7 @@
  * If older_than_this is non-NULL, then only write out mappings which
  * had their first dirtying at a time earlier than *older_than_this.
  *
- * If we're a pdlfush thread, then implement pdlfush collision avoidance
+ * If we're a pdlfush thread, then implement pdflush collision avoidance
  * against the entire list.
  *
  * WB_SYNC_HOLD is a hack for sys_sync(): reattach the inode to sb->s_dirty so
@@ -221,6 +219,11 @@
  * FIXME: this linear search could get expensive with many fileystems.  But
  * how to fix?  We need to go from an address_space to all inodes which share
  * a queue with that address_space.
+ *
+ * The inodes to be written are parked on sb->s_io.  They are moved back onto
+ * sb->s_dirty as they are selected for writing.  This way, none can be missed
+ * on the writer throttling path, and we get decent balancing between many
+ * thrlttled threads: we don't want them all piling up on __wait_on_inode.
  */
 static void
 sync_sb_inodes(struct backing_dev_info *single_bdi, struct super_block *sb,
@@ -241,7 +244,7 @@
 		if (single_bdi && mapping->backing_dev_info != single_bdi) {
 			if (sb != blockdev_superblock)
 				break;		/* inappropriate superblock */
-			list_move(&inode->i_list, &inode->i_sb->s_dirty);
+			list_move(&inode->i_list, &sb->s_dirty);
 			continue;		/* not this blockdev */
 		}
 
@@ -263,10 +266,11 @@
 
 		BUG_ON(inode->i_state & I_FREEING);
 		__iget(inode);
+		list_move(&inode->i_list, &sb->s_dirty);
 		__writeback_single_inode(inode, really_sync, nr_to_write);
 		if (sync_mode == WB_SYNC_HOLD) {
 			mapping->dirtied_when = jiffies;
-			list_move(&inode->i_list, &inode->i_sb->s_dirty);
+			list_move(&inode->i_list, &sb->s_dirty);
 		}
 		if (current_is_pdflush())
 			writeback_release(bdi);
@@ -278,9 +282,8 @@
 	}
 out:
 	/*
-	 * Put the rest back, in the correct order.
+	 * Leave any unwritten inodes on s_io.
 	 */
-	list_splice_init(&sb->s_io, sb->s_dirty.prev);
 	return;
 }
 
@@ -302,7 +305,7 @@
 	spin_lock(&sb_lock);
 	sb = sb_entry(super_blocks.prev);
 	for (; sb != sb_entry(&super_blocks); sb = sb_entry(sb->s_list.prev)) {
-		if (!list_empty(&sb->s_dirty)) {
+		if (!list_empty(&sb->s_dirty) || !list_empty(&sb->s_io)) {
 			spin_unlock(&sb_lock);
 			sync_sb_inodes(bdi, sb, sync_mode, nr_to_write,
 					older_than_this);
@@ -321,7 +324,7 @@
  * Note:
  * We don't need to grab a reference to superblock here. If it has non-empty
  * ->s_dirty it's hadn't been killed yet and kill_super() won't proceed
- * past sync_inodes_sb() until both ->s_dirty and ->s_locked_inodes are
+ * past sync_inodes_sb() until both the ->s_dirty and ->s_io lists are
  * empty. Since __sync_single_inode() regains inode_lock before it finally moves
  * inode from superblock lists we are OK.
  *
@@ -352,19 +355,6 @@
 				sync_mode, older_than_this);
 }
 
-static void __wait_on_locked(struct list_head *head)
-{
-	struct list_head * tmp;
-	while ((tmp = head->prev) != head) {
-		struct inode *inode = list_entry(tmp, struct inode, i_list);
-		__iget(inode);
-		spin_unlock(&inode_lock);
-		__wait_on_inode(inode);
-		iput(inode);
-		spin_lock(&inode_lock);
-	}
-}
-
 /*
  * writeback and wait upon the filesystem's dirty inodes.  The caller will
  * do this in two passes - one to write, and one to wait.  WB_SYNC_HOLD is
@@ -384,8 +374,6 @@
 	spin_lock(&inode_lock);
 	sync_sb_inodes(NULL, sb, wait ? WB_SYNC_ALL : WB_SYNC_HOLD,
 				&nr_to_write, NULL);
-	if (wait)
-		__wait_on_locked(&sb->s_locked_inodes);
 	spin_unlock(&inode_lock);
 }
 
diff -Nru a/fs/inode.c b/fs/inode.c
--- a/fs/inode.c	Wed Aug 28 07:37:38 2002
+++ b/fs/inode.c	Wed Aug 28 07:37:38 2002
@@ -193,6 +193,8 @@
  */
 void __iget(struct inode * inode)
 {
+	assert_locked(&inode_lock);
+
 	if (atomic_read(&inode->i_count)) {
 		atomic_inc(&inode->i_count);
 		return;
@@ -321,7 +323,6 @@
 	busy |= invalidate_list(&inode_unused, sb, &throw_away);
 	busy |= invalidate_list(&sb->s_dirty, sb, &throw_away);
 	busy |= invalidate_list(&sb->s_io, sb, &throw_away);
-	busy |= invalidate_list(&sb->s_locked_inodes, sb, &throw_away);
 	spin_unlock(&inode_lock);
 
 	dispose_list(&throw_away);
@@ -995,11 +996,6 @@
 			remove_inode_dquot_ref(inode, type, &tofree_head);
 	}
 	list_for_each(act_head, &sb->s_io) {
-		inode = list_entry(act_head, struct inode, i_list);
-		if (IS_QUOTAINIT(inode))
-			remove_inode_dquot_ref(inode, type, &tofree_head);
-	}
-	list_for_each(act_head, &sb->s_locked_inodes) {
 		inode = list_entry(act_head, struct inode, i_list);
 		if (IS_QUOTAINIT(inode))
 			remove_inode_dquot_ref(inode, type, &tofree_head);
diff -Nru a/fs/jffs/inode-v23.c b/fs/jffs/inode-v23.c
--- a/fs/jffs/inode-v23.c	Wed Aug 28 07:37:37 2002
+++ b/fs/jffs/inode-v23.c	Wed Aug 28 07:37:37 2002
@@ -47,6 +47,7 @@
 #include <linux/stat.h>
 #include <linux/blkdev.h>
 #include <linux/quotaops.h>
+#include <linux/highmem.h>
 #include <linux/smp_lock.h>
 #include <asm/semaphore.h>
 #include <asm/byteorder.h>
@@ -751,7 +752,6 @@
 
 	get_page(page);
 	/* Don't SetPageLocked(page), should be locked already */
-	buf = page_address(page);
 	ClearPageUptodate(page);
 	ClearPageError(page);
 
@@ -760,8 +760,10 @@
 
 	read_len = 0;
 	result = 0;
-
 	offset = page->index << PAGE_CACHE_SHIFT;
+
+	kmap(page);
+	buf = page_address(page);
 	if (offset < inode->i_size) {
 		read_len = min_t(long, inode->i_size - offset, PAGE_SIZE);
 		r = jffs_read_data(f, buf, offset, read_len);
@@ -779,6 +781,8 @@
 	/* This handles the case of partial or no read in above */
 	if(read_len < PAGE_SIZE)
 	        memset(buf + read_len, 0, PAGE_SIZE - read_len);
+	flush_dcache_page(page);
+	kunmap(page);
 
 	D3(printk (KERN_NOTICE "readpage(): up biglock\n"));
 	up(&c->fmc->biglock);
@@ -788,9 +792,8 @@
 	}else {
 	        SetPageUptodate(page);	        
 	}
-	flush_dcache_page(page);
 
-	put_page(page);
+	page_cache_release(page);
 
 	D3(printk("jffs_readpage(): Leaving...\n"));
 
diff -Nru a/fs/jffs2/file.c b/fs/jffs2/file.c
--- a/fs/jffs2/file.c	Wed Aug 28 07:37:38 2002
+++ b/fs/jffs2/file.c	Wed Aug 28 07:37:38 2002
@@ -17,6 +17,7 @@
 #include <linux/fs.h>
 #include <linux/time.h>
 #include <linux/pagemap.h>
+#include <linux/highmem.h>
 #include <linux/crc32.h>
 #include <linux/jffs2.h>
 #include "nodelist.h"
@@ -381,9 +382,10 @@
 	ri->isize = (uint32_t)inode->i_size;
 	ri->atime = ri->ctime = ri->mtime = CURRENT_TIME;
 
-	/* We rely on the fact that generic_file_write() currently kmaps the page for us. */
+	kmap(pg);
 	ret = jffs2_write_inode_range(c, f, ri, page_address(pg) + start,
 				      (pg->index << PAGE_CACHE_SHIFT) + start, end - start, &writtenlen);
+	kunmap(pg);
 
 	if (ret) {
 		/* There was an error writing. */
diff -Nru a/fs/jfs/jfs_dmap.c b/fs/jfs/jfs_dmap.c
--- a/fs/jfs/jfs_dmap.c	Wed Aug 28 07:37:37 2002
+++ b/fs/jfs/jfs_dmap.c	Wed Aug 28 07:37:37 2002
@@ -325,7 +325,6 @@
 	/*
 	 * write out dirty pages of bmap
 	 */
-	filemap_fdatawait(ipbmap->i_mapping);
 	filemap_fdatawrite(ipbmap->i_mapping);
 	filemap_fdatawait(ipbmap->i_mapping);
 
diff -Nru a/fs/jfs/jfs_imap.c b/fs/jfs/jfs_imap.c
--- a/fs/jfs/jfs_imap.c	Wed Aug 28 07:37:36 2002
+++ b/fs/jfs/jfs_imap.c	Wed Aug 28 07:37:36 2002
@@ -281,7 +281,6 @@
 	/*
 	 * write out dirty pages of imap
 	 */
-	filemap_fdatawait(ipimap->i_mapping);
 	filemap_fdatawrite(ipimap->i_mapping);
 	filemap_fdatawait(ipimap->i_mapping);
 
@@ -595,7 +594,6 @@
 		jERROR(1, ("diFreeSpecial called with NULL ip!\n"));
 		return;
 	}
-	filemap_fdatawait(ip->i_mapping);
 	filemap_fdatawrite(ip->i_mapping);
 	filemap_fdatawait(ip->i_mapping);
 	truncate_inode_pages(ip->i_mapping, 0);
diff -Nru a/fs/jfs/jfs_logmgr.c b/fs/jfs/jfs_logmgr.c
--- a/fs/jfs/jfs_logmgr.c	Wed Aug 28 07:37:37 2002
+++ b/fs/jfs/jfs_logmgr.c	Wed Aug 28 07:37:37 2002
@@ -965,9 +965,6 @@
 		 * We need to make sure all of the "written" metapages
 		 * actually make it to disk
 		 */
-		filemap_fdatawait(sbi->ipbmap->i_mapping);
-		filemap_fdatawait(sbi->ipimap->i_mapping);
-		filemap_fdatawait(sbi->direct_inode->i_mapping);
 		filemap_fdatawrite(sbi->ipbmap->i_mapping);
 		filemap_fdatawrite(sbi->ipimap->i_mapping);
 		filemap_fdatawrite(sbi->direct_inode->i_mapping);
diff -Nru a/fs/jfs/jfs_metapage.c b/fs/jfs/jfs_metapage.c
--- a/fs/jfs/jfs_metapage.c	Wed Aug 28 07:37:36 2002
+++ b/fs/jfs/jfs_metapage.c	Wed Aug 28 07:37:36 2002
@@ -459,7 +459,6 @@
 	if (rc) {
 		jERROR(1, ("prepare_write return %d!\n", rc));
 		ClearPageUptodate(mp->page);
-		kunmap(mp->page);
 		unlock_page(mp->page);
 		clear_bit(META_dirty, &mp->flag);
 		return;
diff -Nru a/fs/jfs/jfs_txnmgr.c b/fs/jfs/jfs_txnmgr.c
--- a/fs/jfs/jfs_txnmgr.c	Wed Aug 28 07:37:37 2002
+++ b/fs/jfs/jfs_txnmgr.c	Wed Aug 28 07:37:37 2002
@@ -1165,7 +1165,6 @@
 		 *
 		 * if ((!S_ISDIR(ip->i_mode))
 		 *    && (tblk->flag & COMMIT_DELETE) == 0) {
-		 *	filemap_fdatawait(ip->i_mapping);
 		 *	filemap_fdatawrite(ip->i_mapping);
 		 *	filemap_fdatawait(ip->i_mapping);
 		 * }
diff -Nru a/fs/jfs/jfs_umount.c b/fs/jfs/jfs_umount.c
--- a/fs/jfs/jfs_umount.c	Wed Aug 28 07:37:36 2002
+++ b/fs/jfs/jfs_umount.c	Wed Aug 28 07:37:36 2002
@@ -112,7 +112,6 @@
 	 * Make sure all metadata makes it to disk before we mark
 	 * the superblock as clean
 	 */
-	filemap_fdatawait(sbi->direct_inode->i_mapping);
 	filemap_fdatawrite(sbi->direct_inode->i_mapping);
 	filemap_fdatawait(sbi->direct_inode->i_mapping);
 
@@ -159,7 +158,6 @@
 	 */
 	dbSync(sbi->ipbmap);
 	diSync(sbi->ipimap);
-	filemap_fdatawait(sbi->direct_inode->i_mapping);
 	filemap_fdatawrite(sbi->direct_inode->i_mapping);
 	filemap_fdatawait(sbi->direct_inode->i_mapping);
 
diff -Nru a/fs/jfs/super.c b/fs/jfs/super.c
--- a/fs/jfs/super.c	Wed Aug 28 07:37:37 2002
+++ b/fs/jfs/super.c	Wed Aug 28 07:37:37 2002
@@ -146,7 +146,6 @@
 	 * We need to clean out the direct_inode pages since this inode
 	 * is not in the inode hash.
 	 */
-	filemap_fdatawait(sbi->direct_inode->i_mapping);
 	filemap_fdatawrite(sbi->direct_inode->i_mapping);
 	filemap_fdatawait(sbi->direct_inode->i_mapping);
 	truncate_inode_pages(sbi->direct_mapping, 0);
@@ -362,7 +361,6 @@
 		jERROR(1, ("jfs_umount failed with return code %d\n", rc));
 	}
 out_mount_failed:
-	filemap_fdatawait(sbi->direct_inode->i_mapping);
 	filemap_fdatawrite(sbi->direct_inode->i_mapping);
 	filemap_fdatawait(sbi->direct_inode->i_mapping);
 	truncate_inode_pages(sbi->direct_mapping, 0);
diff -Nru a/fs/minix/dir.c b/fs/minix/dir.c
--- a/fs/minix/dir.c	Wed Aug 28 07:37:36 2002
+++ b/fs/minix/dir.c	Wed Aug 28 07:37:36 2002
@@ -7,6 +7,7 @@
  */
 
 #include "minix.h"
+#include <linux/highmem.h>
 #include <linux/smp_lock.h>
 
 typedef struct minix_dir_entry minix_dirent;
@@ -261,7 +262,7 @@
 {
 	struct address_space *mapping = page->mapping;
 	struct inode *inode = (struct inode*)mapping->host;
-	char *kaddr = (char*)page_address(page);
+	char *kaddr = page_address(page);
 	unsigned from = (char*)de - kaddr;
 	unsigned to = from + minix_sb(inode->i_sb)->s_dirsize;
 	int err;
@@ -286,7 +287,7 @@
 	struct page *page = grab_cache_page(mapping, 0);
 	struct minix_sb_info * sbi = minix_sb(inode->i_sb);
 	struct minix_dir_entry * de;
-	char *base;
+	char *kaddr;
 	int err;
 
 	if (!page)
@@ -297,15 +298,16 @@
 		goto fail;
 	}
 
-	base = (char*)page_address(page);
-	memset(base, 0, PAGE_CACHE_SIZE);
+	kaddr = kmap_atomic(page, KM_USER0);
+	memset(kaddr, 0, PAGE_CACHE_SIZE);
 
-	de = (struct minix_dir_entry *) base;
+	de = (struct minix_dir_entry *)kaddr;
 	de->inode = inode->i_ino;
 	strcpy(de->name,".");
 	de = minix_next_entry(de, sbi);
 	de->inode = dir->i_ino;
 	strcpy(de->name,"..");
+	kunmap_atomic(kaddr, KM_USER0);
 
 	err = dir_commit_chunk(page, 0, 2 * sbi->s_dirsize);
 fail:
diff -Nru a/fs/mpage.c b/fs/mpage.c
--- a/fs/mpage.c	Wed Aug 28 07:37:36 2002
+++ b/fs/mpage.c	Wed Aug 28 07:37:36 2002
@@ -19,6 +19,7 @@
 #include <linux/highmem.h>
 #include <linux/prefetch.h>
 #include <linux/mpage.h>
+#include <linux/writeback.h>
 #include <linux/pagevec.h>
 
 /*
@@ -459,6 +460,9 @@
 			clear_buffer_dirty(bh);
 			bh = bh->b_this_page;
 		} while (bh != head);
+
+		if (buffer_heads_over_limit)
+			try_to_free_buffers(page);
 	}
 
 	bvec = &bio->bi_io_vec[bio->bi_idx++];
@@ -530,6 +534,7 @@
 	sector_t last_block_in_bio = 0;
 	int ret = 0;
 	int done = 0;
+	int sync = called_for_sync();
 	struct pagevec pvec;
 	int (*writepage)(struct page *);
 
@@ -546,7 +551,7 @@
 		struct page *page = list_entry(mapping->io_pages.prev,
 					struct page, list);
 		list_del(&page->list);
-		if (PageWriteback(page)) {
+		if (PageWriteback(page) && !sync) {
 			if (PageDirty(page)) {
 				list_add(&page->list, &mapping->dirty_pages);
 				continue;
@@ -565,8 +570,11 @@
 
 		lock_page(page);
 
+		if (sync)
+			wait_on_page_writeback(page);
+
 		if (page->mapping && !PageWriteback(page) &&
-					TestClearPageDirty(page)) {
+					test_clear_page_dirty(page)) {
 			if (writepage) {
 				ret = (*writepage)(page);
 			} else {
@@ -579,6 +587,10 @@
 					pagevec_deactivate_inactive(&pvec);
 				page = NULL;
 			}
+			if (ret == -EAGAIN && page) {
+				__set_page_dirty_nobuffers(page);
+				ret = 0;
+			}
 			if (ret || (nr_to_write && --(*nr_to_write) <= 0))
 				done = 1;
 		} else {
@@ -590,9 +602,8 @@
 		write_lock(&mapping->page_lock);
 	}
 	/*
-	 * Put the rest back, in the correct order.
+	 * Leave any remaining dirty pages on ->io_pages
 	 */
-	list_splice_init(&mapping->io_pages, mapping->dirty_pages.prev);
 	write_unlock(&mapping->page_lock);
 	pagevec_deactivate_inactive(&pvec);
 	if (bio)
diff -Nru a/fs/namei.c b/fs/namei.c
--- a/fs/namei.c	Wed Aug 28 07:37:37 2002
+++ b/fs/namei.c	Wed Aug 28 07:37:37 2002
@@ -2200,8 +2200,9 @@
 	err = mapping->a_ops->prepare_write(NULL, page, 0, len-1);
 	if (err)
 		goto fail_map;
-	kaddr = page_address(page);
+	kaddr = kmap_atomic(page, KM_USER0);
 	memcpy(kaddr, symname, len-1);
+	kunmap_atomic(kaddr, KM_USER0);
 	mapping->a_ops->commit_write(NULL, page, 0, len-1);
 	/*
 	 * Notice that we are _not_ going to block here - end of page is
diff -Nru a/fs/nfs/file.c b/fs/nfs/file.c
--- a/fs/nfs/file.c	Wed Aug 28 07:37:37 2002
+++ b/fs/nfs/file.c	Wed Aug 28 07:37:37 2002
@@ -279,10 +279,7 @@
 	 * Flush all pending writes before doing anything
 	 * with locks..
 	 */
-	status = filemap_fdatawait(inode->i_mapping);
-	status2 = filemap_fdatawrite(inode->i_mapping);
-	if (!status)
-		status = status2;
+	status = filemap_fdatawrite(inode->i_mapping);
 	down(&inode->i_sem);
 	status2 = nfs_wb_all(inode);
 	if (!status)
@@ -308,7 +305,6 @@
 	 */
  out_ok:
 	if ((IS_SETLK(cmd) || IS_SETLKW(cmd)) && fl->fl_type != F_UNLCK) {
-		filemap_fdatawait(inode->i_mapping);
 		filemap_fdatawrite(inode->i_mapping);
 		down(&inode->i_sem);
 		nfs_wb_all(inode);      /* we may have slept */
diff -Nru a/fs/nfs/inode.c b/fs/nfs/inode.c
--- a/fs/nfs/inode.c	Wed Aug 28 07:37:37 2002
+++ b/fs/nfs/inode.c	Wed Aug 28 07:37:37 2002
@@ -775,7 +775,6 @@
 	if (!S_ISREG(inode->i_mode))
 		attr->ia_valid &= ~ATTR_SIZE;
 
-	filemap_fdatawait(inode->i_mapping);
 	filemap_fdatawrite(inode->i_mapping);
 	error = nfs_wb_all(inode);
 	filemap_fdatawait(inode->i_mapping);
diff -Nru a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
--- a/fs/nfsd/vfs.c	Wed Aug 28 07:37:37 2002
+++ b/fs/nfsd/vfs.c	Wed Aug 28 07:37:37 2002
@@ -501,7 +501,6 @@
 	struct inode *inode = dp->d_inode;
 	int (*fsync) (struct file *, struct dentry *, int);
 
-	filemap_fdatawait(inode->i_mapping);
 	filemap_fdatawrite(inode->i_mapping);
 	if (fop && (fsync = fop->fsync))
 		fsync(filp, dp, 0);
diff -Nru a/fs/proc/proc_misc.c b/fs/proc/proc_misc.c
--- a/fs/proc/proc_misc.c	Wed Aug 28 07:37:36 2002
+++ b/fs/proc/proc_misc.c	Wed Aug 28 07:37:36 2002
@@ -27,6 +27,7 @@
 #include <linux/ioport.h>
 #include <linux/config.h>
 #include <linux/mm.h>
+#include <linux/mmzone.h>
 #include <linux/pagemap.h>
 #include <linux/swap.h>
 #include <linux/slab.h>
@@ -41,7 +42,8 @@
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
 #include <asm/io.h>
-
+#include <asm/pgalloc.h>
+#include <asm/tlb.h>
 
 #define LOAD_INT(x) ((x) >> FSHIFT)
 #define LOAD_FRAC(x) LOAD_INT(((x) & (FIXED_1-1)) * 100)
@@ -134,8 +136,20 @@
 	struct sysinfo i;
 	int len, committed;
 	struct page_state ps;
+	int cpu;
+	unsigned long inactive;
+	unsigned long active;
+	unsigned long flushes = 0;
+	unsigned long non_flushes = 0;
+
+	for (cpu = 0; cpu < NR_CPUS; cpu++) {
+		flushes += mmu_gathers[cpu].flushes;
+		non_flushes += mmu_gathers[cpu].avoided_flushes;
+	}
 
 	get_page_state(&ps);
+	get_zone_counts(&active, &inactive);
+
 /*
  * display in kilobytes.
  */
@@ -165,14 +179,16 @@
 		"Writeback:    %8lu kB\n"
 		"Committed_AS: %8u kB\n"
 		"PageTables:   %8lu kB\n"
-		"ReverseMaps:  %8lu\n",
+		"ReverseMaps:  %8lu\n"
+		"TLB flushes:  %8lu\n"
+		"non flushes:  %8lu\n",
 		K(i.totalram),
 		K(i.freeram),
 		K(i.sharedram),
 		K(ps.nr_pagecache-swapper_space.nrpages),
 		K(swapper_space.nrpages),
-		K(ps.nr_active),
-		K(ps.nr_inactive),
+		K(active),
+		K(inactive),
 		K(i.totalhigh),
 		K(i.freehigh),
 		K(i.totalram-i.totalhigh),
@@ -183,7 +199,9 @@
 		K(ps.nr_writeback),
 		K(committed),
 		K(ps.nr_page_table_pages),
-		ps.nr_reverse_maps
+		ps.nr_reverse_maps,
+		flushes,
+		non_flushes
 		);
 
 	return proc_calc_metrics(page, start, off, count, eof, len);
diff -Nru a/fs/ramfs/inode.c b/fs/ramfs/inode.c
--- a/fs/ramfs/inode.c	Wed Aug 28 07:37:37 2002
+++ b/fs/ramfs/inode.c	Wed Aug 28 07:37:37 2002
@@ -26,9 +26,11 @@
 #include <linux/module.h>
 #include <linux/fs.h>
 #include <linux/pagemap.h>
+#include <linux/highmem.h>
 #include <linux/init.h>
 #include <linux/string.h>
 #include <linux/smp_lock.h>
+#include <linux/backing-dev.h>
 
 #include <asm/uaccess.h>
 
@@ -40,6 +42,11 @@
 static struct file_operations ramfs_file_operations;
 static struct inode_operations ramfs_dir_inode_operations;
 
+static struct backing_dev_info ramfs_backing_dev_info = {
+	.ra_pages	= 0,	/* No readahead */
+	.memory_backed	= 1,	/* Does not contribute to dirty memory */
+};
+
 /*
  * Read a page. Again trivial. If it didn't already exist
  * in the page cache, it is zero-filled.
@@ -47,8 +54,10 @@
 static int ramfs_readpage(struct file *file, struct page * page)
 {
 	if (!PageUptodate(page)) {
-		memset(kmap(page), 0, PAGE_CACHE_SIZE);
-		kunmap(page);
+		char *kaddr = kmap_atomic(page, KM_USER0);
+
+		memset(kaddr, 0, PAGE_CACHE_SIZE);
+		kunmap_atomic(kaddr, KM_USER0);
 		flush_dcache_page(page);
 		SetPageUptodate(page);
 	}
@@ -58,13 +67,15 @@
 
 static int ramfs_prepare_write(struct file *file, struct page *page, unsigned offset, unsigned to)
 {
-	void *addr = kmap(page);
 	if (!PageUptodate(page)) {
-		memset(addr, 0, PAGE_CACHE_SIZE);
+		char *kaddr = kmap_atomic(page, KM_USER0);
+
+		memset(kaddr, 0, PAGE_CACHE_SIZE);
 		flush_dcache_page(page);
+		kunmap_atomic(kaddr, KM_USER0);
 		SetPageUptodate(page);
 	}
-	SetPageDirty(page);
+	set_page_dirty(page);
 	return 0;
 }
 
@@ -73,7 +84,6 @@
 	struct inode *inode = page->mapping->host;
 	loff_t pos = ((loff_t)page->index << PAGE_CACHE_SHIFT) + to;
 
-	kunmap(page);
 	if (pos > inode->i_size)
 		inode->i_size = pos;
 	return 0;
@@ -91,6 +101,7 @@
 		inode->i_blocks = 0;
 		inode->i_rdev = NODEV;
 		inode->i_mapping->a_ops = &ramfs_aops;
+		inode->i_mapping->backing_dev_info = &ramfs_backing_dev_info;
 		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
 		switch (mode & S_IFMT) {
 		default:
diff -Nru a/fs/reiserfs/inode.c b/fs/reiserfs/inode.c
--- a/fs/reiserfs/inode.c	Wed Aug 28 07:37:37 2002
+++ b/fs/reiserfs/inode.c	Wed Aug 28 07:37:37 2002
@@ -7,6 +7,7 @@
 #include <linux/reiserfs_fs.h>
 #include <linux/smp_lock.h>
 #include <linux/pagemap.h>
+#include <linux/highmem.h>
 #include <asm/uaccess.h>
 #include <asm/unaligned.h>
 #include <linux/buffer_head.h>
@@ -1692,8 +1693,6 @@
     if (error)
 	goto unlock ;
 
-    kunmap(page) ; /* mapped by block_prepare_write */
-
     head = page_buffers(page) ;      
     bh = head;
     do {
@@ -1788,10 +1787,13 @@
         length = offset & (blocksize - 1) ;
 	/* if we are not on a block boundary */
 	if (length) {
+	    char *kaddr;
+
 	    length = blocksize - length ;
-	    memset((char *)kmap(page) + offset, 0, length) ;   
+	    kaddr = kmap_atomic(page, KM_USER0) ;
+	    memset(kaddr + offset, 0, length) ;   
 	    flush_dcache_page(page) ;
-	    kunmap(page) ;
+	    kunmap_atomic(kaddr, KM_USER0) ;
 	    if (buffer_mapped(bh) && bh->b_blocknr != 0) {
 	        mark_buffer_dirty(bh) ;
 	    }
@@ -1941,23 +1943,25 @@
     struct buffer_head *arr[PAGE_CACHE_SIZE/512] ;
     int nr = 0 ;
 
-    if (!page_has_buffers(page)) {
+    if (!page_has_buffers(page))
         block_prepare_write(page, 0, 0, NULL) ;
-	kunmap(page) ;
-    }
+
     /* last page in the file, zero out any contents past the
     ** last byte in the file
     */
     if (page->index >= end_index) {
+	char *kaddr;
+
         last_offset = inode->i_size & (PAGE_CACHE_SIZE - 1) ;
 	/* no file contents in this page */
 	if (page->index >= end_index + 1 || !last_offset) {
 	    error =  -EIO ;
 	    goto fail ;
 	}
-	memset((char *)kmap(page)+last_offset, 0, PAGE_CACHE_SIZE-last_offset) ;
+	kaddr = kmap_atomic(page, KM_USER0);
+	memset(kaddr + last_offset, 0, PAGE_CACHE_SIZE-last_offset) ;
 	flush_dcache_page(page) ;
-	kunmap(page) ;
+	kunmap_atomic(kaddr, KM_USER0) ;
     }
     head = page_buffers(page) ;
     bh = head ;
diff -Nru a/fs/reiserfs/stree.c b/fs/reiserfs/stree.c
--- a/fs/reiserfs/stree.c	Wed Aug 28 07:37:37 2002
+++ b/fs/reiserfs/stree.c	Wed Aug 28 07:37:37 2002
@@ -1284,15 +1284,15 @@
         **
         ** p_s_un_bh is from the page cache (all unformatted nodes are
         ** from the page cache) and might be a highmem page.  So, we
-        ** can't use p_s_un_bh->b_data.  But, the page has already been
-        ** kmapped, so we can use page_address()
+        ** can't use p_s_un_bh->b_data.
 	** -clm
 	*/
 
-        data = page_address(p_s_un_bh->b_page) ;
+        data = kmap_atomic(p_s_un_bh->b_page, KM_USER0);
 	off = ((le_ih_k_offset (&s_ih) - 1) & (PAGE_CACHE_SIZE - 1));
 	memcpy(data + off,
 	       B_I_PITEM(PATH_PLAST_BUFFER(p_s_path), &s_ih), n_ret_value);
+	kunmap_atomic(p_s_un_bh->b_page, KM_USER0);
     }
 
     /* Perform balancing after all resources have been collected at once. */ 
diff -Nru a/fs/reiserfs/tail_conversion.c b/fs/reiserfs/tail_conversion.c
--- a/fs/reiserfs/tail_conversion.c	Wed Aug 28 07:37:38 2002
+++ b/fs/reiserfs/tail_conversion.c	Wed Aug 28 07:37:38 2002
@@ -122,11 +122,12 @@
     }
     /* if we've copied bytes from disk into the page, we need to zero
     ** out the unused part of the block (it was not up to date before)
-    ** the page is still kmapped (by whoever called reiserfs_get_block)
     */
     if (up_to_date_bh) {
         unsigned pgoff = (tail_offset + total_tail - 1) & (PAGE_CACHE_SIZE - 1);
-	memset(page_address(unbh->b_page) + pgoff, 0, n_blk_size - total_tail) ;
+	char *kaddr=kmap_atomic(up_to_date_bh->b_page, KM_USER0);
+	memset(kaddr + pgoff, 0, n_blk_size - total_tail) ;
+	kunmap_atomic(up_to_date_bh->b_page, KM_USER0);
     }
 
     REISERFS_I(inode)->i_first_direct_byte = U32_MAX;
diff -Nru a/fs/smbfs/file.c b/fs/smbfs/file.c
--- a/fs/smbfs/file.c	Wed Aug 28 07:37:38 2002
+++ b/fs/smbfs/file.c	Wed Aug 28 07:37:38 2002
@@ -352,7 +352,6 @@
 		/* We must flush any dirty pages now as we won't be able to
 		   write anything after close. mmap can trigger this.
 		   "openers" should perhaps include mmap'ers ... */
-		filemap_fdatawait(inode->i_mapping);
 		filemap_fdatawrite(inode->i_mapping);
 		filemap_fdatawait(inode->i_mapping);
 		smb_close(inode);
diff -Nru a/fs/smbfs/inode.c b/fs/smbfs/inode.c
--- a/fs/smbfs/inode.c	Wed Aug 28 07:37:36 2002
+++ b/fs/smbfs/inode.c	Wed Aug 28 07:37:36 2002
@@ -650,7 +650,6 @@
 			DENTRY_PATH(dentry),
 			(long) inode->i_size, (long) attr->ia_size);
 
-		filemap_fdatawait(inode->i_mapping);
 		filemap_fdatawrite(inode->i_mapping);
 		filemap_fdatawait(inode->i_mapping);
 
diff -Nru a/fs/super.c b/fs/super.c
--- a/fs/super.c	Wed Aug 28 07:37:37 2002
+++ b/fs/super.c	Wed Aug 28 07:37:37 2002
@@ -58,7 +58,6 @@
 		}
 		INIT_LIST_HEAD(&s->s_dirty);
 		INIT_LIST_HEAD(&s->s_io);
-		INIT_LIST_HEAD(&s->s_locked_inodes);
 		INIT_LIST_HEAD(&s->s_files);
 		INIT_LIST_HEAD(&s->s_instances);
 		INIT_LIST_HEAD(&s->s_anon);
diff -Nru a/fs/sysv/dir.c b/fs/sysv/dir.c
--- a/fs/sysv/dir.c	Wed Aug 28 07:37:37 2002
+++ b/fs/sysv/dir.c	Wed Aug 28 07:37:37 2002
@@ -14,6 +14,7 @@
  */
 
 #include <linux/pagemap.h>
+#include <linux/highmem.h>
 #include <linux/smp_lock.h>
 #include "sysv.h"
 
@@ -273,6 +274,7 @@
 
 	if (!page)
 		return -ENOMEM;
+	kmap(page);
 	err = mapping->a_ops->prepare_write(NULL, page, 0, 2 * SYSV_DIRSIZE);
 	if (err) {
 		unlock_page(page);
@@ -291,6 +293,7 @@
 
 	err = dir_commit_chunk(page, 0, 2 * SYSV_DIRSIZE);
 fail:
+	kunmap(page);
 	page_cache_release(page);
 	return err;
 }
diff -Nru a/fs/udf/inode.c b/fs/udf/inode.c
--- a/fs/udf/inode.c	Wed Aug 28 07:37:38 2002
+++ b/fs/udf/inode.c	Wed Aug 28 07:37:38 2002
@@ -208,7 +208,8 @@
 	mark_buffer_dirty_inode(bh, inode);
 	udf_release_data(bh);
 
-	inode->i_data.a_ops->writepage(page);
+	if (inode->i_data.a_ops->writepage(page) == -EAGAIN)
+		__set_page_dirty_nobuffers(page);
 	page_cache_release(page);
 
 	mark_inode_dirty(inode);
diff -Nru a/include/asm-alpha/cache.h b/include/asm-alpha/cache.h
--- a/include/asm-alpha/cache.h	Wed Aug 28 07:37:37 2002
+++ b/include/asm-alpha/cache.h	Wed Aug 28 07:37:37 2002
@@ -20,5 +20,6 @@
 
 #define L1_CACHE_ALIGN(x)  (((x)+(L1_CACHE_BYTES-1))&~(L1_CACHE_BYTES-1))
 #define SMP_CACHE_BYTES    L1_CACHE_BYTES
+#define L1_CACHE_SHIFT_MAX 6	/* largest L1 which this arch supports */
 
 #endif
diff -Nru a/include/asm-alpha/mmzone.h b/include/asm-alpha/mmzone.h
--- a/include/asm-alpha/mmzone.h	Wed Aug 28 07:37:37 2002
+++ b/include/asm-alpha/mmzone.h	Wed Aug 28 07:37:37 2002
@@ -52,14 +52,14 @@
 
 #if 1
 #define PLAT_NODE_DATA_LOCALNR(p, n)	\
-	(((p) - PLAT_NODE_DATA(n)->gendata.node_start_paddr) >> PAGE_SHIFT)
+	(((p) >> PAGE_SHIFT) - PLAT_NODE_DATA(n)->gendata.node_start_pfn)
 #else
 static inline unsigned long
 PLAT_NODE_DATA_LOCALNR(unsigned long p, int n)
 {
 	unsigned long temp;
-	temp = p - PLAT_NODE_DATA(n)->gendata.node_start_paddr;
-	return (temp >> PAGE_SHIFT);
+	temp = p >> PAGE_SHIFT;
+	return temp - PLAT_NODE_DATA(n)->gendata.node_start_pfn;
 }
 #endif
 
@@ -96,7 +96,7 @@
  * and returns the kaddr corresponding to first physical page in the
  * node's mem_map.
  */
-#define LOCAL_BASE_ADDR(kaddr)	((unsigned long)__va(NODE_DATA(KVADDR_TO_NID(kaddr))->node_start_paddr))
+#define LOCAL_BASE_ADDR(kaddr)	((unsigned long)__va(NODE_DATA(KVADDR_TO_NID(kaddr))->node_start_pfn << PAGE_SHIFT))
 
 #define LOCAL_MAP_NR(kvaddr) \
 	(((unsigned long)(kvaddr)-LOCAL_BASE_ADDR(kvaddr)) >> PAGE_SHIFT)
diff -Nru a/include/asm-alpha/pgtable.h b/include/asm-alpha/pgtable.h
--- a/include/asm-alpha/pgtable.h	Wed Aug 28 07:37:37 2002
+++ b/include/asm-alpha/pgtable.h	Wed Aug 28 07:37:37 2002
@@ -195,8 +195,8 @@
 #define PAGE_TO_PA(page)	((page - mem_map) << PAGE_SHIFT)
 #else
 #define PAGE_TO_PA(page) \
-		((((page)-(page)->zone->zone_mem_map) << PAGE_SHIFT) \
-		+ (page)->zone->zone_start_paddr)
+		((( (page) - (page)->zone->zone_mem_map ) \
+		+ (page)->zone->zone_start_pfn) << PAGE_SHIFT)
 #endif
 
 #ifndef CONFIG_DISCONTIGMEM
@@ -216,7 +216,7 @@
 	unsigned long pfn;							\
 										\
 	pfn = ((unsigned long)((page)-(page)->zone->zone_mem_map)) << 32;	\
-	pfn += (page)->zone->zone_start_paddr << (32-PAGE_SHIFT);		\
+	pfn += (page)->zone->zone_start_pfn << 32);				\
 	pte_val(pte) = pfn | pgprot_val(pgprot);				\
 										\
 	pte;									\
diff -Nru a/include/asm-alpha/tlb.h b/include/asm-alpha/tlb.h
--- a/include/asm-alpha/tlb.h	Wed Aug 28 07:37:37 2002
+++ b/include/asm-alpha/tlb.h	Wed Aug 28 07:37:37 2002
@@ -3,13 +3,13 @@
 
 #define tlb_start_vma(tlb, vma)			do { } while (0)
 #define tlb_end_vma(tlb, vma)			do { } while (0)
-#define tlb_remove_tlb_entry(tlb, pte, addr)	do { } while (0)
+#define __tlb_remove_tlb_entry(tlb, pte, addr)	do { } while (0)
 
 #define tlb_flush(tlb)				flush_tlb_mm((tlb)->mm)
 
 #include <asm-generic/tlb.h>
 
-#define pte_free_tlb(tlb,pte)			pte_free(pte)
-#define pmd_free_tlb(tlb,pmd)			pmd_free(pmd)
+#define __pte_free_tlb(tlb,pte)			pte_free(pte)
+#define __pmd_free_tlb(tlb,pmd)			pmd_free(pmd)
  
 #endif
diff -Nru a/include/asm-arm/cache.h b/include/asm-arm/cache.h
--- a/include/asm-arm/cache.h	Wed Aug 28 07:37:38 2002
+++ b/include/asm-arm/cache.h	Wed Aug 28 07:37:38 2002
@@ -16,4 +16,6 @@
 		 __section__(".data.cacheline_aligned")))
 #endif
 
+#define L1_CACHE_SHIFT_MAX 5	/* largest L1 which this arch supports */
+
 #endif
diff -Nru a/include/asm-arm/memory.h b/include/asm-arm/memory.h
--- a/include/asm-arm/memory.h	Wed Aug 28 07:37:38 2002
+++ b/include/asm-arm/memory.h	Wed Aug 28 07:37:38 2002
@@ -80,8 +80,8 @@
  * around in memory.
  */
 #define page_to_pfn(page)					\
-	(((page) - page_zone(page)->zone_mem_map)		\
-	  + (page_zone(page)->zone_start_paddr >> PAGE_SHIFT))
+	(( (page) - page_zone(page)->zone_mem_map)		\
+	  + page_zone(page)->zone_start_pfn)
 
 #define pfn_to_page(pfn)					\
 	(PFN_TO_MAPBASE(pfn) + LOCAL_MAP_NR((pfn) << PAGE_SHIFT))
diff -Nru a/include/asm-arm/tlb.h b/include/asm-arm/tlb.h
--- a/include/asm-arm/tlb.h	Wed Aug 28 07:37:36 2002
+++ b/include/asm-arm/tlb.h	Wed Aug 28 07:37:36 2002
@@ -11,11 +11,11 @@
 #define tlb_end_vma(tlb,vma)	\
 	flush_tlb_range(vma, vma->vm_start, vma->vm_end)
 
-#define tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
+#define __tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
 
 #include <asm-generic/tlb.h>
 
-#define pmd_free_tlb(tlb, pmd)	pmd_free(pmd)
-#define pte_free_tlb(tlb, pte)	pte_free(pte)
+#define __pmd_free_tlb(tlb, pmd)	pmd_free(pmd)
+#define __pte_free_tlb(tlb, pte)	pte_free(pte)
 
 #endif
diff -Nru a/include/asm-cris/cache.h b/include/asm-cris/cache.h
--- a/include/asm-cris/cache.h	Wed Aug 28 07:37:36 2002
+++ b/include/asm-cris/cache.h	Wed Aug 28 07:37:36 2002
@@ -7,4 +7,6 @@
 
 #define L1_CACHE_BYTES 32
 
+#define L1_CACHE_SHIFT_MAX 5	/* largest L1 which this arch supports */
+
 #endif /* _ASM_CACHE_H */
diff -Nru a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
--- a/include/asm-generic/tlb.h	Wed Aug 28 07:37:36 2002
+++ b/include/asm-generic/tlb.h	Wed Aug 28 07:37:36 2002
@@ -36,9 +36,12 @@
 typedef struct free_pte_ctx {
 	struct mm_struct	*mm;
 	unsigned int		nr;	/* set to ~0U means fast mode */
+	unsigned int		need_flush;/* Really unmapped some ptes? */
 	unsigned int		fullmm; /* non-zero means full mm flush */
 	unsigned long		freed;
 	struct page *		pages[FREE_PTE_NR];
+	unsigned long		flushes;/* stats: count avoided flushes */
+	unsigned long		avoided_flushes;
 } mmu_gather_t;
 
 /* Users of the generic TLB shootdown code must declare this storage space. */
@@ -66,13 +69,18 @@
 {
 	unsigned long nr;
 
+	if (!tlb->need_flush) {
+		tlb->avoided_flushes++;
+		return;
+	}
+	tlb->need_flush = 0;
+	tlb->flushes++;
+
 	tlb_flush(tlb);
 	nr = tlb->nr;
 	if (!tlb_fast_mode(tlb)) {
-		unsigned long i;
+		free_pages_and_swap_cache(tlb->pages, tlb->nr);
 		tlb->nr = 0;
-		for (i=0; i < nr; i++)
-			free_page_and_swap_cache(tlb->pages[i]);
 	}
 }
 
@@ -103,6 +111,7 @@
  */
 static inline void tlb_remove_page(mmu_gather_t *tlb, struct page *page)
 {
+	tlb->need_flush = 1;
 	if (tlb_fast_mode(tlb)) {
 		free_page_and_swap_cache(page);
 		return;
@@ -112,5 +121,29 @@
 		tlb_flush_mmu(tlb, 0, 0);
 }
 
-#endif /* _ASM_GENERIC__TLB_H */
+/**
+ * tlb_remove_tlb_entry - remember a pte unmapping for later tlb invalidation.
+ *
+ * Record the fact that pte's were really umapped in ->need_flush, so we can
+ * later optimise away the tlb invalidate.   This helps when userspace is
+ * unmapping already-unmapped pages, which happens quite a lot.
+ */
+#define tlb_remove_tlb_entry(tlb, ptep, address)		\
+	do {							\
+		tlb->need_flush = 1;				\
+		__tlb_remove_tlb_entry(tlb, ptep, address);	\
+	} while (0)
+
+#define pte_free_tlb(tlb, ptep)					\
+	do {							\
+		tlb->need_flush = 1;				\
+		__pte_free_tlb(tlb, ptep);			\
+	} while (0)
+
+#define pmd_free_tlb(tlb, pmdp)					\
+	do {							\
+		tlb->need_flush = 1;				\
+		__pmd_free_tlb(tlb, pmdp);			\
+	} while (0)
 
+#endif /* _ASM_GENERIC__TLB_H */
diff -Nru a/include/asm-i386/cache.h b/include/asm-i386/cache.h
--- a/include/asm-i386/cache.h	Wed Aug 28 07:37:36 2002
+++ b/include/asm-i386/cache.h	Wed Aug 28 07:37:36 2002
@@ -10,4 +10,6 @@
 #define L1_CACHE_SHIFT	(CONFIG_X86_L1_CACHE_SHIFT)
 #define L1_CACHE_BYTES	(1 << L1_CACHE_SHIFT)
 
+#define L1_CACHE_SHIFT_MAX 7	/* largest L1 which this arch supports */
+
 #endif
diff -Nru a/include/asm-i386/highmem.h b/include/asm-i386/highmem.h
--- a/include/asm-i386/highmem.h	Wed Aug 28 07:37:36 2002
+++ b/include/asm-i386/highmem.h	Wed Aug 28 07:37:36 2002
@@ -81,7 +81,7 @@
 	enum fixed_addresses idx;
 	unsigned long vaddr;
 
-	preempt_disable();
+	inc_preempt_count();
 	if (page < highmem_start_page)
 		return page_address(page);
 
@@ -119,7 +119,7 @@
 	__flush_tlb_one(vaddr);
 #endif
 
-	preempt_enable();
+	dec_preempt_count();
 }
 
 #endif /* __KERNEL__ */
diff -Nru a/include/asm-i386/io.h b/include/asm-i386/io.h
--- a/include/asm-i386/io.h	Wed Aug 28 07:37:37 2002
+++ b/include/asm-i386/io.h	Wed Aug 28 07:37:37 2002
@@ -96,11 +96,7 @@
 /*
  * Change "struct page" to physical address.
  */
-#ifdef CONFIG_HIGHMEM64G
-#define page_to_phys(page)	((u64)(page - mem_map) << PAGE_SHIFT)
-#else
-#define page_to_phys(page)	((page - mem_map) << PAGE_SHIFT)
-#endif
+#define page_to_phys(page)    ((dma_addr_t)page_to_pfn(page) << PAGE_SHIFT)
 
 extern void * __ioremap(unsigned long offset, unsigned long size, unsigned long flags);
 
diff -Nru a/include/asm-i386/max_numnodes.h b/include/asm-i386/max_numnodes.h
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/include/asm-i386/max_numnodes.h	Wed Aug 28 07:37:38 2002
@@ -0,0 +1,12 @@
+#ifndef _ASM_MAX_NUMNODES_H
+#define _ASM_MAX_NUMNODES_H
+
+#include <linux/config.h>
+
+#ifdef CONFIG_X86_NUMAQ
+#include <asm/numaq.h>
+#else
+#define MAX_NUMNODES	1
+#endif /* CONFIG_X86_NUMAQ */
+
+#endif /* _ASM_MAX_NUMNODES_H */
diff -Nru a/include/asm-i386/mmzone.h b/include/asm-i386/mmzone.h
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/include/asm-i386/mmzone.h	Wed Aug 28 07:37:38 2002
@@ -0,0 +1,78 @@
+/*
+ * Written by Pat Gaughen (gone@us.ibm.com) Mar 2002
+ *
+ */
+
+#ifndef _ASM_MMZONE_H_
+#define _ASM_MMZONE_H_
+
+#ifdef CONFIG_DISCONTIGMEM
+
+#ifdef CONFIG_X86_NUMAQ
+#include <asm/numaq.h>
+#else
+#define pa_to_nid(pa)	(0)
+#define pfn_to_nid(pfn)		(0)
+#ifdef CONFIG_NUMA
+#define _cpu_to_node(cpu) 0
+#endif /* CONFIG_NUMA */
+#endif /* CONFIG_X86_NUMAQ */
+
+#ifdef CONFIG_NUMA
+#define numa_node_id() _cpu_to_node(smp_processor_id())
+#endif /* CONFIG_NUMA */
+
+extern struct pglist_data *node_data[];
+
+/*
+ * Following are macros that are specific to this numa platform.
+ */
+#define reserve_bootmem(addr, size) \
+	reserve_bootmem_node(NODE_DATA(0), (addr), (size))
+#define alloc_bootmem(x) \
+	__alloc_bootmem_node(NODE_DATA(0), (x), SMP_CACHE_BYTES, __pa(MAX_DMA_ADDRESS))
+#define alloc_bootmem_low(x) \
+	__alloc_bootmem_node(NODE_DATA(0), (x), SMP_CACHE_BYTES, 0)
+#define alloc_bootmem_pages(x) \
+	__alloc_bootmem_node(NODE_DATA(0), (x), PAGE_SIZE, __pa(MAX_DMA_ADDRESS))
+#define alloc_bootmem_low_pages(x) \
+	__alloc_bootmem_node(NODE_DATA(0), (x), PAGE_SIZE, 0)
+#define alloc_bootmem_node(ignore, x) \
+	__alloc_bootmem_node(NODE_DATA(0), (x), SMP_CACHE_BYTES, __pa(MAX_DMA_ADDRESS))
+#define alloc_bootmem_pages_node(ignore, x) \
+	__alloc_bootmem_node(NODE_DATA(0), (x), PAGE_SIZE, __pa(MAX_DMA_ADDRESS))
+#define alloc_bootmem_low_pages_node(ignore, x) \
+	__alloc_bootmem_node(NODE_DATA(0), (x), PAGE_SIZE, 0)
+
+#define node_startnr(nid)	(node_data[nid]->node_start_mapnr)
+#define node_size(nid)		(node_data[nid]->node_size)
+#define node_localnr(pfn, nid)	((pfn) - node_data[nid]->node_start_pfn)
+
+/*
+ * Following are macros that each numa implmentation must define.
+ */
+
+/*
+ * Given a kernel address, find the home node of the underlying memory.
+ */
+#define kvaddr_to_nid(kaddr)	pa_to_nid(__pa(kaddr))
+
+/*
+ * Return a pointer to the node data for node n.
+ */
+#define NODE_DATA(nid)		(node_data[nid])
+
+#define node_mem_map(nid)	(NODE_DATA(nid)->node_mem_map)
+#define node_start_pfn(nid)	(NODE_DATA(nid)->node_start_pfn)
+
+#define local_mapnr(kvaddr) \
+	( (__pa(kvaddr) >> PAGE_SHIFT) - node_start_pfn(kvaddr_to_nid(kvaddr)) )
+
+#define kern_addr_valid(kaddr)	test_bit(local_mapnr(kaddr), \
+		 NODE_DATA(kvaddr_to_nid(kaddr))->valid_addr_bitmap)
+
+#define pfn_to_page(pfn)	(node_mem_map(pfn_to_nid(pfn)) + node_localnr(pfn, pfn_to_nid(pfn)))
+#define page_to_pfn(page)	((page - page_zone(page)->zone_mem_map) + page_zone(page)->zone_start_pfn)
+#define pmd_page(pmd)		(pfn_to_page(pmd_val(pmd) >> PAGE_SHIFT))
+#endif /* CONFIG_DISCONTIGMEM */
+#endif /* _ASM_MMZONE_H_ */
diff -Nru a/include/asm-i386/numaq.h b/include/asm-i386/numaq.h
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/include/asm-i386/numaq.h	Wed Aug 28 07:37:38 2002
@@ -0,0 +1,177 @@
+/*
+ * Written by: Patricia Gaughen, IBM Corporation
+ *
+ * Copyright (C) 2002, IBM Corp.
+ *
+ * All rights reserved.          
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE, GOOD TITLE or
+ * NON INFRINGEMENT.  See the GNU General Public License for more
+ * details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ *
+ * Send feedback to <gone@us.ibm.com>
+ */
+
+#ifndef NUMAQ_H
+#define NUMAQ_H
+
+#ifdef CONFIG_X86_NUMAQ
+
+#include <asm/smpboot.h>
+
+/*
+ * for now assume that 64Gb is max amount of RAM for whole system
+ *    64Gb * 1024Mb/Gb = 65536 Mb
+ *    65536 Mb / 256Mb = 256
+ */
+#define MAX_ELEMENTS 256
+#define ELEMENT_REPRESENTS 8 /* 256 Mb */
+
+#define MAX_NUMNODES		8
+#ifdef CONFIG_NUMA
+#define _cpu_to_node(cpu) (cpu_to_logical_apicid(cpu) >> 4)
+#endif /* CONFIG_NUMA */
+extern int pa_to_nid(u64);
+extern int pfn_to_nid(unsigned long);
+extern void get_memcfg_numaq(void);
+#define get_memcfg_numa() get_memcfg_numaq()
+
+/*
+ * SYS_CFG_DATA_PRIV_ADDR, struct eachquadmem, and struct sys_cfg_data are the
+ */
+#define SYS_CFG_DATA_PRIV_ADDR		0x0009d000 /* place for scd in private quad space */
+
+/*
+ * Communication area for each processor on lynxer-processor tests.
+ *
+ * NOTE: If you change the size of this eachproc structure you need
+ *       to change the definition for EACH_QUAD_SIZE.
+ */
+struct eachquadmem {
+	unsigned int	priv_mem_start;		/* Starting address of this */
+						/* quad's private memory. */
+						/* This is always 0. */
+						/* In MB. */
+	unsigned int	priv_mem_size;		/* Size of this quad's */
+						/* private memory. */
+						/* In MB. */
+	unsigned int	low_shrd_mem_strp_start;/* Starting address of this */
+						/* quad's low shared block */
+						/* (untranslated). */
+						/* In MB. */
+	unsigned int	low_shrd_mem_start;	/* Starting address of this */
+						/* quad's low shared memory */
+						/* (untranslated). */
+						/* In MB. */
+	unsigned int	low_shrd_mem_size;	/* Size of this quad's low */
+						/* shared memory. */
+						/* In MB. */
+	unsigned int	lmmio_copb_start;	/* Starting address of this */
+						/* quad's local memory */
+						/* mapped I/O in the */
+						/* compatibility OPB. */
+						/* In MB. */
+	unsigned int	lmmio_copb_size;	/* Size of this quad's local */
+						/* memory mapped I/O in the */
+						/* compatibility OPB. */
+						/* In MB. */
+	unsigned int	lmmio_nopb_start;	/* Starting address of this */
+						/* quad's local memory */
+						/* mapped I/O in the */
+						/* non-compatibility OPB. */
+						/* In MB. */
+	unsigned int	lmmio_nopb_size;	/* Size of this quad's local */
+						/* memory mapped I/O in the */
+						/* non-compatibility OPB. */
+						/* In MB. */
+	unsigned int	io_apic_0_start;	/* Starting address of I/O */
+						/* APIC 0. */
+	unsigned int	io_apic_0_sz;		/* Size I/O APIC 0. */
+	unsigned int	io_apic_1_start;	/* Starting address of I/O */
+						/* APIC 1. */
+	unsigned int	io_apic_1_sz;		/* Size I/O APIC 1. */
+	unsigned int	hi_shrd_mem_start;	/* Starting address of this */
+						/* quad's high shared memory.*/
+						/* In MB. */
+	unsigned int	hi_shrd_mem_size;	/* Size of this quad's high */
+						/* shared memory. */
+						/* In MB. */
+	unsigned int	mps_table_addr;		/* Address of this quad's */
+						/* MPS tables from BIOS, */
+						/* in system space.*/
+	unsigned int	lcl_MDC_pio_addr;	/* Port-I/O address for */
+						/* local access of MDC. */
+	unsigned int	rmt_MDC_mmpio_addr;	/* MM-Port-I/O address for */
+						/* remote access of MDC. */
+	unsigned int	mm_port_io_start;	/* Starting address of this */
+						/* quad's memory mapped Port */
+						/* I/O space. */
+	unsigned int	mm_port_io_size;	/* Size of this quad's memory*/
+						/* mapped Port I/O space. */
+	unsigned int	mm_rmt_io_apic_start;	/* Starting address of this */
+						/* quad's memory mapped */
+						/* remote I/O APIC space. */
+	unsigned int	mm_rmt_io_apic_size;	/* Size of this quad's memory*/
+						/* mapped remote I/O APIC */
+						/* space. */
+	unsigned int	mm_isa_start;		/* Starting address of this */
+						/* quad's memory mapped ISA */
+						/* space (contains MDC */
+						/* memory space). */
+	unsigned int	mm_isa_size;		/* Size of this quad's memory*/
+						/* mapped ISA space (contains*/
+						/* MDC memory space). */
+	unsigned int	rmt_qmi_addr;		/* Remote addr to access QMI.*/
+	unsigned int	lcl_qmi_addr;		/* Local addr to access QMI. */
+};
+
+/*
+ * Note: This structure must be NOT be changed unless the multiproc and
+ * OS are changed to reflect the new structure.
+ */
+struct sys_cfg_data {
+	unsigned int	quad_id;
+	unsigned int	bsp_proc_id; /* Boot Strap Processor in this quad. */
+	unsigned int	scd_version; /* Version number of this table. */
+	unsigned int	first_quad_id;
+	unsigned int	quads_present31_0; /* 1 bit for each quad */
+	unsigned int	quads_present63_32; /* 1 bit for each quad */
+	unsigned int	config_flags;
+	unsigned int	boot_flags;
+	unsigned int	csr_start_addr; /* Absolute value (not in MB) */
+	unsigned int	csr_size; /* Absolute value (not in MB) */
+	unsigned int	lcl_apic_start_addr; /* Absolute value (not in MB) */
+	unsigned int	lcl_apic_size; /* Absolute value (not in MB) */
+	unsigned int	low_shrd_mem_base; /* 0 or 512MB or 1GB */
+	unsigned int	low_shrd_mem_quad_offset; /* 0,128M,256M,512M,1G */
+					/* may not be totally populated */
+	unsigned int	split_mem_enbl; /* 0 for no low shared memory */ 
+	unsigned int	mmio_sz; /* Size of total system memory mapped I/O */
+				 /* (in MB). */
+	unsigned int	quad_spin_lock; /* Spare location used for quad */
+					/* bringup. */
+	unsigned int	nonzero55; /* For checksumming. */
+	unsigned int	nonzeroaa; /* For checksumming. */
+	unsigned int	scd_magic_number;
+	unsigned int	system_type;
+	unsigned int	checksum;
+	/*
+	 *	memory configuration area for each quad
+	 */
+        struct	eachquadmem eq[MAX_NUMNODES];	/* indexed by quad id */
+};
+
+#endif /* CONFIG_X86_NUMAQ */
+#endif /* NUMAQ_H */
+
diff -Nru a/include/asm-i386/page.h b/include/asm-i386/page.h
--- a/include/asm-i386/page.h	Wed Aug 28 07:37:36 2002
+++ b/include/asm-i386/page.h	Wed Aug 28 07:37:36 2002
@@ -134,8 +134,10 @@
 #define MAXMEM			((unsigned long)(-PAGE_OFFSET-VMALLOC_RESERVE))
 #define __pa(x)			((unsigned long)(x)-PAGE_OFFSET)
 #define __va(x)			((void *)((unsigned long)(x)+PAGE_OFFSET))
+#ifndef CONFIG_DISCONTIGMEM
 #define pfn_to_page(pfn)	(mem_map + (pfn))
 #define page_to_pfn(page)	((unsigned long)((page) - mem_map))
+#endif /* !CONFIG_DISCONTIGMEM */
 #define virt_to_page(kaddr)	pfn_to_page(__pa(kaddr) >> PAGE_SHIFT)
 
 #define pfn_valid(pfn)		((pfn) < max_mapnr)
diff -Nru a/include/asm-i386/pci.h b/include/asm-i386/pci.h
--- a/include/asm-i386/pci.h	Wed Aug 28 07:37:37 2002
+++ b/include/asm-i386/pci.h	Wed Aug 28 07:37:37 2002
@@ -109,7 +109,7 @@
 	if (direction == PCI_DMA_NONE)
 		BUG();
 
-	return (dma_addr_t)(page - mem_map) * PAGE_SIZE + offset;
+	return (dma_addr_t)(page_to_pfn(page)) * PAGE_SIZE + offset;
 }
 
 static inline void pci_unmap_page(struct pci_dev *hwdev, dma_addr_t dma_address,
@@ -238,9 +238,7 @@
 static __inline__ struct page *
 pci_dac_dma_to_page(struct pci_dev *pdev, dma64_addr_t dma_addr)
 {
-	unsigned long poff = (dma_addr >> PAGE_SHIFT);
-
-	return mem_map + poff;
+	return pfn_to_page(dma_addr >> PAGE_SHIFT);
 }
 
 static __inline__ unsigned long
diff -Nru a/include/asm-i386/pgalloc.h b/include/asm-i386/pgalloc.h
--- a/include/asm-i386/pgalloc.h	Wed Aug 28 07:37:36 2002
+++ b/include/asm-i386/pgalloc.h	Wed Aug 28 07:37:36 2002
@@ -13,7 +13,7 @@
 static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd, struct page *pte)
 {
 	set_pmd(pmd, __pmd(_PAGE_TABLE +
-		((unsigned long long)(pte - mem_map) <<
+		((unsigned long long)page_to_pfn(pte) <<
 			(unsigned long long) PAGE_SHIFT)));
 }
 /*
@@ -37,7 +37,7 @@
 }
 
 
-#define pte_free_tlb(tlb,pte) tlb_remove_page((tlb),(pte))
+#define __pte_free_tlb(tlb,pte) tlb_remove_page((tlb),(pte))
 
 /*
  * allocating and freeing a pmd is trivial: the 1-entry pmd is
@@ -47,7 +47,7 @@
 
 #define pmd_alloc_one(mm, addr)		({ BUG(); ((pmd_t *)2); })
 #define pmd_free(x)			do { } while (0)
-#define pmd_free_tlb(tlb,x)		do { } while (0)
+#define __pmd_free_tlb(tlb,x)		do { } while (0)
 #define pgd_populate(mm, pmd, pte)	BUG()
 
 #define check_pgt_cache()	do { } while (0)
diff -Nru a/include/asm-i386/pgtable.h b/include/asm-i386/pgtable.h
--- a/include/asm-i386/pgtable.h	Wed Aug 28 07:37:37 2002
+++ b/include/asm-i386/pgtable.h	Wed Aug 28 07:37:37 2002
@@ -234,8 +234,9 @@
 #define pmd_page_kernel(pmd) \
 ((unsigned long) __va(pmd_val(pmd) & PAGE_MASK))
 
-#define pmd_page(pmd) \
-	(mem_map + (pmd_val(pmd) >> PAGE_SHIFT))
+#ifndef CONFIG_DISCONTIGMEM
+#define pmd_page(pmd) (pfn_to_page(pmd_val(pmd) >> PAGE_SHIFT))
+#endif /* !CONFIG_DISCONTIGMEM */
 
 #define pmd_large(pmd) \
 	((pmd_val(pmd) & (_PAGE_PSE|_PAGE_PRESENT)) == (_PAGE_PSE|_PAGE_PRESENT))
@@ -280,7 +281,9 @@
 
 #endif /* !__ASSEMBLY__ */
 
+#ifndef CONFIG_DISCONTIGMEM
 #define kern_addr_valid(addr)	(1)
+#endif /* !CONFIG_DISCONTIGMEM */
 
 #define io_remap_page_range remap_page_range
 
diff -Nru a/include/asm-i386/semaphore.h b/include/asm-i386/semaphore.h
--- a/include/asm-i386/semaphore.h	Wed Aug 28 07:37:37 2002
+++ b/include/asm-i386/semaphore.h	Wed Aug 28 07:37:37 2002
@@ -40,6 +40,7 @@
 #include <asm/atomic.h>
 #include <linux/wait.h>
 #include <linux/rwsem.h>
+#include <linux/config.h>
 
 struct semaphore {
 	atomic_t count;
@@ -55,6 +56,12 @@
 		, (int)&(name).__magic
 #else
 # define __SEM_DEBUG_INIT(name)
+#endif
+
+#ifdef CONFIG_DEBUG_SPINLOCK
+# define assert_sem_held(sem)		BUG_ON(!down_trylock(sem))
+#else
+# define assert_sem_held(sem)		do { } while(0)
 #endif
 
 #define __SEMAPHORE_INITIALIZER(name,count) \
diff -Nru a/include/asm-i386/setup.h b/include/asm-i386/setup.h
--- a/include/asm-i386/setup.h	Wed Aug 28 07:37:37 2002
+++ b/include/asm-i386/setup.h	Wed Aug 28 07:37:37 2002
@@ -6,5 +6,38 @@
 #ifndef _i386_SETUP_H
 #define _i386_SETUP_H
 
+#define PFN_UP(x)	(((x) + PAGE_SIZE-1) >> PAGE_SHIFT)
+#define PFN_DOWN(x)	((x) >> PAGE_SHIFT)
+#define PFN_PHYS(x)	((x) << PAGE_SHIFT)
+
+/*
+ * Reserved space for vmalloc and iomap - defined in asm/page.h
+ */
+#define MAXMEM_PFN	PFN_DOWN(MAXMEM)
+#define MAX_NONPAE_PFN	(1 << 20)
+
+/*
+ * This is set up by the setup-routine at boot-time
+ */
+#define PARAM	((unsigned char *)empty_zero_page)
+#define SCREEN_INFO (*(struct screen_info *) (PARAM+0))
+#define EXT_MEM_K (*(unsigned short *) (PARAM+2))
+#define ALT_MEM_K (*(unsigned long *) (PARAM+0x1e0))
+#define E820_MAP_NR (*(char*) (PARAM+E820NR))
+#define E820_MAP    ((struct e820entry *) (PARAM+E820MAP))
+#define APM_BIOS_INFO (*(struct apm_bios_info *) (PARAM+0x40))
+#define DRIVE_INFO (*(struct drive_info_struct *) (PARAM+0x80))
+#define SYS_DESC_TABLE (*(struct sys_desc_table_struct*)(PARAM+0xa0))
+#define MOUNT_ROOT_RDONLY (*(unsigned short *) (PARAM+0x1F2))
+#define RAMDISK_FLAGS (*(unsigned short *) (PARAM+0x1F8))
+#define VIDEO_MODE (*(unsigned short *) (PARAM+0x1FA))
+#define ORIG_ROOT_DEV (*(unsigned short *) (PARAM+0x1FC))
+#define AUX_DEVICE_INFO (*(unsigned char *) (PARAM+0x1FF))
+#define LOADER_TYPE (*(unsigned char *) (PARAM+0x210))
+#define KERNEL_START (*(unsigned long *) (PARAM+0x214))
+#define INITRD_START (*(unsigned long *) (PARAM+0x218))
+#define INITRD_SIZE (*(unsigned long *) (PARAM+0x21c))
+#define COMMAND_LINE ((char *) (PARAM+2048))
+#define COMMAND_LINE_SIZE 256
 
 #endif /* _i386_SETUP_H */
diff -Nru a/include/asm-i386/spinlock.h b/include/asm-i386/spinlock.h
--- a/include/asm-i386/spinlock.h	Wed Aug 28 07:37:36 2002
+++ b/include/asm-i386/spinlock.h	Wed Aug 28 07:37:36 2002
@@ -157,6 +157,7 @@
 #define RW_LOCK_UNLOCKED (rwlock_t) { RW_LOCK_BIAS RWLOCK_MAGIC_INIT }
 
 #define rwlock_init(x)	do { *(x) = RW_LOCK_UNLOCKED; } while(0)
+#define rwlock_is_locked(x) ((x)->lock != RW_LOCK_BIAS)
 
 /*
  * On x86, we implement read-write locks as a 32-bit counter
diff -Nru a/include/asm-i386/tlb.h b/include/asm-i386/tlb.h
--- a/include/asm-i386/tlb.h	Wed Aug 28 07:37:37 2002
+++ b/include/asm-i386/tlb.h	Wed Aug 28 07:37:37 2002
@@ -7,7 +7,7 @@
  */
 #define tlb_start_vma(tlb, vma) do { } while (0)
 #define tlb_end_vma(tlb, vma) do { } while (0)
-#define tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
+#define __tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
 
 /*
  * .. because we flush the whole mm when it
diff -Nru a/include/asm-ia64/cache.h b/include/asm-ia64/cache.h
--- a/include/asm-ia64/cache.h	Wed Aug 28 07:37:37 2002
+++ b/include/asm-ia64/cache.h	Wed Aug 28 07:37:37 2002
@@ -12,6 +12,8 @@
 #define L1_CACHE_SHIFT		CONFIG_IA64_L1_CACHE_SHIFT
 #define L1_CACHE_BYTES		(1 << L1_CACHE_SHIFT)
 
+#define L1_CACHE_SHIFT_MAX 7	/* largest L1 which this arch supports */
+
 #ifdef CONFIG_SMP
 # define SMP_CACHE_SHIFT	L1_CACHE_SHIFT
 # define SMP_CACHE_BYTES	L1_CACHE_BYTES
diff -Nru a/include/asm-ia64/pgalloc.h b/include/asm-ia64/pgalloc.h
--- a/include/asm-ia64/pgalloc.h	Wed Aug 28 07:37:36 2002
+++ b/include/asm-ia64/pgalloc.h	Wed Aug 28 07:37:36 2002
@@ -108,7 +108,7 @@
 	++pgtable_cache_size;
 }
 
-#define pmd_free_tlb(tlb, pmd)	pmd_free(pmd)
+#define __pmd_free_tlb(tlb, pmd)	pmd_free(pmd)
 
 static inline void
 pmd_populate (struct mm_struct *mm, pmd_t *pmd_entry, struct page *pte)
@@ -154,7 +154,7 @@
 	free_page((unsigned long) pte);
 }
 
-#define pte_free_tlb(tlb, pte)	tlb_remove_page((tlb), (pte))
+#define __pte_free_tlb(tlb, pte)	tlb_remove_page((tlb), (pte))
 
 extern void check_pgt_cache (void);
 
diff -Nru a/include/asm-ia64/semaphore.h b/include/asm-ia64/semaphore.h
--- a/include/asm-ia64/semaphore.h	Wed Aug 28 07:37:37 2002
+++ b/include/asm-ia64/semaphore.h	Wed Aug 28 07:37:37 2002
@@ -6,6 +6,7 @@
  * Copyright (C) 1998-2000 David Mosberger-Tang <davidm@hpl.hp.com>
  */
 
+#include <linux/config.h>
 #include <linux/wait.h>
 #include <linux/rwsem.h>
 
@@ -24,6 +25,12 @@
 # define __SEM_DEBUG_INIT(name)		, (long) &(name).__magic
 #else
 # define __SEM_DEBUG_INIT(name)
+#endif
+
+#ifdef CONFIG_DEBUG_SPINLOCK
+# define assert_sem_held(sem)		BUG_ON(!down_trylock(sem))
+#else
+# define assert_sem_held(sem)		do { } while(0)
 #endif
 
 #define __SEMAPHORE_INITIALIZER(name,count)					\
diff -Nru a/include/asm-ia64/spinlock.h b/include/asm-ia64/spinlock.h
--- a/include/asm-ia64/spinlock.h	Wed Aug 28 07:37:36 2002
+++ b/include/asm-ia64/spinlock.h	Wed Aug 28 07:37:36 2002
@@ -109,6 +109,7 @@
 #define RW_LOCK_UNLOCKED (rwlock_t) { 0, 0 }
 
 #define rwlock_init(x) do { *(x) = RW_LOCK_UNLOCKED; } while(0)
+#define rwlock_is_locked(x) ((x)->read_counter != 0 || (x)->write_lock != 0)
 
 #define _raw_read_lock(rw)							\
 do {										\
diff -Nru a/include/asm-ia64/tlb.h b/include/asm-ia64/tlb.h
--- a/include/asm-ia64/tlb.h	Wed Aug 28 07:37:37 2002
+++ b/include/asm-ia64/tlb.h	Wed Aug 28 07:37:37 2002
@@ -172,7 +172,7 @@
  * PTE, not just those pointing to (normal) physical memory.
  */
 static inline void
-tlb_remove_tlb_entry (mmu_gather_t *tlb, pte_t *ptep, unsigned long address)
+__tlb_remove_tlb_entry (mmu_gather_t *tlb, pte_t *ptep, unsigned long address)
 {
 	if (tlb->start_addr == ~0UL)
 		tlb->start_addr = address;
diff -Nru a/include/asm-m68k/cache.h b/include/asm-m68k/cache.h
--- a/include/asm-m68k/cache.h	Wed Aug 28 07:37:37 2002
+++ b/include/asm-m68k/cache.h	Wed Aug 28 07:37:37 2002
@@ -8,4 +8,6 @@
 #define        L1_CACHE_SHIFT  4
 #define        L1_CACHE_BYTES  (1<< L1_CACHE_SHIFT)
 
+#define L1_CACHE_SHIFT_MAX 4	/* largest L1 which this arch supports */
+
 #endif
diff -Nru a/include/asm-m68k/motorola_pgalloc.h b/include/asm-m68k/motorola_pgalloc.h
--- a/include/asm-m68k/motorola_pgalloc.h	Wed Aug 28 07:37:38 2002
+++ b/include/asm-m68k/motorola_pgalloc.h	Wed Aug 28 07:37:38 2002
@@ -55,7 +55,7 @@
 	__free_page(page);
 }
 
-static inline void pte_free_tlb(mmu_gather_t *tlb, struct page *page)
+static inline void __pte_free_tlb(mmu_gather_t *tlb, struct page *page)
 {
 	cache_page(kmap(page));
 	kunmap(page);
@@ -73,7 +73,7 @@
 	return free_pointer_table(pmd);
 }
 
-static inline int pmd_free_tlb(mmu_gather_t *tlb, pmd_t *pmd)
+static inline int __pmd_free_tlb(mmu_gather_t *tlb, pmd_t *pmd)
 {
 	return free_pointer_table(pmd);
 }
diff -Nru a/include/asm-m68k/sun3_pgalloc.h b/include/asm-m68k/sun3_pgalloc.h
--- a/include/asm-m68k/sun3_pgalloc.h	Wed Aug 28 07:37:37 2002
+++ b/include/asm-m68k/sun3_pgalloc.h	Wed Aug 28 07:37:37 2002
@@ -31,7 +31,7 @@
         __free_page(page);
 }
 
-static inline void pte_free_tlb(mmu_gather_t *tlb, struct page *page)
+static inline void __pte_free_tlb(mmu_gather_t *tlb, struct page *page)
 {
 	tlb_remove_page(tlb, page);
 }
@@ -76,7 +76,7 @@
  * inside the pgd, so has no extra memory associated with it.
  */
 #define pmd_free(x)			do { } while (0)
-#define pmd_free_tlb(tlb, x)		do { } while (0)
+#define __pmd_free_tlb(tlb, x)		do { } while (0)
 
 static inline void pgd_free(pgd_t * pgd)
 {
diff -Nru a/include/asm-m68k/tlb.h b/include/asm-m68k/tlb.h
--- a/include/asm-m68k/tlb.h	Wed Aug 28 07:37:38 2002
+++ b/include/asm-m68k/tlb.h	Wed Aug 28 07:37:38 2002
@@ -7,7 +7,7 @@
  */
 #define tlb_start_vma(tlb, vma)	do { } while (0)
 #define tlb_end_vma(tlb, vma)	do { } while (0)
-#define tlb_remove_tlb_entry(tlb, ptep, address)	do { } while (0)
+#define __tlb_remove_tlb_entry(tlb, ptep, address)	do { } while (0)
 
 /*
  * .. because we flush the whole mm when it
diff -Nru a/include/asm-mips/cache.h b/include/asm-mips/cache.h
--- a/include/asm-mips/cache.h	Wed Aug 28 07:37:37 2002
+++ b/include/asm-mips/cache.h	Wed Aug 28 07:37:37 2002
@@ -35,5 +35,6 @@
 #endif
 
 #define SMP_CACHE_BYTES		L1_CACHE_BYTES
+#define L1_CACHE_SHIFT_MAX 5	/* largest L1 which this arch supports */
 
 #endif /* _ASM_CACHE_H */
diff -Nru a/include/asm-mips64/cache.h b/include/asm-mips64/cache.h
--- a/include/asm-mips64/cache.h	Wed Aug 28 07:37:37 2002
+++ b/include/asm-mips64/cache.h	Wed Aug 28 07:37:37 2002
@@ -11,5 +11,6 @@
 
 /* bytes per L1 cache line */
 #define L1_CACHE_BYTES		(1 << CONFIG_L1_CACHE_SHIFT)
+#define L1_CACHE_SHIFT_MAX 7	/* largest L1 which this arch supports */
 
 #endif /* _ASM_CACHE_H */
diff -Nru a/include/asm-mips64/mmzone.h b/include/asm-mips64/mmzone.h
--- a/include/asm-mips64/mmzone.h	Wed Aug 28 07:37:36 2002
+++ b/include/asm-mips64/mmzone.h	Wed Aug 28 07:37:36 2002
@@ -27,7 +27,7 @@
 #define PLAT_NODE_DATA_STARTNR(n)    (PLAT_NODE_DATA(n)->gendata.node_start_mapnr)
 #define PLAT_NODE_DATA_SIZE(n)	     (PLAT_NODE_DATA(n)->gendata.node_size)
 #define PLAT_NODE_DATA_LOCALNR(p, n) \
-		(((p) - PLAT_NODE_DATA(n)->gendata.node_start_paddr) >> PAGE_SHIFT)
+		(((p) >> PAGE_SHIFT) - PLAT_NODE_DATA(n)->gendata.node_start_pfn)
 
 #define numa_node_id()	cputocnode(current->processor)
 
diff -Nru a/include/asm-mips64/pgtable.h b/include/asm-mips64/pgtable.h
--- a/include/asm-mips64/pgtable.h	Wed Aug 28 07:37:38 2002
+++ b/include/asm-mips64/pgtable.h	Wed Aug 28 07:37:38 2002
@@ -484,8 +484,8 @@
 #define PAGE_TO_PA(page)	((page - mem_map) << PAGE_SHIFT)
 #else
 #define PAGE_TO_PA(page) \
-		((((page)-(page)->zone->zone_mem_map) << PAGE_SHIFT) \
-		+ ((page)->zone->zone_start_paddr))
+		(( ((page)-(page)->zone->zone_mem_map) + \
+		   (page)->zone->zone_start_pfn) << PAGE_SHIFT)
 #endif
 #define mk_pte(page, pgprot)						\
 ({									\
diff -Nru a/include/asm-parisc/cache.h b/include/asm-parisc/cache.h
--- a/include/asm-parisc/cache.h	Wed Aug 28 07:37:36 2002
+++ b/include/asm-parisc/cache.h	Wed Aug 28 07:37:36 2002
@@ -34,6 +34,7 @@
 #define L1_CACHE_ALIGN(x)       (((x)+(L1_CACHE_BYTES-1))&~(L1_CACHE_BYTES-1))
 
 #define SMP_CACHE_BYTES L1_CACHE_BYTES
+#define L1_CACHE_SHIFT_MAX 5	/* largest L1 which this arch supports */
 
 #define __cacheline_aligned __attribute__((__aligned__(L1_CACHE_BYTES)))
 
diff -Nru a/include/asm-ppc/cache.h b/include/asm-ppc/cache.h
--- a/include/asm-ppc/cache.h	Wed Aug 28 07:37:38 2002
+++ b/include/asm-ppc/cache.h	Wed Aug 28 07:37:38 2002
@@ -29,6 +29,7 @@
 #define	L1_CACHE_BYTES L1_CACHE_LINE_SIZE
 #define L1_CACHE_SHIFT LG_L1_CACHE_LINE_SIZE
 #define	SMP_CACHE_BYTES L1_CACHE_BYTES
+#define L1_CACHE_SHIFT_MAX 7	/* largest L1 which this arch supports */
 
 #define	L1_CACHE_ALIGN(x)       (((x)+(L1_CACHE_BYTES-1))&~(L1_CACHE_BYTES-1))
 #define	L1_CACHE_PAGES		8
diff -Nru a/include/asm-ppc/hardirq.h b/include/asm-ppc/hardirq.h
--- a/include/asm-ppc/hardirq.h	Wed Aug 28 07:37:36 2002
+++ b/include/asm-ppc/hardirq.h	Wed Aug 28 07:37:36 2002
@@ -85,8 +85,10 @@
 #define irq_enter()		(preempt_count() += HARDIRQ_OFFSET)
 
 #if CONFIG_PREEMPT
+# define in_atomic()	(preempt_count() != kernel_locked())
 # define IRQ_EXIT_OFFSET (HARDIRQ_OFFSET-1)
 #else
+# define in_atomic()	(preempt_count() != 0)
 # define IRQ_EXIT_OFFSET HARDIRQ_OFFSET
 #endif
 #define irq_exit()							\
diff -Nru a/include/asm-ppc/highmem.h b/include/asm-ppc/highmem.h
--- a/include/asm-ppc/highmem.h	Wed Aug 28 07:37:37 2002
+++ b/include/asm-ppc/highmem.h	Wed Aug 28 07:37:37 2002
@@ -88,6 +88,7 @@
 	unsigned int idx;
 	unsigned long vaddr;
 
+	inc_preempt_count();
 	if (page < highmem_start_page)
 		return page_address(page);
 
@@ -122,6 +123,7 @@
 	pte_clear(kmap_pte+idx);
 	flush_tlb_page(0, vaddr);
 #endif
+	dec_preempt_count();
 }
 
 #endif /* __KERNEL__ */
diff -Nru a/include/asm-ppc/pgalloc.h b/include/asm-ppc/pgalloc.h
--- a/include/asm-ppc/pgalloc.h	Wed Aug 28 07:37:36 2002
+++ b/include/asm-ppc/pgalloc.h	Wed Aug 28 07:37:36 2002
@@ -20,7 +20,7 @@
  */
 #define pmd_alloc_one(mm,address)       ({ BUG(); ((pmd_t *)2); })
 #define pmd_free(x)                     do { } while (0)
-#define pmd_free_tlb(tlb,x)		do { } while (0)
+#define __pmd_free_tlb(tlb,x)		do { } while (0)
 #define pgd_populate(mm, pmd, pte)      BUG()
 
 #define pmd_populate_kernel(mm, pmd, pte)	\
@@ -33,7 +33,7 @@
 extern void pte_free_kernel(pte_t *pte);
 extern void pte_free(struct page *pte);
 
-#define pte_free_tlb(tlb, pte)	pte_free((pte))
+#define __pte_free_tlb(tlb, pte)	pte_free((pte))
 
 #define check_pgt_cache()	do { } while (0)
 
diff -Nru a/include/asm-ppc/tlb.h b/include/asm-ppc/tlb.h
--- a/include/asm-ppc/tlb.h	Wed Aug 28 07:37:36 2002
+++ b/include/asm-ppc/tlb.h	Wed Aug 28 07:37:36 2002
@@ -34,7 +34,7 @@
 extern void flush_hash_entry(struct mm_struct *mm, pte_t *ptep,
 			     unsigned long address);
 
-static inline void tlb_remove_tlb_entry(mmu_gather_t *tlb, pte_t *ptep,
+static inline void __tlb_remove_tlb_entry(mmu_gather_t *tlb, pte_t *ptep,
 					unsigned long address)
 {
 	if (pte_val(*ptep) & _PAGE_HASHPTE)
@@ -50,7 +50,7 @@
 #define tlb_finish_arch(tlb)		do { } while (0)
 #define tlb_start_vma(tlb, vma)		do { } while (0)
 #define tlb_end_vma(tlb, vma)		do { } while (0)
-#define tlb_remove_tlb_entry(tlb, pte, address) do { } while (0)
+#define __tlb_remove_tlb_entry(tlb, pte, address) do { } while (0)
 #define tlb_flush(tlb)			flush_tlb_mm((tlb)->mm)
 
 /* Get the generic bits... */
diff -Nru a/include/asm-ppc64/cache.h b/include/asm-ppc64/cache.h
--- a/include/asm-ppc64/cache.h	Wed Aug 28 07:37:36 2002
+++ b/include/asm-ppc64/cache.h	Wed Aug 28 07:37:36 2002
@@ -12,5 +12,6 @@
 #define L1_CACHE_BYTES	(1 << L1_CACHE_SHIFT)
 
 #define SMP_CACHE_BYTES L1_CACHE_BYTES
+#define L1_CACHE_SHIFT_MAX 7	/* largest L1 which this arch supports */
 
 #endif
diff -Nru a/include/asm-ppc64/mmzone.h b/include/asm-ppc64/mmzone.h
--- a/include/asm-ppc64/mmzone.h	Wed Aug 28 07:37:38 2002
+++ b/include/asm-ppc64/mmzone.h	Wed Aug 28 07:37:38 2002
@@ -31,7 +31,7 @@
 	(PLAT_NODE_DATA(n)->gendata.node_start_mapnr)
 #define PLAT_NODE_DATA_SIZE(n)		(PLAT_NODE_DATA(n)->gendata.node_size)
 #define PLAT_NODE_DATA_LOCALNR(p, n)	\
-	(((p) - PLAT_NODE_DATA(n)->gendata.node_start_paddr) >> PAGE_SHIFT)
+	(((p) >> PAGE_SHIFT) - PLAT_NODE_DATA(n)->gendata.node_start_pfn)
 
 #ifdef CONFIG_DISCONTIGMEM
 
@@ -67,7 +67,7 @@
  * node's mem_map.
  */
 #define LOCAL_BASE_ADDR(kaddr) \
-	((unsigned long)__va(NODE_DATA(KVADDR_TO_NID(kaddr))->node_start_paddr))
+	((unsigned long)__va(NODE_DATA(KVADDR_TO_NID(kaddr))->node_start_pfn << PAGE_SHIFT))
 
 #define LOCAL_MAP_NR(kvaddr) \
 	(((unsigned long)(kvaddr)-LOCAL_BASE_ADDR(kvaddr)) >> PAGE_SHIFT)
diff -Nru a/include/asm-ppc64/page.h b/include/asm-ppc64/page.h
--- a/include/asm-ppc64/page.h	Wed Aug 28 07:37:36 2002
+++ b/include/asm-ppc64/page.h	Wed Aug 28 07:37:36 2002
@@ -207,7 +207,7 @@
 #ifdef CONFIG_DISCONTIGMEM
 #define page_to_pfn(page) \
 		((page) - page_zone(page)->zone_mem_map + \
-		(page_zone(page)->zone_start_paddr >> PAGE_SHIFT))
+		(page_zone(page)->zone_start_pfn))
 #define pfn_to_page(pfn)	discontigmem_pfn_to_page(pfn)
 #else
 #define pfn_to_page(pfn)	(mem_map + (pfn))
diff -Nru a/include/asm-ppc64/pgalloc.h b/include/asm-ppc64/pgalloc.h
--- a/include/asm-ppc64/pgalloc.h	Wed Aug 28 07:37:36 2002
+++ b/include/asm-ppc64/pgalloc.h	Wed Aug 28 07:37:36 2002
@@ -53,7 +53,7 @@
 	free_page((unsigned long)pmd);
 }
 
-#define pmd_free_tlb(tlb, pmd)	pmd_free(pmd)
+#define __pmd_free_tlb(tlb, pmd)	pmd_free(pmd)
 
 #define pmd_populate_kernel(mm, pmd, pte) pmd_set(pmd, pte)
 #define pmd_populate(mm, pmd, pte_page) \
@@ -88,7 +88,7 @@
 }
 
 #define pte_free(pte_page)	pte_free_kernel(page_address(pte_page))
-#define pte_free_tlb(tlb, pte)	pte_free(pte)
+#define __pte_free_tlb(tlb, pte)	pte_free(pte)
 
 #define check_pgt_cache()	do { } while (0)
 
diff -Nru a/include/asm-ppc64/tlb.h b/include/asm-ppc64/tlb.h
--- a/include/asm-ppc64/tlb.h	Wed Aug 28 07:37:37 2002
+++ b/include/asm-ppc64/tlb.h	Wed Aug 28 07:37:37 2002
@@ -40,7 +40,7 @@
 
 extern struct ppc64_tlb_batch ppc64_tlb_batch[NR_CPUS];
 
-static inline void tlb_remove_tlb_entry(mmu_gather_t *tlb, pte_t *ptep,
+static inline void __tlb_remove_tlb_entry(mmu_gather_t *tlb, pte_t *ptep,
 					unsigned long address)
 {
 	int cpu = smp_processor_id();
diff -Nru a/include/asm-s390/cache.h b/include/asm-s390/cache.h
--- a/include/asm-s390/cache.h	Wed Aug 28 07:37:36 2002
+++ b/include/asm-s390/cache.h	Wed Aug 28 07:37:36 2002
@@ -13,5 +13,6 @@
 
 #define L1_CACHE_BYTES     256
 #define L1_CACHE_SHIFT     8
+#define L1_CACHE_SHIFT_MAX 8	/* largest L1 which this arch supports */
 
 #endif
diff -Nru a/include/asm-s390/pgalloc.h b/include/asm-s390/pgalloc.h
--- a/include/asm-s390/pgalloc.h	Wed Aug 28 07:37:37 2002
+++ b/include/asm-s390/pgalloc.h	Wed Aug 28 07:37:37 2002
@@ -49,7 +49,7 @@
  */
 #define pmd_alloc_one(mm,address)       ({ BUG(); ((pmd_t *)2); })
 #define pmd_free(x)                     do { } while (0)
-#define pmd_free_tlb(tlb,x)		do { } while (0)
+#define __pmd_free_tlb(tlb,x)		do { } while (0)
 #define pgd_populate(mm, pmd, pte)      BUG()
 
 static inline void 
@@ -107,7 +107,7 @@
         __free_page(pte);
 }
 
-#define pte_free_tlb(tlb,pte) tlb_remove_page((tlb),(pte))
+#define __pte_free_tlb(tlb,pte) tlb_remove_page((tlb),(pte))
 
 /*
  * This establishes kernel virtual mappings (e.g., as a result of a
diff -Nru a/include/asm-s390/tlb.h b/include/asm-s390/tlb.h
--- a/include/asm-s390/tlb.h	Wed Aug 28 07:37:37 2002
+++ b/include/asm-s390/tlb.h	Wed Aug 28 07:37:37 2002
@@ -7,7 +7,7 @@
  */
 #define tlb_start_vma(tlb, vma) do { } while (0)
 #define tlb_end_vma(tlb, vma) do { } while (0)
-#define tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
+#define __tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
 
 /*
  * .. because we flush the whole mm when it
diff -Nru a/include/asm-s390x/cache.h b/include/asm-s390x/cache.h
--- a/include/asm-s390x/cache.h	Wed Aug 28 07:37:36 2002
+++ b/include/asm-s390x/cache.h	Wed Aug 28 07:37:36 2002
@@ -13,5 +13,6 @@
 
 #define L1_CACHE_BYTES     256
 #define L1_CACHE_SHIFT     8
+#define L1_CACHE_SHIFT_MAX 8	/* largest L1 which this arch supports */
 
 #endif
diff -Nru a/include/asm-s390x/pgalloc.h b/include/asm-s390x/pgalloc.h
--- a/include/asm-s390x/pgalloc.h	Wed Aug 28 07:37:36 2002
+++ b/include/asm-s390x/pgalloc.h	Wed Aug 28 07:37:36 2002
@@ -68,7 +68,7 @@
 	free_pages((unsigned long) pmd, 2);
 }
 
-#define pmd_free_tlb(tlb,pmd) pmd_free(pmd)
+#define __pmd_free_tlb(tlb,pmd) pmd_free(pmd)
 
 static inline void
 pmd_populate_kernel(struct mm_struct *mm, pmd_t *pmd, pte_t *pte)
@@ -123,7 +123,7 @@
         __free_page(pte);
 }
 
-#define pte_free_tlb(tlb,pte) tlb_remove_page((tlb),(pte))
+#define __pte_free_tlb(tlb,pte) tlb_remove_page((tlb),(pte))
 
 /*
  * This establishes kernel virtual mappings (e.g., as a result of a
diff -Nru a/include/asm-s390x/tlb.h b/include/asm-s390x/tlb.h
--- a/include/asm-s390x/tlb.h	Wed Aug 28 07:37:36 2002
+++ b/include/asm-s390x/tlb.h	Wed Aug 28 07:37:36 2002
@@ -7,7 +7,7 @@
  */
 #define tlb_start_vma(tlb, vma) do { } while (0)
 #define tlb_end_vma(tlb, vma) do { } while (0)
-#define tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
+#define __tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
 
 /*
  * .. because we flush the whole mm when it
diff -Nru a/include/asm-sh/cache.h b/include/asm-sh/cache.h
--- a/include/asm-sh/cache.h	Wed Aug 28 07:37:37 2002
+++ b/include/asm-sh/cache.h	Wed Aug 28 07:37:37 2002
@@ -14,4 +14,6 @@
 #define        L1_CACHE_BYTES  32
 #endif
 
+#define L1_CACHE_SHIFT_MAX 5	/* largest L1 which this arch supports */
+
 #endif /* __ASM_SH_CACHE_H */
diff -Nru a/include/asm-sparc/cache.h b/include/asm-sparc/cache.h
--- a/include/asm-sparc/cache.h	Wed Aug 28 07:37:37 2002
+++ b/include/asm-sparc/cache.h	Wed Aug 28 07:37:37 2002
@@ -13,6 +13,7 @@
 #define L1_CACHE_SHIFT 5
 #define L1_CACHE_BYTES 32
 #define L1_CACHE_ALIGN(x) ((((x)+(L1_CACHE_BYTES-1))&~(L1_CACHE_BYTES-1)))
+#define L1_CACHE_SHIFT_MAX 5	/* largest L1 which this arch supports */
 
 #define SMP_CACHE_BYTES 32
 
diff -Nru a/include/asm-sparc/hardirq.h b/include/asm-sparc/hardirq.h
--- a/include/asm-sparc/hardirq.h	Wed Aug 28 07:37:38 2002
+++ b/include/asm-sparc/hardirq.h	Wed Aug 28 07:37:38 2002
@@ -113,6 +113,12 @@
 #define irq_exit()		br_read_unlock(BR_GLOBALIRQ_LOCK)
 #endif
 
+#if CONFIG_PREEMPT
+# define in_atomic()	(preempt_count() != kernel_locked())
+#else
+# define in_atomic()	(preempt_count() != 0)
+#endif
+
 #ifndef CONFIG_SMP
 
 #define synchronize_irq()	barrier()
diff -Nru a/include/asm-sparc/highmem.h b/include/asm-sparc/highmem.h
--- a/include/asm-sparc/highmem.h	Wed Aug 28 07:37:38 2002
+++ b/include/asm-sparc/highmem.h	Wed Aug 28 07:37:38 2002
@@ -83,6 +83,7 @@
 	unsigned long idx;
 	unsigned long vaddr;
 
+	inc_preempt_count();
 	if (page < highmem_start_page)
 		return page_address(page);
 
@@ -142,6 +143,7 @@
 	flush_tlb_all();
 #endif
 #endif
+	dec_preempt_count();
 }
 
 #endif /* __KERNEL__ */
diff -Nru a/include/asm-sparc/pgalloc.h b/include/asm-sparc/pgalloc.h
--- a/include/asm-sparc/pgalloc.h	Wed Aug 28 07:37:36 2002
+++ b/include/asm-sparc/pgalloc.h	Wed Aug 28 07:37:36 2002
@@ -47,7 +47,7 @@
 #define free_pmd_fast(pmd)	BTFIXUP_CALL(free_pmd_fast)(pmd)
 
 #define pmd_free(pmd)           free_pmd_fast(pmd)
-#define pmd_free_tlb(tlb, pmd)	pmd_free(pmd)
+#define __pmd_free_tlb(tlb, pmd) pmd_free(pmd)
 
 BTFIXUPDEF_CALL(void, pmd_populate, pmd_t *, struct page *)
 #define pmd_populate(MM, PMD, PTE)        BTFIXUP_CALL(pmd_populate)(PMD, PTE)
@@ -64,6 +64,6 @@
 
 BTFIXUPDEF_CALL(void, pte_free, struct page *)
 #define pte_free(pte)		BTFIXUP_CALL(pte_free)(pte)
-#define pte_free_tlb(tlb, pte)	pte_free(pte)
+#define __pte_free_tlb(tlb, pte)	pte_free(pte)
 
 #endif /* _SPARC_PGALLOC_H */
diff -Nru a/include/asm-sparc/tlb.h b/include/asm-sparc/tlb.h
--- a/include/asm-sparc/tlb.h	Wed Aug 28 07:37:37 2002
+++ b/include/asm-sparc/tlb.h	Wed Aug 28 07:37:37 2002
@@ -11,7 +11,7 @@
 	flush_tlb_range(vma, vma->vm_start, vma->vm_end);	\
 } while (0)
 
-#define tlb_remove_tlb_entry(tlb, pte, address) \
+#define __tlb_remove_tlb_entry(tlb, pte, address) \
 	do { } while (0)
 
 #define tlb_flush(tlb) \
diff -Nru a/include/asm-sparc64/cache.h b/include/asm-sparc64/cache.h
--- a/include/asm-sparc64/cache.h	Wed Aug 28 07:37:37 2002
+++ b/include/asm-sparc64/cache.h	Wed Aug 28 07:37:37 2002
@@ -9,6 +9,7 @@
 #define        L1_CACHE_BYTES	32 /* Two 16-byte sub-blocks per line. */
 
 #define        L1_CACHE_ALIGN(x)       (((x)+(L1_CACHE_BYTES-1))&~(L1_CACHE_BYTES-1))
+#define		L1_CACHE_SHIFT_MAX 5	/* largest L1 which this arch supports */
 
 #define        SMP_CACHE_BYTES_SHIFT	6
 #define        SMP_CACHE_BYTES		(1 << SMP_CACHE_BYTES_SHIFT) /* L2 cache line size. */
diff -Nru a/include/asm-sparc64/tlb.h b/include/asm-sparc64/tlb.h
--- a/include/asm-sparc64/tlb.h	Wed Aug 28 07:37:36 2002
+++ b/include/asm-sparc64/tlb.h	Wed Aug 28 07:37:36 2002
@@ -16,12 +16,12 @@
 		flush_tlb_range(vma, vma->vm_start, vma->vm_end); \
 } while (0)
 
-#define tlb_remove_tlb_entry(tlb, ptep, address) \
+#define __tlb_remove_tlb_entry(tlb, ptep, address) \
 	do { } while (0)
 
 #include <asm-generic/tlb.h>
 
-#define pmd_free_tlb(tlb, pmd)	pmd_free(pmd)
-#define pte_free_tlb(tlb, pte)	pte_free(pte)
+#define __pmd_free_tlb(tlb, pmd)	pmd_free(pmd)
+#define __pte_free_tlb(tlb, pte)	pte_free(pte)
 
 #endif /* _SPARC64_TLB_H */
diff -Nru a/include/asm-x86_64/cache.h b/include/asm-x86_64/cache.h
--- a/include/asm-x86_64/cache.h	Wed Aug 28 07:37:37 2002
+++ b/include/asm-x86_64/cache.h	Wed Aug 28 07:37:37 2002
@@ -9,5 +9,6 @@
 /* L1 cache line size */
 #define L1_CACHE_SHIFT	(CONFIG_X86_L1_CACHE_SHIFT)
 #define L1_CACHE_BYTES	(1 << L1_CACHE_SHIFT)
+#define L1_CACHE_SHIFT_MAX 6	/* largest L1 which this arch supports */
 
 #endif
diff -Nru a/include/asm-x86_64/pgalloc.h b/include/asm-x86_64/pgalloc.h
--- a/include/asm-x86_64/pgalloc.h	Wed Aug 28 07:37:37 2002
+++ b/include/asm-x86_64/pgalloc.h	Wed Aug 28 07:37:37 2002
@@ -75,7 +75,7 @@
 	__free_page(pte);
 } 
 
-#define pte_free_tlb(tlb,pte) tlb_remove_page((tlb),(pte))
-#define pmd_free_tlb(tlb,x)   do { } while (0)
+#define __pte_free_tlb(tlb,pte) tlb_remove_page((tlb),(pte))
+#define __pmd_free_tlb(tlb,x)   do { } while (0)
 
 #endif /* _X86_64_PGALLOC_H */
diff -Nru a/include/asm-x86_64/tlb.h b/include/asm-x86_64/tlb.h
--- a/include/asm-x86_64/tlb.h	Wed Aug 28 07:37:36 2002
+++ b/include/asm-x86_64/tlb.h	Wed Aug 28 07:37:36 2002
@@ -4,7 +4,7 @@
 
 #define tlb_start_vma(tlb, vma) do { } while (0)
 #define tlb_end_vma(tlb, vma) do { } while (0)
-#define tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
+#define __tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
 
 #define tlb_flush(tlb) flush_tlb_mm((tlb)->mm)
 
diff -Nru a/include/linux/backing-dev.h b/include/linux/backing-dev.h
--- a/include/linux/backing-dev.h	Wed Aug 28 07:37:37 2002
+++ b/include/linux/backing-dev.h	Wed Aug 28 07:37:37 2002
@@ -19,6 +19,7 @@
 struct backing_dev_info {
 	unsigned long ra_pages;	/* max readahead in PAGE_CACHE_SIZE units */
 	unsigned long state;	/* Always use atomic bitops on this */
+	int memory_backed;	/* Cannot clean pages with writepage */
 };
 
 extern struct backing_dev_info default_backing_dev_info;
diff -Nru a/include/linux/bootmem.h b/include/linux/bootmem.h
--- a/include/linux/bootmem.h	Wed Aug 28 07:37:38 2002
+++ b/include/linux/bootmem.h	Wed Aug 28 07:37:38 2002
@@ -36,9 +36,10 @@
 
 extern unsigned long __init bootmem_bootmap_pages (unsigned long);
 extern unsigned long __init init_bootmem (unsigned long addr, unsigned long memend);
-extern void __init reserve_bootmem (unsigned long addr, unsigned long size);
 extern void __init free_bootmem (unsigned long addr, unsigned long size);
 extern void * __init __alloc_bootmem (unsigned long size, unsigned long align, unsigned long goal);
+#ifndef CONFIG_HAVE_ARCH_BOOTMEM_NODE
+extern void __init reserve_bootmem (unsigned long addr, unsigned long size);
 #define alloc_bootmem(x) \
 	__alloc_bootmem((x), SMP_CACHE_BYTES, __pa(MAX_DMA_ADDRESS))
 #define alloc_bootmem_low(x) \
@@ -47,6 +48,7 @@
 	__alloc_bootmem((x), PAGE_SIZE, __pa(MAX_DMA_ADDRESS))
 #define alloc_bootmem_low_pages(x) \
 	__alloc_bootmem((x), PAGE_SIZE, 0)
+#endif /* !CONFIG_HAVE_ARCH_BOOTMEM_NODE */
 extern unsigned long __init free_all_bootmem (void);
 
 extern unsigned long __init init_bootmem_node (pg_data_t *pgdat, unsigned long freepfn, unsigned long startpfn, unsigned long endpfn);
@@ -54,11 +56,13 @@
 extern void __init free_bootmem_node (pg_data_t *pgdat, unsigned long addr, unsigned long size);
 extern unsigned long __init free_all_bootmem_node (pg_data_t *pgdat);
 extern void * __init __alloc_bootmem_node (pg_data_t *pgdat, unsigned long size, unsigned long align, unsigned long goal);
+#ifndef CONFIG_HAVE_ARCH_BOOTMEM_NODE
 #define alloc_bootmem_node(pgdat, x) \
 	__alloc_bootmem_node((pgdat), (x), SMP_CACHE_BYTES, __pa(MAX_DMA_ADDRESS))
 #define alloc_bootmem_pages_node(pgdat, x) \
 	__alloc_bootmem_node((pgdat), (x), PAGE_SIZE, __pa(MAX_DMA_ADDRESS))
 #define alloc_bootmem_low_pages_node(pgdat, x) \
 	__alloc_bootmem_node((pgdat), (x), PAGE_SIZE, 0)
+#endif /* !CONFIG_HAVE_ARCH_BOOTMEM_NODE */
 
 #endif /* _LINUX_BOOTMEM_H */
diff -Nru a/include/linux/buffer_head.h b/include/linux/buffer_head.h
--- a/include/linux/buffer_head.h	Wed Aug 28 07:37:36 2002
+++ b/include/linux/buffer_head.h	Wed Aug 28 07:37:36 2002
@@ -167,6 +167,7 @@
 struct buffer_head *alloc_buffer_head(void);
 void free_buffer_head(struct buffer_head * bh);
 void FASTCALL(unlock_buffer(struct buffer_head *bh));
+extern int buffer_heads_over_limit;
 
 /*
  * Generic address_space_operations implementations for buffer_head-backed
diff -Nru a/include/linux/cache.h b/include/linux/cache.h
--- a/include/linux/cache.h	Wed Aug 28 07:37:38 2002
+++ b/include/linux/cache.h	Wed Aug 28 07:37:38 2002
@@ -44,4 +44,13 @@
 #endif /* CONFIG_SMP */
 #endif
 
+#if !defined(____cacheline_maxaligned_in_smp)
+#if defined(CONFIG_SMP)
+#define ____cacheline_maxaligned_in_smp \
+	__attribute__((__aligned__(1 << (L1_CACHE_SHIFT_MAX))))
+#else
+#define ____cacheline_maxaligned_in_smp
+#endif
+#endif
+
 #endif /* __LINUX_CACHE_H */
diff -Nru a/include/linux/dcache.h b/include/linux/dcache.h
--- a/include/linux/dcache.h	Wed Aug 28 07:37:38 2002
+++ b/include/linux/dcache.h	Wed Aug 28 07:37:38 2002
@@ -181,8 +181,6 @@
 extern void shrink_dcache_anon(struct list_head *);
 extern int d_invalidate(struct dentry *);
 
-#define shrink_dcache() prune_dcache(0)
-struct zone_struct;
 /* dcache memory management */
 extern int shrink_dcache_memory(int, unsigned int);
 extern void prune_dcache(int);
diff -Nru a/include/linux/ext3_fs.h b/include/linux/ext3_fs.h
--- a/include/linux/ext3_fs.h	Wed Aug 28 07:37:36 2002
+++ b/include/linux/ext3_fs.h	Wed Aug 28 07:37:36 2002
@@ -341,6 +341,7 @@
   #define EXT3_MOUNT_WRITEBACK_DATA	0x0C00	/* No data ordering */
 #define EXT3_MOUNT_UPDATE_JOURNAL	0x1000	/* Update the journal format */
 #define EXT3_MOUNT_NO_UID32		0x2000  /* Disable 32-bit UIDs */
+#define EXT3_MOUNT_INDEX		0x4000  /* Enable directory index */
 
 /* Compatibility, for having both ext2_fs.h and ext3_fs.h included at once */
 #ifndef _LINUX_EXT2_FS_H
@@ -580,6 +581,28 @@
 #define EXT3_DIR_ROUND			(EXT3_DIR_PAD - 1)
 #define EXT3_DIR_REC_LEN(name_len)	(((name_len) + 8 + EXT3_DIR_ROUND) & \
 					 ~EXT3_DIR_ROUND)
+/*
+ * Hash Tree Directory indexing
+ * (c) Daniel Phillips, 2001
+ */
+
+#ifdef CONFIG_EXT3_INDEX
+  enum {ext3_dx = 1};
+  #define is_dx(dir) (EXT3_I(dir)->i_flags & EXT3_INDEX_FL)
+#define EXT3_DIR_LINK_MAX(dir) (!is_dx(dir) && (dir)->i_nlink >= EXT3_LINK_MAX)
+#define EXT3_DIR_LINK_EMPTY(dir) ((dir)->i_nlink == 2 || (dir)->i_nlink == 1)
+#else
+  enum {ext3_dx = 0};
+  #define is_dx(dir) 0
+#define EXT3_DIR_LINK_MAX(dir) ((dir)->i_nlink >= EXT3_LINK_MAX)
+#define EXT3_DIR_LINK_EMPTY(dir) ((dir)->i_nlink == 2)
+#endif
+
+/* Legal values for the dx_root hash_version field: */
+
+#define DX_HASH_HALF_MD4	1
+
+extern __u32 ext3_make_halfMD4_hash(const char *p, int len);
 
 #ifdef __KERNEL__
 /*
@@ -631,6 +654,7 @@
 extern unsigned long ext3_count_free_inodes (struct super_block *);
 extern void ext3_check_inodes_bitmap (struct super_block *);
 extern unsigned long ext3_count_free (struct buffer_head *, unsigned);
+
 
 /* inode.c */
 extern struct buffer_head * ext3_getblk (handle_t *, struct inode *, long, int, int *);
diff -Nru a/include/linux/ext3_jbd.h b/include/linux/ext3_jbd.h
--- a/include/linux/ext3_jbd.h	Wed Aug 28 07:37:36 2002
+++ b/include/linux/ext3_jbd.h	Wed Aug 28 07:37:36 2002
@@ -63,6 +63,8 @@
 
 #define EXT3_RESERVE_TRANS_BLOCKS	12
 
+#define EXT3_INDEX_EXTRA_TRANS_BLOCKS	8
+
 int
 ext3_mark_iloc_dirty(handle_t *handle, 
 		     struct inode *inode,
diff -Nru a/include/linux/fs.h b/include/linux/fs.h
--- a/include/linux/fs.h	Wed Aug 28 07:37:36 2002
+++ b/include/linux/fs.h	Wed Aug 28 07:37:37 2002
@@ -655,7 +655,6 @@
 
 	struct list_head	s_dirty;	/* dirty inodes */
 	struct list_head	s_io;		/* parked for writeback */
-	struct list_head	s_locked_inodes;/* inodes being synced */
 	struct list_head	s_anon;		/* anonymous dentries for (nfs) exporting */
 	struct list_head	s_files;
 
diff -Nru a/include/linux/gfp.h b/include/linux/gfp.h
--- a/include/linux/gfp.h	Wed Aug 28 07:37:36 2002
+++ b/include/linux/gfp.h	Wed Aug 28 07:37:36 2002
@@ -40,7 +40,7 @@
  * virtual kernel addresses to the allocated page(s).
  */
 extern struct page * FASTCALL(_alloc_pages(unsigned int gfp_mask, unsigned int order));
-extern struct page * FASTCALL(__alloc_pages(unsigned int gfp_mask, unsigned int order, zonelist_t *zonelist));
+extern struct page * FASTCALL(__alloc_pages(unsigned int gfp_mask, unsigned int order, struct zonelist *zonelist));
 extern struct page * alloc_pages_node(int nid, unsigned int gfp_mask, unsigned int order);
 
 static inline struct page * alloc_pages(unsigned int gfp_mask, unsigned int order)
diff -Nru a/include/linux/kernel.h b/include/linux/kernel.h
--- a/include/linux/kernel.h	Wed Aug 28 07:37:36 2002
+++ b/include/linux/kernel.h	Wed Aug 28 07:37:36 2002
@@ -7,6 +7,10 @@
 
 #ifdef __KERNEL__
 
+#if __GNUC__ <= 2 && __GNUC_MINOR__ < 95
+#define __func__ __FUNCTION__
+#endif
+
 #include <stdarg.h>
 #include <linux/linkage.h>
 #include <linux/stddef.h>
diff -Nru a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h	Wed Aug 28 07:37:36 2002
+++ b/include/linux/mm.h	Wed Aug 28 07:37:36 2002
@@ -157,7 +157,7 @@
 	struct address_space *mapping;	/* The inode (or ...) we belong to. */
 	unsigned long index;		/* Our offset within mapping. */
 	struct list_head lru;		/* Pageout list, eg. active_list;
-					   protected by pagemap_lru_lock !! */
+					   protected by zone->lru_lock !! */
 	union {
 		struct pte_chain * chain;	/* Reverse pte mapping pointer.
 					 * protected by PG_chainlock */
@@ -182,6 +182,12 @@
 };
 
 /*
+ * FIXME: take this include out, include page-flags.h in
+ * files which need it (119 of them)
+ */
+#include <linux/page-flags.h>
+
+/*
  * Methods to modify the page usage count.
  *
  * What counts for a page usage:
@@ -198,14 +204,16 @@
 #define put_page_testzero(p) 	atomic_dec_and_test(&(p)->count)
 #define page_count(p)		atomic_read(&(p)->count)
 #define set_page_count(p,v) 	atomic_set(&(p)->count, v)
+
 extern void FASTCALL(__page_cache_release(struct page *));
-#define put_page(p)							\
-	do {								\
-		if (!PageReserved(p) && put_page_testzero(p))		\
-			__page_cache_release(p);			\
-	} while (0)
 void FASTCALL(__free_pages_ok(struct page *page, unsigned int order));
 
+static inline void put_page(struct page *page)
+{
+	if (!PageReserved(page) && put_page_testzero(page))
+		__page_cache_release(page);
+}
+
 /*
  * Multiple processes may "see" the same page. E.g. for untouched
  * mappings of /dev/null, all processes see the same page full of
@@ -256,22 +264,16 @@
  */
 
 /*
- * FIXME: take this include out, include page-flags.h in
- * files which need it (119 of them)
- */
-#include <linux/page-flags.h>
-
-/*
  * The zone field is never updated after free_area_init_core()
  * sets it, so none of the operations on it need to be atomic.
  */
 #define NODE_SHIFT 4
 #define ZONE_SHIFT (BITS_PER_LONG - 8)
 
-struct zone_struct;
-extern struct zone_struct *zone_table[];
+struct zone;
+extern struct zone *zone_table[];
 
-static inline zone_t *page_zone(struct page *page)
+static inline struct zone *page_zone(struct page *page)
 {
 	return zone_table[page->flags >> ZONE_SHIFT];
 }
@@ -310,8 +312,8 @@
 #else /* CONFIG_HIGHMEM || WANT_PAGE_VIRTUAL */
 
 #define page_address(page)						\
-	__va( (((page) - page_zone(page)->zone_mem_map) << PAGE_SHIFT)	\
-			+ page_zone(page)->zone_start_paddr)
+	__va( ( ((page) - page_zone(page)->zone_mem_map)		\
+			+ page_zone(page)->zone_start_pfn) << PAGE_SHIFT)
 
 #endif /* CONFIG_HIGHMEM || WANT_PAGE_VIRTUAL */
 
@@ -392,7 +394,7 @@
 
 extern void free_area_init(unsigned long * zones_size);
 extern void free_area_init_node(int nid, pg_data_t *pgdat, struct page *pmap,
-	unsigned long * zones_size, unsigned long zone_start_paddr, 
+	unsigned long * zones_size, unsigned long zone_start_pfn, 
 	unsigned long *zholes_size);
 extern void mem_init(void);
 extern void show_mem(void);
@@ -449,7 +451,6 @@
 		return 0;
 }
 
-struct zone_t;
 /* filemap.c */
 extern unsigned long page_unuse(struct page *);
 extern void truncate_inode_pages(struct address_space *, loff_t);
diff -Nru a/include/linux/mm_inline.h b/include/linux/mm_inline.h
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/include/linux/mm_inline.h	Wed Aug 28 07:37:38 2002
@@ -0,0 +1,40 @@
+
+static inline void
+add_page_to_active_list(struct zone *zone, struct page *page)
+{
+	list_add(&page->lru, &zone->active_list);
+	zone->nr_active++;
+}
+
+static inline void
+add_page_to_inactive_list(struct zone *zone, struct page *page)
+{
+	list_add(&page->lru, &zone->inactive_list);
+	zone->nr_inactive++;
+}
+
+static inline void
+del_page_from_active_list(struct zone *zone, struct page *page)
+{
+	list_del(&page->lru);
+	zone->nr_active--;
+}
+
+static inline void
+del_page_from_inactive_list(struct zone *zone, struct page *page)
+{
+	list_del(&page->lru);
+	zone->nr_inactive--;
+}
+
+static inline void
+del_page_from_lru(struct zone *zone, struct page *page)
+{
+	list_del(&page->lru);
+	if (PageActive(page)) {
+		ClearPageActive(page);
+		zone->nr_active--;
+	} else {
+		zone->nr_inactive--;
+	}
+}
diff -Nru a/include/linux/mmzone.h b/include/linux/mmzone.h
--- a/include/linux/mmzone.h	Wed Aug 28 07:37:36 2002
+++ b/include/linux/mmzone.h	Wed Aug 28 07:37:36 2002
@@ -8,6 +8,8 @@
 #include <linux/spinlock.h>
 #include <linux/list.h>
 #include <linux/wait.h>
+#include <linux/cache.h>
+#include <asm/atomic.h>
 
 /*
  * Free memory management - zoned buddy allocator.
@@ -27,6 +29,21 @@
 struct pglist_data;
 
 /*
+ * zone->lock and zone->lru_lock are two of the hottest locks in the kernel.
+ * So add a wild amount of padding here to ensure that they fall into separate
+ * cachelines.  There are very few zone structures in the machine, so space
+ * consumption is not a concern here.
+ */
+#if defined(CONFIG_SMP)
+struct zone_padding {
+	int x;
+} ____cacheline_maxaligned_in_smp;
+#define ZONE_PADDING(name)	struct zone_padding name;
+#else
+#define ZONE_PADDING(name)
+#endif
+
+/*
  * On machines where it is needed (eg PCs) we divide physical memory
  * into multiple physical zones. On a PC we have 3 zones:
  *
@@ -34,7 +51,8 @@
  * ZONE_NORMAL	16-896 MB	direct mapped by the kernel
  * ZONE_HIGHMEM	 > 896 MB	only page cache and user processes
  */
-typedef struct zone_struct {
+
+struct zone {
 	/*
 	 * Commonly accessed fields:
 	 */
@@ -43,6 +61,17 @@
 	unsigned long		pages_min, pages_low, pages_high;
 	int			need_balance;
 
+	ZONE_PADDING(_pad1_)
+
+	spinlock_t		lru_lock;	
+	struct list_head	active_list;
+	struct list_head	inactive_list;
+	atomic_t		refill_counter;
+	unsigned long		nr_active;
+	unsigned long		nr_inactive;
+
+	ZONE_PADDING(_pad2_)
+
 	/*
 	 * free areas of different sizes
 	 */
@@ -81,7 +110,8 @@
 	 */
 	struct pglist_data	*zone_pgdat;
 	struct page		*zone_mem_map;
-	unsigned long		zone_start_paddr;
+	/* zone_start_pfn == zone_start_paddr >> PAGE_SHIFT */
+	unsigned long		zone_start_pfn;
 	unsigned long		zone_start_mapnr;
 
 	/*
@@ -89,7 +119,7 @@
 	 */
 	char			*name;
 	unsigned long		size;
-} zone_t;
+} ____cacheline_maxaligned_in_smp;
 
 #define ZONE_DMA		0
 #define ZONE_NORMAL		1
@@ -107,16 +137,16 @@
  * so despite the zonelist table being relatively big, the cache
  * footprint of this construct is very small.
  */
-typedef struct zonelist_struct {
-	zone_t * zones [MAX_NR_ZONES+1]; // NULL delimited
-} zonelist_t;
+struct zonelist {
+	struct zone *zones[MAX_NR_ZONES+1]; // NULL delimited
+};
 
 #define GFP_ZONEMASK	0x0f
 
 /*
  * The pg_data_t structure is used in machines with CONFIG_DISCONTIGMEM
  * (mostly NUMA machines?) to denote a higher-level memory zone than the
- * zone_struct denotes.
+ * zone denotes.
  *
  * On NUMA machines, each NUMA node would have a pg_data_t to describe
  * it's memory layout.
@@ -126,13 +156,13 @@
  */
 struct bootmem_data;
 typedef struct pglist_data {
-	zone_t node_zones[MAX_NR_ZONES];
-	zonelist_t node_zonelists[GFP_ZONEMASK+1];
+	struct zone node_zones[MAX_NR_ZONES];
+	struct zonelist node_zonelists[GFP_ZONEMASK+1];
 	int nr_zones;
 	struct page *node_mem_map;
 	unsigned long *valid_addr_bitmap;
 	struct bootmem_data *bdata;
-	unsigned long node_start_paddr;
+	unsigned long node_start_pfn;
 	unsigned long node_start_mapnr;
 	unsigned long node_size;
 	int node_id;
@@ -142,7 +172,8 @@
 extern int numnodes;
 extern pg_data_t *pgdat_list;
 
-static inline int memclass(zone_t *pgzone, zone_t *classzone)
+static inline int
+memclass(struct zone *pgzone, struct zone *classzone)
 {
 	if (pgzone->zone_pgdat != classzone->zone_pgdat)
 		return 0;
@@ -156,10 +187,10 @@
  * prototypes for the discontig memory code.
  */
 struct page;
-extern void show_free_areas_core(pg_data_t *pgdat);
-extern void free_area_init_core(int nid, pg_data_t *pgdat, struct page **gmap,
+void free_area_init_core(int nid, pg_data_t *pgdat, struct page **gmap,
   unsigned long *zones_size, unsigned long paddr, unsigned long *zholes_size,
   struct page *pmap);
+void get_zone_counts(unsigned long *active, unsigned long *inactive);
 
 extern pg_data_t contig_page_data;
 
@@ -181,7 +212,7 @@
  * next_zone - helper magic for for_each_zone()
  * Thanks to William Lee Irwin III for this piece of ingenuity.
  */
-static inline zone_t * next_zone(zone_t * zone)
+static inline struct zone *next_zone(struct zone *zone)
 {
 	pg_data_t *pgdat = zone->zone_pgdat;
 
@@ -198,7 +229,7 @@
 
 /**
  * for_each_zone - helper macro to iterate over all memory zones
- * @zone - pointer to zone_t variable
+ * @zone - pointer to struct zone variable
  *
  * The user only needs to declare the zone variable, for_each_zone
  * fills it in. This basically means for_each_zone() is an
@@ -206,7 +237,7 @@
  *
  * for (pgdat = pgdat_list; pgdat; pgdat = pgdat->node_next)
  * 	for (i = 0; i < MAX_NR_ZONES; ++i) {
- * 		zone_t * z = pgdat->node_zones + i;
+ * 		struct zone * z = pgdat->node_zones + i;
  * 		...
  * 	}
  * }
diff -Nru a/include/linux/page-flags.h b/include/linux/page-flags.h
--- a/include/linux/page-flags.h	Wed Aug 28 07:37:36 2002
+++ b/include/linux/page-flags.h	Wed Aug 28 07:37:36 2002
@@ -28,7 +28,7 @@
  *
  * Note that the referenced bit, the page->lru list_head and the active,
  * inactive_dirty and inactive_clean lists are protected by the
- * pagemap_lru_lock, and *NOT* by the usual PG_locked bit!
+ * zone->lru_lock, and *NOT* by the usual PG_locked bit!
  *
  * PG_error is set to indicate that an I/O error occurred on this page.
  *
@@ -52,7 +52,7 @@
 #define PG_referenced		 2
 #define PG_uptodate		 3
 
-#define PG_dirty_dontuse	 4
+#define PG_dirty	 	 4
 #define PG_lru			 5
 #define PG_active		 6
 #define PG_slab			 7	/* slab debug (Suparna wants this) */
@@ -76,8 +76,6 @@
 	unsigned long nr_dirty;
 	unsigned long nr_writeback;
 	unsigned long nr_pagecache;
-	unsigned long nr_active;	/* on active_list LRU */
-	unsigned long nr_inactive;	/* on inactive_list LRU */
 	unsigned long nr_page_table_pages;
 	unsigned long nr_reverse_maps;
 } ____cacheline_aligned_in_smp page_states[NR_CPUS];
@@ -122,37 +120,11 @@
 #define SetPageUptodate(page)	set_bit(PG_uptodate, &(page)->flags)
 #define ClearPageUptodate(page)	clear_bit(PG_uptodate, &(page)->flags)
 
-#define PageDirty(page)		test_bit(PG_dirty_dontuse, &(page)->flags)
-#define SetPageDirty(page)						\
-	do {								\
-		if (!test_and_set_bit(PG_dirty_dontuse,			\
-					&(page)->flags))		\
-			inc_page_state(nr_dirty);			\
-	} while (0)
-#define TestSetPageDirty(page)						\
-	({								\
-		int ret;						\
-		ret = test_and_set_bit(PG_dirty_dontuse,		\
-				&(page)->flags);			\
-		if (!ret)						\
-			inc_page_state(nr_dirty);			\
-		ret;							\
-	})
-#define ClearPageDirty(page)						\
-	do {								\
-		if (test_and_clear_bit(PG_dirty_dontuse,		\
-				&(page)->flags))			\
-			dec_page_state(nr_dirty);			\
-	} while (0)
-#define TestClearPageDirty(page)					\
-	({								\
-		int ret;						\
-		ret = test_and_clear_bit(PG_dirty_dontuse,		\
-				&(page)->flags);			\
-		if (ret)						\
-			dec_page_state(nr_dirty);			\
-		ret;							\
-	})
+#define PageDirty(page)		test_bit(PG_dirty, &(page)->flags)
+#define SetPageDirty(page)	set_bit(PG_dirty, &(page)->flags)
+#define TestSetPageDirty(page)	test_and_set_bit(PG_dirty, &(page)->flags)
+#define ClearPageDirty(page)	clear_bit(PG_dirty, &(page)->flags)
+#define TestClearPageDirty(page) test_and_clear_bit(PG_dirty, &(page)->flags)
 
 #define SetPageLRU(page)	set_bit(PG_lru, &(page)->flags)
 #define PageLRU(page)		test_bit(PG_lru, &(page)->flags)
@@ -163,6 +135,7 @@
 #define SetPageActive(page)	set_bit(PG_active, &(page)->flags)
 #define ClearPageActive(page)	clear_bit(PG_active, &(page)->flags)
 #define TestClearPageActive(page) test_and_clear_bit(PG_active, &(page)->flags)
+#define TestSetPageActive(page) test_and_set_bit(PG_active, &(page)->flags)
 
 #define PageSlab(page)		test_bit(PG_slab, &(page)->flags)
 #define SetPageSlab(page)	set_bit(PG_slab, &(page)->flags)
@@ -265,5 +238,12 @@
  */
 extern struct address_space swapper_space;
 #define PageSwapCache(page) ((page)->mapping == &swapper_space)
+
+int test_clear_page_dirty(struct page *page);
+
+static inline void clear_page_dirty(struct page *page)
+{
+	test_clear_page_dirty(page);
+}
 
 #endif	/* PAGE_FLAGS_H */
diff -Nru a/include/linux/pagemap.h b/include/linux/pagemap.h
--- a/include/linux/pagemap.h	Wed Aug 28 07:37:36 2002
+++ b/include/linux/pagemap.h	Wed Aug 28 07:37:36 2002
@@ -22,13 +22,9 @@
 #define PAGE_CACHE_MASK		PAGE_MASK
 #define PAGE_CACHE_ALIGN(addr)	(((addr)+PAGE_CACHE_SIZE-1)&PAGE_CACHE_MASK)
 
-#define page_cache_get(x)	get_page(x)
-
-static inline void page_cache_release(struct page *page)
-{
-	if (!PageReserved(page) && put_page_testzero(page))
-		__page_cache_release(page);
-}
+#define page_cache_get(page)		get_page(page)
+#define page_cache_release(page)	put_page(page)
+void release_pages(struct page **pages, int nr);
 
 static inline struct page *page_cache_alloc(struct address_space *x)
 {
diff -Nru a/include/linux/pagevec.h b/include/linux/pagevec.h
--- a/include/linux/pagevec.h	Wed Aug 28 07:37:38 2002
+++ b/include/linux/pagevec.h	Wed Aug 28 07:37:38 2002
@@ -21,6 +21,7 @@
 void __pagevec_lru_del(struct pagevec *pvec);
 void lru_add_drain(void);
 void pagevec_deactivate_inactive(struct pagevec *pvec);
+void pagevec_strip(struct pagevec *pvec);
 
 static inline void pagevec_init(struct pagevec *pvec)
 {
diff -Nru a/include/linux/preempt.h b/include/linux/preempt.h
--- a/include/linux/preempt.h	Wed Aug 28 07:37:36 2002
+++ b/include/linux/preempt.h	Wed Aug 28 07:37:36 2002
@@ -48,22 +48,12 @@
 	preempt_check_resched(); \
 } while (0)
 
-#define inc_preempt_count_non_preempt()	do { } while (0)
-#define dec_preempt_count_non_preempt()	do { } while (0)
-
 #else
 
 #define preempt_disable()		do { } while (0)
 #define preempt_enable_no_resched()	do { } while (0)
 #define preempt_enable()		do { } while (0)
 #define preempt_check_resched()		do { } while (0)
-
-/*
- * Sometimes we want to increment the preempt count, but we know that it's
- * already incremented if the kernel is compiled for preemptibility.
- */
-#define inc_preempt_count_non_preempt()	inc_preempt_count()
-#define dec_preempt_count_non_preempt()	dec_preempt_count()
 
 #endif
 
diff -Nru a/include/linux/rwsem-spinlock.h b/include/linux/rwsem-spinlock.h
--- a/include/linux/rwsem-spinlock.h	Wed Aug 28 07:37:37 2002
+++ b/include/linux/rwsem-spinlock.h	Wed Aug 28 07:37:37 2002
@@ -46,6 +46,14 @@
 #define __RWSEM_DEBUG_INIT	/* */
 #endif
 
+#ifdef CONFIG_DEBUG_SPINLOCK
+#define assert_rwsem_held_for_write(rwsem)	BUG_ON(__down_read_trylock(sem))
+#define assert_rwsem_held_for_read(rwsem)	BUG_ON(__down_write_trylock(rwsem))
+#else
+#define assert_rwsem_held_for_write(rwsem)	do { } while(0)
+#define assert_rwsem_held_for_read(rwsem)	do { } while(0)
+#endif
+
 #define __RWSEM_INITIALIZER(name) \
 { 0, SPIN_LOCK_UNLOCKED, LIST_HEAD_INIT((name).wait_list) __RWSEM_DEBUG_INIT }
 
diff -Nru a/include/linux/rwsem.h b/include/linux/rwsem.h
--- a/include/linux/rwsem.h	Wed Aug 28 07:37:37 2002
+++ b/include/linux/rwsem.h	Wed Aug 28 07:37:37 2002
@@ -7,6 +7,7 @@
 #ifndef _LINUX_RWSEM_H
 #define _LINUX_RWSEM_H
 
+#include <linux/config.h>
 #include <linux/linkage.h>
 
 #define RWSEM_DEBUG 0
diff -Nru a/include/linux/sched.h b/include/linux/sched.h
--- a/include/linux/sched.h	Wed Aug 28 07:37:36 2002
+++ b/include/linux/sched.h	Wed Aug 28 07:37:36 2002
@@ -405,6 +405,7 @@
 #define PF_FREEZE	0x00010000	/* this task should be frozen for suspend */
 #define PF_IOTHREAD	0x00020000	/* this thread is needed for doing I/O to swap */
 #define PF_FROZEN	0x00040000	/* frozen for system suspend */
+#define PF_SYNC		0x00080000	/* performing fsync(), etc */
 
 /*
  * Ptrace flags
diff -Nru a/include/linux/spinlock.h b/include/linux/spinlock.h
--- a/include/linux/spinlock.h	Wed Aug 28 07:37:37 2002
+++ b/include/linux/spinlock.h	Wed Aug 28 07:37:37 2002
@@ -78,7 +78,19 @@
 #define _raw_write_lock(lock)	(void)(lock)
 #define _raw_write_unlock(lock)	do { } while(0)
 
-#endif /* !SMP */
+#endif /* !CONFIG_SMP */
+
+/*
+ * Simple lock assertions for debugging and documenting where locks need
+ * to be held.
+ */
+#if defined(CONFIG_DEBUG_SPINLOCK) && defined(CONFIG_SMP)
+#define assert_locked(lock)		BUG_ON(!spin_is_locked(lock))
+#define assert_rw_locked(lock)		BUG_ON(!rwlock_is_locked(lock))
+#else
+#define assert_locked(lock)		do { } while(0)
+#define assert_rw_locked(lock)		do { } while(0)
+#endif /* CONFIG_DEBUG_SPINLOCK && CONFIG_SMP */
 
 /*
  * Define the various spin_lock and rw_lock methods.  Note we define these
diff -Nru a/include/linux/swap.h b/include/linux/swap.h
--- a/include/linux/swap.h	Wed Aug 28 07:37:36 2002
+++ b/include/linux/swap.h	Wed Aug 28 07:37:36 2002
@@ -139,7 +139,7 @@
 struct vm_area_struct;
 struct sysinfo;
 struct address_space;
-struct zone_t;
+struct zone;
 
 /* linux/mm/rmap.c */
 extern int FASTCALL(page_referenced(struct page *));
@@ -163,7 +163,7 @@
 
 /* linux/mm/vmscan.c */
 extern wait_queue_head_t kswapd_wait;
-extern int FASTCALL(try_to_free_pages(zone_t *, unsigned int, unsigned int));
+extern int try_to_free_pages(struct zone *, unsigned int, unsigned int);
 
 /* linux/mm/page_io.c */
 int swap_readpage(struct file *file, struct page *page);
@@ -182,6 +182,7 @@
 extern int move_from_swap_cache(struct page *page, unsigned long index,
 		struct address_space *mapping);
 extern void free_page_and_swap_cache(struct page *page);
+extern void free_pages_and_swap_cache(struct page **pages, int nr);
 extern struct page * lookup_swap_cache(swp_entry_t);
 extern struct page * read_swap_cache_async(swp_entry_t);
 
@@ -209,54 +210,7 @@
 asmlinkage long sys_swapoff(const char *);
 asmlinkage long sys_swapon(const char *, int);
 
-extern spinlock_t _pagemap_lru_lock;
-
 extern void FASTCALL(mark_page_accessed(struct page *));
-
-/*
- * List add/del helper macros. These must be called
- * with the pagemap_lru_lock held!
- */
-#define DEBUG_LRU_PAGE(page)			\
-do {						\
-	if (!PageLRU(page))			\
-		BUG();				\
-	if (PageActive(page))			\
-		BUG();				\
-} while (0)
-
-#define __add_page_to_active_list(page)		\
-do {						\
-	list_add(&(page)->lru, &active_list);	\
-	inc_page_state(nr_active);		\
-} while (0)
-
-#define add_page_to_active_list(page)		\
-do {						\
-	DEBUG_LRU_PAGE(page);			\
-	SetPageActive(page);			\
-	__add_page_to_active_list(page);	\
-} while (0)
-
-#define add_page_to_inactive_list(page)		\
-do {						\
-	DEBUG_LRU_PAGE(page);			\
-	list_add(&(page)->lru, &inactive_list);	\
-	inc_page_state(nr_inactive);		\
-} while (0)
-
-#define del_page_from_active_list(page)		\
-do {						\
-	list_del(&(page)->lru);			\
-	ClearPageActive(page);			\
-	dec_page_state(nr_active);		\
-} while (0)
-
-#define del_page_from_inactive_list(page)	\
-do {						\
-	list_del(&(page)->lru);			\
-	dec_page_state(nr_inactive);		\
-} while (0)
 
 extern spinlock_t swaplock;
 
diff -Nru a/include/linux/writeback.h b/include/linux/writeback.h
--- a/include/linux/writeback.h	Wed Aug 28 07:37:36 2002
+++ b/include/linux/writeback.h	Wed Aug 28 07:37:36 2002
@@ -72,4 +72,13 @@
 				   read-only. */
 
 
+/*
+ * Tell the writeback paths that they are being called for a "data integrity"
+ * operation such as fsync().
+ */
+static inline int called_for_sync(void)
+{
+	return current->flags & PF_SYNC;
+}
+
 #endif		/* WRITEBACK_H */
diff -Nru a/kernel/acct.c b/kernel/acct.c
--- a/kernel/acct.c	Wed Aug 28 07:37:37 2002
+++ b/kernel/acct.c	Wed Aug 28 07:37:37 2002
@@ -160,6 +160,8 @@
 {
 	struct file *old_acct = NULL;
 
+	assert_locked(&acct_globals.lock);
+
 	if (acct_globals.file) {
 		old_acct = acct_globals.file;
 		del_timer(&acct_globals.timer);
diff -Nru a/kernel/ksyms.c b/kernel/ksyms.c
--- a/kernel/ksyms.c	Wed Aug 28 07:37:36 2002
+++ b/kernel/ksyms.c	Wed Aug 28 07:37:36 2002
@@ -133,6 +133,7 @@
 EXPORT_SYMBOL(get_user_pages);
 
 /* filesystem internal functions */
+EXPORT_SYMBOL_GPL(def_blk_aops);
 EXPORT_SYMBOL(def_blk_fops);
 EXPORT_SYMBOL(update_atime);
 EXPORT_SYMBOL(get_fs_type);
diff -Nru a/kernel/printk.c b/kernel/printk.c
--- a/kernel/printk.c	Wed Aug 28 07:37:37 2002
+++ b/kernel/printk.c	Wed Aug 28 07:37:37 2002
@@ -353,6 +353,8 @@
 	unsigned long cur_index, start_print;
 	static int msg_level = -1;
 
+	assert_sem_held(&console_sem);
+
 	if (((long)(start - end)) > 0)
 		BUG();
 
diff -Nru a/kernel/suspend.c b/kernel/suspend.c
--- a/kernel/suspend.c	Wed Aug 28 07:37:36 2002
+++ b/kernel/suspend.c	Wed Aug 28 07:37:36 2002
@@ -468,31 +468,33 @@
 {
 	int chunk_size;
 	int nr_copy_pages = 0;
-	int loop;
+	int pfn;
+	struct page *page;
 	
 	if (max_mapnr != num_physpages)
 		panic("mapnr is not expected");
-	for (loop = 0; loop < max_mapnr; loop++) {
-		if (PageHighMem(mem_map+loop))
+	for (pfn = 0; pfn < max_mapnr; pfn++) {
+		page = pfn_to_page(pfn);
+		if (PageHighMem(page))
 			panic("Swsusp not supported on highmem boxes. Send 1GB of RAM to <pavel@ucw.cz> and try again ;-).");
-		if (!PageReserved(mem_map+loop)) {
-			if (PageNosave(mem_map+loop))
+		if (!PageReserved(page)) {
+			if (PageNosave(page))
 				continue;
 
-			if ((chunk_size=is_head_of_free_region(mem_map+loop))!=0) {
-				loop += chunk_size - 1;
+			if ((chunk_size=is_head_of_free_region(page))!=0) {
+				pfn += chunk_size - 1;
 				continue;
 			}
-		} else if (PageReserved(mem_map+loop)) {
-			BUG_ON (PageNosave(mem_map+loop));
+		} else if (PageReserved(page)) {
+			BUG_ON (PageNosave(page));
 
 			/*
 			 * Just copy whole code segment. Hopefully it is not that big.
 			 */
-			if (ADDRESS(loop) >= (unsigned long)
-				&__nosave_begin && ADDRESS(loop) < 
+			if (ADDRESS(pfn) >= (unsigned long)
+				&__nosave_begin && ADDRESS(pfn) < 
 				(unsigned long)&__nosave_end) {
-				PRINTK("[nosave %x]", ADDRESS(loop));
+				PRINTK("[nosave %x]", ADDRESS(pfn));
 				continue;
 			}
 			/* Hmm, perhaps copying all reserved pages is not too healthy as they may contain 
@@ -501,7 +503,7 @@
 
 		nr_copy_pages++;
 		if (pagedir_p) {
-			pagedir_p->orig_address = ADDRESS(loop);
+			pagedir_p->orig_address = ADDRESS(pfn);
 			copy_page(pagedir_p->address, pagedir_p->orig_address);
 			pagedir_p++;
 		}
diff -Nru a/mm/bootmem.c b/mm/bootmem.c
--- a/mm/bootmem.c	Wed Aug 28 07:37:37 2002
+++ b/mm/bootmem.c	Wed Aug 28 07:37:37 2002
@@ -318,10 +318,12 @@
 	return(init_bootmem_core(&contig_page_data, start, 0, pages));
 }
 
+#ifndef CONFIG_HAVE_ARCH_BOOTMEM_NODE
 void __init reserve_bootmem (unsigned long addr, unsigned long size)
 {
 	reserve_bootmem_core(contig_page_data.bdata, addr, size);
 }
+#endif /* !CONFIG_HAVE_ARCH_BOOTMEM_NODE */
 
 void __init free_bootmem (unsigned long addr, unsigned long size)
 {
diff -Nru a/mm/filemap.c b/mm/filemap.c
--- a/mm/filemap.c	Wed Aug 28 07:37:37 2002
+++ b/mm/filemap.c	Wed Aug 28 07:37:37 2002
@@ -61,7 +61,6 @@
  *      ->inode_lock		(__mark_inode_dirty)
  *        ->sb_lock		(fs/fs-writeback.c)
  */
-spinlock_t _pagemap_lru_lock __cacheline_aligned_in_smp = SPIN_LOCK_UNLOCKED;
 
 /*
  * Remove a page from the page cache and free it. Caller has to make
@@ -182,7 +181,7 @@
 	if (PagePrivate(page))
 		do_invalidatepage(page, 0);
 
-	ClearPageDirty(page);
+	clear_page_dirty(page);
 	ClearPageUptodate(page);
 	remove_from_page_cache(page);
 	page_cache_release(page);
@@ -281,7 +280,7 @@
 	for (curr = head->next; curr != head; curr = curr->next) {
 		page = list_entry(curr, struct page, list);
 		if (page->index > start)
-			ClearPageDirty(page);
+			clear_page_dirty(page);
 	}
 }
 
@@ -349,7 +348,7 @@
 		} else
 			unlocked = 0;
 
-		ClearPageDirty(page);
+		clear_page_dirty(page);
 		ClearPageUptodate(page);
 	}
 
@@ -465,31 +464,38 @@
 			SetPageReferenced(page);
 	}
 
-	/* Set the page dirty again, unlock */
-	set_page_dirty(page);
 	unlock_page(page);
-	return 0;
+	return -EAGAIN;		/* It will be set dirty again */
 }
 EXPORT_SYMBOL(fail_writepage);
 
 /**
- *  filemap_fdatawrite - walk the list of dirty pages of the given address space
- *                      and writepage() all of them.
- *
- *  @mapping: address space structure to write
+ * filemap_fdatawrite - start writeback against all of a mapping's dirty pages
+ * @mapping: address space structure to write
  *
+ * This is a "data integrity" operation, as opposed to a regular memory
+ * cleansing writeback.  The difference between these two operations is that
+ * if a dirty page/buffer is encountered, it must be waited upon, and not just
+ * skipped over.
+ *
+ * The PF_SYNC flag is set across this operation and the various functions
+ * which care about this distinction must use called_for_sync() to find out
+ * which behaviour they should implement.
  */
 int filemap_fdatawrite(struct address_space *mapping)
 {
-	return do_writepages(mapping, NULL);
+	int ret;
+
+	current->flags |= PF_SYNC;
+	ret = do_writepages(mapping, NULL);
+	current->flags &= ~PF_SYNC;
+	return ret;
 }
 
 /**
- *      filemap_fdatawait - walk the list of locked pages of the given address space
- *     	and wait for all of them.
- * 
- *      @mapping: address space structure to wait for
- *
+ * filemap_fdatawait - walk the list of locked pages of the given address
+ *                     space and wait for all of them.
+ * @mapping: address space structure to wait for
  */
 int filemap_fdatawait(struct address_space * mapping)
 {
@@ -498,8 +504,9 @@
 	write_lock(&mapping->page_lock);
 
         while (!list_empty(&mapping->locked_pages)) {
-		struct page *page = list_entry(mapping->locked_pages.next, struct page, list);
+		struct page *page;
 
+		page = list_entry(mapping->locked_pages.next,struct page,list);
 		list_del(&page->list);
 		if (PageDirty(page))
 			list_add(&page->list, &mapping->dirty_pages);
@@ -550,8 +557,8 @@
 	error = radix_tree_insert(&mapping->page_tree, offset, page);
 	if (!error) {
 		SetPageLocked(page);
-		ClearPageDirty(page);
 		___add_to_page_cache(page, mapping, offset);
+		ClearPageDirty(page);
 	} else {
 		page_cache_release(page);
 	}
@@ -611,7 +618,7 @@
  */
 static inline wait_queue_head_t *page_waitqueue(struct page *page)
 {
-	const zone_t *zone = page_zone(page);
+	const struct zone *zone = page_zone(page);
 
 	return &zone->wait_table[hash_ptr(page, zone->wait_table_bits)];
 }
@@ -1029,7 +1036,53 @@
 	UPDATE_ATIME(inode);
 }
 
-int file_read_actor(read_descriptor_t * desc, struct page *page, unsigned long offset, unsigned long size)
+/*
+ * Fault a userspace page into pagetables.  Return non-zero on a fault.
+ *
+ * FIXME: this assumes that two userspace pages are always sufficient.  That's
+ * not true if PAGE_CACHE_SIZE > PAGE_SIZE.
+ */
+static inline int fault_in_pages_writeable(char *uaddr, int size)
+{
+	int ret;
+
+	/*
+	 * Writing zeroes into userspace here is OK, because we know that if
+	 * the zero gets there, we'll be overwriting it.
+	 */
+	ret = __put_user(0, uaddr);
+	if (ret == 0) {
+		char *end = uaddr + size - 1;
+
+		/*
+		 * If the page was already mapped, this will get a cache miss
+		 * for sure, so try to avoid doing it.
+		 */
+		if (((unsigned long)uaddr & PAGE_MASK) !=
+				((unsigned long)end & PAGE_MASK))
+		 	ret = __put_user(0, end);
+	}
+	return ret;
+}
+
+static inline int fault_in_pages_readable(const char *uaddr, int size)
+{
+	volatile char c;
+	int ret;
+
+	ret = __get_user(c, (char *)uaddr);
+	if (ret == 0) {
+		const char *end = uaddr + size - 1;
+
+		if (((unsigned long)uaddr & PAGE_MASK) !=
+				((unsigned long)end & PAGE_MASK))
+		 	ret = __get_user(c, (char *)end);
+	}
+	return ret;
+}
+
+int file_read_actor(read_descriptor_t *desc, struct page *page,
+			unsigned long offset, unsigned long size)
 {
 	char *kaddr;
 	unsigned long left, count = desc->count;
@@ -1037,14 +1090,29 @@
 	if (size > count)
 		size = count;
 
+	/*
+	 * Faults on the destination of a read are common, so do it before
+	 * taking the kmap.
+	 */
+	if (!fault_in_pages_writeable(desc->buf, size)) {
+		kaddr = kmap_atomic(page, KM_USER0);
+		left = __copy_to_user(desc->buf, kaddr + offset, size);
+		kunmap_atomic(kaddr, KM_USER0);
+		if (left == 0)
+			goto success;
+		printk("%s: Unexpected page fault\n", __FUNCTION__);
+	}
+
+	/* Do it the slow way */
 	kaddr = kmap(page);
 	left = __copy_to_user(desc->buf, kaddr + offset, size);
 	kunmap(page);
-	
+
 	if (left) {
 		size -= left;
 		desc->error = -EFAULT;
 	}
+success:
 	desc->count = count - size;
 	desc->written += size;
 	desc->buf += size;
@@ -1151,14 +1219,15 @@
 {
 	struct address_space *mapping = file->f_dentry->d_inode->i_mapping;
 	unsigned long max;
-	struct page_state ps;
+	unsigned long active;
+	unsigned long inactive;
 
 	if (!mapping || !mapping->a_ops || !mapping->a_ops->readpage)
 		return -EINVAL;
 
 	/* Limit it to a sane percentage of the inactive list.. */
-	get_page_state(&ps);
-	max = ps.nr_inactive / 2;
+	get_zone_counts(&active, &inactive);
+	max = inactive / 2;
 	if (nr > max)
 		nr = max;
 
@@ -1830,6 +1899,29 @@
 	}
 }
 
+static inline int
+filemap_copy_from_user(struct page *page, unsigned long offset,
+			const char *buf, unsigned bytes, int fault_expected)
+{
+	char *kaddr;
+	int left;
+
+	kaddr = kmap_atomic(page, KM_USER0);
+	left = __copy_from_user(kaddr + offset, buf, bytes);
+	kunmap_atomic(kaddr, KM_USER0);
+
+	if (left != 0) {
+		if (!fault_expected)
+			printk("%s: Unexpected page fault\n", __FUNCTION__);
+
+		/* Do it the slow way */
+		kaddr = kmap(page);
+		left = __copy_from_user(kaddr + offset, buf, bytes);
+		kunmap(page);
+	}
+	return left;
+}
+
 /*
  * Write to a file through the page cache. 
  *
@@ -1982,7 +2074,7 @@
 		unsigned long index;
 		unsigned long offset;
 		long page_fault;
-		char *kaddr;
+		int fault_expected;	/* This is just debug */
 
 		offset = (pos & (PAGE_CACHE_SIZE -1)); /* Within page */
 		index = pos >> PAGE_CACHE_SHIFT;
@@ -1996,10 +2088,7 @@
 		 * same page as we're writing to, without it being marked
 		 * up-to-date.
 		 */
-		{ volatile unsigned char dummy;
-			__get_user(dummy, buf);
-			__get_user(dummy, buf+bytes-1);
-		}
+		fault_expected = fault_in_pages_readable(buf, bytes);
 
 		page = __grab_cache_page(mapping, index, &cached_page, &lru_pvec);
 		if (!page) {
@@ -2007,22 +2096,20 @@
 			break;
 		}
 
-		kaddr = kmap(page);
 		status = a_ops->prepare_write(file, page, offset, offset+bytes);
 		if (unlikely(status)) {
 			/*
 			 * prepare_write() may have instantiated a few blocks
 			 * outside i_size.  Trim these off again.
 			 */
-			kunmap(page);
 			unlock_page(page);
 			page_cache_release(page);
 			if (pos + bytes > inode->i_size)
 				vmtruncate(inode, inode->i_size);
 			break;
 		}
-		page_fault = __copy_from_user(kaddr + offset, buf, bytes);
-		flush_dcache_page(page);
+		page_fault = filemap_copy_from_user(page, offset,
+						buf, bytes, fault_expected);
 		status = a_ops->commit_write(file, page, offset, offset+bytes);
 		if (unlikely(page_fault)) {
 			status = -EFAULT;
@@ -2037,7 +2124,6 @@
 				buf += status;
 			}
 		}
-		kunmap(page);
 		if (!PageReferenced(page))
 			SetPageReferenced(page);
 		unlock_page(page);
diff -Nru a/mm/highmem.c b/mm/highmem.c
--- a/mm/highmem.c	Wed Aug 28 07:37:36 2002
+++ b/mm/highmem.c	Wed Aug 28 07:37:36 2002
@@ -383,7 +383,7 @@
 		/*
 		 * is destination page below bounce pfn?
 		 */
-		if ((page - page_zone(page)->zone_mem_map) + (page_zone(page)->zone_start_paddr >> PAGE_SHIFT) < pfn)
+		if ((page - page_zone(page)->zone_mem_map) + (page_zone(page)->zone_start_pfn) < pfn)
 			continue;
 
 		/*
diff -Nru a/mm/msync.c b/mm/msync.c
--- a/mm/msync.c	Wed Aug 28 07:37:37 2002
+++ b/mm/msync.c	Wed Aug 28 07:37:37 2002
@@ -145,10 +145,7 @@
 			int err;
 
 			down(&inode->i_sem);
-			ret = filemap_fdatawait(inode->i_mapping);
-			err = filemap_fdatawrite(inode->i_mapping);
-			if (!ret)
-				ret = err;
+			ret = filemap_fdatawrite(inode->i_mapping);
 			if (flags & MS_SYNC) {
 				if (file->f_op && file->f_op->fsync) {
 					err = file->f_op->fsync(file, file->f_dentry, 1);
diff -Nru a/mm/numa.c b/mm/numa.c
--- a/mm/numa.c	Wed Aug 28 07:37:37 2002
+++ b/mm/numa.c	Wed Aug 28 07:37:37 2002
@@ -22,11 +22,11 @@
  * Should be invoked with paramters (0, 0, unsigned long *[], start_paddr).
  */
 void __init free_area_init_node(int nid, pg_data_t *pgdat, struct page *pmap,
-	unsigned long *zones_size, unsigned long zone_start_paddr, 
+	unsigned long *zones_size, unsigned long zone_start_pfn, 
 	unsigned long *zholes_size)
 {
 	free_area_init_core(0, &contig_page_data, &mem_map, zones_size, 
-				zone_start_paddr, zholes_size, pmap);
+				zone_start_pfn, zholes_size, pmap);
 }
 
 #endif /* !CONFIG_DISCONTIGMEM */
@@ -48,7 +48,7 @@
  * Nodes can be initialized parallely, in no particular order.
  */
 void __init free_area_init_node(int nid, pg_data_t *pgdat, struct page *pmap,
-	unsigned long *zones_size, unsigned long zone_start_paddr, 
+	unsigned long *zones_size, unsigned long zone_start_pfn, 
 	unsigned long *zholes_size)
 {
 	int i, size = 0;
@@ -57,7 +57,7 @@
 	if (mem_map == NULL)
 		mem_map = (struct page *)PAGE_OFFSET;
 
-	free_area_init_core(nid, pgdat, &discard, zones_size, zone_start_paddr,
+	free_area_init_core(nid, pgdat, &discard, zones_size, zone_start_pfn,
 					zholes_size, pmap);
 	pgdat->node_id = nid;
 
diff -Nru a/mm/page-writeback.c b/mm/page-writeback.c
--- a/mm/page-writeback.c	Wed Aug 28 07:37:36 2002
+++ b/mm/page-writeback.c	Wed Aug 28 07:37:36 2002
@@ -38,7 +38,12 @@
  * After a CPU has dirtied this many pages, balance_dirty_pages_ratelimited
  * will look to see if it needs to force writeback or throttling.
  */
-static int ratelimit_pages = 32;
+static long ratelimit_pages = 32;
+
+/*
+ * The total number of pagesin the machine.
+ */
+static long total_pages;
 
 /*
  * When balance_dirty_pages decides that the caller needs to perform some
@@ -60,17 +65,17 @@
 /*
  * Start background writeback (via pdflush) at this level
  */
-int dirty_background_ratio = 40;
+int dirty_background_ratio = 10;
 
 /*
  * The generator of dirty data starts async writeback at this level
  */
-int dirty_async_ratio = 50;
+int dirty_async_ratio = 40;
 
 /*
  * The generator of dirty data performs sync writeout at this level
  */
-int dirty_sync_ratio = 60;
+int dirty_sync_ratio = 50;
 
 /*
  * The interval between `kupdate'-style writebacks, in centiseconds
@@ -107,18 +112,17 @@
  */
 void balance_dirty_pages(struct address_space *mapping)
 {
-	const int tot = nr_free_pagecache_pages();
 	struct page_state ps;
-	int background_thresh, async_thresh, sync_thresh;
+	long background_thresh, async_thresh, sync_thresh;
 	unsigned long dirty_and_writeback;
 	struct backing_dev_info *bdi;
 
 	get_page_state(&ps);
 	dirty_and_writeback = ps.nr_dirty + ps.nr_writeback;
 
-	background_thresh = (dirty_background_ratio * tot) / 100;
-	async_thresh = (dirty_async_ratio * tot) / 100;
-	sync_thresh = (dirty_sync_ratio * tot) / 100;
+	background_thresh = (dirty_background_ratio * total_pages) / 100;
+	async_thresh = (dirty_async_ratio * total_pages) / 100;
+	sync_thresh = (dirty_sync_ratio * total_pages) / 100;
 	bdi = mapping->backing_dev_info;
 
 	if (dirty_and_writeback > sync_thresh) {
@@ -171,13 +175,14 @@
  */
 static void background_writeout(unsigned long _min_pages)
 {
-	const int tot = nr_free_pagecache_pages();
-	const int background_thresh = (dirty_background_ratio * tot) / 100;
 	long min_pages = _min_pages;
+	long background_thresh;
 	int nr_to_write;
 
 	CHECK_EMERGENCY_SYNC
 
+	background_thresh = (dirty_background_ratio * total_pages) / 100;
+
 	do {
 		struct page_state ps;
 
@@ -269,7 +274,7 @@
 
 static void set_ratelimit(void)
 {
-	ratelimit_pages = nr_free_pagecache_pages() / (num_online_cpus() * 32);
+	ratelimit_pages = total_pages / (num_online_cpus() * 32);
 	if (ratelimit_pages < 16)
 		ratelimit_pages = 16;
 	if (ratelimit_pages * PAGE_CACHE_SIZE > 4096 * 1024)
@@ -288,8 +293,29 @@
 	.next		= NULL,
 };
 
+/*
+ * If the machine has a large highmem:lowmem ratio then scale back the default
+ * dirty memory thresholds: allowing too much dirty highmem pins an excessive
+ * number of buffer_heads.
+ */
 static int __init page_writeback_init(void)
 {
+	long buffer_pages = nr_free_buffer_pages();
+	long correction;
+
+	total_pages = nr_free_pagecache_pages();
+
+	correction = (100 * 4 * buffer_pages) / total_pages;
+
+	if (correction < 100) {
+		dirty_background_ratio *= correction;
+		dirty_background_ratio /= 100;
+		dirty_async_ratio *= correction;
+		dirty_async_ratio /= 100;
+		dirty_sync_ratio *= correction;
+		dirty_sync_ratio /= 100;
+	}
+
 	init_timer(&wb_timer);
 	wb_timer.expires = jiffies + (dirty_writeback_centisecs * HZ) / 100;
 	wb_timer.data = 0;
@@ -350,10 +376,15 @@
 #if 0
 		if (!PageWriteback(page) && PageDirty(page)) {
 			lock_page(page);
-			if (!PageWriteback(page) && TestClearPageDirty(page))
-				page->mapping->a_ops->writepage(page);
-			else
+			if (!PageWriteback(page)&&test_clear_page_dirty(page)) {
+				int ret;
+
+				ret = page->mapping->a_ops->writepage(page);
+				if (ret == -EAGAIN)
+					__set_page_dirty_nobuffers(page);
+			} else {
 				unlock_page(page);
+			}
 		}
 #endif
 	}
@@ -390,11 +421,15 @@
 
 	write_lock(&mapping->page_lock);
 	list_del(&page->list);
-	if (TestClearPageDirty(page)) {
+	if (test_clear_page_dirty(page)) {
 		list_add(&page->list, &mapping->locked_pages);
 		page_cache_get(page);
 		write_unlock(&mapping->page_lock);
 		ret = mapping->a_ops->writepage(page);
+		if (ret == -EAGAIN) {
+			__set_page_dirty_nobuffers(page);
+			ret = 0;
+		}
 		if (ret == 0 && wait) {
 			wait_on_page_writeback(page);
 			if (PageError(page))
@@ -478,6 +513,8 @@
 	if (!TestSetPageDirty(page)) {
 		write_lock(&mapping->page_lock);
 		if (page->mapping) {	/* Race with truncate? */
+			if (!mapping->backing_dev_info->memory_backed)
+				inc_page_state(nr_dirty);
 			list_del(&page->list);
 			list_add(&page->list, &mapping->dirty_pages);
 		}
@@ -514,6 +551,8 @@
 		if (mapping) {
 			write_lock(&mapping->page_lock);
 			if (page->mapping) {	/* Race with truncate? */
+				if (!mapping->backing_dev_info->memory_backed)
+					inc_page_state(nr_dirty);
 				list_del(&page->list);
 				list_add(&page->list, &mapping->dirty_pages);
 			}
@@ -525,4 +564,18 @@
 }
 EXPORT_SYMBOL(__set_page_dirty_nobuffers);
 
+/*
+ * Clear a page's dirty flag, while caring for dirty memory accounting. 
+ * Returns true if the page was previously dirty.
+ */
+int test_clear_page_dirty(struct page *page)
+{
+	if (TestClearPageDirty(page)) {
+		struct address_space *mapping = page->mapping;
 
+		if (mapping && !mapping->backing_dev_info->memory_backed)
+			dec_page_state(nr_dirty);
+		return 1;
+	}
+	return 0;
+}
diff -Nru a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c	Wed Aug 28 07:37:36 2002
+++ b/mm/page_alloc.c	Wed Aug 28 07:37:36 2002
@@ -27,15 +27,13 @@
 unsigned long totalram_pages;
 unsigned long totalhigh_pages;
 int nr_swap_pages;
-LIST_HEAD(active_list);
-LIST_HEAD(inactive_list);
 pg_data_t *pgdat_list;
 
 /*
  * Used by page_zone() to look up the address of the struct zone whose
  * id is encoded in the upper bits of page->flags
  */
-zone_t *zone_table[MAX_NR_ZONES*MAX_NR_NODES];
+struct zone *zone_table[MAX_NR_ZONES*MAX_NR_NODES];
 EXPORT_SYMBOL(zone_table);
 
 static char *zone_names[MAX_NR_ZONES] = { "DMA", "Normal", "HighMem" };
@@ -46,11 +44,11 @@
 /*
  * Temporary debugging check for pages not lying within a given zone.
  */
-static inline int bad_range(zone_t *zone, struct page *page)
+static inline int bad_range(struct zone *zone, struct page *page)
 {
-	if (page - mem_map >= zone->zone_start_mapnr + zone->size)
+	if (page_to_pfn(page) >= zone->zone_start_pfn + zone->size)
 		return 1;
-	if (page - mem_map < zone->zone_start_mapnr)
+	if (page_to_pfn(page) < zone->zone_start_pfn)
 		return 1;
 	if (zone != page_zone(page))
 		return 1;
@@ -85,7 +83,7 @@
 	unsigned long index, page_idx, mask, flags;
 	free_area_t *area;
 	struct page *base;
-	zone_t *zone;
+	struct zone *zone;
 
 	KERNEL_STAT_ADD(pgfree, 1<<order);
 
@@ -93,7 +91,6 @@
 	BUG_ON(PagePrivate(page));
 	BUG_ON(page->mapping != NULL);
 	BUG_ON(PageLocked(page));
-	BUG_ON(PageLRU(page));
 	BUG_ON(PageActive(page));
 	BUG_ON(PageWriteback(page));
 	BUG_ON(page->pte.chain != NULL);
@@ -155,7 +152,8 @@
 #define MARK_USED(index, order, area) \
 	__change_bit((index) >> (1+(order)), (area)->map)
 
-static inline struct page * expand (zone_t *zone, struct page *page,
+static inline struct page *
+expand(struct zone *zone, struct page *page,
 	 unsigned long index, int low, int high, free_area_t * area)
 {
 	unsigned long size = 1 << high;
@@ -186,14 +184,14 @@
 	BUG_ON(PageActive(page));
 	BUG_ON(PageDirty(page));
 	BUG_ON(PageWriteback(page));
+	BUG_ON(page->pte.chain != NULL);
 	page->flags &= ~(1 << PG_uptodate | 1 << PG_error |
 			1 << PG_referenced | 1 << PG_arch_1 |
 			1 << PG_checked);
 	set_page_count(page, 1);
 }
 
-static FASTCALL(struct page * rmqueue(zone_t *zone, unsigned int order));
-static struct page * rmqueue(zone_t *zone, unsigned int order)
+static struct page *rmqueue(struct zone *zone, unsigned int order)
 {
 	free_area_t * area = zone->free_area + order;
 	unsigned int curr_order = order;
@@ -236,7 +234,7 @@
 #ifdef CONFIG_SOFTWARE_SUSPEND
 int is_head_of_free_region(struct page *page)
 {
-        zone_t *zone = page_zone(page);
+        struct zone *zone = page_zone(page);
         unsigned long flags;
 	int order;
 	list_t *curr;
@@ -266,7 +264,7 @@
 #endif
 
 static /* inline */ struct page *
-balance_classzone(zone_t * classzone, unsigned int gfp_mask,
+balance_classzone(struct zone* classzone, unsigned int gfp_mask,
 			unsigned int order, int * freed)
 {
 	struct page * page = NULL;
@@ -321,10 +319,12 @@
 /*
  * This is the 'heart' of the zoned buddy allocator:
  */
-struct page * __alloc_pages(unsigned int gfp_mask, unsigned int order, zonelist_t *zonelist)
+struct page *
+__alloc_pages(unsigned int gfp_mask, unsigned int order,
+		struct zonelist *zonelist)
 {
 	unsigned long min;
-	zone_t **zones, *classzone;
+	struct zone **zones, *classzone;
 	struct page * page;
 	int freed, i;
 
@@ -338,11 +338,11 @@
 	/* Go through the zonelist once, looking for a zone with enough free */
 	min = 1UL << order;
 	for (i = 0; zones[i] != NULL; i++) {
-		zone_t *z = zones[i];
+		struct zone *z = zones[i];
 
 		/* the incremental min is allegedly to discourage fallback */
 		min += z->pages_low;
-		if (z->free_pages > min) {
+		if (z->free_pages > min || z->free_pages >= z->pages_high) {
 			page = rmqueue(z, order);
 			if (page)
 				return page;
@@ -359,13 +359,13 @@
 	min = 1UL << order;
 	for (i = 0; zones[i] != NULL; i++) {
 		unsigned long local_min;
-		zone_t *z = zones[i];
+		struct zone *z = zones[i];
 
 		local_min = z->pages_min;
 		if (gfp_mask & __GFP_HIGH)
 			local_min >>= 2;
 		min += local_min;
-		if (z->free_pages > min) {
+		if (z->free_pages > min || z->free_pages >= z->pages_high) {
 			page = rmqueue(z, order);
 			if (page)
 				return page;
@@ -378,7 +378,7 @@
 	if (current->flags & (PF_MEMALLOC | PF_MEMDIE)) {
 		/* go through the zonelist yet again, ignoring mins */
 		for (i = 0; zones[i] != NULL; i++) {
-			zone_t *z = zones[i];
+			struct zone *z = zones[i];
 
 			page = rmqueue(z, order);
 			if (page)
@@ -405,10 +405,10 @@
 	/* go through the zonelist yet one more time */
 	min = 1UL << order;
 	for (i = 0; zones[i] != NULL; i++) {
-		zone_t *z = zones[i];
+		struct zone *z = zones[i];
 
 		min += z->pages_min;
-		if (z->free_pages > min) {
+		if (z->free_pages > min || z->free_pages >= z->pages_high) {
 			page = rmqueue(z, order);
 			if (page)
 				return page;
@@ -478,7 +478,7 @@
 unsigned int nr_free_pages(void)
 {
 	unsigned int sum = 0;
-	zone_t *zone;
+	struct zone *zone;
 
 	for_each_zone(zone)
 		sum += zone->free_pages;
@@ -492,9 +492,9 @@
 	unsigned int sum = 0;
 
 	for_each_pgdat(pgdat) {
-		zonelist_t *zonelist = pgdat->node_zonelists + offset;
-		zone_t **zonep = zonelist->zones;
-		zone_t *zone;
+		struct zonelist *zonelist = pgdat->node_zonelists + offset;
+		struct zone **zonep = zonelist->zones;
+		struct zone *zone;
 
 		for (zone = *zonep++; zone; zone = *zonep++) {
 			unsigned long size = zone->size;
@@ -559,13 +559,23 @@
 		ret->nr_dirty += ps->nr_dirty;
 		ret->nr_writeback += ps->nr_writeback;
 		ret->nr_pagecache += ps->nr_pagecache;
-		ret->nr_active += ps->nr_active;
-		ret->nr_inactive += ps->nr_inactive;
 		ret->nr_page_table_pages += ps->nr_page_table_pages;
 		ret->nr_reverse_maps += ps->nr_reverse_maps;
 	}
 }
 
+void get_zone_counts(unsigned long *active, unsigned long *inactive)
+{
+	struct zone *zone;
+
+	*active = 0;
+	*inactive = 0;
+	for_each_zone(zone) {
+		*active += zone->nr_active;
+		*inactive += zone->nr_inactive;
+	}
+}
+
 unsigned long get_page_cache_size(void)
 {
 	struct page_state ps;
@@ -602,8 +612,11 @@
 	pg_data_t *pgdat;
 	struct page_state ps;
 	int type;
+	unsigned long active;
+	unsigned long inactive;
 
 	get_page_state(&ps);
+	get_zone_counts(&active, &inactive);
 
 	printk("Free pages:      %6dkB (%6dkB HighMem)\n",
 		K(nr_free_pages()),
@@ -611,22 +624,28 @@
 
 	for (pgdat = pgdat_list; pgdat; pgdat = pgdat->pgdat_next)
 		for (type = 0; type < MAX_NR_ZONES; ++type) {
-			zone_t *zone = &pgdat->node_zones[type];
-			printk("Zone:%s "
-				"freepages:%6lukB "
-				"min:%6lukB "
-				"low:%6lukB " 
-				"high:%6lukB\n", 
+			struct zone *zone = &pgdat->node_zones[type];
+			printk("Zone:%s"
+				" freepages:%6lukB"
+				" min:%6lukB"
+				" low:%6lukB"
+				" high:%6lukB"
+				" active:%6lukB"
+				" inactive:%6lukB"
+				"\n",
 				zone->name,
 				K(zone->free_pages),
 				K(zone->pages_min),
 				K(zone->pages_low),
-				K(zone->pages_high));
+				K(zone->pages_high),
+				K(zone->nr_active),
+				K(zone->nr_inactive)
+				);
 		}
 
 	printk("( Active:%lu inactive:%lu dirty:%lu writeback:%lu free:%u )\n",
-		ps.nr_active,
-		ps.nr_inactive,
+		active,
+		inactive,
 		ps.nr_dirty,
 		ps.nr_writeback,
 		nr_free_pages());
@@ -634,7 +653,7 @@
 	for (pgdat = pgdat_list; pgdat; pgdat = pgdat->pgdat_next)
 		for (type = 0; type < MAX_NR_ZONES; type++) {
 			list_t *elem;
-			zone_t *zone = &pgdat->node_zones[type];
+			struct zone *zone = &pgdat->node_zones[type];
  			unsigned long nr, flags, order, total = 0;
 
 			if (!zone->size)
@@ -663,8 +682,8 @@
 	int i, j, k;
 
 	for (i = 0; i <= GFP_ZONEMASK; i++) {
-		zonelist_t *zonelist;
-		zone_t *zone;
+		struct zonelist *zonelist;
+		struct zone *zone;
 
 		zonelist = pgdat->node_zonelists + i;
 		memset(zonelist, 0, sizeof(*zonelist));
@@ -754,7 +773,7 @@
  *   - clear the memory bitmaps
  */
 void __init free_area_init_core(int nid, pg_data_t *pgdat, struct page **gmap,
-	unsigned long *zones_size, unsigned long zone_start_paddr, 
+	unsigned long *zones_size, unsigned long zone_start_pfn, 
 	unsigned long *zholes_size, struct page *lmem_map)
 {
 	unsigned long i, j;
@@ -762,13 +781,10 @@
 	unsigned long totalpages, offset, realtotalpages;
 	const unsigned long zone_required_alignment = 1UL << (MAX_ORDER-1);
 
-	BUG_ON(zone_start_paddr & ~PAGE_MASK);
-
 	totalpages = 0;
-	for (i = 0; i < MAX_NR_ZONES; i++) {
-		unsigned long size = zones_size[i];
-		totalpages += size;
-	}
+	for (i = 0; i < MAX_NR_ZONES; i++)
+		totalpages += zones_size[i];
+
 	realtotalpages = totalpages;
 	if (zholes_size)
 		for (i = 0; i < MAX_NR_ZONES; i++)
@@ -791,13 +807,13 @@
 	}
 	*gmap = pgdat->node_mem_map = lmem_map;
 	pgdat->node_size = totalpages;
-	pgdat->node_start_paddr = zone_start_paddr;
+	pgdat->node_start_pfn = zone_start_pfn;
 	pgdat->node_start_mapnr = (lmem_map - mem_map);
 	pgdat->nr_zones = 0;
 
 	offset = lmem_map - mem_map;	
 	for (j = 0; j < MAX_NR_ZONES; j++) {
-		zone_t *zone = pgdat->node_zones + j;
+		struct zone *zone = pgdat->node_zones + j;
 		unsigned long mask;
 		unsigned long size, realsize;
 
@@ -806,13 +822,19 @@
 		if (zholes_size)
 			realsize -= zholes_size[j];
 
-		printk("zone(%lu): %lu pages.\n", j, size);
+		printk("  %s zone: %lu pages\n", zone_names[j], realsize);
 		zone->size = size;
 		zone->name = zone_names[j];
-		zone->lock = SPIN_LOCK_UNLOCKED;
+		spin_lock_init(&zone->lock);
+		spin_lock_init(&zone->lru_lock);
 		zone->zone_pgdat = pgdat;
 		zone->free_pages = 0;
 		zone->need_balance = 0;
+		INIT_LIST_HEAD(&zone->active_list);
+		INIT_LIST_HEAD(&zone->inactive_list);
+		atomic_set(&zone->refill_counter, 0);
+		zone->nr_active = 0;
+		zone->nr_inactive = 0;
 		if (!size)
 			continue;
 
@@ -843,9 +865,9 @@
 
 		zone->zone_mem_map = mem_map + offset;
 		zone->zone_start_mapnr = offset;
-		zone->zone_start_paddr = zone_start_paddr;
+		zone->zone_start_pfn = zone_start_pfn;
 
-		if ((zone_start_paddr >> PAGE_SHIFT) & (zone_required_alignment-1))
+		if ((zone_start_pfn) & (zone_required_alignment-1))
 			printk("BUG: wrong zone alignment, it will crash\n");
 
 		/*
@@ -860,8 +882,12 @@
 			SetPageReserved(page);
 			INIT_LIST_HEAD(&page->list);
 			if (j != ZONE_HIGHMEM)
-				set_page_address(page, __va(zone_start_paddr));
-			zone_start_paddr += PAGE_SIZE;
+				/*
+				 * The shift left won't overflow because the
+				 * ZONE_NORMAL is below 4G.
+				 */
+				set_page_address(page, __va(zone_start_pfn << PAGE_SHIFT));
+			zone_start_pfn++;
 		}
 
 		offset += size;
diff -Nru a/mm/rmap.c b/mm/rmap.c
--- a/mm/rmap.c	Wed Aug 28 07:37:38 2002
+++ b/mm/rmap.c	Wed Aug 28 07:37:38 2002
@@ -14,7 +14,7 @@
 /*
  * Locking:
  * - the page->pte.chain is protected by the PG_chainlock bit,
- *   which nests within the pagemap_lru_lock, then the
+ *   which nests within the zone->lru_lock, then the
  *   mm->page_table_lock, and then the page lock.
  * - because swapout locking is opposite to the locking order
  *   in the page fault path, the swapout path uses trylocks
@@ -260,7 +260,7 @@
  * table entry mapping a page. Because locking order here is opposite
  * to the locking order used by the page fault path, we use trylocks.
  * Locking:
- *	pagemap_lru_lock		page_launder()
+ *	zone->lru_lock			page_launder()
  *	    page lock			page_launder(), trylock
  *		pte_chain_lock		page_launder()
  *		    mm->page_table_lock	try_to_unmap_one(), trylock
@@ -328,7 +328,7 @@
  * @page: the page to get unmapped
  *
  * Tries to remove all the page table entries which are mapping this
- * page, used in the pageout path.  Caller must hold pagemap_lru_lock
+ * page, used in the pageout path.  Caller must hold zone->lru_lock
  * and the page lock.  Return values are:
  *
  * SWAP_SUCCESS	- we succeeded in removing all mappings
diff -Nru a/mm/shmem.c b/mm/shmem.c
--- a/mm/shmem.c	Wed Aug 28 07:37:37 2002
+++ b/mm/shmem.c	Wed Aug 28 07:37:37 2002
@@ -29,6 +29,7 @@
 #include <linux/string.h>
 #include <linux/slab.h>
 #include <linux/smp_lock.h>
+#include <linux/backing-dev.h>
 #include <linux/shmem_fs.h>
 
 #include <asm/uaccess.h>
@@ -56,6 +57,11 @@
 static struct inode_operations shmem_dir_inode_operations;
 static struct vm_operations_struct shmem_vm_ops;
 
+static struct backing_dev_info shmem_backing_dev_info = {
+	.ra_pages	= 0,	/* No readahead */
+	.memory_backed	= 1,	/* Does not contribute to dirty memory */
+};
+
 LIST_HEAD (shmem_inodes);
 static spinlock_t shmem_ilock = SPIN_LOCK_UNLOCKED;
 atomic_t shmem_nrpages = ATOMIC_INIT(0); /* Not used right now */
@@ -789,6 +795,7 @@
 		inode->i_blocks = 0;
 		inode->i_rdev = NODEV;
 		inode->i_mapping->a_ops = &shmem_aops;
+		inode->i_mapping->backing_dev_info = &shmem_backing_dev_info;
 		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
 		info = SHMEM_I(inode);
 		spin_lock_init (&info->lock);
diff -Nru a/mm/swap.c b/mm/swap.c
--- a/mm/swap.c	Wed Aug 28 07:37:37 2002
+++ b/mm/swap.c	Wed Aug 28 07:37:37 2002
@@ -19,31 +19,28 @@
 #include <linux/pagemap.h>
 #include <linux/pagevec.h>
 #include <linux/init.h>
+#include <linux/mm_inline.h>
+#include <linux/buffer_head.h>
 #include <linux/prefetch.h>
 
 /* How many pages do we try to swap or page in/out together? */
 int page_cluster;
 
 /*
- * Move an inactive page to the active list.
+ * FIXME: speed this up?
  */
-static inline void activate_page_nolock(struct page * page)
+void activate_page(struct page *page)
 {
+	struct zone *zone = page_zone(page);
+
+	spin_lock_irq(&zone->lru_lock);
 	if (PageLRU(page) && !PageActive(page)) {
-		del_page_from_inactive_list(page);
-		add_page_to_active_list(page);
+		del_page_from_inactive_list(zone, page);
+		SetPageActive(page);
+		add_page_to_active_list(zone, page);
 		KERNEL_STAT_INC(pgactivate);
 	}
-}
-
-/*
- * FIXME: speed this up?
- */
-void activate_page(struct page * page)
-{
-	spin_lock_irq(&_pagemap_lru_lock);
-	activate_page_nolock(page);
-	spin_unlock_irq(&_pagemap_lru_lock);
+	spin_unlock_irq(&zone->lru_lock);
 }
 
 /**
@@ -77,66 +74,71 @@
 void __page_cache_release(struct page *page)
 {
 	unsigned long flags;
+	struct zone *zone = page_zone(page);
 
-	spin_lock_irqsave(&_pagemap_lru_lock, flags);
-	if (TestClearPageLRU(page)) {
-		if (PageActive(page))
-			del_page_from_active_list(page);
-		else
-			del_page_from_inactive_list(page);
-	}
+	spin_lock_irqsave(&zone->lru_lock, flags);
+	if (TestClearPageLRU(page))
+		del_page_from_lru(zone, page);
 	if (page_count(page) != 0)
 		page = NULL;
-	spin_unlock_irqrestore(&_pagemap_lru_lock, flags);
+	spin_unlock_irqrestore(&zone->lru_lock, flags);
 	if (page)
 		__free_pages_ok(page, 0);
 }
 
 /*
  * Batched page_cache_release().  Decrement the reference count on all the
- * pagevec's pages.  If it fell to zero then remove the page from the LRU and
+ * passed pages.  If it fell to zero then remove the page from the LRU and
  * free it.
  *
- * Avoid taking pagemap_lru_lock if possible, but if it is taken, retain it
+ * Avoid taking zone->lru_lock if possible, but if it is taken, retain it
  * for the remainder of the operation.
  *
  * The locking in this function is against shrink_cache(): we recheck the
  * page count inside the lock to see whether shrink_cache grabbed the page
  * via the LRU.  If it did, give up: shrink_cache will free it.
- *
- * This function reinitialises the caller's pagevec.
  */
-void __pagevec_release(struct pagevec *pvec)
+void release_pages(struct page **pages, int nr)
 {
 	int i;
-	int lock_held = 0;
 	struct pagevec pages_to_free;
+	struct zone *zone = NULL;
 
 	pagevec_init(&pages_to_free);
-	for (i = 0; i < pagevec_count(pvec); i++) {
-		struct page *page = pvec->pages[i];
+	for (i = 0; i < nr; i++) {
+		struct page *page = pages[i];
+		struct zone *pagezone;
 
 		if (PageReserved(page) || !put_page_testzero(page))
 			continue;
 
-		if (!lock_held) {
-			spin_lock_irq(&_pagemap_lru_lock);
-			lock_held = 1;
+		pagezone = page_zone(page);
+		if (pagezone != zone) {
+			if (zone)
+				spin_unlock_irq(&zone->lru_lock);
+			zone = pagezone;
+			spin_lock_irq(&zone->lru_lock);
 		}
-
-		if (TestClearPageLRU(page)) {
-			if (PageActive(page))
-				del_page_from_active_list(page);
-			else
-				del_page_from_inactive_list(page);
+		if (TestClearPageLRU(page))
+			del_page_from_lru(zone, page);
+		if (page_count(page) == 0) {
+			if (!pagevec_add(&pages_to_free, page)) {
+				spin_unlock_irq(&zone->lru_lock);
+				pagevec_free(&pages_to_free);
+				pagevec_init(&pages_to_free);
+				spin_lock_irq(&zone->lru_lock);
+			}
 		}
-		if (page_count(page) == 0)
-			pagevec_add(&pages_to_free, page);
 	}
-	if (lock_held)
-		spin_unlock_irq(&_pagemap_lru_lock);
+	if (zone)
+		spin_unlock_irq(&zone->lru_lock);
 
 	pagevec_free(&pages_to_free);
+}
+
+void __pagevec_release(struct pagevec *pvec)
+{
+	release_pages(pvec->pages, pagevec_count(pvec));
 	pagevec_init(pvec);
 }
 
@@ -169,24 +171,27 @@
 void pagevec_deactivate_inactive(struct pagevec *pvec)
 {
 	int i;
-	int lock_held = 0;
+	struct zone *zone = NULL;
 
 	if (pagevec_count(pvec) == 0)
 		return;
 	for (i = 0; i < pagevec_count(pvec); i++) {
 		struct page *page = pvec->pages[i];
+		struct zone *pagezone = page_zone(page);
 
-		if (!lock_held) {
+		if (pagezone != zone) {
 			if (PageActive(page) || !PageLRU(page))
 				continue;
-			spin_lock_irq(&_pagemap_lru_lock);
-			lock_held = 1;
+			if (zone)
+				spin_unlock_irq(&zone->lru_lock);
+			zone = pagezone;
+			spin_lock_irq(&zone->lru_lock);
 		}
 		if (!PageActive(page) && PageLRU(page))
-			list_move(&page->lru, &inactive_list);
+			list_move(&page->lru, &pagezone->inactive_list);
 	}
-	if (lock_held)
-		spin_unlock_irq(&_pagemap_lru_lock);
+	if (zone)
+		spin_unlock_irq(&zone->lru_lock);
 	__pagevec_release(pvec);
 }
 
@@ -197,16 +202,24 @@
 void __pagevec_lru_add(struct pagevec *pvec)
 {
 	int i;
+	struct zone *zone = NULL;
 
-	spin_lock_irq(&_pagemap_lru_lock);
 	for (i = 0; i < pagevec_count(pvec); i++) {
 		struct page *page = pvec->pages[i];
+		struct zone *pagezone = page_zone(page);
 
+		if (pagezone != zone) {
+			if (zone)
+				spin_unlock_irq(&zone->lru_lock);
+			zone = pagezone;
+			spin_lock_irq(&zone->lru_lock);
+		}
 		if (TestSetPageLRU(page))
 			BUG();
-		add_page_to_inactive_list(page);
+		add_page_to_inactive_list(zone, page);
 	}
-	spin_unlock_irq(&_pagemap_lru_lock);
+	if (zone)
+		spin_unlock_irq(&zone->lru_lock);
 	pagevec_release(pvec);
 }
 
@@ -217,20 +230,42 @@
 void __pagevec_lru_del(struct pagevec *pvec)
 {
 	int i;
+	struct zone *zone = NULL;
 
-	spin_lock_irq(&_pagemap_lru_lock);
 	for (i = 0; i < pagevec_count(pvec); i++) {
 		struct page *page = pvec->pages[i];
+		struct zone *pagezone = page_zone(page);
 
+		if (pagezone != zone) {
+			if (zone)
+				spin_unlock_irq(&zone->lru_lock);
+			zone = pagezone;
+			spin_lock_irq(&zone->lru_lock);
+		}
 		if (!TestClearPageLRU(page))
 			BUG();
-		if (PageActive(page))
-			del_page_from_active_list(page);
-		else
-			del_page_from_inactive_list(page);
+		del_page_from_lru(zone, page);
 	}
-	spin_unlock_irq(&_pagemap_lru_lock);
+	if (zone)
+		spin_unlock_irq(&zone->lru_lock);
 	pagevec_release(pvec);
+}
+
+/*
+ * Try to drop buffers from the pages in a pagevec
+ */
+void pagevec_strip(struct pagevec *pvec)
+{
+	int i;
+
+	for (i = 0; i < pagevec_count(pvec); i++) {
+		struct page *page = pvec->pages[i];
+
+		if (PagePrivate(page) && !TestSetPageLocked(page)) {
+			try_to_release_page(page, 0);
+			unlock_page(page);
+		}
+	}
 }
 
 /*
diff -Nru a/mm/swap_state.c b/mm/swap_state.c
--- a/mm/swap_state.c	Wed Aug 28 07:37:37 2002
+++ b/mm/swap_state.c	Wed Aug 28 07:37:37 2002
@@ -13,6 +13,7 @@
 #include <linux/init.h>
 #include <linux/pagemap.h>
 #include <linux/smp_lock.h>
+#include <linux/backing-dev.h>
 #include <linux/buffer_head.h>	/* block_sync_page() */
 
 #include <asm/pgtable.h>
@@ -25,20 +26,26 @@
 	.i_mapping	= &swapper_space,
 };
 
+static struct backing_dev_info swap_backing_dev_info = {
+	.ra_pages	= 0,	/* No readahead */
+	.memory_backed	= 1,	/* Does not contribute to dirty memory */
+};
+
 extern struct address_space_operations swap_aops;
 
 struct address_space swapper_space = {
-	.page_tree	= RADIX_TREE_INIT(GFP_ATOMIC),
-	.page_lock	= RW_LOCK_UNLOCKED,
-	.clean_pages	= LIST_HEAD_INIT(swapper_space.clean_pages),
-	.dirty_pages	= LIST_HEAD_INIT(swapper_space.dirty_pages),
-	.io_pages	= LIST_HEAD_INIT(swapper_space.io_pages),
-	.locked_pages	= LIST_HEAD_INIT(swapper_space.locked_pages),
-	.host		= &swapper_inode,
-	.a_ops		= &swap_aops,
-	.i_shared_lock	= SPIN_LOCK_UNLOCKED,
-	.private_lock	= SPIN_LOCK_UNLOCKED,
-	.private_list	= LIST_HEAD_INIT(swapper_space.private_list),
+	.page_tree		= RADIX_TREE_INIT(GFP_ATOMIC),
+	.page_lock		= RW_LOCK_UNLOCKED,
+	.clean_pages		= LIST_HEAD_INIT(swapper_space.clean_pages),
+	.dirty_pages		= LIST_HEAD_INIT(swapper_space.dirty_pages),
+	.io_pages		= LIST_HEAD_INIT(swapper_space.io_pages),
+	.locked_pages		= LIST_HEAD_INIT(swapper_space.locked_pages),
+	.host			= &swapper_inode,
+	.a_ops			= &swap_aops,
+	.backing_dev_info	= &swap_backing_dev_info,
+	.i_shared_lock		= SPIN_LOCK_UNLOCKED,
+	.private_lock		= SPIN_LOCK_UNLOCKED,
+	.private_list		= LIST_HEAD_INIT(swapper_space.private_list),
 };
 
 #define INC_CACHE_INFO(x)	do { swap_cache_info.x++; } while (0)
@@ -292,26 +299,53 @@
 	return err;
 }
 
+
 /* 
- * Perform a free_page(), also freeing any swap cache associated with
- * this page if it is the last user of the page. Can not do a lock_page,
- * as we are holding the page_table_lock spinlock.
+ * If we are the only user, then try to free up the swap cache. 
+ * 
+ * Its ok to check for PageSwapCache without the page lock
+ * here because we are going to recheck again inside 
+ * exclusive_swap_page() _with_ the lock. 
+ * 					- Marcelo
  */
-void free_page_and_swap_cache(struct page *page)
+static inline void free_swap_cache(struct page *page)
 {
-	/* 
-	 * If we are the only user, then try to free up the swap cache. 
-	 * 
-	 * Its ok to check for PageSwapCache without the page lock
-	 * here because we are going to recheck again inside 
-	 * exclusive_swap_page() _with_ the lock. 
-	 * 					- Marcelo
-	 */
 	if (PageSwapCache(page) && !TestSetPageLocked(page)) {
 		remove_exclusive_swap_page(page);
 		unlock_page(page);
 	}
+}
+
+/* 
+ * Perform a free_page(), also freeing any swap cache associated with
+ * this page if it is the last user of the page. Can not do a lock_page,
+ * as we are holding the page_table_lock spinlock.
+ */
+void free_page_and_swap_cache(struct page *page)
+{
+	free_swap_cache(page);
 	page_cache_release(page);
+}
+
+/*
+ * Passed an array of pages, drop them all from swapcache and then release
+ * them.  They are removed from the LRU and freed if this is their last use.
+ */
+void free_pages_and_swap_cache(struct page **pages, int nr)
+{
+	const int chunk = 16;
+	struct page **pagep = pages;
+
+	while (nr) {
+		int todo = min(chunk, nr);
+		int i;
+
+		for (i = 0; i < todo; i++)
+			free_swap_cache(pagep[i]);
+		release_pages(pagep, todo);
+		pagep += todo;
+		nr -= todo;
+	}
 }
 
 /*
diff -Nru a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c	Wed Aug 28 07:37:36 2002
+++ b/mm/vmscan.c	Wed Aug 28 07:37:36 2002
@@ -23,6 +23,7 @@
 #include <linux/writeback.h>
 #include <linux/suspend.h>
 #include <linux/buffer_head.h>		/* for try_to_release_page() */
+#include <linux/mm_inline.h>
 #include <linux/pagevec.h>
 
 #include <asm/pgalloc.h>
@@ -93,7 +94,7 @@
 }
 
 static /* inline */ int
-shrink_list(struct list_head *page_list, int nr_pages, zone_t *classzone,
+shrink_list(struct list_head *page_list, int nr_pages,
 		unsigned int gfp_mask, int priority, int *max_scan)
 {
 	struct address_space *mapping;
@@ -109,8 +110,6 @@
 
 		page = list_entry(page_list->prev, struct page, lru);
 		list_del(&page->lru);
-		if (!memclass(page_zone(page), classzone))
-			goto keep;
 
 		if (TestSetPageLocked(page))
 			goto keep;
@@ -264,7 +263,7 @@
 }
 
 /*
- * pagemap_lru_lock is heavily contented.  We relieve it by quickly privatising
+ * zone->lru_lock is heavily contented.  We relieve it by quickly privatising
  * a batch of pages and working on them outside the lock.  Any pages which were
  * not freed will be added back to the LRU.
  *
@@ -275,7 +274,7 @@
  * in the kernel (apart from the copy_*_user functions).
  */
 static /* inline */ int
-shrink_cache(int nr_pages, zone_t *classzone,
+shrink_cache(int nr_pages, struct zone *zone,
 		unsigned int gfp_mask, int priority, int max_scan)
 {
 	LIST_HEAD(page_list);
@@ -292,15 +291,17 @@
 	pagevec_init(&pvec);
 
 	lru_add_drain();
-	spin_lock_irq(&_pagemap_lru_lock);
+	spin_lock_irq(&zone->lru_lock);
 	while (max_scan > 0 && nr_pages > 0) {
 		struct page *page;
 		int n = 0;
 
-		while (n < nr_to_process && !list_empty(&inactive_list)) {
-			page = list_entry(inactive_list.prev, struct page, lru);
+		while (n < nr_to_process && !list_empty(&zone->inactive_list)) {
+			page = list_entry(zone->inactive_list.prev,
+					struct page, lru);
 
-			prefetchw_prev_lru_page(page, &inactive_list, flags);
+			prefetchw_prev_lru_page(page,
+						&zone->inactive_list, flags);
 
 			if (!TestClearPageLRU(page))
 				BUG();
@@ -308,28 +309,28 @@
 			if (page_count(page) == 0) {
 				/* It is currently in pagevec_release() */
 				SetPageLRU(page);
-				list_add(&page->lru, &inactive_list);
+				list_add(&page->lru, &zone->inactive_list);
 				continue;
 			}
 			list_add(&page->lru, &page_list);
 			page_cache_get(page);
 			n++;
 		}
-		spin_unlock_irq(&_pagemap_lru_lock);
+		zone->nr_inactive -= n;
+		spin_unlock_irq(&zone->lru_lock);
 
 		if (list_empty(&page_list))
 			goto done;
 
 		max_scan -= n;
-		mod_page_state(nr_inactive, -n);
 		KERNEL_STAT_ADD(pgscan, n);
-		nr_pages = shrink_list(&page_list, nr_pages, classzone,
+		nr_pages = shrink_list(&page_list, nr_pages,
 					gfp_mask, priority, &max_scan);
 
 		if (nr_pages <= 0 && list_empty(&page_list))
 			goto done;
 
-		spin_lock_irq(&_pagemap_lru_lock);
+		spin_lock_irq(&zone->lru_lock);
 		/*
 		 * Put back any unfreeable pages.
 		 */
@@ -339,17 +340,17 @@
 				BUG();
 			list_del(&page->lru);
 			if (PageActive(page))
-				__add_page_to_active_list(page);
+				add_page_to_active_list(zone, page);
 			else
-				add_page_to_inactive_list(page);
+				add_page_to_inactive_list(zone, page);
 			if (!pagevec_add(&pvec, page)) {
-				spin_unlock_irq(&_pagemap_lru_lock);
+				spin_unlock_irq(&zone->lru_lock);
 				__pagevec_release(&pvec);
-				spin_lock_irq(&_pagemap_lru_lock);
+				spin_lock_irq(&zone->lru_lock);
 			}
 		}
   	}
-	spin_unlock_irq(&_pagemap_lru_lock);
+	spin_unlock_irq(&zone->lru_lock);
 done:
 	pagevec_release(&pvec);
 	return nr_pages;	
@@ -362,9 +363,9 @@
  * processes, from rmap.
  *
  * If the pages are mostly unmapped, the processing is fast and it is
- * appropriate to hold pagemap_lru_lock across the whole operation.  But if
+ * appropriate to hold zone->lru_lock across the whole operation.  But if
  * the pages are mapped, the processing is slow (page_referenced()) so we
- * should drop pagemap_lru_lock around each page.  It's impossible to balance
+ * should drop zone->lru_lock around each page.  It's impossible to balance
  * this, so instead we remove the pages from the LRU while processing them.
  * It is safe to rely on PG_active against the non-LRU pages in here because
  * nobody will play with that bit on a non-LRU page.
@@ -372,7 +373,8 @@
  * The downside is that we have to touch page->count against each page.
  * But we had to alter page->flags anyway.
  */
-static /* inline */ void refill_inactive(const int nr_pages_in)
+static /* inline */ void
+refill_inactive_zone(struct zone *zone, const int nr_pages_in)
 {
 	int pgdeactivate = 0;
 	int nr_pages = nr_pages_in;
@@ -383,24 +385,24 @@
 	struct pagevec pvec;
 
 	lru_add_drain();
-	spin_lock_irq(&_pagemap_lru_lock);
-	while (nr_pages && !list_empty(&active_list)) {
-		page = list_entry(active_list.prev, struct page, lru);
-		prefetchw_prev_lru_page(page, &active_list, flags);
+	spin_lock_irq(&zone->lru_lock);
+	while (nr_pages && !list_empty(&zone->active_list)) {
+		page = list_entry(zone->active_list.prev, struct page, lru);
+		prefetchw_prev_lru_page(page, &zone->active_list, flags);
 		if (!TestClearPageLRU(page))
 			BUG();
 		list_del(&page->lru);
 		if (page_count(page) == 0) {
 			/* It is currently in pagevec_release() */
 			SetPageLRU(page);
-			list_add(&page->lru, &active_list);
+			list_add(&page->lru, &zone->active_list);
 			continue;
 		}
 		page_cache_get(page);
 		list_add(&page->lru, &l_hold);
 		nr_pages--;
 	}
-	spin_unlock_irq(&_pagemap_lru_lock);
+	spin_unlock_irq(&zone->lru_lock);
 
 	while (!list_empty(&l_hold)) {
 		page = list_entry(l_hold.prev, struct page, lru);
@@ -419,7 +421,7 @@
 	}
 
 	pagevec_init(&pvec);
-	spin_lock_irq(&_pagemap_lru_lock);
+	spin_lock_irq(&zone->lru_lock);
 	while (!list_empty(&l_inactive)) {
 		page = list_entry(l_inactive.prev, struct page, lru);
 		prefetchw_prev_lru_page(page, &l_inactive, flags);
@@ -427,44 +429,51 @@
 			BUG();
 		if (!TestClearPageActive(page))
 			BUG();
-		list_move(&page->lru, &inactive_list);
+		list_move(&page->lru, &zone->inactive_list);
 		if (!pagevec_add(&pvec, page)) {
-			spin_unlock_irq(&_pagemap_lru_lock);
+			spin_unlock_irq(&zone->lru_lock);
+			if (buffer_heads_over_limit)
+				pagevec_strip(&pvec);
 			__pagevec_release(&pvec);
-			spin_lock_irq(&_pagemap_lru_lock);
+			spin_lock_irq(&zone->lru_lock);
 		}
 	}
+	if (buffer_heads_over_limit) {
+		spin_unlock_irq(&zone->lru_lock);
+		pagevec_strip(&pvec);
+		pagevec_release(&pvec);
+		spin_lock_irq(&zone->lru_lock);
+	}
 	while (!list_empty(&l_active)) {
 		page = list_entry(l_active.prev, struct page, lru);
 		prefetchw_prev_lru_page(page, &l_active, flags);
 		if (TestSetPageLRU(page))
 			BUG();
 		BUG_ON(!PageActive(page));
-		list_move(&page->lru, &active_list);
+		list_move(&page->lru, &zone->active_list);
 		if (!pagevec_add(&pvec, page)) {
-			spin_unlock_irq(&_pagemap_lru_lock);
+			spin_unlock_irq(&zone->lru_lock);
 			__pagevec_release(&pvec);
-			spin_lock_irq(&_pagemap_lru_lock);
+			spin_lock_irq(&zone->lru_lock);
 		}
 	}
-	spin_unlock_irq(&_pagemap_lru_lock);
+	zone->nr_active -= pgdeactivate;
+	zone->nr_inactive += pgdeactivate;
+	spin_unlock_irq(&zone->lru_lock);
 	pagevec_release(&pvec);
 
-	mod_page_state(nr_active, -pgdeactivate);
-	mod_page_state(nr_inactive, pgdeactivate);
 	KERNEL_STAT_ADD(pgscan, nr_pages_in - nr_pages);
 	KERNEL_STAT_ADD(pgdeactivate, pgdeactivate);
 }
 
 static /* inline */ int
-shrink_caches(zone_t *classzone, int priority,
-		unsigned int gfp_mask, int nr_pages)
+shrink_zone(struct zone *zone, int priority,
+	unsigned int gfp_mask, int nr_pages)
 {
 	unsigned long ratio;
-	struct page_state ps;
 	int max_scan;
-	static atomic_t nr_to_refill = ATOMIC_INIT(0);
 
+	/* This is bogus for ZONE_HIGHMEM? */
 	if (kmem_cache_reap(gfp_mask) >= nr_pages)
   		return 0;
 
@@ -478,17 +487,16 @@
 	 * just to make sure that the kernel will slowly sift through the
 	 * active list.
 	 */
-	get_page_state(&ps);
-	ratio = (unsigned long)nr_pages * ps.nr_active /
-				((ps.nr_inactive | 1) * 2);
-	atomic_add(ratio+1, &nr_to_refill);
-	if (atomic_read(&nr_to_refill) > SWAP_CLUSTER_MAX) {
-		atomic_sub(SWAP_CLUSTER_MAX, &nr_to_refill);
-		refill_inactive(SWAP_CLUSTER_MAX);
+	ratio = (unsigned long)nr_pages * zone->nr_active /
+				((zone->nr_inactive | 1) * 2);
+	atomic_add(ratio+1, &zone->refill_counter);
+	if (atomic_read(&zone->refill_counter) > SWAP_CLUSTER_MAX) {
+		atomic_sub(SWAP_CLUSTER_MAX, &zone->refill_counter);
+		refill_inactive_zone(zone, SWAP_CLUSTER_MAX);
 	}
 
-	max_scan = ps.nr_inactive / priority;
-	nr_pages = shrink_cache(nr_pages, classzone,
+	max_scan = zone->nr_inactive / priority;
+	nr_pages = shrink_cache(nr_pages, zone,
 				gfp_mask, priority, max_scan);
 
 	if (nr_pages <= 0)
@@ -507,7 +515,31 @@
 	return nr_pages;
 }
 
-int try_to_free_pages(zone_t *classzone, unsigned int gfp_mask, unsigned int order)
+static int
+shrink_caches(struct zone *classzone, int priority,
+		int gfp_mask, int nr_pages)
+{
+	struct zone *first_classzone;
+	struct zone *zone;
+
+	first_classzone = classzone->zone_pgdat->node_zones;
+	zone = classzone;
+	while (zone >= first_classzone) {
+		if (zone->free_pages <= zone->pages_high) {
+			nr_pages = shrink_zone(zone, priority,
+					gfp_mask, nr_pages);
+		}
+		zone--;
+	}
+	return nr_pages;
+}
+
+/*
+ * This is the main entry point to page reclaim.
+ */
+int
+try_to_free_pages(struct zone *classzone,
+		unsigned int gfp_mask, unsigned int order)
 {
 	int priority = DEF_PRIORITY;
 	int nr_pages = SWAP_CLUSTER_MAX;
@@ -515,24 +547,20 @@
 	KERNEL_STAT_INC(pageoutrun);
 
 	do {
-		nr_pages = shrink_caches(classzone, priority, gfp_mask, nr_pages);
+		nr_pages = shrink_caches(classzone, priority,
+					gfp_mask, nr_pages);
 		if (nr_pages <= 0)
 			return 1;
 	} while (--priority);
-
-	/*
-	 * Hmm.. Cache shrink failed - time to kill something?
-	 * Mhwahahhaha! This is the part I really like. Giggle.
-	 */
 	out_of_memory();
 	return 0;
 }
 
 DECLARE_WAIT_QUEUE_HEAD(kswapd_wait);
 
-static int check_classzone_need_balance(zone_t * classzone)
+static int check_classzone_need_balance(struct zone *classzone)
 {
-	zone_t * first_classzone;
+	struct zone *first_classzone;
 
 	first_classzone = classzone->zone_pgdat->node_zones;
 	while (classzone >= first_classzone) {
@@ -546,7 +574,7 @@
 static int kswapd_balance_pgdat(pg_data_t * pgdat)
 {
 	int need_more_balance = 0, i;
-	zone_t * zone;
+	struct zone *zone;
 
 	for (i = pgdat->nr_zones-1; i >= 0; i--) {
 		zone = pgdat->node_zones + i;
@@ -584,7 +612,7 @@
 
 static int kswapd_can_sleep_pgdat(pg_data_t * pgdat)
 {
-	zone_t * zone;
+	struct zone *zone;
 	int i;
 
 	for (i = pgdat->nr_zones-1; i >= 0; i--) {

---------------


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
