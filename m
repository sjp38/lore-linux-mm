Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7F1EC43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 06:09:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91C082085A
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 06:09:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91C082085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4221D6B0007; Thu,  2 May 2019 02:09:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3D2A76B0008; Thu,  2 May 2019 02:09:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2C19A6B000A; Thu,  2 May 2019 02:09:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id EAB276B0007
	for <linux-mm@kvack.org>; Thu,  2 May 2019 02:09:20 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 63so698947pga.18
        for <linux-mm@kvack.org>; Wed, 01 May 2019 23:09:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=BXUMJAmAtU8I+1zy9esgkFAGeC72peX6yOy4TBwj0rc=;
        b=X6QswPuuaC5+V1Ppzh9oyFLmIToQQC5u8Uyts+rgowR3RyPQpKuvg4TWVwz816OhYT
         dCE0TojraAQxhp4izEH2SMx0SBHJ5NPMZsipx0aFxSzUrYOC8Ywz1Wx8Uu5i//2HQQPC
         N8Lhqw7bQmEcx3vYbidTieJZgyKiSxEisRcXOnuUOz+1qYv4vMLJ8ZlMN9O3XWEEtYzC
         rYOnZGaHDzI0/uad3/bdfmFlTw7Yc0s0UAsbP2puiyYtAZPxCIb834ft7d6qVJIpBV8i
         5LpsJCmTvQtpbERNtcYvmX7UmczbRjbQOviA7QwpBnXIIhBoK6ptmUDRqrWSBZwcjA/6
         24MQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX67NFqFNzY9/x3vxv7EfxKG82bpi3wp76AmnCDykCXCXqMzyiR
	VUxUNERVUXRQNPBvmHWNSyX8bFdwpCVvvA9DOpWmv8HpJRZEbcxGIyCXeem9w4/uIjb6uI99LhE
	ONdYOPpLEERSgdeJCPt+VY9HMwwtx29SdTYZHDxVHx6JYAuEOlsZ2Eiw9jqUvXrs5bA==
X-Received: by 2002:a17:902:4643:: with SMTP id o61mr1813163pld.95.1556777360613;
        Wed, 01 May 2019 23:09:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqywDAmfwLYqaHW58MpiLE0rZjNiF9gHJZr3suYTBECfTC7iY7QaVmClNaA+Q5T8rMX7MMK8
X-Received: by 2002:a17:902:4643:: with SMTP id o61mr1813094pld.95.1556777359887;
        Wed, 01 May 2019 23:09:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556777359; cv=none;
        d=google.com; s=arc-20160816;
        b=Y1TAT36HzLXdWTW3PDBfhBrGJJSVCz4K31MLaikr8O6BnuEvVdG0mzWX4hRj1xyuYY
         kqO5Q5pVK9mDoPd+s328+oyQ+Z+9AhUilJJlPBFo/v5L4TRRkokN88T+aP6eCPuaf2Mo
         VxDq8lo2MQM/N9w4LaoHN9Ahs9OSW5WIGLaDOCCorsh/NPR42WljPZCPsTbIc1zfken3
         BSORo6kv588vXsutRSaQ1cJtzCGUHX9zEu2JNbc0KSiR1kx0Wf7ON+9s6iwt64kADaBt
         FjzQLsYy5VNTmtW0cgyZ5dH1ifEd5SIQxqHfuTZIYUUBbtcrPvB9OsV/GfuAy0cSN5aX
         6YRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=BXUMJAmAtU8I+1zy9esgkFAGeC72peX6yOy4TBwj0rc=;
        b=NzaVDTNixYNlmnf1EWrqx2YOFc6Y6Av3tB0Q2IUuBfSIE4YpuVFV7rL2Xu9Gi9v+Mz
         zx0FS+gHkDBBw169s4FIVPNQxDO8IUv/PTZLEU81BrgeJcmGbbNQX9q7WlGfuss8LyUU
         NFe4Z0HmyklYJ6Zkwx6Ctv9mT50DL6Gh5ada1DGig8MjsYEDUvBFTPs5LDQZpfjGW6BX
         skL/uebmYipGaEh920FYx+LW9fJHOXkTk2hT8iCSnzY+EaWuw/CXw+SmnUNvLWuW+DFA
         GjcHS7cc/34BGN9XPe7z03H8cx/V53FdolMv+7mOeD81PF/d9YvGVkVvZgRrrmR/ILp9
         5lXw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id o12si39902078pgp.94.2019.05.01.23.09.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 May 2019 23:09:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 01 May 2019 23:09:19 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,420,1549958400"; 
   d="scan'208";a="136147452"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga007.jf.intel.com with ESMTP; 01 May 2019 23:09:18 -0700
Subject: [PATCH v7 02/12] mm/sparsemem: Introduce common definitions for the
 size and mask of a section
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>,
 =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
 Logan Gunthorpe <logang@deltatee.com>, linux-nvdimm@lists.01.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org, osalvador@suse.de,
 mhocko@suse.com
Date: Wed, 01 May 2019 22:55:32 -0700
Message-ID: <155677653274.2336373.11220321059915670288.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155677652226.2336373.8700273400832001094.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155677652226.2336373.8700273400832001094.stgit@dwillia2-desk3.amr.corp.intel.com>
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
 

