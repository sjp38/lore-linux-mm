Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5930F6B0396
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 02:13:09 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c87so10468445pfl.6
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 23:13:09 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id d198si4264771pga.192.2017.03.15.23.13.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 23:13:08 -0700 (PDT)
Subject: [PATCH v4 13/13] libnvdimm, pfn,
 dax: stop padding pmem namespaces to section alignment
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 15 Mar 2017 23:07:57 -0700
Message-ID: <148964447742.19438.16449477363393431899.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <148964440651.19438.2288075389153762985.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <148964440651.19438.2288075389153762985.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Toshi Kani <toshi.kani@hpe.com>, linux-nvdimm@lists.01.org

Now that the mm core supports section-unaligned hotplug of ZONE_DEVICE
memory, we no longer need to add padding at pfn/dax device creation
time. The kernel will still honor padding established by older kernels.

Cc: Toshi Kani <toshi.kani@hpe.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/nvdimm/pfn_devs.c |   42 +++++++-----------------------------------
 1 file changed, 7 insertions(+), 35 deletions(-)

diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
index 6c033c9a2f06..00b4071cab8d 100644
--- a/drivers/nvdimm/pfn_devs.c
+++ b/drivers/nvdimm/pfn_devs.c
@@ -538,7 +538,7 @@ static struct vmem_altmap *__nvdimm_setup_pfn(struct nd_pfn *nd_pfn,
 		nd_pfn->npfns = le64_to_cpu(pfn_sb->npfns);
 		altmap = NULL;
 	} else if (nd_pfn->mode == PFN_MODE_PMEM) {
-		nd_pfn->npfns = (resource_size(res) - offset) / PAGE_SIZE;
+		nd_pfn->npfns = PHYS_PFN((resource_size(res) - offset));
 		if (le64_to_cpu(nd_pfn->pfn_sb->npfns) > nd_pfn->npfns)
 			dev_info(&nd_pfn->dev,
 					"number of pfns truncated from %lld to %ld\n",
@@ -557,7 +557,6 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
 {
 	u32 dax_label_reserve = is_nd_dax(&nd_pfn->dev) ? SZ_128K : 0;
 	struct nd_namespace_common *ndns = nd_pfn->ndns;
-	u32 start_pad = 0, end_trunc = 0;
 	resource_size_t start, size;
 	struct nd_namespace_io *nsio;
 	struct nd_region *nd_region;
@@ -590,42 +589,16 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
 		return -ENXIO;
 	}
 
-	memset(pfn_sb, 0, sizeof(*pfn_sb));
-
-	/*
-	 * Check if pmem collides with 'System RAM' when section aligned and
-	 * trim it accordingly
-	 */
-	nsio = to_nd_namespace_io(&ndns->dev);
-	start = PHYS_SECTION_ALIGN_DOWN(nsio->res.start);
-	size = resource_size(&nsio->res);
-	if (region_intersects(start, size, IORESOURCE_SYSTEM_RAM,
-				IORES_DESC_NONE) == REGION_MIXED) {
-		start = nsio->res.start;
-		start_pad = PHYS_SECTION_ALIGN_UP(start) - start;
-	}
-
-	start = nsio->res.start;
-	size = PHYS_SECTION_ALIGN_UP(start + size) - start;
-	if (region_intersects(start, size, IORESOURCE_SYSTEM_RAM,
-				IORES_DESC_NONE) == REGION_MIXED) {
-		size = resource_size(&nsio->res);
-		end_trunc = start + size - PHYS_SECTION_ALIGN_DOWN(start + size);
-	}
-
-	if (start_pad + end_trunc)
-		dev_info(&nd_pfn->dev, "%s section collision, truncate %d bytes\n",
-				dev_name(&ndns->dev), start_pad + end_trunc);
-
 	/*
 	 * Note, we use 64 here for the standard size of struct page,
 	 * debugging options may cause it to be larger in which case the
 	 * implementation will limit the pfns advertised through
 	 * ->direct_access() to those that are included in the memmap.
 	 */
-	start += start_pad;
+	nsio = to_nd_namespace_io(&ndns->dev);
+	start = nsio->res.start;
 	size = resource_size(&nsio->res);
-	npfns = (size - start_pad - end_trunc - SZ_8K) / SZ_4K;
+	npfns = PHYS_PFN(size - SZ_8K);
 	if (nd_pfn->mode == PFN_MODE_PMEM) {
 		/*
 		 * vmemmap_populate_hugepages() allocates the memmap array in
@@ -639,13 +612,14 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
 	else
 		return -ENXIO;
 
-	if (offset + start_pad + end_trunc >= size) {
+	if (offset >= size) {
 		dev_err(&nd_pfn->dev, "%s unable to satisfy requested alignment\n",
 				dev_name(&ndns->dev));
 		return -ENXIO;
 	}
 
-	npfns = (size - offset - start_pad - end_trunc) / SZ_4K;
+	memset(pfn_sb, 0, sizeof(*pfn_sb));
+	npfns = PHYS_PFN(size - offset);
 	pfn_sb->mode = cpu_to_le32(nd_pfn->mode);
 	pfn_sb->dataoff = cpu_to_le64(offset);
 	pfn_sb->npfns = cpu_to_le64(npfns);
@@ -654,8 +628,6 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
 	memcpy(pfn_sb->parent_uuid, nd_dev_to_uuid(&ndns->dev), 16);
 	pfn_sb->version_major = cpu_to_le16(1);
 	pfn_sb->version_minor = cpu_to_le16(2);
-	pfn_sb->start_pad = cpu_to_le32(start_pad);
-	pfn_sb->end_trunc = cpu_to_le32(end_trunc);
 	pfn_sb->align = cpu_to_le32(nd_pfn->align);
 	checksum = nd_sb_checksum((struct nd_gen_sb *) pfn_sb);
 	pfn_sb->checksum = cpu_to_le64(checksum);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
