Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A3D316B004F
	for <linux-mm@kvack.org>; Mon, 27 Jul 2009 10:36:56 -0400 (EDT)
Date: Mon, 27 Jul 2009 09:36:56 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: [PATCH] x86, UV: Delete mapping of MMR rangs mapped by BIOS
Message-ID: <20090727143656.GA7698@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: mingo@elte.hu, tglx@linutronix.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The UV BIOS has added additional MMR ranges that
are mapped via EFI virtual mode mappings. These ranges
should be deleted from ranges mapped by uv_system_init().


Signed-off-by: Jack Steiner <steiner@sgi.com>

---
 arch/x86/kernel/apic/x2apic_uv_x.c |   31 +------------------------------
 1 file changed, 1 insertion(+), 30 deletions(-)

Index: linux/arch/x86/kernel/apic/x2apic_uv_x.c
===================================================================
--- linux.orig/arch/x86/kernel/apic/x2apic_uv_x.c	2009-07-23 09:44:41.000000000 -0500
+++ linux/arch/x86/kernel/apic/x2apic_uv_x.c	2009-07-23 09:45:34.000000000 -0500
@@ -363,12 +363,6 @@ static __init void get_lowmem_redirect(u
 	panic("get_lowmem_redirect: no match!");
 }
 
-static __init void map_low_mmrs(void)
-{
-	init_extra_mapping_uc(UV_GLOBAL_MMR32_BASE, UV_GLOBAL_MMR32_SIZE);
-	init_extra_mapping_uc(UV_LOCAL_MMR_BASE, UV_LOCAL_MMR_SIZE);
-}
-
 enum map_type {map_wb, map_uc};
 
 static __init void map_high(char *id, unsigned long base, int shift,
@@ -396,26 +390,6 @@ static __init void map_gru_high(int max_
 		map_high("GRU", gru.s.base, shift, max_pnode, map_wb);
 }
 
-static __init void map_config_high(int max_pnode)
-{
-	union uvh_rh_gam_cfg_overlay_config_mmr_u cfg;
-	int shift = UVH_RH_GAM_CFG_OVERLAY_CONFIG_MMR_BASE_SHFT;
-
-	cfg.v = uv_read_local_mmr(UVH_RH_GAM_CFG_OVERLAY_CONFIG_MMR);
-	if (cfg.s.enable)
-		map_high("CONFIG", cfg.s.base, shift, max_pnode, map_uc);
-}
-
-static __init void map_mmr_high(int max_pnode)
-{
-	union uvh_rh_gam_mmr_overlay_config_mmr_u mmr;
-	int shift = UVH_RH_GAM_MMR_OVERLAY_CONFIG_MMR_BASE_SHFT;
-
-	mmr.v = uv_read_local_mmr(UVH_RH_GAM_MMR_OVERLAY_CONFIG_MMR);
-	if (mmr.s.enable)
-		map_high("MMR", mmr.s.base, shift, max_pnode, map_uc);
-}
-
 static __init void map_mmioh_high(int max_pnode)
 {
 	union uvh_rh_gam_mmioh_overlay_config_mmr_u mmioh;
@@ -567,8 +541,6 @@ void __init uv_system_init(void)
 	unsigned long mmr_base, present, paddr;
 	unsigned short pnode_mask;
 
-	map_low_mmrs();
-
 	m_n_config.v = uv_read_local_mmr(UVH_SI_ADDR_MAP_CONFIG);
 	m_val = m_n_config.s.m_skt;
 	n_val = m_n_config.s.n_skt;
@@ -668,11 +640,10 @@ void __init uv_system_init(void)
 		pnode = (paddr >> m_val) & pnode_mask;
 		blade = boot_pnode_to_blade(pnode);
 		uv_node_to_blade[nid] = blade;
+		max_pnode = max(pnode, max_pnode);
 	}
 
 	map_gru_high(max_pnode);
-	map_mmr_high(max_pnode);
-	map_config_high(max_pnode);
 	map_mmioh_high(max_pnode);
 
 	uv_cpu_init();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
