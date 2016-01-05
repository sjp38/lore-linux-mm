Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id 720E96B0006
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 13:55:26 -0500 (EST)
Received: by mail-oi0-f50.google.com with SMTP id o124so279609012oia.1
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 10:55:26 -0800 (PST)
Received: from g9t5009.houston.hp.com (g9t5009.houston.hp.com. [15.240.92.67])
        by mx.google.com with ESMTPS id n1si26928946oex.12.2016.01.05.10.55.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 10:55:25 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v3 03/17] resource: Add I/O resource descriptor
Date: Tue,  5 Jan 2016 11:54:27 -0700
Message-Id: <1452020081-26534-3-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1452020081-26534-1-git-send-email-toshi.kani@hpe.com>
References: <1452020081-26534-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, bp@alien8.de
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Toshi Kani <toshi.kani@hpe.com>

walk_iomem_res() and region_intersects() still need to use
strcmp() for searching a resource entry by @name in the
iomem table.

This patch introduces I/O resource descriptor, 'desc' in
struct resoruce, for the iomem search interfaces.  Drivers
can assign their unique descritor to a range when they
support the search interfaces.  Otherwise, 'desc' is set to
IORES_DESC_NONE (0).  This avoids changing most of the drivers
as they typically allocate resource entries statically, or
by calling alloc_resource(), kzalloc(), or alloc_bootmem_low(),
which set the field to zero by default.  A later patch will
address some drivers that use kmalloc() without zero'ing
the field.

Also change release_mem_region_adjustable() to set 'desc'
when its resource entry gets separated.  Other resource
interfaces are also changed to initialize 'desc' explicitly
although alloc_resource() sets it to 0.

Link: http://lkml.kernel.org/r/<20151216181712.GJ29775@pd.tnic>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
---
 include/linux/ioport.h |   18 ++++++++++++++++++
 kernel/resource.c      |    5 +++++
 2 files changed, 23 insertions(+)

diff --git a/include/linux/ioport.h b/include/linux/ioport.h
index 4b65d94..983bea0 100644
--- a/include/linux/ioport.h
+++ b/include/linux/ioport.h
@@ -20,6 +20,7 @@ struct resource {
 	resource_size_t end;
 	const char *name;
 	unsigned long flags;
+	unsigned long desc;
 	struct resource *parent, *sibling, *child;
 };
 
@@ -112,6 +113,22 @@ struct resource {
 /* PCI control bits.  Shares IORESOURCE_BITS with above PCI ROM.  */
 #define IORESOURCE_PCI_FIXED		(1<<4)	/* Do not move resource */
 
+/*
+ * I/O Resource Descriptors
+ *
+ * Descriptors are used by walk_iomem_res_desc() and region_intersects()
+ * for searching a specific resource range in the iomem table.  Assign
+ * a new descriptor when a resource range supports the search interfaces.
+ * Otherwise, resource.desc must be set to IORES_DESC_NONE (0).
+ */
+enum {
+	IORES_DESC_NONE				= 0,
+	IORES_DESC_CRASH_KERNEL			= 1,
+	IORES_DESC_ACPI_TABLES			= 2,
+	IORES_DESC_ACPI_NV_STORAGE		= 3,
+	IORES_DESC_PERSISTENT_MEMORY		= 4,
+	IORES_DESC_PERSISTENT_MEMORY_LEGACY	= 5,
+};
 
 /* helpers to define resources */
 #define DEFINE_RES_NAMED(_start, _size, _name, _flags)			\
@@ -120,6 +137,7 @@ struct resource {
 		.end = (_start) + (_size) - 1,				\
 		.name = (_name),					\
 		.flags = (_flags),					\
+		.desc = IORES_DESC_NONE,				\
 	}
 
 #define DEFINE_RES_IO_NAMED(_start, _size, _name)			\
diff --git a/kernel/resource.c b/kernel/resource.c
index d30a175..65eca4d 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -949,6 +949,7 @@ static void __init __reserve_region_with_split(struct resource *root,
 	res->start = start;
 	res->end = end;
 	res->flags = IORESOURCE_BUSY;
+	res->desc = IORES_DESC_NONE;
 
 	while (1) {
 
@@ -983,6 +984,7 @@ static void __init __reserve_region_with_split(struct resource *root,
 				next_res->start = conflict->end + 1;
 				next_res->end = end;
 				next_res->flags = IORESOURCE_BUSY;
+				next_res->desc = IORES_DESC_NONE;
 			}
 		} else {
 			res->start = conflict->end + 1;
@@ -1074,6 +1076,7 @@ struct resource * __request_region(struct resource *parent,
 	res->end = start + n - 1;
 	res->flags = resource_type(parent) | resource_ext_type(parent);
 	res->flags |= IORESOURCE_BUSY | flags;
+	res->desc = IORES_DESC_NONE;
 
 	write_lock(&resource_lock);
 
@@ -1238,6 +1241,7 @@ int release_mem_region_adjustable(struct resource *parent,
 			new_res->start = end + 1;
 			new_res->end = res->end;
 			new_res->flags = res->flags;
+			new_res->desc = res->desc;
 			new_res->parent = res->parent;
 			new_res->sibling = res->sibling;
 			new_res->child = NULL;
@@ -1413,6 +1417,7 @@ static int __init reserve_setup(char *str)
 			res->start = io_start;
 			res->end = io_start + io_num - 1;
 			res->flags = IORESOURCE_BUSY;
+			res->desc = IORES_DESC_NONE;
 			res->child = NULL;
 			if (request_resource(res->start >= 0x10000 ? &iomem_resource : &ioport_resource, res) == 0)
 				reserved = x+1;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
