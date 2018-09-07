Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 984316B7DA1
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 05:24:37 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id r20-v6so6970550pgv.20
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 02:24:37 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id u15-v6si7957939pgi.76.2018.09.07.02.24.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Sep 2018 02:24:36 -0700 (PDT)
From: Zhang Yi <yi.z.zhang@linux.intel.com>
Subject: [PATCH V5 2/4] mm: introduce memory type MEMORY_DEVICE_DEV_DAX
Date: Sat,  8 Sep 2018 02:03:39 +0800
Message-Id: <c0b53c74379e6d654bbe42471fcef8aa5fd22efd.1536342881.git.yi.z.zhang@linux.intel.com>
In-Reply-To: <cover.1536342881.git.yi.z.zhang@linux.intel.com>
References: <cover.1536342881.git.yi.z.zhang@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pbonzini@redhat.com, dan.j.williams@intel.com, dave.jiang@intel.com, yu.c.zhang@intel.com, pagupta@redhat.com, david@redhat.com, jack@suse.cz, hch@lst.de
Cc: linux-mm@kvack.org, rkrcmar@redhat.com, jglisse@redhat.com, yi.z.zhang@intel.com, Zhang Yi <yi.z.zhang@linux.intel.com>

Currently, NVDIMM pages will be marked 'PageReserved'. However, unlike
other reserved PFNs, pages on NVDIMM shall still behave like normal ones
in many cases, i.e. when used as backend memory of KVM guest. This patch
introduces a new memory type, MEMORY_DEVICE_DEV_DAX. And set this flag
while dax driver hotplug the device memory.

Signed-off-by: Zhang Yi <yi.z.zhang@linux.intel.com>
Signed-off-by: Zhang Yu <yu.c.zhang@linux.intel.com>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 drivers/dax/pmem.c       | 1 +
 include/linux/memremap.h | 8 ++++++++
 2 files changed, 9 insertions(+)

diff --git a/drivers/dax/pmem.c b/drivers/dax/pmem.c
index fd49b24..fb3f363 100644
--- a/drivers/dax/pmem.c
+++ b/drivers/dax/pmem.c
@@ -111,6 +111,7 @@ static int dax_pmem_probe(struct device *dev)
 		return rc;
 
 	dax_pmem->pgmap.ref = &dax_pmem->ref;
+	dax_pmem->pgmap.type = MEMORY_DEVICE_DEV_DAX;
 	addr = devm_memremap_pages(dev, &dax_pmem->pgmap);
 	if (IS_ERR(addr))
 		return PTR_ERR(addr);
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index f91f9e7..cd07ca8 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -53,11 +53,19 @@ struct vmem_altmap {
  * wakeup event whenever a page is unpinned and becomes idle. This
  * wakeup is used to coordinate physical address space management (ex:
  * fs truncate/hole punch) vs pinned pages (ex: device dma).
+ *
+ * MEMORY_DEVICE_DEV_DAX:
+ * Device memory that support raw access to persistent memory. Without need
+ * of an intervening filesystem, it could be directed mapped via an mmap
+ * capable character device. Together with the type MEMORY_DEVICE_FS_DAX,
+ * we could distinguish the persistent memory pages from normal ZONE_DEVICE
+ * pages.
  */
 enum memory_type {
 	MEMORY_DEVICE_PRIVATE = 1,
 	MEMORY_DEVICE_PUBLIC,
 	MEMORY_DEVICE_FS_DAX,
+	MEMORY_DEVICE_DEV_DAX,
 };
 
 /*
-- 
2.7.4
