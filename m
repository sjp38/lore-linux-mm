Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51DC4C46460
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 04:54:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A3782087B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 04:54:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A3782087B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 402856B000D; Mon, 29 Apr 2019 00:54:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 327C56B000A; Mon, 29 Apr 2019 00:54:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 160316B000D; Mon, 29 Apr 2019 00:54:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C18166B000A
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 00:54:08 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id l13so6639242pgp.3
        for <linux-mm@kvack.org>; Sun, 28 Apr 2019 21:54:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=S+++yQqarWAPcVIwK3Wca+PUa2K/J8tS+1mZnBLISis=;
        b=SalkvS06dno7Ut6UonsNFtTN4xk4oJeBx/NbDzNiK5O2cqnuqFxwMYgtNJ4Q9/USuz
         BOLWDNVxtxQ59LmVPN6yziYrFdSnRPzGYUAnQeOqbX9gIpIlJxeEVi277vUJdMqDgcF5
         q1XnM4y/+ls8Av1RWmNvsLSpXKBy0Jat0GXGB4yZUEmwBO7Ns4ky3s3VyGx97R1yXTof
         HW6bzIp3/iWa8giFO9gW4Ka54JodGJVkK5OsVMHo6PC+e+4sWMc4ykxKcmOuerZr5jTt
         Yu4+1OLb1fYrALkyDbXNCAzAXkCSNKr4vDcLnsBPOxDikdU0eGHtjWFG6ukIq0f8x/Mg
         xdTw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXxdL6RBIGb2HAvyoK1ukW8TALh1plLgE8aQui9KiHjA+YPA0Op
	qE87vuaJyL8EE6NHmzROInqx8WaYPSJ89FSVpNZMBabTNpzEsuYEr4hgm0Z26jSF+EhOrkMM69/
	RoSeTmvq1CFOhfbx/DSBOJHEwfQrbWrzef8/49B5JN+Hd6NGB1xmJAugzibK4BbNTeQ==
X-Received: by 2002:a17:902:b403:: with SMTP id x3mr4596547plr.33.1556513648468;
        Sun, 28 Apr 2019 21:54:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWNCflRcNBd3/sC+fWFhCY4FCERcXSx0Ks2ptn3uj+q5HzN5ykT58W2VqukE4PhQGkeo/p
X-Received: by 2002:a17:902:b403:: with SMTP id x3mr4596514plr.33.1556513647719;
        Sun, 28 Apr 2019 21:54:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556513647; cv=none;
        d=google.com; s=arc-20160816;
        b=YMRTeq42jiKpvteFWkefokB+CvuqoeVws0gt2aR586MSuu91lemo22OYlXprGTN3rF
         mzVU++hTA2Xb6bAdsyix2Qmw+SxpS+hFbO/i8zDv9apq25E1hvwP+7XzBay9VpofVsiZ
         xUDWLVrOvkUTpvlsCof/Q3RjBNAZMjrCzdrR4G2Eff3bsi/sV+AKlvsRkfbB5KhEBlcm
         iwbwQwLz1tHYqEmavI5qk08SkglWi9FtvXurp32Gi86fEAE6qjo1d4Sl6T2gmQPixW62
         vLwolcsgQOJiuWnJcApRbgUYQ4YvP1dzB1lXUCbKNsv+yfEbk/stiHVPHibutSzM0BXJ
         xVHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=S+++yQqarWAPcVIwK3Wca+PUa2K/J8tS+1mZnBLISis=;
        b=Qw6uBW0FFvcRYNBnGDQbI14gkAIX3TtS+aJIELnv+CaMPqXpPWxeb0oYLi6PzYnFjg
         a8Ws8UymYS6Ibjehr2NY2SfQItngQq/N8U8YKcgVpYcoy8KTFMjSyEjGyJNlkAUOx/pR
         tcQPBQNVavQ9pCYhRa7KbDLlS7jVPYP6016mgk0R00pW+tDLi/OnUzQYH4ulSiOd+fh1
         oQTOcNw7J9+mn7L5Ksr06EJBCe4ihxbHEDpDMwSq1/S18FY8Z3dnRMOawbGrPUOXwzQl
         ByUhrTuZaD6wpsqJUvPHtUAqnTWaN1BXt3WE+HZk0MWa2nEJklNaXi5qeMoFdITAgZNz
         VjWA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id m184si14181099pfb.166.2019.04.28.21.54.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Apr 2019 21:54:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Apr 2019 21:54:07 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,408,1549958400"; 
   d="scan'208";a="146566285"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga003.jf.intel.com with ESMTP; 28 Apr 2019 21:54:06 -0700
From: ira.weiny@intel.com
To: lsf-pc@lists.linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Dan Williams <dan.j.williams@intel.com>,
	Jan Kara <jack@suse.cz>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@suse.com>,
	Ira Weiny <ira.weiny@intel.com>
Subject: [RFC PATCH 03/10] mm/gup: Pass flags down to __gup_device_huge* calls
Date: Sun, 28 Apr 2019 21:53:52 -0700
Message-Id: <20190429045359.8923-4-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190429045359.8923-1-ira.weiny@intel.com>
References: <20190429045359.8923-1-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

In order to support taking and/or checking for a LONGTERM lease on a FS
DAX inode these calls need to know if FOLL_LONGTERM was specified.

This patch passes the flags down but does not use them.  It does this in
prep for 2 future patches.
---
 mm/gup.c | 26 +++++++++++++++++---------
 1 file changed, 17 insertions(+), 9 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 42680823fbbe..a8ac75bc1452 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1853,7 +1853,8 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 
 #if defined(__HAVE_ARCH_PTE_DEVMAP) && defined(CONFIG_TRANSPARENT_HUGEPAGE)
 static int __gup_device_huge(unsigned long pfn, unsigned long addr,
-		unsigned long end, struct page **pages, int *nr)
+		unsigned long end, struct page **pages, int *nr,
+		unsigned int flags)
 {
 	int nr_start = *nr;
 	struct dev_pagemap *pgmap = NULL;
@@ -1886,30 +1887,33 @@ static int __gup_device_huge(unsigned long pfn, unsigned long addr,
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
@@ -1920,14 +1924,16 @@ static int __gup_device_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
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
@@ -1946,7 +1952,8 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
 	if (pmd_devmap(orig)) {
 		if (unlikely(flags & FOLL_LONGTERM))
 			return 0;
-		return __gup_device_huge_pmd(orig, pmdp, addr, end, pages, nr);
+		return __gup_device_huge_pmd(orig, pmdp, addr, end, pages, nr,
+					     flags);
 	}
 
 	refs = 0;
@@ -1988,7 +1995,8 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
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

