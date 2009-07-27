Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B32BB6B004D
	for <linux-mm@kvack.org>; Mon, 27 Jul 2009 10:35:10 -0400 (EDT)
Date: Mon, 27 Jul 2009 09:35:07 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: [PATCH] x86, UV: blade-local memory 
Message-ID: <20090727143507.GA7006@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: mingo@elte.hu, tglx@linutronix.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

UV blades may not have any blade-local memory. Add a field (nid) to the UV
blade structure to indicates whether the node has local memory.
This is needed by the GRU driver (pushed separately).


Signed-off-by: Jack Steiner <steiner@sgi.com>

---
 arch/x86/include/asm/uv/uv_hub.h   |    7 +++++++
 arch/x86/kernel/apic/x2apic_uv_x.c |    5 +++++
 2 files changed, 12 insertions(+)

Index: linux/arch/x86/include/asm/uv/uv_hub.h
===================================================================
--- linux.orig/arch/x86/include/asm/uv/uv_hub.h	2009-07-23 09:17:15.000000000 -0500
+++ linux/arch/x86/include/asm/uv/uv_hub.h	2009-07-23 09:44:41.000000000 -0500
@@ -327,6 +327,7 @@ struct uv_blade_info {
 	unsigned short	nr_possible_cpus;
 	unsigned short	nr_online_cpus;
 	unsigned short	pnode;
+	short		memory_nid;
 };
 extern struct uv_blade_info *uv_blade_info;
 extern short *uv_node_to_blade;
@@ -363,6 +364,12 @@ static inline int uv_blade_to_pnode(int 
 	return uv_blade_info[bid].pnode;
 }
 
+/* Nid of memory node on blade. -1 if no blade-local memory */
+static inline int uv_blade_to_memory_nid(int bid)
+{
+	return uv_blade_info[bid].memory_nid;
+}
+
 /* Determine the number of possible cpus on a blade */
 static inline int uv_blade_nr_possible_cpus(int bid)
 {
Index: linux/arch/x86/kernel/apic/x2apic_uv_x.c
===================================================================
--- linux.orig/arch/x86/kernel/apic/x2apic_uv_x.c	2009-07-23 09:17:15.000000000 -0500
+++ linux/arch/x86/kernel/apic/x2apic_uv_x.c	2009-07-23 09:44:41.000000000 -0500
@@ -592,6 +592,8 @@ void __init uv_system_init(void)
 	bytes = sizeof(struct uv_blade_info) * uv_num_possible_blades();
 	uv_blade_info = kmalloc(bytes, GFP_KERNEL);
 	BUG_ON(!uv_blade_info);
+	for (blade = 0; blade < uv_num_possible_blades(); blade++)
+		uv_blade_info[blade].memory_nid = -1;
 
 	get_lowmem_redirect(&lowmem_redir_base, &lowmem_redir_size);
 
@@ -630,6 +632,9 @@ void __init uv_system_init(void)
 		lcpu = uv_blade_info[blade].nr_possible_cpus;
 		uv_blade_info[blade].nr_possible_cpus++;
 
+		/* Any node on the blade, else will contain -1. */
+		uv_blade_info[blade].memory_nid = nid;
+
 		uv_cpu_hub_info(cpu)->lowmem_remap_base = lowmem_redir_base;
 		uv_cpu_hub_info(cpu)->lowmem_remap_top = lowmem_redir_size;
 		uv_cpu_hub_info(cpu)->m_val = m_val;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
