Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4FF36C433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:33:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF0DC217D9
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:33:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BTuTOhHS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF0DC217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 91B126B0006; Tue,  6 Aug 2019 21:33:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A5FC6B0007; Tue,  6 Aug 2019 21:33:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 570896B0008; Tue,  6 Aug 2019 21:33:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1A7AB6B0006
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:33:48 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id m17so47076748pgh.21
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:33:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=4akykUxH2KxKuvwfnCStCJj6GMSMvpgFOQ+wq4ARE7Y=;
        b=UhjcrHM+9SloVrYF7NkOBn9v0nDK/V56JbU9WN/XpWoGNHz/0M8hQcPcbEjGeOUhDA
         YbDUmge/AFdfUeM4D7EN7waIF5Hqgic3Z9v+RRHGqO/LGF3kVKWnJvmtdmaG0filhNa6
         lb/ghgmccDDZWu511PMm+2hAGyDbZvZPTqzWSn5IjCZO6GHQf5eV7GOApJPPv2Ewinx0
         6P1JWgcn65q5gB4+AL1JCsPjA87ok1h9IYUX7qobb5RElkwJknOfmSL037osbItj7pRz
         4iYVeVJcsM5/O6/TYIuHbGh0RrjYAvyeCi4mTzHWvh93cVq95y/dE7kRnDuQF0lXeePA
         ML2Q==
X-Gm-Message-State: APjAAAUOfEdKm/VM91+aat+NAaIVYZ9YHJswldS3Uk8J1IOuE4Hb0OXC
	qags4Afi2iKvPBaJZZFH1b77j90C6E4/OX2q97cKAJFo1hKZwzpqcHMxx0T07fEX+BwYvA4hJzl
	++fo3cGndKZ/YnmVTd+N/1O0leLiOiTUg4bFLwOtF8XQYYnTyPbEZspAUMryg/4EU0A==
X-Received: by 2002:a17:902:6b85:: with SMTP id p5mr5703967plk.225.1565141627739;
        Tue, 06 Aug 2019 18:33:47 -0700 (PDT)
X-Received: by 2002:a17:902:6b85:: with SMTP id p5mr5703908plk.225.1565141626755;
        Tue, 06 Aug 2019 18:33:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141626; cv=none;
        d=google.com; s=arc-20160816;
        b=KXMgpHnLb08iXyk1w2xHBEBAmZxGoxQF7+YnqkFkiqUqoco6Bmmv4ILs+ucP+UwsXk
         IDyNwQP2Vvst8zvDdEuN2KhfGCM9yr2gHNp4dSPvFhydPLWmqshVaqFgVS2b41RuT9+R
         b5aleQvOl3uemq1dnbRcSzXQC2iHZ4YQ1S6xpDdt4dI8a66lavlpGgtP27QR2droYpT3
         8b0tk/NlzDMMRz9w7wvMxqLZ3FQrz6Ms6qL4GHUYsEBSfle37YYhBcVeAzqy6nLXmKti
         PhUuc71r4+MoNkPX8cADcnZayCMUm7H2n8dMsKCU80lmjky7O5fOrEyBW60Mh6L4LVdb
         ipSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=4akykUxH2KxKuvwfnCStCJj6GMSMvpgFOQ+wq4ARE7Y=;
        b=lv0jgcTYwsWcOdjBNRWvkbISeHgquNSOzdinrUpDCBCLbl9BGJ03LB32oYJRR4z9Il
         zUr1a0O0t7VyRWkn5yDNM9uQBERjFPdkJhxed6krk14G5W/xBqC3auZ9zlBzJKBhr1Eh
         1SPDep9exXJ97TjQr/BizljJQ2oqOLnJ7J3DYAyeFrXJlUpnrARZyzqQUKsjGTOEqY0m
         YG2azTN3XuxJZrwRamiOpkOYqBkoFdixbzZEGWdz9ztTXyaRwkbMUOPDzPXLvarGykNi
         XPfl1kvpcAm7d4fkHIFXFBQu2HUEebnmplPbO38wQlKxyPJB/7hXsj2gywsaVDaJWnAE
         N21g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BTuTOhHS;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n13sor26876271pjc.24.2019.08.06.18.33.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:33:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BTuTOhHS;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=4akykUxH2KxKuvwfnCStCJj6GMSMvpgFOQ+wq4ARE7Y=;
        b=BTuTOhHSALyHLiJJfJrgxYVdEdRj89X+n2AhI5pRVlo4ueNU/tMLNAP+URjW32r6b8
         x4wB6jHXYTUs7EDYZOBU5HBi4pwi3S1VWA7Wcj7tqnMBPBIFb7mcOnVVcb2houoWoU6W
         3slEK52fIhg8Uj+zaiV/BNmacr2qelkUW51yKRkkDF/epktcDrFW6YlPml6XZi1BqLcK
         ENzpL7YRF4dGdmgStUF+D1iFpLn5tkpJ1tFedkGf0iMmyC5BHvDJYkjVkK/CaiwGWX7g
         LaicxKNPbvd4JZae6EE+9VOhEPgTUP/EaZi95PE5gVrggdEIbbzTN1RmHnxFA+oS3Md8
         dUpg==
X-Google-Smtp-Source: APXvYqwVsJZOQSwIml6vLhbn090EKpXVgy2KmUBFZJGaeJKod8dBYbI9B77G5XovazwgI3IANAmVew==
X-Received: by 2002:a17:90a:e38f:: with SMTP id b15mr6126996pjz.85.1565141626401;
        Tue, 06 Aug 2019 18:33:46 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.33.44
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:33:45 -0700 (PDT)
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
	Christoph Hellwig <hch@lst.de>,
	Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v3 01/41] mm/gup: add make_dirty arg to put_user_pages_dirty_lock()
Date: Tue,  6 Aug 2019 18:33:00 -0700
Message-Id: <20190807013340.9706-2-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190807013340.9706-1-jhubbard@nvidia.com>
References: <20190807013340.9706-1-jhubbard@nvidia.com>
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
Reviewed-by: Ira Weiny <ira.weiny@intel.com>

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
 mm/gup.c                                   | 109 ++++++++-------------
 7 files changed, 54 insertions(+), 107 deletions(-)

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
index 98f13ab37bac..7f5737edb624 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -29,85 +29,62 @@ struct follow_page_context {
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
+ * @pages:  array of pages to be put
  * @npages: number of pages in the @pages array.
+ * @make_dirty: whether to mark the pages dirty
  *
  * "gup-pinned page" refers to a page that has had one of the get_user_pages()
  * variants called on that page.
  *
- * For each page in the @pages array, make that page (or its head page, if a
- * compound page) dirty, if it was previously listed as clean. Then, release
- * the page using put_user_page().
+ * For each page in the @pages array, release the page.  If @make_dirty is
+ * true, mark the page dirty prior to release.
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

