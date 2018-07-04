Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0F4566B0269
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 02:52:04 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id f9-v6so1217583pfn.22
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 23:52:04 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id a7-v6si3071668pfg.200.2018.07.03.23.52.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 23:52:03 -0700 (PDT)
From: Zhang Yi <yi.z.zhang@linux.intel.com>
Subject: [PATCH 2/3] mm: introduce memory type MEMORY_DEVICE_DEV_DAX
Date: Wed,  4 Jul 2018 23:30:19 +0800
Message-Id: <5c7996b8e6d31541f3185f8e4064ff97582c86f8.1530716899.git.yi.z.zhang@linux.intel.com>
In-Reply-To: <cover.1530716899.git.yi.z.zhang@linux.intel.com>
References: <cover.1530716899.git.yi.z.zhang@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pbonzini@redhat.com, dan.j.williams@intel.com, jack@suse.cz, hch@lst.de, yu.c.zhang@intel.com
Cc: linux-mm@kvack.org, rkrcmar@redhat.com, yi.z.zhang@intel.com, Zhang Yi <yi.z.zhang@linux.intel.com>

Currently, NVDIMM pages will be marked 'PageReserved'. However, unlike
other reserved PFNs, pages on NVDIMM shall still behave like normal ones
in many cases, i.e. when used as backend memory of KVM guest. This patch
introduces a new memory type, MEMORY_DEVICE_DEV_DAX. Together with the
existing type MEMORY_DEVICE_FS_DAX, we can differentiate the pages on
NVDIMM with the normal reserved pages.

Signed-off-by: Zhang Yi <yi.z.zhang@linux.intel.com>
Signed-off-by: Zhang Yu <yu.c.zhang@linux.intel.com>
---
 drivers/dax/pmem.c       | 1 +
 include/linux/memremap.h | 1 +
 2 files changed, 2 insertions(+)

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
index 5ebfff6..4127bf7 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -58,6 +58,7 @@ enum memory_type {
 	MEMORY_DEVICE_PRIVATE = 1,
 	MEMORY_DEVICE_PUBLIC,
 	MEMORY_DEVICE_FS_DAX,
+	MEMORY_DEVICE_DEV_DAX,
 };
 
 /*
-- 
2.7.4
