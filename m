Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08DB7C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 05:30:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD0EA21905
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 05:30:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD0EA21905
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B71D8E0006; Wed, 20 Feb 2019 00:30:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D2968E0008; Wed, 20 Feb 2019 00:30:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4226C8E0007; Wed, 20 Feb 2019 00:30:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 01D808E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 00:30:52 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id h70so17944429pfd.11
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 21:30:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=tgNdEt5FRga0HkLa8ndjlDXGyjg8hU5HkhXgPKbLuBo=;
        b=DBHddmnM8KnHbbMfBcsPeqcsb5FG+a7XDD5jwc7IhvC3l1yqhGCjKGwrosGlNUdw3D
         OFnHtbz4vy7GLWcdPup8CscUNu3ofQCld10kpaw2uMIR8YAoZ0dVVmOCgFjvMeokYvnM
         p3nmdVqiMvJk2htjd0tc2ipD33Xnx13RoVo0TZEvZSVDh9Lo8h4Iyqr3u4FN19/31GpV
         HCNG59V/3ouV5s+5dBLYP5M/ctdkawu3CsPhew6msX9II2X0EFzAlBSJRnVK/9xjLr37
         2S6uElufqT7knb3Nei8Xg+UrEbTQF2xndD4zgMN7L8tlVuSt2mwknYc7hRx14kgaSS7n
         uHUQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZbwHDVtq9wJyo//hWa+F8VRb1hDj/tbrNx/LgZ6RQEO+IHuNLw
	gP6/91bCYGbQNgKB6oU5YF2n0LVRvcqjgQr7PFrBx/YAMR69TN0/wrXbMfUbjUK+u1k5e+vBldP
	OelyEk26/Rk0Dbz7UuVLSyiJZGtkkfTs+Hgg+OJdEdKrWgyOiTFnYX3wNzqacv/G+2Q==
X-Received: by 2002:a17:902:8e8a:: with SMTP id bg10mr34891921plb.192.1550640651523;
        Tue, 19 Feb 2019 21:30:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZJhglrjHyy0F++4AnLSb+lqUZXcL6sj2ToGFyqBHaZmV+6OEdqt4A8cwJ/5yPTXNizh9hC
X-Received: by 2002:a17:902:8e8a:: with SMTP id bg10mr34891872plb.192.1550640650825;
        Tue, 19 Feb 2019 21:30:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550640650; cv=none;
        d=google.com; s=arc-20160816;
        b=rdrWMs0Eg8rI+uJ9DGX24VXeGgydmXWpgRoLksGTU5HfoVhGOSMEOFuG2rzRLTOrn8
         mDPk30w1cgkTWPGeBzuiGhhvIc/OGe6wRa9wuZ/JNCFqo88B+sDrHzjd9FMHuzz7gdb0
         I8uYoHidiKbvGmRidte6NZ8ur8dH1gIbp8QShkp9EtimeUFjOdfULHN80Mxx+tLKjzRe
         cKhzBDWS1C0m4/f+z6IH3Ns4nchB0oaUHK+ofsXYuZDiNOQhCwVvjdiZSBhIHjf0RLj7
         8SgGUwCnc+oqYGzN+G4bxogNI5hvZGW6dwfTkGFmxVbRhuvD1LMFV9PVoS6gfu/Ytkik
         R07Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=tgNdEt5FRga0HkLa8ndjlDXGyjg8hU5HkhXgPKbLuBo=;
        b=gLb9as56QoT2ALi3F9KOi0y9IFqqABwdHcF45DcJUVlnMpPTuZwksMS09NSXs7Lb4M
         t+r+Wqa9QSvAczif6vMPNcs+8I3VkR+kRYr+7dgkqt0eG59LbiRmnrv89gZPPmlP0GG7
         V4v80PnT0ab4pcYTbW3qasXgy6lOVeuAnUBPXok1FcWug8AxTi0CGtSQc+HVzq0rrUXq
         D1RT/kXoDpZECPH8tsG67nnz7lQdn+fFMrg2DdLfCDVTG5QLdCM3biYfS2YjMmjY/q5x
         EfTruMFUeCO613HbDp7ux6HyPHD34XED1UHmGtMfGWvn6Suyj0FE6eM2ZPqlZmPPLYQA
         yfXg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id e17si17976549pgd.109.2019.02.19.21.30.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 21:30:50 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 19 Feb 2019 21:30:50 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,388,1544515200"; 
   d="scan'208";a="144924913"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga002.fm.intel.com with ESMTP; 19 Feb 2019 21:30:50 -0800
From: ira.weiny@intel.com
To: John Hubbard <jhubbard@nvidia.com>,
	Andrew Morton <akpm@linux-foundation.org>,
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
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>
Cc: Ira Weiny <ira.weiny@intel.com>,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-mips@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	kvm-ppc@vger.kernel.org,
	kvm@vger.kernel.org,
	linux-fpga@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org,
	linux-scsi@vger.kernel.org,
	devel@driverdev.osuosl.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org,
	linux-fbdev@vger.kernel.org,
	xen-devel@lists.xenproject.org,
	devel@lists.orangefs.org,
	ceph-devel@vger.kernel.org,
	rds-devel@oss.oracle.com
Subject: [RESEND PATCH 4/7] mm/gup: Add FOLL_LONGTERM capability to GUP fast
Date: Tue, 19 Feb 2019 21:30:37 -0800
Message-Id: <20190220053040.10831-5-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190220053040.10831-1-ira.weiny@intel.com>
References: <20190220053040.10831-1-ira.weiny@intel.com>
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
 mm/gup.c | 24 +++++++++++++++++++++---
 1 file changed, 21 insertions(+), 3 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 6f32d36b3c5b..f7e759c523bb 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1439,6 +1439,9 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 			goto pte_unmap;
 
 		if (pte_devmap(pte)) {
+			if (unlikely(flags & FOLL_LONGTERM))
+				goto pte_unmap;
+
 			pgmap = get_dev_pagemap(pte_pfn(pte), pgmap);
 			if (unlikely(!pgmap)) {
 				undo_dev_pagemap(nr, nr_start, pages);
@@ -1578,8 +1581,11 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
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
@@ -1904,8 +1910,20 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
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

