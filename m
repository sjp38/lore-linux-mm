Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83F16C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 02:36:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 43CCE20872
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 02:36:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 43CCE20872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F9F96B000E; Sun, 17 Mar 2019 22:36:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 681E96B026A; Sun, 17 Mar 2019 22:36:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B9236B000A; Sun, 17 Mar 2019 22:36:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id D6A216B000A
	for <linux-mm@kvack.org>; Sun, 17 Mar 2019 22:36:06 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id v3so3316501pgk.9
        for <linux-mm@kvack.org>; Sun, 17 Mar 2019 19:36:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=6wzlX7Q3HmA8CjwFtjtOCiX1cJQ1JoP4raDfaqWNpKY=;
        b=WPWN5IFJ7Vj5b2eGWPezLcmSgkGwUAuiIwa0BqBPZUXDUq724q6R6yhG7meP/aWP+I
         xRvNuZFP4oLZY0/792bJ9zk6hN/wH73EgivbddNQqGvDSuPZeOYbQByHrK61PFmfzDqU
         1RYnbebCCHAw9V1PWjqvGWPyAsITaMhPNs5WhMtSEKVj0wd0Qg2PPVqtgwhoz1n8WB2F
         ysb2caHl1GHi4/QCzqcXUUa5Q8EtnLqI/ptbTQKWe8S68+WB0PF4wbkvRvTKzDt+ZwsE
         ORcTiui2SQMHhQDBPvmH1DAJj1msVPtJnhCa+Qcbde+uYjFkOr15bIC7UGESDH1AmHmT
         QjGg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXsSk8Rhn5cYWe5pPl6XqsvNXxgajRLbAinSqpLHnjFhbR3UVgs
	R0Bmnw53PN88aSef4YIYenAAcozJsrLKfw8CEtr7EGcFJd7hD2x9QB2VdAMhYg9wBApPEmPsGli
	WsnXEzkcMp7VxP+tQlHI+iWZ7o5bxodWlOogRMzQYJNS7bKdvF156E9TmresqZGHSpw==
X-Received: by 2002:a17:902:ab82:: with SMTP id f2mr16953127plr.93.1552876566482;
        Sun, 17 Mar 2019 19:36:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzRV7aSUDImwrUXKjbgEJiRY2PEtqwk1lGRVLzTRDhJVtxP+8s7KlYp5zqRpMY62ClFKXOQ
X-Received: by 2002:a17:902:ab82:: with SMTP id f2mr16953072plr.93.1552876565624;
        Sun, 17 Mar 2019 19:36:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552876565; cv=none;
        d=google.com; s=arc-20160816;
        b=SLYDnce/2FIXB22WJtNcBa2jJ4FxQe79K1vUowYZ+J4c26pxh+9i3lFgm/gPRfhXZi
         af2UQHL+aZT8ID68UpEen3cTLks9L7X9vx2gxlR6NbVEWTHmIGDQgKBi7eUVyEuiHL+x
         Ta6t2gbL2LDfjkmETRVuU5le0cbw94HM2OYfeuFWwYZe9vN7BNfIlEVzVN2bCMFvJUwz
         tNPWq1kCdPak4pU/5nOxB4gpxYpSdQjDs7V03qkew9YR7Vf/2mCcEnwmEv5t8TnibgN3
         TErPzheDFq8JBpeX15HvBo6l6+fe09NuFq9EilILJxuRz6/NpVRcP5eJMSJJuFao8G0D
         i4yA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=6wzlX7Q3HmA8CjwFtjtOCiX1cJQ1JoP4raDfaqWNpKY=;
        b=pI1m9Jy+FjPY3c6pFuz9u5MURPp1xVPu9/oMR8aL4ts2eNvwlM/C3l1e0aRJAmtzPi
         Y7AITH/nn3OShLzk1kf0VQFAQ3/ObgnUTL9ULH/uKUS8dhXoitsxgg3ZPmIEPEt6waxK
         jvxuPsbs9H4+RBNtDJn2WD5OC6PbCM0mKo5HwRqLIGD3q2Pzq+VDlT2QXdtEZVSPeRBx
         S3EZDR+2I3Saa7wH7mCFrsntwIUALeufmkb9/PSOwfkLJIcIyKdF10K4Jq0myG6TXiTh
         brMPSXovlXnok+vRYvxzkqS856ksX0kZdxLjK3wVrdeiPvO/R5czNOaSz08ZHJpSdu3e
         QSlQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id j71si8521384pfc.280.2019.03.17.19.36.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Mar 2019 19:36:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Mar 2019 19:36:04 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,491,1544515200"; 
   d="scan'208";a="155877421"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga001.fm.intel.com with ESMTP; 17 Mar 2019 19:36:04 -0700
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
Subject: [RESEND 4/7] mm/gup: Add FOLL_LONGTERM capability to GUP fast
Date: Sun, 17 Mar 2019 11:34:35 -0700
Message-Id: <20190317183438.2057-5-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190317183438.2057-1-ira.weiny@intel.com>
References: <20190317183438.2057-1-ira.weiny@intel.com>
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
 mm/gup.c | 29 +++++++++++++++++++++++++----
 1 file changed, 25 insertions(+), 4 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 0684a9536207..173db0c44678 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1600,6 +1600,9 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 			goto pte_unmap;
 
 		if (pte_devmap(pte)) {
+			if (unlikely(flags & FOLL_LONGTERM))
+				goto pte_unmap;
+
 			pgmap = get_dev_pagemap(pte_pfn(pte), pgmap);
 			if (unlikely(!pgmap)) {
 				undo_dev_pagemap(nr, nr_start, pages);
@@ -1739,8 +1742,11 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
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
@@ -1777,8 +1783,11 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
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
@@ -2066,8 +2075,20 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
 		start += nr << PAGE_SHIFT;
 		pages += nr;
 
-		ret = get_user_pages_unlocked(start, nr_pages - nr, pages,
-					      gup_flags);
+		if (gup_flags & FOLL_LONGTERM) {
+			down_read(&current->mm->mmap_sem);
+			ret = __gup_longterm_locked(current, current->mm,
+						    start, nr_pages - nr,
+						    pages, NULL, gup_flags);
+			up_read(&current->mm->mmap_sem);
+		} else {
+			/*
+			 * retain FAULT_FOLL_ALLOW_RETRY optimization if
+			 * possible
+			 */
+			ret = get_user_pages_unlocked(start, nr_pages - nr,
+						      pages, gup_flags);
+		}
 
 		/* Have to be a bit careful with return values */
 		if (nr > 0) {
-- 
2.20.1

