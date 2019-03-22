Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A92DC10F03
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 17:10:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB40C21917
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 17:10:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB40C21917
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A32F6B0007; Fri, 22 Mar 2019 13:10:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 452086B0008; Fri, 22 Mar 2019 13:10:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3685E6B000A; Fri, 22 Mar 2019 13:10:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id F3E656B0007
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 13:10:45 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id y2so2889168pfl.16
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 10:10:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=038kwI3sjgsCjDZLXeME3KWp2RPRkDZYPRJ4y9KN7nQ=;
        b=r3841CCF9dJYbPHbHtgjuV3+sYJEYCwVHNFfmY631eVf891xLtvIpQIyvf3mCAIU5l
         CbGhK6GsVuHGPPe1UtMy5qbXT1/GU4UbYIzVxypp37+lw0/jW2L65fB3IehmPg314KNt
         yjPuE3FoS+5APThQ5PnG/GCwWYGtCq0eooLeEs00PzlLrMwZmywhExxbV/i2kGXjVp27
         JlZ3QqhuhDBpRfe1NLtDuuxfzfxLYlCPqVsmirUXp09M/Y0KwKwSCK0/PNXT877Y06E9
         YNIJE18mwS18vyRBl6cfJBF1MXRnAqxc9gGZDVfmIl3BMGGaj/pVbaIuMnGGw7yp0xWu
         k5EA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVl549JrGS+fyPoFlSae1MxY3TCg4FeeR+u8Qk2cNzsmumFdxnS
	Rx4VNFF1OsHWZKqek6nt6vnXkC+vecyWN5KfT4qm1QJf5ywX6mIhBDUCV93hi05Ws/QLTNPFPzM
	SozjCyM486t/+VqBMUVv9jA2d8raVePIknntSLT0Jy9oAfunltZjwsS6VDZVrxV80vQ==
X-Received: by 2002:a63:4a5a:: with SMTP id j26mr2330555pgl.361.1553274645666;
        Fri, 22 Mar 2019 10:10:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxaLkxzZOLfCjqkLiKEqsZfkwSi8iH586qD0kY1aTZYn/5KvYRZPLY5QzNjXMB2wQUb3oMI
X-Received: by 2002:a63:4a5a:: with SMTP id j26mr2330493pgl.361.1553274644936;
        Fri, 22 Mar 2019 10:10:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553274644; cv=none;
        d=google.com; s=arc-20160816;
        b=Ei/faHONycM/u9ZPhvPwYZbSG89Q2/OPgYVs6vvZu1HDMDTAz6YjqKM7aYXklYYyui
         eWz9eXb6dbJdUNlee1JyrY1ItckDT0WUFO4P2LuLQ9YpgpU1WuqbYG1AeIIi7gb7JHjc
         PCuZYKqrze2a4JuND0Uv1CA3ao00kB5WacSEbYgV9JU215IeKm2Y5atEgIRwhHjVA7O/
         CCip8B5EWsugV3ciacKagPPw894aSyG0o0FrBlrSPtk6bmj0VKecHvjxUiHUwF/n9oT4
         xXlvA0JDH0OyhkjaTNZwIR/mjGXbbVAsBnD36C00+6rfrP5WrfnzMaZBlSWyf0Xfz49k
         O01Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=038kwI3sjgsCjDZLXeME3KWp2RPRkDZYPRJ4y9KN7nQ=;
        b=h34PPRonVLk7NUaRykWCXom1vvka38Si5Dps6PP+wAODv4Vb/lTIbi85YcFxfE6sbl
         gBXkNWQM3COK85tEdll/tfPgWVXJiMconhkpHdyCfCVklpGvwCH51gfcnFk3rjMrAY8H
         7JN/NCxDG7+Kf9B4Y/5lAOi2qHAQrdhfamknkkjMnkNwGevTLrGz9O/UcLmfP12W+t/u
         MrYMYIOHi8HgvWZdnorCxdhBs4JV+kMTULir/7yeGxrbRBBP0HiaPPvghaV27u0pXhxM
         g1icl5aCaCn/NdbCa/lp/z6CEXSe30bC6FQkC5UTmesIYWQMWizsoq9dBpRI5Y8Quf2X
         rihw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id l34si4179755pgb.574.2019.03.22.10.10.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 10:10:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Mar 2019 10:10:44 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,256,1549958400"; 
   d="scan'208";a="216629502"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga001.jf.intel.com with ESMTP; 22 Mar 2019 10:10:43 -0700
Subject: [PATCH v5 02/10] mm/sparsemem: Introduce common definitions for the
 size and mask of a section
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>,
 =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
 Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org,
 linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org
Date: Fri, 22 Mar 2019 09:58:05 -0700
Message-ID: <155327388517.225273.8517440825117584932.stgit@dwillia2-desk3.amr.corp.intel.com>
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

Up-level the local section size and mask from kernel/memremap.c to
global definitions.  These will be used by the new sub-section hotplug
support.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Logan Gunthorpe <logang@deltatee.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/mmzone.h |    2 ++
 kernel/memremap.c      |   10 ++++------
 mm/hmm.c               |    2 --
 3 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 151dd7327e0b..69b9cb9cb2ed 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1081,6 +1081,8 @@ static inline unsigned long early_pfn_to_nid(unsigned long pfn)
  * PFN_SECTION_SHIFT		pfn to/from section number
  */
 #define PA_SECTION_SHIFT	(SECTION_SIZE_BITS)
+#define PA_SECTION_SIZE		(1UL << PA_SECTION_SHIFT)
+#define PA_SECTION_MASK		(~(PA_SECTION_SIZE-1))
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
 

