Date: Thu, 19 Jun 2008 21:51:05 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: [PATCH] - Fix stack overflow for large values of MAX_APICS
Message-ID: <20080620025104.GA25571@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu, tglx@linutronix.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

physid_mask_of_physid() causes a huge stack (12k) to be created if the
number of APICS is large. Replace physid_mask_of_physid() with a
new function that does not create large stacks. This is a problem only
on large x86_64 systems.

Signed-off-by: Jack Steiner <steiner@sgi.com>

---

Ingo - the "Increase MAX_APICS patch" can now works. Do you
want me to resend???



 arch/x86/kernel/apic_32.c |    2 +-
 arch/x86/kernel/apic_64.c |    2 +-
 arch/x86/kernel/smpboot.c |    5 ++---
 include/asm-x86/mpspec.h  |    7 +++++++
 4 files changed, 11 insertions(+), 5 deletions(-)

Index: linux/arch/x86/kernel/apic_32.c
===================================================================
--- linux.orig/arch/x86/kernel/apic_32.c	2008-06-19 11:50:07.000000000 -0500
+++ linux/arch/x86/kernel/apic_32.c	2008-06-19 19:28:04.000000000 -0500
@@ -1267,7 +1267,7 @@ int __init APIC_init_uniprocessor(void)
 #ifdef CONFIG_CRASH_DUMP
 	boot_cpu_physical_apicid = GET_APIC_ID(read_apic_id());
 #endif
-	phys_cpu_present_map = physid_mask_of_physid(boot_cpu_physical_apicid);
+	physid_set_mask_of_physid(boot_cpu_physical_apicid, &phys_cpu_present_map);
 
 	setup_local_APIC();
 
Index: linux/arch/x86/kernel/apic_64.c
===================================================================
--- linux.orig/arch/x86/kernel/apic_64.c	2008-06-19 15:59:58.000000000 -0500
+++ linux/arch/x86/kernel/apic_64.c	2008-06-19 19:25:18.000000000 -0500
@@ -920,7 +920,7 @@ int __init APIC_init_uniprocessor(void)
 
 	connect_bsp_APIC();
 
-	phys_cpu_present_map = physid_mask_of_physid(boot_cpu_physical_apicid);
+	physid_set_mask_of_physid(boot_cpu_physical_apicid, &phys_cpu_present_map);
 	apic_write(APIC_ID, SET_APIC_ID(boot_cpu_physical_apicid));
 
 	setup_local_APIC();
Index: linux/arch/x86/kernel/smpboot.c
===================================================================
--- linux.orig/arch/x86/kernel/smpboot.c	2008-06-19 19:06:00.000000000 -0500
+++ linux/arch/x86/kernel/smpboot.c	2008-06-19 19:37:37.000000000 -0500
@@ -1042,10 +1042,9 @@ static __init void disable_smp(void)
 	smpboot_clear_io_apic_irqs();
 
 	if (smp_found_config)
-		phys_cpu_present_map =
-				physid_mask_of_physid(boot_cpu_physical_apicid);
+		physid_set_mask_of_physid(boot_cpu_physical_apicid, &phys_cpu_present_map);
 	else
-		phys_cpu_present_map = physid_mask_of_physid(0);
+		physid_set_mask_of_physid(0, &phys_cpu_present_map);
 	map_cpu_to_logical_apicid();
 	cpu_set(0, per_cpu(cpu_sibling_map, 0));
 	cpu_set(0, per_cpu(cpu_core_map, 0));
Index: linux/include/asm-x86/mpspec.h
===================================================================
--- linux.orig/include/asm-x86/mpspec.h	2008-06-19 11:50:09.000000000 -0500
+++ linux/include/asm-x86/mpspec.h	2008-06-19 19:39:11.000000000 -0500
@@ -122,6 +122,7 @@ typedef struct physid_mask physid_mask_t
 		__physid_mask;						\
 	})
 
+/* Note: will create very large stack frames if physid_mask_t is big */
 #define physid_mask_of_physid(physid)					\
 	({								\
 		physid_mask_t __physid_mask = PHYSID_MASK_NONE;		\
@@ -129,6 +130,12 @@ typedef struct physid_mask physid_mask_t
 		__physid_mask;						\
 	})
 
+static inline void physid_set_mask_of_physid(int physid, physid_mask_t *map)
+{
+	physids_clear(*map);
+	physid_set(physid, *map);
+}
+
 #define PHYSID_MASK_ALL		{ {[0 ... PHYSID_ARRAY_SIZE-1] = ~0UL} }
 #define PHYSID_MASK_NONE	{ {[0 ... PHYSID_ARRAY_SIZE-1] = 0UL} }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
