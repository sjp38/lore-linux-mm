Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59EABC10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 18:57:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 15DEE20818
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 18:57:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15DEE20818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B13526B000D; Fri, 12 Apr 2019 14:57:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A77546B0010; Fri, 12 Apr 2019 14:57:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 87B526B026A; Fri, 12 Apr 2019 14:57:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 34EA26B000D
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 14:57:26 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id h26so5467523eds.6
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 11:57:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=W8RImTT5/NuqjLVEjUkkWwa/kQ7S5eOStSkQSRaZDsM=;
        b=SZj5LYWyVFKkTcDHh3LzJZJ5xkCySPjxdZupQ5l6l2svSrTEZlzZ93u97SToFDLteg
         C2mSidFh9qxjDnDl1Q9h4/hmMzd/nPmO5ptOgIiBww1BSUxXtz/iu5VKARVd2yU3+1UR
         WoO/rxrl8hQhX/fVbaviD78SpVPFMoSwdT/2TpD03tjSZ9HyRHkex9iw+MH5EGItcyS3
         CnZID8Fuo1eCY2vhhP0crE3IJ5tWysITIiv7RcnN+6D8bPbhPs7IRmJbk0E/Kq8RVUq/
         IXwkIr/EnrOP11D3FnuBHFCh+y+FG/VYGumyepmBxD/mm8oOsSsmVu4j++wHYOHpteEI
         cO2Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: APjAAAU+Sq53L36PGeSl2pTywkXydP8d6teVEuWmUF9R1A6RQB8OcFDg
	jkOFqd4J4Ij17TCbMl3lzGoEcTYf1/UaQmEymt2dLSWuUJJKuFt4bscqSCwjGvUzquHg5lv1fuo
	+02g1hw0nFCfYjJZwEUZMN1DfoHZ80G8kBlJrPctQRFEDhUOo6wFiJ99IB7ARV+eX8w==
X-Received: by 2002:a50:9a21:: with SMTP id o30mr14234753edb.253.1555095445716;
        Fri, 12 Apr 2019 11:57:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx5SsgWSRYAZqLjouAXn5QEmGONPRMQasPJkBZu+xJGd9hhElbl8vhP1i+asYtrqLSR2Odx
X-Received: by 2002:a50:9a21:: with SMTP id o30mr14234693edb.253.1555095444575;
        Fri, 12 Apr 2019 11:57:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555095444; cv=none;
        d=google.com; s=arc-20160816;
        b=m1BnL2pxyugNLCKIXmFkHLHBea1xp7Pene2RCkndeSQ27SZZ00uSd1WTS4cWKonYu9
         JoKaNiQzwJD3M5DVVxYFcAO3HdUcaeqbiSeK//en7Cu3U7+s3wq0ce+vzCai8MzuMFIX
         r3Nif9M5k/S3SzQYqefc9/7eNhU+S8rJEfVCCAAS9pNPoFacdVUvPDT+05Y6kyuFL8zx
         pez8ueXRwtBABOWoKA90zMN6egBzNiNtetJjJYoMOD1SaDcO5f0ggEN5dTaR40AOWeUy
         +fX1jgcVeFfZfYasKnhQOnoxlU2268VHEEYIGC1BwZKo8FeGrjDERATlwzbezJL7Ksph
         PjxA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=W8RImTT5/NuqjLVEjUkkWwa/kQ7S5eOStSkQSRaZDsM=;
        b=vz/dxqsdaQjm0bPQgJBYN//0AB22Us2UkWP7RHVHR3MYv0KRvzrT74IkjJk2e5LcMT
         PMP24718+MqhanIyDBtrlHWflrFwFZLDrth4Yoi2APysn5CZauSTPQsjVig1qFZWwCMF
         DnGpSeTOTAq/IadKeBo45vEW8UOf0PKrJMaFlM/C/k4A1cH4Cc5nIYTP4oPWoFPqcJaY
         AB8BJL/B82j9b5nc+Xu8qqxI0Fi1HK0pRYprmLLczLG0iFzmza4eGC7CBHjQYj9Uab7D
         ufjYKwUeh5jmb4JxxI0SVagjwKGRuX5hmVOsPMCktzQd+zJSu7w12hbOHb0ubJPpg9HP
         b2Ng==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a20si3489809edd.353.2019.04.12.11.57.23
        for <linux-mm@kvack.org>;
        Fri, 12 Apr 2019 11:57:24 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 2FC1F15BE;
	Fri, 12 Apr 2019 11:57:23 -0700 (PDT)
Received: from e110467-lin.cambridge.arm.com (e110467-lin.cambridge.arm.com [10.1.196.75])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 872D63F718;
	Fri, 12 Apr 2019 11:57:21 -0700 (PDT)
From: Robin Murphy <robin.murphy@arm.com>
To: linux-mm@kvack.org
Cc: dan.j.williams@intel.com,
	ira.weiny@intel.com,
	jglisse@redhat.com,
	ohall@gmail.com,
	x86@kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	anshuman.khandual@arm.com,
	linux-kernel@vger.kernel.org
Subject: [PATCH 1/3] mm/memremap: Rename and consolidate SECTION_SIZE
Date: Fri, 12 Apr 2019 19:56:00 +0100
Message-Id: <029d4af64642019a6d73c804d362d840f4eb0941.1555093412.git.robin.murphy@arm.com>
X-Mailer: git-send-email 2.21.0.dirty
In-Reply-To: <cover.1555093412.git.robin.murphy@arm.com>
References: <cover.1555093412.git.robin.murphy@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Trying to activatee ZONE_DEVICE for arm64 reveals that memremap's
internal helpers for sparsemem sections conflict with and arm64's
definitions for hugepages, which inherit the name of "sections" from
earlier versions of the ARM architecture.

Disambiguate memremap (and now HMM too) by propagating sparsemem's PA_
prefix, to clarify that these values are in terms of addresses rather
than PFNs (and because it's a heck of a lot easier than changing all the
arch code). SECTION_MASK is unused, so it can just go.

[anshuman: Consolidated mm/hmm.c instance and updated the commit message]

Acked-by: Michal Hocko <mhocko@suse.com>
Reviewed-by: David Hildenbrand <david@redhat.com>
Signed-off-by: Robin Murphy <robin.murphy@arm.com>
Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 include/linux/mmzone.h |  1 +
 kernel/memremap.c      | 10 ++++------
 mm/hmm.c               |  2 --
 3 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index fba7741533be..ed7dd27ee94a 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1081,6 +1081,7 @@ static inline unsigned long early_pfn_to_nid(unsigned long pfn)
  * PFN_SECTION_SHIFT		pfn to/from section number
  */
 #define PA_SECTION_SHIFT	(SECTION_SIZE_BITS)
+#define PA_SECTION_SIZE		(1UL << PA_SECTION_SHIFT)
 #define PFN_SECTION_SHIFT	(SECTION_SIZE_BITS - PAGE_SHIFT)
 
 #define NR_MEM_SECTIONS		(1UL << SECTIONS_SHIFT)
diff --git a/kernel/memremap.c b/kernel/memremap.c
index a856cb5ff192..dda1367b385d 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -14,8 +14,6 @@
 #include <linux/hmm.h>
 
 static DEFINE_XARRAY(pgmap_array);
-#define SECTION_MASK ~((1UL << PA_SECTION_SHIFT) - 1)
-#define SECTION_SIZE (1UL << PA_SECTION_SHIFT)
 
 #if IS_ENABLED(CONFIG_DEVICE_PRIVATE)
 vm_fault_t device_private_entry_fault(struct vm_area_struct *vma,
@@ -98,8 +96,8 @@ static void devm_memremap_pages_release(void *data)
 		put_page(pfn_to_page(pfn));
 
 	/* pages are dead and unused, undo the arch mapping */
-	align_start = res->start & ~(SECTION_SIZE - 1);
-	align_size = ALIGN(res->start + resource_size(res), SECTION_SIZE)
+	align_start = res->start & ~(PA_SECTION_SIZE - 1);
+	align_size = ALIGN(res->start + resource_size(res), PA_SECTION_SIZE)
 		- align_start;
 
 	nid = page_to_nid(pfn_to_page(align_start >> PAGE_SHIFT));
@@ -154,8 +152,8 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 	if (!pgmap->ref || !pgmap->kill)
 		return ERR_PTR(-EINVAL);
 
-	align_start = res->start & ~(SECTION_SIZE - 1);
-	align_size = ALIGN(res->start + resource_size(res), SECTION_SIZE)
+	align_start = res->start & ~(PA_SECTION_SIZE - 1);
+	align_size = ALIGN(res->start + resource_size(res), PA_SECTION_SIZE)
 		- align_start;
 	align_end = align_start + align_size - 1;
 
diff --git a/mm/hmm.c b/mm/hmm.c
index fe1cd87e49ac..ef9e4e6c9f92 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -33,8 +33,6 @@
 #include <linux/mmu_notifier.h>
 #include <linux/memory_hotplug.h>
 
-#define PA_SECTION_SIZE (1UL << PA_SECTION_SHIFT)
-
 #if IS_ENABLED(CONFIG_HMM_MIRROR)
 static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
 
-- 
2.21.0.dirty

