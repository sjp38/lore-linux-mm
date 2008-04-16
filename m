Date: Wed, 16 Apr 2008 11:45:15 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: [PATCH] - UV startup of slave cpus
Message-ID: <20080416164515.GA23371@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu, tglx@linutronix.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This patch changes smpboot.c so that it can start slave cpus running
in UV non-unique apicid mode. The SIPI must be sent using a UV-specific
mechanism.

Signed-off-by: Jack Steiner <steiner@sgi.com>

---
 arch/x86/kernel/genx2apic_uv_x.c |   17 +++++++++++------
 arch/x86/kernel/smpboot.c        |   29 ++++++++++++++++++++---------
 include/asm-x86/genapic_32.h     |    1 +
 3 files changed, 32 insertions(+), 15 deletions(-)


Built against git://git.kernel.org/pub/scm/linux/kernel/git/x86/linux-2.6-x86.git


Index: linux/arch/x86/kernel/smpboot.c
===================================================================
--- linux.orig/arch/x86/kernel/smpboot.c	2008-04-16 10:56:44.000000000 -0500
+++ linux/arch/x86/kernel/smpboot.c	2008-04-16 10:59:42.000000000 -0500
@@ -61,6 +61,7 @@
 #include <asm/mtrr.h>
 #include <asm/nmi.h>
 #include <asm/vmi.h>
+#include <asm/genapic.h>
 #include <linux/mc146818rtc.h>
 
 #include <mach_apic.h>
@@ -677,6 +678,12 @@ wakeup_secondary_cpu(int phys_apicid, un
 	unsigned long send_status, accept_status = 0;
 	int maxlvt, num_starts, j;
 
+	if (get_uv_system_type() == UV_NON_UNIQUE_APIC) {
+		send_status = uv_wakeup_secondary(phys_apicid, start_eip);
+		atomic_set(&init_deasserted, 1);
+		return send_status;
+	}
+
 	/*
 	 * Be paranoid about clearing APIC errors.
 	 */
@@ -918,16 +925,19 @@ do_rest:
 
 	atomic_set(&init_deasserted, 0);
 
-	Dprintk("Setting warm reset code and vector.\n");
+	if (get_uv_system_type() != UV_NON_UNIQUE_APIC) {
 
-	store_NMI_vector(&nmi_high, &nmi_low);
+		Dprintk("Setting warm reset code and vector.\n");
 
-	smpboot_setup_warm_reset_vector(start_ip);
-	/*
-	 * Be paranoid about clearing APIC errors.
-	 */
-	apic_write(APIC_ESR, 0);
-	apic_read(APIC_ESR);
+		store_NMI_vector(&nmi_high, &nmi_low);
+
+		smpboot_setup_warm_reset_vector(start_ip);
+		/*
+		 * Be paranoid about clearing APIC errors.
+	 	*/
+		apic_write(APIC_ESR, 0);
+		apic_read(APIC_ESR);
+	}
 
 	/*
 	 * Starting actual IPI sequence...
@@ -966,7 +976,8 @@ do_rest:
 			else
 				/* trampoline code not run */
 				printk(KERN_ERR "Not responding.\n");
-			inquire_remote_apic(apicid);
+			if (get_uv_system_type() != UV_NON_UNIQUE_APIC)
+				inquire_remote_apic(apicid);
 		}
 	}
 
Index: linux/include/asm-x86/genapic_32.h
===================================================================
--- linux.orig/include/asm-x86/genapic_32.h	2008-04-16 10:56:46.000000000 -0500
+++ linux/include/asm-x86/genapic_32.h	2008-04-16 10:59:42.000000000 -0500
@@ -117,6 +117,7 @@ extern struct genapic *genapic;
 enum uv_system_type {UV_NONE, UV_LEGACY_APIC, UV_X2APIC, UV_NON_UNIQUE_APIC};
 #define get_uv_system_type()		UV_NONE
 #define is_uv_system()			0
+#define uv_wakeup_secondary(a,b)	1
 
 
 #endif
Index: linux/arch/x86/kernel/genx2apic_uv_x.c
===================================================================
--- linux.orig/arch/x86/kernel/genx2apic_uv_x.c	2008-04-16 10:56:44.000000000 -0500
+++ linux/arch/x86/kernel/genx2apic_uv_x.c	2008-04-16 10:59:42.000000000 -0500
@@ -61,26 +61,31 @@ int uv_wakeup_secondary(int phys_apicid,
 	val = (1UL << UVH_IPI_INT_SEND_SHFT) |
 	    (phys_apicid << UVH_IPI_INT_APIC_ID_SHFT) |
 	    (((long)start_rip << UVH_IPI_INT_VECTOR_SHFT) >> 12) |
-	    (6 << UVH_IPI_INT_DELIVERY_MODE_SHFT);
+	    APIC_DM_INIT;
+	uv_write_global_mmr64(nasid, UVH_IPI_INT, val);
+	mdelay(10);
+
+	val = (1UL << UVH_IPI_INT_SEND_SHFT) |
+	    (phys_apicid << UVH_IPI_INT_APIC_ID_SHFT) |
+	    (((long)start_rip << UVH_IPI_INT_VECTOR_SHFT) >> 12) |
+	    APIC_DM_STARTUP;
 	uv_write_global_mmr64(nasid, UVH_IPI_INT, val);
 	return 0;
 }
 
 static void uv_send_IPI_one(int cpu, int vector)
 {
-	unsigned long val, apicid;
+	unsigned long val, apicid, lapicid;
 	int nasid;
 
 	apicid = per_cpu(x86_cpu_to_apicid, cpu); /* ZZZ - cache node-local ? */
+	lapicid = apicid & 0x3f;		/* ZZZ macro needed */
 	nasid = uv_apicid_to_nasid(apicid);
 	val =
-	    (1UL << UVH_IPI_INT_SEND_SHFT) | (apicid <<
+	    (1UL << UVH_IPI_INT_SEND_SHFT) | (lapicid <<
 					      UVH_IPI_INT_APIC_ID_SHFT) |
 	    (vector << UVH_IPI_INT_VECTOR_SHFT);
 	uv_write_global_mmr64(nasid, UVH_IPI_INT, val);
-	printk(KERN_DEBUG
-	     "UV: IPI to cpu %d, apicid 0x%lx, vec %d, nasid%d, val 0x%lx\n",
-	     cpu, apicid, vector, nasid, val);
 }
 
 static void uv_send_IPI_mask(cpumask_t mask, int vector)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
