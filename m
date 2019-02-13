Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1AB22C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 23:05:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C8A4F222A1
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 23:05:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C8A4F222A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 71AE18E0013; Wed, 13 Feb 2019 18:05:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 69F798E0001; Wed, 13 Feb 2019 18:05:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 518AF8E0013; Wed, 13 Feb 2019 18:05:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 058B08E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 18:05:32 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id e68so2823152plb.3
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 15:05:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=tgNdEt5FRga0HkLa8ndjlDXGyjg8hU5HkhXgPKbLuBo=;
        b=R648w+g3Biapkd0vxTu649hMU673eeZgUsmOjPKaoolushzRC/VSPxhEQh4+pN16hz
         ziz7bj+rn2VvVwXSnImAyyg2ZwNFQDNY+0cokR1J0Wt7WgSiU3kOYGIkR5dHnfgvldQM
         6Ai564wiv3JGH4HGgO7DUCsE36lIo8l4gMCiM5LOuglMjAzzZrYCRcDB8WaaoMMzkBGS
         gEplG6ubOQwp430DqkBCE+3SG+jj1R72XDeaLm3cWksTmrQ+ToVGkTcs18jYQS11k5Bg
         07qVC62uPT+rFbQjE9AnVgpiWKUVmhmyc1luQQXLJOQJy7kpxlco43O6eP8ah4HHE5M9
         oKPw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuYT2ZSgOhZ3yc+dfw1HbLhXDzbhXB0jt0FJg9cD92YvJefDhJHh
	snhWAyS9V3pfp6BaXNlN0cJL6VyHenswNAuU6KmXKc5sBmzAdmZiuKVLgPDC1d6wl5glQJ/eYgR
	ztey7I5VRXQpJZUOUXyf4VkK6ozr+x/hd461x75Mt3YBLn4rVdNa78Gg4arMjly9RZQ==
X-Received: by 2002:a62:6f49:: with SMTP id k70mr637158pfc.7.1550099131697;
        Wed, 13 Feb 2019 15:05:31 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYw6rW4sSYrlT8D50+ggAnwOF+08NdOeTNiEquGoC3lwyWVEOO22PszfpF3cSB+3L+hoL7q
X-Received: by 2002:a62:6f49:: with SMTP id k70mr637100pfc.7.1550099130972;
        Wed, 13 Feb 2019 15:05:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550099130; cv=none;
        d=google.com; s=arc-20160816;
        b=Qt9l6D8QrtZmiVCLSyVhjpi4qZ42eP4O62bL7rw6+uDAColU+EGf5LvuYkY+PWwIZH
         LIp8fn8C9wJmIUGnHQmypl8bKOVqvg21QaKiWf8FgzsdBfYet6UXMrCq+K+CUokAHjWC
         CzTp9WK0PEqIs3Mfi7C630czZlJd33KTbqLXm1hMDPY2d8b0uiz4ieXBXYiQE0HlRC1+
         16z7kZftjABLqKH7/dKbAsJHri4zID9VEgNyK5QS/MUwNXbhA4+Ki+7RivtMG+z8X0uF
         IuOcr7KgeQ4wKRb05olfiSA7UQvV8ID48akm4rhFc/CoFGiNSAkOjzNtFNWdpu7ZUidv
         6gYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=tgNdEt5FRga0HkLa8ndjlDXGyjg8hU5HkhXgPKbLuBo=;
        b=S/fYdMp6QxIjHSrfRvtIHNJichuFKawJq0BsdZ6aAHQ8O4aeLS+hqoZFNiRj2hopxN
         JRudWy4MP+ZlXXUVueD8CKscuUZYDMO4mFXVOadylLpHYYyszFdLk+lJT41nxQXOEtLF
         INYHKgE+5CJmT2pAO0UQVIGdS7mgGkLfctcLfoiRzV6lkhbtGOMxGHzY27qOkc20t3qL
         AUmzh5HKtfRdSJRlrCLPIi8diAlApaXLDAj+S8aNl0JU2GIKJqEZ8RYItMiugPda6UDJ
         FORqiEsmReCUUBGTf4c4w3SSsBC3lEhnscNipuXXz0VdVivvsAzBBF0pPO9JwfRF5hf3
         FUQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id f9si574863pgh.435.2019.02.13.15.05.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 15:05:30 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Feb 2019 15:05:26 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,366,1544515200"; 
   d="scan'208";a="138415618"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga001.jf.intel.com with ESMTP; 13 Feb 2019 15:05:24 -0800
From: ira.weiny@intel.com
To: linux-mips@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kvm-ppc@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
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
	linux-mm@kvack.org,
	ceph-devel@vger.kernel.org,
	rds-devel@oss.oracle.com
Cc: Ira Weiny <ira.weiny@intel.com>,
	John Hubbard <jhubbard@nvidia.com>,
	David Hildenbrand <david@redhat.com>,
	Cornelia Huck <cohuck@redhat.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	Joerg Roedel <joro@8bytes.org>,
	Wu Hao <hao.wu@intel.com>,
	Alan Tull <atull@kernel.org>,
	Moritz Fischer <mdf@kernel.org>,
	David Airlie <airlied@linux.ie>,
	Daniel Vetter <daniel@ffwll.ch>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Christian Benvenuti <benve@cisco.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Matt Porter <mporter@kernel.crashing.org>,
	Alexandre Bounine <alex.bou9@gmail.com>,
	=?UTF-8?q?Kai=20M=C3=A4kisara?= <Kai.Makisara@kolumbus.fi>,
	"James E.J. Bottomley" <jejb@linux.ibm.com>,
	"Martin K. Petersen" <martin.petersen@oracle.com>,
	Rob Springer <rspringer@google.com>,
	Todd Poynor <toddpoynor@google.com>,
	Ben Chan <benchan@chromium.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Stefano Stabellini <sstabellini@kernel.org>,
	Martin Brandenburg <martin@omnibond.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH V2 4/7] mm/gup: Add FOLL_LONGTERM capability to GUP fast
Date: Wed, 13 Feb 2019 15:04:52 -0800
Message-Id: <20190213230455.5605-5-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190213230455.5605-1-ira.weiny@intel.com>
References: <20190211201643.7599-1-ira.weiny@intel.com>
 <20190213230455.5605-1-ira.weiny@intel.com>
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

