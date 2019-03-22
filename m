Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F9A4C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 17:11:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D26C421900
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 17:11:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D26C421900
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 899906B0010; Fri, 22 Mar 2019 13:11:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 847CD6B0266; Fri, 22 Mar 2019 13:11:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7396C6B0269; Fri, 22 Mar 2019 13:11:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 396B16B0010
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 13:11:17 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id g1so2107315pfo.2
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 10:11:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=bjCWBK7XWA7ZduHohUaiiF9VXYObt6QrOmEaCPsYtCg=;
        b=ZIUouXRrUvSXqhRAZDluO8KnCH5m/IBvh2GFVptZ3HpTK3QREH14cEzM9ws3RY/lZc
         6lVTbxzmd4W/+B6uYsN0YhEXRXA9YTRtG2Z76oB7S84nU/bRsun4j4tdfQmsIwrenlXH
         nrzQ09NS6MZN+XqefiOw8uJsheIuzs8h/lGs7sDVgfJJ0qR4/hRdkWJMn8ehMOLHF8tb
         KN/GCApYI4JLYHuYCxbL+wl/aL6A5Oi7YFNBs3QLGKHhf+nUj+1LGEUHPglAPs91IfLJ
         vzo+IVAVJhRQ3/HGoum59062GMqzkStf7cmthf7iV/gywJY0w75Urw8yEbzdZlYZmoLk
         2gtA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWd+F2NDsAZk0m97RWK+LqYbXP7QVKPQdQqSGXOWhaOIQ9qBYLR
	hs8msRFGE1MocSvJQXQ/hUXQpSyGu9tt7FR9nOTBt3vMayfeR91uZNPnK+r4PIR98buwam5a2l2
	2+d2pZJAjvyFr5ty+GIARC+j8cWHfprgV8M+7vtdYKj96B73yye2toz0n5u8YlKjPkw==
X-Received: by 2002:a17:902:361:: with SMTP id 88mr10766903pld.78.1553274676895;
        Fri, 22 Mar 2019 10:11:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqymI/q8UZ+uicFYHeKyhWktuC9Ye7s/PHzmOBKy58i3rq7mfXZ8s8YAcTA8YdgMD3hmLyzO
X-Received: by 2002:a17:902:361:: with SMTP id 88mr10766841pld.78.1553274676067;
        Fri, 22 Mar 2019 10:11:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553274676; cv=none;
        d=google.com; s=arc-20160816;
        b=fpsO37A4XFtcW9nFSjAqvr7hSSRxSufCsuJtvpZ0ljLcsWE7ar//bGGIkRTQNWudFZ
         ap3A0JwWesry+puIfhPrQJI+ShFibvvX5j55i7nSxOKuQHhHqubjVF5yqohfp8X1X1jC
         0bEUI9DllMQlYSfHExXdXsadIQMzOVyJf5DxRg6wnCfieZ7Sywxlyess2rs9H22IBO1J
         eToZB0S3pWl8Vfd4dgEwXb7UV8LDAqm4Dz7v8R+fkpK4BVoctzsy+1Z+uiVx/9eaWsGv
         LZZYfPil4/AF/eTst0PDyB10RzSAyGVXiVNq9nfPVvVWJT64WbQgsAZsjcdlGasqs4Cq
         PK6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=bjCWBK7XWA7ZduHohUaiiF9VXYObt6QrOmEaCPsYtCg=;
        b=NGeWCY/Yg6jBceA75HRIlFsgLXD1B6PDQPe8Q9aLUCXuYKRh1O04lxPyDbrz+Jsgjj
         ps6wv9Em1FUo5OnwoaXs66H59grWmm3fxRsMccnclUGb/QNTvDSTAoMAUcVSI3G6+3fJ
         otnz67qmdogSuOHbIcmR4Q/HsobCU5aQk24ylD4XqTTWEmNFnmJe3v8s+nqkqzad4Hxr
         jtaOMHxf3+mLGeKCIsaB8WrWFw8hKm61PyUuQ/z2m9f5/IfQYvqNIlY27NwfAlnFUWkz
         MJH48D98PMnE1jtz7TqYPXwHHzvq6RX6cfCy3hDitRXQJ2C06zr8P/QOq/83IlaMfPH4
         iutg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id i65si7045774pfj.105.2019.03.22.10.11.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 10:11:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Mar 2019 10:11:15 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,256,1549958400"; 
   d="scan'208";a="136552998"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga007.fm.intel.com with ESMTP; 22 Mar 2019 10:11:14 -0700
Subject: [PATCH v5 08/10] mm/devm_memremap_pages: Enable sub-section remap
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Toshi Kani <toshi.kani@hpe.com>,
 =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
 Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org,
 linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org
Date: Fri, 22 Mar 2019 09:58:36 -0700
Message-ID: <155327391603.225273.924677730380586912.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155327387405.225273.9325594075351253804.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155327387405.225273.9325594075351253804.stgit@dwillia2-desk3.amr.corp.intel.com>
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
 kernel/memremap.c |   55 +++++++++++++++++++++--------------------------------
 1 file changed, 22 insertions(+), 33 deletions(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index dda1367b385d..08344869e717 100644
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
@@ -141,7 +136,6 @@ static void devm_memremap_pages_release(void *data)
  */
 void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 {
-	resource_size_t align_start, align_size, align_end;
 	struct vmem_altmap *altmap = pgmap->altmap_valid ?
 			&pgmap->altmap : NULL;
 	struct resource *res = &pgmap->res;
@@ -152,26 +146,21 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
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
@@ -192,8 +181,8 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 	if (nid < 0)
 		nid = numa_mem_id();
 
-	error = track_pfn_remap(NULL, &pgprot, PHYS_PFN(align_start), 0,
-			align_size);
+	error = track_pfn_remap(NULL, &pgprot, PHYS_PFN(res->start), 0,
+			resource_size(res));
 	if (error)
 		goto err_pfn_remap;
 
@@ -211,16 +200,16 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 	 * arch_add_memory().
 	 */
 	if (pgmap->type == MEMORY_DEVICE_PRIVATE) {
-		error = add_pages(nid, align_start >> PAGE_SHIFT,
-				align_size >> PAGE_SHIFT, NULL, false);
+		error = add_pages(nid, PHYS_PFN(res->start),
+				PHYS_PFN(resource_size(res)), NULL, false);
 	} else {
-		error = kasan_add_zero_shadow(__va(align_start), align_size);
+		error = kasan_add_zero_shadow(__va(res->start), resource_size(res));
 		if (error) {
 			mem_hotplug_done();
 			goto err_kasan;
 		}
 
-		error = arch_add_memory(nid, align_start, align_size, altmap,
+		error = arch_add_memory(nid, res->start, resource_size(res), altmap,
 				false);
 	}
 
@@ -228,8 +217,8 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 		struct zone *zone;
 
 		zone = &NODE_DATA(nid)->node_zones[ZONE_DEVICE];
-		move_pfn_range_to_zone(zone, align_start >> PAGE_SHIFT,
-				align_size >> PAGE_SHIFT, altmap);
+		move_pfn_range_to_zone(zone, PHYS_PFN(res->start),
+				PHYS_PFN(resource_size(res)), altmap);
 	}
 
 	mem_hotplug_done();
@@ -241,8 +230,8 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 	 * to allow us to do the work while not holding the hotplug lock.
 	 */
 	memmap_init_zone_device(&NODE_DATA(nid)->node_zones[ZONE_DEVICE],
-				align_start >> PAGE_SHIFT,
-				align_size >> PAGE_SHIFT, pgmap);
+				PHYS_PFN(res->start),
+				PHYS_PFN(resource_size(res)), pgmap);
 	percpu_ref_get_many(pgmap->ref, pfn_end(pgmap) - pfn_first(pgmap));
 
 	error = devm_add_action_or_reset(dev, devm_memremap_pages_release,
@@ -253,9 +242,9 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
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

