Date: Mon, 24 Mar 2008 13:21:12 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: [RFC 3/8] x86_64: Increase size of APICID
Message-ID: <20080324182112.GA28026@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu, tglx@linutronix.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Increase the number of bits in an apicid from 8 to 32.

By default, MP_processor_info() gets the APICID from the
mpc_config_processor structure. However, this structure limits
the size of APICID to 8 bits. This patch allows the caller of
MP_processor_info() to optionally pass a larger APICID that will
be used instead of the one in the mpc_config_processor struct.



	Signed-off-by: Jack Steiner <steiner@sgi.com>

---
 arch/x86/kernel/mpparse_64.c |   29 ++++++++++++++++-------------
 arch/x86/mm/srat_64.c        |    6 +++++-
 include/asm-x86/apicdef.h    |    4 ++--
 include/asm-x86/mpspec.h     |    2 +-
 4 files changed, 24 insertions(+), 17 deletions(-)

Index: linux/arch/x86/kernel/mpparse_64.c
===================================================================
--- linux.orig/arch/x86/kernel/mpparse_64.c	2008-03-21 15:36:45.000000000 -0500
+++ linux/arch/x86/kernel/mpparse_64.c	2008-03-21 15:38:52.000000000 -0500
@@ -92,7 +92,8 @@ static int __init mpf_checksum(unsigned 
 	return sum & 0xFF;
 }
 
-static void __cpuinit MP_processor_info(struct mpc_config_processor *m)
+static void __cpuinit MP_processor_info(struct mpc_config_processor *m,
+					int apicid)
 {
 	int cpu;
 	cpumask_t tmp_map;
@@ -102,12 +103,14 @@ static void __cpuinit MP_processor_info(
 		disabled_cpus++;
 		return;
 	}
+	if (apicid < 0)
+		apicid = m->mpc_apicid;
 	if (m->mpc_cpuflag & CPU_BOOTPROCESSOR) {
 		bootup_cpu = " (Bootup-CPU)";
-		boot_cpu_id = m->mpc_apicid;
+		boot_cpu_id = apicid;
 	}
 
-	printk(KERN_INFO "Processor #%d%s\n", m->mpc_apicid, bootup_cpu);
+	printk(KERN_INFO "Processor #%d%s\n", apicid, bootup_cpu);
 
 	if (num_processors >= NR_CPUS) {
 		printk(KERN_WARNING "WARNING: NR_CPUS limit of %i reached."
@@ -119,7 +122,7 @@ static void __cpuinit MP_processor_info(
 	cpus_complement(tmp_map, cpu_present_map);
 	cpu = first_cpu(tmp_map);
 
-	physid_set(m->mpc_apicid, phys_cpu_present_map);
+	physid_set(apicid, phys_cpu_present_map);
  	if (m->mpc_cpuflag & CPU_BOOTPROCESSOR) {
  		/*
 		 * x86_bios_cpu_apicid is required to have processors listed
@@ -133,11 +136,11 @@ static void __cpuinit MP_processor_info(
 		u16 *cpu_to_apicid = x86_cpu_to_apicid_early_ptr;
 		u16 *bios_cpu_apicid = x86_bios_cpu_apicid_early_ptr;
 
-		cpu_to_apicid[cpu] = m->mpc_apicid;
-		bios_cpu_apicid[cpu] = m->mpc_apicid;
+		cpu_to_apicid[cpu] = apicid;
+		bios_cpu_apicid[cpu] = apicid;
 	} else {
-		per_cpu(x86_cpu_to_apicid, cpu) = m->mpc_apicid;
-		per_cpu(x86_bios_cpu_apicid, cpu) = m->mpc_apicid;
+		per_cpu(x86_cpu_to_apicid, cpu) = apicid;
+		per_cpu(x86_bios_cpu_apicid, cpu) = apicid;
 	}
 
 	cpu_set(cpu, cpu_possible_map);
@@ -269,7 +272,7 @@ static int __init smp_read_mpc(struct mp
 				struct mpc_config_processor *m=
 					(struct mpc_config_processor *)mpt;
 				if (!acpi_lapic)
-					MP_processor_info(m);
+					MP_processor_info(m, -1);
 				mpt += sizeof(*m);
 				count += sizeof(*m);
 				break;
@@ -419,7 +422,7 @@ static inline void __init construct_defa
 	processor.mpc_reserved[1] = 0;
 	for (i = 0; i < 2; i++) {
 		processor.mpc_apicid = i;
-		MP_processor_info(&processor);
+		MP_processor_info(&processor, -1);
 	}
 
 	bus.mpc_type = MP_BUS;
@@ -617,7 +620,7 @@ void __init mp_register_lapic_address(u6
 		boot_cpu_id = get_apic_id();
 }
 
-void __cpuinit mp_register_lapic (u8 id, u8 enabled)
+void __cpuinit mp_register_lapic(int id, u8 enabled)
 {
 	struct mpc_config_processor processor;
 	int			boot_cpu = 0;
@@ -626,7 +629,7 @@ void __cpuinit mp_register_lapic (u8 id,
 		boot_cpu = 1;
 
 	processor.mpc_type = MP_PROCESSOR;
-	processor.mpc_apicid = id;
+	processor.mpc_apicid = 0;
 	processor.mpc_apicver = 0;
 	processor.mpc_cpuflag = (enabled ? CPU_ENABLED : 0);
 	processor.mpc_cpuflag |= (boot_cpu ? CPU_BOOTPROCESSOR : 0);
@@ -635,7 +638,7 @@ void __cpuinit mp_register_lapic (u8 id,
 	processor.mpc_reserved[0] = 0;
 	processor.mpc_reserved[1] = 0;
 
-	MP_processor_info(&processor);
+	MP_processor_info(&processor, id);
 }
 
 #define MP_ISA_BUS		0
Index: linux/include/asm-x86/mpspec.h
===================================================================
--- linux.orig/include/asm-x86/mpspec.h	2008-03-21 15:36:38.000000000 -0500
+++ linux/include/asm-x86/mpspec.h	2008-03-21 15:37:22.000000000 -0500
@@ -42,7 +42,7 @@ extern void find_smp_config(void);
 extern void get_smp_config(void);
 
 #ifdef CONFIG_ACPI
-extern void mp_register_lapic(u8 id, u8 enabled);
+extern void mp_register_lapic(int id, u8 enabled);
 extern void mp_register_lapic_address(u64 address);
 extern void mp_register_ioapic(u8 id, u32 address, u32 gsi_base);
 extern void mp_override_legacy_irq(u8 bus_irq, u8 polarity, u8 trigger,
Index: linux/arch/x86/mm/srat_64.c
===================================================================
--- linux.orig/arch/x86/mm/srat_64.c	2008-03-21 15:36:38.000000000 -0500
+++ linux/arch/x86/mm/srat_64.c	2008-03-21 15:37:22.000000000 -0500
@@ -20,6 +20,7 @@
 #include <asm/proto.h>
 #include <asm/numa.h>
 #include <asm/e820.h>
+#include <asm/genapic.h>
 
 int acpi_numa __initdata;
 
@@ -148,7 +149,10 @@ acpi_numa_processor_affinity_init(struct
 		return;
 	}
 
-	apic_id = pa->apic_id;
+	if (is_uv_system())
+		apic_id = (pa->apic_id << 8) | pa->local_sapic_eid;
+	else
+		apic_id = pa->apic_id;
 	apicid_to_node[apic_id] = node;
 	acpi_numa = 1;
 	printk(KERN_INFO "SRAT: PXM %u -> APIC %u -> Node %u\n",
Index: linux/include/asm-x86/apicdef.h
===================================================================
--- linux.orig/include/asm-x86/apicdef.h	2008-03-21 15:36:45.000000000 -0500
+++ linux/include/asm-x86/apicdef.h	2008-03-21 15:37:22.000000000 -0500
@@ -134,7 +134,7 @@
 # define MAX_IO_APICS 64
 #else
 # define MAX_IO_APICS 128
-# define MAX_LOCAL_APIC 256
+# define MAX_LOCAL_APIC 32768
 #endif
 
 /*
@@ -407,6 +407,6 @@ struct local_apic {
 
 #undef u32
 
-#define BAD_APICID 0xFFu
+#define BAD_APICID 0xFFFFu
 
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
