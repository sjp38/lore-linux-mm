Date: Fri, 28 Mar 2008 14:12:06 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: [PATCH 2/8] x86_64: Add functions to determine if platform is a UV platform
Message-ID: <20080328191206.GA16425@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu, tglx@linutronix.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Add functions that can be used to determine if an x86_64
system is a SGI "UV" system. UV systems come in 3 types and
are identified by the OEM ID in the MADT.

Based on:
        git://git.kernel.org/pub/scm/linux/kernel/git/x86/linux-2.6-x86.git

Signed-off-by: Jack Steiner <steiner@sgi.com>

---
 arch/x86/kernel/acpi/boot.c  |    4 +---
 arch/x86/kernel/genapic_64.c |   25 +++++++++++++++++++++++++
 include/asm-x86/genapic_32.h |    5 +++++
 include/asm-x86/genapic_64.h |    5 +++++
 4 files changed, 36 insertions(+), 3 deletions(-)

Index: linux/arch/x86/kernel/acpi/boot.c
===================================================================
--- linux.orig/arch/x86/kernel/acpi/boot.c	2008-03-27 11:24:49.000000000 -0500
+++ linux/arch/x86/kernel/acpi/boot.c	2008-03-27 12:47:22.000000000 -0500
@@ -56,9 +56,7 @@ EXPORT_SYMBOL(acpi_disabled);
 #ifdef	CONFIG_X86_64
 
 #include <asm/proto.h>
-
-static inline int acpi_madt_oem_check(char *oem_id, char *oem_table_id) { return 0; }
-
+#include <asm/genapic.h>
 
 #else				/* X86 */
 
Index: linux/arch/x86/kernel/genapic_64.c
===================================================================
--- linux.orig/arch/x86/kernel/genapic_64.c	2008-03-27 11:33:09.000000000 -0500
+++ linux/arch/x86/kernel/genapic_64.c	2008-03-27 12:47:22.000000000 -0500
@@ -35,6 +35,8 @@ EXPORT_PER_CPU_SYMBOL(x86_cpu_to_apicid)
 
 struct genapic __read_mostly *genapic = &apic_flat;
 
+static enum uv_system_type uv_system_type;
+
 /*
  * Check the APIC IDs in bios_cpu_apicid and choose the APIC mode.
  */
@@ -66,3 +68,26 @@ void send_IPI_self(int vector)
 {
 	__send_IPI_shortcut(APIC_DEST_SELF, vector, APIC_DEST_PHYSICAL);
 }
+
+int __init acpi_madt_oem_check(char *oem_id, char *oem_table_id)
+{
+	if (!strcmp(oem_id, "SGI")) {
+		if (!strcmp(oem_table_id, "UVL"))
+			uv_system_type = UV_LEGACY_APIC;
+		else if (!strcmp(oem_table_id, "UVX"))
+			uv_system_type = UV_X2APIC;
+		else if (!strcmp(oem_table_id, "UVH"))
+			uv_system_type = UV_NON_UNIQUE_APIC;
+	}
+	return 0;
+}
+
+enum uv_system_type get_uv_system_type(void)
+{
+	return uv_system_type;
+}
+
+int is_uv_system(void)
+{
+	return uv_system_type != UV_NONE;
+}
Index: linux/include/asm-x86/genapic_64.h
===================================================================
--- linux.orig/include/asm-x86/genapic_64.h	2008-03-27 11:24:52.000000000 -0500
+++ linux/include/asm-x86/genapic_64.h	2008-03-27 12:47:22.000000000 -0500
@@ -33,5 +33,10 @@ extern struct genapic *genapic;
 
 extern struct genapic apic_flat;
 extern struct genapic apic_physflat;
+extern int acpi_madt_oem_check(char *, char *);
+
+enum uv_system_type {UV_NONE, UV_LEGACY_APIC, UV_X2APIC, UV_NON_UNIQUE_APIC};
+extern enum uv_system_type get_uv_system_type(void);
+extern int is_uv_system(void);
 
 #endif
Index: linux/include/asm-x86/genapic_32.h
===================================================================
--- linux.orig/include/asm-x86/genapic_32.h	2008-03-27 11:24:52.000000000 -0500
+++ linux/include/asm-x86/genapic_32.h	2008-03-27 12:47:22.000000000 -0500
@@ -114,4 +114,9 @@ struct genapic {
 
 extern struct genapic *genapic;
 
+enum uv_system_type {UV_NONE, UV_LEGACY_APIC, UV_X2APIC, UV_NON_UNIQUE_APIC};
+#define get_uv_system_type()		UV_NONE
+#define is_uv_system()			0
+
+
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
