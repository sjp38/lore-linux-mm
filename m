Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8CB3C282CE
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 21:09:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B0B1920850
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 21:09:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B0B1920850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 96AA66B0278; Thu, 11 Apr 2019 17:09:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F9036B0279; Thu, 11 Apr 2019 17:09:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6AF4F6B027A; Thu, 11 Apr 2019 17:09:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 43A5C6B0278
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 17:09:33 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id x58so6891586qtc.1
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 14:09:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ZX+IVIPUOx8/j9xWWpixjgXqzvod7vEUO8iiE6HQVo4=;
        b=LXAYIqlAsTTJxKnLICMZKdCl+qo6htxmqPXkMjj8h2CoSaS3MGJfY9DOkzKWmn0mVB
         W03Ubm8/w7XRz8ixScMYyt4huiSUdBM4ER+aO87mZ1lNBpcI1WOpGtMu7RK1+rA23u9+
         f1k3k44AbKCoUG7MSWfi8ztBevyXksQWauWWN03LcVCBI/i+Y4ThU7ODpJrsISMCpPLX
         RRpdBD4g7T+8J3A9Ul3UfKDJ2Rr0P3ufZu2lJtALph808GgiOGQlfV7lfDO8Fi3roMoy
         Lj24mygKPqAT2/Q63V9FiJEaeraCKoiPRTihQ6w8Lam/BdNycvTTJr1IvE6yoqmNnt7Y
         4rxA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXdIB1HZMhg1i/KbiFs3tBBPP1Eyl/ZHc9RYsXozXUAnqYtu6NB
	diB7hyBVfvd6RcRrb0SfMTl16Itvz7vh7/mog/zRZqCPLdgt7lD+gM1V8LqwI6ix2r5mkm0HhCJ
	sLPUL2TEROw/VfA+dSeAvfmgJcVaao9OiBC8fYNa8o0OBO/UhS++QDPJ+DFwYDJt4PQ==
X-Received: by 2002:a05:620a:1024:: with SMTP id a4mr42246432qkk.232.1555016973054;
        Thu, 11 Apr 2019 14:09:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwjpK5v1rlkpTo9cIHa1toEfmQPNcjycKenharnm7txCZpBSBJUBX4Seq5mh4Qeq7lA3lnc
X-Received: by 2002:a05:620a:1024:: with SMTP id a4mr42246324qkk.232.1555016971690;
        Thu, 11 Apr 2019 14:09:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555016971; cv=none;
        d=google.com; s=arc-20160816;
        b=IkTlUZQKH7buA0ez0ZhABVWk5embW+k/ycYyYTozvKuf1TuSzHS1P4mt/Nt7C9Pdxh
         Qpv4pFfiTLSmUXvxqzyiCYaPB0M9KQpMQZ48wLqG9JZz/169b1FX4yohuNtcqj54qM+w
         yeCWjGKA00VzyzIR55GACPXy3M2QV1OY1NACqiinHMd/tQhfTV6pb8cN/mVtZOi/c3aH
         azdu/E+YVRu4bh7TMbrhMnBS+cLW/enFI0QCXMVx7wzuBT4VruH9LE1aQwg39RLZ5K8y
         DSdvbHrikbO4buEvQP8jhRLhlBq01GEngF5qkfL5GC6ZMTeZyrfigJwrtymI+e4l5Pwj
         ba1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=ZX+IVIPUOx8/j9xWWpixjgXqzvod7vEUO8iiE6HQVo4=;
        b=oWWiVrQNhxtHAOzvyF/jK0iYO3ipADIAxTE41ZYjTmZYngxfaTGDYInm4PcFc2M2Lv
         menMRgbWLycxLjISEym0H4evZnD5sC4OcOcUenGxWCPJPOD0LDhSrqs12Lr3UYaMAyCL
         6E+s8dBaG3fVtudVWUc5lGR/Z59vJfATQ9lFaE2RRY8TYuXqm/zj3A4iqo9ilLQwVx+0
         ai1xX8YBWlAzMCO/IFNRWi3AP02bzb95Hm+2U5y/jGBDlyGZL7jVAEaUWjCZIUNgXVeC
         f7N3gK/ikiXqA6dH7FEohQ3k9FBmVV/0kvGUGmYS7HDENiGotdu/4aCRtNlky0/WFdX4
         Vwug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m31si6256131qvg.182.2019.04.11.14.09.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 14:09:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B58E9A0918;
	Thu, 11 Apr 2019 21:09:30 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 8FEDD5C225;
	Thu, 11 Apr 2019 21:09:21 +0000 (UTC)
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
	Yan Zheng <zyan@redhat.com>,
	Sage Weil <sage@redhat.com>,
	Ilya Dryomov <idryomov@gmail.com>,
	ceph-devel@vger.kernel.org
Subject: [PATCH v1 15/15] ceph: use put_user_pages() instead of ceph_put_page_vector()
Date: Thu, 11 Apr 2019 17:08:34 -0400
Message-Id: <20190411210834.4105-16-jglisse@redhat.com>
In-Reply-To: <20190411210834.4105-1-jglisse@redhat.com>
References: <20190411210834.4105-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Thu, 11 Apr 2019 21:09:31 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

When page reference were taken through GUP (get_user_page*()) we need
to drop them with put_user_pages().

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
Cc: Yan Zheng <zyan@redhat.com>
Cc: Sage Weil <sage@redhat.com>
Cc: Ilya Dryomov <idryomov@gmail.com>
Cc: ceph-devel@vger.kernel.org
---
 fs/ceph/file.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/ceph/file.c b/fs/ceph/file.c
index 6c5b85f01721..5842ad3a4218 100644
--- a/fs/ceph/file.c
+++ b/fs/ceph/file.c
@@ -667,7 +667,8 @@ static ssize_t ceph_sync_read(struct kiocb *iocb, struct iov_iter *to,
 			} else {
 				iov_iter_advance(to, 0);
 			}
-			ceph_put_page_vector(pages, num_pages, false);
+			/* iov_iter_get_pages_alloc() did call GUP */
+			put_user_pages(pages, num_pages);
 		} else {
 			int idx = 0;
 			size_t left = ret > 0 ? ret : 0;
-- 
2.20.1

