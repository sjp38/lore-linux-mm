Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 030B0C28CC6
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 01:45:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB65720874
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 01:45:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB65720874
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 76FA86B0271; Wed,  5 Jun 2019 21:45:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6AB556B0272; Wed,  5 Jun 2019 21:45:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4AE006B0273; Wed,  5 Jun 2019 21:45:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0E7196B0271
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 21:45:15 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 91so515748pla.7
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 18:45:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=s7DWfafskOgsiBfZmagZult6DZudLkXSYifUFY2yeVQ=;
        b=Ujy0EVw/2mNN2DFgMz/atwOSxr8VWPkBUeTKSO3yZaXintHebkKVoaS2rwMzseSSXv
         2mAu8gjY/PoiFY09a8M5EHjJQaRiPJwpUKLCjriEd4Gy/ziEkxt8q1p0IJQvo+7OQjup
         n5p9dFRRo46Qn6aoqO57ZWshyh1Zu0wb9zQpVK39EH6UbRTaB410pL4YSbzWGT6vLxWF
         xmFOfxHpzOhVEuajsO74P4pVhDnaYvs7XP1xpWIFcqSxBQG80+kGdHWTRMMV1K0N63mC
         n169bfGsmRzyHXwgvIZFmpzIaakRRagFweItefZJg/MWSqBV69eBgHd3sU2s1L0uVZXU
         QuDA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAV8oSGuzrddlRb0LWopvgvTALbIM8Z7b+WUOONhu8VgssRkpNd6
	lkjjIAYnPL5ctJTiT2v04ijtYGTSQLj6kq0Xz6gFUmqyD58o5SEMXxKWlxqbpRmV/TFG2PVhXCa
	jpim61DJlHE6pjxyIJYAQU+2rRSMazfZjk2IR1kE47Rb8mzoR2nvIbyKQbjBj8sgUgQ==
X-Received: by 2002:a62:ac1a:: with SMTP id v26mr28070745pfe.184.1559785514723;
        Wed, 05 Jun 2019 18:45:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy791Qekwah8qsDN999usWnttKWNu08NFoNrveBohg2d2xJpskMelhybVa6krn8PWtoaSjJ
X-Received: by 2002:a62:ac1a:: with SMTP id v26mr28070693pfe.184.1559785513982;
        Wed, 05 Jun 2019 18:45:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559785513; cv=none;
        d=google.com; s=arc-20160816;
        b=sIIcOG+IlKgOxQcSUG4yI5sWbKtF/wk18fM2OiBVFx/F6EAmb5fBPnF1LKh5ApEyKA
         LWHtMK9jDMycKTH96Gk0xEymRDllxoYupqEgQYL5QzOORWmYZoqm7GqJkoImRw+iebXF
         YRtrqCoMDl+ZWYT6rE2o8xFXJyX4BKWpvPgs8tg3KHmj3nT800L41GaC+3wNouZ7XGpY
         ck890+9TamZvC9QWEwtEyil9rAwvCHvRNHZUQm5qiAgZ5mg4G/VNMQE8aMNcjba2NFGY
         GXSh0tcwjbv5tH4BqU6TbWp+QqUWr6CZ9VqW4SwesK73K41+5DesQqkp9Iv6/ANO6Fls
         tjyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=s7DWfafskOgsiBfZmagZult6DZudLkXSYifUFY2yeVQ=;
        b=fxQB6oIOdV3vXoSwxRz2/0rFpYNyXTotk6gziUB2fFpXD+bj54B4P+V4bHsQoY86WX
         4wT8NCwbsrAMZPHWYyqbUTTvYr3ojWNIRrey5p2BY0LeKipgkiefh/Aq1MchXfOXl8dN
         FvA6aJAnmWulYaTykPAwbygwp582w12hnRfFxUzrA6v4mSQ2BPvSndUj4F9AbKOtoQV/
         Le9LS93aCxYl5LCOJyC0uxlRPa7TpRULQOx9fMNo8O/KvybAzndqwgNj9hPLr6kPe9Hi
         dgHigvky7syx6vQR98XrGEsusINRRdj8U4sLe6thv0qnLZY+jGe70mLEtE+3Dm0sD+u/
         IKVg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id k18si276921pfk.103.2019.06.05.18.45.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 18:45:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Jun 2019 18:45:13 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga002.jf.intel.com with ESMTP; 05 Jun 2019 18:45:12 -0700
From: ira.weiny@intel.com
To: Dan Williams <dan.j.williams@intel.com>,
	Jan Kara <jack@suse.cz>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Jeff Layton <jlayton@kernel.org>,
	Dave Chinner <david@fromorbit.com>
Cc: Ira Weiny <ira.weiny@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-xfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org,
	linux-ext4@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH RFC 03/10] mm/gup: Pass flags down to __gup_device_huge* calls
Date: Wed,  5 Jun 2019 18:45:36 -0700
Message-Id: <20190606014544.8339-4-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190606014544.8339-1-ira.weiny@intel.com>
References: <20190606014544.8339-1-ira.weiny@intel.com>
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

Prepare for this with this patch.

Signed-off-by: Ira Weiny <ira.weiny@intel.com>
---
 mm/gup.c | 26 +++++++++++++++++---------
 1 file changed, 17 insertions(+), 9 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index a3fb48605836..26a7a3a3a657 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1939,7 +1939,8 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 
 #if defined(__HAVE_ARCH_PTE_DEVMAP) && defined(CONFIG_TRANSPARENT_HUGEPAGE)
 static int __gup_device_huge(unsigned long pfn, unsigned long addr,
-		unsigned long end, struct page **pages, int *nr)
+		unsigned long end, struct page **pages, int *nr,
+		unsigned int flags)
 {
 	int nr_start = *nr;
 	struct dev_pagemap *pgmap = NULL;
@@ -1969,30 +1970,33 @@ static int __gup_device_huge(unsigned long pfn, unsigned long addr,
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
@@ -2003,14 +2007,16 @@ static int __gup_device_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
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
@@ -2029,7 +2035,8 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
 	if (pmd_devmap(orig)) {
 		if (unlikely(flags & FOLL_LONGTERM))
 			return 0;
-		return __gup_device_huge_pmd(orig, pmdp, addr, end, pages, nr);
+		return __gup_device_huge_pmd(orig, pmdp, addr, end, pages, nr,
+					     flags);
 	}
 
 	refs = 0;
@@ -2072,7 +2079,8 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
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

