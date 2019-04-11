Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35777C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 21:08:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D613220850
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 21:08:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D613220850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC5046B026D; Thu, 11 Apr 2019 17:08:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E23476B026E; Thu, 11 Apr 2019 17:08:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C9D1E6B026F; Thu, 11 Apr 2019 17:08:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id A607D6B026D
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 17:08:54 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id l26so6812208qtk.18
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 14:08:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=tJY/hNbZ3bSboRGCLaNnbTCmp0SlQGBJRAI1x7JusCc=;
        b=MBngYfFjDCrA08pKzxLpNvDHQCk15H3WznhgioKrb0LOBlW0V01Bq0zzul6/Jcz38y
         L+328yQohd5NOxzsp0/PyHorVGJN5HOyWqw8hBPu8QL5f62NjIOu1K0SZ1awqrQoIN/C
         Ws5svuCVsgu5aNA6euK6Q06+5HT/MTXU0S28hUc29DDsm1ikVDiIIS6awRgbma59hyR2
         xO2DOLhU36gbInCV64mNu7Q9WknL/h98KOnlybQ3mGf6eMbnI3upDCXhoElnVvCWEG/f
         jlwIQzBqOqGk5btGknrhgCg62r+XpBoGOPbKBQ61esCYVPXv2apsTLSCFRyFyLQg1UQe
         M84w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXGSz2yN9RHx1BuDW//+4JztG1N+8/Zm1MAwyk7pMEXT0aSubH3
	5EjKhjnqtt8WNMcmQdqv8wvTLDBzklIKZPx6JTykjJA9AvoasQkzk9pMSngsJVpqHSBEB+p+eMv
	3i/IwLQ6x0I4XoHf6k05v2mp6fiPxl36LnfMP3mCjzUGM3KnDDi2pRok+8DOxQ9tZTA==
X-Received: by 2002:a37:49ca:: with SMTP id w193mr38759365qka.261.1555016934397;
        Thu, 11 Apr 2019 14:08:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzd2NzUy5FFCDMcwkHZCYW5c2YZOibkXX/On5a3Y+gxM/NfIAFk54mabdwrNpVzoyRcBeiA
X-Received: by 2002:a37:49ca:: with SMTP id w193mr38759297qka.261.1555016933418;
        Thu, 11 Apr 2019 14:08:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555016933; cv=none;
        d=google.com; s=arc-20160816;
        b=PCJ1AOxA7ZjoGKP/5PPtyEoZ6vzESFSZrasw7J5nif2WqcnW2ZB9sipXKth8/Cm0se
         vOAENoscZ98neP5mVJd3Ut0WTD0KjPd2EVyxGlqkd+hfL1hEV8e1zsb9Jk7SgSfZAmZc
         tnQ785XIxL9WG6pashSo/z3L/mTVswYatP4h62djNdEhVkcQqd0uBV16uOWDXGrqr8WY
         EUwNfcv9awusSpD57ERLhfLnj9//HgHW/FzqGjtoqEL92rcfCyqD0Lb9PnaKZboYTmfO
         vDdts+Rzk1OPq9RuUEF9aegoDhItgLybEEWdW5qVQ+aU4D4AqmRjXtvqId1ETqT4CJTB
         pYBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=tJY/hNbZ3bSboRGCLaNnbTCmp0SlQGBJRAI1x7JusCc=;
        b=kia7JJsN8omfPIl7+au8Vv+M0k8k3QHj+mzJbOrjppojUaRmnz4vUNeeZXaYDmCoXA
         ByYqGoifd7y3DPMz3Quwp0HBQqAb7dyzbewozP8q8UsFGyXiA6FJ5k53rMyCDjtkjlsi
         CZX6mM/v1OhMxWW4s/nPmIlQoD6kpYPE744F9k9Z0/jttBgMyBvQGq8uxWGi67tP2oQQ
         /lNpbsOvRoV2sTMjdcYuc3xKeOpH97iBVD3xNi9dWRU+zhcfesO+f5E6P/hW07RTmTQh
         7m4TaAdhAhScvkDafPhOc5liPnIttcDwI1xUfJmOY0K+KrTDvZ32eBhtrxZ13H9QrHhB
         DWaw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 38si12193653qvk.147.2019.04.11.14.08.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 14:08:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 40B6489C36;
	Thu, 11 Apr 2019 21:08:52 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id B270B5C220;
	Thu, 11 Apr 2019 21:08:49 +0000 (UTC)
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
	Ilya Dryomov <idryomov@gmail.com>,
	Sage Weil <sage@redhat.com>,
	Alex Elder <elder@kernel.org>,
	ceph-devel@vger.kernel.org,
	Eric Van Hensbergen <ericvh@gmail.com>,
	Latchesar Ionkov <lucho@ionkov.net>,
	Steve French <sfrench@samba.org>,
	linux-cifs@vger.kernel.org,
	Mike Marshall <hubcap@omnibond.com>,
	Martin Brandenburg <martin@omnibond.com>,
	devel@lists.orangefs.org,
	Dominique Martinet <asmadeus@codewreck.org>,
	v9fs-developer@lists.sourceforge.net
Subject: [PATCH v1 04/15] block: introduce BIO_VEC_INIT() macro to initialize bio_vec structure
Date: Thu, 11 Apr 2019 17:08:23 -0400
Message-Id: <20190411210834.4105-5-jglisse@redhat.com>
In-Reply-To: <20190411210834.4105-1-jglisse@redhat.com>
References: <20190411210834.4105-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Thu, 11 Apr 2019 21:08:52 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

This add a macro to initialize bio_vec structure. We want to convert
all initialization with that macro so that it is easier to change the
bvec->page fields in latter patch.

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
Cc: Ilya Dryomov <idryomov@gmail.com>
Cc: Sage Weil <sage@redhat.com>
Cc: Alex Elder <elder@kernel.org>
Cc: ceph-devel@vger.kernel.org
Cc: Eric Van Hensbergen <ericvh@gmail.com>
Cc: Latchesar Ionkov <lucho@ionkov.net>
Cc: Steve French <sfrench@samba.org>
Cc: linux-cifs@vger.kernel.org
Cc: Mike Marshall <hubcap@omnibond.com>
Cc: Martin Brandenburg <martin@omnibond.com>
Cc: devel@lists.orangefs.org
Cc: Dominique Martinet <asmadeus@codewreck.org>
Cc: v9fs-developer@lists.sourceforge.net
---
 block/blk-integrity.c | 4 ++--
 block/blk-merge.c     | 2 +-
 fs/9p/vfs_addr.c      | 2 +-
 fs/ceph/file.c        | 8 +++-----
 fs/cifs/connect.c     | 4 ++--
 fs/orangefs/inode.c   | 2 +-
 include/linux/bvec.h  | 2 ++
 mm/page_io.c          | 6 +-----
 net/ceph/messenger.c  | 6 +-----
 9 files changed, 14 insertions(+), 22 deletions(-)

diff --git a/block/blk-integrity.c b/block/blk-integrity.c
index d1ab089e0919..916a5406649d 100644
--- a/block/blk-integrity.c
+++ b/block/blk-integrity.c
@@ -40,7 +40,7 @@
  */
 int blk_rq_count_integrity_sg(struct request_queue *q, struct bio *bio)
 {
-	struct bio_vec iv, ivprv = { NULL };
+	struct bio_vec iv, ivprv = BIO_VEC_INIT(NULL, 0, 0);
 	unsigned int segments = 0;
 	unsigned int seg_size = 0;
 	struct bvec_iter iter;
@@ -82,7 +82,7 @@ EXPORT_SYMBOL(blk_rq_count_integrity_sg);
 int blk_rq_map_integrity_sg(struct request_queue *q, struct bio *bio,
 			    struct scatterlist *sglist)
 {
-	struct bio_vec iv, ivprv = { NULL };
+	struct bio_vec iv, ivprv = BIO_VEC_INIT(NULL, 0, 0);
 	struct scatterlist *sg = NULL;
 	unsigned int segments = 0;
 	struct bvec_iter iter;
diff --git a/block/blk-merge.c b/block/blk-merge.c
index 1c9d4f0f96ea..c355fb9e9e8e 100644
--- a/block/blk-merge.c
+++ b/block/blk-merge.c
@@ -447,7 +447,7 @@ void blk_recount_segments(struct request_queue *q, struct bio *bio)
 static int blk_phys_contig_segment(struct request_queue *q, struct bio *bio,
 				   struct bio *nxt)
 {
-	struct bio_vec end_bv = { NULL }, nxt_bv;
+	struct bio_vec end_bv = BIO_VEC_INIT(NULL, 0, 0), nxt_bv;
 
 	if (bio->bi_seg_back_size + nxt->bi_seg_front_size >
 	    queue_max_segment_size(q))
diff --git a/fs/9p/vfs_addr.c b/fs/9p/vfs_addr.c
index 0bcbcc20f769..b626b28f0ce9 100644
--- a/fs/9p/vfs_addr.c
+++ b/fs/9p/vfs_addr.c
@@ -53,7 +53,7 @@
 static int v9fs_fid_readpage(struct p9_fid *fid, struct page *page)
 {
 	struct inode *inode = page->mapping->host;
-	struct bio_vec bvec = {.bv_page = page, .bv_len = PAGE_SIZE};
+	struct bio_vec bvec = BIO_VEC_INIT(page, PAGE_SIZE, 0);
 	struct iov_iter to;
 	int retval, err;
 
diff --git a/fs/ceph/file.c b/fs/ceph/file.c
index 9f53c3d99304..d3c8035335a2 100644
--- a/fs/ceph/file.c
+++ b/fs/ceph/file.c
@@ -100,11 +100,9 @@ static ssize_t __iter_get_bvecs(struct iov_iter *iter, size_t maxsize,
 		size += bytes;
 
 		for ( ; bytes; idx++, bvec_idx++) {
-			struct bio_vec bv = {
-				.bv_page = pages[idx],
-				.bv_len = min_t(int, bytes, PAGE_SIZE - start),
-				.bv_offset = start,
-			};
+			struct bio_vec bv = BIO_VEC_INIT(pages[idx],
+				min_t(int, bytes, PAGE_SIZE - start),
+				start);
 
 			bvecs[bvec_idx] = bv;
 			bytes -= bv.bv_len;
diff --git a/fs/cifs/connect.c b/fs/cifs/connect.c
index 4c0e44489f21..86438f3933a9 100644
--- a/fs/cifs/connect.c
+++ b/fs/cifs/connect.c
@@ -809,8 +809,8 @@ cifs_read_page_from_socket(struct TCP_Server_Info *server, struct page *page,
 	unsigned int page_offset, unsigned int to_read)
 {
 	struct msghdr smb_msg;
-	struct bio_vec bv = {
-		.bv_page = page, .bv_len = to_read, .bv_offset = page_offset};
+	struct bio_vec bv = BIO_VEC_INIT(page, to_read, page_offset);
+
 	iov_iter_bvec(&smb_msg.msg_iter, READ, &bv, 1, to_read);
 	return cifs_readv_from_socket(server, &smb_msg);
 }
diff --git a/fs/orangefs/inode.c b/fs/orangefs/inode.c
index c3334eca18c7..5ebd2da4c093 100644
--- a/fs/orangefs/inode.c
+++ b/fs/orangefs/inode.c
@@ -23,7 +23,7 @@ static int read_one_page(struct page *page)
 	const __u32 blocksize = PAGE_SIZE;
 	const __u32 blockbits = PAGE_SHIFT;
 	struct iov_iter to;
-	struct bio_vec bv = {.bv_page = page, .bv_len = PAGE_SIZE};
+	struct bio_vec bv = BIO_VEC_INIT(page, PAGE_SIZE, 0);
 
 	iov_iter_bvec(&to, READ, &bv, 1, PAGE_SIZE);
 
diff --git a/include/linux/bvec.h b/include/linux/bvec.h
index 44866555258a..8f8fb528ce53 100644
--- a/include/linux/bvec.h
+++ b/include/linux/bvec.h
@@ -70,6 +70,8 @@ static inline struct page *bvec_nth_page(struct page *page, int idx)
  * various member access, note that bio_data should of course not be used
  * on highmem page vectors
  */
+#define BIO_VEC_INIT(p, l, o) {.bv_page = (p), .bv_len = (l), .bv_offset = (o)}
+
 #define __bvec_iter_bvec(bvec, iter)	(&(bvec)[(iter).bi_idx])
 
 /* multi-page (mp_bvec) helpers */
diff --git a/mm/page_io.c b/mm/page_io.c
index 2e8019d0e048..6b3be0445c61 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -287,11 +287,7 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc,
 		struct kiocb kiocb;
 		struct file *swap_file = sis->swap_file;
 		struct address_space *mapping = swap_file->f_mapping;
-		struct bio_vec bv = {
-			.bv_page = page,
-			.bv_len  = PAGE_SIZE,
-			.bv_offset = 0
-		};
+		struct bio_vec bv = BIO_VEC_INIT(page, PAGE_SIZE, 0);
 		struct iov_iter from;
 
 		iov_iter_bvec(&from, WRITE, &bv, 1, PAGE_SIZE);
diff --git a/net/ceph/messenger.c b/net/ceph/messenger.c
index 3083988ce729..3e16187491d8 100644
--- a/net/ceph/messenger.c
+++ b/net/ceph/messenger.c
@@ -523,11 +523,7 @@ static int ceph_tcp_recvmsg(struct socket *sock, void *buf, size_t len)
 static int ceph_tcp_recvpage(struct socket *sock, struct page *page,
 		     int page_offset, size_t length)
 {
-	struct bio_vec bvec = {
-		.bv_page = page,
-		.bv_offset = page_offset,
-		.bv_len = length
-	};
+	struct bio_vec bvec = BIO_VEC_INIT(page, length, page_offset);
 	struct msghdr msg = { .msg_flags = MSG_DONTWAIT | MSG_NOSIGNAL };
 	int r;
 
-- 
2.20.1

