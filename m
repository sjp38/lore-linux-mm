Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7895CC4360F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 11:16:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 428832229F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 11:16:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 428832229F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E77C08E000E; Fri, 15 Feb 2019 06:16:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DFDEC8E0001; Fri, 15 Feb 2019 06:16:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C9F3F8E000E; Fri, 15 Feb 2019 06:16:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 92E488E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 06:16:24 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id k1so8689536qta.2
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 03:16:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=xr6DahF5ogf42oUHn8yO+xHUQepi7gnUCentUFTY6cc=;
        b=X5l0TNDHZtTMgqRkXfXuPZ2d481rhNCROl4943BuZI0aYdjW6oHvPpYmSMVf+Q97G0
         WIEphz/L9hJtC2iiRvzadYCniED5RQ6FtxB/oDlmXAzRju5vvprnJuSsU8DOuhjnFqVQ
         30eGc+SU31gZnUkw56J5jkbEb4gNLsN9QDxO97scp7wdj2A3a2xgKMP4sDwaZ8LCV1dn
         0reP9s3Fr2z4c2SipPh0ihxyVBAc7uNdsCyta6D785fEaX2Hg33hMvUD2Jzl3ksSfdre
         RRkxGqKZ3LxpEWbwVThOW+5CyaLt/WpvlWQ5vywrVh3siNXJCK5xuqptTo47a7Or22+S
         rG5Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuY2K3Cj+yPqqyZD5r59rszusV2Y7t7ufgz8yFpk2zQIOWOo3OuQ
	VMuZtnEbxG1iULtZdBIZdXUhRfcNv1L9d1HAeJCc12Qh7E6P6QRNPgN1gssKKZE+Tjz3CH7cue5
	ht0YwxW3aNuXbPbsxddCT1uTYGKzJhgjMuE2qV4JL9rl+spFzUgCFKQu3RknQlfcFYA==
X-Received: by 2002:ac8:1662:: with SMTP id x31mr6989876qtk.55.1550229384401;
        Fri, 15 Feb 2019 03:16:24 -0800 (PST)
X-Google-Smtp-Source: AHgI3IagkkfK/wA1OZC34hE3FKhStjbhFBuZKvxUoQnrVXDOzNzsuuSBx3pIou8XR1067j/EhT/1
X-Received: by 2002:ac8:1662:: with SMTP id x31mr6989845qtk.55.1550229383911;
        Fri, 15 Feb 2019 03:16:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550229383; cv=none;
        d=google.com; s=arc-20160816;
        b=bccHXJuaNd6rPjAoCmDxGeindPbgsP7DcSkGQ7/faARTFN9d4kMNEa+M2JS3sVA2Lw
         mSTdJFuSA9e/T34vloPyI3E7uZ1PpcM+ZpOzXlonBgB9Hk+GEpCrQWkchkS7s2yZfVZm
         dLOXUDw89yMSETsglASUK/yBJe/NuSIcqxuB2sg7Ql067maxYaEH2ytVeeWOV19HK8iL
         8R70YSFNt+z95WEtsfz4HdPe8YRCGhOyKkqTxj43CTGWYVhH2hgKEkmP1eAQe9zqF4sO
         Natsechh5IGWDxd5eQkOATJGwlfFmdcrOzh67dpYcUcqNcJdzRsxhEDTqrrXO7HJ6nW8
         gadQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=xr6DahF5ogf42oUHn8yO+xHUQepi7gnUCentUFTY6cc=;
        b=e/O/bOnTGSXRkNd70LwfDUPSF2KXcqB67WQ7zWj9Guu8//HBeBsPSvnToIJwU1N25K
         jIRZ3JyCehrygvnxdOcSqZopf82ayPCMSjHupWuRJPV+PAVmtRGowRJ5vb/qPfd9jvJX
         MZqNociFYlL/cPg6KLmYBWuphaiauq84FHQVjBSysHwHNh+hDakYLazf7TpIgo1tu+Vc
         e43kPGqZhXa4HkblBdgfoFYCHhtFjVnRxdW4h3euu7jQxdS6TCXd7X6Rpi9tdReb3RsU
         XN7j7R/LPOZtnmjIz5Xogmc9rjchSVQdbj23BIxJ0o4nH4xpfqHL6rKt4DAN0T4U7ZSN
         zSWw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y5si2032823qtc.187.2019.02.15.03.16.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 03:16:23 -0800 (PST)
Received-SPF: pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5204DC7857;
	Fri, 15 Feb 2019 11:16:22 +0000 (UTC)
Received: from localhost (ovpn-8-22.pek2.redhat.com [10.72.8.22])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 38D6A26E74;
	Fri, 15 Feb 2019 11:16:20 +0000 (UTC)
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
Subject: [PATCH V15 12/18] bcache: avoid to use bio_for_each_segment_all() in bch_bio_alloc_pages()
Date: Fri, 15 Feb 2019 19:13:18 +0800
Message-Id: <20190215111324.30129-13-ming.lei@redhat.com>
In-Reply-To: <20190215111324.30129-1-ming.lei@redhat.com>
References: <20190215111324.30129-1-ming.lei@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Fri, 15 Feb 2019 11:16:23 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

bch_bio_alloc_pages() is always called on one new bio, so it is safe
to access the bvec table directly. Given it is the only kind of this
case, open code the bvec table access since bio_for_each_segment_all()
will be changed to support for iterating over multipage bvec.

Acked-by: Coly Li <colyli@suse.de>
Reviewed-by: Omar Sandoval <osandov@fb.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 drivers/md/bcache/util.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/md/bcache/util.c b/drivers/md/bcache/util.c
index 20eddeac1531..62fb917f7a4f 100644
--- a/drivers/md/bcache/util.c
+++ b/drivers/md/bcache/util.c
@@ -270,7 +270,11 @@ int bch_bio_alloc_pages(struct bio *bio, gfp_t gfp_mask)
 	int i;
 	struct bio_vec *bv;
 
-	bio_for_each_segment_all(bv, bio, i) {
+	/*
+	 * This is called on freshly new bio, so it is safe to access the
+	 * bvec table directly.
+	 */
+	for (i = 0, bv = bio->bi_io_vec; i < bio->bi_vcnt; bv++, i++) {
 		bv->bv_page = alloc_page(gfp_mask);
 		if (!bv->bv_page) {
 			while (--bv >= bio->bi_io_vec)
-- 
2.9.5

