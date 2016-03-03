Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 08AAD6B0257
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 16:53:34 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id w128so22448169pfb.2
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 13:53:34 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id wz4si640581pab.145.2016.03.03.13.53.33
        for <linux-mm@kvack.org>;
        Thu, 03 Mar 2016 13:53:33 -0800 (PST)
Subject: [PATCH v2 1/3] libnvdimm,
 pmem: fix 'pfn' support for section-misaligned namespaces
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 03 Mar 2016 13:53:09 -0800
Message-ID: <20160303215309.1014.4943.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <20160303215304.1014.69931.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <20160303215304.1014.69931.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

The altmap for a section-misaligned namespace needs to arrange for the
base_pfn to be section-aligned.  As a result the 'reserve' region (pfns
from base that do not have a struct page) must be increased.  Otherwise
we trip the altmap validation check in __add_pages:

	if (altmap->base_pfn != phys_start_pfn
			|| vmem_altmap_offset(altmap) > nr_pages) {
		pr_warn_once("memory add fail, invalid altmap\n");
		return -EINVAL;
	}

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/nvdimm/pfn.h  |   13 +++++++++++++
 drivers/nvdimm/pmem.c |   24 ++++++++++++++++++++++--
 2 files changed, 35 insertions(+), 2 deletions(-)

diff --git a/drivers/nvdimm/pfn.h b/drivers/nvdimm/pfn.h
index cc243754acef..6ee707e5b279 100644
--- a/drivers/nvdimm/pfn.h
+++ b/drivers/nvdimm/pfn.h
@@ -15,6 +15,7 @@
 #define __NVDIMM_PFN_H
 
 #include <linux/types.h>
+#include <linux/mmzone.h>
 
 #define PFN_SIG_LEN 16
 #define PFN_SIG "NVDIMM_PFN_INFO\0"
@@ -32,4 +33,16 @@ struct nd_pfn_sb {
 	u8 padding[4012];
 	__le64 checksum;
 };
+
+#ifdef CONFIG_SPARSEMEM
+#define PFN_SECTION_ALIGN_DOWN(x) SECTION_ALIGN_DOWN(x)
+#define PFN_SECTION_ALIGN_UP(x) SECTION_ALIGN_UP(x)
+#else
+/*
+ * In this case ZONE_DEVICE=n and we will disable 'pfn' device support,
+ * but we still want pmem to compile.
+ */
+#define PFN_SECTION_ALIGN_DOWN(x) (x)
+#define PFN_SECTION_ALIGN_UP(x) (x)
+#endif
 #endif /* __NVDIMM_PFN_H */
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index 7edf31671dab..68a20b2e3d03 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -356,6 +356,26 @@ static int nvdimm_namespace_detach_pfn(struct nd_namespace_common *ndns)
 	return 0;
 }
 
+/*
+ * We hotplug memory at section granularity, pad the reserved area from
+ * the previous section base to the namespace base address.
+ */
+static unsigned long init_altmap_base(resource_size_t base)
+{
+	unsigned long base_pfn = __phys_to_pfn(base);
+
+	return PFN_SECTION_ALIGN_DOWN(base_pfn);
+}
+
+static unsigned long init_altmap_reserve(resource_size_t base)
+{
+	unsigned long reserve = __phys_to_pfn(SZ_8K);
+	unsigned long base_pfn = __phys_to_pfn(base);
+
+	reserve += base_pfn - PFN_SECTION_ALIGN_DOWN(base_pfn);
+	return reserve;
+}
+
 static int nvdimm_namespace_attach_pfn(struct nd_namespace_common *ndns)
 {
 	struct nd_namespace_io *nsio = to_nd_namespace_io(&ndns->dev);
@@ -369,8 +389,8 @@ static int nvdimm_namespace_attach_pfn(struct nd_namespace_common *ndns)
 	phys_addr_t offset;
 	int rc;
 	struct vmem_altmap __altmap = {
-		.base_pfn = __phys_to_pfn(nsio->res.start),
-		.reserve = __phys_to_pfn(SZ_8K),
+		.base_pfn = init_altmap_base(nsio->res.start),
+		.reserve = init_altmap_reserve(nsio->res.start),
 	};
 
 	if (!nd_pfn->uuid || !nd_pfn->ndns)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
