Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 33B8B6B0003
	for <linux-mm@kvack.org>; Thu, 14 Jun 2018 14:25:06 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id g20-v6so3379763pfi.2
        for <linux-mm@kvack.org>; Thu, 14 Jun 2018 11:25:06 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id v11-v6si5947014plp.25.2018.06.14.11.25.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jun 2018 11:25:04 -0700 (PDT)
Subject: [PATCH] mm: disallow mapping that conflict for devm_memremap_pages()
From: Dave Jiang <dave.jiang@intel.com>
Date: Thu, 14 Jun 2018 11:25:03 -0700
Message-ID: <152900070339.49084.2958083852988708457.stgit@djiang5-desk3.ch.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, dan.j.williams@intel.com, linux-nvdimm@lists.01.org

When pmem namespaces created are smaller than section size, this can cause
issue during removal and gpf was observed:

[ 249.613597] general protection fault: 0000 1 SMP PTI
[ 249.725203] CPU: 36 PID: 3941 Comm: ndctl Tainted: G W
4.14.28-1.el7uek.x86_64 #2
[ 249.745495] task: ffff88acda150000 task.stack: ffffc900233a4000
[ 249.752107] RIP: 0010:__put_page+0x56/0x79
[ 249.844675] Call Trace:
[ 249.847410] devm_memremap_pages_release+0x155/0x23a
[ 249.852953] release_nodes+0x21e/0x260
[ 249.857138] devres_release_all+0x3c/0x48
[ 249.861606] device_release_driver_internal+0x15c/0x207
[ 249.867439] device_release_driver+0x12/0x14
[ 249.872204] unbind_store+0xba/0xd8
[ 249.876098] drv_attr_store+0x27/0x31
[ 249.880186] sysfs_kf_write+0x3f/0x46
[ 249.884266] kernfs_fop_write+0x10f/0x18b
[ 249.888734] __vfs_write+0x3a/0x16d
[ 249.892628] ? selinux_file_permission+0xe5/0x116
[ 249.897881] ? security_file_permission+0x41/0xbb
[ 249.903133] vfs_write+0xb2/0x1a1
[ 249.906835] ? syscall_trace_enter+0x1ce/0x2b8
[ 249.911795] SyS_write+0x55/0xb9
[ 249.915397] do_syscall_64+0x79/0x1ae
[ 249.919485] entry_SYSCALL_64_after_hwframe+0x3d/0x0

Add code to check whether we have mapping already in the same section and
prevent additional mapping from created if that is the case.

Signed-off-by: Dave Jiang <dave.jiang@intel.com>
---
 kernel/memremap.c |   18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index 5857267a4af5..d9ac547993cb 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -176,10 +176,27 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 	unsigned long pfn, pgoff, order;
 	pgprot_t pgprot = PAGE_KERNEL;
 	int error, nid, is_ram;
+	struct dev_pagemap *conflict_pgmap;
 
 	align_start = res->start & ~(SECTION_SIZE - 1);
 	align_size = ALIGN(res->start + resource_size(res), SECTION_SIZE)
 		- align_start;
+	align_end = align_start + align_size - 1;
+
+	conflict_pgmap = get_dev_pagemap(PHYS_PFN(align_start), NULL);
+	if (conflict_pgmap) {
+		dev_warn(dev, "Conflicting mapping in same section\n");
+		put_dev_pagemap(conflict_pgmap);
+		return ERR_PTR(-ENOMEM);
+	}
+
+	conflict_pgmap = get_dev_pagemap(PHYS_PFN(align_end), NULL);
+	if (conflict_pgmap) {
+		dev_warn(dev, "Conflicting mapping in same section\n");
+		put_dev_pagemap(conflict_pgmap);
+		return ERR_PTR(-ENOMEM);
+	}
+
 	is_ram = region_intersects(align_start, align_size,
 		IORESOURCE_SYSTEM_RAM, IORES_DESC_NONE);
 
@@ -199,7 +216,6 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 
 	mutex_lock(&pgmap_lock);
 	error = 0;
-	align_end = align_start + align_size - 1;
 
 	foreach_order_pgoff(res, order, pgoff) {
 		error = __radix_tree_insert(&pgmap_radix,
