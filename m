Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB7D2C282CE
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 21:09:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9209220850
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 21:09:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9209220850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C9796B0272; Thu, 11 Apr 2019 17:09:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 17C186B0273; Thu, 11 Apr 2019 17:09:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F33EB6B0274; Thu, 11 Apr 2019 17:09:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id D0CAB6B0272
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 17:09:04 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id e31so6925079qtb.0
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 14:09:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=90HIC5obuLmHnwIKhEY8SaLby7fSTiZozn2ahR/xyIM=;
        b=aw8MqcR0P06638cyWyEBgq4XJUvDYec62xsqiK+e7fgPRktFtPdgLj3ktce5YpFFuJ
         8cH6a5vSMyQkZNuplcQZGaX/wETbG0gqvw3IBjVjkxFJBn8Hx/KjOfIvJFg96LGObeUR
         ziWdo0CPlqXcks8wLLpYpsqxaRu5wxzWQLAdrYmSIOCzFum8c9mNEUwpCUgAT5bCH7Vp
         ZQ0572vKB9RyS1vXcHmw3rjlK/cEM7ZIu0BXT8tWjPwuuUbmuS9+GUnkBKZaU8XbvvCa
         xBM+Ii24UF9oGYO7I29/OAkw7aQSh/OI4LhuN889FQXrJvC2xCbEava0zV04O7UUoI5h
         ac7g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX4mJf1hjJdMeryPj6dKB1CCOD6tmv3to6DBoSpaZpKrnGhPGGl
	Uw3H8rJwsgQRXnThPOZwJwrEMMGwmERoINEcxWYHTvgSK8UiOjDxmxaLvzgKpxyb2kfQoEL8p4u
	xf1q4jeG5+rse4S24qSjdtrVyyqcSx4NFlRKvgnOVBqCXQEB3KTNUViljBpmcsIitwg==
X-Received: by 2002:aed:3641:: with SMTP id e59mr43522338qtb.235.1555016944625;
        Thu, 11 Apr 2019 14:09:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx5CwQ5GwMS5SaBBC6kLJZOrrfFrwuq4pwK8W48mGxXNN/sy6faHnmIup8VJ0oEKhZy6Rml
X-Received: by 2002:aed:3641:: with SMTP id e59mr43522261qtb.235.1555016943564;
        Thu, 11 Apr 2019 14:09:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555016943; cv=none;
        d=google.com; s=arc-20160816;
        b=rNcfWYPV2H9ZvXLTxtVbD1BV055q4xH4WcZbAvgRVMdI5zsj1d7LLmhbQ+5Yh3wAmV
         A4aL6KDOKComiZ81eGPweax8f8bpxG5t86C3C5BmS9RT8pgsUEDVjcZwRx045UHNgDQi
         /1CAxOyWCZXD4ls/rAUXR5SzmCeWeueDJTqiAbpF92dOAGTHx/9he+ugEl+0k9UOwBGv
         nKr7KKFY/Zk/g+smdBl6VRGcWobp0+uKYuDhgSvpddu+TtZANttcu0CzJtXbOA0V3tm5
         9WGrxaNCZ5L8l65aP7rmSr3ii/nD/KoPERDTMEbB0+8Eu/iyog9DuM65WUavqeGK5JuG
         0FtQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=90HIC5obuLmHnwIKhEY8SaLby7fSTiZozn2ahR/xyIM=;
        b=sbumg+D+Llo/1peMZacmOvBaGaMLHaTH8D94mxthcSLLEepAxCgWaSRP1wiBQvcyqE
         71ZrznWCzZ/1LIwicI5Z8FucwvG1qmgnUqwIoPuRD4VFtbRlCzYt5ZdunEEN73WpSTo4
         n/xX9HkuTmPBnPBD/f6xutKqQ8fZFIak4MkrWbVPqQP1Ijv6hzW6qdvi9jnLDALcizxX
         MCUo7GQ29iQcWRxUE+iZK6VYmiZ0tzNrrk0LjooIwFHsBwMQym+F4l8O0YVYdRUEcTmI
         62s6PHpeEIZiHvU2qG7sAyIwhDJ4z6eumj1ACZqzYIhwasWolzRiQDnOqQFXP9Gpms1d
         mOuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r14si1328055qvn.15.2019.04.11.14.09.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 14:09:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id AFE38309E9A7;
	Thu, 11 Apr 2019 21:09:02 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 4018C5C220;
	Thu, 11 Apr 2019 21:09:01 +0000 (UTC)
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
Subject: [PATCH v1 09/15] block: bvec_put_page_dirty* instead of set_page_dirty* and bvec_put_page
Date: Thu, 11 Apr 2019 17:08:28 -0400
Message-Id: <20190411210834.4105-10-jglisse@redhat.com>
In-Reply-To: <20190411210834.4105-1-jglisse@redhat.com>
References: <20190411210834.4105-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Thu, 11 Apr 2019 21:09:02 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

Use bvec_put_page_dirty*() instead of set_page_dirty*() followed by a call
to bvec_put_page(). With this change we can use the proper put_user_page*()
helpers.

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
 block/bio.c    | 8 ++------
 fs/block_dev.c | 8 +++-----
 fs/ceph/file.c | 6 +-----
 fs/cifs/misc.c | 8 +++-----
 4 files changed, 9 insertions(+), 21 deletions(-)

diff --git a/block/bio.c b/block/bio.c
index b74b81085f3a..efd254c90974 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -1448,12 +1448,8 @@ static void __bio_unmap_user(struct bio *bio)
 	/*
 	 * make sure we dirty pages we wrote to
 	 */
-	bio_for_each_segment_all(bvec, bio, i, iter_all) {
-		if (bio_data_dir(bio) == READ)
-			set_page_dirty_lock(bvec_page(bvec));
-
-		bvec_put_page(bvec);
-	}
+	bio_for_each_segment_all(bvec, bio, i, iter_all)
+		bvec_put_page_dirty_lock(bvec, bio_data_dir(bio) == READ);
 
 	bio_put(bio);
 }
diff --git a/fs/block_dev.c b/fs/block_dev.c
index 9761f7943774..16a17fae6694 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -261,11 +261,9 @@ __blkdev_direct_IO_simple(struct kiocb *iocb, struct iov_iter *iter,
 	}
 	__set_current_state(TASK_RUNNING);
 
-	bio_for_each_segment_all(bvec, &bio, i, iter_all) {
-		if (should_dirty && !PageCompound(bvec_page(bvec)))
-			set_page_dirty_lock(bvec_page(bvec));
-		bvec_put_page(bvec);
-	}
+	bio_for_each_segment_all(bvec, &bio, i, iter_all)
+		bvec_put_page_dirty_lock(bvec, should_dirty &&
+				!PageCompound(bvec_page(bvec)));
 
 	if (unlikely(bio.bi_status))
 		ret = blk_status_to_errno(bio.bi_status);
diff --git a/fs/ceph/file.c b/fs/ceph/file.c
index 6a39347f4956..d5561662b902 100644
--- a/fs/ceph/file.c
+++ b/fs/ceph/file.c
@@ -160,11 +160,7 @@ static void put_bvecs(struct bio_vec *bvecs, int num_bvecs, bool should_dirty)
 	int i;
 
 	for (i = 0; i < num_bvecs; i++) {
-		if (bvec_page(&bvecs[i])) {
-			if (should_dirty)
-				set_page_dirty_lock(bvec_page(&bvecs[i]));
-			bvec_put_page(&bvecs[i]);
-		}
+		bvec_put_page_dirty_lock(&bvecs[i], should_dirty);
 	}
 	kvfree(bvecs);
 }
diff --git a/fs/cifs/misc.c b/fs/cifs/misc.c
index 86d78f297526..bc77a4a5f1af 100644
--- a/fs/cifs/misc.c
+++ b/fs/cifs/misc.c
@@ -800,11 +800,9 @@ cifs_aio_ctx_release(struct kref *refcount)
 	if (ctx->bv) {
 		unsigned i;
 
-		for (i = 0; i < ctx->npages; i++) {
-			if (ctx->should_dirty)
-				set_page_dirty(bvec_page(&ctx->bv[i]));
-			bvec_put_page(&ctx->bv[i]);
-		}
+		for (i = 0; i < ctx->npages; i++)
+			bvec_put_page_dirty_lock(&ctx->bv[i],
+					  ctx->should_dirty);
 		kvfree(ctx->bv);
 	}
 
-- 
2.20.1

