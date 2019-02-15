Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97626C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 11:15:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5BBB921B1C
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 11:15:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5BBB921B1C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EEBBC8E0007; Fri, 15 Feb 2019 06:15:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E9BD68E0001; Fri, 15 Feb 2019 06:15:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB43B8E0007; Fri, 15 Feb 2019 06:15:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id AEF848E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 06:15:11 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id a65so7820171qkf.19
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 03:15:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=Fr9EnIrxI+HhD+i6K4i9/AzKSS6rcNfuTuDhUsAQpw4=;
        b=W1zSOaZiY91Gn9w60D5svHyFxgXAI5s8VH/seJgLU7hlruJuRKn0yzkkTGPdnQub+W
         QNJO0gRG9at+6YdyNIgeb8SZEbi0MUjkyJ2YtahvHOXhie0Th9hKAIghKPBqLKtp2701
         8Nhu5d9o++0XZKyZyNsgLs7yFuNhwfzKcXgMCMSfAVKYY0LI6ark/dTc/dYGAikccxni
         CbqUrUie68R3oPd9sjsZirVeEJPit40LKMJvleh4EhuK1CmZKk8fL+zLrJ1uLneZf9Kg
         R0gRsLlRqUIb9vCsJYKfaL/DC8r6KZpcDQPIIxdoXMmc5W3I/AqhrgI2r+YvejV/Hk2l
         cD+Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZmbzwuIvYt7gYHRnn17wA12IOWsVGes2Y0Hpa+J7HJGW1VN31r
	/0tjQiFeaQbA858yuiGYPXW7hHBZh8v0Pzrb/yQNozfaMk/LkArxX2Ro/NtPt0Y9DD8ly53i2Nv
	D3k2/jjuDVyIhNPn5yqbgF+4FjqRo4k3qI0RxAGagW/C4U1W0nFrE9+7yVnzqlBkCNw==
X-Received: by 2002:a37:8b41:: with SMTP id n62mr6517974qkd.262.1550229311467;
        Fri, 15 Feb 2019 03:15:11 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbT1HBuRqekm2Z/LE5kXWMmInnx3aUAAPRtfYbxhOH1Tm62iXwSexTzrKjMcBLD7Jsqnat6
X-Received: by 2002:a37:8b41:: with SMTP id n62mr6517943qkd.262.1550229310833;
        Fri, 15 Feb 2019 03:15:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550229310; cv=none;
        d=google.com; s=arc-20160816;
        b=NyxFv3z08x/2cFTSNlI1zRLlglT7x9LUMeXxqCfff5KYUb/DVD3wUNAbG+jN71L6Ql
         x5iO4Jb+fjH0WK2Wow+yADqsy91ajlPWc3byKJ8c75LumASgFuwocjD5k2zStFBcU/l+
         j/GuAMYOLFX2ztn+JgSJ/JdcUEoCFGkFAWCx19odLJ690XUHNXqmcbhYiSC4wY0fstLe
         OzJY8+gbgW3Z/eQkP9HNTrg4XveJ8F3nJl8btkWo1+jUWiMV6VNb4JSGITaLmeFAYZAa
         +HqrVU0vvmyu4ZQqO6nFpdPosBTC/uFrz4WDqahbjPGycXzkKcBJl0j/iHJFXaYzlcpl
         nF/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=Fr9EnIrxI+HhD+i6K4i9/AzKSS6rcNfuTuDhUsAQpw4=;
        b=eg+uTKnvrKkaA196vPE75wqyc4La8ywF/bt+9mv2t/9rPlv4ckmQqxfUFElfS53TLp
         L+7Qw3+VVKEBtsiPpuBpc0CCohhK0DA+7haJh6DwvhATY9HH70NzmkQhul6nxSH5Wnyd
         nq74+n8E0+eUZph0AkVWl2VMc57JSEhO0uCezIdjXBn1vokI+y/PuWFmBwcQ5pUCPQev
         RGcOkGTVmwSDkgWiODiCl/gYeHp7keY7BUI6s3MnIzBwJnfzWFPHw3Ln7aw08Bh9jmfI
         u6CJkLPvNzYU7w7gbLE0YJG27kvbDh/iPOPxN0KbuEmXM5wmlc19JKzIyp5Lnh+vOv0k
         KJHg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a62si3309496qke.165.2019.02.15.03.15.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 03:15:10 -0800 (PST)
Received-SPF: pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E52A5C075BDF;
	Fri, 15 Feb 2019 11:15:08 +0000 (UTC)
Received: from localhost (ovpn-8-22.pek2.redhat.com [10.72.8.22])
	by smtp.corp.redhat.com (Postfix) with ESMTP id C8457600C1;
	Fri, 15 Feb 2019 11:14:53 +0000 (UTC)
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
Subject: [PATCH V15 05/18] block: introduce bio_for_each_bvec() and rq_for_each_bvec()
Date: Fri, 15 Feb 2019 19:13:11 +0800
Message-Id: <20190215111324.30129-6-ming.lei@redhat.com>
In-Reply-To: <20190215111324.30129-1-ming.lei@redhat.com>
References: <20190215111324.30129-1-ming.lei@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Fri, 15 Feb 2019 11:15:10 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

bio_for_each_bvec() is used for iterating over multi-page bvec for bio
split & merge code.

rq_for_each_bvec() can be used for drivers which may handle the
multi-page bvec directly, so far loop is one perfect use case.

Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Omar Sandoval <osandov@fb.com>
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 include/linux/bio.h    | 10 ++++++++++
 include/linux/blkdev.h |  4 ++++
 2 files changed, 14 insertions(+)

diff --git a/include/linux/bio.h b/include/linux/bio.h
index 72b4f7be2106..7ef8a7505c0a 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -156,6 +156,16 @@ static inline void bio_advance_iter(struct bio *bio, struct bvec_iter *iter,
 #define bio_for_each_segment(bvl, bio, iter)				\
 	__bio_for_each_segment(bvl, bio, iter, (bio)->bi_iter)
 
+#define __bio_for_each_bvec(bvl, bio, iter, start)		\
+	for (iter = (start);						\
+	     (iter).bi_size &&						\
+		((bvl = mp_bvec_iter_bvec((bio)->bi_io_vec, (iter))), 1); \
+	     bio_advance_iter((bio), &(iter), (bvl).bv_len))
+
+/* iterate over multi-page bvec */
+#define bio_for_each_bvec(bvl, bio, iter)			\
+	__bio_for_each_bvec(bvl, bio, iter, (bio)->bi_iter)
+
 #define bio_iter_last(bvec, iter) ((iter).bi_size == (bvec).bv_len)
 
 static inline unsigned bio_segments(struct bio *bio)
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index 3603270cb82d..b6292d469ea4 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -792,6 +792,10 @@ struct req_iterator {
 	__rq_for_each_bio(_iter.bio, _rq)			\
 		bio_for_each_segment(bvl, _iter.bio, _iter.iter)
 
+#define rq_for_each_bvec(bvl, _rq, _iter)			\
+	__rq_for_each_bio(_iter.bio, _rq)			\
+		bio_for_each_bvec(bvl, _iter.bio, _iter.iter)
+
 #define rq_iter_last(bvec, _iter)				\
 		(_iter.bio->bi_next == NULL &&			\
 		 bio_iter_last(bvec, _iter.iter))
-- 
2.9.5

