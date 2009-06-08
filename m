Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 47C196B004D
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 10:23:27 -0400 (EDT)
Date: Mon, 8 Jun 2009 10:44:05 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: [PATCH] x86, UV: Fix nacros for multiple coherency domains
Message-ID: <20090608154405.GA16395@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: mingo@elte.hu, tglx@linutronix.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Fix bug in the SGI UV macros that support systems with multiple coherency
domains.  The macros used for referencing global MMR (chipset registers)
are failing to correctly "or" the NASID (node identifier) bits that reside
above M+N. These high bits are supplied automatically by the chipset for
memory accesses coming from the processor socket. However, the bits must
be present for references to the special global MMR space used to map chipset
registers. (See uv_hub.h for more details ...)

The bug results in references to invalid/incorrect nodes.

Signed-off-by: Jack Steiner <steiner@sgi.com>

---
 arch/x86/include/asm/uv/uv_hub.h   |    6 ++++--
 arch/x86/kernel/apic/x2apic_uv_x.c |   15 +++++++++------
 2 files changed, 13 insertions(+), 8 deletions(-)

Index: linux/arch/x86/include/asm/uv/uv_hub.h
===================================================================
--- linux.orig/arch/x86/include/asm/uv/uv_hub.h	2009-06-07 15:20:13.000000000 -0500
+++ linux/arch/x86/include/asm/uv/uv_hub.h	2009-06-08 10:13:45.000000000 -0500
@@ -133,6 +133,7 @@ struct uv_scir_s {
 struct uv_hub_info_s {
 	unsigned long		global_mmr_base;
 	unsigned long		gpa_mask;
+	unsigned int		gnode_extra;
 	unsigned long		gnode_upper;
 	unsigned long		lowmem_remap_top;
 	unsigned long		lowmem_remap_base;
@@ -159,7 +160,8 @@ DECLARE_PER_CPU(struct uv_hub_info_s, __
  * 		p -  PNODE (local part of nsids, right shifted 1)
  */
 #define UV_NASID_TO_PNODE(n)		(((n) >> 1) & uv_hub_info->pnode_mask)
-#define UV_PNODE_TO_NASID(p)		(((p) << 1) | uv_hub_info->gnode_upper)
+#define UV_PNODE_TO_GNODE(p)		((p) |uv_hub_info->gnode_extra)
+#define UV_PNODE_TO_NASID(p)		(UV_PNODE_TO_GNODE(p) << 1)
 
 #define UV_LOCAL_MMR_BASE		0xf4000000UL
 #define UV_GLOBAL_MMR32_BASE		0xf8000000UL
@@ -173,7 +175,7 @@ DECLARE_PER_CPU(struct uv_hub_info_s, __
 #define UV_GLOBAL_MMR32_PNODE_BITS(p)	((p) << (UV_GLOBAL_MMR32_PNODE_SHIFT))
 
 #define UV_GLOBAL_MMR64_PNODE_BITS(p)					\
-	((unsigned long)(p) << UV_GLOBAL_MMR64_PNODE_SHIFT)
+	((unsigned long)(UV_PNODE_TO_GNODE(p)) << UV_GLOBAL_MMR64_PNODE_SHIFT)
 
 #define UV_APIC_PNODE_SHIFT	6
 
Index: linux/arch/x86/kernel/apic/x2apic_uv_x.c
===================================================================
--- linux.orig/arch/x86/kernel/apic/x2apic_uv_x.c	2009-06-08 09:45:42.000000000 -0500
+++ linux/arch/x86/kernel/apic/x2apic_uv_x.c	2009-06-08 10:15:31.000000000 -0500
@@ -537,7 +537,7 @@ void __init uv_system_init(void)
 	union uvh_node_id_u node_id;
 	unsigned long gnode_upper, lowmem_redir_base, lowmem_redir_size;
 	int bytes, nid, cpu, lcpu, pnode, blade, i, j, m_val, n_val;
-	int max_pnode = 0;
+	int gnode_extra, max_pnode = 0;
 	unsigned long mmr_base, present, paddr;
 	unsigned short pnode_mask;
 
@@ -547,6 +547,13 @@ void __init uv_system_init(void)
 	mmr_base =
 	    uv_read_local_mmr(UVH_RH_GAM_MMR_OVERLAY_CONFIG_MMR) &
 	    ~UV_MMR_ENABLE;
+	pnode_mask = (1 << n_val) - 1;
+	node_id.v = uv_read_local_mmr(UVH_NODE_ID);
+	gnode_extra = (node_id.s.node_id & ~((1 << n_val) - 1)) >> 1;
+	gnode_upper = ((unsigned long)gnode_extra  << m_val);
+	printk(KERN_DEBUG "UV: N %d, M %d, gnode_upper 0x%lx, gnode_extra 0x%x\n",
+			n_val, m_val, gnode_upper, gnode_extra);
+
 	printk(KERN_DEBUG "UV: global MMR base 0x%lx\n", mmr_base);
 
 	for(i = 0; i < UVH_NODE_PRESENT_TABLE_DEPTH; i++)
@@ -583,11 +590,6 @@ void __init uv_system_init(void)
 		}
 	}
 
-	pnode_mask = (1 << n_val) - 1;
-	node_id.v = uv_read_local_mmr(UVH_NODE_ID);
-	gnode_upper = (((unsigned long)node_id.s.node_id) &
-		       ~((1 << n_val) - 1)) << m_val;
-
 	uv_bios_init();
 	uv_bios_get_sn_info(0, &uv_type, &sn_partition_id,
 			    &sn_coherency_id, &sn_region_size);
@@ -610,6 +612,7 @@ void __init uv_system_init(void)
 		uv_cpu_hub_info(cpu)->pnode_mask = pnode_mask;
 		uv_cpu_hub_info(cpu)->gpa_mask = (1 << (m_val + n_val)) - 1;
 		uv_cpu_hub_info(cpu)->gnode_upper = gnode_upper;
+		uv_cpu_hub_info(cpu)->gnode_extra = gnode_extra;
 		uv_cpu_hub_info(cpu)->global_mmr_base = mmr_base;
 		uv_cpu_hub_info(cpu)->coherency_domain_number = sn_coherency_id;
 		uv_cpu_hub_info(cpu)->scir.offset = SCIR_LOCAL_MMR_BASE + lcpu;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
