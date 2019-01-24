Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1321C8E00A6
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 18:08:30 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id y88so5915403pfi.9
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 15:08:30 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id i7si24473410pgc.144.2019.01.24.15.08.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jan 2019 15:08:29 -0800 (PST)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCHv5 09/10] acpi/hmat: Register memory side cache attributes
Date: Thu, 24 Jan 2019 16:07:23 -0700
Message-Id: <20190124230724.10022-10-keith.busch@intel.com>
In-Reply-To: <20190124230724.10022-1-keith.busch@intel.com>
References: <20190124230724.10022-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>

Register memory side cache attributes with the memory's node if HMAT
provides the side cache iniformation table.

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 drivers/acpi/hmat/hmat.c | 32 ++++++++++++++++++++++++++++++++
 1 file changed, 32 insertions(+)

diff --git a/drivers/acpi/hmat/hmat.c b/drivers/acpi/hmat/hmat.c
index 917e6122b3f0..11f65b38e9f9 100644
--- a/drivers/acpi/hmat/hmat.c
+++ b/drivers/acpi/hmat/hmat.c
@@ -245,6 +245,7 @@ static __init int hmat_parse_cache(union acpi_subtable_headers *header,
 				   const unsigned long end)
 {
 	struct acpi_hmat_cache *cache = (void *)header;
+	struct node_cache_attrs cache_attrs;
 	u32 attrs;
 
 	if (cache->header.length < sizeof(*cache)) {
@@ -258,6 +259,37 @@ static __init int hmat_parse_cache(union acpi_subtable_headers *header,
 		cache->memory_PD, cache->cache_size, attrs,
 		cache->number_of_SMBIOShandles);
 
+	cache_attrs.size = cache->cache_size;
+	cache_attrs.level = (attrs & ACPI_HMAT_CACHE_LEVEL) >> 4;
+	cache_attrs.line_size = (attrs & ACPI_HMAT_CACHE_LINE_SIZE) >> 16;
+
+	switch ((attrs & ACPI_HMAT_CACHE_ASSOCIATIVITY) >> 8) {
+	case ACPI_HMAT_CA_DIRECT_MAPPED:
+		cache_attrs.associativity = NODE_CACHE_DIRECT_MAP;
+		break;
+	case ACPI_HMAT_CA_COMPLEX_CACHE_INDEXING:
+		cache_attrs.associativity = NODE_CACHE_INDEXED;
+		break;
+	case ACPI_HMAT_CA_NONE:
+	default:
+		cache_attrs.associativity = NODE_CACHE_OTHER;
+		break;
+	}
+
+	switch ((attrs & ACPI_HMAT_WRITE_POLICY) >> 12) {
+	case ACPI_HMAT_CP_WB:
+		cache_attrs.write_policy = NODE_CACHE_WRITE_BACK;
+		break;
+	case ACPI_HMAT_CP_WT:
+		cache_attrs.write_policy = NODE_CACHE_WRITE_THROUGH;
+		break;
+	case ACPI_HMAT_CP_NONE:
+	default:
+		cache_attrs.write_policy = NODE_CACHE_WRITE_OTHER;
+		break;
+	}
+
+	node_add_cache(pxm_to_node(cache->memory_PD), &cache_attrs);
 	return 0;
 }
 
-- 
2.14.4
