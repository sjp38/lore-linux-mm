Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B78EC76194
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 22:34:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 327FB21985
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 22:34:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="U6/9IuL/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 327FB21985
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 664876B0005; Mon, 22 Jul 2019 18:34:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5284B6B0007; Mon, 22 Jul 2019 18:34:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3551C8E0001; Mon, 22 Jul 2019 18:34:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id F172E6B0005
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 18:34:21 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id f25so24727657pfk.14
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 15:34:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Smy6CazaiFl/H6ExmdJz5h/Ca61boss3Hwy2iE3dK+Q=;
        b=AVu9pLrq1hxB52siwjK80rU1YS4hPKNslVw4XeRobLzIPALaC58VY+ajfyoI3yVWGS
         ZOhrNKhi4W+y4n72mq0054mplQEIyMDst+iVWKbEo8PgnD8goEogtsLhWOQOG5qhcTC5
         VfLOnJQyfFnYKeMkSgxrG2M2adhDBTv8cYqYcg0zbT3LVuWiH+asTpMbZOjndhGzvmNJ
         0qRJ81Ece/j1arEpIFuhvUKxF9SXhUb/FZ5PIJakaHpb2Qkm/VCyqt7/80b5m01yHw7a
         DEJdPFVXojA4h6/Xo5HhhYdjcYqs+tuBIncvvi65Ier0nbwUPKF1DJ8xQYPSj+2dbnhB
         VMyQ==
X-Gm-Message-State: APjAAAU+IR7ekS6QyaCWWwLOiqL/EiOuYqV2+zrVtFrLDAzslk5343U5
	mjZnnoR40qgRBEaHuysYBqkIsnlQfEFLO5uFZZkU40rG+AR7bXH/mcOrPeT8JElafG+h2evAo98
	o3/zIVKjN0qHzuvdBAkf91PZ3jnbpEfNFsnjTvEgRxecHpg0jDUYmnHjfs3avl9twKQ==
X-Received: by 2002:a17:902:a50d:: with SMTP id s13mr78129491plq.12.1563834861508;
        Mon, 22 Jul 2019 15:34:21 -0700 (PDT)
X-Received: by 2002:a17:902:a50d:: with SMTP id s13mr78129437plq.12.1563834860843;
        Mon, 22 Jul 2019 15:34:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563834860; cv=none;
        d=google.com; s=arc-20160816;
        b=ATFPOFmL9lPdJhjJAaGzGk5GlikhmyBIf9ESGUHtZXwtr85XahAmAs1i4e+juXnvlV
         pHgEQlauAmgtQnkehas9e0q1DtjXNViGxALE0qs8zBOtu8cVMk7BrQ0m0bbVPxH47JbY
         YvlCsgkGk6WXm2wbJPqPP0f9jYRaQZP1sa1UigeLR0BJHy70nEDxzCgZDy8uDCy7d9+t
         HTj9ElUyGM0m/ZbAm7aiP8E2+kSGqLXZPb26nZIjGBkqEdagDNYmROm9xfDVkRf7U+Hl
         xdU4Udea0sFnwFLx9Q8Yi46nBEwjgcBrI2Sn7aOyvcctJqVPlskdOSK83XyI7GcF5wDt
         mpSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Smy6CazaiFl/H6ExmdJz5h/Ca61boss3Hwy2iE3dK+Q=;
        b=zmYQeNhdY37R9aQazuZOAhuo/i0fyc0zYaB8QyLwAfCAqI/eZ9IEAoR2I/lylu49+y
         u1nNYdp9wPxX0GRc9VrNcYj82YCrBlxQEZ5x8ijCheqvvuxGYokjInPOWmBo0cpv3Klv
         q37i04ykGdKw473t8RPryqSfCtd+/67zDVODAbzIJpJH8OQV9os7EGGtr4IGucmmRZJr
         gevwu0+X2uFXq6tA7zn4HKGN0XJmM/UcQ5DfF/KpcL3X5c8RiO3dy0dWFYwJam//Ql/4
         YF0Veo3hhxU1m2tqBCQ1eemQ5E2p3s87YX13x1R87yrnVF9wd1aoS9tetrEtc7MQ//Hx
         785A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="U6/9IuL/";
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a23sor22419527pfa.54.2019.07.22.15.34.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jul 2019 15:34:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="U6/9IuL/";
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Smy6CazaiFl/H6ExmdJz5h/Ca61boss3Hwy2iE3dK+Q=;
        b=U6/9IuL/TDFPDdHP/xEXC6qMrm1JOrSFcurq01xiF+Ds4AZyxPEN0zUc6M5cA6Ac2S
         lkz9/GilaTPQsdifymQ/iRSnBB3jF8OL7EtArtnl3P24bowo3fJlj3rjN86K6voNS6GH
         Dqmbtb60GhmjYXSXo6GRkm723W8wBuMOSeua5HmsQ6B7GzeInFzsL3p7urhRUckE7nOz
         cZAS/lxZQg2opPLxvraqp1cJo6cbVXc0mSOp571t2fjxJq+aMSbg5Xu5EFd+E1lReoM9
         BS3AbtelcWJr2yfzvyHmXxv8QcBg7OH7i3yTert2ueqfUr/6ie3hJa/sawyB9+pwB1Ts
         W4KA==
X-Google-Smtp-Source: APXvYqz/H2LrvbsAG7WTQI6TytjdHd6yi9WvqhWVYARGR3hkdauf6CDVf8InQZb+IHek/f+tTcf/6A==
X-Received: by 2002:a62:1444:: with SMTP id 65mr2422112pfu.145.1563834860576;
        Mon, 22 Jul 2019 15:34:20 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id r18sm30597570pfg.77.2019.07.22.15.34.19
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 22 Jul 2019 15:34:20 -0700 (PDT)
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
	John Hubbard <jhubbard@nvidia.com>
Subject: [PATCH 1/3] mm/gup: introduce __put_user_pages()
Date: Mon, 22 Jul 2019 15:34:13 -0700
Message-Id: <20190722223415.13269-2-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190722223415.13269-1-jhubbard@nvidia.com>
References: <20190722223415.13269-1-jhubbard@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

Add a more capable variation of put_user_pages() to the
API set, and call it from the simple ones.

The new __put_user_pages() takes an enum that handles the various
combinations of needing to call set_page_dirty() or
set_page_dirty_lock(), before calling put_user_page().

Cc: Matthew Wilcox <willy@infradead.org>
Cc: Jan Kara <jack@suse.cz>
Cc: Christoph Hellwig <hch@lst.de>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 include/linux/mm.h |  58 ++++++++++++++++++-
 mm/gup.c           | 137 ++++++++++++++++++++++-----------------------
 2 files changed, 124 insertions(+), 71 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0334ca97c584..7218585681b2 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1057,8 +1057,62 @@ static inline void put_user_page(struct page *page)
 	put_page(page);
 }
 
-void put_user_pages_dirty(struct page **pages, unsigned long npages);
-void put_user_pages_dirty_lock(struct page **pages, unsigned long npages);
+enum pup_flags_t {
+	PUP_FLAGS_CLEAN		= 0,
+	PUP_FLAGS_DIRTY		= 1,
+	PUP_FLAGS_LOCK		= 2,
+	PUP_FLAGS_DIRTY_LOCK	= 3,
+};
+
+void __put_user_pages(struct page **pages, unsigned long npages,
+		      enum pup_flags_t flags);
+
+/**
+ * put_user_pages_dirty() - release and dirty an array of gup-pinned pages
+ * @pages:  array of pages to be marked dirty and released.
+ * @npages: number of pages in the @pages array.
+ *
+ * "gup-pinned page" refers to a page that has had one of the get_user_pages()
+ * variants called on that page.
+ *
+ * For each page in the @pages array, make that page (or its head page, if a
+ * compound page) dirty, if it was previously listed as clean. Then, release
+ * the page using put_user_page().
+ *
+ * Please see the put_user_page() documentation for details.
+ *
+ * set_page_dirty(), which does not lock the page, is used here.
+ * Therefore, it is the caller's responsibility to ensure that this is
+ * safe. If not, then put_user_pages_dirty_lock() should be called instead.
+ *
+ */
+static inline void put_user_pages_dirty(struct page **pages,
+					unsigned long npages)
+{
+	__put_user_pages(pages, npages, PUP_FLAGS_DIRTY);
+}
+
+/**
+ * put_user_pages_dirty_lock() - release and dirty an array of gup-pinned pages
+ * @pages:  array of pages to be marked dirty and released.
+ * @npages: number of pages in the @pages array.
+ *
+ * For each page in the @pages array, make that page (or its head page, if a
+ * compound page) dirty, if it was previously listed as clean. Then, release
+ * the page using put_user_page().
+ *
+ * Please see the put_user_page() documentation for details.
+ *
+ * This is just like put_user_pages_dirty(), except that it invokes
+ * set_page_dirty_lock(), instead of set_page_dirty().
+ *
+ */
+static inline void put_user_pages_dirty_lock(struct page **pages,
+					     unsigned long npages)
+{
+	__put_user_pages(pages, npages, PUP_FLAGS_DIRTY_LOCK);
+}
+
 void put_user_pages(struct page **pages, unsigned long npages);
 
 #if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
diff --git a/mm/gup.c b/mm/gup.c
index 98f13ab37bac..6831ef064d76 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -29,87 +29,86 @@ struct follow_page_context {
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
+ * __put_user_pages() - release an array of gup-pinned pages.
  * @pages:  array of pages to be marked dirty and released.
  * @npages: number of pages in the @pages array.
+ * @flags: additional hints, to be applied to each page:
  *
- * "gup-pinned page" refers to a page that has had one of the get_user_pages()
- * variants called on that page.
+ *	PUP_FLAGS_CLEAN: no additional steps required. (Consider calling
+ *			 put_user_pages() directly, instead.)
  *
- * For each page in the @pages array, make that page (or its head page, if a
- * compound page) dirty, if it was previously listed as clean. Then, release
- * the page using put_user_page().
+ *	PUP_FLAGS_DIRTY: Call set_page_dirty() on the page (if not already
+ *			 dirty).
  *
- * Please see the put_user_page() documentation for details.
+ *      PUP_FLAGS_LOCK: meaningless by itself, but included in order to show
+ *			the numeric relationship between the flags.
  *
- * set_page_dirty(), which does not lock the page, is used here.
- * Therefore, it is the caller's responsibility to ensure that this is
- * safe. If not, then put_user_pages_dirty_lock() should be called instead.
+ *      PUP_FLAGS_DIRTY_LOCK: Call set_page_dirty_lock() on the page (if not
+ *			      already dirty).
  *
+ * For each page in the @pages array, release the page using put_user_page().
  */
-void put_user_pages_dirty(struct page **pages, unsigned long npages)
+void __put_user_pages(struct page **pages, unsigned long npages,
+		      enum pup_flags_t flags)
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
+	for (index = 0; index < npages; index++) {
+		struct page *page = compound_head(pages[index]);
+
+		switch (flags) {
+		case PUP_FLAGS_CLEAN:
+			break;
+
+		case PUP_FLAGS_DIRTY:
+			/*
+			 * Checking PageDirty at this point may race with
+			 * clear_page_dirty_for_io(), but that's OK. Two key
+			 * cases:
+			 *
+			 * 1) This code sees the page as already dirty, so it
+			 * skips the call to set_page_dirty(). That could happen
+			 * because clear_page_dirty_for_io() called
+			 * page_mkclean(), followed by set_page_dirty().
+			 * However, now the page is going to get written back,
+			 * which meets the original intention of setting it
+			 * dirty, so all is well: clear_page_dirty_for_io() goes
+			 * on to call TestClearPageDirty(), and write the page
+			 * back.
+			 *
+			 * 2) This code sees the page as clean, so it calls
+			 * set_page_dirty(). The page stays dirty, despite being
+			 * written back, so it gets written back again in the
+			 * next writeback cycle. This is harmless.
+			 */
+			if (!PageDirty(page))
+				set_page_dirty(page);
+			break;
+
+		case PUP_FLAGS_LOCK:
+			VM_WARN_ON_ONCE(flags == PUP_FLAGS_LOCK);
+			/*
+			 * Shouldn't happen, but treat it as _DIRTY_LOCK if
+			 * it does: fall through.
+			 */
+
+		case PUP_FLAGS_DIRTY_LOCK:
+			/* Same comments as for PUP_FLAGS_DIRTY apply here. */
+			if (!PageDirty(page))
+				set_page_dirty_lock(page);
+			break;
+		};
+		put_user_page(page);
+	}
 }
-EXPORT_SYMBOL(put_user_pages_dirty_lock);
+EXPORT_SYMBOL(__put_user_pages);
 
 /**
  * put_user_pages() - release an array of gup-pinned pages.
-- 
2.22.0

