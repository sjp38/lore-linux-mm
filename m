Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2559C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 11:16:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B3BD21B1C
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 11:16:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B3BD21B1C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C9AC8E000D; Fri, 15 Feb 2019 06:16:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3292A8E0001; Fri, 15 Feb 2019 06:16:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D0E78E000D; Fri, 15 Feb 2019 06:16:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id E1A2B8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 06:16:20 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id c84so7841120qkb.13
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 03:16:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=QDJuYdB/v5IBDbMNukxwyLgaj2zPEtaGeI+9DGb7M44=;
        b=WJykEW/s2w93i1sFSzcLZGmU+HAvng3fAjYqD2PPhxU99jcBVz13hq2S33IyCz8CEg
         cafHvb/E6z0Ye4ZlyAF/ykNiwLBdzLVYBRvr7Nv8luaPAUWKXgpOu1Dz6ycDimN5gsgg
         DX3KOv5pFZmnJpG7InMErnMQUuVgrF7wxpzZb8hJaZBAiLelN/MWMDvr+l2LbU2aNszY
         ZPaS966O4BM76++t33DHqjhLkvd7wJWqkWyiG9OrSMilpbHvy+HarGGxyYHj2SjXSNnC
         /qdVaa3iCmLfyOL7xhqpjaeXeidVW7+9icVCBxEbkkrgfREgvgtDb0yG4qwQmCTO2+dI
         t9Uw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubAq1zJEGbAZtZiqJdF8sORXq9Y+VmLV9OBL2aCSnRdiale156U
	Skyt4fFT5D32PG/QksN4j2mDtYtcAMRqIrM9/jgPmLzCi54oca8nDLJo8VHOIs9o6nC0J7QgBT4
	G/Nt3nYW9iiSJJdZyVNcB9BAEZd4r4kwos0FbNv1/gFVox2wARuBwch2bNlCllHtxcQ==
X-Received: by 2002:ae9:c303:: with SMTP id n3mr6449283qkg.49.1550229380673;
        Fri, 15 Feb 2019 03:16:20 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY4RlwLv17TfL/P9KrQXQLGTO03e0T1KPbjyJacaegeDAevm5kHFAOiXDtwLpIqMHQL8xEc
X-Received: by 2002:ae9:c303:: with SMTP id n3mr6449258qkg.49.1550229380085;
        Fri, 15 Feb 2019 03:16:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550229380; cv=none;
        d=google.com; s=arc-20160816;
        b=VAXPb5v+u61oPJpgQXLq0pA+9acpxMuxxwRSju71BvvLN7BxmFYpK/LFvWCjdYvFaA
         P5l24iaT62UCx2D+aXcURweZcfBohMIQJweC5TtGL+KMybQgtaCWzfK9Af7v/jUAlgbU
         VEr7AHeY8vcSZgYm2v+5VECn1hC11OgmThkfTsrezA9A/O7zTSCcnqf6THoP/oM28Htr
         MTpOhaj3pfZGrSfIB1Vk4kKfvgQ+NoTA5ed56ZBCHKStUbEv/d5C3yZLXSurFLsd4uP3
         uaqZYaJ5l4Lsx7wS6BoHy9nXTQVizPXjBO0GMfiUgFjz6vsZIzmttJNApQpeFuQFMyHY
         yLSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=QDJuYdB/v5IBDbMNukxwyLgaj2zPEtaGeI+9DGb7M44=;
        b=JZp484oYd49DegsJFSRaQL+uOerx/Hfmr6JivTFtreT7BiR9zgvnaSGncpGAFUrWLY
         6Ug/cBIT39xWHYVlXTjSwiLxhBv2iEYUZl7KWP+6L2NM5y3KggTT8lbH6LtJrpHQsbMi
         LykXBqrJiWZFsCW7FYLrPqq8tMZnvg1aS5sERsrIkQ8q28hB0pCZwweC3Iy2BSAJQuwt
         HdDuWDxAKUqCzg8xspm5/R2y1fjuIkxvbhzavaTF0dxwa+Fdv1IBwJSwJASU0oUaEQra
         1R9bP27LbTBy9OC1gs0BuIqkNlMpVwQMtEdLPwoA+TlByChXeP9IrY4DmMf8i9uY4DGx
         Ri0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n66si3468547qka.101.2019.02.15.03.16.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 03:16:20 -0800 (PST)
Received-SPF: pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B6648C01DE19;
	Fri, 15 Feb 2019 11:16:18 +0000 (UTC)
Received: from localhost (ovpn-8-22.pek2.redhat.com [10.72.8.22])
	by smtp.corp.redhat.com (Postfix) with ESMTP id B69A026E59;
	Fri, 15 Feb 2019 11:16:17 +0000 (UTC)
From: Ming Lei <ming.lei@redhat.com>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-block@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Theodore Ts'o <tytso@mit.edu>,
	Omar Sandoval <osandov@fb.com>,
	Sagi Grimberg <sagi@grimberg.me>,
	Dave Chinner <dchinner@redhat.com>,
	Kent Overstreet <kent.overstreet@gmail.com>,
	Mike Snitzer <snitzer@redhat.com>,
	dm-devel@redhat.com,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	linux-fsdevel@vger.kernel.org,
	linux-raid@vger.kernel.org,
	David Sterba <dsterba@suse.com>,
	linux-btrfs@vger.kernel.org,
	"Darrick J . Wong" <darrick.wong@oracle.com>,
	linux-xfs@vger.kernel.org,
	Gao Xiang <gaoxiang25@huawei.com>,
	Christoph Hellwig <hch@lst.de>,
	linux-ext4@vger.kernel.org,
	Coly Li <colyli@suse.de>,
	linux-bcache@vger.kernel.org,
	Boaz Harrosh <ooo@electrozaur.com>,
	Bob Peterson <rpeterso@redhat.com>,
	cluster-devel@redhat.com,
	Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V15 11/18] block: loop: pass multi-page bvec to iov_iter
Date: Fri, 15 Feb 2019 19:13:17 +0800
Message-Id: <20190215111324.30129-12-ming.lei@redhat.com>
In-Reply-To: <20190215111324.30129-1-ming.lei@redhat.com>
References: <20190215111324.30129-1-ming.lei@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Fri, 15 Feb 2019 11:16:19 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

iov_iter is implemented on bvec itererator helpers, so it is safe to pass
multi-page bvec to it, and this way is much more efficient than passing one
page in each bvec.

Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Omar Sandoval <osandov@fb.com>
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 drivers/block/loop.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/block/loop.c b/drivers/block/loop.c
index cf5538942834..8ef583197414 100644
--- a/drivers/block/loop.c
+++ b/drivers/block/loop.c
@@ -511,21 +511,22 @@ static int lo_rw_aio(struct loop_device *lo, struct loop_cmd *cmd,
 		     loff_t pos, bool rw)
 {
 	struct iov_iter iter;
+	struct req_iterator rq_iter;
 	struct bio_vec *bvec;
 	struct request *rq = blk_mq_rq_from_pdu(cmd);
 	struct bio *bio = rq->bio;
 	struct file *file = lo->lo_backing_file;
+	struct bio_vec tmp;
 	unsigned int offset;
-	int segments = 0;
+	int nr_bvec = 0;
 	int ret;
 
+	rq_for_each_bvec(tmp, rq, rq_iter)
+		nr_bvec++;
+
 	if (rq->bio != rq->biotail) {
-		struct req_iterator iter;
-		struct bio_vec tmp;
 
-		__rq_for_each_bio(bio, rq)
-			segments += bio_segments(bio);
-		bvec = kmalloc_array(segments, sizeof(struct bio_vec),
+		bvec = kmalloc_array(nr_bvec, sizeof(struct bio_vec),
 				     GFP_NOIO);
 		if (!bvec)
 			return -EIO;
@@ -534,10 +535,10 @@ static int lo_rw_aio(struct loop_device *lo, struct loop_cmd *cmd,
 		/*
 		 * The bios of the request may be started from the middle of
 		 * the 'bvec' because of bio splitting, so we can't directly
-		 * copy bio->bi_iov_vec to new bvec. The rq_for_each_segment
+		 * copy bio->bi_iov_vec to new bvec. The rq_for_each_bvec
 		 * API will take care of all details for us.
 		 */
-		rq_for_each_segment(tmp, rq, iter) {
+		rq_for_each_bvec(tmp, rq, rq_iter) {
 			*bvec = tmp;
 			bvec++;
 		}
@@ -551,11 +552,10 @@ static int lo_rw_aio(struct loop_device *lo, struct loop_cmd *cmd,
 		 */
 		offset = bio->bi_iter.bi_bvec_done;
 		bvec = __bvec_iter_bvec(bio->bi_io_vec, bio->bi_iter);
-		segments = bio_segments(bio);
 	}
 	atomic_set(&cmd->ref, 2);
 
-	iov_iter_bvec(&iter, rw, bvec, segments, blk_rq_bytes(rq));
+	iov_iter_bvec(&iter, rw, bvec, nr_bvec, blk_rq_bytes(rq));
 	iter.iov_offset = offset;
 
 	cmd->iocb.ki_pos = pos;
-- 
2.9.5

