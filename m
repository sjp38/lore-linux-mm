Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29990C04AAB
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 23:53:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DAFB020830
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 23:53:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DAFB020830
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D53D6B0007; Mon,  6 May 2019 19:53:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5850C6B0008; Mon,  6 May 2019 19:53:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 49ABF6B000A; Mon,  6 May 2019 19:53:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1230E6B0007
	for <linux-mm@kvack.org>; Mon,  6 May 2019 19:53:25 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id a8so8973631pgq.22
        for <linux-mm@kvack.org>; Mon, 06 May 2019 16:53:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=8RNOIZV97NnexO1Jdc7vL45W3MhnWW1X7GLE26PcXAY=;
        b=VUXdSinlOQOI/KNAYauJmZzvpRcyozHkq6BP4SD1dygsBUrc0u4EdMJAC2+uEAh3VM
         YKqQGHh/xlWg8WsLp7vcRxvEuDzdku1YjNRF1yRNa+6DVkvfahYkJDFeHOU96pvSmUns
         VGT+qOMonqCNXnd7xQFNmj4C8Sm++A884WDy28eNlLCVvEPo7wdY/yZGbA6XlRMLqngq
         h+Ar81Z3jNm2UrFaziBxM6qgzPFOMcWthub5uRypS1Ol9RbYiCnhvu+lqdFBiy70gBVt
         L2MNCaV/VOB0gNxiaw61sMRRSegksT1KRqweR7BcCghxl4JfBK4vyVZSDtu2pF3v4sQo
         o33w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAV6/DvPI+bx5dkO4C0/sYjQKDYLKeMAQodRC9Y098BmeXnME1cV
	T7otnvMvqcEeoAd6+HNuAZRDkkJMabUodm633v9+sIW78CaCdNbUM0GYGD1xrSc79aDFKaWfSlp
	ZyPvp6JBk/++80lymGxtxfQj2vnrkC6r9h+3suvXVIgipI6hd+l+TDA2WJfoXPat0MA==
X-Received: by 2002:a17:902:2827:: with SMTP id e36mr35262945plb.45.1557186804707;
        Mon, 06 May 2019 16:53:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwyZXpIylgmKFGtIu0VZ5H88JKckfHVTEGSKa/tA6cXzlFOrXME1hctwTVq8g7kDqWiMfMe
X-Received: by 2002:a17:902:2827:: with SMTP id e36mr35262891plb.45.1557186803842;
        Mon, 06 May 2019 16:53:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557186803; cv=none;
        d=google.com; s=arc-20160816;
        b=laudWF1D35CBvR42xIH+nWYsMCjDaYkPB1SYU0Zt4xG0L2Ps5OHuwOKeQPsnIWK1gh
         /Hx1/D2p2zXEThllrbJw4ybtJqN3cKBqWAQ1z1QwZZqsL1b/YFbtx2VrOMj3B9CKV77n
         1P5KSu2Psv7Hq9TaYznYiNaJ7/6KzIM34KHk4n/TBudOqO2pm6wuE7/z3PlO4qLKIupi
         2bXeOUEiK21SCukpG7/TExLTtSnQzNziR+e1vLYJyaMLLjW7kZd2TDNT98pRWa2kFiW+
         +Zgor7Zk2lpX91Sz6mU7o/ROFdu34Xhv3p/K3MitPQu4OHj3cfkoBpub6K4gbwDZL6Rq
         J9nQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=8RNOIZV97NnexO1Jdc7vL45W3MhnWW1X7GLE26PcXAY=;
        b=pUqWpFaVewvLg0Vcy51L9Ze7wc5vEis2wP0bsMt1OQ85z710TOpP9wtWlUcgdOXRmf
         m9Dt7UlnIHC8zN43Yj+UVg3y1EMtwWmFqHxVFH8pHunH2L9zBCYZhiADKweLjeKzyINf
         mld3cDjDvJW0ThgF9PjgIJJe+7F7ojwW8xa/+8zpuJd+3oKrOBiUFcyl6/XQwJFjmhQB
         M0mwb9IHksw4UOhYEN50bQOFCBU4auRUKTqN6odwHxo5CpvUy4X70yDGTgLFW0g1lZha
         rpbRndLJQxQHYjhka7Xky6oOzV40lMhhbS2gEqyOITCQsal5KhM3oAf2K6Y7fyG6jh3J
         0hKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id z6si16989449plo.372.2019.05.06.16.53.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 16:53:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 May 2019 16:53:23 -0700
X-ExtLoop1: 1
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga002.jf.intel.com with ESMTP; 06 May 2019 16:53:23 -0700
Subject: [PATCH v8 02/12] mm/memremap: Rename and consolidate SECTION_SIZE
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, David Hildenbrand <david@redhat.com>,
 Oscar Salvador <osalvador@suse.de>, Pavel Tatashin <pasha.tatashin@soleen.com>,
 Robin Murphy <robin.murphy@arm.com>,
 Anshuman Khandual <anshuman.khandual@arm.com>, linux-nvdimm@lists.01.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org, osalvador@suse.de,
 mhocko@suse.com
Date: Mon, 06 May 2019 16:39:37 -0700
Message-ID: <155718597703.130019.5955560833756434949.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155718596657.130019.17139634728875079809.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155718596657.130019.17139634728875079809.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Robin Murphy <robin.murphy@arm.com>

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
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Signed-off-by: Robin Murphy <robin.murphy@arm.com>
Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/mmzone.h |    1 +
 kernel/memremap.c      |   10 ++++------
 mm/hmm.c               |    2 --
 3 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index ef8d878079f9..ac163f2f274f 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1134,6 +1134,7 @@ static inline unsigned long early_pfn_to_nid(unsigned long pfn)
  * PFN_SECTION_SHIFT		pfn to/from section number
  */
 #define PA_SECTION_SHIFT	(SECTION_SIZE_BITS)
+#define PA_SECTION_SIZE		(1UL << PA_SECTION_SHIFT)
 #define PFN_SECTION_SHIFT	(SECTION_SIZE_BITS - PAGE_SHIFT)
 
 #define NR_MEM_SECTIONS		(1UL << SECTIONS_SHIFT)
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 4e59d29245f4..f355586ea54a 100644
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
@@ -160,8 +158,8 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 	if (!pgmap->ref || !pgmap->kill)
 		return ERR_PTR(-EINVAL);
 
-	align_start = res->start & ~(SECTION_SIZE - 1);
-	align_size = ALIGN(res->start + resource_size(res), SECTION_SIZE)
+	align_start = res->start & ~(PA_SECTION_SIZE - 1);
+	align_size = ALIGN(res->start + resource_size(res), PA_SECTION_SIZE)
 		- align_start;
 	align_end = align_start + align_size - 1;
 
diff --git a/mm/hmm.c b/mm/hmm.c
index 0db8491090b8..a7e7f8e33c5f 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -34,8 +34,6 @@
 #include <linux/mmu_notifier.h>
 #include <linux/memory_hotplug.h>
 
-#define PA_SECTION_SIZE (1UL << PA_SECTION_SHIFT)
-
 #if IS_ENABLED(CONFIG_HMM_MIRROR)
 static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
 

