Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7079C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:59:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5940D21743
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:59:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5940D21743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E74686B026A; Fri,  9 Aug 2019 18:59:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E25F16B026B; Fri,  9 Aug 2019 18:59:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C2C2A6B026C; Fri,  9 Aug 2019 18:59:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 87C9F6B026A
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 18:59:01 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id b30so4454964pla.16
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 15:59:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=PjJDK8ia3RZCm4uOYMDrFLIGclr9bexVfc/3xOpYMjQ=;
        b=EyM055SGYjqb6588alSHhpd157dhQU23m/VQR0KWncxy0ATD10KQYI12ne9y5gA2fz
         1w0/WDu3LCljTn55ffzliA1jz2UGW5x5Gbhk0b/U+VSDuIcGihKWUpxbgS0er8ZuQDtx
         ng7eP03oAXaWQovW6Hneyi0jWxX76tp9DsqnH4LkgO2uf7Y+tmpbURVk12agOdOzu+Uh
         tozOqRPb1ot1qN5gTyK5YJYBRA3nXBH4NnGog6zVdYknE9ANaxKTeYXocAcHv0UtUTgj
         MioAwBWwZwikS7wVix7KvD9dFU2oqmEN35qMjhvirSPpfUirxC7/zMb4BYtdsXGkYkAs
         /ilA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWopeofWlGmwphG1zWC64peQXM6ma9SUFn8QUnROp2dGNdT9Ci+
	GNzSTFTmESCXJ+zu3VpRS85Cf8R7r9TPr6ffgU48sroZIzbdhgpBaSN7Njs6TQCHIPhNa5RW4JD
	vH4Bc+isKxjgGU2Ct8qteMTIuvCoU4GzjRWMbgcN9kVz4h+aT0QJMVif1Z9pT/IjKXQ==
X-Received: by 2002:aa7:9514:: with SMTP id b20mr24552743pfp.223.1565391541127;
        Fri, 09 Aug 2019 15:59:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzJnlcV1GQ8xYKcnGcSHx7qjRsRtrmJ4PlM6gu/7luhH0caQc46TshD5pu7Oqv5hn+EEPv+
X-Received: by 2002:aa7:9514:: with SMTP id b20mr24552670pfp.223.1565391539830;
        Fri, 09 Aug 2019 15:58:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565391539; cv=none;
        d=google.com; s=arc-20160816;
        b=K63gcS84CwfQRzJ4HE/lgBoRiFIMq00OZ1YyEu/AxGzm1gcF2Q3RQULkw/fiCfO8h1
         Be+kR67qi21iXVXoFdt3SXXRFlgb6AF8AWEJCGkBze+TWB1YA6SzR75NUowNHRhpetLB
         vocMmM/VjTh2BWsyLNUC7pbzYJxPQxTiDn+aO0jTLbkVghVZViVJhFoOjXIIv/muX0at
         EU/EvnUvZTVeObb2XxPVncTFFvHl3otjkz6WfcAo41OvF+tsh35W53ipkm8q9JtZ02/w
         0D4LFVATM4X4BGovVMgKZaP7AkLU0omv66dhK2SUPXlXzA71hxg+yrGVeuV2t5wLmbHX
         eEIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=PjJDK8ia3RZCm4uOYMDrFLIGclr9bexVfc/3xOpYMjQ=;
        b=P92egwU74i3t1kZH3P4kEN5BZn7vXBRNL40h3xN6O/qB7UFdlQtEXeI/XqUoWWp3Om
         +BkZXhJPJHTMNti00ZcXp1iZQOhCpTqishB5hmRzaUTBkmzUMjt+jEWQvch5VsEHfOf2
         0Q0Tnz34vcuMPbtusXIp/5IkpF83TDmVQ5+bS2zBq3snCSJxmaFq8eSlQFZUJx3JrVJw
         //U0E+Y5F9tnNDMnPeBTkffQyY06d01yYN9PvEi1QsdXoxsjHOmvclW/wejC8pFYYNU/
         uQJcG9PsSx3RGVi5YFd+ED+5za9oCp+2M9DMuBpwHg1C0c1kg/mHfqIzgnotzhtoRRJ8
         wWLg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 21si59278041pfo.138.2019.08.09.15.58.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 15:58:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 15:58:59 -0700
X-IronPort-AV: E=Sophos;i="5.64,367,1559545200"; 
   d="scan'208";a="177765523"
Received: from iweiny-desk2.sc.intel.com (HELO localhost) ([10.3.52.157])
  by orsmga003-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 15:58:58 -0700
From: ira.weiny@intel.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jason Gunthorpe <jgg@ziepe.ca>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Jan Kara <jack@suse.cz>,
	"Theodore Ts'o" <tytso@mit.edu>,
	John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@suse.com>,
	Dave Chinner <david@fromorbit.com>,
	linux-xfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-nvdimm@lists.01.org,
	linux-ext4@vger.kernel.org,
	linux-mm@kvack.org,
	Ira Weiny <ira.weiny@intel.com>
Subject: [RFC PATCH v2 11/19] mm/gup: Pass follow_page_context further down the call stack
Date: Fri,  9 Aug 2019 15:58:25 -0700
Message-Id: <20190809225833.6657-12-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190809225833.6657-1-ira.weiny@intel.com>
References: <20190809225833.6657-1-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

In preparation for passing more information (vaddr_pin) into
follow_page_pte(), follow_devmap_pud(), and follow_devmap_pmd().

Signed-off-by: Ira Weiny <ira.weiny@intel.com>
---
 include/linux/huge_mm.h | 17 -----------------
 mm/gup.c                | 31 +++++++++++++++----------------
 mm/huge_memory.c        |  6 ++++--
 mm/internal.h           | 28 ++++++++++++++++++++++++++++
 4 files changed, 47 insertions(+), 35 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 45ede62aa85b..b01a20ce0bb9 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -233,11 +233,6 @@ static inline int hpage_nr_pages(struct page *page)
 	return 1;
 }
 
-struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
-		pmd_t *pmd, int flags, struct dev_pagemap **pgmap);
-struct page *follow_devmap_pud(struct vm_area_struct *vma, unsigned long addr,
-		pud_t *pud, int flags, struct dev_pagemap **pgmap);
-
 extern vm_fault_t do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t orig_pmd);
 
 extern struct page *huge_zero_page;
@@ -375,18 +370,6 @@ static inline void mm_put_huge_zero_page(struct mm_struct *mm)
 	return;
 }
 
-static inline struct page *follow_devmap_pmd(struct vm_area_struct *vma,
-	unsigned long addr, pmd_t *pmd, int flags, struct dev_pagemap **pgmap)
-{
-	return NULL;
-}
-
-static inline struct page *follow_devmap_pud(struct vm_area_struct *vma,
-	unsigned long addr, pud_t *pud, int flags, struct dev_pagemap **pgmap)
-{
-	return NULL;
-}
-
 static inline bool thp_migration_supported(void)
 {
 	return false;
diff --git a/mm/gup.c b/mm/gup.c
index 504af3e9a942..a7a9d2f5278c 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -24,11 +24,6 @@
 
 #include "internal.h"
 
-struct follow_page_context {
-	struct dev_pagemap *pgmap;
-	unsigned int page_mask;
-};
-
 /**
  * put_user_pages_dirty_lock() - release and optionally dirty gup-pinned pages
  * @pages:  array of pages to be maybe marked dirty, and definitely released.
@@ -172,8 +167,9 @@ static inline bool can_follow_write_pte(pte_t pte, unsigned int flags)
 
 static struct page *follow_page_pte(struct vm_area_struct *vma,
 		unsigned long address, pmd_t *pmd, unsigned int flags,
-		struct dev_pagemap **pgmap)
+		struct follow_page_context *ctx)
 {
+	struct dev_pagemap **pgmap = &ctx->pgmap;
 	struct mm_struct *mm = vma->vm_mm;
 	struct page *page;
 	spinlock_t *ptl;
@@ -363,13 +359,13 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
 	}
 	if (pmd_devmap(pmdval)) {
 		ptl = pmd_lock(mm, pmd);
-		page = follow_devmap_pmd(vma, address, pmd, flags, &ctx->pgmap);
+		page = follow_devmap_pmd(vma, address, pmd, flags, ctx);
 		spin_unlock(ptl);
 		if (page)
 			return page;
 	}
 	if (likely(!pmd_trans_huge(pmdval)))
-		return follow_page_pte(vma, address, pmd, flags, &ctx->pgmap);
+		return follow_page_pte(vma, address, pmd, flags, ctx);
 
 	if ((flags & FOLL_NUMA) && pmd_protnone(pmdval))
 		return no_page_table(vma, flags);
@@ -389,7 +385,7 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
 	}
 	if (unlikely(!pmd_trans_huge(*pmd))) {
 		spin_unlock(ptl);
-		return follow_page_pte(vma, address, pmd, flags, &ctx->pgmap);
+		return follow_page_pte(vma, address, pmd, flags, ctx);
 	}
 	if (flags & (FOLL_SPLIT | FOLL_SPLIT_PMD)) {
 		int ret;
@@ -419,7 +415,7 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
 		}
 
 		return ret ? ERR_PTR(ret) :
-			follow_page_pte(vma, address, pmd, flags, &ctx->pgmap);
+			follow_page_pte(vma, address, pmd, flags, ctx);
 	}
 	page = follow_trans_huge_pmd(vma, address, pmd, flags);
 	spin_unlock(ptl);
@@ -456,7 +452,7 @@ static struct page *follow_pud_mask(struct vm_area_struct *vma,
 	}
 	if (pud_devmap(*pud)) {
 		ptl = pud_lock(mm, pud);
-		page = follow_devmap_pud(vma, address, pud, flags, &ctx->pgmap);
+		page = follow_devmap_pud(vma, address, pud, flags, ctx);
 		spin_unlock(ptl);
 		if (page)
 			return page;
@@ -786,7 +782,8 @@ static int check_vma_flags(struct vm_area_struct *vma, unsigned long gup_flags)
 static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		unsigned long start, unsigned long nr_pages,
 		unsigned int gup_flags, struct page **pages,
-		struct vm_area_struct **vmas, int *nonblocking)
+		struct vm_area_struct **vmas, int *nonblocking,
+		struct vaddr_pin *vaddr_pin)
 {
 	long ret = 0, i = 0;
 	struct vm_area_struct *vma = NULL;
@@ -797,6 +794,8 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 
 	VM_BUG_ON(!!pages != !!(gup_flags & FOLL_GET));
 
+	ctx.vaddr_pin = vaddr_pin;
+
 	/*
 	 * If FOLL_FORCE is set then do not force a full fault as the hinting
 	 * fault information is unrelated to the reference behaviour of a task
@@ -1025,7 +1024,7 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 	lock_dropped = false;
 	for (;;) {
 		ret = __get_user_pages(tsk, mm, start, nr_pages, flags, pages,
-				       vmas, locked);
+				       vmas, locked, vaddr_pin);
 		if (!locked)
 			/* VM_FAULT_RETRY couldn't trigger, bypass */
 			return ret;
@@ -1068,7 +1067,7 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 		lock_dropped = true;
 		down_read(&mm->mmap_sem);
 		ret = __get_user_pages(tsk, mm, start, 1, flags | FOLL_TRIED,
-				       pages, NULL, NULL);
+				       pages, NULL, NULL, vaddr_pin);
 		if (ret != 1) {
 			BUG_ON(ret > 1);
 			if (!pages_done)
@@ -1226,7 +1225,7 @@ long populate_vma_page_range(struct vm_area_struct *vma,
 	 * not result in a stack expansion that recurses back here.
 	 */
 	return __get_user_pages(current, mm, start, nr_pages, gup_flags,
-				NULL, NULL, nonblocking);
+				NULL, NULL, nonblocking, NULL);
 }
 
 /*
@@ -1311,7 +1310,7 @@ struct page *get_dump_page(unsigned long addr)
 
 	if (__get_user_pages(current, current->mm, addr, 1,
 			     FOLL_FORCE | FOLL_DUMP | FOLL_GET, &page, &vma,
-			     NULL) < 1)
+			     NULL, NULL) < 1)
 		return NULL;
 	flush_cache_page(vma, addr, page_to_pfn(page));
 	return page;
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index bc1a07a55be1..7e09f2f17ed8 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -916,8 +916,9 @@ static void touch_pmd(struct vm_area_struct *vma, unsigned long addr,
 }
 
 struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
-		pmd_t *pmd, int flags, struct dev_pagemap **pgmap)
+		pmd_t *pmd, int flags, struct follow_page_context *ctx)
 {
+	struct dev_pagemap **pgmap = &ctx->pgmap;
 	unsigned long pfn = pmd_pfn(*pmd);
 	struct mm_struct *mm = vma->vm_mm;
 	struct page *page;
@@ -1068,8 +1069,9 @@ static void touch_pud(struct vm_area_struct *vma, unsigned long addr,
 }
 
 struct page *follow_devmap_pud(struct vm_area_struct *vma, unsigned long addr,
-		pud_t *pud, int flags, struct dev_pagemap **pgmap)
+		pud_t *pud, int flags, struct follow_page_context *ctx)
 {
+	struct dev_pagemap **pgmap = &ctx->pgmap;
 	unsigned long pfn = pud_pfn(*pud);
 	struct mm_struct *mm = vma->vm_mm;
 	struct page *page;
diff --git a/mm/internal.h b/mm/internal.h
index 0d5f720c75ab..46ada5279856 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -12,6 +12,34 @@
 #include <linux/pagemap.h>
 #include <linux/tracepoint-defs.h>
 
+struct follow_page_context {
+	struct dev_pagemap *pgmap;
+	unsigned int page_mask;
+	struct vaddr_pin *vaddr_pin;
+};
+
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
+		pmd_t *pmd, int flags, struct follow_page_context *ctx);
+struct page *follow_devmap_pud(struct vm_area_struct *vma, unsigned long addr,
+		pud_t *pud, int flags, struct follow_page_context *ctx);
+#else
+static inline struct page *follow_devmap_pmd(struct vm_area_struct *vma,
+	unsigned long addr, pmd_t *pmd, int flags,
+	struct follow_page_context *ctx)
+{
+	return NULL;
+}
+
+static inline struct page *follow_devmap_pud(struct vm_area_struct *vma,
+	unsigned long addr, pud_t *pud, int flags,
+	struct follow_page_context *ctx)
+{
+	return NULL;
+}
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+
+
 /*
  * The set of flags that only affect watermark checking and reclaim
  * behaviour. This is used by the MM to obey the caller constraints
-- 
2.20.1

