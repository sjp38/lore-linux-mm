Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4809AC04AA6
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 17:22:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F0589215EA
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 17:22:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F0589215EA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A6E206B0005; Mon, 29 Apr 2019 13:22:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F5CE6B0007; Mon, 29 Apr 2019 13:22:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E67A6B0008; Mon, 29 Apr 2019 13:22:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4232B6B0005
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 13:22:30 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f17so5159867edq.3
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 10:22:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=2eKKxYJ9+/a0EhcYiOjWwiTGOV8tvC7ALn17if7OocU=;
        b=fSn9kSLNP8CVS3NSH52unUfSToeobFeEZWrRrXR872QC0RfLHpGmUgRO3xbn09L80z
         r1+cKd20x4lPDwOCWlEgmk35KV+hZdoM3T8KtKgKpWfql14PbyPVGtYC9MQI0RMh3Hv4
         NlcHN343bIsAPSS2XiOYtJKINsFr3gBmH3GWp2Gyuj3ctS7WDkORt45xT9xbYV6sAEpQ
         Nl9Gl5FV4Ojt82QfHjRFMS4EAywGkb1VB+MTGtRA50oDvc6UGBhn6Di1QbNNUfD7dHSw
         NorKapF2uI354uYicnxEjkroPbr462NUFNtDdaH/VGdYHKS2/MChxqRKteTm3qFJzLVZ
         SySw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: APjAAAXDZgb3oNlbnmnHO+1ThlzhrDzH4X72KQKD+ZMWNGG9avhU9khx
	LdqV4m++peIZHmO2FqqndGncUHpfqmRMBTu5siiNeoDeOqICSZnYz+BZll+bzYmI4VEArK4C6SQ
	brcG207nhbWsq7/5b8guYS6Sf78lzyJPIqUoTnV6uCSxwIvXmTxCvQdidaBWafZyFfQ==
X-Received: by 2002:a50:a3c2:: with SMTP id t2mr39466726edb.46.1556558549786;
        Mon, 29 Apr 2019 10:22:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxM05fa+S12u+/pAWFRMFetLpGKd0nIIYBDMKaYF7un27LgBOopgh9/t3uQd//et/wwyUUK
X-Received: by 2002:a50:a3c2:: with SMTP id t2mr39466674edb.46.1556558548854;
        Mon, 29 Apr 2019 10:22:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556558548; cv=none;
        d=google.com; s=arc-20160816;
        b=OCoVlfyUHBo9M7JeuYr4b83mqyi0tX4YyHLEILgzUgGRpyaUAExyj4gOQcRQNovV3E
         +4wt7RmUDAUQZUBofGVCsm6nq4GRO6pBM2rQmFi/8RQJ4OvxK80G3rxQ35Ifh2yWKmrD
         epgcEmdldQEaOhDTsS4TpX+s/x7nA7AcDjOD0GzdiWryCzrjzgeQRfwTsvJy3PyN1CLj
         MbhW0x/F1j7brmUDcqafrS2M0Ux2yac6Q/8jAhQ3EZobaf+Xzg4zM7x3nSrLrb50hvrj
         xgNl4LgndPbve8zOlp8Y5pyutsSWdcqXntWLQWlYP2aORL8nxqnAnmxqeygi9IhtkpFX
         6LoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=2eKKxYJ9+/a0EhcYiOjWwiTGOV8tvC7ALn17if7OocU=;
        b=gD2arC1sUu4z0boo3cFNC6MOksl8CIPykJZm/+g2Hz7X9SpVNKEA3B0mpIbSuL5VSI
         EQy6gWHwckkVgWINMPAVkWv7kG3AllI1ZXPsriD4Fw551G1bKnCG9jgaKyG95vSVVLvK
         Zzb+kcOBuTOB+xmSnjjt23aujn6mZUPeU3leD7ps3c6AEZj+QdOvnTHQabHpLKavkk9a
         RK3wzZ4lOuTn+Oi0TRuRNa4ZodPeNvb7Y8/n9O0JnTRmfUiILjZWhqz/yqXs8Z1EuBR6
         iuT1JKw7pVcV5Gqq2OOhsY94UAFDToR4kGe6122jZIMou0ZUAPyG+aOgR6wEuaOiN0gr
         rJ1w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f7si9658718edj.85.2019.04.29.10.22.28
        for <linux-mm@kvack.org>;
        Mon, 29 Apr 2019 10:22:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 9426780D;
	Mon, 29 Apr 2019 10:22:27 -0700 (PDT)
Received: from e110467-lin.cambridge.arm.com (e110467-lin.cambridge.arm.com [10.1.196.75])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 2E14B3F557;
	Mon, 29 Apr 2019 10:22:26 -0700 (PDT)
From: Robin Murphy <robin.murphy@arm.com>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org,
	Michal Hocko <mhocko@suse.com>,
	David Hildenbrand <david@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Anshuman Khandual <anshuman.khandual@arm.com>
Subject: [PATCH v2 1/3] mm/memremap: Rename and consolidate SECTION_SIZE
Date: Mon, 29 Apr 2019 18:22:15 +0100
Message-Id: <7c31ee50c533a67f88d21ba439851837a00d7d50.1556555457.git.robin.murphy@arm.com>
X-Mailer: git-send-email 2.21.0.dirty
In-Reply-To: <cover.1556555457.git.robin.murphy@arm.com>
References: <cover.1556555457.git.robin.murphy@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Trying to activate ZONE_DEVICE for arm64 reveals that memremap's
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
Acked-by: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Robin Murphy <robin.murphy@arm.com>
Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---

v2: Fix commit message typo, add review tags.

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

