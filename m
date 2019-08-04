Return-Path: <SRS0=DZuJ=WA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0ECF2C32750
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 21:40:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A79D620880
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 21:40:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="l6/GXqxR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A79D620880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 46AB86B0005; Sun,  4 Aug 2019 17:40:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D20B6B0006; Sun,  4 Aug 2019 17:40:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 14B0D6B0007; Sun,  4 Aug 2019 17:40:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id C7F486B0005
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 17:40:48 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id x19so51324927pgx.1
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 14:40:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=AIONVD1ibu9lCnP7gBI5NeGvxxgvVJwLeJRH750Gszo=;
        b=fh4RtwKOnNJEqc4R8uQVYjPMnIy7RrmR4fJ6vbBBUjC0ZWaxtrgZW603v2djcjN+CV
         pQ4LJDkXm/Cij6iA7isOaH5Bk1pkC2blEPOndrq02dQl82/Ir0TFjjJsGoP5o55cnYcN
         +zRx4Z1KfYdcK9Hgfxa1qW/4D4qYQtEkF099PXciYy6aSRW8DWmPDa1dlTJ+Fe24Zvrq
         HAHz0m7LtxIxR6hV0jZ3KMnleaD9bw/lkJg0MHCH9UPqJTKlw9/0I4xdYeLfMQOIHuJs
         344ZrnxVjCqced59msgkMxsI4zycIkahiAZkK0Qn1WNkl0JuxhJLal4egMgW76IAwR7S
         CjOg==
X-Gm-Message-State: APjAAAVu/KDYA16F/db6r4af2iaqyw8gd45td9SlHWN7YPAcVoe8s4qN
	bjVO60VE+uRK8/byaWj+m9Dhqgjc4MVi33FFKX79L9uHpQ97lie2EhLO5b7RgZr4MOEJTTprmW3
	clNzHflaiO3WUMgBsEieUMeqTHjjWYZ2pwk8KyBYS8YiV+vsxK+Ke+Cua6JdzoEtYJg==
X-Received: by 2002:a63:381d:: with SMTP id f29mr136900079pga.101.1564954848229;
        Sun, 04 Aug 2019 14:40:48 -0700 (PDT)
X-Received: by 2002:a63:381d:: with SMTP id f29mr136900043pga.101.1564954847394;
        Sun, 04 Aug 2019 14:40:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564954847; cv=none;
        d=google.com; s=arc-20160816;
        b=oLPl9iuG1uYlbakvgURFT0aHaVfu7j39XffK6BwtvuMtfrG/Ovyw0+r+PU8J64uC9t
         iNZCzGarYoGe795bEI4VVucjlqsMD7pJ7wBZ8Uj0yORdYmy5cH6SNcE2zNSVHdtYwpRP
         3wYqOoHC+QVhUKphv4Ka5gd2tZ4QXtE+XTL1rwUEZQSmLfEYMoyas8vnxfPni1vrd0BA
         3COWxF5KhSEj9tp+79wSIJgqPnjF9K0sqPDvvYs9ytQzvcIfs4I3RSlJg990uazB9En+
         9YHVysBtctBWqG9LzN4SJXtGuoKdJ3bMgMcnJlgHYVTJvUuK6PuneKT/izQAlx1zv7QD
         B9mA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=AIONVD1ibu9lCnP7gBI5NeGvxxgvVJwLeJRH750Gszo=;
        b=CvHaE6j2U1uXOc+FO5DMrKa6VayZaoHPDEZg04a65SWe9L6+AYNrB3R9sV7YeSvzTx
         q57fDOEMYLJlJlDulnkPEq37ddh2z0RyR6fgR5+OxnG65fUlQSaiSj7vySbbGQhTwmO2
         a5xyt4clisTRqpesZSgqC77rODzISgpGl0xscKvqxol1qPj+atuLZB0Z7Vv2uPl+/R64
         TJh/V5KoVAjnwU3jSlM7BMWMHNZVEZdDK88JMn1wcAAKttjlFI709TkE/71hdQb2JQBT
         T3bb0YsVLVYHBPDYch9NARROXpR5eduknwH3DFHevn0cR3d/9LsUjkpS/wWqf3KZZG4B
         gzUw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="l6/GXqxR";
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b17sor17944570pjz.4.2019.08.04.14.40.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 14:40:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="l6/GXqxR";
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=AIONVD1ibu9lCnP7gBI5NeGvxxgvVJwLeJRH750Gszo=;
        b=l6/GXqxR/s34zlyqJbk/kDxjD3yWDqEQe/AOqLflWOvrm5eDHR/+h64o5FGJVVZDm7
         AwjgeyGZZdKef0rYvnbiV+VVbqlH03c+/Srjd2r9Zj+6k3KwG7Fcina+ZOVD6jjcndEs
         m+NnyuUfp3kqqdx+MqMM0U9dp85aAko8k8ZJd6uqb/CMJsH8T4m2SrLXKjcEOHCMLJdn
         NznoDSCuK5a0TUfWCagRu70OdxNzQH7i4t1HGVY6UMearz1sHdD2pMxacliOxKD+PQmJ
         8zD7/pt5jYtEkhlcpCTn1BHo1kZKHX/RyFxS3pNMHaOBsmremV8j1DGM3LazIUu1lY7z
         9ncQ==
X-Google-Smtp-Source: APXvYqz2MBNqhiG2px2PMwKYRAiP1sDwwqvpNjzYISERV2LltM0YqC5wJEEcTpUvplCDBQRFVwft1Q==
X-Received: by 2002:a17:90a:36a7:: with SMTP id t36mr14741393pjb.34.1564954847063;
        Sun, 04 Aug 2019 14:40:47 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id 143sm123751024pgc.6.2019.08.04.14.40.45
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 14:40:46 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	=?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@intel.com>,
	Boaz Harrosh <boaz@plexistor.com>,
	Christoph Hellwig <hch@lst.de>,
	Daniel Vetter <daniel@ffwll.ch>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	David Airlie <airlied@linux.ie>,
	"David S . Miller" <davem@davemloft.net>,
	Ilya Dryomov <idryomov@gmail.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Jens Axboe <axboe@kernel.dk>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Magnus Karlsson <magnus.karlsson@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Ming Lei <ming.lei@redhat.com>,
	Sage Weil <sage@redhat.com>,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>,
	Yan Zheng <zyan@redhat.com>,
	netdev@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org,
	linux-rdma@vger.kernel.org,
	bpf@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Ira Weiny <ira.weiny@intel.com>
Subject: [PATCH v6 1/3] mm/gup: add make_dirty arg to put_user_pages_dirty_lock()
Date: Sun,  4 Aug 2019 14:40:40 -0700
Message-Id: <20190804214042.4564-2-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190804214042.4564-1-jhubbard@nvidia.com>
References: <20190804214042.4564-1-jhubbard@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

Provide a more capable variation of put_user_pages_dirty_lock(),
and delete put_user_pages_dirty(). This is based on the
following:

1. Lots of call sites become simpler if a bool is passed
into put_user_page*(), instead of making the call site
choose which put_user_page*() variant to call.

2. Christoph Hellwig's observation that set_page_dirty_lock()
is usually correct, and set_page_dirty() is usually a
bug, or at least questionable, within a put_user_page*()
calling chain.

This leads to the following API choices:

    * put_user_pages_dirty_lock(page, npages, make_dirty)

    * There is no put_user_pages_dirty(). You have to
      hand code that, in the rare case that it's
      required.

Reviewed-by: Christoph Hellwig <hch@lst.de>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Jan Kara <jack@suse.cz>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/infiniband/core/umem.c             |   5 +-
 drivers/infiniband/hw/hfi1/user_pages.c    |   5 +-
 drivers/infiniband/hw/qib/qib_user_pages.c |  13 +--
 drivers/infiniband/hw/usnic/usnic_uiom.c   |   5 +-
 drivers/infiniband/sw/siw/siw_mem.c        |  19 +---
 include/linux/mm.h                         |   5 +-
 mm/gup.c                                   | 115 +++++++++------------
 7 files changed, 61 insertions(+), 106 deletions(-)

diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
index 08da840ed7ee..965cf9dea71a 100644
--- a/drivers/infiniband/core/umem.c
+++ b/drivers/infiniband/core/umem.c
@@ -54,10 +54,7 @@ static void __ib_umem_release(struct ib_device *dev, struct ib_umem *umem, int d
 
 	for_each_sg_page(umem->sg_head.sgl, &sg_iter, umem->sg_nents, 0) {
 		page = sg_page_iter_page(&sg_iter);
-		if (umem->writable && dirty)
-			put_user_pages_dirty_lock(&page, 1);
-		else
-			put_user_page(page);
+		put_user_pages_dirty_lock(&page, 1, umem->writable && dirty);
 	}
 
 	sg_free_table(&umem->sg_head);
diff --git a/drivers/infiniband/hw/hfi1/user_pages.c b/drivers/infiniband/hw/hfi1/user_pages.c
index b89a9b9aef7a..469acb961fbd 100644
--- a/drivers/infiniband/hw/hfi1/user_pages.c
+++ b/drivers/infiniband/hw/hfi1/user_pages.c
@@ -118,10 +118,7 @@ int hfi1_acquire_user_pages(struct mm_struct *mm, unsigned long vaddr, size_t np
 void hfi1_release_user_pages(struct mm_struct *mm, struct page **p,
 			     size_t npages, bool dirty)
 {
-	if (dirty)
-		put_user_pages_dirty_lock(p, npages);
-	else
-		put_user_pages(p, npages);
+	put_user_pages_dirty_lock(p, npages, dirty);
 
 	if (mm) { /* during close after signal, mm can be NULL */
 		atomic64_sub(npages, &mm->pinned_vm);
diff --git a/drivers/infiniband/hw/qib/qib_user_pages.c b/drivers/infiniband/hw/qib/qib_user_pages.c
index bfbfbb7e0ff4..26c1fb8d45cc 100644
--- a/drivers/infiniband/hw/qib/qib_user_pages.c
+++ b/drivers/infiniband/hw/qib/qib_user_pages.c
@@ -37,15 +37,6 @@
 
 #include "qib.h"
 
-static void __qib_release_user_pages(struct page **p, size_t num_pages,
-				     int dirty)
-{
-	if (dirty)
-		put_user_pages_dirty_lock(p, num_pages);
-	else
-		put_user_pages(p, num_pages);
-}
-
 /**
  * qib_map_page - a safety wrapper around pci_map_page()
  *
@@ -124,7 +115,7 @@ int qib_get_user_pages(unsigned long start_page, size_t num_pages,
 
 	return 0;
 bail_release:
-	__qib_release_user_pages(p, got, 0);
+	put_user_pages_dirty_lock(p, got, false);
 bail:
 	atomic64_sub(num_pages, &current->mm->pinned_vm);
 	return ret;
@@ -132,7 +123,7 @@ int qib_get_user_pages(unsigned long start_page, size_t num_pages,
 
 void qib_release_user_pages(struct page **p, size_t num_pages)
 {
-	__qib_release_user_pages(p, num_pages, 1);
+	put_user_pages_dirty_lock(p, num_pages, true);
 
 	/* during close after signal, mm can be NULL */
 	if (current->mm)
diff --git a/drivers/infiniband/hw/usnic/usnic_uiom.c b/drivers/infiniband/hw/usnic/usnic_uiom.c
index 0b0237d41613..62e6ffa9ad78 100644
--- a/drivers/infiniband/hw/usnic/usnic_uiom.c
+++ b/drivers/infiniband/hw/usnic/usnic_uiom.c
@@ -75,10 +75,7 @@ static void usnic_uiom_put_pages(struct list_head *chunk_list, int dirty)
 		for_each_sg(chunk->page_list, sg, chunk->nents, i) {
 			page = sg_page(sg);
 			pa = sg_phys(sg);
-			if (dirty)
-				put_user_pages_dirty_lock(&page, 1);
-			else
-				put_user_page(page);
+			put_user_pages_dirty_lock(&page, 1, dirty);
 			usnic_dbg("pa: %pa\n", &pa);
 		}
 		kfree(chunk);
diff --git a/drivers/infiniband/sw/siw/siw_mem.c b/drivers/infiniband/sw/siw/siw_mem.c
index 67171c82b0c4..1e197753bf2f 100644
--- a/drivers/infiniband/sw/siw/siw_mem.c
+++ b/drivers/infiniband/sw/siw/siw_mem.c
@@ -60,20 +60,6 @@ struct siw_mem *siw_mem_id2obj(struct siw_device *sdev, int stag_index)
 	return NULL;
 }
 
-static void siw_free_plist(struct siw_page_chunk *chunk, int num_pages,
-			   bool dirty)
-{
-	struct page **p = chunk->plist;
-
-	while (num_pages--) {
-		if (!PageDirty(*p) && dirty)
-			put_user_pages_dirty_lock(p, 1);
-		else
-			put_user_page(*p);
-		p++;
-	}
-}
-
 void siw_umem_release(struct siw_umem *umem, bool dirty)
 {
 	struct mm_struct *mm_s = umem->owning_mm;
@@ -82,8 +68,9 @@ void siw_umem_release(struct siw_umem *umem, bool dirty)
 	for (i = 0; num_pages; i++) {
 		int to_free = min_t(int, PAGES_PER_CHUNK, num_pages);
 
-		siw_free_plist(&umem->page_chunk[i], to_free,
-			       umem->writable && dirty);
+		put_user_pages_dirty_lock(umem->page_chunk[i].plist,
+					  to_free,
+					  umem->writable && dirty);
 		kfree(umem->page_chunk[i].plist);
 		num_pages -= to_free;
 	}
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0334ca97c584..9759b6a24420 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1057,8 +1057,9 @@ static inline void put_user_page(struct page *page)
 	put_page(page);
 }
 
-void put_user_pages_dirty(struct page **pages, unsigned long npages);
-void put_user_pages_dirty_lock(struct page **pages, unsigned long npages);
+void put_user_pages_dirty_lock(struct page **pages, unsigned long npages,
+			       bool make_dirty);
+
 void put_user_pages(struct page **pages, unsigned long npages);
 
 #if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
diff --git a/mm/gup.c b/mm/gup.c
index 98f13ab37bac..7fefd7ab02c4 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -29,85 +29,70 @@ struct follow_page_context {
 	unsigned int page_mask;
 };
 
-typedef int (*set_dirty_func_t)(struct page *page);
-
-static void __put_user_pages_dirty(struct page **pages,
-				   unsigned long npages,
-				   set_dirty_func_t sdf)
-{
-	unsigned long index;
-
-	for (index = 0; index < npages; index++) {
-		struct page *page = compound_head(pages[index]);
-
-		/*
-		 * Checking PageDirty at this point may race with
-		 * clear_page_dirty_for_io(), but that's OK. Two key cases:
-		 *
-		 * 1) This code sees the page as already dirty, so it skips
-		 * the call to sdf(). That could happen because
-		 * clear_page_dirty_for_io() called page_mkclean(),
-		 * followed by set_page_dirty(). However, now the page is
-		 * going to get written back, which meets the original
-		 * intention of setting it dirty, so all is well:
-		 * clear_page_dirty_for_io() goes on to call
-		 * TestClearPageDirty(), and write the page back.
-		 *
-		 * 2) This code sees the page as clean, so it calls sdf().
-		 * The page stays dirty, despite being written back, so it
-		 * gets written back again in the next writeback cycle.
-		 * This is harmless.
-		 */
-		if (!PageDirty(page))
-			sdf(page);
-
-		put_user_page(page);
-	}
-}
-
 /**
- * put_user_pages_dirty() - release and dirty an array of gup-pinned pages
- * @pages:  array of pages to be marked dirty and released.
+ * put_user_pages_dirty_lock() - release and optionally dirty gup-pinned pages
+ * @pages:  array of pages to be maybe marked dirty, and definitely released.
  * @npages: number of pages in the @pages array.
+ * @make_dirty: whether to mark the pages dirty
  *
  * "gup-pinned page" refers to a page that has had one of the get_user_pages()
  * variants called on that page.
  *
  * For each page in the @pages array, make that page (or its head page, if a
- * compound page) dirty, if it was previously listed as clean. Then, release
- * the page using put_user_page().
+ * compound page) dirty, if @make_dirty is true, and if the page was previously
+ * listed as clean. In any case, releases all pages using put_user_page(),
+ * possibly via put_user_pages(), for the non-dirty case.
  *
  * Please see the put_user_page() documentation for details.
  *
- * set_page_dirty(), which does not lock the page, is used here.
- * Therefore, it is the caller's responsibility to ensure that this is
- * safe. If not, then put_user_pages_dirty_lock() should be called instead.
+ * set_page_dirty_lock() is used internally. If instead, set_page_dirty() is
+ * required, then the caller should a) verify that this is really correct,
+ * because _lock() is usually required, and b) hand code it:
+ * set_page_dirty_lock(), put_user_page().
  *
  */
-void put_user_pages_dirty(struct page **pages, unsigned long npages)
+void put_user_pages_dirty_lock(struct page **pages, unsigned long npages,
+			       bool make_dirty)
 {
-	__put_user_pages_dirty(pages, npages, set_page_dirty);
-}
-EXPORT_SYMBOL(put_user_pages_dirty);
+	unsigned long index;
 
-/**
- * put_user_pages_dirty_lock() - release and dirty an array of gup-pinned pages
- * @pages:  array of pages to be marked dirty and released.
- * @npages: number of pages in the @pages array.
- *
- * For each page in the @pages array, make that page (or its head page, if a
- * compound page) dirty, if it was previously listed as clean. Then, release
- * the page using put_user_page().
- *
- * Please see the put_user_page() documentation for details.
- *
- * This is just like put_user_pages_dirty(), except that it invokes
- * set_page_dirty_lock(), instead of set_page_dirty().
- *
- */
-void put_user_pages_dirty_lock(struct page **pages, unsigned long npages)
-{
-	__put_user_pages_dirty(pages, npages, set_page_dirty_lock);
+	/*
+	 * TODO: this can be optimized for huge pages: if a series of pages is
+	 * physically contiguous and part of the same compound page, then a
+	 * single operation to the head page should suffice.
+	 */
+
+	if (!make_dirty) {
+		put_user_pages(pages, npages);
+		return;
+	}
+
+	for (index = 0; index < npages; index++) {
+		struct page *page = compound_head(pages[index]);
+		/*
+		 * Checking PageDirty at this point may race with
+		 * clear_page_dirty_for_io(), but that's OK. Two key
+		 * cases:
+		 *
+		 * 1) This code sees the page as already dirty, so it
+		 * skips the call to set_page_dirty(). That could happen
+		 * because clear_page_dirty_for_io() called
+		 * page_mkclean(), followed by set_page_dirty().
+		 * However, now the page is going to get written back,
+		 * which meets the original intention of setting it
+		 * dirty, so all is well: clear_page_dirty_for_io() goes
+		 * on to call TestClearPageDirty(), and write the page
+		 * back.
+		 *
+		 * 2) This code sees the page as clean, so it calls
+		 * set_page_dirty(). The page stays dirty, despite being
+		 * written back, so it gets written back again in the
+		 * next writeback cycle. This is harmless.
+		 */
+		if (!PageDirty(page))
+			set_page_dirty_lock(page);
+		put_user_page(page);
+	}
 }
 EXPORT_SYMBOL(put_user_pages_dirty_lock);
 
-- 
2.22.0

