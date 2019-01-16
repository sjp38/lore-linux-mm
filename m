Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 88F438E0005
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 12:59:39 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id b8so5211779pfe.10
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 09:59:39 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id y8si6735247plr.92.2019.01.16.09.59.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 09:59:36 -0800 (PST)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCHv4 01/13] acpi: Create subtable parsing infrastructure
Date: Wed, 16 Jan 2019 10:57:52 -0700
Message-Id: <20190116175804.30196-2-keith.busch@intel.com>
In-Reply-To: <20190116175804.30196-1-keith.busch@intel.com>
References: <20190116175804.30196-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>

Parsing entries in an ACPI table had assumed a generic header
structure. There is no standard ACPI header, though, so less common
layouts with different field sizes required custom parsers to go through
their subtable entry list.

Create the infrastructure for adding different table types so parsing
the entries array may be more reused for all ACPI system tables and
the common code doesn't need to be duplicated.

Reviewed-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 arch/arm64/kernel/acpi_numa.c                 |  2 +-
 arch/arm64/kernel/smp.c                       |  4 +-
 arch/ia64/kernel/acpi.c                       | 12 ++---
 arch/x86/kernel/acpi/boot.c                   | 36 +++++++-------
 drivers/acpi/numa.c                           | 16 +++----
 drivers/acpi/scan.c                           |  4 +-
 drivers/acpi/tables.c                         | 67 +++++++++++++++++++++++----
 drivers/irqchip/irq-gic-v2m.c                 |  2 +-
 drivers/irqchip/irq-gic-v3-its-pci-msi.c      |  2 +-
 drivers/irqchip/irq-gic-v3-its-platform-msi.c |  2 +-
 drivers/irqchip/irq-gic-v3-its.c              |  6 +--
 drivers/irqchip/irq-gic-v3.c                  | 10 ++--
 drivers/irqchip/irq-gic.c                     |  4 +-
 drivers/mailbox/pcc.c                         |  2 +-
 include/linux/acpi.h                          |  5 +-
 15 files changed, 112 insertions(+), 62 deletions(-)

diff --git a/arch/arm64/kernel/acpi_numa.c b/arch/arm64/kernel/acpi_numa.c
index eac1d0cc595c..7ff800045434 100644
--- a/arch/arm64/kernel/acpi_numa.c
+++ b/arch/arm64/kernel/acpi_numa.c
@@ -45,7 +45,7 @@ static inline int get_cpu_for_acpi_id(u32 uid)
 	return -EINVAL;
 }
 
-static int __init acpi_parse_gicc_pxm(struct acpi_subtable_header *header,
+static int __init acpi_parse_gicc_pxm(union acpi_subtable_headers *header,
 				      const unsigned long end)
 {
 	struct acpi_srat_gicc_affinity *pa;
diff --git a/arch/arm64/kernel/smp.c b/arch/arm64/kernel/smp.c
index 1598d6f7200a..e6a148604dcc 100644
--- a/arch/arm64/kernel/smp.c
+++ b/arch/arm64/kernel/smp.c
@@ -553,7 +553,7 @@ acpi_map_gic_cpu_interface(struct acpi_madt_generic_interrupt *processor)
 }
 
 static int __init
-acpi_parse_gic_cpu_interface(struct acpi_subtable_header *header,
+acpi_parse_gic_cpu_interface(union acpi_subtable_headers *header,
 			     const unsigned long end)
 {
 	struct acpi_madt_generic_interrupt *processor;
@@ -562,7 +562,7 @@ acpi_parse_gic_cpu_interface(struct acpi_subtable_header *header,
 	if (BAD_MADT_GICC_ENTRY(processor, end))
 		return -EINVAL;
 
-	acpi_table_print_madt_entry(header);
+	acpi_table_print_madt_entry(&header->common);
 
 	acpi_map_gic_cpu_interface(processor);
 
diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index 41eb281709da..3973d2c2a9b0 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -177,7 +177,7 @@ struct acpi_table_madt *acpi_madt __initdata;
 static u8 has_8259;
 
 static int __init
-acpi_parse_lapic_addr_ovr(struct acpi_subtable_header * header,
+acpi_parse_lapic_addr_ovr(union acpi_subtable_headers * header,
 			  const unsigned long end)
 {
 	struct acpi_madt_local_apic_override *lapic;
@@ -216,7 +216,7 @@ acpi_parse_lsapic(struct acpi_subtable_header * header, const unsigned long end)
 }
 
 static int __init
-acpi_parse_lapic_nmi(struct acpi_subtable_header * header, const unsigned long end)
+acpi_parse_lapic_nmi(union acpi_subtable_headers * header, const unsigned long end)
 {
 	struct acpi_madt_local_apic_nmi *lacpi_nmi;
 
@@ -230,7 +230,7 @@ acpi_parse_lapic_nmi(struct acpi_subtable_header * header, const unsigned long e
 }
 
 static int __init
-acpi_parse_iosapic(struct acpi_subtable_header * header, const unsigned long end)
+acpi_parse_iosapic(union acpi_subtable_headers * header, const unsigned long end)
 {
 	struct acpi_madt_io_sapic *iosapic;
 
@@ -245,7 +245,7 @@ acpi_parse_iosapic(struct acpi_subtable_header * header, const unsigned long end
 static unsigned int __initdata acpi_madt_rev;
 
 static int __init
-acpi_parse_plat_int_src(struct acpi_subtable_header * header,
+acpi_parse_plat_int_src(union acpi_subtable_headers * header,
 			const unsigned long end)
 {
 	struct acpi_madt_interrupt_source *plintsrc;
@@ -329,7 +329,7 @@ unsigned int get_cpei_target_cpu(void)
 }
 
 static int __init
-acpi_parse_int_src_ovr(struct acpi_subtable_header * header,
+acpi_parse_int_src_ovr(union acpi_subtable_headers * header,
 		       const unsigned long end)
 {
 	struct acpi_madt_interrupt_override *p;
@@ -350,7 +350,7 @@ acpi_parse_int_src_ovr(struct acpi_subtable_header * header,
 }
 
 static int __init
-acpi_parse_nmi_src(struct acpi_subtable_header * header, const unsigned long end)
+acpi_parse_nmi_src(union acpi_subtable_headers * header, const unsigned long end)
 {
 	struct acpi_madt_nmi_source *nmi_src;
 
diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
index 2624de16cd7a..b694a32f95d4 100644
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
index 7bbbf8256a41..d6433b14864c 100644
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
index 5efd4219f112..a894ce3556f2 100644
--- a/drivers/acpi/scan.c
+++ b/drivers/acpi/scan.c
@@ -2240,10 +2240,10 @@ static struct acpi_probe_entry *ape;
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
index 48eabb6c2d4f..967e1168becf 100644
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
diff --git a/drivers/irqchip/irq-gic-v2m.c b/drivers/irqchip/irq-gic-v2m.c
index f5fe0100f9ff..de14e06fd9ec 100644
--- a/drivers/irqchip/irq-gic-v2m.c
+++ b/drivers/irqchip/irq-gic-v2m.c
@@ -446,7 +446,7 @@ static struct fwnode_handle *gicv2m_get_fwnode(struct device *dev)
 }
 
 static int __init
-acpi_parse_madt_msi(struct acpi_subtable_header *header,
+acpi_parse_madt_msi(union acpi_subtable_headers *header,
 		    const unsigned long end)
 {
 	int ret;
diff --git a/drivers/irqchip/irq-gic-v3-its-pci-msi.c b/drivers/irqchip/irq-gic-v3-its-pci-msi.c
index 8d6d009d1d58..c81d5b81da56 100644
--- a/drivers/irqchip/irq-gic-v3-its-pci-msi.c
+++ b/drivers/irqchip/irq-gic-v3-its-pci-msi.c
@@ -159,7 +159,7 @@ static int __init its_pci_of_msi_init(void)
 #ifdef CONFIG_ACPI
 
 static int __init
-its_pci_msi_parse_madt(struct acpi_subtable_header *header,
+its_pci_msi_parse_madt(union acpi_subtable_headers *header,
 		       const unsigned long end)
 {
 	struct acpi_madt_generic_translator *its_entry;
diff --git a/drivers/irqchip/irq-gic-v3-its-platform-msi.c b/drivers/irqchip/irq-gic-v3-its-platform-msi.c
index 7b8e87b493fe..9cdcda5bb3bd 100644
--- a/drivers/irqchip/irq-gic-v3-its-platform-msi.c
+++ b/drivers/irqchip/irq-gic-v3-its-platform-msi.c
@@ -117,7 +117,7 @@ static int __init its_pmsi_init_one(struct fwnode_handle *fwnode,
 
 #ifdef CONFIG_ACPI
 static int __init
-its_pmsi_parse_madt(struct acpi_subtable_header *header,
+its_pmsi_parse_madt(union acpi_subtable_headers *header,
 			const unsigned long end)
 {
 	struct acpi_madt_generic_translator *its_entry;
diff --git a/drivers/irqchip/irq-gic-v3-its.c b/drivers/irqchip/irq-gic-v3-its.c
index db20e992a40f..d6677075d68f 100644
--- a/drivers/irqchip/irq-gic-v3-its.c
+++ b/drivers/irqchip/irq-gic-v3-its.c
@@ -3764,13 +3764,13 @@ static int __init acpi_get_its_numa_node(u32 its_id)
 	return NUMA_NO_NODE;
 }
 
-static int __init gic_acpi_match_srat_its(struct acpi_subtable_header *header,
+static int __init gic_acpi_match_srat_its(union acpi_subtable_headers *header,
 					  const unsigned long end)
 {
 	return 0;
 }
 
-static int __init gic_acpi_parse_srat_its(struct acpi_subtable_header *header,
+static int __init gic_acpi_parse_srat_its(union acpi_subtable_headers *header,
 			 const unsigned long end)
 {
 	int node;
@@ -3837,7 +3837,7 @@ static int __init acpi_get_its_numa_node(u32 its_id) { return NUMA_NO_NODE; }
 static void __init acpi_its_srat_maps_free(void) { }
 #endif
 
-static int __init gic_acpi_parse_madt_its(struct acpi_subtable_header *header,
+static int __init gic_acpi_parse_madt_its(union acpi_subtable_headers *header,
 					  const unsigned long end)
 {
 	struct acpi_madt_generic_translator *its_entry;
diff --git a/drivers/irqchip/irq-gic-v3.c b/drivers/irqchip/irq-gic-v3.c
index 0868a9d81c3c..44db6b809c52 100644
--- a/drivers/irqchip/irq-gic-v3.c
+++ b/drivers/irqchip/irq-gic-v3.c
@@ -1392,7 +1392,7 @@ gic_acpi_register_redist(phys_addr_t phys_base, void __iomem *redist_base)
 }
 
 static int __init
-gic_acpi_parse_madt_redist(struct acpi_subtable_header *header,
+gic_acpi_parse_madt_redist(union acpi_subtable_headers *header,
 			   const unsigned long end)
 {
 	struct acpi_madt_generic_redistributor *redist =
@@ -1410,7 +1410,7 @@ gic_acpi_parse_madt_redist(struct acpi_subtable_header *header,
 }
 
 static int __init
-gic_acpi_parse_madt_gicc(struct acpi_subtable_header *header,
+gic_acpi_parse_madt_gicc(union acpi_subtable_headers *header,
 			 const unsigned long end)
 {
 	struct acpi_madt_generic_interrupt *gicc =
@@ -1452,14 +1452,14 @@ static int __init gic_acpi_collect_gicr_base(void)
 	return -ENODEV;
 }
 
-static int __init gic_acpi_match_gicr(struct acpi_subtable_header *header,
+static int __init gic_acpi_match_gicr(union acpi_subtable_headers *header,
 				  const unsigned long end)
 {
 	/* Subtable presence means that redist exists, that's it */
 	return 0;
 }
 
-static int __init gic_acpi_match_gicc(struct acpi_subtable_header *header,
+static int __init gic_acpi_match_gicc(union acpi_subtable_headers *header,
 				      const unsigned long end)
 {
 	struct acpi_madt_generic_interrupt *gicc =
@@ -1525,7 +1525,7 @@ static bool __init acpi_validate_gic_table(struct acpi_subtable_header *header,
 	return true;
 }
 
-static int __init gic_acpi_parse_virt_madt_gicc(struct acpi_subtable_header *header,
+static int __init gic_acpi_parse_virt_madt_gicc(union acpi_subtable_headers *header,
 						const unsigned long end)
 {
 	struct acpi_madt_generic_interrupt *gicc =
diff --git a/drivers/irqchip/irq-gic.c b/drivers/irqchip/irq-gic.c
index ba2a37a27a54..a749d73f8337 100644
--- a/drivers/irqchip/irq-gic.c
+++ b/drivers/irqchip/irq-gic.c
@@ -1508,7 +1508,7 @@ static struct
 } acpi_data __initdata;
 
 static int __init
-gic_acpi_parse_madt_cpu(struct acpi_subtable_header *header,
+gic_acpi_parse_madt_cpu(union acpi_subtable_headers *header,
 			const unsigned long end)
 {
 	struct acpi_madt_generic_interrupt *processor;
@@ -1540,7 +1540,7 @@ gic_acpi_parse_madt_cpu(struct acpi_subtable_header *header,
 }
 
 /* The things you have to do to just *count* something... */
-static int __init acpi_dummy_func(struct acpi_subtable_header *header,
+static int __init acpi_dummy_func(union acpi_subtable_headers *header,
 				  const unsigned long end)
 {
 	return 0;
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
index 87715f20b69a..7c3c4ebaded6 100644
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
