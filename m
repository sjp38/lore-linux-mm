Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E085B6B025E
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 21:10:32 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id n6so3197856pfg.19
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 18:10:32 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id e69si2358748pfc.337.2017.12.13.18.10.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 18:10:31 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v3 1/3] acpi: HMAT support in acpi_parse_entries_array()
Date: Wed, 13 Dec 2017 19:10:17 -0700
Message-Id: <20171214021019.13579-2-ross.zwisler@linux.intel.com>
In-Reply-To: <20171214021019.13579-1-ross.zwisler@linux.intel.com>
References: <20171214021019.13579-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>, "Box, David E" <david.e.box@intel.com>, "Kogut, Jaroslaw" <Jaroslaw.Kogut@intel.com>, "Koss, Marcin" <marcin.koss@intel.com>, "Koziej, Artur" <artur.koziej@intel.com>, "Lahtinen, Joonas" <joonas.lahtinen@intel.com>, "Moore, Robert" <robert.moore@intel.com>, "Nachimuthu, Murugasamy" <murugasamy.nachimuthu@intel.com>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "Schmauss, Erik" <erik.schmauss@intel.com>, "Verma, Vishal L" <vishal.l.verma@intel.com>, "Zheng, Lv" <lv.zheng@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <bsingharora@gmail.com>, Brice Goglin <brice.goglin@gmail.com>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Len Brown <lenb@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, devel@acpica.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

The current implementation of acpi_parse_entries_array() assumes that each
subtable has a standard ACPI subtable entry of type struct
acpi_subtable_header.  This standard subtable header has a one byte length
followed by a one byte type.

The HMAT subtables have to allow for a longer length so they have subtable
headers of type struct acpi_hmat_structure which has a 2 byte type and a 4
byte length.

Enhance the subtable parsing in acpi_parse_entries_array() so that it can
handle these new HMAT subtables.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 drivers/acpi/tables.c | 52 ++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 41 insertions(+), 11 deletions(-)

diff --git a/drivers/acpi/tables.c b/drivers/acpi/tables.c
index 80ce2a7d224b..f777b94c234a 100644
--- a/drivers/acpi/tables.c
+++ b/drivers/acpi/tables.c
@@ -218,6 +218,33 @@ void acpi_table_print_madt_entry(struct acpi_subtable_header *header)
 	}
 }
 
+static unsigned long __init
+acpi_get_entry_type(char *id, void *entry)
+{
+	if (strncmp(id, ACPI_SIG_HMAT, 4) == 0)
+		return ((struct acpi_hmat_structure *)entry)->type;
+	else
+		return ((struct acpi_subtable_header *)entry)->type;
+}
+
+static unsigned long __init
+acpi_get_entry_length(char *id, void *entry)
+{
+	if (strncmp(id, ACPI_SIG_HMAT, 4) == 0)
+		return ((struct acpi_hmat_structure *)entry)->length;
+	else
+		return ((struct acpi_subtable_header *)entry)->length;
+}
+
+static unsigned long __init
+acpi_get_subtable_header_length(char *id)
+{
+	if (strncmp(id, ACPI_SIG_HMAT, 4) == 0)
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
2.14.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
