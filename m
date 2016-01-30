Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id A6ECC6B0254
	for <linux-mm@kvack.org>; Sat, 30 Jan 2016 04:29:54 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id ho8so54408947pac.2
        for <linux-mm@kvack.org>; Sat, 30 Jan 2016 01:29:54 -0800 (PST)
Received: from terminus.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id 84si29645777pfr.114.2016.01.30.01.29.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Jan 2016 01:29:53 -0800 (PST)
Date: Sat, 30 Jan 2016 01:28:45 -0800
From: tip-bot for Toshi Kani <tipbot@zytor.com>
Message-ID: <tip-43ee493bde78da00deaf5737925365c691a036ad@git.kernel.org>
Reply-To: dan.j.williams@intel.com, mingo@kernel.org, toshi.kani@hpe.com,
        bp@alien8.de, torvalds@linux-foundation.org, tglx@linutronix.de,
        linux-mm@kvack.org, hpa@zytor.com, mcgrof@suse.com,
        akpm@linux-foundation.org, jsitnicki@gmail.com, toshi.kani@hp.com,
        dvlasenk@redhat.com, peterz@infradead.org, luto@amacapital.net,
        jiang.liu@linux.intel.com, linux-kernel@vger.kernel.org, bp@suse.de,
        brgerst@gmail.com
In-Reply-To: <1453841853-11383-4-git-send-email-bp@alien8.de>
References: <1453841853-11383-4-git-send-email-bp@alien8.de>
Subject: [tip:core/resources] resource: Add I/O resource descriptor
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: hpa@zytor.com, mcgrof@suse.com, akpm@linux-foundation.org, jsitnicki@gmail.com, dvlasenk@redhat.com, toshi.kani@hp.com, dan.j.williams@intel.com, mingo@kernel.org, toshi.kani@hpe.com, torvalds@linux-foundation.org, bp@alien8.de, tglx@linutronix.de, linux-mm@kvack.org, bp@suse.de, brgerst@gmail.com, jiang.liu@linux.intel.com, luto@amacapital.net, peterz@infradead.org, linux-kernel@vger.kernel.org

Commit-ID:  43ee493bde78da00deaf5737925365c691a036ad
Gitweb:     http://git.kernel.org/tip/43ee493bde78da00deaf5737925365c691a036ad
Author:     Toshi Kani <toshi.kani@hpe.com>
AuthorDate: Tue, 26 Jan 2016 21:57:19 +0100
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Sat, 30 Jan 2016 09:49:56 +0100

resource: Add I/O resource descriptor

walk_iomem_res() and region_intersects() still need to use
strcmp() for searching a resource entry by @name in the iomem
table.

This patch introduces I/O resource descriptor 'desc' in struct
resource for the iomem search interfaces. Drivers can assign
their unique descriptor to a range when they support the search
interfaces.

Otherwise, 'desc' is set to IORES_DESC_NONE (0). This avoids
changing most of the drivers as they typically allocate resource
entries statically, or by calling alloc_resource(), kzalloc(),
or alloc_bootmem_low(), which set the field to zero by default.
A later patch will address some drivers that use kmalloc()
without zero'ing the field.

Also change release_mem_region_adjustable() to set 'desc' when
its resource entry gets separated. Other resource interfaces are
also changed to initialize 'desc' explicitly although
alloc_resource() sets it to 0.

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Signed-off-by: Borislav Petkov <bp@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Jakub Sitnicki <jsitnicki@gmail.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Toshi Kani <toshi.kani@hp.com>
Cc: linux-arch@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>
Link: http://lkml.kernel.org/r/1453841853-11383-4-git-send-email-bp@alien8.de
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/ioport.h | 18 ++++++++++++++++++
 kernel/resource.c      |  5 +++++
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
index 96afc80..61512e9 100644
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
