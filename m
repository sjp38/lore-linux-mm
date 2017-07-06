Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 038776B02C3
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 17:52:47 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u62so15038539pgb.13
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 14:52:46 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id r9si736092pfe.5.2017.07.06.14.52.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jul 2017 14:52:46 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [RFC v2 2/5] acpi: HMAT support in acpi_parse_entries_array()
Date: Thu,  6 Jul 2017 15:52:30 -0600
Message-Id: <20170706215233.11329-3-ross.zwisler@linux.intel.com>
In-Reply-To: <20170706215233.11329-1-ross.zwisler@linux.intel.com>
References: <20170706215233.11329-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>, "Box, David E" <david.e.box@intel.com>, "Kogut, Jaroslaw" <Jaroslaw.Kogut@intel.com>, "Lahtinen, Joonas" <joonas.lahtinen@intel.com>, "Moore, Robert" <robert.moore@intel.com>, "Nachimuthu, Murugasamy" <murugasamy.nachimuthu@intel.com>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "Schmauss, Erik" <erik.schmauss@intel.com>, "Verma, Vishal L" <vishal.l.verma@intel.com>, "Zheng, Lv" <lv.zheng@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jerome Glisse <jglisse@redhat.com>, Len Brown <lenb@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, devel@acpica.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

The current implementation of acpi_parse_entries_array() assumes that each
subtable has a standard ACPI subtable entry of type struct
acpi_sutbable_header.  This standard subtable header has a one byte length
followed by a one byte type.

The HMAT subtables have to allow for a longer length so they have subtable
headers of type struct acpi_hmat_structure which has a 2 byte type and a 4
byte length.

Enhance the subtable parsing in acpi_parse_entries_array() so that it can
handle these new HMAT subtables.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 drivers/acpi/numa.c   |  2 +-
 drivers/acpi/tables.c | 52 ++++++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 42 insertions(+), 12 deletions(-)

diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
index edb0c79..917f1cc 100644
--- a/drivers/acpi/numa.c
+++ b/drivers/acpi/numa.c
@@ -443,7 +443,7 @@ int __init acpi_numa_init(void)
 	 * So go over all cpu entries in SRAT to get apicid to node mapping.
 	 */
 
-	/* SRAT: Static Resource Affinity Table */
+	/* SRAT: System Resource Affinity Table */
 	if (!acpi_table_parse(ACPI_SIG_SRAT, acpi_parse_srat)) {
 		struct acpi_subtable_proc srat_proc[3];
 
diff --git a/drivers/acpi/tables.c b/drivers/acpi/tables.c
index ff42539..7979171 100644
--- a/drivers/acpi/tables.c
+++ b/drivers/acpi/tables.c
@@ -218,6 +218,33 @@ void acpi_table_print_madt_entry(struct acpi_subtable_header *header)
 	}
 }
 
+static unsigned long __init
+acpi_get_entry_type(char *id, void *entry)
+{
+	if (!strncmp(id, ACPI_SIG_HMAT, 4))
+		return ((struct acpi_hmat_structure *)entry)->type;
+	else
+		return ((struct acpi_subtable_header *)entry)->type;
+}
+
+static unsigned long __init
+acpi_get_entry_length(char *id, void *entry)
+{
+	if (!strncmp(id, ACPI_SIG_HMAT, 4))
+		return ((struct acpi_hmat_structure *)entry)->length;
+	else
+		return ((struct acpi_subtable_header *)entry)->length;
+}
+
+static unsigned long __init
+acpi_get_subtable_header_length(char *id)
+{
+	if (!strncmp(id, ACPI_SIG_HMAT, 4))
+		return sizeof(struct acpi_hmat_structure);
+	else
+		return sizeof(struct acpi_subtable_header);
+}
+
 /**
  * acpi_parse_entries_array - for each proc_num find a suitable subtable
  *
@@ -242,10 +269,10 @@ acpi_parse_entries_array(char *id, unsigned long table_size,
 		struct acpi_subtable_proc *proc, int proc_num,
 		unsigned int max_entries)
 {
-	struct acpi_subtable_header *entry;
-	unsigned long table_end;
+	unsigned long table_end, subtable_header_length;
 	int count = 0;
 	int errs = 0;
+	void *entry;
 	int i;
 
 	if (acpi_disabled)
@@ -263,19 +290,23 @@ acpi_parse_entries_array(char *id, unsigned long table_size,
 	}
 
 	table_end = (unsigned long)table_header + table_header->length;
+	subtable_header_length = acpi_get_subtable_header_length(id);
 
 	/* Parse all entries looking for a match. */
 
-	entry = (struct acpi_subtable_header *)
-	    ((unsigned long)table_header + table_size);
+	entry = (void *)table_header + table_size;
+
+	while (((unsigned long)entry) + subtable_header_length  < table_end) {
+		unsigned long entry_type, entry_length;
 
-	while (((unsigned long)entry) + sizeof(struct acpi_subtable_header) <
-	       table_end) {
 		if (max_entries && count >= max_entries)
 			break;
 
+		entry_type = acpi_get_entry_type(id, entry);
+		entry_length = acpi_get_entry_length(id, entry);
+
 		for (i = 0; i < proc_num; i++) {
-			if (entry->type != proc[i].id)
+			if (entry_type != proc[i].id)
 				continue;
 			if (!proc[i].handler ||
 			     (!errs && proc[i].handler(entry, table_end))) {
@@ -290,16 +321,15 @@ acpi_parse_entries_array(char *id, unsigned long table_size,
 			count++;
 
 		/*
-		 * If entry->length is 0, break from this loop to avoid
+		 * If entry_length is 0, break from this loop to avoid
 		 * infinite loop.
 		 */
-		if (entry->length == 0) {
+		if (entry_length == 0) {
 			pr_err("[%4.4s:0x%02x] Invalid zero length\n", id, proc->id);
 			return -EINVAL;
 		}
 
-		entry = (struct acpi_subtable_header *)
-		    ((unsigned long)entry + entry->length);
+		entry += entry_length;
 	}
 
 	if (max_entries && count > max_entries) {
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
