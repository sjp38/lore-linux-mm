Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E73EC04AAB
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 23:54:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C5B720830
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 23:54:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C5B720830
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F29C6B026A; Mon,  6 May 2019 19:54:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A4B26B026B; Mon,  6 May 2019 19:54:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EFB626B026C; Mon,  6 May 2019 19:54:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B54A46B026A
	for <linux-mm@kvack.org>; Mon,  6 May 2019 19:54:07 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id n3so8943175pff.4
        for <linux-mm@kvack.org>; Mon, 06 May 2019 16:54:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=m7C8BslmRbGGSGQpdjo+HYZBj54+tXDU6VhYpS0DnS8=;
        b=HAIxlgbb/sEQiI46uin/B5NArIUhvUsQW83qRCEklNDy3mMVAkzD+wzNfix1x3IuG+
         u8s0SlpZLgaTRW5IpCQK4noGNRetCdHYAXfNs7rtrGOZCbsanT5GTHQTM3NyhSSIAtp1
         8tMixFZYtRzdUkFKHluaVlW4BXCMlWHvKGkLWG1mNerrG19uvXDaWIi8dXTPzYsmoXXq
         MnAo5Nh6Z/57FM9G3SKdzK/L/gzux9mAM6dn6TtukxqdOA+pQ3DaxnwgJU6a/8agWkDF
         jOc0Iegkhgn7bxvLavv8fc6uEw97PToGc1gqF7t4BFWbdKFWmbR3C4cSSk1CgXESyHyU
         AJGQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXJPSGpJ7cXuuY5n1h9g+zkWnlwlLuId1Dc/Nfb75coq/TZyxVx
	yvKeaXSZuulqpnsmAtHx2uFep+zpt+ddjPXOkFIk42KgYH5y+g/bL0xMfb3MFzOsEZw9U9GIMpA
	z2L98OEJvVJ4akLeISxbgpoHEdU0Q+ZAEGu/UfIZAp0APXIRqJmzu3kbJfOwKo5503g==
X-Received: by 2002:a65:4b88:: with SMTP id t8mr35819390pgq.374.1557186847382;
        Mon, 06 May 2019 16:54:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxGiVLp8W0ekLXJlSrE4T639JVEPg1OPsw0LhZyhmzZmrWvMRqsUGcTjBPChBO0iG6vD4GO
X-Received: by 2002:a65:4b88:: with SMTP id t8mr35819329pgq.374.1557186846595;
        Mon, 06 May 2019 16:54:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557186846; cv=none;
        d=google.com; s=arc-20160816;
        b=lcfgAckJPHahXo9CU4zTYBYiWMXvatwki1rkj8wBzNYdxG+4Gdm+GKhbcjFoIlkJ+r
         fhPS5i0PbyZLHuiVBtnpjtOJBg5M0zd04BuhioklVGKDcCfEYvMpKwV+B2KWa5RcY8au
         /LaNBrbVqIyv1MZ0gqUlWQHSEj1L0XrqOK6HNq6Y+IPHpy/8j+rmGrFPmef3lY66Yuof
         CLQnsviwPgFRRzeRZVQ6/20W3LijlnYDzTGmeevQ4yV3RI4V6TeXm+uXiPIRcqlHqwJd
         IDOGyenTW8eEkXxlzGM4ScQEGsK/7WX50/lk/0KN7Oxpqu8JQAGXF7w3POHTOQzfLop1
         hb+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=m7C8BslmRbGGSGQpdjo+HYZBj54+tXDU6VhYpS0DnS8=;
        b=fF5rL3BaGjZL6bIEsuMWW9hFSXeXxcltDiPSIe3+y9PMJc5pFWBQVWIbYKagjt5ULn
         LVsgsBoVjaHZ6qijglh86dC8rYkxzqpiUPFNcWC/kFcBt7alRGajIp74oc9L4s8PcYiU
         tPdKMGOEwJhLkFjZd7047QAxrf6HEMat176v6yDzaOD4q6R3nvrFUc7TwNegBr0U74bM
         0xlH8lXl7XzEzS5p+Pjz2kNAbXm5cFAcNIWa1QAjD/Hgsgr7MAd4v0usxqXvi0jy0gFp
         57xlziLyYUgWl/KloLmp/N5HLisfWsXHCZfjScevXcZNpZkKnvkzUEdyVs447IH4i1i9
         iQvg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id bg4si11836895plb.164.2019.05.06.16.54.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 16:54:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 May 2019 16:54:06 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,439,1549958400"; 
   d="scan'208";a="147053379"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga008.fm.intel.com with ESMTP; 06 May 2019 16:54:05 -0700
Subject: [PATCH v8 10/12] mm/devm_memremap_pages: Enable sub-section remap
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Toshi Kani <toshi.kani@hpe.com>,
 =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
 Logan Gunthorpe <logang@deltatee.com>, Oscar Salvador <osalvador@suse.de>,
 Pavel Tatashin <pasha.tatashin@soleen.com>, linux-nvdimm@lists.01.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org, osalvador@suse.de,
 mhocko@suse.com
Date: Mon, 06 May 2019 16:40:19 -0700
Message-ID: <155718601917.130019.30099990750225408.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155718596657.130019.17139634728875079809.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155718596657.130019.17139634728875079809.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Teach devm_memremap_pages() about the new sub-section capabilities of
arch_{add,remove}_memory(). Effectively, just replace all usage of
align_start, align_end, and align_size with res->start, res->end, and
resource_size(res). The existing sanity check will still make sure that
the two separate remap attempts do not collide within a sub-section (2MB
on x86).

Cc: Michal Hocko <mhocko@suse.com>
Cc: Toshi Kani <toshi.kani@hpe.com>
Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 kernel/memremap.c |   61 +++++++++++++++++++++--------------------------------
 1 file changed, 24 insertions(+), 37 deletions(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index f355586ea54a..425904858d97 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -59,7 +59,7 @@ static unsigned long pfn_first(struct dev_pagemap *pgmap)
 	struct vmem_altmap *altmap = &pgmap->altmap;
 	unsigned long pfn;
 
-	pfn = res->start >> PAGE_SHIFT;
+	pfn = PHYS_PFN(res->start);
 	if (pgmap->altmap_valid)
 		pfn += vmem_altmap_offset(altmap);
 	return pfn;
@@ -87,7 +87,6 @@ static void devm_memremap_pages_release(void *data)
 	struct dev_pagemap *pgmap = data;
 	struct device *dev = pgmap->dev;
 	struct resource *res = &pgmap->res;
-	resource_size_t align_start, align_size;
 	unsigned long pfn;
 	int nid;
 
@@ -96,25 +95,21 @@ static void devm_memremap_pages_release(void *data)
 		put_page(pfn_to_page(pfn));
 
 	/* pages are dead and unused, undo the arch mapping */
-	align_start = res->start & ~(PA_SECTION_SIZE - 1);
-	align_size = ALIGN(res->start + resource_size(res), PA_SECTION_SIZE)
-		- align_start;
-
-	nid = page_to_nid(pfn_to_page(align_start >> PAGE_SHIFT));
+	nid = page_to_nid(pfn_to_page(PHYS_PFN(res->start)));
 
 	mem_hotplug_begin();
 	if (pgmap->type == MEMORY_DEVICE_PRIVATE) {
-		pfn = align_start >> PAGE_SHIFT;
+		pfn = PHYS_PFN(res->start);
 		__remove_pages(page_zone(pfn_to_page(pfn)), pfn,
-				align_size >> PAGE_SHIFT, NULL);
+				PHYS_PFN(resource_size(res)), NULL);
 	} else {
-		arch_remove_memory(nid, align_start, align_size,
+		arch_remove_memory(nid, res->start, resource_size(res),
 				pgmap->altmap_valid ? &pgmap->altmap : NULL);
-		kasan_remove_zero_shadow(__va(align_start), align_size);
+		kasan_remove_zero_shadow(__va(res->start), resource_size(res));
 	}
 	mem_hotplug_done();
 
-	untrack_pfn(NULL, PHYS_PFN(align_start), align_size);
+	untrack_pfn(NULL, PHYS_PFN(res->start), resource_size(res));
 	pgmap_array_delete(res);
 	dev_WARN_ONCE(dev, pgmap->altmap.alloc,
 		      "%s: failed to free all reserved pages\n", __func__);
@@ -141,16 +136,13 @@ static void devm_memremap_pages_release(void *data)
  */
 void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 {
-	resource_size_t align_start, align_size, align_end;
-	struct vmem_altmap *altmap = pgmap->altmap_valid ?
-			&pgmap->altmap : NULL;
 	struct resource *res = &pgmap->res;
 	struct dev_pagemap *conflict_pgmap;
 	struct mhp_restrictions restrictions = {
 		/*
 		 * We do not want any optional features only our own memmap
 		*/
-		.altmap = altmap,
+		.altmap = pgmap->altmap_valid ? &pgmap->altmap : NULL,
 	};
 	pgprot_t pgprot = PAGE_KERNEL;
 	int error, nid, is_ram;
@@ -158,26 +150,21 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 	if (!pgmap->ref || !pgmap->kill)
 		return ERR_PTR(-EINVAL);
 
-	align_start = res->start & ~(PA_SECTION_SIZE - 1);
-	align_size = ALIGN(res->start + resource_size(res), PA_SECTION_SIZE)
-		- align_start;
-	align_end = align_start + align_size - 1;
-
-	conflict_pgmap = get_dev_pagemap(PHYS_PFN(align_start), NULL);
+	conflict_pgmap = get_dev_pagemap(PHYS_PFN(res->start), NULL);
 	if (conflict_pgmap) {
 		dev_WARN(dev, "Conflicting mapping in same section\n");
 		put_dev_pagemap(conflict_pgmap);
 		return ERR_PTR(-ENOMEM);
 	}
 
-	conflict_pgmap = get_dev_pagemap(PHYS_PFN(align_end), NULL);
+	conflict_pgmap = get_dev_pagemap(PHYS_PFN(res->end), NULL);
 	if (conflict_pgmap) {
 		dev_WARN(dev, "Conflicting mapping in same section\n");
 		put_dev_pagemap(conflict_pgmap);
 		return ERR_PTR(-ENOMEM);
 	}
 
-	is_ram = region_intersects(align_start, align_size,
+	is_ram = region_intersects(res->start, resource_size(res),
 		IORESOURCE_SYSTEM_RAM, IORES_DESC_NONE);
 
 	if (is_ram != REGION_DISJOINT) {
@@ -198,8 +185,8 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 	if (nid < 0)
 		nid = numa_mem_id();
 
-	error = track_pfn_remap(NULL, &pgprot, PHYS_PFN(align_start), 0,
-			align_size);
+	error = track_pfn_remap(NULL, &pgprot, PHYS_PFN(res->start), 0,
+			resource_size(res));
 	if (error)
 		goto err_pfn_remap;
 
@@ -217,25 +204,25 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 	 * arch_add_memory().
 	 */
 	if (pgmap->type == MEMORY_DEVICE_PRIVATE) {
-		error = add_pages(nid, align_start >> PAGE_SHIFT,
-				align_size >> PAGE_SHIFT, &restrictions);
+		error = add_pages(nid, PHYS_PFN(res->start),
+				PHYS_PFN(resource_size(res)), &restrictions);
 	} else {
-		error = kasan_add_zero_shadow(__va(align_start), align_size);
+		error = kasan_add_zero_shadow(__va(res->start), resource_size(res));
 		if (error) {
 			mem_hotplug_done();
 			goto err_kasan;
 		}
 
-		error = arch_add_memory(nid, align_start, align_size,
-					&restrictions);
+		error = arch_add_memory(nid, res->start, resource_size(res),
+				&restrictions);
 	}
 
 	if (!error) {
 		struct zone *zone;
 
 		zone = &NODE_DATA(nid)->node_zones[ZONE_DEVICE];
-		move_pfn_range_to_zone(zone, align_start >> PAGE_SHIFT,
-				align_size >> PAGE_SHIFT, altmap);
+		move_pfn_range_to_zone(zone, PHYS_PFN(res->start),
+				PHYS_PFN(resource_size(res)), restrictions.altmap);
 	}
 
 	mem_hotplug_done();
@@ -247,8 +234,8 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 	 * to allow us to do the work while not holding the hotplug lock.
 	 */
 	memmap_init_zone_device(&NODE_DATA(nid)->node_zones[ZONE_DEVICE],
-				align_start >> PAGE_SHIFT,
-				align_size >> PAGE_SHIFT, pgmap);
+				PHYS_PFN(res->start),
+				PHYS_PFN(resource_size(res)), pgmap);
 	percpu_ref_get_many(pgmap->ref, pfn_end(pgmap) - pfn_first(pgmap));
 
 	error = devm_add_action_or_reset(dev, devm_memremap_pages_release,
@@ -259,9 +246,9 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 	return __va(res->start);
 
  err_add_memory:
-	kasan_remove_zero_shadow(__va(align_start), align_size);
+	kasan_remove_zero_shadow(__va(res->start), resource_size(res));
  err_kasan:
-	untrack_pfn(NULL, PHYS_PFN(align_start), align_size);
+	untrack_pfn(NULL, PHYS_PFN(res->start), resource_size(res));
  err_pfn_remap:
 	pgmap_array_delete(res);
  err_array:

