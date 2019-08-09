Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9F0AC32756
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:59:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5BA09208C4
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:59:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5BA09208C4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B9286B0269; Fri,  9 Aug 2019 18:58:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 96A416B026A; Fri,  9 Aug 2019 18:58:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 771806B026B; Fri,  9 Aug 2019 18:58:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 30DBD6B0269
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 18:58:59 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 21so62378538pfu.9
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 15:58:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=IYbL9R6/GsOg8Lm6+VjpJDRhe/AIP19VysgM8nkePVA=;
        b=I/36bnbGb2TpVQ/0iK297cV1AX8e3yq2J2Of48Avw5/UNnt9EOk2NYiE0RuJ7gPkLX
         E0BmJFScVxvPTMDxSxPYhUDH4Y/9pR6FJQUDPRqCHHL3mlSovhyWkd9Q5+uxiSFNOb05
         qgcnWaAmV4yz01TmmOqsdg+K28GW2A/Xo7rOWH+D1cuqqbfeWoY/ZrAMkAEoaDKUB9Ay
         +wmjTIfwRpVV0A7e++QkcA3/OS399vKVxr087OK/QM1fcRsj1inKRT+NbbejY03vzACA
         FYFy+yy+292t1ILZlxRZTPTGM+duTJ9AGXRE4vLeuUptHglZEdRAWOLT2SUyKpR+AxWN
         j7yQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUqbNSC0vhevF3obSb/n1O37029WcIso9I2jIu/MJqfZQiqhRMM
	TuPXRE3aMJMLXcmXl+B6c+hyRcIVh8JMk0x5oIiZ5EfFwzYTpD6ChIcZ+UsZ7PPR0WC/FMzJLjY
	vu2+gs+LV4WZ7m2YrPRe9816HME6OtGJNW9zpnlt36pqsuHS5DvhKxvkMKBn8LBPzIA==
X-Received: by 2002:a63:ea50:: with SMTP id l16mr19919721pgk.160.1565391538720;
        Fri, 09 Aug 2019 15:58:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxDt7v23iMpwzRLj8aqcdt/jfU4oASAEkBde5RkYCtUPBkh4OffmwVELF0WKdMGlgp0U5g/
X-Received: by 2002:a63:ea50:: with SMTP id l16mr19919656pgk.160.1565391537251;
        Fri, 09 Aug 2019 15:58:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565391537; cv=none;
        d=google.com; s=arc-20160816;
        b=if4LTJs494JYPBxo0HRFtxdUO85lNNXJbtdZEnnSYUIsmiqL5hBz1p/0ERMqMN0N9V
         EsdWNdnrZ0j2pVXRCJNPJrGzgYPmc+kCUL9GRT0tqzxjxRVYe8WoiUogD73vhvmrge5A
         gB7nHO7G68jaW6JH9bi6VxbFg50oJtXKAsxAqCx0zC18dffDhVuXHH+8xHGTGxlg8T86
         JOj4TOFskdMPLXkvGOLEERe8WrW2pGFDOwczcHlMdQcwg8OqU1FbiUWDuMHLMX0lJ9JB
         LV4lO9C/umsa0zcPWjAtV36zvdmoioXrnnqE6xYE6x288wFyrH6qHMJsmWpz0MoTU/aE
         ZtuA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=IYbL9R6/GsOg8Lm6+VjpJDRhe/AIP19VysgM8nkePVA=;
        b=W/O8TG7+pNQO1XKzhU1s1VOFsYBJj7ufkYxTY9y70F9dQbf02ZKDmFXfbyjh6zE8TF
         03Ym4tvXrqF7xDIcqpJnxF10rGZ1EMQzDbPJon9mx+Epch0EXQmbwnneTor5mHOOzE9i
         pa9h3ZS+3gQ/nOQAz0F569fqXLEUM6m26+Klc2O4lq2qGWqQiL8hZW1WR+j2+zZOJF89
         Hlw/4zmrw0QSvhrkXUwzYCfjeuTf0sYTO2p3NTEvkwQJZSnq5ZVNh95kqIesaw2WW1uD
         WdBj23COUwP56H8JNuIsqX0S85Agts7SxcQ4XoeBWHDbtampGzF4t4OTvyVC2m4XBXWC
         VZPw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id e17si22370683pgt.192.2019.08.09.15.58.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 15:58:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 15:58:56 -0700
X-IronPort-AV: E=Sophos;i="5.64,367,1559545200"; 
   d="scan'208";a="326762567"
Received: from iweiny-desk2.sc.intel.com (HELO localhost) ([10.3.52.157])
  by orsmga004-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 15:58:56 -0700
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
Subject: [RFC PATCH v2 10/19] mm/gup: Pass a NULL vaddr_pin through GUP fast
Date: Fri,  9 Aug 2019 15:58:24 -0700
Message-Id: <20190809225833.6657-11-ira.weiny@intel.com>
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

Internally GUP fast needs to know that fast users will not support file
pins.  Pass NULL for vaddr_pin through the fast call stack so that the
pin code can return an error if it encounters file backed memory within
the address range.

Signed-off-by: Ira Weiny <ira.weiny@intel.com>
---
 mm/gup.c | 65 ++++++++++++++++++++++++++++++++++----------------------
 1 file changed, 40 insertions(+), 25 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 7a449500f0a6..504af3e9a942 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1813,7 +1813,8 @@ static inline struct page *try_get_compound_head(struct page *page, int refs)
 
 #ifdef CONFIG_ARCH_HAS_PTE_SPECIAL
 static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
-			 unsigned int flags, struct page **pages, int *nr)
+			 unsigned int flags, struct page **pages, int *nr,
+			 struct vaddr_pin *vaddr_pin)
 {
 	struct dev_pagemap *pgmap = NULL;
 	int nr_start = *nr, ret = 0;
@@ -1894,7 +1895,8 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
  * useful to have gup_huge_pmd even if we can't operate on ptes.
  */
 static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
-			 unsigned int flags, struct page **pages, int *nr)
+			 unsigned int flags, struct page **pages, int *nr,
+			 struct vaddr_pin *vaddr_pin)
 {
 	return 0;
 }
@@ -1903,7 +1905,7 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 #if defined(CONFIG_ARCH_HAS_PTE_DEVMAP) && defined(CONFIG_TRANSPARENT_HUGEPAGE)
 static int __gup_device_huge(unsigned long pfn, unsigned long addr,
 		unsigned long end, struct page **pages, int *nr,
-		unsigned int flags)
+		unsigned int flags, struct vaddr_pin *vaddr_pin)
 {
 	int nr_start = *nr;
 	struct dev_pagemap *pgmap = NULL;
@@ -1938,13 +1940,14 @@ static int __gup_device_huge(unsigned long pfn, unsigned long addr,
 
 static int __gup_device_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
 		unsigned long end, struct page **pages, int *nr,
-		unsigned int flags)
+		unsigned int flags, struct vaddr_pin *vaddr_pin)
 {
 	unsigned long fault_pfn;
 	int nr_start = *nr;
 
 	fault_pfn = pmd_pfn(orig) + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
-	if (!__gup_device_huge(fault_pfn, addr, end, pages, nr, flags))
+	if (!__gup_device_huge(fault_pfn, addr, end, pages, nr, flags,
+			       vaddr_pin))
 		return 0;
 
 	if (unlikely(pmd_val(orig) != pmd_val(*pmdp))) {
@@ -1957,13 +1960,14 @@ static int __gup_device_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
 
 static int __gup_device_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
 		unsigned long end, struct page **pages, int *nr,
-		unsigned int flags)
+		unsigned int flags, struct vaddr_pin *vaddr_pin)
 {
 	unsigned long fault_pfn;
 	int nr_start = *nr;
 
 	fault_pfn = pud_pfn(orig) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
-	if (!__gup_device_huge(fault_pfn, addr, end, pages, nr, flags))
+	if (!__gup_device_huge(fault_pfn, addr, end, pages, nr, flags,
+			       vaddr_pin))
 		return 0;
 
 	if (unlikely(pud_val(orig) != pud_val(*pudp))) {
@@ -1975,7 +1979,7 @@ static int __gup_device_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
 #else
 static int __gup_device_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
 		unsigned long end, struct page **pages, int *nr,
-		unsigned int flags)
+		unsigned int flags, struct vaddr_pin *vaddr_pin)
 {
 	BUILD_BUG();
 	return 0;
@@ -1983,7 +1987,7 @@ static int __gup_device_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
 
 static int __gup_device_huge_pud(pud_t pud, pud_t *pudp, unsigned long addr,
 		unsigned long end, struct page **pages, int *nr,
-		unsigned int flags)
+		unsigned int flags, struct vaddr_pin *vaddr_pin)
 {
 	BUILD_BUG();
 	return 0;
@@ -2075,7 +2079,8 @@ static inline int gup_huge_pd(hugepd_t hugepd, unsigned long addr,
 #endif /* CONFIG_ARCH_HAS_HUGEPD */
 
 static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
-		unsigned long end, unsigned int flags, struct page **pages, int *nr)
+		unsigned long end, unsigned int flags, struct page **pages,
+		int *nr, struct vaddr_pin *vaddr_pin)
 {
 	struct page *head, *page;
 	int refs;
@@ -2087,7 +2092,7 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
 		if (unlikely(flags & FOLL_LONGTERM))
 			return 0;
 		return __gup_device_huge_pmd(orig, pmdp, addr, end, pages, nr,
-					     flags);
+					     flags, vaddr_pin);
 	}
 
 	refs = 0;
@@ -2117,7 +2122,8 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
 }
 
 static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
-		unsigned long end, unsigned int flags, struct page **pages, int *nr)
+		unsigned long end, unsigned int flags, struct page **pages, int *nr,
+		struct vaddr_pin *vaddr_pin)
 {
 	struct page *head, *page;
 	int refs;
@@ -2129,7 +2135,7 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
 		if (unlikely(flags & FOLL_LONGTERM))
 			return 0;
 		return __gup_device_huge_pud(orig, pudp, addr, end, pages, nr,
-					     flags);
+					     flags, vaddr_pin);
 	}
 
 	refs = 0;
@@ -2196,7 +2202,8 @@ static int gup_huge_pgd(pgd_t orig, pgd_t *pgdp, unsigned long addr,
 }
 
 static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
-		unsigned int flags, struct page **pages, int *nr)
+		unsigned int flags, struct page **pages, int *nr,
+		struct vaddr_pin *vaddr_pin)
 {
 	unsigned long next;
 	pmd_t *pmdp;
@@ -2220,7 +2227,7 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 				return 0;
 
 			if (!gup_huge_pmd(pmd, pmdp, addr, next, flags,
-				pages, nr))
+				pages, nr, vaddr_pin))
 				return 0;
 
 		} else if (unlikely(is_hugepd(__hugepd(pmd_val(pmd))))) {
@@ -2231,7 +2238,8 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 			if (!gup_huge_pd(__hugepd(pmd_val(pmd)), addr,
 					 PMD_SHIFT, next, flags, pages, nr))
 				return 0;
-		} else if (!gup_pte_range(pmd, addr, next, flags, pages, nr))
+		} else if (!gup_pte_range(pmd, addr, next, flags, pages, nr,
+					  vaddr_pin))
 			return 0;
 	} while (pmdp++, addr = next, addr != end);
 
@@ -2239,7 +2247,8 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 }
 
 static int gup_pud_range(p4d_t p4d, unsigned long addr, unsigned long end,
-			 unsigned int flags, struct page **pages, int *nr)
+			 unsigned int flags, struct page **pages, int *nr,
+			 struct vaddr_pin *vaddr_pin)
 {
 	unsigned long next;
 	pud_t *pudp;
@@ -2253,13 +2262,14 @@ static int gup_pud_range(p4d_t p4d, unsigned long addr, unsigned long end,
 			return 0;
 		if (unlikely(pud_huge(pud))) {
 			if (!gup_huge_pud(pud, pudp, addr, next, flags,
-					  pages, nr))
+					  pages, nr, vaddr_pin))
 				return 0;
 		} else if (unlikely(is_hugepd(__hugepd(pud_val(pud))))) {
 			if (!gup_huge_pd(__hugepd(pud_val(pud)), addr,
 					 PUD_SHIFT, next, flags, pages, nr))
 				return 0;
-		} else if (!gup_pmd_range(pud, addr, next, flags, pages, nr))
+		} else if (!gup_pmd_range(pud, addr, next, flags, pages, nr,
+					  vaddr_pin))
 			return 0;
 	} while (pudp++, addr = next, addr != end);
 
@@ -2267,7 +2277,8 @@ static int gup_pud_range(p4d_t p4d, unsigned long addr, unsigned long end,
 }
 
 static int gup_p4d_range(pgd_t pgd, unsigned long addr, unsigned long end,
-			 unsigned int flags, struct page **pages, int *nr)
+			 unsigned int flags, struct page **pages, int *nr,
+			 struct vaddr_pin *vaddr_pin)
 {
 	unsigned long next;
 	p4d_t *p4dp;
@@ -2284,7 +2295,8 @@ static int gup_p4d_range(pgd_t pgd, unsigned long addr, unsigned long end,
 			if (!gup_huge_pd(__hugepd(p4d_val(p4d)), addr,
 					 P4D_SHIFT, next, flags, pages, nr))
 				return 0;
-		} else if (!gup_pud_range(p4d, addr, next, flags, pages, nr))
+		} else if (!gup_pud_range(p4d, addr, next, flags, pages, nr,
+					  vaddr_pin))
 			return 0;
 	} while (p4dp++, addr = next, addr != end);
 
@@ -2292,7 +2304,8 @@ static int gup_p4d_range(pgd_t pgd, unsigned long addr, unsigned long end,
 }
 
 static void gup_pgd_range(unsigned long addr, unsigned long end,
-		unsigned int flags, struct page **pages, int *nr)
+		unsigned int flags, struct page **pages, int *nr,
+		struct vaddr_pin *vaddr_pin)
 {
 	unsigned long next;
 	pgd_t *pgdp;
@@ -2312,7 +2325,8 @@ static void gup_pgd_range(unsigned long addr, unsigned long end,
 			if (!gup_huge_pd(__hugepd(pgd_val(pgd)), addr,
 					 PGDIR_SHIFT, next, flags, pages, nr))
 				return;
-		} else if (!gup_p4d_range(pgd, addr, next, flags, pages, nr))
+		} else if (!gup_p4d_range(pgd, addr, next, flags, pages, nr,
+					  vaddr_pin))
 			return;
 	} while (pgdp++, addr = next, addr != end);
 }
@@ -2374,7 +2388,8 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	if (IS_ENABLED(CONFIG_HAVE_FAST_GUP) &&
 	    gup_fast_permitted(start, end)) {
 		local_irq_save(flags);
-		gup_pgd_range(start, end, write ? FOLL_WRITE : 0, pages, &nr);
+		gup_pgd_range(start, end, write ? FOLL_WRITE : 0, pages, &nr,
+			      NULL);
 		local_irq_restore(flags);
 	}
 
@@ -2445,7 +2460,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
 	if (IS_ENABLED(CONFIG_HAVE_FAST_GUP) &&
 	    gup_fast_permitted(start, end)) {
 		local_irq_disable();
-		gup_pgd_range(addr, end, gup_flags, pages, &nr);
+		gup_pgd_range(addr, end, gup_flags, pages, &nr, NULL);
 		local_irq_enable();
 		ret = nr;
 	}
-- 
2.20.1

