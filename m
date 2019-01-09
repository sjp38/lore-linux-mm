Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0CC158E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 12:47:48 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id v2so4568806plg.6
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 09:47:48 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id f75si4647455pff.131.2019.01.09.09.47.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 09:47:47 -0800 (PST)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCHv3 02/13] acpi: Add HMAT to generic parsing tables
Date: Wed,  9 Jan 2019 10:43:30 -0700
Message-Id: <20190109174341.19818-3-keith.busch@intel.com>
In-Reply-To: <20190109174341.19818-1-keith.busch@intel.com>
References: <20190109174341.19818-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>

The Heterogeneous Memory Attribute Table (HMAT) header has different
field lengths than the existing parsing uses. Add the HMAT type to the
parsing rules so it may be generically parsed.

Cc: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 drivers/acpi/tables.c | 9 +++++++++
 include/linux/acpi.h  | 1 +
 2 files changed, 10 insertions(+)

diff --git a/drivers/acpi/tables.c b/drivers/acpi/tables.c
index 967e1168becf..d9911cd55edc 100644
--- a/drivers/acpi/tables.c
+++ b/drivers/acpi/tables.c
@@ -51,6 +51,7 @@ static int acpi_apic_instance __initdata;
 
 enum acpi_subtable_type {
 	ACPI_SUBTABLE_COMMON,
+	ACPI_SUBTABLE_HMAT,
 };
 
 struct acpi_subtable_entry {
@@ -232,6 +233,8 @@ acpi_get_entry_type(struct acpi_subtable_entry *entry)
 	switch (entry->type) {
 	case ACPI_SUBTABLE_COMMON:
 		return entry->hdr->common.type;
+	case ACPI_SUBTABLE_HMAT:
+		return entry->hdr->hmat.type;
 	}
 	return 0;
 }
@@ -242,6 +245,8 @@ acpi_get_entry_length(struct acpi_subtable_entry *entry)
 	switch (entry->type) {
 	case ACPI_SUBTABLE_COMMON:
 		return entry->hdr->common.length;
+	case ACPI_SUBTABLE_HMAT:
+		return entry->hdr->hmat.length;
 	}
 	return 0;
 }
@@ -252,6 +257,8 @@ acpi_get_subtable_header_length(struct acpi_subtable_entry *entry)
 	switch (entry->type) {
 	case ACPI_SUBTABLE_COMMON:
 		return sizeof(entry->hdr->common);
+	case ACPI_SUBTABLE_HMAT:
+		return sizeof(entry->hdr->hmat);
 	}
 	return 0;
 }
@@ -259,6 +266,8 @@ acpi_get_subtable_header_length(struct acpi_subtable_entry *entry)
 static enum acpi_subtable_type __init
 acpi_get_subtable_type(char *id)
 {
+	if (strncmp(id, ACPI_SIG_HMAT, 4) == 0)
+		return ACPI_SUBTABLE_HMAT;
 	return ACPI_SUBTABLE_COMMON;
 }
 
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index 7c3c4ebaded6..53f93dff171c 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -143,6 +143,7 @@ enum acpi_address_range_id {
 /* Table Handlers */
 union acpi_subtable_headers {
 	struct acpi_subtable_header common;
+	struct acpi_hmat_structure hmat;
 };
 
 typedef int (*acpi_tbl_table_handler)(struct acpi_table_header *table);
-- 
2.14.4
