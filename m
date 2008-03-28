Date: Fri, 28 Mar 2008 14:12:02 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: [PATCH 1/8] x86_64: Change GET_APIC_ID() from an inline function to an out-of-line function
Message-ID: <20080328191202.GA16420@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu, tglx@linutronix.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Introduce a function to read the local APIC_ID.

This change is in preparation for additional changes to
the APICID functions that will come in a later patch.

Based on:
        git://git.kernel.org/pub/scm/linux/kernel/git/x86/linux-2.6-x86.git

Signed-off-by: Jack Steiner <steiner@sgi.com>

---
 arch/x86/kernel/apic_32.c                |    4 ++--
 arch/x86/kernel/apic_64.c                |   10 +++++-----
 arch/x86/kernel/genapic_flat_64.c        |    2 +-
 arch/x86/kernel/io_apic_32.c             |    6 +++---
 arch/x86/kernel/io_apic_64.c             |    5 ++---
 arch/x86/kernel/mpparse_32.c             |    2 +-
 arch/x86/kernel/mpparse_64.c             |    2 +-
 arch/x86/kernel/smpboot.c                |    6 +++---
 include/asm-x86/mach-default/mach_apic.h |    2 +-
 include/asm-x86/mach-es7000/mach_apic.h  |    2 +-
 include/asm-x86/mach-visws/mach_apic.h   |    2 +-
 include/asm-x86/smp.h                    |    7 ++++++-
 12 files changed, 27 insertions(+), 23 deletions(-)

Index: linux/arch/x86/kernel/apic_32.c
===================================================================
--- linux.orig/arch/x86/kernel/apic_32.c	2008-03-28 11:47:10.000000000 -0500
+++ linux/arch/x86/kernel/apic_32.c	2008-03-28 11:49:38.000000000 -0500
@@ -1195,7 +1195,7 @@ void __init init_apic_mappings(void)
 	 * default configuration (or the MP table is broken).
 	 */
 	if (boot_cpu_physical_apicid == -1U)
-		boot_cpu_physical_apicid = GET_APIC_ID(apic_read(APIC_ID));
+		boot_cpu_physical_apicid = GET_APIC_ID(read_apic_id());
 
 #ifdef CONFIG_X86_IO_APIC
 	{
@@ -1265,7 +1265,7 @@ int __init APIC_init_uniprocessor(void)
 	 * might be zero if read from MP tables. Get it from LAPIC.
 	 */
 #ifdef CONFIG_CRASH_DUMP
-	boot_cpu_physical_apicid = GET_APIC_ID(apic_read(APIC_ID));
+	boot_cpu_physical_apicid = GET_APIC_ID(read_apic_id());
 #endif
 	phys_cpu_present_map = physid_mask_of_physid(boot_cpu_physical_apicid);
 
Index: linux/arch/x86/kernel/apic_64.c
===================================================================
--- linux.orig/arch/x86/kernel/apic_64.c	2008-03-28 11:47:10.000000000 -0500
+++ linux/arch/x86/kernel/apic_64.c	2008-03-28 11:49:38.000000000 -0500
@@ -650,10 +650,10 @@ int __init verify_local_APIC(void)
 	/*
 	 * The ID register is read/write in a real APIC.
 	 */
-	reg0 = apic_read(APIC_ID);
+	reg0 = read_apic_id();
 	apic_printk(APIC_DEBUG, "Getting ID: %x\n", reg0);
 	apic_write(APIC_ID, reg0 ^ APIC_ID_MASK);
-	reg1 = apic_read(APIC_ID);
+	reg1 = read_apic_id();
 	apic_printk(APIC_DEBUG, "Getting ID: %x\n", reg1);
 	apic_write(APIC_ID, reg0);
 	if (reg1 != (reg0 ^ APIC_ID_MASK))
@@ -892,7 +892,7 @@ void __init early_init_lapic_mapping(voi
 	 * Fetch the APIC ID of the BSP in case we have a
 	 * default configuration (or the MP table is broken).
 	 */
-	boot_cpu_physical_apicid = GET_APIC_ID(apic_read(APIC_ID));
+	boot_cpu_physical_apicid = GET_APIC_ID(read_apic_id());
 }
 
 /**
@@ -919,7 +919,7 @@ void __init init_apic_mappings(void)
 	 * Fetch the APIC ID of the BSP in case we have a
 	 * default configuration (or the MP table is broken).
 	 */
-	boot_cpu_physical_apicid = GET_APIC_ID(apic_read(APIC_ID));
+	boot_cpu_physical_apicid = GET_APIC_ID(read_apic_id());
 }
 
 /*
@@ -1140,7 +1140,7 @@ static int lapic_suspend(struct sys_devi
 
 	maxlvt = lapic_get_maxlvt();
 
-	apic_pm_state.apic_id = apic_read(APIC_ID);
+	apic_pm_state.apic_id = read_apic_id();
 	apic_pm_state.apic_taskpri = apic_read(APIC_TASKPRI);
 	apic_pm_state.apic_ldr = apic_read(APIC_LDR);
 	apic_pm_state.apic_dfr = apic_read(APIC_DFR);
Index: linux/arch/x86/kernel/genapic_flat_64.c
===================================================================
--- linux.orig/arch/x86/kernel/genapic_flat_64.c	2008-03-28 11:47:10.000000000 -0500
+++ linux/arch/x86/kernel/genapic_flat_64.c	2008-03-28 11:49:38.000000000 -0500
@@ -97,7 +97,7 @@ static void flat_send_IPI_all(int vector
 
 static int flat_apic_id_registered(void)
 {
-	return physid_isset(GET_APIC_ID(apic_read(APIC_ID)), phys_cpu_present_map);
+	return physid_isset(GET_APIC_ID(read_apic_id()), phys_cpu_present_map);
 }
 
 static unsigned int flat_cpu_mask_to_apicid(cpumask_t cpumask)
Index: linux/arch/x86/kernel/io_apic_32.c
===================================================================
--- linux.orig/arch/x86/kernel/io_apic_32.c	2008-03-28 11:47:10.000000000 -0500
+++ linux/arch/x86/kernel/io_apic_32.c	2008-03-28 11:49:38.000000000 -0500
@@ -1482,8 +1482,8 @@ void /*__init*/ print_local_APIC(void * 
 
 	printk("\n" KERN_DEBUG "printing local APIC contents on CPU#%d/%d:\n",
 		smp_processor_id(), hard_smp_processor_id());
-	v = apic_read(APIC_ID);
-	printk(KERN_INFO "... APIC ID:      %08x (%01x)\n", v, GET_APIC_ID(v));
+	printk(KERN_INFO "... APIC ID:      %08x (%01x)\n", v,
+			GET_APIC_ID(read_apic_id()));
 	v = apic_read(APIC_LVR);
 	printk(KERN_INFO "... APIC VERSION: %08x\n", v);
 	ver = GET_APIC_VERSION(v);
@@ -1692,7 +1692,7 @@ void disable_IO_APIC(void)
 		entry.delivery_mode   = dest_ExtINT; /* ExtInt */
 		entry.vector          = 0;
 		entry.dest.physical.physical_dest =
-					GET_APIC_ID(apic_read(APIC_ID));
+					GET_APIC_ID(read_apic_id());
 
 		/*
 		 * Add it to the IO-APIC irq-routing table:
Index: linux/arch/x86/kernel/io_apic_64.c
===================================================================
--- linux.orig/arch/x86/kernel/io_apic_64.c	2008-03-28 11:47:10.000000000 -0500
+++ linux/arch/x86/kernel/io_apic_64.c	2008-03-28 11:49:38.000000000 -0500
@@ -1068,8 +1068,7 @@ void __apicdebuginit print_local_APIC(vo
 
 	printk("\n" KERN_DEBUG "printing local APIC contents on CPU#%d/%d:\n",
 		smp_processor_id(), hard_smp_processor_id());
-	v = apic_read(APIC_ID);
-	printk(KERN_INFO "... APIC ID:      %08x (%01x)\n", v, GET_APIC_ID(v));
+	printk(KERN_INFO "... APIC ID:      %08x (%01x)\n", v, GET_APIC_ID(read_apic_id()));
 	v = apic_read(APIC_LVR);
 	printk(KERN_INFO "... APIC VERSION: %08x\n", v);
 	ver = GET_APIC_VERSION(v);
@@ -1263,7 +1262,7 @@ void disable_IO_APIC(void)
 		entry.dest_mode       = 0; /* Physical */
 		entry.delivery_mode   = dest_ExtINT; /* ExtInt */
 		entry.vector          = 0;
-		entry.dest          = GET_APIC_ID(apic_read(APIC_ID));
+		entry.dest          = GET_APIC_ID(read_apic_id());
 
 		/*
 		 * Add it to the IO-APIC irq-routing table:
Index: linux/arch/x86/kernel/mpparse_32.c
===================================================================
--- linux.orig/arch/x86/kernel/mpparse_32.c	2008-03-28 11:47:10.000000000 -0500
+++ linux/arch/x86/kernel/mpparse_32.c	2008-03-28 11:49:38.000000000 -0500
@@ -802,7 +802,7 @@ void __init mp_register_lapic_address(u6
 	set_fixmap_nocache(FIX_APIC_BASE, mp_lapic_addr);
 
 	if (boot_cpu_physical_apicid == -1U)
-		boot_cpu_physical_apicid = GET_APIC_ID(apic_read(APIC_ID));
+		boot_cpu_physical_apicid = GET_APIC_ID(read_apic_id());
 
 	Dprintk("Boot CPU = %d\n", boot_cpu_physical_apicid);
 }
Index: linux/arch/x86/kernel/mpparse_64.c
===================================================================
--- linux.orig/arch/x86/kernel/mpparse_64.c	2008-03-28 11:47:10.000000000 -0500
+++ linux/arch/x86/kernel/mpparse_64.c	2008-03-28 11:49:38.000000000 -0500
@@ -631,7 +631,7 @@ void __init mp_register_lapic_address(u6
 	mp_lapic_addr = (unsigned long)address;
 	set_fixmap_nocache(FIX_APIC_BASE, mp_lapic_addr);
 	if (boot_cpu_physical_apicid == -1U)
-		boot_cpu_physical_apicid  = GET_APIC_ID(apic_read(APIC_ID));
+		boot_cpu_physical_apicid  = GET_APIC_ID(read_apic_id());
 }
 
 #define MP_ISA_BUS		0
Index: linux/arch/x86/kernel/smpboot.c
===================================================================
--- linux.orig/arch/x86/kernel/smpboot.c	2008-03-28 11:47:10.000000000 -0500
+++ linux/arch/x86/kernel/smpboot.c	2008-03-28 11:49:38.000000000 -0500
@@ -237,7 +237,7 @@ void __cpuinit smp_callin(void)
 	/*
 	 * (This works even if the APIC is not enabled.)
 	 */
-	phys_id = GET_APIC_ID(apic_read(APIC_ID));
+	phys_id = GET_APIC_ID(read_apic_id());
 	cpuid = smp_processor_id();
 	if (cpu_isset(cpuid, cpu_callin_map)) {
 		panic("%s: phys CPU#%d, CPU#%d already present??\n", __func__,
@@ -1205,9 +1205,9 @@ void __init native_smp_prepare_cpus(unsi
 		return;
 	}
 
-	if (GET_APIC_ID(apic_read(APIC_ID)) != boot_cpu_physical_apicid) {
+	if (GET_APIC_ID(read_apic_id()) != boot_cpu_physical_apicid) {
 		panic("Boot APIC ID in local APIC unexpected (%d vs %d)",
-		     GET_APIC_ID(apic_read(APIC_ID)), boot_cpu_physical_apicid);
+		     GET_APIC_ID(read_apic_id()), boot_cpu_physical_apicid);
 		/* Or can we switch back to PIC here? */
 	}
 
Index: linux/include/asm-x86/mach-default/mach_apic.h
===================================================================
--- linux.orig/include/asm-x86/mach-default/mach_apic.h	2008-03-28 11:47:12.000000000 -0500
+++ linux/include/asm-x86/mach-default/mach_apic.h	2008-03-28 11:49:38.000000000 -0500
@@ -54,7 +54,7 @@ static inline void init_apic_ldr(void)
 
 static inline int apic_id_registered(void)
 {
-	return physid_isset(GET_APIC_ID(apic_read(APIC_ID)), phys_cpu_present_map);
+	return physid_isset(GET_APIC_ID(read_apic_id()), phys_cpu_present_map);
 }
 
 static inline unsigned int cpu_mask_to_apicid(cpumask_t cpumask)
Index: linux/include/asm-x86/mach-es7000/mach_apic.h
===================================================================
--- linux.orig/include/asm-x86/mach-es7000/mach_apic.h	2008-03-28 11:47:12.000000000 -0500
+++ linux/include/asm-x86/mach-es7000/mach_apic.h	2008-03-28 11:49:38.000000000 -0500
@@ -141,7 +141,7 @@ static inline void setup_portio_remap(vo
 extern unsigned int boot_cpu_physical_apicid;
 static inline int check_phys_apicid_present(int cpu_physical_apicid)
 {
-	boot_cpu_physical_apicid = GET_APIC_ID(apic_read(APIC_ID));
+	boot_cpu_physical_apicid = GET_APIC_ID(read_apic_id());
 	return (1);
 }
 
Index: linux/include/asm-x86/mach-visws/mach_apic.h
===================================================================
--- linux.orig/include/asm-x86/mach-visws/mach_apic.h	2008-03-28 11:47:12.000000000 -0500
+++ linux/include/asm-x86/mach-visws/mach_apic.h	2008-03-28 11:49:38.000000000 -0500
@@ -23,7 +23,7 @@
 
 static inline int apic_id_registered(void)
 {
-	return physid_isset(GET_APIC_ID(apic_read(APIC_ID)), phys_cpu_present_map);
+	return physid_isset(GET_APIC_ID(read_apic_id()), phys_cpu_present_map);
 }
 
 /*
Index: linux/include/asm-x86/smp.h
===================================================================
--- linux.orig/include/asm-x86/smp.h	2008-03-28 11:47:12.000000000 -0500
+++ linux/include/asm-x86/smp.h	2008-03-28 11:53:48.000000000 -0500
@@ -179,6 +179,11 @@ static inline int logical_smp_processor_
 	return GET_APIC_LOGICAL_ID(*(u32 *)(APIC_BASE + APIC_LDR));
 }
 
+static inline unsigned int read_apic_id(void)
+{
+	return *(u32 *)(APIC_BASE + APIC_ID);
+}
+
 # ifdef APIC_DEFINITION
 extern int hard_smp_processor_id(void);
 # else
@@ -186,7 +191,7 @@ extern int hard_smp_processor_id(void);
 static inline int hard_smp_processor_id(void)
 {
 	/* we don't want to mark this access volatile - bad code generation */
-	return GET_APIC_ID(*(u32 *)(APIC_BASE + APIC_ID));
+	return GET_APIC_ID(read_apic_id());
 }
 # endif /* APIC_DEFINITION */
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
