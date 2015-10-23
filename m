Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 721876B0253
	for <linux-mm@kvack.org>; Fri, 23 Oct 2015 14:57:53 -0400 (EDT)
Received: by obbwb3 with SMTP id wb3so101356543obb.0
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 11:57:53 -0700 (PDT)
Received: from g2t4622.austin.hp.com (g2t4622.austin.hp.com. [15.73.212.79])
        by mx.google.com with ESMTPS id rk8si13202761oeb.17.2015.10.23.11.57.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Oct 2015 11:57:50 -0700 (PDT)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v2 2/3] resource: Add region_intersects_pmem()
Date: Fri, 23 Oct 2015 12:53:58 -0600
Message-Id: <1445626439-8424-3-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1445626439-8424-1-git-send-email-toshi.kani@hpe.com>
References: <1445626439-8424-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, dan.j.williams@intel.com, rjw@rjwysocki.net
Cc: linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, Toshi Kani <toshi.kani@hpe.com>

Add region_intersects_pmem(), which checks if a specified address
range is persistent memory registered as "Persistent Memory" in
the iomem_resource list.

Note, it does not support legacy persistent memory registered as
"Persistent Memory (legacy)".  It can be supported by extending
this function or a separate function, if necessary.

This interface is exported so that it can be called from modules,
such as the EINJ driver.

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
---
 include/linux/mm.h |    1 +
 kernel/resource.c  |   12 ++++++++++++
 2 files changed, 13 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 699224e..ae1790f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -361,6 +361,7 @@ enum {
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
