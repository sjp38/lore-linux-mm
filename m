Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1EAEC282DC
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 18:53:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A062620663
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 18:53:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A062620663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4EF8C6B0005; Wed, 17 Apr 2019 14:53:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C7526B026C; Wed, 17 Apr 2019 14:53:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B78D6B026D; Wed, 17 Apr 2019 14:53:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 03AFA6B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 14:53:49 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id p13so15979466pll.20
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 11:53:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=0Eiev16VluPo/Ft1mi41KIG+c9eC0uF0PiWNIa4cMlE=;
        b=nS28BB5Fwx/eXpYDJ1nt/kNo+SCIdkzxZ958RN6RbXBrwt94rv6l6j4uZ/Xc+sF2/U
         m8VOEy4v6m3zL1PbwxxCSGAf4zHyk9bSATEILRC89s4HklYH21rCqeCIKtw+pgkYt/QH
         Wt1Slr3+YpgukCN3hRAnw9dwFljejtH+hCrlMSVx2xjcEKN04mP17jBZQmlE6MUbQNoj
         Juw6ZSEXokJx9irkq9mRW3eMeWgOG8Wbk8i5mPxLdPed5CpniY1Im8sUZCO4b5Z/iUHI
         pFCAG0CLxfWDlfhbg3OkhN7TmyJekG3vcE5TZ7XXxNNlItTW/w1t0hQkBmB98m2lmZVK
         gZFg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXS3GrqzD+ogmorzMMmZF3emKlH7pN/BYeB++CNkwGiodbeHZ5w
	2oX60EYc8CAGI/lu573wmUYNDG2kkSc4AxhaIJikC7Vb+1oqi2JLS1bkRT+sJMSdaGJASFaZdIp
	TTnZZPN9tIbZrP18hxL+XvE+T9wj6VnemMQ5FESWijJEJ35T1TBsw7rg1CHUpzrJbyw==
X-Received: by 2002:a63:1f61:: with SMTP id q33mr78288760pgm.325.1555527228652;
        Wed, 17 Apr 2019 11:53:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyF4eAtzTM5ogXYK3Gu7dFZtuUGYIuLT3XaxqkRqVmfrR2IAis0E+VgREnEkcIP7TgRO6zd
X-Received: by 2002:a63:1f61:: with SMTP id q33mr78288686pgm.325.1555527227650;
        Wed, 17 Apr 2019 11:53:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555527227; cv=none;
        d=google.com; s=arc-20160816;
        b=LgwUDR8jhSH6vHaBPfu0kDd2ZlG5BR14AlJeleBkU+kEVg0N8MruVOSzPi6koPEH+w
         EZG46V/yhTidVkOqlcfOc3Lyrl6YjLv4MUWw46NjiraqfTKvS7wntfVvl27B6xLM+Bmt
         h48LMX9OrjQSADWKvnj4eqhmr0pbPr7QeUVczDERzaNy2PSV6F7ZPfcsRvTzflaiLbae
         jc3umigIVKF3TD0tFf1nPMSf+1p5gDcNJdGvSCm5HhI8MG2e5ogUbWzXbqvOBjLF8wsd
         UmOuVMK7aLuZpa8dnILcIXG/VT6C7uiKPorO0aWZFG4LjqgU2TKt71u3WHzJD0+CFwmh
         qTiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=0Eiev16VluPo/Ft1mi41KIG+c9eC0uF0PiWNIa4cMlE=;
        b=tjDc/9CQC+HwE9A6VNDJ3ckat79lSr38YDzIOdQQIbBhFwQOZvpuLkrRIs08FTU9/R
         hSwc6y5G7YUD47mpbeY0ItkBf+ewDhJqYAoSUrfx2u0dYfDaig4KouP5vizGfla0zkjl
         qRKqycJcOgympFQERtQinjv6PyP3LtChSufPAOhaGPhr0vw9ISN/jSXdWdMdaeUwjCtQ
         eho46KO5efpiUjJkOeJqPeKouq6pVT8zYXlRcSw+wdb7mtSNssjUfMq6cbsvM99443kG
         DeOfxkHzags7uEDzq2lsPxOtMbYraI8mJzWUbXRN/8btWNURp86vQZASL+tJc6L23fP/
         kA7w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id d6si48144276pls.402.2019.04.17.11.53.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 11:53:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Apr 2019 11:53:47 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,362,1549958400"; 
   d="scan'208";a="143759353"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga007.fm.intel.com with ESMTP; 17 Apr 2019 11:53:44 -0700
Subject: [PATCH v6 12/12] libnvdimm/pfn: Stop padding pmem namespaces to
 section alignment
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Jeff Moyer <jmoyer@redhat.com>, linux-mm@kvack.org,
 linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, mhocko@suse.com,
 david@redhat.com
Date: Wed, 17 Apr 2019 11:39:58 -0700
Message-ID: <155552639846.2015392.14832585852837457293.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
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
 drivers/nvdimm/pfn.h      |   11 ++-----
 drivers/nvdimm/pfn_devs.c |   75 +++++++--------------------------------------
 include/linux/mmzone.h    |    4 ++
 3 files changed, 19 insertions(+), 71 deletions(-)

diff --git a/drivers/nvdimm/pfn.h b/drivers/nvdimm/pfn.h
index e901e3a3b04c..ae589cc528f2 100644
--- a/drivers/nvdimm/pfn.h
+++ b/drivers/nvdimm/pfn.h
@@ -41,18 +41,13 @@ struct nd_pfn_sb {
 	__le64 checksum;
 };
 
-#ifdef CONFIG_SPARSEMEM
-#define PFN_SECTION_ALIGN_DOWN(x) SECTION_ALIGN_DOWN(x)
-#define PFN_SECTION_ALIGN_UP(x) SECTION_ALIGN_UP(x)
-#else
 /*
  * In this case ZONE_DEVICE=n and we will disable 'pfn' device support,
  * but we still want pmem to compile.
  */
-#define PFN_SECTION_ALIGN_DOWN(x) (x)
-#define PFN_SECTION_ALIGN_UP(x) (x)
+#ifndef SUB_SECTION_ALIGN_DOWN
+#define SUB_SECTION_ALIGN_DOWN(x) (x)
+#define SUB_SECTION_ALIGN_UP(x) (x)
 #endif
 
-#define PHYS_SECTION_ALIGN_DOWN(x) PFN_PHYS(PFN_SECTION_ALIGN_DOWN(PHYS_PFN(x)))
-#define PHYS_SECTION_ALIGN_UP(x) PFN_PHYS(PFN_SECTION_ALIGN_UP(PHYS_PFN(x)))
 #endif /* __NVDIMM_PFN_H */
diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
index a2406253eb70..7bdaaf3dc77e 100644
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
+	return SUB_SECTION_ALIGN_DOWN(base_pfn);
 }
 
 static unsigned long init_altmap_reserve(resource_size_t base)
@@ -610,7 +610,7 @@ static unsigned long init_altmap_reserve(resource_size_t base)
 	unsigned long reserve = info_block_reserve() >> PAGE_SHIFT;
 	unsigned long base_pfn = PHYS_PFN(base);
 
-	reserve += base_pfn - PFN_SECTION_ALIGN_DOWN(base_pfn);
+	reserve += base_pfn - SUB_SECTION_ALIGN_DOWN(base_pfn);
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
@@ -658,50 +657,10 @@ static int __nvdimm_setup_pfn(struct nd_pfn *nd_pfn, struct dev_pagemap *pgmap)
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
 	struct nd_pfn_sb *pfn_sb;
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
 	if (nd_pfn->mode == PFN_MODE_PMEM) {
 		/*
 		 * The altmap should be padded out to the block size used
 		 * when populating the vmemmap. This *should* be equal to
 		 * PMD_SIZE for most architectures.
 		 */
-		offset = ALIGN(start + reserve + 64 * npfns,
-				max(nd_pfn->align, PMD_SIZE)) - start;
+		offset = ALIGN(start + SZ_8K + 64 * npfns,
+				max(nd_pfn->align, SECTION_ACTIVE_SIZE)) - start;
 	} else if (nd_pfn->mode == PFN_MODE_RAM)
-		offset = ALIGN(start + reserve, nd_pfn->align) - start;
+		offset = ALIGN(start + SZ_8K, nd_pfn->align) - start;
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
index 3237c5e456df..d2445c483ad4 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1155,6 +1155,10 @@ static inline unsigned long section_nr_to_pfn(unsigned long sec)
 #define PAGES_PER_SUB_SECTION (SECTION_ACTIVE_SIZE / PAGE_SIZE)
 #define PAGE_SUB_SECTION_MASK (~(PAGES_PER_SUB_SECTION-1))
 
+#define SUB_SECTION_ALIGN_UP(pfn) (((pfn) + PAGES_PER_SUB_SECTION - 1) \
+		& PAGE_SUB_SECTION_MASK)
+#define SUB_SECTION_ALIGN_DOWN(pfn) ((pfn) & PAGE_SUB_SECTION_MASK)
+
 struct mem_section_usage {
 	/*
 	 * SECTION_ACTIVE_SIZE portions of the section that are populated in

