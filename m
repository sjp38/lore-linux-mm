Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4367AC10F14
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 21:08:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E3A3020850
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 21:08:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E3A3020850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F0E76B026C; Thu, 11 Apr 2019 17:08:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 553BE6B026D; Thu, 11 Apr 2019 17:08:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C3AD6B026E; Thu, 11 Apr 2019 17:08:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1A0096B026C
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 17:08:52 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id d8so6177590qkk.17
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 14:08:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=W/N1NPAdMMPgiENmVjRvzAftohKD0XW58WPEDgE8mHY=;
        b=G4AnKXFm4ps8pjb2BWQpJKW8c/2vO8D39t8KTDyCQygGheTZbM3g/SwxFLl6zBLE+o
         t8T/THJ5VWmzpN5kIvKG+YEugS/J8E1xZe2DI/gjMeZuOawtCo0qWCqPJl4lRhm4eJSj
         ccvfi0BU1NINSaCisrZ4IODO3xPQ9jNAMnefgvaxaeTgL1lZFG1ZcGUfSVu0LRzkXzvn
         F1llidFzyQToE1Q7Nqa2PZYiOCiiAtH0EdcbPBxSWBaVtxBBux7+Vp+BJy/fbu9nnRpr
         DUeJiE7+Le+iAgNSaJts6TgNZO0WWcEc5LumfdVoFmBdpKp3mSP3EgBH/grZ5Y0jqL2L
         2i3w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWK02B09gFLzgUiit3m5mngy15KouYOxeq44GT7A4a4jBwN9uUu
	Vby5cfR4Uo+MMtRMcxme67cv2erBDmKKFRzynOm8CA7nPmGYLD5TkpYhbV6LNMt2bEQ2x04kumY
	E4jI/rMqTLQ0SbjR01z8SgOtV/39pOtL3hui/zRVIjBYhie1pUW4swzF783Zp3aKgOA==
X-Received: by 2002:ac8:6646:: with SMTP id j6mr43297789qtp.197.1555016931798;
        Thu, 11 Apr 2019 14:08:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwH0wTkvwGmXccmhYXz4ineO7yCwpQnYqJPr4oPbA/Ai+nqM71CVniXZVL0oPE2jYS5FodG
X-Received: by 2002:ac8:6646:: with SMTP id j6mr43297678qtp.197.1555016930534;
        Thu, 11 Apr 2019 14:08:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555016930; cv=none;
        d=google.com; s=arc-20160816;
        b=bRozwUrtVr/T3W4rdeNGqkAZEn7+Aa/Q++7HPtjmSb+gHYid0Lj3WtLWn1fam3WJqf
         OZ82tlEZDRThQGDNKOEc5gUJkNR4JX/eiA6icIt8OxSx733zgetUDC3XtgWeSm40huAh
         PxsGBytztWdlXdpYJEwIg44o7Qvf+f/VdWqfVcUuGB8G4E6WeAw6bNbKIPm9Ybl0a4f3
         bZ4J4j4n6iqiyXRK0S4oZbj3l7fxoLRyKj30Z7fwA66WYwCSc5Fs5A5Ya6l7tUYLqZ5b
         B38cCxWYSjVJzNbmptB1OATe2UM4kDXDlxd7I3SF1Qvf5NgHUHa5eftVUAnS47shDh4V
         kUlg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=W/N1NPAdMMPgiENmVjRvzAftohKD0XW58WPEDgE8mHY=;
        b=Av436I/UI7mpZrmuCHMN87j44I0bFC9z/zWm41FmiDYIV6gpAgSOq56X88mWPiphR6
         oVt/4D50fNtpjqetCJTjJ3LsDjgLzs6V+3S0Fm1vMjP63GxAIfPDCvu4+k4Tna1K5W9i
         1xo9xs6hF7dGFUojUsAcNyxbca88JMdp5Uv07BNncFr7CU8XwWeuL9943TyKczyoFZT5
         rohBjvH3hO7Z20EqHexiVwXT081RPg/9Mc5BeXkuHOs6vzK5r1fOKVNs4KgpUHbmazQq
         VLcut5k8nwcNc+BjClrA5H+PRvB90xURWGkvLKmW6cXGz0n/wxNbcDNQ7oWeOmUJqTpE
         KpLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i28si5825726qkk.260.2019.04.11.14.08.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 14:08:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 909725AFF4;
	Thu, 11 Apr 2019 21:08:49 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id DB0BE5C219;
	Thu, 11 Apr 2019 21:08:47 +0000 (UTC)
From: jglisse@redhat.com
To: linux-kernel@vger.kernel.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org,
	linux-block@vger.kernel.org,
	linux-mm@kvack.org,
	John Hubbard <jhubbard@nvidia.com>,
	Jan Kara <jack@suse.cz>,
	Dan Williams <dan.j.williams@intel.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Christoph Hellwig <hch@lst.de>,
	Jens Axboe <axboe@kernel.dk>,
	Ming Lei <ming.lei@redhat.com>,
	Dave Chinner <david@fromorbit.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Matthew Wilcox <willy@infradead.org>,
	Coly Li <colyli@suse.de>,
	Kent Overstreet <kent.overstreet@gmail.com>,
	linux-bcache@vger.kernel.org
Subject: [PATCH v1 03/15] block: introduce bvec_page()/bvec_set_page() to get/set bio_vec.bv_page
Date: Thu, 11 Apr 2019 17:08:22 -0400
Message-Id: <20190411210834.4105-4-jglisse@redhat.com>
In-Reply-To: <20190411210834.4105-1-jglisse@redhat.com>
References: <20190411210834.4105-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Thu, 11 Apr 2019 21:08:49 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

This add an helper to lookup the page a bvec struct points to. We want
to convert all direct dereference of bvec->page to call to those helpers
so that we can change the bvec->page fields.

To make coccinelle convertion (in latter patch) easier this patch also
do update some macro and some code that coccinelle is not able to match.

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-block@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Johannes Thumshirn <jthumshirn@suse.de>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Ming Lei <ming.lei@redhat.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Coly Li <colyli@suse.de>
Cc: Kent Overstreet <kent.overstreet@gmail.com>
Cc: linux-bcache@vger.kernel.org
---
 block/bounce.c            |  2 +-
 drivers/block/rbd.c       |  2 +-
 drivers/md/bcache/btree.c |  2 +-
 include/linux/bvec.h      | 14 ++++++++++++--
 lib/iov_iter.c            | 32 ++++++++++++++++----------------
 5 files changed, 31 insertions(+), 21 deletions(-)

diff --git a/block/bounce.c b/block/bounce.c
index 47eb7e936e22..d6ba1cac969f 100644
--- a/block/bounce.c
+++ b/block/bounce.c
@@ -85,7 +85,7 @@ static void bounce_copy_vec(struct bio_vec *to, unsigned char *vfrom)
 #else /* CONFIG_HIGHMEM */
 
 #define bounce_copy_vec(to, vfrom)	\
-	memcpy(page_address((to)->bv_page) + (to)->bv_offset, vfrom, (to)->bv_len)
+	memcpy(page_address(bvec_page(to)) + (to)->bv_offset, vfrom, (to)->bv_len)
 
 #endif /* CONFIG_HIGHMEM */
 
diff --git a/drivers/block/rbd.c b/drivers/block/rbd.c
index 2210c1b9491b..aa3b82be5946 100644
--- a/drivers/block/rbd.c
+++ b/drivers/block/rbd.c
@@ -2454,7 +2454,7 @@ static bool is_zero_bvecs(struct bio_vec *bvecs, u32 bytes)
 	};
 
 	ceph_bvec_iter_advance_step(&it, bytes, ({
-		if (memchr_inv(page_address(bv.bv_page) + bv.bv_offset, 0,
+		if (memchr_inv(page_address(bvec_page(&bv)) + bv.bv_offset, 0,
 			       bv.bv_len))
 			return false;
 	}));
diff --git a/drivers/md/bcache/btree.c b/drivers/md/bcache/btree.c
index 64def336f053..b5f3168dc5ff 100644
--- a/drivers/md/bcache/btree.c
+++ b/drivers/md/bcache/btree.c
@@ -435,7 +435,7 @@ static void do_btree_node_write(struct btree *b)
 		struct bvec_iter_all iter_all;
 
 		bio_for_each_segment_all(bv, b->bio, j, iter_all)
-			memcpy(page_address(bv->bv_page),
+			memcpy(page_address(bvec_page(bv)),
 			       base + j * PAGE_SIZE, PAGE_SIZE);
 
 		bch_submit_bbio(b->bio, b->c, &k.key, 0);
diff --git a/include/linux/bvec.h b/include/linux/bvec.h
index f6275c4da13a..44866555258a 100644
--- a/include/linux/bvec.h
+++ b/include/linux/bvec.h
@@ -51,6 +51,16 @@ struct bvec_iter_all {
 	unsigned	done;
 };
 
+static inline struct page *bvec_page(const struct bio_vec *bvec)
+{
+	return bvec->bv_page;
+}
+
+static inline void bvec_set_page(struct bio_vec *bvec, struct page *page)
+{
+	bvec->bv_page = page;
+}
+
 static inline struct page *bvec_nth_page(struct page *page, int idx)
 {
 	return idx == 0 ? page : nth_page(page, idx);
@@ -64,7 +74,7 @@ static inline struct page *bvec_nth_page(struct page *page, int idx)
 
 /* multi-page (mp_bvec) helpers */
 #define mp_bvec_iter_page(bvec, iter)				\
-	(__bvec_iter_bvec((bvec), (iter))->bv_page)
+	(bvec_page(__bvec_iter_bvec((bvec), (iter))))
 
 #define mp_bvec_iter_len(bvec, iter)				\
 	min((iter).bi_size,					\
@@ -192,6 +202,6 @@ static inline void mp_bvec_last_segment(const struct bio_vec *bvec,
 #define mp_bvec_for_each_page(pg, bv, i)				\
 	for (i = (bv)->bv_offset / PAGE_SIZE;				\
 		(i <= (((bv)->bv_offset + (bv)->bv_len - 1) / PAGE_SIZE)) && \
-		(pg = bvec_nth_page((bv)->bv_page, i)); i += 1)
+		(pg = bvec_nth_page(bvec_page(bv), i)); i += 1)
 
 #endif /* __LINUX_BVEC_ITER_H */
diff --git a/lib/iov_iter.c b/lib/iov_iter.c
index ea36dc355da1..e20a3b1d8b0e 100644
--- a/lib/iov_iter.c
+++ b/lib/iov_iter.c
@@ -608,7 +608,7 @@ size_t _copy_to_iter(const void *addr, size_t bytes, struct iov_iter *i)
 		might_fault();
 	iterate_and_advance(i, bytes, v,
 		copyout(v.iov_base, (from += v.iov_len) - v.iov_len, v.iov_len),
-		memcpy_to_page(v.bv_page, v.bv_offset,
+		memcpy_to_page(bvec_page(&v), v.bv_offset,
 			       (from += v.bv_len) - v.bv_len, v.bv_len),
 		memcpy(v.iov_base, (from += v.iov_len) - v.iov_len, v.iov_len)
 	)
@@ -709,7 +709,7 @@ size_t _copy_to_iter_mcsafe(const void *addr, size_t bytes, struct iov_iter *i)
 	iterate_and_advance(i, bytes, v,
 		copyout_mcsafe(v.iov_base, (from += v.iov_len) - v.iov_len, v.iov_len),
 		({
-		rem = memcpy_mcsafe_to_page(v.bv_page, v.bv_offset,
+		rem = memcpy_mcsafe_to_page(bvec_page(&v), v.bv_offset,
                                (from += v.bv_len) - v.bv_len, v.bv_len);
 		if (rem) {
 			curr_addr = (unsigned long) from;
@@ -744,7 +744,7 @@ size_t _copy_from_iter(void *addr, size_t bytes, struct iov_iter *i)
 		might_fault();
 	iterate_and_advance(i, bytes, v,
 		copyin((to += v.iov_len) - v.iov_len, v.iov_base, v.iov_len),
-		memcpy_from_page((to += v.bv_len) - v.bv_len, v.bv_page,
+		memcpy_from_page((to += v.bv_len) - v.bv_len, bvec_page(&v),
 				 v.bv_offset, v.bv_len),
 		memcpy((to += v.iov_len) - v.iov_len, v.iov_base, v.iov_len)
 	)
@@ -770,7 +770,7 @@ bool _copy_from_iter_full(void *addr, size_t bytes, struct iov_iter *i)
 				      v.iov_base, v.iov_len))
 			return false;
 		0;}),
-		memcpy_from_page((to += v.bv_len) - v.bv_len, v.bv_page,
+		memcpy_from_page((to += v.bv_len) - v.bv_len, bvec_page(&v),
 				 v.bv_offset, v.bv_len),
 		memcpy((to += v.iov_len) - v.iov_len, v.iov_base, v.iov_len)
 	)
@@ -790,7 +790,7 @@ size_t _copy_from_iter_nocache(void *addr, size_t bytes, struct iov_iter *i)
 	iterate_and_advance(i, bytes, v,
 		__copy_from_user_inatomic_nocache((to += v.iov_len) - v.iov_len,
 					 v.iov_base, v.iov_len),
-		memcpy_from_page((to += v.bv_len) - v.bv_len, v.bv_page,
+		memcpy_from_page((to += v.bv_len) - v.bv_len, bvec_page(&v),
 				 v.bv_offset, v.bv_len),
 		memcpy((to += v.iov_len) - v.iov_len, v.iov_base, v.iov_len)
 	)
@@ -824,7 +824,7 @@ size_t _copy_from_iter_flushcache(void *addr, size_t bytes, struct iov_iter *i)
 	iterate_and_advance(i, bytes, v,
 		__copy_from_user_flushcache((to += v.iov_len) - v.iov_len,
 					 v.iov_base, v.iov_len),
-		memcpy_page_flushcache((to += v.bv_len) - v.bv_len, v.bv_page,
+		memcpy_page_flushcache((to += v.bv_len) - v.bv_len, bvec_page(&v),
 				 v.bv_offset, v.bv_len),
 		memcpy_flushcache((to += v.iov_len) - v.iov_len, v.iov_base,
 			v.iov_len)
@@ -849,7 +849,7 @@ bool _copy_from_iter_full_nocache(void *addr, size_t bytes, struct iov_iter *i)
 					     v.iov_base, v.iov_len))
 			return false;
 		0;}),
-		memcpy_from_page((to += v.bv_len) - v.bv_len, v.bv_page,
+		memcpy_from_page((to += v.bv_len) - v.bv_len, bvec_page(&v),
 				 v.bv_offset, v.bv_len),
 		memcpy((to += v.iov_len) - v.iov_len, v.iov_base, v.iov_len)
 	)
@@ -951,7 +951,7 @@ size_t iov_iter_zero(size_t bytes, struct iov_iter *i)
 		return pipe_zero(bytes, i);
 	iterate_and_advance(i, bytes, v,
 		clear_user(v.iov_base, v.iov_len),
-		memzero_page(v.bv_page, v.bv_offset, v.bv_len),
+		memzero_page(bvec_page(&v), v.bv_offset, v.bv_len),
 		memset(v.iov_base, 0, v.iov_len)
 	)
 
@@ -974,7 +974,7 @@ size_t iov_iter_copy_from_user_atomic(struct page *page,
 	}
 	iterate_all_kinds(i, bytes, v,
 		copyin((p += v.iov_len) - v.iov_len, v.iov_base, v.iov_len),
-		memcpy_from_page((p += v.bv_len) - v.bv_len, v.bv_page,
+		memcpy_from_page((p += v.bv_len) - v.bv_len, bvec_page(&v),
 				 v.bv_offset, v.bv_len),
 		memcpy((p += v.iov_len) - v.iov_len, v.iov_base, v.iov_len)
 	)
@@ -1300,7 +1300,7 @@ ssize_t iov_iter_get_pages(struct iov_iter *i,
 	0;}),({
 		/* can't be more than PAGE_SIZE */
 		*start = v.bv_offset;
-		get_page(*pages = v.bv_page);
+		get_page(*pages = bvec_page(&v));
 		return v.bv_len;
 	}),({
 		return -EFAULT;
@@ -1387,7 +1387,7 @@ ssize_t iov_iter_get_pages_alloc(struct iov_iter *i,
 		*pages = p = get_pages_array(1);
 		if (!p)
 			return -ENOMEM;
-		get_page(*p = v.bv_page);
+		get_page(*p = bvec_page(&v));
 		return v.bv_len;
 	}),({
 		return -EFAULT;
@@ -1419,7 +1419,7 @@ size_t csum_and_copy_from_iter(void *addr, size_t bytes, __wsum *csum,
 		}
 		err ? v.iov_len : 0;
 	}), ({
-		char *p = kmap_atomic(v.bv_page);
+		char *p = kmap_atomic(bvec_page(&v));
 		sum = csum_and_memcpy((to += v.bv_len) - v.bv_len,
 				      p + v.bv_offset, v.bv_len,
 				      sum, off);
@@ -1461,7 +1461,7 @@ bool csum_and_copy_from_iter_full(void *addr, size_t bytes, __wsum *csum,
 		off += v.iov_len;
 		0;
 	}), ({
-		char *p = kmap_atomic(v.bv_page);
+		char *p = kmap_atomic(bvec_page(&v));
 		sum = csum_and_memcpy((to += v.bv_len) - v.bv_len,
 				      p + v.bv_offset, v.bv_len,
 				      sum, off);
@@ -1507,7 +1507,7 @@ size_t csum_and_copy_to_iter(const void *addr, size_t bytes, void *csump,
 		}
 		err ? v.iov_len : 0;
 	}), ({
-		char *p = kmap_atomic(v.bv_page);
+		char *p = kmap_atomic(bvec_page(&v));
 		sum = csum_and_memcpy(p + v.bv_offset,
 				      (from += v.bv_len) - v.bv_len,
 				      v.bv_len, sum, off);
@@ -1696,10 +1696,10 @@ int iov_iter_for_each_range(struct iov_iter *i, size_t bytes,
 		return 0;
 
 	iterate_all_kinds(i, bytes, v, -EINVAL, ({
-		w.iov_base = kmap(v.bv_page) + v.bv_offset;
+		w.iov_base = kmap(bvec_page(&v)) + v.bv_offset;
 		w.iov_len = v.bv_len;
 		err = f(&w, context);
-		kunmap(v.bv_page);
+		kunmap(bvec_page(&v));
 		err;}), ({
 		w = v;
 		err = f(&w, context);})
-- 
2.20.1

