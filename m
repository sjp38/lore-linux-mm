Date: Mon, 24 Mar 2008 13:21:22 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: [RFC 8/8] x86_64: Support for new UV apic
Message-ID: <20080324182122.GA28327@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu, tglx@linutronix.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

UV supports really big systems. So big, in fact, that the APICID register
does not contain enough bits to contain an APICID that is unique across all
cpus.

The UV BIOS supports 3 APICID modes:

	- legacy mode. This mode uses the old APIC mode where
	  APICID is in bits [31:24] of the APICID register.

	- x2apic mode. This mode is whitebox-compatible. APICIDs
	  are unique across all cpus. Standard x2apic APIC operations
	  (Intel-defined) can be used for IPIs. The node identifier
	  fits within the Intel-defined portion of the APICID register.

	- x2apic-uv mode. In this mode, the APICIDs on each node have
	  unique IDs, but IDs on different node are not unique. For example,
	  if each mode has 32 cpus, the APICIDs on each node might be
	  0 - 31. Every node has the same set of IDs.
	  The UV hub is used to route IPIs/interrupts to the correct node.
	  Traditional APIC operations WILL NOT WORK.

In x2apic-uv mode, the ACPI tables all contain a full unique ID (note:
exact bit layout still changing but the following is close):
	
	nnnnnnnnnnlc0cch
		n = unique node number
		l = socket number on board
		c = core
		h = hyperthread
		
Only the "lc0cch" bits are written to the APICID register. The remaining bits are
supplied by having the get_apic_id() function "OR" the extra bits into the value
read from the APICID register. (Hmmm.. why not keep the ENTIRE APICID register
in per-cpu data....)

The x2apic-uv mode is recognized by the MADT table containing:
	  oem_id = "SGI"
	  oem_table_id = "UV-X"
	

(NOTE: a work-in-progress. Pieces missing....)


	Signed-off-by: Jack Steiner <steiner@sgi.com>

---
 arch/x86/kernel/Makefile         |    2 
 arch/x86/kernel/genapic_64.c     |   15 +
 arch/x86/kernel/genx2apic_uv_x.c |  305 +++++++++++++++++++++++++++++++++++++++
 arch/x86/kernel/setup64.c        |    4 
 arch/x86/kernel/smpboot_64.c     |    7 
 include/asm-x86/genapic_64.h     |    5 
 6 files changed, 335 insertions(+), 3 deletions(-)

Index: linux/arch/x86/kernel/genapic_64.c
===================================================================
--- linux.orig/arch/x86/kernel/genapic_64.c	2008-03-21 15:37:05.000000000 -0500
+++ linux/arch/x86/kernel/genapic_64.c	2008-03-21 15:49:38.000000000 -0500
@@ -30,6 +30,7 @@ u16 x86_cpu_to_apicid_init[NR_CPUS] __in
 void *x86_cpu_to_apicid_early_ptr;
 DEFINE_PER_CPU(u16, x86_cpu_to_apicid) = BAD_APICID;
 EXPORT_PER_CPU_SYMBOL(x86_cpu_to_apicid);
+DEFINE_PER_CPU(int, x2apic_extra_bits);
 
 struct genapic __read_mostly *genapic = &apic_flat;
 
@@ -40,6 +41,9 @@ static enum uv_system_type uv_system_typ
  */
 void __init setup_apic_routing(void)
 {
+	if (uv_system_type == UV_NON_UNIQUE_APIC)
+		genapic = &apic_x2apic_uv_x;
+	else
 #ifdef CONFIG_ACPI
 	/*
 	 * Quirk: some x86_64 machines can only use physical APIC mode
@@ -69,7 +73,16 @@ void send_IPI_self(int vector)
 
 unsigned int get_apic_id(void)
 {
-	return (apic_read(APIC_ID) >> 24) & 0xFFu;
+	unsigned int id;
+
+	preempt_disable();
+	id = apic_read(APIC_ID);
+	if (uv_system_type >= UV_X2APIC)
+		id  |= __get_cpu_var(x2apic_extra_bits);
+	else
+		id = (id >> 24) & 0xFFu;;
+	preempt_enable();
+	return id;
 }
 
 int __init acpi_madt_oem_check(char *oem_id, char *oem_table_id)
Index: linux/arch/x86/kernel/genx2apic_uv_x.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux/arch/x86/kernel/genx2apic_uv_x.c	2008-03-24 09:21:56.000000000 -0500
@@ -0,0 +1,305 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * SGI UV APIC functions (note: not an Intel compatible APIC)
+ *
+ * Copyright (C) 2007 Silicon Graphics, Inc. All rights reserved.
+ */
+
+#include <linux/threads.h>
+#include <linux/cpumask.h>
+#include <linux/string.h>
+#include <linux/kernel.h>
+#include <linux/ctype.h>
+#include <linux/init.h>
+#include <linux/sched.h>
+#include <linux/bootmem.h>
+#include <linux/module.h>
+#include <asm/smp.h>
+#include <asm/ipi.h>
+#include <asm/genapic.h>
+#include <asm/uv_mmrs.h>
+#include <asm/uv_hub.h>
+
+DEFINE_PER_CPU(struct uv_hub_info_s, __uv_hub_info);
+EXPORT_PER_CPU_SYMBOL(__uv_hub_info);
+
+struct uv_blade_info *uv_blade_info;
+EXPORT_SYMBOL_GPL(uv_blade_info);
+
+short *uv_node_to_blade;
+EXPORT_SYMBOL_GPL(uv_node_to_blade);
+
+short *uv_cpu_to_blade;
+EXPORT_SYMBOL_GPL(uv_cpu_to_blade);
+
+short uv_possible_blades;
+EXPORT_SYMBOL_GPL(uv_possible_blades);
+
+/* Start with all IRQs pointing to boot CPU.  IRQ balancing will shift them. */
+/* Probably incorrect for UV  ZZZ */
+
+static cpumask_t uv_target_cpus(void)
+{
+	return cpumask_of_cpu(0);
+}
+
+static cpumask_t uv_vector_allocation_domain(int cpu)
+{
+	cpumask_t domain = CPU_MASK_NONE;
+	cpu_set(cpu, domain);
+	return domain;
+}
+
+int uv_wakeup_secondary(int phys_apicid, unsigned int start_rip)
+{
+	unsigned long val;
+	int nasid;
+
+	printk(KERN_DEBUG "ZZZZZZZZZZZ send SIPI to apicid 0x%x, start 0x%x\n",
+	       phys_apicid, start_rip);
+	nasid = uv_apicid_to_nasid(phys_apicid);
+	val = (1UL << UVH_IPI_INT_SEND_SHFT) |
+	    (phys_apicid << UVH_IPI_INT_APIC_ID_SHFT) |
+	    (((long)start_rip << UVH_IPI_INT_VECTOR_SHFT) >> 12) |
+	    (6 << UVH_IPI_INT_DELIVERY_MODE_SHFT);
+	printk(KERN_DEBUG "ZZZZZZZZZZZ      nasid %d, val 0x%lx\n", nasid, val);
+	uv_write_global_mmr64(nasid, UVH_IPI_INT, val);
+	return 0;
+}
+
+static void uv_send_IPI_one(int cpu, int vector)
+{
+	unsigned long val, apicid;
+	int nasid;
+
+	apicid = per_cpu(x86_cpu_to_apicid, cpu); /* ZZZ - cache node-local ? */
+	nasid = uv_apicid_to_nasid(apicid);
+	val =
+	    (1UL << UVH_IPI_INT_SEND_SHFT) | (apicid <<
+					      UVH_IPI_INT_APIC_ID_SHFT) |
+	    (vector << UVH_IPI_INT_VECTOR_SHFT);
+	uv_write_global_mmr64(nasid, UVH_IPI_INT, val);
+	printk(KERN_DEBUG
+	     "UV: IPI to cpu %d, apicid 0x%lx, vec %d, nasid%d, val 0x%lx\n",
+	     cpu, apicid, vector, nasid, val);
+}
+
+static void uv_send_IPI_mask(cpumask_t mask, int vector)
+{
+	unsigned long flags;
+	unsigned int cpu;
+
+	local_irq_save(flags);
+	for (cpu = 0; cpu < NR_CPUS; ++cpu)
+		if (cpu_isset(cpu, mask))
+			uv_send_IPI_one(cpu, vector);
+	local_irq_restore(flags);
+}
+
+static void uv_send_IPI_allbutself(int vector)
+{
+	cpumask_t mask = cpu_online_map;
+
+	cpu_clear(smp_processor_id(), mask);
+
+	if (!cpus_empty(mask))
+		uv_send_IPI_mask(mask, vector);
+}
+
+static void uv_send_IPI_all(int vector)
+{
+	uv_send_IPI_mask(cpu_online_map, vector);
+}
+
+static int uv_apic_id_registered(void)
+{
+	return 1;
+}
+
+static unsigned int uv_cpu_mask_to_apicid(cpumask_t cpumask)
+{
+	int cpu;
+
+	/*
+	 * We're using fixed IRQ delivery, can only return one phys APIC ID.
+	 * May as well be the first.
+	 */
+	cpu = first_cpu(cpumask);
+	if ((unsigned)cpu < NR_CPUS)
+		return per_cpu(x86_cpu_to_apicid, cpu);
+	else
+		return BAD_APICID;
+}
+
+static unsigned int phys_pkg_id(int index_msb)
+{
+	return get_apic_id() >> index_msb;
+}
+
+#ifdef ZZZ
+static void uv_send_IPI_self(int vector)
+{
+	apic_write(APIC_SELF_IPI, vector);
+}
+#endif
+
+struct genapic apic_x2apic_uv_x = {
+	.name = "UV large system",
+	.int_delivery_mode = dest_Fixed,
+	.int_dest_mode = (APIC_DEST_PHYSICAL != 0),
+	.target_cpus = uv_target_cpus,
+	.vector_allocation_domain = uv_vector_allocation_domain,/* Fixme ZZZ */
+	.apic_id_registered = uv_apic_id_registered,
+	.send_IPI_all = uv_send_IPI_all,
+	.send_IPI_allbutself = uv_send_IPI_allbutself,
+	.send_IPI_mask = uv_send_IPI_mask,
+	/* ZZZ.send_IPI_self = uv_send_IPI_self, */
+	.cpu_mask_to_apicid = uv_cpu_mask_to_apicid,
+	.phys_pkg_id = phys_pkg_id,	/* Fixme ZZZ */
+};
+
+static __cpuinit void set_x2apic_extra_bits(int nasid)
+{
+	__get_cpu_var(x2apic_extra_bits) = ((nasid >> 1) << 6);
+}
+
+/*
+ * Called on boot cpu.
+ */
+static __init void uv_system_init(void)
+{
+	union uvh_si_addr_map_config_u m_n_config;
+	int bytes, nid, cpu, lcpu, nasid, last_nasid, blade;
+	unsigned long mmr_base;
+
+	m_n_config.v = uv_read_local_mmr(UVH_SI_ADDR_MAP_CONFIG);
+	mmr_base =
+	    uv_read_local_mmr(UVH_RH_GAM_MMR_OVERLAY_CONFIG_MMR) &
+	    ~UV_MMR_ENABLE;
+	printk(KERN_DEBUG "UV: global MMR base 0x%lx\n", mmr_base);
+
+	last_nasid = -1;
+	for_each_possible_cpu(cpu) {
+		nid = cpu_to_node(cpu);
+		nasid = uv_apicid_to_nasid(per_cpu(x86_cpu_to_apicid, cpu));
+		if (nasid != last_nasid)
+			uv_possible_blades++;
+		last_nasid = nasid;
+	}
+	printk(KERN_DEBUG "UV: Found %d blades\n", uv_num_possible_blades());
+
+	bytes = sizeof(struct uv_blade_info) * uv_num_possible_blades();
+	uv_blade_info = alloc_bootmem_pages(bytes);
+	memset(uv_blade_info, 255, bytes);
+
+	bytes = sizeof(uv_node_to_blade[0]) * num_possible_nodes();
+	uv_node_to_blade = alloc_bootmem_pages(bytes);
+	memset(uv_node_to_blade, 255, bytes);
+
+	bytes = sizeof(uv_cpu_to_blade[0]) * num_possible_cpus();
+	uv_cpu_to_blade = alloc_bootmem_pages(bytes);
+	memset(uv_cpu_to_blade, 255, bytes);
+
+	last_nasid = -1;
+	blade = -1;
+	lcpu = -1;
+	for_each_possible_cpu(cpu) {
+		nid = cpu_to_node(cpu);
+		nasid = uv_apicid_to_nasid(per_cpu(x86_cpu_to_apicid, cpu));
+		if (nasid != last_nasid) {
+			blade++;
+			lcpu = -1;
+			uv_blade_info[blade].nr_posible_cpus = 0;
+			uv_blade_info[blade].nr_online_cpus = 0;
+		}
+		last_nasid = nasid;
+		lcpu++;
+
+		uv_cpu_hub_info(cpu)->m_val = m_n_config.s.m_skt;
+		uv_cpu_hub_info(cpu)->n_val = m_n_config.s.n_skt;
+		uv_cpu_hub_info(cpu)->numa_blade_id = blade;
+		uv_cpu_hub_info(cpu)->blade_processor_id = lcpu;
+		uv_cpu_hub_info(cpu)->local_nasid = nasid;
+		uv_cpu_hub_info(cpu)->gnode_upper =
+		    nasid & ~((1 << uv_hub_info->n_val) - 1);
+		uv_cpu_hub_info(cpu)->global_mmr_base = mmr_base;
+		uv_cpu_hub_info(cpu)->coherency_domain_number = 0;/* ZZZ */
+		uv_blade_info[blade].nasid = nasid;
+		uv_blade_info[blade].nr_posible_cpus++;
+		uv_node_to_blade[nid] = blade;
+		uv_cpu_to_blade[cpu] = blade;
+
+		printk(KERN_DEBUG "UV cpu %d, apicid 0x%x, nasid %d, nid %d\n",
+		       cpu, per_cpu(x86_cpu_to_apicid, cpu), nasid, nid);
+		printk(KERN_DEBUG "UV   lcpu %d, blade %d\n", lcpu, blade);
+
+#ifdef ZZZ
+		printk(KERN_DEBUG "UV ZZZZ nasid %d\n", nasid);
+		printk(KERN_DEBUG "UV  ZZZ local paddr %p\n",
+		       __pa(uv_local_mmr_address
+			    (UVH_LB_BAU_SB_DESCRIPTOR_BASE)));
+		printk(KERN_DEBUG "UV  ZZZ global paddr %p\n",
+		       __pa(uv_global_mmr64_address
+			    (nasid, UVH_LB_BAU_SB_DESCRIPTOR_BASE)));
+		printk(KERN_DEBUG "UV  ZZZ global32 paddr %p\n",
+		       __pa(uv_global_mmr32_address
+			    (nasid, UVH_LB_BAU_SB_DESCRIPTOR_BASE_32)));
+		printk(KERN_DEBUG "UV  ZZZ local addr %p\n",
+		       uv_local_mmr_address(UVH_LB_BAU_SB_DESCRIPTOR_BASE));
+		printk(KERN_DEBUG "UV  ZZZ global addr %p\n",
+		       uv_global_mmr64_address(nasid,
+					       UVH_LB_BAU_SB_DESCRIPTOR_BASE));
+		printk(KERN_DEBUG "UV  ZZZ global32 addr %p\n",
+		       uv_global_mmr32_address(nasid,
+					UVH_LB_BAU_SB_DESCRIPTOR_BASE_32));
+
+		printk(KERN_DEBUG "UV  ZZZ local 0x%lx\n",
+		       uv_read_local_mmr(UVH_LB_BAU_SB_DESCRIPTOR_BASE));
+		printk(KERN_DEBUG "UV  ZZZ global 0x%lx\n",
+		       uv_read_global_mmr64(nasid,
+					    UVH_LB_BAU_SB_DESCRIPTOR_BASE));
+		printk(KERN_DEBUG "UV  ZZZ global32 0x%lx\n",
+		       uv_read_global_mmr32(nasid,
+					    UVH_LB_BAU_SB_DESCRIPTOR_BASE_32));
+#endif
+	}
+}
+
+/*
+ * Called on each cpu to initialize the per_cpu UV data area.
+ */
+void __cpuinit uv_cpu_init(void)
+{
+	if (!uv_node_to_blade)
+		uv_system_init();
+
+	uv_blade_info[uv_numa_blade_id()].nr_online_cpus++;
+
+	if (get_uv_system_type() == UV_NON_UNIQUE_APIC)
+		set_x2apic_extra_bits(uv_hub_info->local_nasid);
+
+#ifndef ZZZ
+	printk(KERN_DEBUG
+	       "UV cpu %d, lcpu %d, blade %d, nasid %d/%d/%d, possible %d,"
+	       " online %d, cputoblade %d, uv_node_to_blade_id %d\n",
+	       smp_processor_id(), uv_blade_processor_id(), uv_numa_blade_id(),
+	       uv_blade_to_nasid(uv_numa_blade_id()),
+	       uv_cpu_to_nasid(smp_processor_id()),
+	       uv_node_to_nasid(numa_node_id()),
+	       uv_blade_nr_possible_cpus(uv_numa_blade_id()),
+	       uv_blade_nr_online_cpus(uv_numa_blade_id()),
+	       uv_cpu_to_blade_id(smp_processor_id()),
+	       uv_node_to_blade_id(numa_node_id()));
+
+	printk(KERN_DEBUG
+	       "UV cpu %d: hdw_apic_id 0x%x, extra_apic 0x%x, nasid 0x%x, "
+	       "M %d, N %d, nasid_h 0x%x, mmrs 0x%lx\n",
+	       smp_processor_id(), apic_read(APIC_ID),
+	       __get_cpu_var(x2apic_extra_bits), uv_hub_info->local_nasid,
+	       uv_hub_info->m_val, uv_hub_info->n_val, uv_hub_info->gnode_upper,
+	       uv_hub_info->global_mmr_base);
+#endif
+}
Index: linux/arch/x86/kernel/setup64.c
===================================================================
--- linux.orig/arch/x86/kernel/setup64.c	2008-03-21 15:36:35.000000000 -0500
+++ linux/arch/x86/kernel/setup64.c	2008-03-21 15:49:38.000000000 -0500
@@ -24,6 +24,7 @@
 #include <asm/proto.h>
 #include <asm/sections.h>
 #include <asm/setup.h>
+#include <asm/genapic.h>
 
 #ifndef CONFIG_DEBUG_BOOT_PARAMS
 struct boot_params __initdata boot_params;
@@ -355,4 +356,7 @@ void __cpuinit cpu_init (void)
 	fpu_init(); 
 
 	raw_local_save_flags(kernel_eflags);
+
+	if (is_uv_system())
+		uv_cpu_init();
 }
Index: linux/arch/x86/kernel/Makefile
===================================================================
--- linux.orig/arch/x86/kernel/Makefile	2008-03-21 15:36:35.000000000 -0500
+++ linux/arch/x86/kernel/Makefile	2008-03-21 15:49:38.000000000 -0500
@@ -90,7 +90,7 @@ scx200-y			+= scx200_32.o
 ###
 # 64 bit specific files
 ifeq ($(CONFIG_X86_64),y)
-        obj-y				+= genapic_64.o genapic_flat_64.o
+        obj-y				+= genapic_64.o genapic_flat_64.o genx2apic_uv_x.o
         obj-$(CONFIG_X86_PM_TIMER)	+= pmtimer_64.o
         obj-$(CONFIG_AUDIT)		+= audit_64.o
 
Index: linux/arch/x86/kernel/smpboot_64.c
===================================================================
--- linux.orig/arch/x86/kernel/smpboot_64.c	2008-03-21 15:36:45.000000000 -0500
+++ linux/arch/x86/kernel/smpboot_64.c	2008-03-21 15:49:38.000000000 -0500
@@ -60,6 +60,7 @@
 #include <asm/hw_irq.h>
 #include <asm/numa.h>
 #include <asm/trampoline.h>
+#include <asm/genapic.h>
 
 /* Number of siblings per CPU package */
 int smp_num_siblings = 1;
@@ -418,6 +419,9 @@ static int __cpuinit wakeup_secondary_vi
 	unsigned long send_status, accept_status = 0;
 	int maxlvt, num_starts, j;
 
+	if (get_uv_system_type() == UV_NON_UNIQUE_APIC)
+		return uv_wakeup_secondary(phys_apicid, start_rip);
+
 	Dprintk("Asserting INIT.\n");
 
 	/*
@@ -679,7 +683,8 @@ do_rest:
 				/* trampoline code not run */
 				printk("Not responding.\n");
 #ifdef APIC_DEBUG
-			inquire_remote_apic(apicid);
+			if (get_uv_system_type() != UV_NON_UNIQUE_APIC)
+				inquire_remote_apic(apicid);
 #endif
 		}
 	}
Index: linux/include/asm-x86/genapic_64.h
===================================================================
--- linux.orig/include/asm-x86/genapic_64.h	2008-03-21 15:37:05.000000000 -0500
+++ linux/include/asm-x86/genapic_64.h	2008-03-21 15:49:38.000000000 -0500
@@ -39,4 +39,9 @@ enum uv_system_type {UV_NONE, UV_LEGACY_
 extern enum uv_system_type get_uv_system_type(void);
 extern int is_uv_system(void);
 
+extern struct genapic apic_x2apic_uv_x;
+DECLARE_PER_CPU(int, x2apic_extra_bits);
+extern void uv_cpu_init(void);
+extern int uv_wakeup_secondary(int phys_apicid, unsigned int start_rip);
+
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
