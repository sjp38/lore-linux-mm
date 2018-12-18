Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id A96D58E0001
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 23:36:10 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id 68so14025034pfr.6
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 20:36:10 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 97si12335161plm.312.2018.12.17.20.36.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 20:36:09 -0800 (PST)
Subject: [PATCH v6 2/6] acpi: Add HMAT to generic parsing tables
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 17 Dec 2018 20:23:33 -0800
Message-ID: <154510701343.1941238.7745758103869136625.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <154510700291.1941238.817190985966612531.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <154510700291.1941238.817190985966612531.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Keith Busch <keith.busch@intel.com>, peterz@infradead.org, dave.hansen@linux.intel.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, mgorman@suse.de

From: Keith Busch <keith.busch@intel.com>

The HMAT table header has different field lengths than the existing
parsing uses. Add the HMAT type to the parsing rules so it may be
generically parsed.

Signed-off-by: Keith Busch <keith.busch@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/acpi/tables.c |    9 +++++++++
 include/linux/acpi.h  |    1 +
 2 files changed, 10 insertions(+)

diff --git a/drivers/acpi/tables.c b/drivers/acpi/tables.c
index e9643b4267c7..bc1addf715dc 100644
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
index 18805a967c70..4373f5ba0f95 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -143,6 +143,7 @@ enum acpi_address_range_id {
 /* Table Handlers */
 union acpi_subtable_headers {
 	struct acpi_subtable_header common;
+	struct acpi_hmat_structure hmat;
 };
 
 typedef int (*acpi_tbl_table_handler)(struct acpi_table_header *table);
