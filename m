Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 4CA846B0253
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 21:56:50 -0500 (EST)
Received: by mail-pf0-f174.google.com with SMTP id w128so58712304pfb.2
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 18:56:50 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id iv8si7992264pac.104.2016.02.29.18.56.49
        for <linux-mm@kvack.org>;
        Mon, 29 Feb 2016 18:56:49 -0800 (PST)
Subject: [PATCH 1/2] libnvdimm,
 pmem: fix 'pfn' support for section-misaligned namespaces
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 29 Feb 2016 18:56:26 -0800
Message-ID: <20160301025626.12812.4840.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <20160301025620.12812.87268.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <20160301025620.12812.87268.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

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
 drivers/nvdimm/pmem.c |   29 +++++++++++++++++++++++++++--
 1 file changed, 27 insertions(+), 2 deletions(-)

diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index efc2a5e671c6..6a6283ab974c 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -356,6 +356,31 @@ static int nvdimm_namespace_detach_pfn(struct nd_namespace_common *ndns)
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
+#ifdef CONFIG_SPARSEMEM
+	base_pfn = SECTION_ALIGN_DOWN(base_pfn);
+#endif
+	return base_pfn;
+}
+
+static unsigned long init_altmap_reserve(resource_size_t base)
+{
+	unsigned long base_pfn = __phys_to_pfn(base);
+	unsigned long reserve = __phys_to_pfn(SZ_8K);
+
+#ifdef CONFIG_SPARSEMEM
+	reserve += base_pfn - SECTION_ALIGN_DOWN(base_pfn);
+#endif
+	return reserve;
+}
+
 static int nvdimm_namespace_attach_pfn(struct nd_namespace_common *ndns)
 {
 	struct nd_namespace_io *nsio = to_nd_namespace_io(&ndns->dev);
@@ -369,8 +394,8 @@ static int nvdimm_namespace_attach_pfn(struct nd_namespace_common *ndns)
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
