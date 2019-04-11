Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C373CC282DA
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 21:09:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E10E20850
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 21:09:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E10E20850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DD9A86B0277; Thu, 11 Apr 2019 17:09:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D68006B0278; Thu, 11 Apr 2019 17:09:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B90D76B0279; Thu, 11 Apr 2019 17:09:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 94EAA6B0277
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 17:09:23 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id t22so6870723qtc.13
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 14:09:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=wTeGgPgRtAI59U3mHpRXdkM87C8oLWFhGZMrZW5DVcU=;
        b=lPJ74vh7DLm8Q9uZfYAUJYBEV1k5fZl+TjfbIlMR+IyQBNdEsKRhpSR/CvbNEsqbn0
         buAyUR7Lm9Y3DiD3oKMh0+FZ5nGCJYy5xzAb+2EuMJsoi11Mn/RVgy+YNNZMaegLwpuV
         uV7izUGUtfNGSHbWMI49Dm5Wi/PV2bDMXQnAEuCPl/n/ejVw+gF4qw1h28L+fpIKHQSp
         kM2CPgj1HUZoRCCgaryvk4g04U26GOByY58P+qpuLIfrPkMyBErBqXrO2CGJmyBukPdF
         4/HOm1INuf7kv+vARqNX2m3FFfHnBaJjwOhPqNnqCmWXVObROVDvX3rXaixCL4ubmq/I
         ZA6A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUZglxU0EoVZ+U2uDiGR9pOQonV4aVovPtmhiI8vdMRfYzreAzP
	GUecWHcPDJvwnWLSzhDm7LzvDOpIfEG0AKrAzmGdMLpPn8p7neF3sZbJCdr/HwXJ5hMQUFs3hfi
	0qt4OSsbTiIVdndK+sMz57MWjqUC6oRXqO2EF975LE6zwuMpnTMCa7jg84ZDNDBKnFA==
X-Received: by 2002:a0c:96fd:: with SMTP id b58mr42189699qvd.134.1555016963367;
        Thu, 11 Apr 2019 14:09:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyAokljQFM/684ARSopL1DMcd1zMWptF+UB2OjuTcNZcMFUKHAi9PpO23ElA0QWot8gxKva
X-Received: by 2002:a0c:96fd:: with SMTP id b58mr42189629qvd.134.1555016962494;
        Thu, 11 Apr 2019 14:09:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555016962; cv=none;
        d=google.com; s=arc-20160816;
        b=yeLBO8LCAsmxKfOsKWZ/L/M7urqYqLga/Q9i/SmMJ+jvYRUBJlNdELcVfL9NRDxh0x
         UEX3/UPO0avi+WXkXK6z6GAPr2utAYgKjOLkCtGt3TnRf/RoRbw9M3EsmRnddXr+FbLE
         WhXXyOJpKa18m0eve9PVPRT0YUFnosm6Y+ZmmVJcqPs+LwXD4fVufUACOHEyYxcNL9pP
         nujAzCNw/b50drhyXgtclaMPxu+bqrWwrIswsf7yh2u2kyD1qFUp0K/yM32lvue0sF+q
         2XA2/Oa/CQHAzDYxjYQ1lDLnMs0+mzNk5x26Q1OfDzejg7DxEDko9MJau1yvu46foSQI
         /cvg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=wTeGgPgRtAI59U3mHpRXdkM87C8oLWFhGZMrZW5DVcU=;
        b=sKPQ4j7KWJSww/iv1Tkv6sExPwVFAzwj4+H64EKUI87jV8ihz8ey4XszgrowtHYHeh
         0Tjo2Vx1i0fih1+LK4fToq65EqZ/Hog2tWB7EG0G9ADEkJOPeAq7c/0Gpju7LZ8/8C33
         DG1ficzSXBO75q9de0tskY5O63o+9ucOk9O6cRYOoOVzmlpbpTW+xaqU7ku6+SwAxvXS
         ikASEDL5xquEiumANUh+o45Kg3M3HwpV9CY/+RpLi53rLhktCCy/hGE9t2Vjj/khuAwh
         17Rd8J7p92iAkIqoCKIf7MSf+8ur0zIPjWAKeMnILN3ONpt5NK20rMBAnZoWOxQECzEI
         FKZw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u16si5472025qtk.178.2019.04.11.14.09.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 14:09:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 700C8B082E;
	Thu, 11 Apr 2019 21:09:21 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 4A8945C219;
	Thu, 11 Apr 2019 21:09:11 +0000 (UTC)
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
	Steve French <sfrench@samba.org>,
	linux-cifs@vger.kernel.org,
	samba-technical@lists.samba.org,
	Ilya Dryomov <idryomov@gmail.com>,
	Sage Weil <sage@redhat.com>,
	Alex Elder <elder@kernel.org>,
	ceph-devel@vger.kernel.org
Subject: [PATCH v1 14/15] fs: use bvec_set_gup_page() where appropriate
Date: Thu, 11 Apr 2019 17:08:33 -0400
Message-Id: <20190411210834.4105-15-jglisse@redhat.com>
In-Reply-To: <20190411210834.4105-1-jglisse@redhat.com>
References: <20190411210834.4105-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Thu, 11 Apr 2019 21:09:21 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

When we get a page reference through get_user_page*() we want to keep
track of that and bvec now has the ability to do so. Convert code to
use bvec_set_gup_page() where appropriate.

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
Cc: Steve French <sfrench@samba.org>
Cc: linux-cifs@vger.kernel.org
Cc: samba-technical@lists.samba.org
Cc: Ilya Dryomov <idryomov@gmail.com>
Cc: Sage Weil <sage@redhat.com>
Cc: Alex Elder <elder@kernel.org>
Cc: ceph-devel@vger.kernel.org
---
 fs/ceph/file.c | 3 +++
 fs/cifs/misc.c | 6 +++++-
 2 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/fs/ceph/file.c b/fs/ceph/file.c
index d5561662b902..6c5b85f01721 100644
--- a/fs/ceph/file.c
+++ b/fs/ceph/file.c
@@ -104,6 +104,9 @@ static ssize_t __iter_get_bvecs(struct iov_iter *iter, size_t maxsize,
 				min_t(int, bytes, PAGE_SIZE - start),
 				start);
 
+			/* Is iov_iter_get_pages() using GUP ? */
+			if (iov_iter_get_pages_use_gup(iter))
+				bvec_set_gup_page(&bv, pages[idx]);
 			bvecs[bvec_idx] = bv;
 			bytes -= bv.bv_len;
 			start = 0;
diff --git a/fs/cifs/misc.c b/fs/cifs/misc.c
index bc77a4a5f1af..e10d9f0f5874 100644
--- a/fs/cifs/misc.c
+++ b/fs/cifs/misc.c
@@ -883,7 +883,11 @@ setup_aio_ctx_iter(struct cifs_aio_ctx *ctx, struct iov_iter *iter, int rw)
 
 		for (i = 0; i < cur_npages; i++) {
 			len = rc > PAGE_SIZE ? PAGE_SIZE : rc;
-			bvec_set_page(&bv[npages + i], pages[i]);
+			/* Is iov_iter_get_pages() using GUP ? */
+			if (iov_iter_get_pages_use_gup(iter))
+				bvec_set_gup_page(&bv[npages + i], pages[i]);
+			else
+				bvec_set_page(&bv[npages + i], pages[i]);
 			bv[npages + i].bv_offset = start;
 			bv[npages + i].bv_len = len - start;
 			rc -= len;
-- 
2.20.1

