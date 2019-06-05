Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 116CEC28D18
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 22:13:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B69902075B
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 22:13:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B69902075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 684626B0279; Wed,  5 Jun 2019 18:13:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 634E76B027A; Wed,  5 Jun 2019 18:13:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D7316B027B; Wed,  5 Jun 2019 18:13:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 131776B0279
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 18:13:12 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id g65so199583plb.9
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 15:13:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=EowCKhf3YudIrPL5E9Ee9l1jM9t44G3yACrnSK7J+yA=;
        b=o4UTvGwmUMBfhO5+MFVPu6Byp9dC8j8MykdusfB2BS5I3KM2PmSjTY65zoq0zt9KVY
         Ragv1A+nhZxReoh/CK4dh94iX5VS/uKG6eTecAOoddMkVp5UzCyLKUymmJAmVJJyBGdz
         yIslm++gxm2Cluqf7JN3dneuOTzFe9CqX0zSzr5RXjj2UbypvJ35hzUP9efeR3kl0+PH
         g924w7KDP79NOBXOCID58MFRNpi9Ok7B0NUdpNxS5lwYAa2yjFg1oqHO7R7C4i0gN0Yj
         3Bl7ExzjgCamP0k8XC5cUCKCYXVcKYbGhIPqUWoIz5AjafxbwTS/Byijz7HGUw8E4WkY
         D74Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWiR51m/h3AtsZUbvxBceEw0DnJgWGuE1pa2DMUqAMQMKUZnc+9
	/b3qXNm1IfMWRLmAbAboKXhciLMyWKMf6UDqZmvEqGgMLN0sD87dv7nLQELP9nb8w2bHZW5Ifpg
	5mvWcX5R8oeGBbum1spE/AZkSygWQyp0/VChqqGVnsMawFixB2zM8cChtWXBpXiNBRw==
X-Received: by 2002:a62:2b81:: with SMTP id r123mr9714543pfr.108.1559772791553;
        Wed, 05 Jun 2019 15:13:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1DRTHEh6bMsHHq1hiYd7REQsE44LOrdekQ23nZi5pjRReaiboAIAbFYrz9WIIC/d5OM16
X-Received: by 2002:a62:2b81:: with SMTP id r123mr9714435pfr.108.1559772790607;
        Wed, 05 Jun 2019 15:13:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559772790; cv=none;
        d=google.com; s=arc-20160816;
        b=cAg68RF6tGCAxLDua9+LruaqBDmxpaaGdeL8W2WLNxaAL8E2DJ/CNjphXbw9UBG5bX
         hqphib0uItgLcQapf/fU/KrfYEYGZzhLXMK45ePx1/XhvbUPwe4cxlT/afzEoH5c2eCX
         Ww6hX98rPVlLokZulsSM1wmEm3bfG/iqdtEM5AsKznX6SsCern8wMwm79G7Ogq4myRkG
         +ZbhlAQMm1g2n1gqMdQxgJGdj84bwNvx7lBCnbL/4Tc0w7SCKDZap+JrtnwXaweBRV28
         zLLIv67KRusW7+K+tByqo8j4H3uEiQpCFmp2uxd1oh/jeRwYHIKJe/aTG+5Pe8ukD5H8
         9kJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=EowCKhf3YudIrPL5E9Ee9l1jM9t44G3yACrnSK7J+yA=;
        b=ylwFvdRYG4o8UQ8Ceezgj1glTvLl8JhEPC+eSMZ6eWwQ0ctuWFr+zOEZv5Wq1WaO29
         G1Dm+hYIQju0sLLYOoT0F51XkRnNm1n8FdOjQyRDzrFMxrA64peA8Hs4C50hjw7ZxFcb
         KI8KAEpqn0+7tB0hQEWz6IUiIgIJNAob3BGQC41PGVEjvnIR5UuOATl604/IwOpCaBNO
         BUic/AxC/EAjDEZJuZHHjt5OIPTBTqFAUm19SvrdPaWOTFl3be0fmYDC/W/Uv/CNeBib
         2+bk9BnU8/0DKRacb0+PNogXXTamexMUXSXuHzDJTKYxGRAoCxXYH+2UxYRrUxwncXsY
         VOxg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id w12si10385063pld.301.2019.06.05.15.13.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 15:13:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Jun 2019 15:13:10 -0700
X-ExtLoop1: 1
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga006.fm.intel.com with ESMTP; 05 Jun 2019 15:13:09 -0700
Subject: [PATCH v9 10/12] mm/devm_memremap_pages: Enable sub-section remap
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Toshi Kani <toshi.kani@hpe.com>,
 =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
 Logan Gunthorpe <logang@deltatee.com>, Oscar Salvador <osalvador@suse.de>,
 Pavel Tatashin <pasha.tatashin@soleen.com>, linux-mm@kvack.org,
 linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, osalvador@suse.de,
 mhocko@suse.com
Date: Wed, 05 Jun 2019 14:58:53 -0700
Message-ID: <155977193326.2443951.14201009973429527491.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155977186863.2443951.9036044808311959913.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155977186863.2443951.9036044808311959913.stgit@dwillia2-desk3.amr.corp.intel.com>
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
index 57980ed4e571..a0e5f6b91b04 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -58,7 +58,7 @@ static unsigned long pfn_first(struct dev_pagemap *pgmap)
 	struct vmem_altmap *altmap = &pgmap->altmap;
 	unsigned long pfn;
 
-	pfn = res->start >> PAGE_SHIFT;
+	pfn = PHYS_PFN(res->start);
 	if (pgmap->altmap_valid)
 		pfn += vmem_altmap_offset(altmap);
 	return pfn;
@@ -86,7 +86,6 @@ static void devm_memremap_pages_release(void *data)
 	struct dev_pagemap *pgmap = data;
 	struct device *dev = pgmap->dev;
 	struct resource *res = &pgmap->res;
-	resource_size_t align_start, align_size;
 	unsigned long pfn;
 	int nid;
 
@@ -96,25 +95,21 @@ static void devm_memremap_pages_release(void *data)
 	pgmap->cleanup(pgmap->ref);
 
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
@@ -160,12 +152,7 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 		return ERR_PTR(-EINVAL);
 	}
 
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
@@ -173,7 +160,7 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 		goto err_array;
 	}
 
-	conflict_pgmap = get_dev_pagemap(PHYS_PFN(align_end), NULL);
+	conflict_pgmap = get_dev_pagemap(PHYS_PFN(res->end), NULL);
 	if (conflict_pgmap) {
 		dev_WARN(dev, "Conflicting mapping in same section\n");
 		put_dev_pagemap(conflict_pgmap);
@@ -181,7 +168,7 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 		goto err_array;
 	}
 
-	is_ram = region_intersects(align_start, align_size,
+	is_ram = region_intersects(res->start, resource_size(res),
 		IORESOURCE_SYSTEM_RAM, IORES_DESC_NONE);
 
 	if (is_ram != REGION_DISJOINT) {
@@ -202,8 +189,8 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 	if (nid < 0)
 		nid = numa_mem_id();
 
-	error = track_pfn_remap(NULL, &pgprot, PHYS_PFN(align_start), 0,
-			align_size);
+	error = track_pfn_remap(NULL, &pgprot, PHYS_PFN(res->start), 0,
+			resource_size(res));
 	if (error)
 		goto err_pfn_remap;
 
@@ -221,25 +208,25 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
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
@@ -251,8 +238,8 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 	 * to allow us to do the work while not holding the hotplug lock.
 	 */
 	memmap_init_zone_device(&NODE_DATA(nid)->node_zones[ZONE_DEVICE],
-				align_start >> PAGE_SHIFT,
-				align_size >> PAGE_SHIFT, pgmap);
+				PHYS_PFN(res->start),
+				PHYS_PFN(resource_size(res)), pgmap);
 	percpu_ref_get_many(pgmap->ref, pfn_end(pgmap) - pfn_first(pgmap));
 
 	error = devm_add_action_or_reset(dev, devm_memremap_pages_release,
@@ -263,9 +250,9 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
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

