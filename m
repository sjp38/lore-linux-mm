Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 038B8C32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:35:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B00C621743
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:35:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="eabm6eV7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B00C621743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 597FB6B0003; Tue,  6 Aug 2019 21:34:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4FE696B02AA; Tue,  6 Aug 2019 21:34:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D88D6B02AC; Tue,  6 Aug 2019 21:34:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id E148D6B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:34:51 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id j96so3536734plb.5
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:34:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=iyBF/TunLLNE9m64WGZW5xnvl+XVp1Tkb/4cWK4Q28U=;
        b=Yd/mHdzfOQyumrXjHdZ/cxvqIALHsLJOyBCRfF9dxlwjnM0u8NlpYBkGI8y1VQxEd2
         HTEYD3mqcL+PRb5ATlxjzCalmyVAQUBcg/O88h2Z+ZZhERBJsdLda/R3RkCj4EIPouFx
         ZsJn4q2CFjPorFs2USguADWWmXkwYRwZFVh5wVrvgJ9TKWQ4XmkzLn7SESWh/9zH5LBE
         ogBeOqC6Z415xrrxZ9vM5xPhuoX7uGMxq2axgkjopBv8qKNmQFDn3In0N3xIxB5qc2Ew
         SjESFr5KKOHXi90pHDBV9gLBm71bz+06p6LDkjW8+7tC9O15P+3FAzzGsvaP7v/E7pO7
         VWQQ==
X-Gm-Message-State: APjAAAWyCuwzLHwnrGafXgQEq0CPO84enSKX6vAcjhwrOJtsh6k4588P
	e6UkSx1p0+auD+4GBDeFHUqUnMDPil151ggCCsA2FBJXR6Hj9n5Ohkp9ttIuuhfFBX8FyjSNYEY
	uWhHZLXgfF44u5e9FKGgYAzZbqBc5V1olcgwZq2AxbV43OjRaWnRukqIXP9+iDZ5wIQ==
X-Received: by 2002:a17:902:28c9:: with SMTP id f67mr5903687plb.19.1565141691575;
        Tue, 06 Aug 2019 18:34:51 -0700 (PDT)
X-Received: by 2002:a17:902:28c9:: with SMTP id f67mr5903627plb.19.1565141690429;
        Tue, 06 Aug 2019 18:34:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141690; cv=none;
        d=google.com; s=arc-20160816;
        b=tRaJLuLg1/1VV+l11ySen1+ybzwL9qrOI7x5jvHRfvyLF4Tfm7TSOBirpXVl4LqJmW
         H7oIwdkXe4E91Ue3WcZJsU9bU7PPCM0sW2EiSmHJ4VD+6wrVh6xOEtilD+1dMplYYBqH
         KnwXGTtFhIw/12quOtGXSeZ+VZbg3hC5xl5Tcy2VOeGCG3mOUbefhM1dIg36vEMhmob6
         Ej8GjIiQVGZ73HtLfAW4mjyCFPeTAdH9nDG+rvZKZfpKgC22b6GMz3GYzVk/aAg2CPNV
         jFyla4yhXdEcbEFVCwFwtllmuUclqNiVGVyp+J+pmlfRQJ6dhV9IGIiFsZNEQ7UKNZ51
         4+qg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=iyBF/TunLLNE9m64WGZW5xnvl+XVp1Tkb/4cWK4Q28U=;
        b=HaSPw9Pd8J4TtAGDeYG8Wf0Cm6yBpRgMc76BPEGY6E7NL4gOZU0yyBAt3rG4VmENn+
         lWOSYsWy2qyTxT5MHp9bkutf+SRmM6YQBleamMb9pikp0JrFWC/MUajiIeax0AncEWNp
         JuLZpFkIpToYo/afeC03mJdN8ta00mNb+ioxEN1+n5XrdxEdOxpy1xfFb7pSdKsjaDPO
         swycb6BKtc8rpaRTHNpSACTjufFRCX2Z9umzrKYWPDRNdfv+g/bBOW6JaMhBWTfFiSGY
         CaFo0Pglyvz2srluQhBhwarl2aS+Kga2TjZHavzp7NUdCVXB84yfBaI1Lh9j2Z1j308E
         99Yw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=eabm6eV7;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a13sor70008161pfr.48.2019.08.06.18.34.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:34:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=eabm6eV7;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=iyBF/TunLLNE9m64WGZW5xnvl+XVp1Tkb/4cWK4Q28U=;
        b=eabm6eV7x6nJ3H6jB3OWHKTAjJ5hccshhWRSvyF8YaL4Xb3kcN3FPSj+mrT7hdf1FM
         0MWhm5PqlQFyy6zw76EwLtyOlQEQTOAPUCRq2cKY8d4yFrfincU70ZRfebLbmlijIWR2
         wTENuQ2R1ycfB8EIZdvDLYgUy7fahn8NbpOFjvcP7wPItsW4fy1klzu0bIomS6ZhLV9L
         FATmBTkmPO3bz1bBRYsOrrqOVmLfRrGMChgnyEYGXYwKFOo3GWkjWYe147H72f0kIcVc
         Tr73f17ZMCrLU+eCYt8HTv90LoBSVz+pg0lUMLNh1TQmkPNzI1sbpCYBSoNZ3shE6svq
         cn7w==
X-Google-Smtp-Source: APXvYqz3mrxPCB1S0CW+dxLuweNihe5G+Md2rLL8K5hOTJIrjMzyu1ZdPrsndXXUg8jjoSZHHVCyxA==
X-Received: by 2002:a62:14c4:: with SMTP id 187mr6515801pfu.241.1565141690166;
        Tue, 06 Aug 2019 18:34:50 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.34.48
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:34:49 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	amd-gfx@lists.freedesktop.org,
	ceph-devel@vger.kernel.org,
	devel@driverdev.osuosl.org,
	devel@lists.orangefs.org,
	dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org,
	kvm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-block@vger.kernel.org,
	linux-crypto@vger.kernel.org,
	linux-fbdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-media@vger.kernel.org,
	linux-mm@kvack.org,
	linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	linux-rpi-kernel@lists.infradead.org,
	linux-xfs@vger.kernel.org,
	netdev@vger.kernel.org,
	rds-devel@oss.oracle.com,
	sparclinux@vger.kernel.org,
	x86@kernel.org,
	xen-devel@lists.xenproject.org,
	John Hubbard <jhubbard@nvidia.com>,
	Daniel Black <daniel@linux.ibm.com>,
	Matthew Wilcox <willy@infradead.org>,
	Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v3 41/41] mm/ksm: convert put_page() to put_user_page*()
Date: Tue,  6 Aug 2019 18:33:40 -0700
Message-Id: <20190807013340.9706-42-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190807013340.9706-1-jhubbard@nvidia.com>
References: <20190807013340.9706-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page() or
release_pages().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Daniel Black <daniel@linux.ibm.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 mm/ksm.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 3dc4346411e4..e10ee4d5fdd8 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -456,7 +456,7 @@ static inline bool ksm_test_exit(struct mm_struct *mm)
  * We use break_ksm to break COW on a ksm page: it's a stripped down
  *
  *	if (get_user_pages(addr, 1, 1, 1, &page, NULL) == 1)
- *		put_page(page);
+ *		put_user_page(page);
  *
  * but taking great care only to touch a ksm page, in a VM_MERGEABLE vma,
  * in case the application has unmapped and remapped mm,addr meanwhile.
@@ -483,7 +483,7 @@ static int break_ksm(struct vm_area_struct *vma, unsigned long addr)
 					FAULT_FLAG_WRITE | FAULT_FLAG_REMOTE);
 		else
 			ret = VM_FAULT_WRITE;
-		put_page(page);
+		put_user_page(page);
 	} while (!(ret & (VM_FAULT_WRITE | VM_FAULT_SIGBUS | VM_FAULT_SIGSEGV | VM_FAULT_OOM)));
 	/*
 	 * We must loop because handle_mm_fault() may back out if there's
@@ -568,7 +568,7 @@ static struct page *get_mergeable_page(struct rmap_item *rmap_item)
 		flush_anon_page(vma, page, addr);
 		flush_dcache_page(page);
 	} else {
-		put_page(page);
+		put_user_page(page);
 out:
 		page = NULL;
 	}
@@ -1974,10 +1974,10 @@ struct rmap_item *unstable_tree_search_insert(struct rmap_item *rmap_item,
 
 		parent = *new;
 		if (ret < 0) {
-			put_page(tree_page);
+			put_user_page(tree_page);
 			new = &parent->rb_left;
 		} else if (ret > 0) {
-			put_page(tree_page);
+			put_user_page(tree_page);
 			new = &parent->rb_right;
 		} else if (!ksm_merge_across_nodes &&
 			   page_to_nid(tree_page) != nid) {
@@ -1986,7 +1986,7 @@ struct rmap_item *unstable_tree_search_insert(struct rmap_item *rmap_item,
 			 * it will be flushed out and put in the right unstable
 			 * tree next time: only merge with it when across_nodes.
 			 */
-			put_page(tree_page);
+			put_user_page(tree_page);
 			return NULL;
 		} else {
 			*tree_pagep = tree_page;
@@ -2328,7 +2328,7 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
 							&rmap_item->rmap_list;
 					ksm_scan.address += PAGE_SIZE;
 				} else
-					put_page(*page);
+					put_user_page(*page);
 				up_read(&mm->mmap_sem);
 				return rmap_item;
 			}
-- 
2.22.0

