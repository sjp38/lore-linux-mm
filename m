Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5055CC282DC
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 18:52:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0CC1A20663
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 18:52:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0CC1A20663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 876996B0007; Wed, 17 Apr 2019 14:52:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7FD9C6B0008; Wed, 17 Apr 2019 14:52:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6ECD36B000A; Wed, 17 Apr 2019 14:52:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 398D26B0007
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 14:52:53 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id s22so16012787plq.1
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 11:52:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=IWDyHzmpfGujcmr8kiUjBHNn9xrobFYl7Wt30dr8yPw=;
        b=e908Wd1kM0LiRMEMhpv/b/hgeJQNpY44Jh9uKQ8MWZxtQXVuVAgV1KCQ1fQPXa+sZo
         Ek+JJT76JWlMwDA5Hu//+bkdegjtU9xbwysjT2Xk7QpxDeXdBZpE5B9jLxL3VIeKr4IH
         WQekB/T3Z/3WimwDFpn9JxcHQxEfGMeS8UWICjfW9rP5F/VT5aCxFPt+TEk3MQuf61V1
         +cEed1G5ZZC3ZHnD/vG9KsO33fC71h5GEqIq+avfzYMg4BvGSz5TRwzhOJOYfXt1zZtN
         GK/ROA1RHUUPI9fekVLPGBlHu0I053ozY7JHWA9R8u8Sq1scnryi59bHQsZzXAzJ5tpP
         msrw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUCLaT3qMV+a6OwtXjiUXj5jrnubtTj/VaN+l3gzJPePrQ6GQxi
	GZWmcWMIHn/hoR30yLXfzEuyrEV3x2jrouU4oyQcQdn1oHfdDMsnJIgz/DT4ngPdcpTHMUadxN6
	Z1bdWRKvGRCbU7wJwCp8rRqIkB68nv27teRwQhSIU47hMgXMtbOGy6EmKsdeF1+ynxQ==
X-Received: by 2002:a17:902:7c01:: with SMTP id x1mr64847279pll.299.1555527172795;
        Wed, 17 Apr 2019 11:52:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/iuiKcAlBgEYdHqryF4Mkki6a87iM+SAHKEk4EZqyjw6GMB6Vld7Pabs4+EKHKX5xNJzx
X-Received: by 2002:a17:902:7c01:: with SMTP id x1mr64847233pll.299.1555527172107;
        Wed, 17 Apr 2019 11:52:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555527172; cv=none;
        d=google.com; s=arc-20160816;
        b=g3QJ5NY+4zAI3muIghfG6OHAm6r+OR/esIjcgQ75/6JRuilnMKrd6CEnagR1aEMhlv
         LtM7B6sGqBvPnvG/Vm2SgsPAwBFEJRdK0TXIRAx6wqOJCdiSq9E3n/bnWReDNa13Wlff
         uo9XnEs9T2dkSDh7cyiXYHTsxH5iKMov794W7Q7/yagPIKqiG3XB6rfMGhn99vktMeCG
         uKZ/xnTmSU/xgUPHLO4GRokI7lxwjyaCaAp/bwnj7V1ArEQ48qj5cXQhXjaa+SeI1Bdk
         HLY34ubIvVm66r+W720S2doDupJzpuX4FS/G7EqeWd8JlGP5pFSt15xwmOaywTBW3SJ+
         RLfg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=IWDyHzmpfGujcmr8kiUjBHNn9xrobFYl7Wt30dr8yPw=;
        b=bUAr+sciWIfuKG/68w4jqoUopPztdRPjy9FwLLmXI21JE1774l2Vsqkn6A5y98n0ql
         aQkalwCFNizyT/NmLYCRzvXITArFqAFZpDfobPCtcfokPgY46jG2A1tDCGVaRR5k4uWy
         dVLVcD836JeykyvQXV+Rfdvj2BNHC9nYeKUwInU01gqNcvbAlzHewcG8UqaGeOTe3nGB
         vBpZXiKC8rRN2WHIs0Um1v5W+fyyrQHMK0FRw0qN163a2UJogS0xBSIoiCw/CyZ6QLMx
         4wZN09WzQ8N7afJ74U2gNrK/cmyug+Cs8amOGHJmkMSRNQktoohuRt3pV1RPmwLlj/UK
         xaAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id f2si27881166pgc.182.2019.04.17.11.52.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 11:52:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Apr 2019 11:52:51 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,362,1549958400"; 
   d="scan'208";a="292403034"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga004.jf.intel.com with ESMTP; 17 Apr 2019 11:52:51 -0700
Subject: [PATCH v6 02/12] mm/sparsemem: Introduce common definitions for the
 size and mask of a section
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>,
 =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
 Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org,
 linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, mhocko@suse.com,
 david@redhat.com
Date: Wed, 17 Apr 2019 11:39:05 -0700
Message-ID: <155552634586.2015392.2662168839054356692.stgit@dwillia2-desk3.amr.corp.intel.com>
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
index f0bbd85dc19a..6726fc175b51 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1134,6 +1134,8 @@ static inline unsigned long early_pfn_to_nid(unsigned long pfn)
  * PFN_SECTION_SHIFT		pfn to/from section number
  */
 #define PA_SECTION_SHIFT	(SECTION_SIZE_BITS)
+#define PA_SECTION_SIZE		(1UL << PA_SECTION_SHIFT)
+#define PA_SECTION_MASK		(~(PA_SECTION_SIZE-1))
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
index ecd16718285e..def451a56c3e 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -34,8 +34,6 @@
 #include <linux/mmu_notifier.h>
 #include <linux/memory_hotplug.h>
 
-#define PA_SECTION_SIZE (1UL << PA_SECTION_SHIFT)
-
 #if IS_ENABLED(CONFIG_HMM_MIRROR)
 static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
 

