Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B3DFC4360F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 11:14:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 33BD22086C
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 11:14:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 33BD22086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C546C8E0004; Fri, 15 Feb 2019 06:14:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C04138E0001; Fri, 15 Feb 2019 06:14:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF3128E0004; Fri, 15 Feb 2019 06:14:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8670E8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 06:14:18 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id c84so7837479qkb.13
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 03:14:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=slTW8uoG6sTMlKcMLmau18LMT15MeeTevHwmv3l5NcU=;
        b=q1nW9I825t0KaiPLMjyrF3hSRLF/s1rtAfsYdVmr9rGWQCFISEUTk/Sok+uejo1ajR
         0ylVB7hj9j7r/Okx9xwbbXvF1j0ONP+pMFqKJtOxXzeL5wD4Rjx+LU71D2hn+BgfLidg
         VVTc/yMJgb6ByzQFX6jq4cKMJ6JnK9bHWV+kI5xy6+qrY0SiQG4WTnqxUwnGvgyJaX9u
         i1135svHoPnCnYXIPepCJ1On1m3SiLJtv3IqSVBtQ1iY4Fr2g/Bs3d1rNd7JWtu/kxuQ
         xsClylBgM4KuuDPiy8Y4iHpzQRCJJej0GvqqvQsD1VyluPR+UB0ecDYhjtLGCEnMJkq4
         OGVg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuaJmnE6YmzXhZHfS0oIWQWEcZUYWx+ZbtZ/BuR4FW7HO0yYeJ/a
	2NpyhkNFhtWrHoPOPwd/gaLRG7zzaFfHljQjF3MRU6d9MBolvxoev4ZjKhSe2BAjT7rfkaLpmEZ
	yubtxy4DMDjufAiNwRYOD2pqNp6hNO+B4xKbWoVXc7u8iVKzOwaRIgJZio/Js5JXWwA==
X-Received: by 2002:ac8:dc5:: with SMTP id t5mr6883325qti.80.1550229258327;
        Fri, 15 Feb 2019 03:14:18 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZEOlxpk8tl3iIdC3IsBH3tlAEfPi6FN89OoqWp/qyRgjoekTFTeuMpgAO5eeQqFC6l1+zK
X-Received: by 2002:ac8:dc5:: with SMTP id t5mr6883293qti.80.1550229257754;
        Fri, 15 Feb 2019 03:14:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550229257; cv=none;
        d=google.com; s=arc-20160816;
        b=kT0cS/MxvQyCLt8f30BjO6KvSgK3wKxZc3k8uUpGKUATCB1aWqUlB4g9EaAkxfJ5V4
         cmCor+z0At9MiltSpH+lSj1oX31CtVbGuTRXtIVJ23aitI0iry08DDwYcI8ekUUYqfK2
         gvtggWE29AqfbekhLrn1IKvNtbTq/kw/TAC2n8C02DTYK48U4MRE0K4pb6VhWRHYaL5C
         LWat3hb30dGel4yoRfstygtL/UEpqG0rQ5bLzvkgkKeNy+Wy+BZmwDvm1GRP+QCpJdAm
         m3bRcMuPUA12mC3ZjyLEMqFrQui2sti4aahH/UUhbRQHe9N1M4dt/ICmkx3jM0VLS2lq
         HYOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=slTW8uoG6sTMlKcMLmau18LMT15MeeTevHwmv3l5NcU=;
        b=fpGWfbQv+mnuKuK5PgYRpmkrmeWtuKF4tXDXwNR1EQCErtfpokaYhDW0bc0M2B7VKZ
         Sy7/8yvEg8jqNsYoo/poB8h25z+LZspgQAtnbR1gC2PmK5ty9BMq5M7WEjyVngOLZWxz
         U3o+5EjOdZVHOTZL+jLXm3GS6FTHfZIpNGc+dgNkD64vlJcRG/leMLUyCJmxmNs8BVO2
         S7A2RycgSRxjb+yMBPZp9LtZ8bNvN8+T5b+wOoe8qej3qlsmXltbqmWyriRUvsAQEq76
         wd3ibNWJPHFTuu5+PhjPZOF4yQ9LTuo7p1iAgUkZh3yefp1n4QpQAQkVEGmWyY5wjl2W
         kDHg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e10si1292036qth.95.2019.02.15.03.14.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 03:14:17 -0800 (PST)
Received-SPF: pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B0FAE8666D;
	Fri, 15 Feb 2019 11:14:16 +0000 (UTC)
Received: from localhost (ovpn-8-22.pek2.redhat.com [10.72.8.22])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 01A5960C62;
	Fri, 15 Feb 2019 11:13:59 +0000 (UTC)
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
Subject: [PATCH V15 02/18] block: don't use bio->bi_vcnt to figure out segment number
Date: Fri, 15 Feb 2019 19:13:08 +0800
Message-Id: <20190215111324.30129-3-ming.lei@redhat.com>
In-Reply-To: <20190215111324.30129-1-ming.lei@redhat.com>
References: <20190215111324.30129-1-ming.lei@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Fri, 15 Feb 2019 11:14:17 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

It is wrong to use bio->bi_vcnt to figure out how many segments
there are in the bio even though CLONED flag isn't set on this bio,
because this bio may be splitted or advanced.

So always use bio_segments() in blk_recount_segments(), and it shouldn't
cause any performance loss now because the physical segment number is figured
out in blk_queue_split() and BIO_SEG_VALID is set meantime since
bdced438acd83ad83a6c ("block: setup bi_phys_segments after splitting").

Reviewed-by: Omar Sandoval <osandov@fb.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Fixes: 76d8137a3113 ("blk-merge: recaculate segment if it isn't less than max segments")
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 block/blk-merge.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/block/blk-merge.c b/block/blk-merge.c
index 71e9ac03f621..f85d878f313d 100644
--- a/block/blk-merge.c
+++ b/block/blk-merge.c
@@ -367,13 +367,7 @@ void blk_recalc_rq_segments(struct request *rq)
 
 void blk_recount_segments(struct request_queue *q, struct bio *bio)
 {
-	unsigned short seg_cnt;
-
-	/* estimate segment number by bi_vcnt for non-cloned bio */
-	if (bio_flagged(bio, BIO_CLONED))
-		seg_cnt = bio_segments(bio);
-	else
-		seg_cnt = bio->bi_vcnt;
+	unsigned short seg_cnt = bio_segments(bio);
 
 	if (test_bit(QUEUE_FLAG_NO_SG_MERGE, &q->queue_flags) &&
 			(seg_cnt < queue_max_segments(q)))
-- 
2.9.5

