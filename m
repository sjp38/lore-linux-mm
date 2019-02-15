Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80718C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 11:14:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 474772086C
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 11:14:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 474772086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE07C8E0003; Fri, 15 Feb 2019 06:13:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B90878E0001; Fri, 15 Feb 2019 06:13:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA9C78E0003; Fri, 15 Feb 2019 06:13:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8431B8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 06:13:59 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id r24so8647947qtj.13
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 03:13:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=jR/ABfQzsk4snuRwt6xiKLLtmUVGlJ+rbLpyE5UJ55c=;
        b=EaowXKcGTQpWQqjXQuVPe1HmxcLryJg6BehdpKwZSbiL1zCTh5mNcXUhgw6cZ8km51
         ca0eajACzPatr7hx7qPeheht6n4vMgUVZi+hj1ZuAeEBqlBjBVcuBMw4ox5skBweMNeA
         exGhJl7866YWsDNfvneNvaZ0v6VbzBRArvBCDXGBtEefIFbOpVI7tL1IfZ4BFUVDiGyK
         cgUqSTsQqDbveZAuajcQtbT5uacYqkuhksFcZspaqWcZygYTE6gPmGEK2hAtoWOsuRbv
         R1zgmPuhFG6cj7PBLmSukgMksbHyMnylCiIt6NlY84S2He+nWnxf+0qX7EwhIbHEkixZ
         mC+w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZqeUwpxBMFxqpvfE4eXp97IvSTWTvkhSspjXXcmok+IYAzW/P6
	ijuCuxgGBCYNvqbSyDodl8e+I8yrCyHq42lD1dq8hsZYX5otMJ7zB8Zm/OC/XaQRr6ybRqa1/MQ
	2xR5lA7bqGE6P22KPxHh/zVrBN2pGraI1fAqZP7DIrdtDjK3dOSXpaUPaSFnl67Xj6w==
X-Received: by 2002:a0c:8c8d:: with SMTP id p13mr6728137qvb.48.1550229239236;
        Fri, 15 Feb 2019 03:13:59 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbAUpJKFiRNCc0iPm7iXGr9Jc5WgezLRzaFkC1CteG9lVn22tEZdWWL0wKmwCJOmN8iAvog
X-Received: by 2002:a0c:8c8d:: with SMTP id p13mr6728107qvb.48.1550229238671;
        Fri, 15 Feb 2019 03:13:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550229238; cv=none;
        d=google.com; s=arc-20160816;
        b=D3NBsmDesov8apYKhQx++kF1mTgMqNhXgRYQuS4XxcnQ0D1bu4EnWTiI8WyNO6wYwf
         9wUYvZvXwwamWzrlSFWzFVwYwWCuu7zormsfs8BSEJzC6KU15DIrnLNhteC5nkHVZdK2
         5O/PDq2czMOggvVQSR5baakNzXL8b4638hIgNj31Lk3wxjbLQk6ensGow6O2u8bUQY3g
         M82leYwW/Z8pCp6pUuG7yRkbsHB3fp9Frkl1MeGOhLYG9qrn2AVqs0NJD+BeBLm+uUHf
         wZ6D9aTYe5oyztIEvpgcKQ/VNZRGloa64IKtjbqFZTEnPdK01+Cl7+3NetMXjtmMkIKV
         GMHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=jR/ABfQzsk4snuRwt6xiKLLtmUVGlJ+rbLpyE5UJ55c=;
        b=QZ0QeEQiU81hDqgIknpJX9nsa8CPCQCv06arftS0jEjv6HMcqQj0nDMLE2BD0dfJNI
         VK8kZwhHAvkPvBHX0pJrzD+7wOzNhXtk8R30FJCIDEH0gzDI6ZXuqVFFH+NFOOkeS2r1
         MMmdHO03W1v1z2qvNjLTRibji9i6cAgmIFE+u/62mutG49QnB3eAq9yGZgZed9VIV03+
         yf+HqODRsXohb50VCueVrzZMQEo/LRzzzUFH9tr9yTuf0WT8fgoziGqlKAnSUs63StWs
         QpAhOtCuGJ/CFwyAGUXgIeyJakz5+anOoxhK5Cthr91/Vl7xRNxlnRTxGl7ElAPhd7/b
         Mlrw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v57si538148qtj.260.2019.02.15.03.13.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 03:13:58 -0800 (PST)
Received-SPF: pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7E31DC0AD406;
	Fri, 15 Feb 2019 11:13:57 +0000 (UTC)
Received: from localhost (ovpn-8-22.pek2.redhat.com [10.72.8.22])
	by smtp.corp.redhat.com (Postfix) with ESMTP id E81596090A;
	Fri, 15 Feb 2019 11:13:49 +0000 (UTC)
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
	cluster-devel@redhat.com
Subject: [PATCH V15 01/18] btrfs: look at bi_size for repair decisions
Date: Fri, 15 Feb 2019 19:13:07 +0800
Message-Id: <20190215111324.30129-2-ming.lei@redhat.com>
In-Reply-To: <20190215111324.30129-1-ming.lei@redhat.com>
References: <20190215111324.30129-1-ming.lei@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Fri, 15 Feb 2019 11:13:58 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Christoph Hellwig <hch@lst.de>

bio_readpage_error currently uses bi_vcnt to decide if it is worth
retrying an I/O.  But the vector count is mostly an implementation
artifact - it really should figure out if there is more than a
single sector worth retrying.  Use bi_size for that and shift by
PAGE_SHIFT.  This really should be blocks/sectors, but given that
btrfs doesn't support a sector size different from the PAGE_SIZE
using the page size keeps the changes to a minimum.

Reviewed-by: Omar Sandoval <osandov@fb.com>
Reviewed-by: David Sterba <dsterba@suse.com>
Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/btrfs/extent_io.c | 2 +-
 include/linux/bio.h  | 6 ------
 2 files changed, 1 insertion(+), 7 deletions(-)

diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index 52abe4082680..dc8ba3ee515d 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -2350,7 +2350,7 @@ static int bio_readpage_error(struct bio *failed_bio, u64 phy_offset,
 	int read_mode = 0;
 	blk_status_t status;
 	int ret;
-	unsigned failed_bio_pages = bio_pages_all(failed_bio);
+	unsigned failed_bio_pages = failed_bio->bi_iter.bi_size >> PAGE_SHIFT;
 
 	BUG_ON(bio_op(failed_bio) == REQ_OP_WRITE);
 
diff --git a/include/linux/bio.h b/include/linux/bio.h
index 7380b094dcca..72b4f7be2106 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -263,12 +263,6 @@ static inline void bio_get_last_bvec(struct bio *bio, struct bio_vec *bv)
 		bv->bv_len = iter.bi_bvec_done;
 }
 
-static inline unsigned bio_pages_all(struct bio *bio)
-{
-	WARN_ON_ONCE(bio_flagged(bio, BIO_CLONED));
-	return bio->bi_vcnt;
-}
-
 static inline struct bio_vec *bio_first_bvec_all(struct bio *bio)
 {
 	WARN_ON_ONCE(bio_flagged(bio, BIO_CLONED));
-- 
2.9.5

