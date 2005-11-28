Date: Mon, 28 Nov 2005 20:37:08 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch:RFC] Specifing un-reclaim node for new_zone.
Message-Id: <20051128200644.5D84.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>, linux-ia64@vger.kernel.org
Cc: Joel Schopp <jschopp@austin.ibm.com>
List-ID: <linux-mm.kvack.org>

I made another patch for new zone.
Final purpose of this patch is to allocate ZONE_EASY_RECLAIM for 
some nodes. But, this patch's way is not direct.

By this patch, user can specify the number of un-reclaim nodes 
by bootoption "knode=###". Just the un-reclaim nodes are initialized 
like current way. 

And, this patch expects that other nodes will be hot-added as after booting,
and new area will be initialized as ZONE_EASY_RECLAIM.
(When ACPI is initialized at late phase of booting, DSDT
 will be searched by acpi_bus_scan() and hot-add code will be
 called.)

This way can make easy to remove node too. Because, when a node is removed
with current code, hot-remove code must judge which way
-alloc_bootmem() or kmalloc()- was used for allocation of some structures.
However, it can use kfree() for all removable node by this patch due to
all allocation of structures for reclaim node become kmalloc().
This is why I selected this way.

This code has some phases.

   1) Check srat table's hotplug bit and dma area (it is hard to be removed)
      against each memblk. These will be un-reclaim nodes.
   2) If knode num still remains, select other sacrifice.
   3) Then, only unreclaim node will be initialized.

Future work is CPU.
  CPUs on reclaim nodes must be offlined at boottime like memory.

Please comment.

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

Index: new_zone_mm/arch/ia64/kernel/acpi.c
===================================================================
--- new_zone_mm.orig/arch/ia64/kernel/acpi.c	2005-11-28 16:12:17.000000000 +0900
+++ new_zone_mm/arch/ia64/kernel/acpi.c	2005-11-28 16:17:30.000000000 +0900
@@ -53,6 +53,7 @@
 #include <asm/numa.h>
 #include <asm/sal.h>
 #include <asm/cyclone.h>
+#include <asm/dma.h>
 
 #define BAD_MADT_ENTRY(entry, end) (                                        \
 		(!entry) || (unsigned long)entry + sizeof(*entry) > end ||  \
@@ -414,6 +415,17 @@ int __devinitdata pxm_to_nid_map[MAX_PXM
 int __initdata nid_to_pxm_map[MAX_NUMNODES];
 static struct acpi_table_slit __initdata *slit_table;
 
+static u32 __devinitdata prepxm_flag[PXM_FLAG_LEN] = {0};
+#define prepxm_bit_set(bit)	(set_bit(bit,(void *)prepxm_flag))
+#define prepxm_bit_test(bit)	(test_bit(bit,(void *)prepxm_flag))
+
+static u32 __devinitdata pxm_hotpluggable_flag[PXM_FLAG_LEN] = {0};
+#define set_pxm_hotpluggable(bit)	(set_bit(bit,(void *)pxm_hotpluggable_flag))
+#define pxm_hotpluggable(bit)	(test_bit(bit,(void *)pxm_hotpluggable_flag))
+#define clear_pxm_hotpluggable(bit)	(clear_bit(bit,(void *)pxm_hotpluggable_flag))
+
+extern unsigned long knode_num;
+
 /*
  * ACPI 2.0 SLIT (System Locality Information Table)
  * http://devresource.hp.com/devresource/Docs/TechPapers/IA64/slit.pdf
@@ -447,6 +459,62 @@ acpi_numa_processor_affinity_init(struct
 	srat_num_cpus++;
 }
 
+static int __init
+is_hotpluggable_blk(struct acpi_table_memory_affinity *ma)
+{
+	unsigned long paddr;
+
+	paddr = ma->base_addr_hi;
+	paddr = (paddr << 32) | ma->base_addr_lo;
+
+	if (ma->flags.hot_pluggable && paddr >= __pa(MAX_DMA_ADDRESS))
+		return 1;
+
+	return 0;
+}
+
+void  __init
+acpi_numa_memory_hotpluggable_count(struct acpi_table_memory_affinity *ma)
+{
+	u8 pxm;
+
+	pxm = ma->proximity_domain;
+
+	if (!ma->flags.enabled)
+		return;
+
+	if (!prepxm_bit_test(pxm)){ /* This block is new node ? */
+		prepxm_bit_set(pxm);
+		if (is_hotpluggable_blk(ma))
+			set_pxm_hotpluggable(pxm);
+
+	} else if (!is_hotpluggable_blk(ma))
+		clear_pxm_hotpluggable(pxm); /* turn to unhotpluggable */
+
+}
+
+void __init
+acpi_numa_decide_knode(void)
+{
+	int i, remain, count_knode = 0;
+
+	for (i = 0; i < MAX_PXM_DOMAINS; i++)
+		if (prepxm_bit_test(i) && !pxm_hotpluggable(i))
+			count_knode++;
+
+	remain = knode_num - count_knode;
+
+	for (i = 0; i < MAX_PXM_DOMAINS; i++) {
+		if (prepxm_bit_test(i) && pxm_hotpluggable(i)) {
+			clear_pxm_hotpluggable(i);
+			remain--;
+		}
+
+		if (remain <= 0) break;
+	}
+
+}
+
 void __init
 acpi_numa_memory_affinity_init(struct acpi_table_memory_affinity *ma)
 {
@@ -466,6 +534,10 @@ acpi_numa_memory_affinity_init(struct ac
 	if (!ma->flags.enabled)
 		return;
 
+	/* Hotpluggable node will be initialized by hot-add of DSDT search. */
+	if (pxm_hotpluggable(pxm))
+		return;
+
 	/* record this node in proximity bitmap */
 	pxm_bit_set(pxm);
 
@@ -528,8 +600,13 @@ void __init acpi_numa_arch_fixup(void)
 	}
 
 	/* set logical node id in cpu structure */
-	for (i = 0; i < srat_num_cpus; i++)
-		node_cpuid[i].nid = pxm_to_nid_map[node_cpuid[i].nid];
+	for (i = 0; i < srat_num_cpus; i++){
+		/* XXX: cpus on hotpluggable node should be offlined at this time too. */
+		if (pxm_bit_test(node_cpuid[i].nid) && !pxm_hotpluggable(node_cpuid[i].nid))
+			node_cpuid[i].nid = pxm_to_nid_map[node_cpuid[i].nid];
+		else
+			node_cpuid[i].nid =0;
+	}
 
 	printk(KERN_INFO "Number of logical nodes in system = %d\n",
 	       num_online_nodes());
Index: new_zone_mm/drivers/acpi/numa.c
===================================================================
--- new_zone_mm.orig/drivers/acpi/numa.c	2005-11-28 16:12:17.000000000 +0900
+++ new_zone_mm/drivers/acpi/numa.c	2005-11-28 16:17:30.000000000 +0900
@@ -130,6 +130,22 @@ acpi_parse_processor_affinity(acpi_table
 	return 0;
 }
 
+
+static int __init
+acpi_parse_memory_count(acpi_table_entry_header * header,
+			   const unsigned long end)
+{
+	struct acpi_table_memory_affinity *memory_affinity;
+
+	memory_affinity = (struct acpi_table_memory_affinity *)header;
+	if (!memory_affinity)
+		return -EINVAL;
+
+	acpi_table_print_srat_entry(header);
+	acpi_numa_memory_hotpluggable_count(memory_affinity);
+
+}
+
 static int __init
 acpi_parse_memory_affinity(acpi_table_entry_header * header,
 			   const unsigned long end)
@@ -180,6 +196,12 @@ int __init acpi_numa_init(void)
 		result = acpi_table_parse_srat(ACPI_SRAT_PROCESSOR_AFFINITY,
 					       acpi_parse_processor_affinity,
 					       NR_CPUS);
+
+		result = acpi_table_parse_srat(ACPI_SRAT_MEMORY_AFFINITY, acpi_parse_memory_count, NR_NODE_MEMBLKS);	// IA64 specific
+
+
+		acpi_numa_decide_knode();
+
 		result = acpi_table_parse_srat(ACPI_SRAT_MEMORY_AFFINITY, acpi_parse_memory_affinity, NR_NODE_MEMBLKS);	// IA64 specific
 	}
 
Index: new_zone_mm/arch/ia64/kernel/efi.c
===================================================================
--- new_zone_mm.orig/arch/ia64/kernel/efi.c	2005-11-28 16:12:15.000000000 +0900
+++ new_zone_mm/arch/ia64/kernel/efi.c	2005-11-28 16:17:31.000000000 +0900
@@ -41,6 +41,7 @@ struct efi efi;
 EXPORT_SYMBOL(efi);
 static efi_runtime_services_t *runtime;
 static unsigned long mem_limit = ~0UL, max_addr = ~0UL;
+unsigned long knode_num = MAX_NUMNODES;
 
 #define efi_call_virt(f, args...)	(*(f))(args)
 
@@ -430,7 +431,13 @@ efi_init (void)
 			if (end != cp)
 				break;
 			cp = end;
-		} else {
+		} else if (memcmp(cp, "knode_num=", 10) == 0) {
+			cp += 10;
+			knode_num = simple_strtoul(cp, &end, 0);
+			if (end != cp)
+				break;
+			cp = end;
+ 		} else {
 			while (*cp != ' ' && *cp)
 				++cp;
 			while (*cp == ' ')

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
