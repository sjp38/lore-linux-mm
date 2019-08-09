Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E252EC41514
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:59:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A24C8208C4
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:59:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A24C8208C4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E25026B0272; Fri,  9 Aug 2019 18:59:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB16D6B0273; Fri,  9 Aug 2019 18:59:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C26366B0274; Fri,  9 Aug 2019 18:59:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8AA136B0273
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 18:59:11 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id s13so2417023plp.7
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 15:59:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=dCSe5Gz/krwYGTrjnccnTjmL88HvXVG7GECluMxTUKQ=;
        b=MAYT/erEsp7Cj7rtez0UAUwgyDUbidrBalsyXkex4i9uW2wbFjx9qIriep49RKf7zy
         EQ+pMW028ccgsRlxuoJ1VQwN876PymtE6D5CAqCy9JlAQViQ7ZKAB0/6WClaCVuJ9DxY
         IcReBap8gV6+brtA5YrPQq7vRruomSFrtRDXIQ5qsPPxzMxz49PnPzkgFh1P+PrAcC3N
         sQfX0H6GSIWPeUdYfRg16jsHwV4urRozRd+Ep7Dd1y9E0BpicaC2W1JtnafuHhzS91Ek
         iUw1KakW5+ZnlAymTVEcDNZkcU4YiW9B1TvEVIzW75LnVgG9zf02d8tfBz/wYlMGXVSF
         xZLQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAW0k7nqEdx0n930Yy1D99EeLtVy8DyR6a3t9Ks2IbFyplf7N67M
	uFLLKIdcdmIxAe4PgGX+Ed7fj9TPTPSd1i2WQ+AvkdgObRGVoER8wadWE3v7Whn9Gv7c6xNaOV7
	Gb08V74GlTJPslTtAc/G2+ttliDrYjU6cmiRMDkBRhfl99V0GB8LvXntdr2rlpIcwtA==
X-Received: by 2002:a17:902:fe14:: with SMTP id g20mr20103223plj.54.1565391551212;
        Fri, 09 Aug 2019 15:59:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzsW+Cwbgc4KIYcDOgECOT3RyHn84PV81ceXilFeZ9ZGjWmMVELoOWTLnf2lA6rCio8OfgP
X-Received: by 2002:a17:902:fe14:: with SMTP id g20mr20103193plj.54.1565391550406;
        Fri, 09 Aug 2019 15:59:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565391550; cv=none;
        d=google.com; s=arc-20160816;
        b=XPjaJ5CgwS3JMdsyhMT5C7qRgTtF4Px+4Qgjf2VK2snsZB6mN5iugfVgVUiWlIP4zn
         IylvpuC7egSs2AuXv/8m6NXoqHdK/BLexZhizlxR9kYibscgDK/hLYjjRULuhr9wldyr
         Sd7HmCEKMEqcqrIPp1+NrKAjeojn7JJ0Pwj19fbLpoas1fXlMXnAbv0O75z7N0/dYWU1
         Aukn+wd37fqv5Wgp7Yeyn3vJV0SrOqTX3WQLI3km1ivRRSI6KiNc+X/Jba672ikN1vh3
         04qk2Qau8R5FXUiRAvk2KTuwDYdcoIii3X4ZSrXKwmo14VyUSm4kbFU7RWoyKvSb15CP
         LMng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=dCSe5Gz/krwYGTrjnccnTjmL88HvXVG7GECluMxTUKQ=;
        b=tgTKXFAPjPiytnrTRtGLUvMncFfibcX88B34iqwejil98XoIOutJZBM8vTKHzyq4Tl
         1UGOJypqUeMYXqTNoFyZAjLDm8sfwrSo7ekDWcMx7AyKaBGAEwmPY3XuPnrSIlcoO6Kv
         bgvu03Hp00p3B8h4tfevF4YSIV1W5T1qGyZqpSPAZiIAES4zF4U5EmcqslzLViwghWM+
         x0SzUubQqJyUgcGK+nS19/YO2QOqCLs6ZhNy/x7JAu54PxH2pUfn3xjREOcPQzcZ3sOA
         mKBAJiTBMUXKBYFbetN7+DZAUoxS5WLQZKY7460JauCLHXKp5k2C0gWayc6dR/NCPKaY
         E4rw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id x12si38312062pgq.220.2019.08.09.15.59.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 15:59:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 15:59:09 -0700
X-IronPort-AV: E=Sophos;i="5.64,367,1559545200"; 
   d="scan'208";a="183030881"
Received: from iweiny-desk2.sc.intel.com (HELO localhost) ([10.3.52.157])
  by fmsmga003-auth.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 15:59:09 -0700
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
Subject: [RFC PATCH v2 19/19] mm/gup: Remove FOLL_LONGTERM DAX exclusion
Date: Fri,  9 Aug 2019 15:58:33 -0700
Message-Id: <20190809225833.6657-20-ira.weiny@intel.com>
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

Now that there is a mechanism for users to safely take LONGTERM pins on
FS DAX pages, remove the FS DAX exclusion from the GUP implementation.

Special processing remains in effect for CONFIG_CMA

NOTE: Some callers still fail because the vaddr_pin information has not
been passed into the new interface.  As new users appear they can start
to use the new interface to support FS DAX.

Signed-off-by: Ira Weiny <ira.weiny@intel.com>
---
 mm/gup.c | 78 ++++++--------------------------------------------------
 1 file changed, 8 insertions(+), 70 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 6d23f70d7847..58f008a3c153 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1415,26 +1415,6 @@ static long __get_user_pages_locked(struct task_struct *tsk,
 }
 #endif /* !CONFIG_MMU */
 
-#if defined(CONFIG_FS_DAX) || defined (CONFIG_CMA)
-static bool check_dax_vmas(struct vm_area_struct **vmas, long nr_pages)
-{
-	long i;
-	struct vm_area_struct *vma_prev = NULL;
-
-	for (i = 0; i < nr_pages; i++) {
-		struct vm_area_struct *vma = vmas[i];
-
-		if (vma == vma_prev)
-			continue;
-
-		vma_prev = vma;
-
-		if (vma_is_fsdax(vma))
-			return true;
-	}
-	return false;
-}
-
 #ifdef CONFIG_CMA
 static struct page *new_non_cma_page(struct page *page, unsigned long private)
 {
@@ -1568,18 +1548,6 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
 
 	return nr_pages;
 }
-#else
-static long check_and_migrate_cma_pages(struct task_struct *tsk,
-					struct mm_struct *mm,
-					unsigned long start,
-					unsigned long nr_pages,
-					struct page **pages,
-					struct vm_area_struct **vmas,
-					unsigned int gup_flags)
-{
-	return nr_pages;
-}
-#endif /* CONFIG_CMA */
 
 /*
  * __gup_longterm_locked() is a wrapper for __get_user_pages_locked which
@@ -1594,49 +1562,28 @@ static long __gup_longterm_locked(struct task_struct *tsk,
 				  unsigned int gup_flags,
 				  struct vaddr_pin *vaddr_pin)
 {
-	struct vm_area_struct **vmas_tmp = vmas;
 	unsigned long flags = 0;
-	long rc, i;
+	long rc;
 
-	if (gup_flags & FOLL_LONGTERM) {
-		if (!pages)
-			return -EINVAL;
-
-		if (!vmas_tmp) {
-			vmas_tmp = kcalloc(nr_pages,
-					   sizeof(struct vm_area_struct *),
-					   GFP_KERNEL);
-			if (!vmas_tmp)
-				return -ENOMEM;
-		}
+	if (flags & FOLL_LONGTERM)
 		flags = memalloc_nocma_save();
-	}
 
 	rc = __get_user_pages_locked(tsk, mm, start, nr_pages, pages,
-				     vmas_tmp, NULL, gup_flags, vaddr_pin);
+				     vmas, NULL, gup_flags, vaddr_pin);
 
 	if (gup_flags & FOLL_LONGTERM) {
 		memalloc_nocma_restore(flags);
 		if (rc < 0)
 			goto out;
 
-		if (check_dax_vmas(vmas_tmp, rc)) {
-			for (i = 0; i < rc; i++)
-				put_page(pages[i]);
-			rc = -EOPNOTSUPP;
-			goto out;
-		}
-
 		rc = check_and_migrate_cma_pages(tsk, mm, start, rc, pages,
-						 vmas_tmp, gup_flags);
+						 vmas, gup_flags);
 	}
 
 out:
-	if (vmas_tmp != vmas)
-		kfree(vmas_tmp);
 	return rc;
 }
-#else /* !CONFIG_FS_DAX && !CONFIG_CMA */
+#else /* !CONFIG_CMA */
 static __always_inline long __gup_longterm_locked(struct task_struct *tsk,
 						  struct mm_struct *mm,
 						  unsigned long start,
@@ -1649,7 +1596,7 @@ static __always_inline long __gup_longterm_locked(struct task_struct *tsk,
 	return __get_user_pages_locked(tsk, mm, start, nr_pages, pages, vmas,
 				       NULL, flags, vaddr_pin);
 }
-#endif /* CONFIG_FS_DAX || CONFIG_CMA */
+#endif /* CONFIG_CMA */
 
 /*
  * This is the same as get_user_pages_remote(), just with a
@@ -1887,9 +1834,6 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 			goto pte_unmap;
 
 		if (pte_devmap(pte)) {
-			if (unlikely(flags & FOLL_LONGTERM))
-				goto pte_unmap;
-
 			pgmap = get_dev_pagemap(pte_pfn(pte), pgmap);
 			if (unlikely(!pgmap)) {
 				undo_dev_pagemap(nr, nr_start, pages);
@@ -2139,12 +2083,9 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
 	if (!pmd_access_permitted(orig, flags & FOLL_WRITE))
 		return 0;
 
-	if (pmd_devmap(orig)) {
-		if (unlikely(flags & FOLL_LONGTERM))
-			return 0;
+	if (pmd_devmap(orig))
 		return __gup_device_huge_pmd(orig, pmdp, addr, end, pages, nr,
 					     flags, vaddr_pin);
-	}
 
 	refs = 0;
 	page = pmd_page(orig) + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
@@ -2182,12 +2123,9 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
 	if (!pud_access_permitted(orig, flags & FOLL_WRITE))
 		return 0;
 
-	if (pud_devmap(orig)) {
-		if (unlikely(flags & FOLL_LONGTERM))
-			return 0;
+	if (pud_devmap(orig))
 		return __gup_device_huge_pud(orig, pudp, addr, end, pages, nr,
 					     flags, vaddr_pin);
-	}
 
 	refs = 0;
 	page = pud_page(orig) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
-- 
2.20.1

