Date: Fri, 28 Mar 2008 14:12:09 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: [PATCH 4/8] x86_64: Parsing for ACPI "SAPIC" table
Message-ID: <20080328191209.GA16435@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu, tglx@linutronix.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Add kernel support for new ACPI "sapic" tables that contain 16-bit APICIDs.
This patch simply adds parsing of an optional SAPIC table if present.
Otherwise, the traditional local APIC table is used.

Note: the SAPIC table is not a new ACPI table - it exists on other architectures
but is not currently recognized by x86_64.

Based on:
	git://git.kernel.org/pub/scm/linux/kernel/git/x86/linux-2.6-x86.git


Signed-off-by: Jack Steiner <steiner@sgi.com>


---
 arch/x86/kernel/acpi/boot.c |   26 ++++++++++++++++++++++++--
 1 file changed, 24 insertions(+), 2 deletions(-)

Index: linux/arch/x86/kernel/acpi/boot.c
===================================================================
--- linux.orig/arch/x86/kernel/acpi/boot.c	2008-03-28 12:24:34.000000000 -0500
+++ linux/arch/x86/kernel/acpi/boot.c	2008-03-28 12:41:01.000000000 -0500
@@ -283,6 +283,24 @@ acpi_parse_lapic(struct acpi_subtable_he
 }
 
 static int __init
+acpi_parse_sapic(struct acpi_subtable_header *header, const unsigned long end)
+{
+	struct acpi_madt_local_sapic *processor = NULL;
+
+	processor = (struct acpi_madt_local_sapic *)header;
+
+	if (BAD_MADT_ENTRY(processor, end))
+		return -EINVAL;
+
+	acpi_table_print_madt_entry(header);
+
+	acpi_register_lapic((processor->id << 8) | processor->eid,/* APIC ID */
+		processor->lapic_flags & ACPI_MADT_ENABLED);	/* Enabled? */
+
+	return 0;
+}
+
+static int __init
 acpi_parse_lapic_addr_ovr(struct acpi_subtable_header * header,
 			  const unsigned long end)
 {
@@ -801,8 +819,12 @@ static int __init acpi_parse_madt_lapic_
 
 	mp_register_lapic_address(acpi_lapic_addr);
 
-	count = acpi_table_parse_madt(ACPI_MADT_TYPE_LOCAL_APIC, acpi_parse_lapic,
-				      MAX_APICS);
+	count = acpi_table_parse_madt(ACPI_MADT_TYPE_LOCAL_SAPIC,
+				      acpi_parse_sapic, MAX_APICS);
+
+	if (!count)
+		count = acpi_table_parse_madt(ACPI_MADT_TYPE_LOCAL_APIC,
+					      acpi_parse_lapic, MAX_APICS);
 	if (!count) {
 		printk(KERN_ERR PREFIX "No LAPIC entries present\n");
 		/* TBD: Cleanup to allow fallback to MPS */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
