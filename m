Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E12DC10F06
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:30:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E0906206C0
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:30:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E0906206C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 83D7A6B028E; Wed,  3 Apr 2019 00:30:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7EB516B0290; Wed,  3 Apr 2019 00:30:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6B44A6B0291; Wed,  3 Apr 2019 00:30:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1D5B76B028E
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 00:30:45 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d2so6714608edo.23
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 21:30:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=EkSxpVM4Bmt2ySq+et1fZS12TxWCefQIMkki4BSNv7E=;
        b=Vngz61cAKspbkDFXLke0UW3OQjoiuw2KgMN41ZEJ/bkksoo4AtL2NFtvoNIrNjvO8/
         vrejxD5iSNw2VMYeUiIq9LY6Q6daCuMkBTC4cUXybL/hQNAGxjHDXe3fjaIemr61qKea
         0qii3rF9W83BsLVYKAkzjNXo0FDq7ivL535+JWQe6y4JslH1JAITX2fUueqmS4oU612l
         K6MmPb8WLqHOM4dENHzAdAkMz5mq2hIyW5i8CKewTF9Tz1pR0VrRuPt4WQJKltpN1cc4
         3oUWd/ZcbbzQc9U7Ga2W/zleDZ6geP8KTqjHrENu1GEGk77jJfHKphJHKnYic4ebUISE
         bxIg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUjUxn1mbzLjML2R51YPxCE6BvKR93bM7IjcDaNAIHrJ9ftl2m0
	n4qTImsTxqjnPoCKFfbwdDgw+TxpUX5x5HTFExjcvY7GSXjf60yGWTmEQTIy3WgLpMT7Log1mX9
	Z4wTZKnE80mlI+ba1/RvcS9JSXPWS8jiCU40qMa/w/JLFmtI5Tey+1MBmbn4HHGUFdw==
X-Received: by 2002:a17:906:b80e:: with SMTP id dv14mr33097088ejb.157.1554265844573;
        Tue, 02 Apr 2019 21:30:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxOwjRszB9q7wGddKeDk1Pt2j7iEvUc/9HbX6WZNUjMUAs0eKi7eZUk/SgJojyt7zZFg7HH
X-Received: by 2002:a17:906:b80e:: with SMTP id dv14mr33097058ejb.157.1554265843619;
        Tue, 02 Apr 2019 21:30:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554265843; cv=none;
        d=google.com; s=arc-20160816;
        b=Mum5CtJEBPoVSue2lIPja7WkuUQ5m+nBs8+z7fhB37ArDQZs7Ag+TZUtkMWXguCjVE
         dHdqkjihP2a9LZ0Mil6xTiXyPT65EO3QNDwYPGD/2skNnQmVVfjNhZVXDIhLR9hfRzIH
         9fLghZdMekRkfxi3QSXHCVC3fJogpDXl66pMPLHq2Pjt+I4sHLE5Kcq+7qpUv5lOioDc
         1sGKdJUa/p2sx5LofZD6p8mbc8So1lz63clBRNvS/F6SW3PeE+QGOKN6c8IsINy34BMZ
         Xymh2yH1pktUSpRnUPeU38Z/zjmzo3BPeCcfMM9GepYrfARrVOgIcEjnBSs5LKKFUjDK
         17xg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=EkSxpVM4Bmt2ySq+et1fZS12TxWCefQIMkki4BSNv7E=;
        b=WsnW6vzg35jXPwsB6D/DQRQIYzjXB2EudekPcn5llXuP8VJu+nSOJEc01P7k7ngmfH
         jk+ZBEqAAWJnqUSFdv2QLg8euLmkvBqEgiBpcsVDrHzF8tlC7HsdkN7jOf6J/NPx6ry4
         Czysj/xtwcizEhr9trtdKf1onu2Nc8ijwDnFCBjcjioM2VJOmkKXQrbbE0NBZnMunxgK
         92x81kOakD0Y7QJFzuGYiPvcPBwxUVE7FpuqY2Q2kjlahUEKvN6J0k+iEmYffkgxsIkO
         bMN2qNTXLw1yEj29cDjCi1hkrcHpWrIT2hyXHuxvhVu9zUt2gb6gJhCtNvG4/b1tpIo7
         qQNw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id x28si4076547edm.210.2019.04.02.21.30.43
        for <linux-mm@kvack.org>;
        Tue, 02 Apr 2019 21:30:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 7FAC780D;
	Tue,  2 Apr 2019 21:30:42 -0700 (PDT)
Received: from p8cg001049571a15.arm.com (unknown [10.163.1.97])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 0E79E3F721;
	Tue,  2 Apr 2019 21:30:36 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org,
	akpm@linux-foundation.org,
	will.deacon@arm.com,
	catalin.marinas@arm.com
Cc: mhocko@suse.com,
	mgorman@techsingularity.net,
	james.morse@arm.com,
	mark.rutland@arm.com,
	robin.murphy@arm.com,
	cpandya@codeaurora.org,
	arunks@codeaurora.org,
	dan.j.williams@intel.com,
	osalvador@suse.de,
	logang@deltatee.com,
	pasha.tatashin@oracle.com,
	david@redhat.com,
	cai@lca.pw
Subject: [PATCH 5/6] mm/memremap: Rename and consolidate SECTION_SIZE
Date: Wed,  3 Apr 2019 10:00:05 +0530
Message-Id: <1554265806-11501-6-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
References: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Robin Murphy <robin.murphy@arm.com>

Enabling ZONE_DEVICE (through ARCH_HAS_ZONE_DEVICE) for arm64 reveals that
memremap's internal helpers for sparsemem sections conflict with arm64's
definitions for hugepages which inherit the name of "sections" from earlier
versions of the ARM architecture.

Disambiguate memremap by propagating sparsemem's PA_ prefix, to clarify
that these values are in terms of addresses rather than PFNs (and
because it's a heck of a lot easier than changing all the arch code).
SECTION_MASK is unused, so it can just go. While here consolidate single
instance of PA_SECTION_SIZE from mm/hmm.c as well.

[anshuman: Consolidated mm/hmm.c instance and updated the commit message]

Signed-off-by: Robin Murphy <robin.murphy@arm.com>
Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 include/linux/mmzone.h |  1 +
 kernel/memremap.c      | 10 ++++------
 mm/hmm.c               |  2 --
 3 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index fba7741..ed7dd27 100644
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
index a856cb5..dda1367 100644
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
index fe1cd87..ef9e4e6 100644
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
2.7.4

