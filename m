Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D517C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:59:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 417F4208C4
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:59:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 417F4208C4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 724816B026B; Fri,  9 Aug 2019 18:59:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5BF7A6B026C; Fri,  9 Aug 2019 18:59:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B1376B026D; Fri,  9 Aug 2019 18:59:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0218D6B026B
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 18:59:03 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id k9so58271673pls.13
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 15:59:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=UXaF8E75Fz8TNtd5YlkD6jNcYk7EPaE+qiAcVO8EQK8=;
        b=jXR3GLf5OpEVsnGZL0RjoFFtCiQ2Sk9EIBm3b3F+eNC1ojhNMlwUCdhAoOftH1MGXU
         YTDiqRdKNj1ltinVfhJSXx+pABicrO9UnHIQe/ipjRgw0GDoWFqs8sunDNTdhwNv8nDP
         kcyFo3rwBc7tUaZcQ12NLvqR5qpAL+jpChyYaQNSwFcPxod52gm2lewNBwYeYPkxGKB2
         uOtxvxOva7sT0Ik6Jj0Wfz8DEXfl0XsDMbIVJpfIUPCgC/SLg7xRyDPhqv8cyLfLHREf
         NZ34l6niytTyZpOtr8aRUg4NM6kpE7iOefDZRvueLKifcrw7npIQxtae33BZ+wSxuv+x
         F3Tg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX7B6YaaG0N5fOeYHP+phx8UZU/O9A9qhQuhTbZCIoEx8Yn+ZSw
	+jdCr39FJfm6VkXXQPom0B9Ytgo7QkDKUUthUSgCHZ6jDMOaJ87ZwriwTaq4XTzO677t43fQbLQ
	STEGr8Ts7PJ25OuZ8SKYrOhLQYugexVjgOmBejj8hfANZhYHPpux1FOviE4SpxtLeBg==
X-Received: by 2002:a63:8dc9:: with SMTP id z192mr19185781pgd.151.1565391542604;
        Fri, 09 Aug 2019 15:59:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwf/4zz2ggySgyosK3Y5V4HFdZr/Zg0pss+d2m9bTPDQrjuvJp1wYrf+LAZfhal9rTjqYjv
X-Received: by 2002:a63:8dc9:: with SMTP id z192mr19185730pgd.151.1565391541548;
        Fri, 09 Aug 2019 15:59:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565391541; cv=none;
        d=google.com; s=arc-20160816;
        b=a4ausUnY2oPo1yMnY34vtAkLTA9CGN+isWc+IX2IIqgSxkDDme3+uWcNqZ+malo+RM
         Lb3MzpZc8pwac/QNYo9Q1JLE+Cs+P4hlQghlBWJnRG0kGxhqsH+LeviPBDMU0T0zKHDw
         DPs5Bt6nDLQ058mMZhPnvcyohX8V1Hhz8FSj61X7mcuyc11AWKpVdIg15odsxWsmg2dA
         TSTSZnrnZFTBWGGXCqWigfIfMXIICbfo1JEKxqKCjMxMooTWm6DMG7sT/DprVPDLC5vo
         StYFQOOsW6Zp4oGiCaL3TZgSyAX2Ut22CFMymAxcRP+ONXxcEu8DsgpMgh6nExd0N1GS
         6CQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=UXaF8E75Fz8TNtd5YlkD6jNcYk7EPaE+qiAcVO8EQK8=;
        b=A+Vy71Sl2yPWTML1tC7LUw/RK/ZoiZXU6/A0Gl/Y3X8iY/zW9B2udq12vOtlSkPXg2
         PlcZ1BqbKw83wFcwXBmH1JvSsFIqUdzkkSDMzc2qgGR4Iu/RIVSUFRuo8WCn8TNPdV1n
         1CDSksoJDB+gdr+adIPKxMCZX7oEBHi1wkgCwTMv3LhYk3r12emTXlvn+44n6dZGSwsZ
         ditPg3eCb749sgF8Xq/sVlGDFnXJeSvKaFvUlWEIeGS89CmXYsucmwAZQFYi1i1isiaY
         Rx8rTMjea4q4cV12iJNzw5IbI0/dYoCIKfl8sOIA1u7f52eZ07tYjBvQHgmlzrmVe/xb
         RVTA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id f12si24938561pgp.218.2019.08.09.15.59.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 15:59:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 15:59:00 -0700
X-IronPort-AV: E=Sophos;i="5.64,367,1559545200"; 
   d="scan'208";a="186799457"
Received: from iweiny-desk2.sc.intel.com (HELO localhost) ([10.3.52.157])
  by orsmga002-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 15:59:00 -0700
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
Subject: [RFC PATCH v2 12/19] mm/gup: Prep put_user_pages() to take an vaddr_pin struct
Date: Fri,  9 Aug 2019 15:58:26 -0700
Message-Id: <20190809225833.6657-13-ira.weiny@intel.com>
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

Once callers start to use vaddr_pin the put_user_pages calls will need
to have access to this data coming in.  Prep put_user_pages() for this
data.

Signed-off-by: Ira Weiny <ira.weiny@intel.com>
---
 include/linux/mm.h |  20 +-------
 mm/gup.c           | 122 ++++++++++++++++++++++++++++++++-------------
 2 files changed, 88 insertions(+), 54 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index befe150d17be..9d37cafbef9a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1064,25 +1064,7 @@ static inline void put_page(struct page *page)
 		__put_page(page);
 }
 
-/**
- * put_user_page() - release a gup-pinned page
- * @page:            pointer to page to be released
- *
- * Pages that were pinned via get_user_pages*() must be released via
- * either put_user_page(), or one of the put_user_pages*() routines
- * below. This is so that eventually, pages that are pinned via
- * get_user_pages*() can be separately tracked and uniquely handled. In
- * particular, interactions with RDMA and filesystems need special
- * handling.
- *
- * put_user_page() and put_page() are not interchangeable, despite this early
- * implementation that makes them look the same. put_user_page() calls must
- * be perfectly matched up with get_user_page() calls.
- */
-static inline void put_user_page(struct page *page)
-{
-	put_page(page);
-}
+void put_user_page(struct page *page);
 
 void put_user_pages_dirty_lock(struct page **pages, unsigned long npages,
 			       bool make_dirty);
diff --git a/mm/gup.c b/mm/gup.c
index a7a9d2f5278c..10cfd30ff668 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -24,30 +24,41 @@
 
 #include "internal.h"
 
-/**
- * put_user_pages_dirty_lock() - release and optionally dirty gup-pinned pages
- * @pages:  array of pages to be maybe marked dirty, and definitely released.
- * @npages: number of pages in the @pages array.
- * @make_dirty: whether to mark the pages dirty
- *
- * "gup-pinned page" refers to a page that has had one of the get_user_pages()
- * variants called on that page.
- *
- * For each page in the @pages array, make that page (or its head page, if a
- * compound page) dirty, if @make_dirty is true, and if the page was previously
- * listed as clean. In any case, releases all pages using put_user_page(),
- * possibly via put_user_pages(), for the non-dirty case.
- *
- * Please see the put_user_page() documentation for details.
- *
- * set_page_dirty_lock() is used internally. If instead, set_page_dirty() is
- * required, then the caller should a) verify that this is really correct,
- * because _lock() is usually required, and b) hand code it:
- * set_page_dirty_lock(), put_user_page().
- *
- */
-void put_user_pages_dirty_lock(struct page **pages, unsigned long npages,
-			       bool make_dirty)
+static void __put_user_page(struct vaddr_pin *vaddr_pin, struct page *page)
+{
+	page = compound_head(page);
+
+	/*
+	 * For devmap managed pages we need to catch refcount transition from
+	 * GUP_PIN_COUNTING_BIAS to 1, when refcount reach one it means the
+	 * page is free and we need to inform the device driver through
+	 * callback. See include/linux/memremap.h and HMM for details.
+	 */
+	if (put_devmap_managed_page(page))
+		return;
+
+	if (put_page_testzero(page))
+		__put_page(page);
+}
+
+static void __put_user_pages(struct vaddr_pin *vaddr_pin, struct page **pages,
+			     unsigned long npages)
+{
+	unsigned long index;
+
+	/*
+	 * TODO: this can be optimized for huge pages: if a series of pages is
+	 * physically contiguous and part of the same compound page, then a
+	 * single operation to the head page should suffice.
+	 */
+	for (index = 0; index < npages; index++)
+		__put_user_page(vaddr_pin, pages[index]);
+}
+
+static void __put_user_pages_dirty_lock(struct vaddr_pin *vaddr_pin,
+					struct page **pages,
+					unsigned long npages,
+					bool make_dirty)
 {
 	unsigned long index;
 
@@ -58,7 +69,7 @@ void put_user_pages_dirty_lock(struct page **pages, unsigned long npages,
 	 */
 
 	if (!make_dirty) {
-		put_user_pages(pages, npages);
+		__put_user_pages(vaddr_pin, pages, npages);
 		return;
 	}
 
@@ -86,9 +97,58 @@ void put_user_pages_dirty_lock(struct page **pages, unsigned long npages,
 		 */
 		if (!PageDirty(page))
 			set_page_dirty_lock(page);
-		put_user_page(page);
+		__put_user_page(vaddr_pin, page);
 	}
 }
+
+/**
+ * put_user_page() - release a gup-pinned page
+ * @page:            pointer to page to be released
+ *
+ * Pages that were pinned via get_user_pages*() must be released via
+ * either put_user_page(), or one of the put_user_pages*() routines
+ * below. This is so that eventually, pages that are pinned via
+ * get_user_pages*() can be separately tracked and uniquely handled. In
+ * particular, interactions with RDMA and filesystems need special
+ * handling.
+ *
+ * put_user_page() and put_page() are not interchangeable, despite this early
+ * implementation that makes them look the same. put_user_page() calls must
+ * be perfectly matched up with get_user_page() calls.
+ */
+void put_user_page(struct page *page)
+{
+	__put_user_page(NULL, page);
+}
+EXPORT_SYMBOL(put_user_page);
+
+/**
+ * put_user_pages_dirty_lock() - release and optionally dirty gup-pinned pages
+ * @pages:  array of pages to be maybe marked dirty, and definitely released.
+ * @npages: number of pages in the @pages array.
+ * @make_dirty: whether to mark the pages dirty
+ *
+ * "gup-pinned page" refers to a page that has had one of the get_user_pages()
+ * variants called on that page.
+ *
+ * For each page in the @pages array, make that page (or its head page, if a
+ * compound page) dirty, if @make_dirty is true, and if the page was previously
+ * listed as clean. In any case, releases all pages using put_user_page(),
+ * possibly via put_user_pages(), for the non-dirty case.
+ *
+ * Please see the put_user_page() documentation for details.
+ *
+ * set_page_dirty_lock() is used internally. If instead, set_page_dirty() is
+ * required, then the caller should a) verify that this is really correct,
+ * because _lock() is usually required, and b) hand code it:
+ * set_page_dirty_lock(), put_user_page().
+ *
+ */
+void put_user_pages_dirty_lock(struct page **pages, unsigned long npages,
+			       bool make_dirty)
+{
+	__put_user_pages_dirty_lock(NULL, pages, npages, make_dirty);
+}
 EXPORT_SYMBOL(put_user_pages_dirty_lock);
 
 /**
@@ -102,15 +162,7 @@ EXPORT_SYMBOL(put_user_pages_dirty_lock);
  */
 void put_user_pages(struct page **pages, unsigned long npages)
 {
-	unsigned long index;
-
-	/*
-	 * TODO: this can be optimized for huge pages: if a series of pages is
-	 * physically contiguous and part of the same compound page, then a
-	 * single operation to the head page should suffice.
-	 */
-	for (index = 0; index < npages; index++)
-		put_user_page(pages[index]);
+	__put_user_pages(NULL, pages, npages);
 }
 EXPORT_SYMBOL(put_user_pages);
 
-- 
2.20.1

