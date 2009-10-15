Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1E0D56B005A
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 18:49:50 -0400 (EDT)
From: Robin Holt <holt@sgi.com>
Message-Id: <20091015224946.396355000@alcatraz.americas.sgi.com>
Date: Thu, 15 Oct 2009 17:40:00 -0500
Subject: [patch 1/2] x86, UV: Fix information in __uv_hub_info structure.
References: <20091015223959.783988000@alcatraz.americas.sgi.com>
Content-Disposition: inline; filename=uv_hub_info_fix
Sender: owner-linux-mm@kvack.org
To: mingo@elte.hu, tglx@linutronix.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Cliff Whickman <cpw@sgi.com>, stable@kernel.org
List-ID: <linux-mm.kvack.org>


A few parts of the uv_hub_info structure are initialized incorrectly.

 - n_val is being loaded with m_val.
 - gpa_mask is initialized with a bytes instead of an unsigned long.
 - Handle the case where none of the alias registers are used.

Lastly I converted the bau over to using the uv_hub_info->m_val which
is the correct value.

To: Ingo Molnar <mingo@elte.hu>
To: tglx@linutronix.de
Signed-off-by: Robin Holt <holt@sgi.com>
Signed-off-by: Jack Steiner <steiner@sgi.com>
Cc: stable@kernel.org
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

---
 arch/x86/kernel/apic/x2apic_uv_x.c |    8 ++++----
 arch/x86/kernel/tlb_uv.c           |    4 ++--
 2 files changed, 6 insertions(+), 6 deletions(-)
Index: linux/arch/x86/kernel/apic/x2apic_uv_x.c
===================================================================
--- linux.orig/arch/x86/kernel/apic/x2apic_uv_x.c	2009-10-15 17:02:33.000000000 -0500
+++ linux/arch/x86/kernel/apic/x2apic_uv_x.c	2009-10-15 17:24:13.000000000 -0500
@@ -352,14 +352,14 @@ static __init void get_lowmem_redirect(u
 
 	for (i = 0; i < ARRAY_SIZE(redir_addrs); i++) {
 		alias.v = uv_read_local_mmr(redir_addrs[i].alias);
-		if (alias.s.base == 0) {
+		if (alias.s.enable && alias.s.base == 0) {
 			*size = (1UL << alias.s.m_alias);
 			redirect.v = uv_read_local_mmr(redir_addrs[i].redirect);
 			*base = (unsigned long)redirect.s.dest_base << DEST_SHIFT;
 			return;
 		}
 	}
-	BUG();
+	*base = *size = 0;
 }
 
 enum map_type {map_wb, map_uc};
@@ -619,12 +619,12 @@ void __init uv_system_init(void)
 		uv_cpu_hub_info(cpu)->lowmem_remap_base = lowmem_redir_base;
 		uv_cpu_hub_info(cpu)->lowmem_remap_top = lowmem_redir_size;
 		uv_cpu_hub_info(cpu)->m_val = m_val;
-		uv_cpu_hub_info(cpu)->n_val = m_val;
+		uv_cpu_hub_info(cpu)->n_val = n_val;
 		uv_cpu_hub_info(cpu)->numa_blade_id = blade;
 		uv_cpu_hub_info(cpu)->blade_processor_id = lcpu;
 		uv_cpu_hub_info(cpu)->pnode = pnode;
 		uv_cpu_hub_info(cpu)->pnode_mask = pnode_mask;
-		uv_cpu_hub_info(cpu)->gpa_mask = (1 << (m_val + n_val)) - 1;
+		uv_cpu_hub_info(cpu)->gpa_mask = (1UL << (m_val + n_val)) - 1;
 		uv_cpu_hub_info(cpu)->gnode_upper = gnode_upper;
 		uv_cpu_hub_info(cpu)->gnode_extra = gnode_extra;
 		uv_cpu_hub_info(cpu)->global_mmr_base = mmr_base;
Index: linux/arch/x86/kernel/tlb_uv.c
===================================================================
--- linux.orig/arch/x86/kernel/tlb_uv.c	2009-10-15 17:02:33.000000000 -0500
+++ linux/arch/x86/kernel/tlb_uv.c	2009-10-15 17:29:32.000000000 -0500
@@ -843,8 +843,8 @@ static int __init uv_bau_init(void)
 				       GFP_KERNEL, cpu_to_node(cur_cpu));
 
 	uv_bau_retry_limit = 1;
-	uv_nshift = uv_hub_info->n_val;
-	uv_mmask = (1UL << uv_hub_info->n_val) - 1;
+	uv_nshift = uv_hub_info->m_val;
+	uv_mmask = (1UL << uv_hub_info->m_val) - 1;
 	nblades = uv_num_possible_blades();
 
 	uv_bau_table_bases = (struct bau_control **)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
