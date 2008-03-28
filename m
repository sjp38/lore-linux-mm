Date: Fri, 28 Mar 2008 14:12:08 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: [PATCH 3/8] x86_64: Increase size of APICID
Message-ID: <20080328191208.GA16430@sgi.com>
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

Based on:
        git://git.kernel.org/pub/scm/linux/kernel/git/x86/linux-2.6-x86.git


Signed-off-by: Jack Steiner <steiner@sgi.com>

---
 arch/x86/kernel/acpi/boot.c  |    2 +-
 arch/x86/kernel/mpparse_32.c |    2 +-
 arch/x86/mm/srat_64.c        |    6 +++++-
 include/asm-x86/apicdef.h    |    9 ++++++---
 include/asm-x86/mpspec.h     |    2 +-
 5 files changed, 14 insertions(+), 7 deletions(-)

Index: linux/include/asm-x86/mpspec.h
===================================================================
--- linux.orig/include/asm-x86/mpspec.h	2008-03-28 12:11:09.000000000 -0500
+++ linux/include/asm-x86/mpspec.h	2008-03-28 12:13:00.000000000 -0500
@@ -47,7 +47,7 @@ extern void get_smp_config(void);
 
 void __cpuinit generic_processor_info(int apicid, int version);
 #ifdef CONFIG_ACPI
-extern void mp_register_lapic(u8 id, u8 enabled);
+extern void mp_register_lapic(int id, u8 enabled);
 extern void mp_register_lapic_address(u64 address);
 extern void mp_register_ioapic(u8 id, u32 address, u32 gsi_base);
 extern void mp_override_legacy_irq(u8 bus_irq, u8 polarity, u8 trigger,
Index: linux/arch/x86/mm/srat_64.c
===================================================================
--- linux.orig/arch/x86/mm/srat_64.c	2008-03-28 12:11:09.000000000 -0500
+++ linux/arch/x86/mm/srat_64.c	2008-03-28 12:13:00.000000000 -0500
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
--- linux.orig/include/asm-x86/apicdef.h	2008-03-28 12:11:09.000000000 -0500
+++ linux/include/asm-x86/apicdef.h	2008-03-28 12:13:00.000000000 -0500
@@ -133,7 +133,7 @@
 # define MAX_IO_APICS 64
 #else
 # define MAX_IO_APICS 128
-# define MAX_LOCAL_APIC 256
+# define MAX_LOCAL_APIC 32768
 #endif
 
 /*
@@ -406,6 +406,9 @@ struct local_apic {
 
 #undef u32
 
-#define BAD_APICID 0xFFu
-
+#ifdef CONFIG_X86_32
+ #define BAD_APICID 0xFFu
+#else
+ #define BAD_APICID 0xFFFFu
+#endif
 #endif
Index: linux/arch/x86/kernel/mpparse_32.c
===================================================================
--- linux.orig/arch/x86/kernel/mpparse_32.c	2008-03-28 12:11:09.000000000 -0500
+++ linux/arch/x86/kernel/mpparse_32.c	2008-03-28 12:13:00.000000000 -0500
@@ -807,7 +807,7 @@ void __init mp_register_lapic_address(u6
 	Dprintk("Boot CPU = %d\n", boot_cpu_physical_apicid);
 }
 
-void __cpuinit mp_register_lapic (u8 id, u8 enabled)
+void __cpuinit mp_register_lapic (int id, u8 enabled)
 {
 	if (MAX_APICS - id <= 0) {
 		printk(KERN_WARNING "Processor #%d invalid (max %d)\n",
Index: linux/arch/x86/kernel/acpi/boot.c
===================================================================
--- linux.orig/arch/x86/kernel/acpi/boot.c	2008-03-28 12:12:56.000000000 -0500
+++ linux/arch/x86/kernel/acpi/boot.c	2008-03-28 12:24:34.000000000 -0500
@@ -239,7 +239,7 @@ static int __init acpi_parse_madt(struct
 	return 0;
 }
 
-static void __cpuinit acpi_register_lapic(u8 id, u8 enabled)
+static void __cpuinit acpi_register_lapic(int id, u8 enabled)
 {
 #ifdef CONFIG_X86_SMP
 	if (MAX_APICS - id <= 0) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
