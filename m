Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6CF8C8E0018
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 20:05:46 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id s71so11185559pfi.22
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 17:05:46 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id i1si11402278pfj.276.2018.12.10.17.05.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 17:05:44 -0800 (PST)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCHv2 01/12] acpi: Create subtable parsing infrastructure
Date: Mon, 10 Dec 2018 18:02:59 -0700
Message-Id: <20181211010310.8551-2-keith.busch@intel.com>
In-Reply-To: <20181211010310.8551-1-keith.busch@intel.com>
References: <20181211010310.8551-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>

Parsing entries in an ACPI table had assumed a generic header structure
that is most common. There is no standard ACPI header, though, so less
common types would need custom parsers if they want go through their
sub-table entry list.

Create the infrastructure for adding different table types so parsing
the entries array may be more reused for all ACPI system tables.

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 arch/x86/kernel/acpi/boot.c  | 36 ++++++++++++------------
 drivers/acpi/numa.c          | 16 +++++------
 drivers/acpi/scan.c          |  4 +--
 drivers/acpi/tables.c        | 67 +++++++++++++++++++++++++++++++++++++-------
 drivers/irqchip/irq-gic-v3.c |  2 +-
 drivers/mailbox/pcc.c        |  2 +-
 include/linux/acpi.h         |  5 +++-
 7 files changed, 91 insertions(+), 41 deletions(-)

diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
index 06635fbca81c..58561b4df09d 100644
--- a/arch/x86/kernel/acpi/boot.c
+++ b/arch/x86/kernel/acpi/boot.c
@@ -197,7 +197,7 @@ static int acpi_register_lapic(int id, u32 acpiid, u8 enabled)
 }
 
 static int __init
-acpi_parse_x2apic(struct acpi_subtable_header *header, const unsigned long end)
+acpi_parse_x2apic(union acpi_subtable_headers *header, const unsigned long end)
 {
 	struct acpi_madt_local_x2apic *processor = NULL;
 #ifdef CONFIG_X86_X2APIC
@@ -210,7 +210,7 @@ acpi_parse_x2apic(struct acpi_subtable_header *header, const unsigned long end)
 	if (BAD_MADT_ENTRY(processor, end))
 		return -EINVAL;
 
-	acpi_table_print_madt_entry(header);
+	acpi_table_print_madt_entry(&header->common);
 
 #ifdef CONFIG_X86_X2APIC
 	apic_id = processor->local_apic_id;
@@ -242,7 +242,7 @@ acpi_parse_x2apic(struct acpi_subtable_header *header, const unsigned long end)
 }
 
 static int __init
-acpi_parse_lapic(struct acpi_subtable_header * header, const unsigned long end)
+acpi_parse_lapic(union acpi_subtable_headers * header, const unsigned long end)
 {
 	struct acpi_madt_local_apic *processor = NULL;
 
@@ -251,7 +251,7 @@ acpi_parse_lapic(struct acpi_subtable_header * header, const unsigned long end)
 	if (BAD_MADT_ENTRY(processor, end))
 		return -EINVAL;
 
-	acpi_table_print_madt_entry(header);
+	acpi_table_print_madt_entry(&header->common);
 
 	/* Ignore invalid ID */
 	if (processor->id == 0xff)
@@ -272,7 +272,7 @@ acpi_parse_lapic(struct acpi_subtable_header * header, const unsigned long end)
 }
 
 static int __init
-acpi_parse_sapic(struct acpi_subtable_header *header, const unsigned long end)
+acpi_parse_sapic(union acpi_subtable_headers *header, const unsigned long end)
 {
 	struct acpi_madt_local_sapic *processor = NULL;
 
@@ -281,7 +281,7 @@ acpi_parse_sapic(struct acpi_subtable_header *header, const unsigned long end)
 	if (BAD_MADT_ENTRY(processor, end))
 		return -EINVAL;
 
-	acpi_table_print_madt_entry(header);
+	acpi_table_print_madt_entry(&header->common);
 
 	acpi_register_lapic((processor->id << 8) | processor->eid,/* APIC ID */
 			    processor->processor_id, /* ACPI ID */
@@ -291,7 +291,7 @@ acpi_parse_sapic(struct acpi_subtable_header *header, const unsigned long end)
 }
 
 static int __init
-acpi_parse_lapic_addr_ovr(struct acpi_subtable_header * header,
+acpi_parse_lapic_addr_ovr(union acpi_subtable_headers * header,
 			  const unsigned long end)
 {
 	struct acpi_madt_local_apic_override *lapic_addr_ovr = NULL;
@@ -301,7 +301,7 @@ acpi_parse_lapic_addr_ovr(struct acpi_subtable_header * header,
 	if (BAD_MADT_ENTRY(lapic_addr_ovr, end))
 		return -EINVAL;
 
-	acpi_table_print_madt_entry(header);
+	acpi_table_print_madt_entry(&header->common);
 
 	acpi_lapic_addr = lapic_addr_ovr->address;
 
@@ -309,7 +309,7 @@ acpi_parse_lapic_addr_ovr(struct acpi_subtable_header * header,
 }
 
 static int __init
-acpi_parse_x2apic_nmi(struct acpi_subtable_header *header,
+acpi_parse_x2apic_nmi(union acpi_subtable_headers *header,
 		      const unsigned long end)
 {
 	struct acpi_madt_local_x2apic_nmi *x2apic_nmi = NULL;
@@ -319,7 +319,7 @@ acpi_parse_x2apic_nmi(struct acpi_subtable_header *header,
 	if (BAD_MADT_ENTRY(x2apic_nmi, end))
 		return -EINVAL;
 
-	acpi_table_print_madt_entry(header);
+	acpi_table_print_madt_entry(&header->common);
 
 	if (x2apic_nmi->lint != 1)
 		printk(KERN_WARNING PREFIX "NMI not connected to LINT 1!\n");
@@ -328,7 +328,7 @@ acpi_parse_x2apic_nmi(struct acpi_subtable_header *header,
 }
 
 static int __init
-acpi_parse_lapic_nmi(struct acpi_subtable_header * header, const unsigned long end)
+acpi_parse_lapic_nmi(union acpi_subtable_headers * header, const unsigned long end)
 {
 	struct acpi_madt_local_apic_nmi *lapic_nmi = NULL;
 
@@ -337,7 +337,7 @@ acpi_parse_lapic_nmi(struct acpi_subtable_header * header, const unsigned long e
 	if (BAD_MADT_ENTRY(lapic_nmi, end))
 		return -EINVAL;
 
-	acpi_table_print_madt_entry(header);
+	acpi_table_print_madt_entry(&header->common);
 
 	if (lapic_nmi->lint != 1)
 		printk(KERN_WARNING PREFIX "NMI not connected to LINT 1!\n");
@@ -449,7 +449,7 @@ static int __init mp_register_ioapic_irq(u8 bus_irq, u8 polarity,
 }
 
 static int __init
-acpi_parse_ioapic(struct acpi_subtable_header * header, const unsigned long end)
+acpi_parse_ioapic(union acpi_subtable_headers * header, const unsigned long end)
 {
 	struct acpi_madt_io_apic *ioapic = NULL;
 	struct ioapic_domain_cfg cfg = {
@@ -462,7 +462,7 @@ acpi_parse_ioapic(struct acpi_subtable_header * header, const unsigned long end)
 	if (BAD_MADT_ENTRY(ioapic, end))
 		return -EINVAL;
 
-	acpi_table_print_madt_entry(header);
+	acpi_table_print_madt_entry(&header->common);
 
 	/* Statically assign IRQ numbers for IOAPICs hosting legacy IRQs */
 	if (ioapic->global_irq_base < nr_legacy_irqs())
@@ -508,7 +508,7 @@ static void __init acpi_sci_ioapic_setup(u8 bus_irq, u16 polarity, u16 trigger,
 }
 
 static int __init
-acpi_parse_int_src_ovr(struct acpi_subtable_header * header,
+acpi_parse_int_src_ovr(union acpi_subtable_headers * header,
 		       const unsigned long end)
 {
 	struct acpi_madt_interrupt_override *intsrc = NULL;
@@ -518,7 +518,7 @@ acpi_parse_int_src_ovr(struct acpi_subtable_header * header,
 	if (BAD_MADT_ENTRY(intsrc, end))
 		return -EINVAL;
 
-	acpi_table_print_madt_entry(header);
+	acpi_table_print_madt_entry(&header->common);
 
 	if (intsrc->source_irq == acpi_gbl_FADT.sci_interrupt) {
 		acpi_sci_ioapic_setup(intsrc->source_irq,
@@ -550,7 +550,7 @@ acpi_parse_int_src_ovr(struct acpi_subtable_header * header,
 }
 
 static int __init
-acpi_parse_nmi_src(struct acpi_subtable_header * header, const unsigned long end)
+acpi_parse_nmi_src(union acpi_subtable_headers * header, const unsigned long end)
 {
 	struct acpi_madt_nmi_source *nmi_src = NULL;
 
@@ -559,7 +559,7 @@ acpi_parse_nmi_src(struct acpi_subtable_header * header, const unsigned long end
 	if (BAD_MADT_ENTRY(nmi_src, end))
 		return -EINVAL;
 
-	acpi_table_print_madt_entry(header);
+	acpi_table_print_madt_entry(&header->common);
 
 	/* TBD: Support nimsrc entries? */
 
diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
index 274699463b4f..f5e09c39ff22 100644
--- a/drivers/acpi/numa.c
+++ b/drivers/acpi/numa.c
@@ -338,7 +338,7 @@ acpi_numa_x2apic_affinity_init(struct acpi_srat_x2apic_cpu_affinity *pa)
 }
 
 static int __init
-acpi_parse_x2apic_affinity(struct acpi_subtable_header *header,
+acpi_parse_x2apic_affinity(union acpi_subtable_headers *header,
 			   const unsigned long end)
 {
 	struct acpi_srat_x2apic_cpu_affinity *processor_affinity;
@@ -347,7 +347,7 @@ acpi_parse_x2apic_affinity(struct acpi_subtable_header *header,
 	if (!processor_affinity)
 		return -EINVAL;
 
-	acpi_table_print_srat_entry(header);
+	acpi_table_print_srat_entry(&header->common);
 
 	/* let architecture-dependent part to do it */
 	acpi_numa_x2apic_affinity_init(processor_affinity);
@@ -356,7 +356,7 @@ acpi_parse_x2apic_affinity(struct acpi_subtable_header *header,
 }
 
 static int __init
-acpi_parse_processor_affinity(struct acpi_subtable_header *header,
+acpi_parse_processor_affinity(union acpi_subtable_headers *header,
 			      const unsigned long end)
 {
 	struct acpi_srat_cpu_affinity *processor_affinity;
@@ -365,7 +365,7 @@ acpi_parse_processor_affinity(struct acpi_subtable_header *header,
 	if (!processor_affinity)
 		return -EINVAL;
 
-	acpi_table_print_srat_entry(header);
+	acpi_table_print_srat_entry(&header->common);
 
 	/* let architecture-dependent part to do it */
 	acpi_numa_processor_affinity_init(processor_affinity);
@@ -374,7 +374,7 @@ acpi_parse_processor_affinity(struct acpi_subtable_header *header,
 }
 
 static int __init
-acpi_parse_gicc_affinity(struct acpi_subtable_header *header,
+acpi_parse_gicc_affinity(union acpi_subtable_headers *header,
 			 const unsigned long end)
 {
 	struct acpi_srat_gicc_affinity *processor_affinity;
@@ -383,7 +383,7 @@ acpi_parse_gicc_affinity(struct acpi_subtable_header *header,
 	if (!processor_affinity)
 		return -EINVAL;
 
-	acpi_table_print_srat_entry(header);
+	acpi_table_print_srat_entry(&header->common);
 
 	/* let architecture-dependent part to do it */
 	acpi_numa_gicc_affinity_init(processor_affinity);
@@ -394,7 +394,7 @@ acpi_parse_gicc_affinity(struct acpi_subtable_header *header,
 static int __initdata parsed_numa_memblks;
 
 static int __init
-acpi_parse_memory_affinity(struct acpi_subtable_header * header,
+acpi_parse_memory_affinity(union acpi_subtable_headers * header,
 			   const unsigned long end)
 {
 	struct acpi_srat_mem_affinity *memory_affinity;
@@ -403,7 +403,7 @@ acpi_parse_memory_affinity(struct acpi_subtable_header * header,
 	if (!memory_affinity)
 		return -EINVAL;
 
-	acpi_table_print_srat_entry(header);
+	acpi_table_print_srat_entry(&header->common);
 
 	/* let architecture-dependent part to do it */
 	if (!acpi_numa_memory_affinity_init(memory_affinity))
diff --git a/drivers/acpi/scan.c b/drivers/acpi/scan.c
index bd1c59fb0e17..d98d5da6a279 100644
--- a/drivers/acpi/scan.c
+++ b/drivers/acpi/scan.c
@@ -2234,10 +2234,10 @@ static struct acpi_probe_entry *ape;
 static int acpi_probe_count;
 static DEFINE_MUTEX(acpi_probe_mutex);
 
-static int __init acpi_match_madt(struct acpi_subtable_header *header,
+static int __init acpi_match_madt(union acpi_subtable_headers *header,
 				  const unsigned long end)
 {
-	if (!ape->subtable_valid || ape->subtable_valid(header, ape))
+	if (!ape->subtable_valid || ape->subtable_valid(&header->common, ape))
 		if (!ape->probe_subtbl(header, end))
 			acpi_probe_count++;
 
diff --git a/drivers/acpi/tables.c b/drivers/acpi/tables.c
index 61203eebf3a1..e9643b4267c7 100644
--- a/drivers/acpi/tables.c
+++ b/drivers/acpi/tables.c
@@ -49,6 +49,15 @@ static struct acpi_table_desc initial_tables[ACPI_MAX_TABLES] __initdata;
 
 static int acpi_apic_instance __initdata;
 
+enum acpi_subtable_type {
+	ACPI_SUBTABLE_COMMON,
+};
+
+struct acpi_subtable_entry {
+	union acpi_subtable_headers *hdr;
+	enum acpi_subtable_type type;
+};
+
 /*
  * Disable table checksum verification for the early stage due to the size
  * limitation of the current x86 early mapping implementation.
@@ -217,6 +226,42 @@ void acpi_table_print_madt_entry(struct acpi_subtable_header *header)
 	}
 }
 
+static unsigned long __init
+acpi_get_entry_type(struct acpi_subtable_entry *entry)
+{
+	switch (entry->type) {
+	case ACPI_SUBTABLE_COMMON:
+		return entry->hdr->common.type;
+	}
+	return 0;
+}
+
+static unsigned long __init
+acpi_get_entry_length(struct acpi_subtable_entry *entry)
+{
+	switch (entry->type) {
+	case ACPI_SUBTABLE_COMMON:
+		return entry->hdr->common.length;
+	}
+	return 0;
+}
+
+static unsigned long __init
+acpi_get_subtable_header_length(struct acpi_subtable_entry *entry)
+{
+	switch (entry->type) {
+	case ACPI_SUBTABLE_COMMON:
+		return sizeof(entry->hdr->common);
+	}
+	return 0;
+}
+
+static enum acpi_subtable_type __init
+acpi_get_subtable_type(char *id)
+{
+	return ACPI_SUBTABLE_COMMON;
+}
+
 /**
  * acpi_parse_entries_array - for each proc_num find a suitable subtable
  *
@@ -246,8 +291,8 @@ acpi_parse_entries_array(char *id, unsigned long table_size,
 		struct acpi_subtable_proc *proc, int proc_num,
 		unsigned int max_entries)
 {
-	struct acpi_subtable_header *entry;
-	unsigned long table_end;
+	struct acpi_subtable_entry entry;
+	unsigned long table_end, subtable_len, entry_len;
 	int count = 0;
 	int errs = 0;
 	int i;
@@ -270,19 +315,20 @@ acpi_parse_entries_array(char *id, unsigned long table_size,
 
 	/* Parse all entries looking for a match. */
 
-	entry = (struct acpi_subtable_header *)
+	entry.type = acpi_get_subtable_type(id);
+	entry.hdr = (union acpi_subtable_headers *)
 	    ((unsigned long)table_header + table_size);
+	subtable_len = acpi_get_subtable_header_length(&entry);
 
-	while (((unsigned long)entry) + sizeof(struct acpi_subtable_header) <
-	       table_end) {
+	while (((unsigned long)entry.hdr) + subtable_len  < table_end) {
 		if (max_entries && count >= max_entries)
 			break;
 
 		for (i = 0; i < proc_num; i++) {
-			if (entry->type != proc[i].id)
+			if (acpi_get_entry_type(&entry) != proc[i].id)
 				continue;
 			if (!proc[i].handler ||
-			     (!errs && proc[i].handler(entry, table_end))) {
+			     (!errs && proc[i].handler(entry.hdr, table_end))) {
 				errs++;
 				continue;
 			}
@@ -297,13 +343,14 @@ acpi_parse_entries_array(char *id, unsigned long table_size,
 		 * If entry->length is 0, break from this loop to avoid
 		 * infinite loop.
 		 */
-		if (entry->length == 0) {
+		entry_len = acpi_get_entry_length(&entry);
+		if (entry_len == 0) {
 			pr_err("[%4.4s:0x%02x] Invalid zero length\n", id, proc->id);
 			return -EINVAL;
 		}
 
-		entry = (struct acpi_subtable_header *)
-		    ((unsigned long)entry + entry->length);
+		entry.hdr = (union acpi_subtable_headers *)
+		    ((unsigned long)entry.hdr + entry_len);
 	}
 
 	if (max_entries && count > max_entries) {
diff --git a/drivers/irqchip/irq-gic-v3.c b/drivers/irqchip/irq-gic-v3.c
index 8f87f40c9460..ef3f72196ad6 100644
--- a/drivers/irqchip/irq-gic-v3.c
+++ b/drivers/irqchip/irq-gic-v3.c
@@ -1383,7 +1383,7 @@ gic_acpi_parse_madt_redist(struct acpi_subtable_header *header,
 }
 
 static int __init
-gic_acpi_parse_madt_gicc(struct acpi_subtable_header *header,
+gic_acpi_parse_madt_gicc(union acpi_subtable_headers *header,
 			 const unsigned long end)
 {
 	struct acpi_madt_generic_interrupt *gicc =
diff --git a/drivers/mailbox/pcc.c b/drivers/mailbox/pcc.c
index 256f18b67e8a..08a0a3517138 100644
--- a/drivers/mailbox/pcc.c
+++ b/drivers/mailbox/pcc.c
@@ -382,7 +382,7 @@ static const struct mbox_chan_ops pcc_chan_ops = {
  *
  * This gets called for each entry in the PCC table.
  */
-static int parse_pcc_subspace(struct acpi_subtable_header *header,
+static int parse_pcc_subspace(union acpi_subtable_headers *header,
 		const unsigned long end)
 {
 	struct acpi_pcct_subspace *ss = (struct acpi_pcct_subspace *) header;
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index ed80f147bd50..18805a967c70 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -141,10 +141,13 @@ enum acpi_address_range_id {
 
 
 /* Table Handlers */
+union acpi_subtable_headers {
+	struct acpi_subtable_header common;
+};
 
 typedef int (*acpi_tbl_table_handler)(struct acpi_table_header *table);
 
-typedef int (*acpi_tbl_entry_handler)(struct acpi_subtable_header *header,
+typedef int (*acpi_tbl_entry_handler)(union acpi_subtable_headers *header,
 				      const unsigned long end);
 
 /* Debugger support */
-- 
2.14.4
