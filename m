Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 82D096B000A
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 22:14:34 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id a23-v6so2396603pfo.23
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 19:14:34 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id b13-v6si4645352plz.467.2018.08.08.19.14.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Aug 2018 19:14:33 -0700 (PDT)
From: Zhang Yi <yi.z.zhang@linux.intel.com>
Subject: [PATCH V3 2/4] mm: introduce memory type MEMORY_DEVICE_DEV_DAX
Date: Thu,  9 Aug 2018 18:53:08 +0800
Message-Id: <01aaca83694c3b0093fcb2f48af1dff0b147a4b2.1533811181.git.yi.z.zhang@linux.intel.com>
In-Reply-To: <cover.1533811181.git.yi.z.zhang@linux.intel.com>
References: <cover.1533811181.git.yi.z.zhang@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pbonzini@redhat.com, dan.j.williams@intel.com, jack@suse.cz, hch@lst.de, yu.c.zhang@intel.com
Cc: linux-mm@kvack.org, rkrcmar@redhat.com, yi.z.zhang@intel.com, Zhang Yi <yi.z.zhang@linux.intel.com>

Currently, NVDIMM pages will be marked 'PageReserved'. However, unlike
other reserved PFNs, pages on NVDIMM shall still behave like normal ones
in many cases, i.e. when used as backend memory of KVM guest. This patch
introduces a new memory type, MEMORY_DEVICE_DEV_DAX. And set this flag
while dax driver hotplug the device memory.

Signed-off-by: Zhang Yi <yi.z.zhang@linux.intel.com>
Signed-off-by: Zhang Yu <yu.c.zhang@linux.intel.com>
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
