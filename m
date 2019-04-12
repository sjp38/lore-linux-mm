Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 504C8C10F14
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 19:02:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E26020818
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 19:02:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E26020818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A999A6B000D; Fri, 12 Apr 2019 15:02:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A4C546B0010; Fri, 12 Apr 2019 15:02:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C22B6B026A; Fri, 12 Apr 2019 15:02:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 40A6F6B000D
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 15:02:08 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id w27so5479794edb.13
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 12:02:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=W8RImTT5/NuqjLVEjUkkWwa/kQ7S5eOStSkQSRaZDsM=;
        b=iSByGN93MVsBneLezYCaElAt/hoRNPx04SrWnp2aOHiwha5uqpZWKj8EWVyXkQRWF+
         0W2bwu/e+X0iplVlD712C8HBAMK8EAZ5HhkkifEz5N8sD1wxuKMU5/bIm5Fws9h5YVtr
         ANneyndUWf2tJt3YJOIuC3xQSQ8vgt9qLVyd2H5qfwH79dPkhvF/V18Tc6Jk3j86c+g/
         R2mfDiyZ1JBtGoSDp9rEN1MrrjTMxuzgrpNGH8XFL+2ZfPIXOZcaIQHk7QQOPQ7jvB+U
         W5xclpLiblqq590a0K/QP31t6QQqx5dRX8FVnCwTUqlxiKjOmM1e7tBDLvnt+g0AgRkS
         OqQg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: APjAAAXSsdtpsXRBPvr+Prrz27j5GMxQQVOoST3P06LGoJWoMV14Z67U
	uPyc/OaRC5nRMpt536dM84WCs+WIf+QzxqPcsTP3kj6E3DA1qsqaCr2mkmMJ49VmGoO20qmrfG+
	QEA3ZgCdpElS8edhxLBbBjlPG0BWvIQmbyXB6FavNHf/XvN6Lh9nGurhlsOV2XBc9QA==
X-Received: by 2002:a50:b618:: with SMTP id b24mr37252509ede.9.1555095727836;
        Fri, 12 Apr 2019 12:02:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxPynpM3dC3uYjPr8jY2zJcMYfSYkNScqx+BaevKD4Efky99U+2HCHLWulUlDUASXiNW6fs
X-Received: by 2002:a50:b618:: with SMTP id b24mr37252466ede.9.1555095727026;
        Fri, 12 Apr 2019 12:02:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555095727; cv=none;
        d=google.com; s=arc-20160816;
        b=0ZYvXFa21gZ5K7ERXiaXbrcimqW9p61U7dew/gdSK1Msqop6YKHRJBzrC30uukalcJ
         RQ1y8CxMih2FdjRWm0hbUwIKIgEr1B+RWpLGTJU4Q2Qy7ymsHjmJTT03VLTWVv/MTiEs
         gWkfGEoPKK6PiD/DXACUDG0omn1nJl6DM5QuXbqOsbKRjAvcjY242uUul/i79WRdqsqd
         nXjL4L75RRDd8yCnuk6C3dAJOIK1TDJW2Eh2SwUjr+kmKCQ7s/MvIo65bJdkZPlPAFcc
         FQuulotwsWyGdtfiKyc/lh4D0/7t5tGCQ1Hh7JdKTikKv10xHPbBBWz9HPpuIJTqA40W
         eFiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=W8RImTT5/NuqjLVEjUkkWwa/kQ7S5eOStSkQSRaZDsM=;
        b=vG0VQDkW6yj1j3X17H62JuZV08iH7Dt1/1Obe83e3CsxA6Vw+Coynx7OacXADURqZC
         P5Ojq3FDyjAt9vK1E75GcF2MnEHRSwoZO+2L9q5fC25OnNtlNDnST0AM31ZcPuZ3FIp+
         Gf1tQHYUj3RCICWAJT7wO8VPqSb1K9quloH6Yr9GP5Kyv3F8m0pvNhcXzQOGPvkE6jZE
         6hDcoRT4VrTfuGehwMtgAlBtFe1GF+0+ay2bMV+pmPOciAVim72vZRs9BbPzb97Kc7IA
         UoaKBQS/WMt2RYZ+yIqhYnLChTsReVYnS0QAqFzjpDraDkXcWKQn3Dad0UrGKsgDY2G5
         5jfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id me22si2194843ejb.21.2019.04.12.12.02.06
        for <linux-mm@kvack.org>;
        Fri, 12 Apr 2019 12:02:07 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D6D9115AD;
	Fri, 12 Apr 2019 12:02:05 -0700 (PDT)
Received: from e110467-lin.cambridge.arm.com (e110467-lin.cambridge.arm.com [10.1.196.75])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 3843C3F718;
	Fri, 12 Apr 2019 12:02:04 -0700 (PDT)
From: Robin Murphy <robin.murphy@arm.com>
To: linux-mm@kvack.org
Cc: dan.j.williams@intel.com,
	ira.weiny@intel.com,
	jglisse@redhat.com,
	oohall@gmail.com,
	x86@kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	anshuman.khandual@arm.com,
	linux-kernel@vger.kernel.org
Subject: [PATCH RESEND 1/3] mm/memremap: Rename and consolidate SECTION_SIZE
Date: Fri, 12 Apr 2019 20:01:56 +0100
Message-Id:
 <029d4af64642019a6d73c804d362d840f4eb0941.1555093412.git.robin.murphy@arm.com>
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
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190412190156.P8bruvQ_4BSXjkksO_UJie66_DzfqIenT_nUsj5O8nc@z>

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

