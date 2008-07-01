Date: Tue, 1 Jul 2008 14:45:38 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: [PATCH 2/2] - Map UV chipset space - UV support
Message-ID: <20080701194538.GA28410@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu, tglx@linutronix.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Create page table entries to map the SGI UV chipset GRU. local MMR &
global MMR ranges.

Signed-off-by: Jack Steiner <steiner@sgi.com>

---
 arch/x86/kernel/genx2apic_uv_x.c |   75 ++++++++++++++++++++++++++++++++++++++-
 include/asm-x86/uv/uv_hub.h      |    2 +
 include/asm-x86/uv/uv_mmrs.h     |   46 +++++++++++++++++++++++
 3 files changed, 122 insertions(+), 1 deletion(-)

Index: linux/arch/x86/kernel/genx2apic_uv_x.c
===================================================================
--- linux.orig/arch/x86/kernel/genx2apic_uv_x.c	2008-07-01 14:36:00.000000000 -0500
+++ linux/arch/x86/kernel/genx2apic_uv_x.c	2008-07-01 14:39:50.000000000 -0500
@@ -8,6 +8,7 @@
  * Copyright (C) 2007-2008 Silicon Graphics, Inc. All rights reserved.
  */
 
+#include <linux/kernel.h>
 #include <linux/threads.h>
 #include <linux/cpumask.h>
 #include <linux/string.h>
@@ -20,6 +21,7 @@
 #include <asm/smp.h>
 #include <asm/ipi.h>
 #include <asm/genapic.h>
+#include <asm/pgtable.h>
 #include <asm/uv/uv_mmrs.h>
 #include <asm/uv/uv_hub.h>
 
@@ -213,14 +215,79 @@ static __init void get_lowmem_redirect(u
 	BUG();
 }
 
+static __init void map_low_mmrs(void)
+{
+	init_extra_mapping_uc(UV_GLOBAL_MMR32_BASE, UV_GLOBAL_MMR32_SIZE);
+	init_extra_mapping_uc(UV_LOCAL_MMR_BASE, UV_LOCAL_MMR_SIZE);
+}
+
+enum map_type {map_wb, map_uc};
+
+static void map_high(char *id, unsigned long base, int shift, enum map_type map_type)
+{
+	unsigned long bytes, paddr;
+
+	paddr = base << shift;
+	bytes = (1UL << shift);
+	printk(KERN_INFO "UV: Map %s_HI 0x%lx - 0x%lx\n", id, paddr,
+	       					paddr + bytes);
+	if (map_type == map_uc)
+		init_extra_mapping_uc(paddr, bytes);
+	else
+		init_extra_mapping_wb(paddr, bytes);
+
+}
+static __init void map_gru_high(int max_pnode)
+{
+	union uvh_rh_gam_gru_overlay_config_mmr_u gru;
+	int shift = UVH_RH_GAM_GRU_OVERLAY_CONFIG_MMR_BASE_SHFT;
+
+	gru.v = uv_read_local_mmr(UVH_RH_GAM_GRU_OVERLAY_CONFIG_MMR);
+	if (gru.s.enable)
+		map_high("GRU", gru.s.base, shift, map_wb);
+}
+
+static __init void map_config_high(int max_pnode)
+{
+	union uvh_rh_gam_cfg_overlay_config_mmr_u cfg;
+	int shift = UVH_RH_GAM_CFG_OVERLAY_CONFIG_MMR_BASE_SHFT;
+
+	cfg.v = uv_read_local_mmr(UVH_RH_GAM_CFG_OVERLAY_CONFIG_MMR);
+	if (cfg.s.enable)
+		map_high("CONFIG", cfg.s.base, shift, map_uc);
+}
+
+static __init void map_mmr_high(int max_pnode)
+{
+	union uvh_rh_gam_mmr_overlay_config_mmr_u mmr;
+	int shift = UVH_RH_GAM_MMR_OVERLAY_CONFIG_MMR_BASE_SHFT;
+
+	mmr.v = uv_read_local_mmr(UVH_RH_GAM_MMR_OVERLAY_CONFIG_MMR);
+	if (mmr.s.enable)
+		map_high("MMR", mmr.s.base, shift, map_uc);
+}
+
+static __init void map_mmioh_high(int max_pnode)
+{
+	union uvh_rh_gam_mmioh_overlay_config_mmr_u mmioh;
+	int shift = UVH_RH_GAM_MMIOH_OVERLAY_CONFIG_MMR_BASE_SHFT;
+
+	mmioh.v = uv_read_local_mmr(UVH_RH_GAM_MMIOH_OVERLAY_CONFIG_MMR);
+	if (mmioh.s.enable)
+		map_high("MMIOH", mmioh.s.base, shift, map_uc);
+}
+
 static __init void uv_system_init(void)
 {
 	union uvh_si_addr_map_config_u m_n_config;
 	union uvh_node_id_u node_id;
 	unsigned long gnode_upper, lowmem_redir_base, lowmem_redir_size;
 	int bytes, nid, cpu, lcpu, pnode, blade, i, j, m_val, n_val;
+	int max_pnode = 0;
 	unsigned long mmr_base, present;
 
+	map_low_mmrs();
+
 	m_n_config.v = uv_read_local_mmr(UVH_SI_ADDR_MAP_CONFIG);
 	m_val = m_n_config.s.m_skt;
 	n_val = m_n_config.s.n_skt;
@@ -286,12 +353,18 @@ static __init void uv_system_init(void)
 		uv_cpu_hub_info(cpu)->coherency_domain_number = 0;/* ZZZ */
 		uv_node_to_blade[nid] = blade;
 		uv_cpu_to_blade[cpu] = blade;
+		max_pnode = max(pnode, max_pnode);
 
-		printk(KERN_DEBUG "UV cpu %d, apicid 0x%x, pnode %d, nid %d, "
+		printk(KERN_DEBUG "UV: cpu %d, apicid 0x%x, pnode %d, nid %d, "
 			"lcpu %d, blade %d\n",
 			cpu, per_cpu(x86_cpu_to_apicid, cpu), pnode, nid,
 			lcpu, blade);
 	}
+
+	map_gru_high(max_pnode);
+	map_mmr_high(max_pnode);
+	map_config_high(max_pnode);
+	map_mmioh_high(max_pnode);
 }
 
 /*
Index: linux/include/asm-x86/uv/uv_mmrs.h
===================================================================
--- linux.orig/include/asm-x86/uv/uv_mmrs.h	2008-07-01 14:36:00.000000000 -0500
+++ linux/include/asm-x86/uv/uv_mmrs.h	2008-07-01 14:39:11.000000000 -0500
@@ -713,6 +713,26 @@ union uvh_rh_gam_alias210_redirect_confi
 };
 
 /* ========================================================================= */
+/*                    UVH_RH_GAM_CFG_OVERLAY_CONFIG_MMR                      */
+/* ========================================================================= */
+#define UVH_RH_GAM_CFG_OVERLAY_CONFIG_MMR 0x1600020UL
+
+#define UVH_RH_GAM_CFG_OVERLAY_CONFIG_MMR_BASE_SHFT 26
+#define UVH_RH_GAM_CFG_OVERLAY_CONFIG_MMR_BASE_MASK 0x00003ffffc000000UL
+#define UVH_RH_GAM_CFG_OVERLAY_CONFIG_MMR_ENABLE_SHFT 63
+#define UVH_RH_GAM_CFG_OVERLAY_CONFIG_MMR_ENABLE_MASK 0x8000000000000000UL
+
+union uvh_rh_gam_cfg_overlay_config_mmr_u {
+    unsigned long	v;
+    struct uvh_rh_gam_cfg_overlay_config_mmr_s {
+	unsigned long	rsvd_0_25: 26;  /*    */
+	unsigned long	base   : 20;  /* RW */
+	unsigned long	rsvd_46_62: 17;  /*    */
+	unsigned long	enable :  1;  /* RW */
+    } s;
+};
+
+/* ========================================================================= */
 /*                    UVH_RH_GAM_GRU_OVERLAY_CONFIG_MMR                      */
 /* ========================================================================= */
 #define UVH_RH_GAM_GRU_OVERLAY_CONFIG_MMR 0x1600010UL
@@ -740,6 +760,32 @@ union uvh_rh_gam_gru_overlay_config_mmr_
 };
 
 /* ========================================================================= */
+/*                   UVH_RH_GAM_MMIOH_OVERLAY_CONFIG_MMR                     */
+/* ========================================================================= */
+#define UVH_RH_GAM_MMIOH_OVERLAY_CONFIG_MMR 0x1600030UL
+
+#define UVH_RH_GAM_MMIOH_OVERLAY_CONFIG_MMR_BASE_SHFT 30
+#define UVH_RH_GAM_MMIOH_OVERLAY_CONFIG_MMR_BASE_MASK 0x00003fffc0000000UL
+#define UVH_RH_GAM_MMIOH_OVERLAY_CONFIG_MMR_M_IO_SHFT 46
+#define UVH_RH_GAM_MMIOH_OVERLAY_CONFIG_MMR_M_IO_MASK 0x000fc00000000000UL
+#define UVH_RH_GAM_MMIOH_OVERLAY_CONFIG_MMR_N_IO_SHFT 52
+#define UVH_RH_GAM_MMIOH_OVERLAY_CONFIG_MMR_N_IO_MASK 0x00f0000000000000UL
+#define UVH_RH_GAM_MMIOH_OVERLAY_CONFIG_MMR_ENABLE_SHFT 63
+#define UVH_RH_GAM_MMIOH_OVERLAY_CONFIG_MMR_ENABLE_MASK 0x8000000000000000UL
+
+union uvh_rh_gam_mmioh_overlay_config_mmr_u {
+    unsigned long	v;
+    struct uvh_rh_gam_mmioh_overlay_config_mmr_s {
+	unsigned long	rsvd_0_29: 30;  /*    */
+	unsigned long	base   : 16;  /* RW */
+	unsigned long	m_io   :  6;  /* RW */
+	unsigned long	n_io   :  4;  /* RW */
+	unsigned long	rsvd_56_62:  7;  /*    */
+	unsigned long	enable :  1;  /* RW */
+    } s;
+};
+
+/* ========================================================================= */
 /*                    UVH_RH_GAM_MMR_OVERLAY_CONFIG_MMR                      */
 /* ========================================================================= */
 #define UVH_RH_GAM_MMR_OVERLAY_CONFIG_MMR 0x1600028UL
Index: linux/include/asm-x86/uv/uv_hub.h
===================================================================
--- linux.orig/include/asm-x86/uv/uv_hub.h	2008-07-01 14:36:00.000000000 -0500
+++ linux/include/asm-x86/uv/uv_hub.h	2008-07-01 14:39:11.000000000 -0500
@@ -149,6 +149,8 @@ DECLARE_PER_CPU(struct uv_hub_info_s, __
 #define UV_LOCAL_MMR_BASE		0xf4000000UL
 #define UV_GLOBAL_MMR32_BASE		0xf8000000UL
 #define UV_GLOBAL_MMR64_BASE		(uv_hub_info->global_mmr_base)
+#define UV_LOCAL_MMR_SIZE		(64UL * 1024 * 1024)
+#define UV_GLOBAL_MMR32_SIZE		(64UL * 1024 * 1024)
 
 #define UV_GLOBAL_MMR32_PNODE_SHIFT	15
 #define UV_GLOBAL_MMR64_PNODE_SHIFT	26

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
