Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DBCE1C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 11:18:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 950D721B1A
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 11:18:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 950D721B1A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4185A8E0005; Fri, 15 Feb 2019 06:18:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3C4308E0001; Fri, 15 Feb 2019 06:18:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2658D8E0005; Fri, 15 Feb 2019 06:18:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id F0C758E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 06:18:00 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id 207so7850092qkf.9
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 03:18:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=JdFCPIv8/ZohHW7Z9bynsznzb31S+LQgq2A7alDik90=;
        b=mNL2Dv2z6V/MLO14dV7HOZRsgOtWaS1+vmQynMxzn/cqCghGwbk/7YAnV9MrNVHRio
         wjGmr/LM/h1KSV/f4pRCTmj3pLhWdyndCgRE7WcFYsvNObIoamieeA+ydiqafopS8WK5
         yZlAXGG8mBZCMPYJ8hgIVBYiqjRTYX3jsR5lDu72lVUygBcGyqeCMOKIe+SpDlveN8qn
         AFNezPxLMsef3WX23hTw5M9i5iHodWVvpFh6oLthhzwxgrQ8xY032ZbmUFuPRvjjIgzJ
         +68+DCMD5JCCwfTl3NFij2TI4AR3o1BTionOLZhVJq31wpiVZT9BYYcb1pJC7LUZxAs4
         1oxA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZOYipdrh3FVU2G6U7W2YPJEAxZkvGbf3oh/CybeHFrlnID3efD
	8QQ7zyuhZCqG3dsjxWZ8jpzs5VnAI2JQUUIjCrtrlMYxTPPNzpY8cS9/KToKjtK5vgWDA2LWeNr
	IUjBsfS7g5nIcHSoVuRLBb5CTGtzeeSeeE8HeOM9NxVyce7NjAwxaMy6JSoFNk1me+A==
X-Received: by 2002:a37:6d44:: with SMTP id i65mr6397455qkc.73.1550229480705;
        Fri, 15 Feb 2019 03:18:00 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbyGRWKFN0EQEPfjiHb9HsLOYH/qzDXS9YdHhpvzl1Gym2JItm+HYDl5E3dxHI/r55AumbT
X-Received: by 2002:a37:6d44:: with SMTP id i65mr6397419qkc.73.1550229479948;
        Fri, 15 Feb 2019 03:17:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550229479; cv=none;
        d=google.com; s=arc-20160816;
        b=a8hROWAnkeCq0K9Llv6kPJUsEZ+f/u5H6MtX1RJoUVPEetlskMPmb3LAkz+5l+9CBT
         b1jGMcMzJhkySyxYmL3SWMIRbyOEC/m7d395UlZ5QusEDZxOWJQcIE6n7WoQJoypJ74f
         54YTvp2tJko8dTnXIblO+PZo++jGpRm35b0HaSXGdU8RtcoF2KiU+AYFaHzhVOnPlihU
         AY/7xFQghkJGBQvu3ZEr+L/dUscNN8T050zdvjRKQY2UfLTdZYHLOZ58wCispBZZhEFg
         h+1qq6JS7psZvdy/mz5TbtUGClsvDPbbPcRmpSffuLO/VKSZ4es6DrI0HKQ4tW5jljX8
         rf2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=JdFCPIv8/ZohHW7Z9bynsznzb31S+LQgq2A7alDik90=;
        b=P3F3cLp79wJMTFRFJXsO8TwctV+2gtGp9p4z59ZEIFL1DEGm/9t+V4fcZ+xtLd4ua0
         s22tQOxNUoCgCLZ/1g718WGrsz15FoJumBQVmjqiZj6RRCFM+hJbZOeybJUayzO9ejJ8
         O3LPeNYTHyLb0Dj0u8960tn5bGm9gEZiNmmOBdtYj9vU1DqNNp2pku9aTCFIFWd4j0eW
         c4iNMIQfFDrf42Zn8kSO4qY9rGoHbkkH0fBDPIhC7kY16SPPaSh7K2ul+ukVWw/pWc32
         xmQD9Gq85ETtCVLITYkoVrWNCXMyO6z44M177ViE68M2CEJ6Y1NaQLyw2usg3XHhRDNe
         xG1A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z54si257650qth.152.2019.02.15.03.17.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 03:17:59 -0800 (PST)
Received-SPF: pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id EC0DB83F51;
	Fri, 15 Feb 2019 11:17:58 +0000 (UTC)
Received: from localhost (ovpn-8-22.pek2.redhat.com [10.72.8.22])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 210A25F9C6;
	Fri, 15 Feb 2019 11:17:50 +0000 (UTC)
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
Subject: [PATCH V15 17/18] block: kill QUEUE_FLAG_NO_SG_MERGE
Date: Fri, 15 Feb 2019 19:13:23 +0800
Message-Id: <20190215111324.30129-18-ming.lei@redhat.com>
In-Reply-To: <20190215111324.30129-1-ming.lei@redhat.com>
References: <20190215111324.30129-1-ming.lei@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Fri, 15 Feb 2019 11:17:59 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Since bdced438acd83ad83a6c ("block: setup bi_phys_segments after splitting"),
physical segment number is mainly figured out in blk_queue_split() for
fast path, and the flag of BIO_SEG_VALID is set there too.

Now only blk_recount_segments() and blk_recalc_rq_segments() use this
flag.

Basically blk_recount_segments() is bypassed in fast path given BIO_SEG_VALID
is set in blk_queue_split().

For another user of blk_recalc_rq_segments():

- run in partial completion branch of blk_update_request, which is an unusual case

- run in blk_cloned_rq_check_limits(), still not a big problem if the flag is killed
since dm-rq is the only user.

Multi-page bvec is enabled now, not doing S/G merging is rather pointless with the
current setup of the I/O path, as it isn't going to save you a significant amount
of cycles.

Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Omar Sandoval <osandov@fb.com>
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 block/blk-merge.c      | 31 ++++++-------------------------
 block/blk-mq-debugfs.c |  1 -
 block/blk-mq.c         |  3 ---
 drivers/md/dm-table.c  | 13 -------------
 include/linux/blkdev.h |  1 -
 5 files changed, 6 insertions(+), 43 deletions(-)

diff --git a/block/blk-merge.c b/block/blk-merge.c
index 1912499b08b7..bed065904677 100644
--- a/block/blk-merge.c
+++ b/block/blk-merge.c
@@ -358,8 +358,7 @@ void blk_queue_split(struct request_queue *q, struct bio **bio)
 EXPORT_SYMBOL(blk_queue_split);
 
 static unsigned int __blk_recalc_rq_segments(struct request_queue *q,
-					     struct bio *bio,
-					     bool no_sg_merge)
+					     struct bio *bio)
 {
 	struct bio_vec bv, bvprv = { NULL };
 	int prev = 0;
@@ -385,13 +384,6 @@ static unsigned int __blk_recalc_rq_segments(struct request_queue *q,
 	nr_phys_segs = 0;
 	for_each_bio(bio) {
 		bio_for_each_bvec(bv, bio, iter) {
-			/*
-			 * If SG merging is disabled, each bio vector is
-			 * a segment
-			 */
-			if (no_sg_merge)
-				goto new_segment;
-
 			if (prev) {
 				if (seg_size + bv.bv_len
 				    > queue_max_segment_size(q))
@@ -421,27 +413,16 @@ static unsigned int __blk_recalc_rq_segments(struct request_queue *q,
 
 void blk_recalc_rq_segments(struct request *rq)
 {
-	bool no_sg_merge = !!test_bit(QUEUE_FLAG_NO_SG_MERGE,
-			&rq->q->queue_flags);
-
-	rq->nr_phys_segments = __blk_recalc_rq_segments(rq->q, rq->bio,
-			no_sg_merge);
+	rq->nr_phys_segments = __blk_recalc_rq_segments(rq->q, rq->bio);
 }
 
 void blk_recount_segments(struct request_queue *q, struct bio *bio)
 {
-	unsigned short seg_cnt = bio_segments(bio);
-
-	if (test_bit(QUEUE_FLAG_NO_SG_MERGE, &q->queue_flags) &&
-			(seg_cnt < queue_max_segments(q)))
-		bio->bi_phys_segments = seg_cnt;
-	else {
-		struct bio *nxt = bio->bi_next;
+	struct bio *nxt = bio->bi_next;
 
-		bio->bi_next = NULL;
-		bio->bi_phys_segments = __blk_recalc_rq_segments(q, bio, false);
-		bio->bi_next = nxt;
-	}
+	bio->bi_next = NULL;
+	bio->bi_phys_segments = __blk_recalc_rq_segments(q, bio);
+	bio->bi_next = nxt;
 
 	bio_set_flag(bio, BIO_SEG_VALID);
 }
diff --git a/block/blk-mq-debugfs.c b/block/blk-mq-debugfs.c
index c782e81db627..697d6213c82b 100644
--- a/block/blk-mq-debugfs.c
+++ b/block/blk-mq-debugfs.c
@@ -128,7 +128,6 @@ static const char *const blk_queue_flag_name[] = {
 	QUEUE_FLAG_NAME(SAME_FORCE),
 	QUEUE_FLAG_NAME(DEAD),
 	QUEUE_FLAG_NAME(INIT_DONE),
-	QUEUE_FLAG_NAME(NO_SG_MERGE),
 	QUEUE_FLAG_NAME(POLL),
 	QUEUE_FLAG_NAME(WC),
 	QUEUE_FLAG_NAME(FUA),
diff --git a/block/blk-mq.c b/block/blk-mq.c
index 44d471ff8754..fa508ee31742 100644
--- a/block/blk-mq.c
+++ b/block/blk-mq.c
@@ -2837,9 +2837,6 @@ struct request_queue *blk_mq_init_allocated_queue(struct blk_mq_tag_set *set,
 	    set->map[HCTX_TYPE_POLL].nr_queues)
 		blk_queue_flag_set(QUEUE_FLAG_POLL, q);
 
-	if (!(set->flags & BLK_MQ_F_SG_MERGE))
-		blk_queue_flag_set(QUEUE_FLAG_NO_SG_MERGE, q);
-
 	q->sg_reserved_size = INT_MAX;
 
 	INIT_DELAYED_WORK(&q->requeue_work, blk_mq_requeue_work);
diff --git a/drivers/md/dm-table.c b/drivers/md/dm-table.c
index 4b1be754cc41..ba9481f1bf3c 100644
--- a/drivers/md/dm-table.c
+++ b/drivers/md/dm-table.c
@@ -1698,14 +1698,6 @@ static int device_is_not_random(struct dm_target *ti, struct dm_dev *dev,
 	return q && !blk_queue_add_random(q);
 }
 
-static int queue_supports_sg_merge(struct dm_target *ti, struct dm_dev *dev,
-				   sector_t start, sector_t len, void *data)
-{
-	struct request_queue *q = bdev_get_queue(dev->bdev);
-
-	return q && !test_bit(QUEUE_FLAG_NO_SG_MERGE, &q->queue_flags);
-}
-
 static bool dm_table_all_devices_attribute(struct dm_table *t,
 					   iterate_devices_callout_fn func)
 {
@@ -1902,11 +1894,6 @@ void dm_table_set_restrictions(struct dm_table *t, struct request_queue *q,
 	if (!dm_table_supports_write_zeroes(t))
 		q->limits.max_write_zeroes_sectors = 0;
 
-	if (dm_table_all_devices_attribute(t, queue_supports_sg_merge))
-		blk_queue_flag_clear(QUEUE_FLAG_NO_SG_MERGE, q);
-	else
-		blk_queue_flag_set(QUEUE_FLAG_NO_SG_MERGE, q);
-
 	dm_table_verify_integrity(t);
 
 	/*
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index b6292d469ea4..faed9d9eb84c 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -588,7 +588,6 @@ struct request_queue {
 #define QUEUE_FLAG_SAME_FORCE	12	/* force complete on same CPU */
 #define QUEUE_FLAG_DEAD		13	/* queue tear-down finished */
 #define QUEUE_FLAG_INIT_DONE	14	/* queue is initialized */
-#define QUEUE_FLAG_NO_SG_MERGE	15	/* don't attempt to merge SG segments*/
 #define QUEUE_FLAG_POLL		16	/* IO polling enabled if set */
 #define QUEUE_FLAG_WC		17	/* Write back caching */
 #define QUEUE_FLAG_FUA		18	/* device supports FUA writes */
-- 
2.9.5

