Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 863716B0255
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 16:38:34 -0500 (EST)
Received: by obbww6 with SMTP id ww6so24380652obb.0
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 13:38:34 -0800 (PST)
Received: from g9t5008.houston.hp.com (g9t5008.houston.hp.com. [15.240.92.66])
        by mx.google.com with ESMTPS id e198si7047175oih.37.2015.11.24.13.38.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 13:38:32 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v3 2/3] resource: Add region_intersects_pmem()
Date: Tue, 24 Nov 2015 15:33:37 -0700
Message-Id: <1448404418-28800-3-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1448404418-28800-1-git-send-email-toshi.kani@hpe.com>
References: <1448404418-28800-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rjw@rjwysocki.net, dan.j.williams@intel.com
Cc: tony.luck@intel.com, bp@alien8.de, vishal.l.verma@intel.com, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, Toshi Kani <toshi.kani@hpe.com>

Add region_intersects_pmem(), which checks if a specified address
range is persistent memory registered as "Persistent Memory" in
the iomem_resource list.

Note, it does not support legacy persistent memory registered as
"Persistent Memory (legacy)".  It can be supported by extending
this function or a separate function, if necessary.

This interface is exported so that it can be called from modules,
such as the EINJ driver.

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Reviewed-by: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Vishal Verma <vishal.l.verma@intel.com>
---
 include/linux/mm.h |    1 +
 kernel/resource.c  |   12 ++++++++++++
 2 files changed, 13 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index c776af3..3825879 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -365,6 +365,7 @@ enum {
 int region_intersects(resource_size_t offset, size_t size, const char *type,
 			unsigned long flags);
 int region_intersects_ram(resource_size_t offset, size_t size);
+int region_intersects_pmem(resource_size_t offset, size_t size);
 
 /* Support for virtually mapped pages */
 struct page *vmalloc_to_page(const void *addr);
diff --git a/kernel/resource.c b/kernel/resource.c
index 15c133e..5230e63 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -548,6 +548,18 @@ int region_intersects_ram(resource_size_t start, size_t size)
 }
 EXPORT_SYMBOL_GPL(region_intersects_ram);
 
+/*
+ * region_intersects_pmem() checks if a specified address range is
+ * persistent memory, registered as "Persistent Memory", in the
+ * iomem_resource list.
+ */
+int region_intersects_pmem(resource_size_t start, size_t size)
+{
+	return region_intersects(start, size, "Persistent Memory",
+				 IORESOURCE_MEM);
+}
+EXPORT_SYMBOL_GPL(region_intersects_pmem);
+
 void __weak arch_remove_reservations(struct resource *avail)
 {
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
