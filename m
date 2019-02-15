Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5FC4C10F02
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 11:15:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F84221B1C
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 11:15:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F84221B1C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 12E6F8E0008; Fri, 15 Feb 2019 06:15:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E0578E0001; Fri, 15 Feb 2019 06:15:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F386E8E0008; Fri, 15 Feb 2019 06:15:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id C90BB8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 06:15:46 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id q15so7838611qki.14
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 03:15:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=uvWYqf4GK8lhAsEaw5k4QrLmk8zZiBbvYT4KVo/7NoQ=;
        b=V+fOzNRcy5qMHjn7bb4voSInrU6Q3MU47OnRcKgAG+ZHzDmnA881/fjg6No/Jv7Ip1
         f5aih+eaVmwegS5IiUJk2w2zrE2Nqlklnk7c0aveJljwZXo7+GjUQWuPViOcM7qGLB5W
         wOWff8sEVWiU5OUsM3UQ9fr24wjrPfnECH7Js7ZXOdmxBKneUrFq0JZox93Eh/c0sB+K
         of17XjUqgTfJFJ0LXF+7W3q1bUVQDve3h89xJYQdfVuJeenzExvFaaIFYlfN1x5Wu7mm
         n6hI8l2qXSe7lYgMCb+kyhHharsOneYPAQutr4WEpwVwge1egqg81F6xz1BQhEUEbVux
         Eu6A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuYv2rBtzreRVupudvf0iTZ5OTQKgNaE8Lk/QLKiz28wOXufaEbT
	r1QsBsv7dQvQnBdT85Nbscwv/gJcqK9XLs7q5GKYAvmXjXRNsg3bIIW5S7z9C84hpXxWzvhBE0u
	s/EupzRXhIbJ84hK6/rxWFN9b5ARbMiAwRELkdxiubtWZt/bvB9/HcRljdGzyKX8EyA==
X-Received: by 2002:ac8:3474:: with SMTP id v49mr6990965qtb.132.1550229346576;
        Fri, 15 Feb 2019 03:15:46 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZkyE8XF0xjuzQv5yQmukqCaTAgMftHdoRiYE9Anl7zwe81Eu0illHtLHV9jrDG4Igy5Ly4
X-Received: by 2002:ac8:3474:: with SMTP id v49mr6990927qtb.132.1550229345906;
        Fri, 15 Feb 2019 03:15:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550229345; cv=none;
        d=google.com; s=arc-20160816;
        b=Fn5R/I4xc470qqq97P4fYngd31ihNycNywI1L+7JwiJrswyGIy1dviVJG60jeuMcsW
         7RIF4jSDlASp1AH3wmENhG6zs5lgXKocdqyw5CBl+DYplLb2+kUQzZDsxLKl5RyxkRLn
         4EeUsWOWlkoCXxR8a9ScF5hTeXevn8XhCizbjFVtwMlH9lfqAmWnXeK8vNCgyQzkRTkk
         tulfFxA56kOTBh6sQ+JUYRf3OViMy9iMtyVg5IIGWq5xCVoSKgpzBVcFOMbZg1YqrXIT
         rDSXP/Cv6GtpHbU8yFg+X4gLESt2+p0871XoHTU1N6skH17Hv3dThn5Ar9Tbqtc0A1pR
         R3Ew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=uvWYqf4GK8lhAsEaw5k4QrLmk8zZiBbvYT4KVo/7NoQ=;
        b=LuA1j6zguRfruA7n+ol7hvDq+PPxOXborFHM9rrvbqWRo2fjCNyhkibl4hQzrT6WCr
         EJbm7mwozLKN2gLVo6eQBye5i8nq4xEZzD236b5lgnLtmhmIpdgInl5GL3baKfT9KAf9
         +/+NRW5L/4Ua9s33BWjUjATwGfw0kQ2A7RmWFuIPvVKetuMIAM7N7CKoRzqq9rTFUD9L
         W/2r+toW7L10Qpbsg1ujNpwQejL8j0kFio5TDZO5RnGRaqtBKsYp/5wIHPn9qgVmdQ3r
         XSksfHZ7DrwMStutEiD6ajqhCVh3HGelunL0L5M2Tx6S0UTMpeYISwFAc+K1Z5fbrS8H
         nDoQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j35si366472qtc.137.2019.02.15.03.15.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 03:15:45 -0800 (PST)
Received-SPF: pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0A7472D6E46;
	Fri, 15 Feb 2019 11:15:44 +0000 (UTC)
Received: from localhost (ovpn-8-22.pek2.redhat.com [10.72.8.22])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 2EF8E5D707;
	Fri, 15 Feb 2019 11:15:10 +0000 (UTC)
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
Subject: [PATCH V15 06/18] block: use bio_for_each_bvec() to compute multi-page bvec count
Date: Fri, 15 Feb 2019 19:13:12 +0800
Message-Id: <20190215111324.30129-7-ming.lei@redhat.com>
In-Reply-To: <20190215111324.30129-1-ming.lei@redhat.com>
References: <20190215111324.30129-1-ming.lei@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Fri, 15 Feb 2019 11:15:45 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

First it is more efficient to use bio_for_each_bvec() in both
blk_bio_segment_split() and __blk_recalc_rq_segments() to compute how
many multi-page bvecs there are in the bio.

Secondly once bio_for_each_bvec() is used, the bvec may need to be
splitted because its length can be very longer than max segment size,
so we have to split the big bvec into several segments.

Thirdly when splitting multi-page bvec into segments, the max segment
limit may be reached, so the bio split need to be considered under
this situation too.

Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Omar Sandoval <osandov@fb.com>
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 block/blk-merge.c | 103 +++++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 83 insertions(+), 20 deletions(-)

diff --git a/block/blk-merge.c b/block/blk-merge.c
index f85d878f313d..4ef56b2d2aa5 100644
--- a/block/blk-merge.c
+++ b/block/blk-merge.c
@@ -161,6 +161,73 @@ static inline unsigned get_max_io_size(struct request_queue *q,
 	return sectors;
 }
 
+static unsigned get_max_segment_size(struct request_queue *q,
+				     unsigned offset)
+{
+	unsigned long mask = queue_segment_boundary(q);
+
+	/* default segment boundary mask means no boundary limit */
+	if (mask == BLK_SEG_BOUNDARY_MASK)
+		return queue_max_segment_size(q);
+
+	return min_t(unsigned long, mask - (mask & offset) + 1,
+		     queue_max_segment_size(q));
+}
+
+/*
+ * Split the bvec @bv into segments, and update all kinds of
+ * variables.
+ */
+static bool bvec_split_segs(struct request_queue *q, struct bio_vec *bv,
+		unsigned *nsegs, unsigned *last_seg_size,
+		unsigned *front_seg_size, unsigned *sectors)
+{
+	unsigned len = bv->bv_len;
+	unsigned total_len = 0;
+	unsigned new_nsegs = 0, seg_size = 0;
+
+	/*
+	 * Multi-page bvec may be too big to hold in one segment, so the
+	 * current bvec has to be splitted as multiple segments.
+	 */
+	while (len && new_nsegs + *nsegs < queue_max_segments(q)) {
+		seg_size = get_max_segment_size(q, bv->bv_offset + total_len);
+		seg_size = min(seg_size, len);
+
+		new_nsegs++;
+		total_len += seg_size;
+		len -= seg_size;
+
+		if ((bv->bv_offset + total_len) & queue_virt_boundary(q))
+			break;
+	}
+
+	if (!new_nsegs)
+		return !!len;
+
+	/* update front segment size */
+	if (!*nsegs) {
+		unsigned first_seg_size;
+
+		if (new_nsegs == 1)
+			first_seg_size = get_max_segment_size(q, bv->bv_offset);
+		else
+			first_seg_size = queue_max_segment_size(q);
+
+		if (*front_seg_size < first_seg_size)
+			*front_seg_size = first_seg_size;
+	}
+
+	/* update other varibles */
+	*last_seg_size = seg_size;
+	*nsegs += new_nsegs;
+	if (sectors)
+		*sectors += total_len >> 9;
+
+	/* split in the middle of the bvec if len != 0 */
+	return !!len;
+}
+
 static struct bio *blk_bio_segment_split(struct request_queue *q,
 					 struct bio *bio,
 					 struct bio_set *bs,
@@ -174,7 +241,7 @@ static struct bio *blk_bio_segment_split(struct request_queue *q,
 	struct bio *new = NULL;
 	const unsigned max_sectors = get_max_io_size(q, bio);
 
-	bio_for_each_segment(bv, bio, iter) {
+	bio_for_each_bvec(bv, bio, iter) {
 		/*
 		 * If the queue doesn't support SG gaps and adding this
 		 * offset would create a gap, disallow it.
@@ -189,8 +256,12 @@ static struct bio *blk_bio_segment_split(struct request_queue *q,
 			 */
 			if (nsegs < queue_max_segments(q) &&
 			    sectors < max_sectors) {
-				nsegs++;
-				sectors = max_sectors;
+				/* split in the middle of bvec */
+				bv.bv_len = (max_sectors - sectors) << 9;
+				bvec_split_segs(q, &bv, &nsegs,
+						&seg_size,
+						&front_seg_size,
+						&sectors);
 			}
 			goto split;
 		}
@@ -212,14 +283,12 @@ static struct bio *blk_bio_segment_split(struct request_queue *q,
 		if (nsegs == queue_max_segments(q))
 			goto split;
 
-		if (nsegs == 1 && seg_size > front_seg_size)
-			front_seg_size = seg_size;
-
-		nsegs++;
 		bvprv = bv;
 		bvprvp = &bvprv;
-		seg_size = bv.bv_len;
-		sectors += bv.bv_len >> 9;
+
+		if (bvec_split_segs(q, &bv, &nsegs, &seg_size,
+				    &front_seg_size, &sectors))
+			goto split;
 
 	}
 
@@ -233,8 +302,6 @@ static struct bio *blk_bio_segment_split(struct request_queue *q,
 			bio = new;
 	}
 
-	if (nsegs == 1 && seg_size > front_seg_size)
-		front_seg_size = seg_size;
 	bio->bi_seg_front_size = front_seg_size;
 	if (seg_size > bio->bi_seg_back_size)
 		bio->bi_seg_back_size = seg_size;
@@ -297,6 +364,7 @@ static unsigned int __blk_recalc_rq_segments(struct request_queue *q,
 	struct bio_vec bv, bvprv = { NULL };
 	int prev = 0;
 	unsigned int seg_size, nr_phys_segs;
+	unsigned front_seg_size = bio->bi_seg_front_size;
 	struct bio *fbio, *bbio;
 	struct bvec_iter iter;
 
@@ -316,7 +384,7 @@ static unsigned int __blk_recalc_rq_segments(struct request_queue *q,
 	seg_size = 0;
 	nr_phys_segs = 0;
 	for_each_bio(bio) {
-		bio_for_each_segment(bv, bio, iter) {
+		bio_for_each_bvec(bv, bio, iter) {
 			/*
 			 * If SG merging is disabled, each bio vector is
 			 * a segment
@@ -336,20 +404,15 @@ static unsigned int __blk_recalc_rq_segments(struct request_queue *q,
 				continue;
 			}
 new_segment:
-			if (nr_phys_segs == 1 && seg_size >
-			    fbio->bi_seg_front_size)
-				fbio->bi_seg_front_size = seg_size;
-
-			nr_phys_segs++;
 			bvprv = bv;
 			prev = 1;
-			seg_size = bv.bv_len;
+			bvec_split_segs(q, &bv, &nr_phys_segs, &seg_size,
+					&front_seg_size, NULL);
 		}
 		bbio = bio;
 	}
 
-	if (nr_phys_segs == 1 && seg_size > fbio->bi_seg_front_size)
-		fbio->bi_seg_front_size = seg_size;
+	fbio->bi_seg_front_size = front_seg_size;
 	if (seg_size > bbio->bi_seg_back_size)
 		bbio->bi_seg_back_size = seg_size;
 
-- 
2.9.5

