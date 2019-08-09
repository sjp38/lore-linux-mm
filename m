Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4602AC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:58:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 03751208C4
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:58:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03751208C4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0461E6B0008; Fri,  9 Aug 2019 18:58:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E4E7E6B000A; Fri,  9 Aug 2019 18:58:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D16CC6B000C; Fri,  9 Aug 2019 18:58:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 992F66B0008
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 18:58:46 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id q67so2583087pfc.10
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 15:58:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=kI6c4a62ifA21eFJIjI6cgtgJg208C1izl/S8s1k1Lg=;
        b=jjETGhSdndlDiV/ywvSWPyYXGmNcjAc4kQMbhJLgjKutOMkyQ2R3Np1RVQ96TmFoop
         PWN2o7vcWlBqI3b5hInA77YHstVS/2ovwEN32M6Kp1TOUTHrtV0vnjZIWJYecS22FtaN
         Bkp+AqtwZFfjsXJy8u4STzKzfyDaRrSf+U1B/jMBHfZW+MYSRLz/lxLiSEhKjIHkVZri
         lnIBc0S6mQEQ9efH3fRvOs4wZ9EaRGj0iV+YdfTsok8QoV3LoTr1/UFwtK82xcqf9bNE
         RZ0dhS4ndp6QAKwForhAwM65aGFLbObFd8NoxPLsqRZQ2nJgbE8MHagGVadWUxnC+qQz
         8ZFA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXgLMn5TAtG5TCh0ZxTBHUzLqHk0QyXcqFG2ubALsVqfAIi2OEY
	rt0T4a2mNwESRNkTk0b1WNsyE/xo9yBB5QaX8ZUKsIA8W0ljYblie80aICKygGxL9O5cpS+hDHb
	CZNG77/OHI5LlkQQ72z3eI7yyjTWS72mYFI8rqa6UHh4h8pq3h+vhNJn1yv4wwGxDVg==
X-Received: by 2002:a65:5188:: with SMTP id h8mr19464304pgq.294.1565391526224;
        Fri, 09 Aug 2019 15:58:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyCJeCr5PEJCh99HXj5KAaResUKAtaXn6ccUKI7IiRXPTG2rcDpkl1ZUs3oQ8QVQcCfgs8Q
X-Received: by 2002:a65:5188:: with SMTP id h8mr19464272pgq.294.1565391525431;
        Fri, 09 Aug 2019 15:58:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565391525; cv=none;
        d=google.com; s=arc-20160816;
        b=SbTQ4vKii5/sYWj8kCfALpq8kHa7C5r+WOu8UvnvQPCZJhoCD+Nta6yjUs6oaxfIG5
         j/W9P5xr3j3NBtqViyDxDO/OcY1X1aFZ8LbkOVirFulq2qVK4OTGWWyfPwwqfVcdzTXZ
         jhd0hLLb01mKeBWjvc7sq9Xc7ZxAulX74bAOcLYp624AiHjbz3+c9ScijRVkKMeiaYP6
         aIGMMUdh+oioOigfHwJN49SF5XWvpKb114PgStLogG+wGAyp0AWpQ8Q7DuA1nwC9oiw4
         hPpxwYWiUDqM1eT7UqZyJvJR8q0isZx0EXirfiGexOMFAQXeEdKWlDsGeLedYNNkR410
         YafQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=kI6c4a62ifA21eFJIjI6cgtgJg208C1izl/S8s1k1Lg=;
        b=0/p2y3KOuheA32Uw9l6Bg3/MleFZvpawimts5iN4/6GO/RIJ2xMTfWkWm2ntlbpX+e
         hDZbZnyMQ9x9WhBv1NFfc8dpln1R26xSgVNeCVVJgCZen57gLe1JGbQKoGeBT6SPkS66
         D5BQRK7qrnBLkvXMF0gtrZD57J3w0qQOwZ9OO+deAws89ZxuraxAZDBQq6v54i1COcZm
         /Egk7UNyElkdq5klSRFepd7+IInUr8XJ1sA3HodYPB8EoMiCXpDnDI11OV6DXVfneFaT
         R/AEzPhgxbYLivCNIuUpdsejE3Yc+renDr3ABfM2PokM4BzJp/y99ZZqCyVMUFOMEaBY
         me/g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id k22si25962862pfi.289.2019.08.09.15.58.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 15:58:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 15:58:45 -0700
X-IronPort-AV: E=Sophos;i="5.64,367,1559545200"; 
   d="scan'208";a="183030758"
Received: from iweiny-desk2.sc.intel.com (HELO localhost) ([10.3.52.157])
  by fmsmga003-auth.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 15:58:44 -0700
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
Subject: [RFC PATCH v2 03/19] mm/gup: Pass flags down to __gup_device_huge* calls
Date: Fri,  9 Aug 2019 15:58:17 -0700
Message-Id: <20190809225833.6657-4-ira.weiny@intel.com>
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

In order to support checking for a layout lease on a FS DAX inode these
calls need to know if FOLL_LONGTERM was specified.

Signed-off-by: Ira Weiny <ira.weiny@intel.com>
---
 mm/gup.c | 26 +++++++++++++++++---------
 1 file changed, 17 insertions(+), 9 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index b6a293bf1267..80423779a50a 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1881,7 +1881,8 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 
 #if defined(CONFIG_ARCH_HAS_PTE_DEVMAP) && defined(CONFIG_TRANSPARENT_HUGEPAGE)
 static int __gup_device_huge(unsigned long pfn, unsigned long addr,
-		unsigned long end, struct page **pages, int *nr)
+		unsigned long end, struct page **pages, int *nr,
+		unsigned int flags)
 {
 	int nr_start = *nr;
 	struct dev_pagemap *pgmap = NULL;
@@ -1907,30 +1908,33 @@ static int __gup_device_huge(unsigned long pfn, unsigned long addr,
 }
 
 static int __gup_device_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
-		unsigned long end, struct page **pages, int *nr)
+		unsigned long end, struct page **pages, int *nr,
+		unsigned int flags)
 {
 	unsigned long fault_pfn;
 	int nr_start = *nr;
 
 	fault_pfn = pmd_pfn(orig) + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
-	if (!__gup_device_huge(fault_pfn, addr, end, pages, nr))
+	if (!__gup_device_huge(fault_pfn, addr, end, pages, nr, flags))
 		return 0;
 
 	if (unlikely(pmd_val(orig) != pmd_val(*pmdp))) {
 		undo_dev_pagemap(nr, nr_start, pages);
 		return 0;
 	}
+
 	return 1;
 }
 
 static int __gup_device_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
-		unsigned long end, struct page **pages, int *nr)
+		unsigned long end, struct page **pages, int *nr,
+		unsigned int flags)
 {
 	unsigned long fault_pfn;
 	int nr_start = *nr;
 
 	fault_pfn = pud_pfn(orig) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
-	if (!__gup_device_huge(fault_pfn, addr, end, pages, nr))
+	if (!__gup_device_huge(fault_pfn, addr, end, pages, nr, flags))
 		return 0;
 
 	if (unlikely(pud_val(orig) != pud_val(*pudp))) {
@@ -1941,14 +1945,16 @@ static int __gup_device_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
 }
 #else
 static int __gup_device_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
-		unsigned long end, struct page **pages, int *nr)
+		unsigned long end, struct page **pages, int *nr,
+		unsigned int flags)
 {
 	BUILD_BUG();
 	return 0;
 }
 
 static int __gup_device_huge_pud(pud_t pud, pud_t *pudp, unsigned long addr,
-		unsigned long end, struct page **pages, int *nr)
+		unsigned long end, struct page **pages, int *nr,
+		unsigned int flags)
 {
 	BUILD_BUG();
 	return 0;
@@ -2051,7 +2057,8 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
 	if (pmd_devmap(orig)) {
 		if (unlikely(flags & FOLL_LONGTERM))
 			return 0;
-		return __gup_device_huge_pmd(orig, pmdp, addr, end, pages, nr);
+		return __gup_device_huge_pmd(orig, pmdp, addr, end, pages, nr,
+					     flags);
 	}
 
 	refs = 0;
@@ -2092,7 +2099,8 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
 	if (pud_devmap(orig)) {
 		if (unlikely(flags & FOLL_LONGTERM))
 			return 0;
-		return __gup_device_huge_pud(orig, pudp, addr, end, pages, nr);
+		return __gup_device_huge_pud(orig, pudp, addr, end, pages, nr,
+					     flags);
 	}
 
 	refs = 0;
-- 
2.20.1

