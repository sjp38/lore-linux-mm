Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF1F3C10F03
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 16:45:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8BC712183F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 16:45:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8BC712183F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E9AB6B000E; Thu, 28 Mar 2019 12:45:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 79AA46B0266; Thu, 28 Mar 2019 12:45:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 617006B0269; Thu, 28 Mar 2019 12:45:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1E4AA6B000E
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 12:45:40 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id j10so16753194pfn.13
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 09:45:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=pKhbha+WUywohFctCak1tUkuN6pFAwfalpdwTGtV4f4=;
        b=GIvFGPMHsfupF6F7+2DvrvAejL1vFwr9Njzee9r05POvWSykIhQ7PU/0k4GEsQ8lcb
         WeT3o4ME0cnRJdrCn3PLFJZsSpRZNuddyJVjeLgKZHQbM7ZiMLa6xtpNB8gcnYW4BK/U
         Mmu3cRDsc23aifGJh7cZgATLwKo3qq3snI9vAcopxKi613f+IUpA1nNfVAmXMmBUbF1T
         jgKXTFe8iu5LDk96QM2vwvtgid4gaoYQ463ipXvjm2t32qqTvzVuK0rWjpo+fjSh742G
         47zYQS171LrK+Lx50DUQRZ+pckoQPRZALSNlbdIMNHK0Aa1hjvblJUIsfSkogOcsJrqk
         ZJZQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVXxQ6E1YNKI+F/S6au3ApNVKl9zBZ+WSOj9qmk96H83hJj32ph
	OxhNqqwyi0BIhDdDGdA9fNPOFnXglmXe2s8dzmg1myth+RTZLVEz/Fe6/npFQd4TDq9jkhlo/cd
	AMGIkHeDPHBZDL9+iaFr0CjBxW8vOYx1Zstt23Ld3nS8W/TZAE0LPy3znTO/gt4yYoQ==
X-Received: by 2002:a17:902:a98c:: with SMTP id bh12mr42842720plb.289.1553791539796;
        Thu, 28 Mar 2019 09:45:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxc0HRVhCRU+UYbe1jm+xthHTvztDtBvAOS00LAm6aB5xfBESxlnkou+3LurX8D35QdIj1b
X-Received: by 2002:a17:902:a98c:: with SMTP id bh12mr42842665plb.289.1553791538968;
        Thu, 28 Mar 2019 09:45:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553791538; cv=none;
        d=google.com; s=arc-20160816;
        b=CqisNXklGwv8GC9VlXb8kDH3mlPN4x5F05cI5MS9BV3lFMl/8l3KNi6oFwKJopmjAB
         MZ81OmHLFDCU0cgZdpJc5LbU7hOdUlWKOXFSWtipjhXUgo1k0rSx381yQYDXM7iTKJdn
         PCUlOCxEt9poLzcFbB+RGckWlG02TVbsVch+iJSJWXGraPMcrbMgBizSjj9QFUm9cwRB
         wfN5JW9HPJIajdZR49OiFp0fB0EvOSbbW9SOtyMMu+mPRnee3E0KbNduEMP+bf9FXIpJ
         qkMyjiktwkB/5M6iCVn63vR/vvci8Gjk+u+r1kUYEbNiT+IHpjvkilxQUCknO7UNsq5S
         TkPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=pKhbha+WUywohFctCak1tUkuN6pFAwfalpdwTGtV4f4=;
        b=lN2hDvAoQS0poZo9J4zM3ASY80sDX0ucp7Wc0/zEe5r0YX2ndWtcO5uwksthNgWXZZ
         i10eKbOaITqN9kyaOU6G5vswlOYJkLPOL+zX8IEDwV7sxr+uvQ5BAahIDE6VSbxiOSmt
         f2neK8lp4a3Y2yB6rM96ynIMf5upKxc/bXM9TxGYzIOFUOudKD0DOiQTauoUjOgo5xWl
         0C0qkfpfm5mCfX4EMY0NDygC4hr9haa8L9mDubrsFdn+tRPpIcS+8T8n6y8q8XP+6Tkw
         5eBZJaVyXXJ2HnkNJyB90+U62fwIhMmlgCuW5qrqYHbUVQLWUVs8Cn1ize3LZprdO2ZF
         HVYA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 31si22686092plb.39.2019.03.28.09.45.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 09:45:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Mar 2019 09:45:36 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,281,1549958400"; 
   d="scan'208";a="218460206"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga001.jf.intel.com with ESMTP; 28 Mar 2019 09:45:37 -0700
From: ira.weiny@intel.com
To: Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@suse.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Rich Felker <dalias@libc.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	Ralf Baechle <ralf@linux-mips.org>,
	James Hogan <jhogan@kernel.org>
Cc: Ira Weiny <ira.weiny@intel.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-mips@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org
Subject: [PATCH V3 4/7] mm/gup: Add FOLL_LONGTERM capability to GUP fast
Date: Thu, 28 Mar 2019 01:44:19 -0700
Message-Id: <20190328084422.29911-5-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190328084422.29911-1-ira.weiny@intel.com>
References: <20190328084422.29911-1-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

DAX pages were previously unprotected from longterm pins when users
called get_user_pages_fast().

Use the new FOLL_LONGTERM flag to check for DEVMAP pages and fall
back to regular GUP processing if a DEVMAP page is encountered.

Signed-off-by: Ira Weiny <ira.weiny@intel.com>

---
Changes from V2:
	Add comment on special use case of FOLL_LONGTERM

 mm/gup.c | 40 ++++++++++++++++++++++++++++++++++++----
 1 file changed, 36 insertions(+), 4 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 0fa7244d6f19..567bd1b295f0 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1613,6 +1613,9 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 			goto pte_unmap;
 
 		if (pte_devmap(pte)) {
+			if (unlikely(flags & FOLL_LONGTERM))
+				goto pte_unmap;
+
 			pgmap = get_dev_pagemap(pte_pfn(pte), pgmap);
 			if (unlikely(!pgmap)) {
 				undo_dev_pagemap(nr, nr_start, pages);
@@ -1752,8 +1755,11 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
 	if (!pmd_access_permitted(orig, flags & FOLL_WRITE))
 		return 0;
 
-	if (pmd_devmap(orig))
+	if (pmd_devmap(orig)) {
+		if (unlikely(flags & FOLL_LONGTERM))
+			return 0;
 		return __gup_device_huge_pmd(orig, pmdp, addr, end, pages, nr);
+	}
 
 	refs = 0;
 	page = pmd_page(orig) + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
@@ -1790,8 +1796,11 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
 	if (!pud_access_permitted(orig, flags & FOLL_WRITE))
 		return 0;
 
-	if (pud_devmap(orig))
+	if (pud_devmap(orig)) {
+		if (unlikely(flags & FOLL_LONGTERM))
+			return 0;
 		return __gup_device_huge_pud(orig, pudp, addr, end, pages, nr);
+	}
 
 	refs = 0;
 	page = pud_page(orig) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
@@ -2034,6 +2043,29 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	return nr;
 }
 
+static int __gup_longterm_unlocked(unsigned long start, int nr_pages,
+				   unsigned int gup_flags, struct page **pages)
+{
+	int ret;
+
+	/*
+	 * FIXME: FOLL_LONGTERM does not work with
+	 * get_user_pages_unlocked() (see comments in that function)
+	 */
+	if (gup_flags & FOLL_LONGTERM) {
+		down_read(&current->mm->mmap_sem);
+		ret = __gup_longterm_locked(current, current->mm,
+					    start, nr_pages,
+					    pages, NULL, gup_flags);
+		up_read(&current->mm->mmap_sem);
+	} else {
+		ret = get_user_pages_unlocked(start, nr_pages,
+					      pages, gup_flags);
+	}
+
+	return ret;
+}
+
 /**
  * get_user_pages_fast() - pin user pages in memory
  * @start:	starting user address
@@ -2079,8 +2111,8 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
 		start += nr << PAGE_SHIFT;
 		pages += nr;
 
-		ret = get_user_pages_unlocked(start, nr_pages - nr, pages,
-					      gup_flags);
+		ret = __gup_longterm_unlocked(start, nr_pages - nr,
+					      gup_flags, pages);
 
 		/* Have to be a bit careful with return values */
 		if (nr > 0) {
-- 
2.20.1

