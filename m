Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 399ACC282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 18:53:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D81C920663
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 18:53:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D81C920663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 825096B0269; Wed, 17 Apr 2019 14:53:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7FC576B026A; Wed, 17 Apr 2019 14:53:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6EBB76B026B; Wed, 17 Apr 2019 14:53:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 35DF66B0269
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 14:53:35 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id h14so15120501pgn.23
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 11:53:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=aSPlNcaqYJWY7Dx9FIn/bsDVRzbR+x2q4v+WFCxxa2g=;
        b=cgc2G28tjN24e7GMSBY4iAnxgRC19zrLIth7R8RF1SZXc5A9rZVUBkihgBE7X1zvp1
         gujvju62do5Dkm0+47hqUQZPvctfRMl2EJdOOvHuwhvst4maa9s+L8SLM71ViNv4eCc3
         N+c5jCxBrBchNQyzEXNoQyeRLb25rgZav0zjuqZgcMwCwmkMBwLEJwUz93n68sJWcRxq
         rY4yICWDvCPQvYc9Cntbng7tztCOJuz3wF9C8WlrL6+aMYvAriiu3QUC20JkedABISNa
         8ez6xUW+RN5RdxWoGAhfYsBbCJErFOeaNFnOQHzh+AIUOEhxZXgXkoRWbqq5OZ+dXBpR
         AegQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU7mLk5eX6jeB0g/gR9PqDKANd4AKMIMC+lia7zqZtwS+zbB/DT
	cIYHzvuFH5uQ3Ms5WbBnPhMO3nUfUZf//e8R81eTT7kJDVsTeIis2oyT1ZMydPGJ3JSddIflDWl
	j7qwe+Zg94qIbQCbojQ4VHLuLKQHPdgElb30KNKoUXhf5/MrcnvG27bbtA7looeHJKA==
X-Received: by 2002:a62:6444:: with SMTP id y65mr90817903pfb.56.1555527214863;
        Wed, 17 Apr 2019 11:53:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyrcsgIYMz5nssBrMblHqx82JgOVwavQs8vUIsiWFqp51+F1BkfweJ70HBp5Yxmk9P92PcY
X-Received: by 2002:a62:6444:: with SMTP id y65mr90817840pfb.56.1555527214114;
        Wed, 17 Apr 2019 11:53:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555527214; cv=none;
        d=google.com; s=arc-20160816;
        b=KbtzzXt8D+FNPm9QPHX5MUjjqbFHjCmj6viXoKDNRP58b6Rm/OkoKw1RS4byXCExD0
         aSK6KYjbGJhkZdRkfIbXN98a+KSexSLCXcgLGv+e0MjdJPkkBjaraZjA89iKfoYX8vKS
         3tAAWrDQG1eSv/vCINPWkD+zpObWp+iwfB1T7/0RyMsyFanhFhx5wxvdDyUccWHaHijf
         ssnmhMUbpEzl/pXjSJJmX1Ak/5GA8TXf0Udcfz3uj3X5LNAz1ImmmN3I/85qqtPb18Dv
         chaH7/r2tjsbYyqRrWV1gEMvS/qJVp+I4p/dKTH8jF8VtaPGCzwG7aI8sN2gzTsm+oyD
         Sc6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=aSPlNcaqYJWY7Dx9FIn/bsDVRzbR+x2q4v+WFCxxa2g=;
        b=yw9OkwsnpO5aVfhP4Ga9Pur3h3bLUeFkN2RzF0dgNE3rtvnfFyXRSi0zrd7+jCq6Qt
         6aQ27FrV68fdNS04NouDy6HR9VftE8e1APqQmjX3ZthY+67v547IiEBdeaSEKmUVgOok
         SVh2E/Mymq94aq2DCLAuNNBFgAUck9jpzzm4vrmcbjd5TZ6Rf+McBFb9UgQ88caG13LV
         OIwjIp+JH3ZWrta7z5SJYnD4edTU85K1XgNceRk+Ms1HOAAlONUlxA30m6eLYwjA5tcm
         CQV7zn7gR4yH+O1wPFTpf+ASTKSAqscHDXSHzy5T78crzp+OTFpvhT2nWK63f4VRKSHt
         NrNw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id l191si33259965pgd.549.2019.04.17.11.53.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 11:53:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Apr 2019 11:53:33 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,362,1549958400"; 
   d="scan'208";a="338429903"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga006.fm.intel.com with ESMTP; 17 Apr 2019 11:53:33 -0700
Subject: [PATCH v6 10/12] mm/devm_memremap_pages: Enable sub-section remap
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Toshi Kani <toshi.kani@hpe.com>,
 =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
 Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org,
 linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, mhocko@suse.com,
 david@redhat.com
Date: Wed, 17 Apr 2019 11:39:47 -0700
Message-ID: <155552638740.2015392.3474262226224495313.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
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
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 kernel/memremap.c |   58 ++++++++++++++++++++++-------------------------------
 1 file changed, 24 insertions(+), 34 deletions(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index 33475e211568..ca74a006371a 100644
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
 
@@ -96,28 +95,25 @@ static void devm_memremap_pages_release(void *data)
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
 		struct mhp_restrictions restrictions = {
 			.altmap = pgmap->altmap_valid ? &pgmap->altmap : NULL,
 		};
 
-		arch_remove_memory(nid, align_start, align_size, &restrictions);
-		kasan_remove_zero_shadow(__va(align_start), align_size);
+		arch_remove_memory(nid, res->start, resource_size(res),
+				&restrictions);
+		kasan_remove_zero_shadow(__va(res->start), resource_size(res));
 	}
 	mem_hotplug_done();
 
-	untrack_pfn(NULL, PHYS_PFN(align_start), align_size);
+	untrack_pfn(NULL, PHYS_PFN(res->start), resource_size(res));
 	pgmap_array_delete(res);
 	dev_WARN_ONCE(dev, pgmap->altmap.alloc,
 		      "%s: failed to free all reserved pages\n", __func__);
@@ -144,7 +140,6 @@ static void devm_memremap_pages_release(void *data)
  */
 void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 {
-	resource_size_t align_start, align_size, align_end;
 	struct resource *res = &pgmap->res;
 	struct dev_pagemap *conflict_pgmap;
 	struct mhp_restrictions restrictions = {
@@ -160,26 +155,21 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
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
@@ -200,8 +190,8 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 	if (nid < 0)
 		nid = numa_mem_id();
 
-	error = track_pfn_remap(NULL, &pgprot, PHYS_PFN(align_start), 0,
-			align_size);
+	error = track_pfn_remap(NULL, &pgprot, PHYS_PFN(res->start), 0,
+			resource_size(res));
 	if (error)
 		goto err_pfn_remap;
 
@@ -219,25 +209,25 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
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
-				align_size >> PAGE_SHIFT, restrictions.altmap);
+		move_pfn_range_to_zone(zone, PHYS_PFN(res->start),
+				PHYS_PFN(resource_size(res)), restrictions.altmap);
 	}
 
 	mem_hotplug_done();
@@ -249,8 +239,8 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 	 * to allow us to do the work while not holding the hotplug lock.
 	 */
 	memmap_init_zone_device(&NODE_DATA(nid)->node_zones[ZONE_DEVICE],
-				align_start >> PAGE_SHIFT,
-				align_size >> PAGE_SHIFT, pgmap);
+				PHYS_PFN(res->start),
+				PHYS_PFN(resource_size(res)), pgmap);
 	percpu_ref_get_many(pgmap->ref, pfn_end(pgmap) - pfn_first(pgmap));
 
 	error = devm_add_action_or_reset(dev, devm_memremap_pages_release,
@@ -261,9 +251,9 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
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

