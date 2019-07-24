Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED317C7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 04:25:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9049022387
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 04:25:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BFNUQlsl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9049022387
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B1E06B000D; Wed, 24 Jul 2019 00:25:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 93CFB8E0003; Wed, 24 Jul 2019 00:25:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7B54B8E0002; Wed, 24 Jul 2019 00:25:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 42CA96B000D
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 00:25:30 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id a5so23346985pla.3
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 21:25:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=CtboR7Ufy9O9fDFcRIuCIk1t8EIvDdcqQ3tCIzPpVTU=;
        b=Unc6BWf2BFC3CEbhB00c5MGd21bgQrF18/Sfpk3weGbl8np/UeFlNIaRrn11+QXLDz
         y33+JIm2ZiseH/FgCBSzk0v8ar0a4eva+XE7PiMn9om1H2qzMuqtf3b3SX03XLlDpADc
         EIu7HHni3bN99b8QksNLP9QYrHTHOa/8p448IKHKyvkVD1/l/DWfKj05y5ioI3l/4KbD
         Rj9u9f+ILPfsTZ2XOwbjrDEH/ZOszaZl6xnRBPmKYag0EWEXZYM2qZFac2isJj3t+LFq
         N9BSjLWSfg4AAgjyAPEpleyQ1IY6Aj2kstVYShgE8sQDx6DM6/VEVZLGsGOJf9wRrJEZ
         rZcw==
X-Gm-Message-State: APjAAAUYXmIWSKnh30LXiBPpF0iSCg0hjzhZYap6sgJ/bWMo/7PCMfYc
	HACgtaxcVkHY7SaLSDShBzRwGJxtwm/Gjsr55pjufIKwiEXwoWIXj+P5+roVJZqVC/m9/i7/ghU
	pFVOxC0pXBJTQTbaVJey5wDXOCCzEdPInHwp6Dx0QPZB4j9DtVa0bsdnyVi/Mm6DJ3A==
X-Received: by 2002:a17:902:aa03:: with SMTP id be3mr83514190plb.240.1563942329926;
        Tue, 23 Jul 2019 21:25:29 -0700 (PDT)
X-Received: by 2002:a17:902:aa03:: with SMTP id be3mr83514117plb.240.1563942328723;
        Tue, 23 Jul 2019 21:25:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563942328; cv=none;
        d=google.com; s=arc-20160816;
        b=0h4GR6MLMJviUu6ERWEbQpNQK3Llx0q1GhDm4Y0Hu2ZDcdT/TKgVqkUGyX4qONekDY
         KLtfvtymZ43cOuvYwao57wWJKBNtA4z/lbvGcTCh3ZUHKXbye0rDgYFiYaIqCO8mF2TJ
         XKrfTXyVxH9x5zhnjNaCEab2Oa5dBaU3xlpy1rjpJOwEiClweWuwfSJp0dZ6F13bXdjO
         dDzdbGinGvXPiCJ7GPwiX2wc2ain3ypQzAYZMXqEzi2280HIm/mG37fybjOfr7kD7MU2
         6S+35ea2nfruZJTe4MO8yOLUckl80AzUKpmgGH5G2xjFxLrsXisB16tWenyemS6NZhjL
         CqBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=CtboR7Ufy9O9fDFcRIuCIk1t8EIvDdcqQ3tCIzPpVTU=;
        b=Zt7nU7/PoX9LEDsDcMP6RbEVf2x/Fsw27OXDvD9I07H/4YsU+R9QDba0bm9wlrhYU7
         SbOeNIW+KXAvpbiLRu7Babu8UdiBrH/ryRLMcSYHT3FS/vuPXMKHzjmw97lMPwh4z8LO
         a4DpOABxdJd2KoeZJwGSBX3tDs0bL5mpc6bfvkpGlyePYZ1NYHngRnGQmD6OBwkjNw0i
         +MyF9VhpJSTueMqUKIa37xZgceM47BFPFTJ4mxRSJpKJ8xEfdjP+kIek7lk3zEQwrj6r
         vFXsk45Z4r5eAHVu3ZXo9E/8WD+yrJP/7FXrsxCu2r4TYBE/dIO56rcHpeTVgSQwUECM
         ki7w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BFNUQlsl;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l68sor54124492plb.69.2019.07.23.21.25.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 21:25:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BFNUQlsl;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=CtboR7Ufy9O9fDFcRIuCIk1t8EIvDdcqQ3tCIzPpVTU=;
        b=BFNUQlsly9hFNZnfDRf69ho0wDvCVUqoj8dGJpNcOiGYgy46obMbORHEMN/I5tUQuy
         K86xGPjY4b4QO+54v/Zv7nQ40O3fVB4kil84sULCnYrDgJVTXlsEFmALWYldAbZAgMBP
         fvIXv3sy0T/Ns+lBLfXM4dLPELbccf6aa9owKLeIZQZMk4ea+nMOdmYcBOB36dALtS4z
         0SnWHD/Ra8zQZlPYXX9NedMId4XeBIsKRL/2j4wXYAsw4ctlt6Th0vAum9effAlS+CNc
         g0HRax01vlO2YL0JWYjboqvm7PfjfxsTzbm2nbAhIfIebOVYGUr1FquaKAPIEQbTrE+e
         0YTg==
X-Google-Smtp-Source: APXvYqw2fBb16YWxNCvrkJttPP2qps3nLx7+Bn7G811lLUhuqyz8ucaB8iJLC4by+I8yTQYjbx90Ag==
X-Received: by 2002:a17:902:2ec5:: with SMTP id r63mr82774537plb.21.1563942328383;
        Tue, 23 Jul 2019 21:25:28 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id a15sm34153364pgw.3.2019.07.23.21.25.27
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 21:25:27 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	Anna Schumaker <anna.schumaker@netapp.com>,
	"David S . Miller" <davem@davemloft.net>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Eric Van Hensbergen <ericvh@gmail.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Jason Wang <jasowang@redhat.com>,
	Jens Axboe <axboe@kernel.dk>,
	Latchesar Ionkov <lucho@ionkov.net>,
	"Michael S . Tsirkin" <mst@redhat.com>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	Christoph Hellwig <hch@lst.de>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	ceph-devel@vger.kernel.org,
	kvm@vger.kernel.org,
	linux-block@vger.kernel.org,
	linux-cifs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org,
	samba-technical@lists.samba.org,
	v9fs-developer@lists.sourceforge.net,
	virtualization@lists.linux-foundation.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Jan Kara <jack@suse.cz>,
	Dan Williams <dan.j.williams@intel.com>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Ming Lei <ming.lei@redhat.com>,
	Dave Chinner <david@fromorbit.com>,
	Boaz Harrosh <boaz@plexistor.com>
Subject: [PATCH 05/12] block_dev: convert put_page() to put_user_page*()
Date: Tue, 23 Jul 2019 21:25:11 -0700
Message-Id: <20190724042518.14363-6-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190724042518.14363-1-jhubbard@nvidia.com>
References: <20190724042518.14363-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page() or
release_pages().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

Changes from Jérôme's original patch:

* reworked to be compatible with recent bio_release_pages() changes.

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-block@vger.kernel.org
Cc: linux-mm@kvack.org
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
Cc: Boaz Harrosh <boaz@plexistor.com>
---
 block/bio.c         | 13 +++++++++++++
 fs/block_dev.c      | 22 +++++++++++++++++-----
 include/linux/bio.h |  8 ++++++++
 3 files changed, 38 insertions(+), 5 deletions(-)

diff --git a/block/bio.c b/block/bio.c
index 74f9eba2583b..3b9f66e64bc1 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -1746,6 +1746,19 @@ void bio_check_pages_dirty(struct bio *bio)
 	__bio_check_pages_dirty(bio, false);
 }
 
+enum bio_rp_flags_t bio_rp_flags(struct iov_iter *iter, bool mark_dirty)
+{
+	enum bio_rp_flags_t flags = BIO_RP_NORMAL;
+
+	if (mark_dirty)
+		flags |= BIO_RP_MARK_DIRTY;
+
+	if (iov_iter_get_pages_use_gup(iter))
+		flags |= BIO_RP_FROM_GUP;
+
+	return flags;
+}
+
 void update_io_ticks(struct hd_struct *part, unsigned long now)
 {
 	unsigned long stamp;
diff --git a/fs/block_dev.c b/fs/block_dev.c
index 9fe6616f8788..d53abaf31e54 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -259,7 +259,7 @@ __blkdev_direct_IO_simple(struct kiocb *iocb, struct iov_iter *iter,
 	}
 	__set_current_state(TASK_RUNNING);
 
-	bio_release_pages(&bio, bio_rp_dirty_flag(should_dirty));
+	bio_release_pages(&bio, bio_rp_flags(iter, should_dirty));
 	if (unlikely(bio.bi_status))
 		ret = blk_status_to_errno(bio.bi_status);
 
@@ -295,7 +295,7 @@ static int blkdev_iopoll(struct kiocb *kiocb, bool wait)
 	return blk_poll(q, READ_ONCE(kiocb->ki_cookie), wait);
 }
 
-static void blkdev_bio_end_io(struct bio *bio)
+static void _blkdev_bio_end_io(struct bio *bio, bool from_gup)
 {
 	struct blkdev_dio *dio = bio->bi_private;
 	bool should_dirty = dio->should_dirty;
@@ -327,13 +327,23 @@ static void blkdev_bio_end_io(struct bio *bio)
 	}
 
 	if (should_dirty) {
-		bio_check_pages_dirty(bio);
+		__bio_check_pages_dirty(bio, from_gup);
 	} else {
-		bio_release_pages(bio, BIO_RP_NORMAL);
+		bio_release_pages(bio, bio_rp_gup_flag(from_gup));
 		bio_put(bio);
 	}
 }
 
+static void blkdev_bio_end_io(struct bio *bio)
+{
+	_blkdev_bio_end_io(bio, false);
+}
+
+static void blkdev_bio_from_gup_end_io(struct bio *bio)
+{
+	_blkdev_bio_end_io(bio, true);
+}
+
 static ssize_t
 __blkdev_direct_IO(struct kiocb *iocb, struct iov_iter *iter, int nr_pages)
 {
@@ -380,7 +390,9 @@ __blkdev_direct_IO(struct kiocb *iocb, struct iov_iter *iter, int nr_pages)
 		bio->bi_iter.bi_sector = pos >> 9;
 		bio->bi_write_hint = iocb->ki_hint;
 		bio->bi_private = dio;
-		bio->bi_end_io = blkdev_bio_end_io;
+		bio->bi_end_io = iov_iter_get_pages_use_gup(iter) ?
+				 blkdev_bio_from_gup_end_io :
+				 blkdev_bio_end_io;
 		bio->bi_ioprio = iocb->ki_ioprio;
 
 		ret = bio_iov_iter_get_pages(bio, iter);
diff --git a/include/linux/bio.h b/include/linux/bio.h
index d68a40c2c9d4..b9460d1a4679 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -452,6 +452,13 @@ static inline enum bio_rp_flags_t bio_rp_dirty_flag(bool mark_dirty)
 	return mark_dirty ? BIO_RP_MARK_DIRTY : BIO_RP_NORMAL;
 }
 
+static inline enum bio_rp_flags_t bio_rp_gup_flag(bool from_gup)
+{
+	return from_gup ? BIO_RP_FROM_GUP : BIO_RP_NORMAL;
+}
+
+enum bio_rp_flags_t bio_rp_flags(struct iov_iter *iter, bool mark_dirty);
+
 void bio_release_pages(struct bio *bio, enum bio_rp_flags_t flags);
 struct rq_map_data;
 extern struct bio *bio_map_user_iov(struct request_queue *,
@@ -463,6 +470,7 @@ extern struct bio *bio_copy_kern(struct request_queue *, void *, unsigned int,
 				 gfp_t, int);
 extern void bio_set_pages_dirty(struct bio *bio);
 extern void bio_check_pages_dirty(struct bio *bio);
+void __bio_check_pages_dirty(struct bio *bio, bool from_gup);
 
 void generic_start_io_acct(struct request_queue *q, int op,
 				unsigned long sectors, struct hd_struct *part);
-- 
2.22.0

