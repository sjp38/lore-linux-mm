Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FF7FC28CC5
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 22:13:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 40CA12070B
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 22:13:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 40CA12070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E4BA86B0270; Wed,  5 Jun 2019 18:13:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DFD5D6B027A; Wed,  5 Jun 2019 18:13:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CEBB76B027B; Wed,  5 Jun 2019 18:13:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 962E06B0270
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 18:13:23 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id r7so206086plo.6
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 15:13:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=bYwzlu+qlg87yG+G9ABQwbpiA0ygWWX0zPRHiAUPmik=;
        b=ItquAhwoVCP6h+FBeqT3xC+NmAyZwLCWVMiUxNjQohd+H2X5iBBYIxqP3Scj/KfpUq
         9Vei+yTWWhxSklx0MdcdoHBpVAKzMf9PMONk8BKrMcJWCzzhs/RdfDQOycpNr1ZzHE2P
         wZUc2hYfCfQCrQDOlbe5Nc0sDB1aptRNfNMj+2u/BgKhKfi6BxoVdIVza3KSCk8Y0b/6
         AntXUrdliXShSIqndWKAKRkzvz2v5RJzCi3zKtfdL8r9G4tT5OQ6TUQXYmxLqsdrRPGD
         4ypg7DBAnxIiXsoKH+3MIPWE96M68frlR8wVj1o7bL+di4xQYiFTrosYQBXsxzR19c1D
         2rTA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUOIDIWyI5bpc04+l6nqkoN0untANg9kbq9XBkSwKku7tM9Bttt
	TizboIZt9HU1V0APVSGErnsK6p1NICB4ChzTejGVRPiHFGGvEjPD8uaMEr/cNRg3PIW8DVqDrzc
	o925ugnmPXlybxR1e/X+zdqvLTyYdiBfyQwafms3xPu/ey4EBaMqDQGjoTroxUG5IWg==
X-Received: by 2002:a17:902:7295:: with SMTP id d21mr33502069pll.299.1559772803086;
        Wed, 05 Jun 2019 15:13:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyAIJEMLRPuYP9vaMBmBtv9h787ghG6aN9mtUThyohDZsIUoqpfZYGPILaEODEKGknqpskY
X-Received: by 2002:a17:902:7295:: with SMTP id d21mr33501945pll.299.1559772801882;
        Wed, 05 Jun 2019 15:13:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559772801; cv=none;
        d=google.com; s=arc-20160816;
        b=nahqWU6akOG0/kEre9QxdKO2jZBevuoR2bVNVb7XpuLxg2KXMrg9kS+CtaUbBPYg2j
         wUzBFZ5nzA79XaHeK7rXbVf2ascQeliQ2iDZDHhlJIXJCL8XCTQI1MvsbPewm20AmV9E
         v1ZUyxZOEOG3Xshvv76xUohc+hzYvSIrDfDYN6Zyp1nRWVAxrEUcRGn4z21vjBGxDki1
         Zc8rTMUYcyAtKcsM1MLwNlUSjHFrydNm2OE7SF6HP+YqOoqZt/c9l2aEtjOy0G+etCwz
         HN7QbPDOEdvX2bwk72zJWC5P6KZUjmmaSxKWZ26adYF6BZs5IGvkoTqpeeTzPDt0L1kt
         eezA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=bYwzlu+qlg87yG+G9ABQwbpiA0ygWWX0zPRHiAUPmik=;
        b=RHwqa+x9Xi1aoGG7NysEh8j/gwOdgQp9YYJlaBJAV7as226M+dmc4mZLZczE/hr5oD
         e1DoByGza8Yp6AJN48jfnMhthkxIYI65SivY02X4hkdk9EbAlMn6p3pr3r1H/zztCNPY
         WVaSTkgfu+HlmL/aP+8psg5KIRlJtw00QMZuNiLVhdLVLyj/+CMPKvgLQs+l5HbY8id6
         be0TNceq1dMQsje8bWKVgQHT2T/Zw40zJUayMVJ5gKft8UfZlXPXamkLJRQnSNoJAYqx
         HunXbAFa4gXUr2M1Wg3LkhUVeiJxLWny/Qu+jHL2vuAMvGC7osHL+djlYVKj8BvPDRkJ
         k7Pg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id j59si30233009plb.176.2019.06.05.15.13.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 15:13:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Jun 2019 15:13:21 -0700
X-ExtLoop1: 1
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga007.fm.intel.com with ESMTP; 05 Jun 2019 15:13:20 -0700
Subject: [PATCH v9 12/12] libnvdimm/pfn: Stop padding pmem namespaces to
 section alignment
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Jeff Moyer <jmoyer@redhat.com>, linux-mm@kvack.org,
 linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, osalvador@suse.de,
 mhocko@suse.com
Date: Wed, 05 Jun 2019 14:59:04 -0700
Message-ID: <155977194407.2443951.14077225226024648760.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155977186863.2443951.9036044808311959913.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155977186863.2443951.9036044808311959913.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Now that the mm core supports section-unaligned hotplug of ZONE_DEVICE
memory, we no longer need to add padding at pfn/dax device creation
time. The kernel will still honor padding established by older kernels.

Reported-by: Jeff Moyer <jmoyer@redhat.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/nvdimm/pfn.h      |   14 --------
 drivers/nvdimm/pfn_devs.c |   77 ++++++++-------------------------------------
 include/linux/mmzone.h    |    3 ++
 3 files changed, 16 insertions(+), 78 deletions(-)

diff --git a/drivers/nvdimm/pfn.h b/drivers/nvdimm/pfn.h
index e901e3a3b04c..cc042a98758f 100644
--- a/drivers/nvdimm/pfn.h
+++ b/drivers/nvdimm/pfn.h
@@ -41,18 +41,4 @@ struct nd_pfn_sb {
 	__le64 checksum;
 };
 
-#ifdef CONFIG_SPARSEMEM
-#define PFN_SECTION_ALIGN_DOWN(x) SECTION_ALIGN_DOWN(x)
-#define PFN_SECTION_ALIGN_UP(x) SECTION_ALIGN_UP(x)
-#else
-/*
- * In this case ZONE_DEVICE=n and we will disable 'pfn' device support,
- * but we still want pmem to compile.
- */
-#define PFN_SECTION_ALIGN_DOWN(x) (x)
-#define PFN_SECTION_ALIGN_UP(x) (x)
-#endif
-
-#define PHYS_SECTION_ALIGN_DOWN(x) PFN_PHYS(PFN_SECTION_ALIGN_DOWN(PHYS_PFN(x)))
-#define PHYS_SECTION_ALIGN_UP(x) PFN_PHYS(PFN_SECTION_ALIGN_UP(PHYS_PFN(x)))
 #endif /* __NVDIMM_PFN_H */
diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
index a2406253eb70..7f54374b082f 100644
--- a/drivers/nvdimm/pfn_devs.c
+++ b/drivers/nvdimm/pfn_devs.c
@@ -595,14 +595,14 @@ static u32 info_block_reserve(void)
 }
 
 /*
- * We hotplug memory at section granularity, pad the reserved area from
- * the previous section base to the namespace base address.
+ * We hotplug memory at sub-section granularity, pad the reserved area
+ * from the previous section base to the namespace base address.
  */
 static unsigned long init_altmap_base(resource_size_t base)
 {
 	unsigned long base_pfn = PHYS_PFN(base);
 
-	return PFN_SECTION_ALIGN_DOWN(base_pfn);
+	return SUBSECTION_ALIGN_DOWN(base_pfn);
 }
 
 static unsigned long init_altmap_reserve(resource_size_t base)
@@ -610,7 +610,7 @@ static unsigned long init_altmap_reserve(resource_size_t base)
 	unsigned long reserve = info_block_reserve() >> PAGE_SHIFT;
 	unsigned long base_pfn = PHYS_PFN(base);
 
-	reserve += base_pfn - PFN_SECTION_ALIGN_DOWN(base_pfn);
+	reserve += base_pfn - SUBSECTION_ALIGN_DOWN(base_pfn);
 	return reserve;
 }
 
@@ -641,8 +641,7 @@ static int __nvdimm_setup_pfn(struct nd_pfn *nd_pfn, struct dev_pagemap *pgmap)
 		nd_pfn->npfns = le64_to_cpu(pfn_sb->npfns);
 		pgmap->altmap_valid = false;
 	} else if (nd_pfn->mode == PFN_MODE_PMEM) {
-		nd_pfn->npfns = PFN_SECTION_ALIGN_UP((resource_size(res)
-					- offset) / PAGE_SIZE);
+		nd_pfn->npfns = PHYS_PFN((resource_size(res) - offset));
 		if (le64_to_cpu(nd_pfn->pfn_sb->npfns) > nd_pfn->npfns)
 			dev_info(&nd_pfn->dev,
 					"number of pfns truncated from %lld to %ld\n",
@@ -658,54 +657,14 @@ static int __nvdimm_setup_pfn(struct nd_pfn *nd_pfn, struct dev_pagemap *pgmap)
 	return 0;
 }
 
-static u64 phys_pmem_align_down(struct nd_pfn *nd_pfn, u64 phys)
-{
-	return min_t(u64, PHYS_SECTION_ALIGN_DOWN(phys),
-			ALIGN_DOWN(phys, nd_pfn->align));
-}
-
-/*
- * Check if pmem collides with 'System RAM', or other regions when
- * section aligned.  Trim it accordingly.
- */
-static void trim_pfn_device(struct nd_pfn *nd_pfn, u32 *start_pad, u32 *end_trunc)
-{
-	struct nd_namespace_common *ndns = nd_pfn->ndns;
-	struct nd_namespace_io *nsio = to_nd_namespace_io(&ndns->dev);
-	struct nd_region *nd_region = to_nd_region(nd_pfn->dev.parent);
-	const resource_size_t start = nsio->res.start;
-	const resource_size_t end = start + resource_size(&nsio->res);
-	resource_size_t adjust, size;
-
-	*start_pad = 0;
-	*end_trunc = 0;
-
-	adjust = start - PHYS_SECTION_ALIGN_DOWN(start);
-	size = resource_size(&nsio->res) + adjust;
-	if (region_intersects(start - adjust, size, IORESOURCE_SYSTEM_RAM,
-				IORES_DESC_NONE) == REGION_MIXED
-			|| nd_region_conflict(nd_region, start - adjust, size))
-		*start_pad = PHYS_SECTION_ALIGN_UP(start) - start;
-
-	/* Now check that end of the range does not collide. */
-	adjust = PHYS_SECTION_ALIGN_UP(end) - end;
-	size = resource_size(&nsio->res) + adjust;
-	if (region_intersects(start, size, IORESOURCE_SYSTEM_RAM,
-				IORES_DESC_NONE) == REGION_MIXED
-			|| !IS_ALIGNED(end, nd_pfn->align)
-			|| nd_region_conflict(nd_region, start, size))
-		*end_trunc = end - phys_pmem_align_down(nd_pfn, end);
-}
-
 static int nd_pfn_init(struct nd_pfn *nd_pfn)
 {
 	struct nd_namespace_common *ndns = nd_pfn->ndns;
 	struct nd_namespace_io *nsio = to_nd_namespace_io(&ndns->dev);
-	u32 start_pad, end_trunc, reserve = info_block_reserve();
 	resource_size_t start, size;
 	struct nd_region *nd_region;
+	unsigned long npfns, align;
 	struct nd_pfn_sb *pfn_sb;
-	unsigned long npfns;
 	phys_addr_t offset;
 	const char *sig;
 	u64 checksum;
@@ -736,43 +695,35 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
 		return -ENXIO;
 	}
 
-	memset(pfn_sb, 0, sizeof(*pfn_sb));
-
-	trim_pfn_device(nd_pfn, &start_pad, &end_trunc);
-	if (start_pad + end_trunc)
-		dev_info(&nd_pfn->dev, "%s alignment collision, truncate %d bytes\n",
-				dev_name(&ndns->dev), start_pad + end_trunc);
-
 	/*
 	 * Note, we use 64 here for the standard size of struct page,
 	 * debugging options may cause it to be larger in which case the
 	 * implementation will limit the pfns advertised through
 	 * ->direct_access() to those that are included in the memmap.
 	 */
-	start = nsio->res.start + start_pad;
+	start = nsio->res.start;
 	size = resource_size(&nsio->res);
-	npfns = PFN_SECTION_ALIGN_UP((size - start_pad - end_trunc - reserve)
-			/ PAGE_SIZE);
+	npfns = PHYS_PFN(size - SZ_8K);
+	align = max(nd_pfn->align, (1UL << SUBSECTION_SHIFT));
 	if (nd_pfn->mode == PFN_MODE_PMEM) {
 		/*
 		 * The altmap should be padded out to the block size used
 		 * when populating the vmemmap. This *should* be equal to
 		 * PMD_SIZE for most architectures.
 		 */
-		offset = ALIGN(start + reserve + 64 * npfns,
-				max(nd_pfn->align, PMD_SIZE)) - start;
+		offset = ALIGN(start + SZ_8K + 64 * npfns, align) - start;
 	} else if (nd_pfn->mode == PFN_MODE_RAM)
-		offset = ALIGN(start + reserve, nd_pfn->align) - start;
+		offset = ALIGN(start + SZ_8K, align) - start;
 	else
 		return -ENXIO;
 
-	if (offset + start_pad + end_trunc >= size) {
+	if (offset >= size) {
 		dev_err(&nd_pfn->dev, "%s unable to satisfy requested alignment\n",
 				dev_name(&ndns->dev));
 		return -ENXIO;
 	}
 
-	npfns = (size - offset - start_pad - end_trunc) / SZ_4K;
+	npfns = PHYS_PFN(size - offset);
 	pfn_sb->mode = cpu_to_le32(nd_pfn->mode);
 	pfn_sb->dataoff = cpu_to_le64(offset);
 	pfn_sb->npfns = cpu_to_le64(npfns);
@@ -781,8 +732,6 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
 	memcpy(pfn_sb->parent_uuid, nd_dev_to_uuid(&ndns->dev), 16);
 	pfn_sb->version_major = cpu_to_le16(1);
 	pfn_sb->version_minor = cpu_to_le16(3);
-	pfn_sb->start_pad = cpu_to_le32(start_pad);
-	pfn_sb->end_trunc = cpu_to_le32(end_trunc);
 	pfn_sb->align = cpu_to_le32(nd_pfn->align);
 	checksum = nd_sb_checksum((struct nd_gen_sb *) pfn_sb);
 	pfn_sb->checksum = cpu_to_le64(checksum);
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 49e7fb452dfd..15e07f007ba2 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1181,6 +1181,9 @@ static inline unsigned long section_nr_to_pfn(unsigned long sec)
 #define SUBSECTIONS_PER_SECTION (1UL << (SECTION_SIZE_BITS - SUBSECTION_SHIFT))
 #endif
 
+#define SUBSECTION_ALIGN_UP(pfn) ALIGN((pfn), PAGES_PER_SUBSECTION)
+#define SUBSECTION_ALIGN_DOWN(pfn) ((pfn) & PAGE_SUBSECTION_MASK)
+
 struct mem_section_usage {
 	DECLARE_BITMAP(subsection_map, SUBSECTIONS_PER_SECTION);
 	/* See declaration of similar field in struct zone */

