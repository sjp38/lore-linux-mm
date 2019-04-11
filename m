Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0AF3C282E0
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 21:09:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7852D20850
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 21:09:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7852D20850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7BCA66B026F; Thu, 11 Apr 2019 17:09:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 76DAF6B0270; Thu, 11 Apr 2019 17:09:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 610026B0271; Thu, 11 Apr 2019 17:09:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3D19C6B026F
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 17:09:00 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id h51so6772416qte.22
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 14:09:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Gov63VTi0un9dLWg9omlFEgYS60McwcNyB2C4BW8sEA=;
        b=FP+PHSByZRpwhDe1e5/e57JbkFdoEXX/T7jQcq4vdxV12tCzQmgZkj31mdKfmYUNxR
         +46yMchimLVCoPIiRLjJw6xdLLZpcWO8en2fgZktTv2HpSfzYRF1/uTI1IqMgDCvKNZr
         S/9CpXSTJVJPDgh9BFVjUIdb7uB+0m/O/Wf7hfjNldLRs/aJKamvs6APwNDJAlElCHiA
         oQ+ux6pvQ1efxhgxN62eNKimHLPQRyffKK5i9Hs8S496jeXmFCYvmMK1gLgS5LcVnunW
         /wxMXWF3y8o3ibqF2UhW6MyWkJoOX1Ke9g7H8W5j1YEIP0ZW8AjjFNHXvIynyvzEkfkg
         t+Jw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUdCoicIkPF5/T7jvNYRXrdeoHb3yfgsmE8poyEoMOpJ+Bu4a6t
	lIgDa3DVrw3YXkJFxHKnnuUPkYcEmIUkovF8n6yVdwoqq1CPs8Uj1I1pWdnmUlMSyJbdO2Z+28w
	iT/Rx2mYMnUPujM2EOsi3d4WOSx5YwDd0uf2ClDLBD87guQlPLbl8zK6vOk7fqj2u7w==
X-Received: by 2002:ac8:1738:: with SMTP id w53mr42845625qtj.201.1555016940008;
        Thu, 11 Apr 2019 14:09:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztIKIDpOe1yQoFdbcT72bXNTF5MVovxGZZynyfCZxUe1n8kZA7W4RcKLSOADcj7sHbVskg
X-Received: by 2002:ac8:1738:: with SMTP id w53mr42845535qtj.201.1555016938904;
        Thu, 11 Apr 2019 14:08:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555016938; cv=none;
        d=google.com; s=arc-20160816;
        b=xePym1NYEGh/TBxe+PxDGcNQFRELYqvGRcc8tsDJ3OvvpLvDz51ix28xvdlGI2xnaW
         2OEWrSQ/7R3RJzQ684b+LtRKKDcjm2OMT6GCo9741bzJqtew9zP/80sr6dssxRK0ZHHw
         esXtiBOMeFQLumYckFIv1cXmrReRMvwBePk2RG0um0R+rtyVDaJP42FKwQWs12fw5CCx
         xXuugkDGE9Ak4K8coqB/JQvmP1mGYUsqh5qH0h4yofnImdVhW/omk3yBGt/mGGg+NT1c
         aPlqzZyS14zXgOdW8EekmGfHjX89/oOsbrDLERgZp1/z8TN8oJh9ajOKae7BiM9g4PFm
         cxOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Gov63VTi0un9dLWg9omlFEgYS60McwcNyB2C4BW8sEA=;
        b=loUlXTKaMcYP33uGjVKMaMlOsZFb8FqG63avjm7Srlx4WnL75TAy16aILjb+I/Hk8X
         cKPDjYqZaPdDtj/AWUINKt2es+iaRjyXSmRD+GGN6TSqwK5R2VMIPQfyUN7D9XpuQr3H
         PJ2EpE/mwGeIcn8FyhDBIpFO3TxE0i41mkl0ut/TTOVMD4pWAzJ7OVPmARO/NNe22ruO
         zCOOYvBykZ6fdVQYkxXFeJh9kEWRn+Cn/1xfMxha40x5HCt12Km+Q5kNYPFrX1cooLNg
         y5kx27Y3/Y/t9unHnSjucLzv8Z9B5GEZLcHUmo9ixmMz0jreI0UVx8TouC1evCUT4m5L
         0aWg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p26si1608808qkm.63.2019.04.11.14.08.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 14:08:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E0FA5DC8FB;
	Thu, 11 Apr 2019 21:08:57 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 397AA5C220;
	Thu, 11 Apr 2019 21:08:54 +0000 (UTC)
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
	Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v1 06/15] block: convert bio_vec.bv_page to bv_pfn to store pfn and not page
Date: Thu, 11 Apr 2019 17:08:25 -0400
Message-Id: <20190411210834.4105-7-jglisse@redhat.com>
In-Reply-To: <20190411210834.4105-1-jglisse@redhat.com>
References: <20190411210834.4105-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Thu, 11 Apr 2019 21:08:58 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

To be able to store flags with each bio_vec store the pfn value and
not the page this leave us with couple uppers bits we can latter use
for flags.

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
---
 Documentation/block/biodoc.txt |  7 +++++--
 include/linux/bvec.h           | 29 +++++++++++++++++++++--------
 2 files changed, 26 insertions(+), 10 deletions(-)

diff --git a/Documentation/block/biodoc.txt b/Documentation/block/biodoc.txt
index ac18b488cb5e..c673d4285781 100644
--- a/Documentation/block/biodoc.txt
+++ b/Documentation/block/biodoc.txt
@@ -410,7 +410,7 @@ mapped to bio structures.
 2.2 The bio struct
 
 The bio structure uses a vector representation pointing to an array of tuples
-of <page, offset, len> to describe the i/o buffer, and has various other
+of <pfn, offset, len> to describe the i/o buffer, and has various other
 fields describing i/o parameters and state that needs to be maintained for
 performing the i/o.
 
@@ -418,11 +418,14 @@ Notice that this representation means that a bio has no virtual address
 mapping at all (unlike buffer heads).
 
 struct bio_vec {
-       struct page     *bv_page;
+       unsigned long   *bv_pfn;
        unsigned short  bv_len;
        unsigned short  bv_offset;
 };
 
+You should not access the bv_pfn fields directly but use helpers to get the
+corresponding struct page as bv_pfn can encode more than page pfn value.
+
 /*
  * main unit of I/O for the block layer and lower layers (ie drivers)
  */
diff --git a/include/linux/bvec.h b/include/linux/bvec.h
index d701cd968f13..ac84ac66a333 100644
--- a/include/linux/bvec.h
+++ b/include/linux/bvec.h
@@ -29,7 +29,7 @@
  * was unsigned short, but we might as well be ready for > 64kB I/O pages
  */
 struct bio_vec {
-	struct page	*bv_page;
+	unsigned long	bv_pfn;
 	unsigned int	bv_len;
 	unsigned int	bv_offset;
 };
@@ -51,14 +51,19 @@ struct bvec_iter_all {
 	unsigned	done;
 };
 
+static inline unsigned long page_to_bvec_pfn(struct page *page)
+{
+	return page ? page_to_pfn(page) : -1UL;
+}
+
 static inline struct page *bvec_page(const struct bio_vec *bvec)
 {
-	return bvec->bv_page;
+	return bvec->bv_pfn == -1UL ? NULL : pfn_to_page(bvec->bv_pfn);
 }
 
 static inline void bvec_set_page(struct bio_vec *bvec, struct page *page)
 {
-	bvec->bv_page = page;
+	bvec->bv_pfn = page_to_bvec_pfn(page);
 }
 
 static inline struct page *bvec_nth_page(struct page *page, int idx)
@@ -70,11 +75,15 @@ static inline struct page *bvec_nth_page(struct page *page, int idx)
  * various member access, note that bio_data should of course not be used
  * on highmem page vectors
  */
-#define BIO_VEC_INIT(p, l, o) {.bv_page = (p), .bv_len = (l), .bv_offset = (o)}
+#define BIO_VEC_INIT(p, l, o) {.bv_pfn = page_to_bvec_pfn(p), \
+				.bv_len = (l), .bv_offset = (o)}
 
 #define __bvec_iter_bvec(bvec, iter)	(&(bvec)[(iter).bi_idx])
 
 /* multi-page (mp_bvec) helpers */
+#define mp_bvec_iter_pfn(bvec, iter)				\
+	((__bvec_iter_bvec((bvec), (iter)))->bv_pfn)
+
 #define mp_bvec_iter_page(bvec, iter)				\
 	(bvec_page(__bvec_iter_bvec((bvec), (iter))))
 
@@ -90,7 +99,7 @@ static inline struct page *bvec_nth_page(struct page *page, int idx)
 
 #define mp_bvec_iter_bvec(bvec, iter)				\
 ((struct bio_vec) {						\
-	.bv_page	= mp_bvec_iter_page((bvec), (iter)),	\
+	.bv_pfn		= mp_bvec_iter_pfn((bvec), (iter)),	\
 	.bv_len		= mp_bvec_iter_len((bvec), (iter)),	\
 	.bv_offset	= mp_bvec_iter_offset((bvec), (iter)),	\
 })
@@ -100,16 +109,20 @@ static inline struct page *bvec_nth_page(struct page *page, int idx)
 	(mp_bvec_iter_offset((bvec), (iter)) % PAGE_SIZE)
 
 #define bvec_iter_len(bvec, iter)				\
-	min_t(unsigned, mp_bvec_iter_len((bvec), (iter)),		\
+	min_t(unsigned, mp_bvec_iter_len((bvec), (iter)),	\
 	      PAGE_SIZE - bvec_iter_offset((bvec), (iter)))
 
 #define bvec_iter_page(bvec, iter)				\
-	bvec_nth_page(mp_bvec_iter_page((bvec), (iter)),		\
+	bvec_nth_page(mp_bvec_iter_page((bvec), (iter)),	\
 		      mp_bvec_iter_page_idx((bvec), (iter)))
 
+#define bvec_iter_pfn(bvec, iter)				\
+	(mp_bvec_iter_pfn((bvec), (iter)) +			\
+	 mp_bvec_iter_page_idx((bvec), (iter)))
+
 #define bvec_iter_bvec(bvec, iter)				\
 ((struct bio_vec) {						\
-	.bv_page	= bvec_iter_page((bvec), (iter)),	\
+	.bv_pfn		= bvec_iter_pfn((bvec), (iter)),	\
 	.bv_len		= bvec_iter_len((bvec), (iter)),	\
 	.bv_offset	= bvec_iter_offset((bvec), (iter)),	\
 })
-- 
2.20.1

