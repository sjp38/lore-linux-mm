Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C58AAC76197
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 04:30:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8473E2199C
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 04:30:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZjncIryv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8473E2199C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 375068E0001; Mon, 22 Jul 2019 00:30:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 326836B0008; Mon, 22 Jul 2019 00:30:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 215CC8E0001; Mon, 22 Jul 2019 00:30:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id DB55F6B0007
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 00:30:19 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id f25so22993092pfk.14
        for <linux-mm@kvack.org>; Sun, 21 Jul 2019 21:30:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=D+V1JOqHKw89xuQJyKyrQPxBPg1TKqg5mmM4KBGZiv0=;
        b=IJEORHUMcTba8ujWC0z+0p4KDhknMUhnZcH21GNESERVymim0LI9FSG4qUzd5Jr3+M
         rJbfHjp3OhAoutussXdKzahF4edKVhBlHXeXtGGZRrRSKe2IzV16iUlSzK4EU9GZxdMc
         xTXhUZ18HbUoVgJJ0sKpb1IIKhqrh++s81kmNHwil0Drb91RiADbGJT3pZU6IJAyweqR
         Tcz6UrQOJerFSfy6EkHBSl9ovznjFsWvK43DkbV3YCvWfl3pBLmhq+3y4iplWbfk2YnQ
         pxhZyjxPBt1nx/S5BCLdvdPWFFuXQw/qJ5hAD6zMx33hkVV1jPxnKLHUrzafHKIMxBzI
         Q60w==
X-Gm-Message-State: APjAAAVgwQif/nq0lYYhYnTDZwXedxGbSUTbte3YMLVyYIK2QskNFTM6
	LF5/9Qosvf1Nr2xe9tjO4g97rwMekY0LKbicfdUklLpEuJNKnawlp/mMWv7FwSzoVBsf2pSsQH4
	lvIn+VV7o9M19FVkfn5xE5z3QzPwQcxodSKLc5o8l33kwT8+SOdFo06dt22iKNzMNoA==
X-Received: by 2002:a63:e948:: with SMTP id q8mr67273630pgj.93.1563769819296;
        Sun, 21 Jul 2019 21:30:19 -0700 (PDT)
X-Received: by 2002:a63:e948:: with SMTP id q8mr67273574pgj.93.1563769818468;
        Sun, 21 Jul 2019 21:30:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563769818; cv=none;
        d=google.com; s=arc-20160816;
        b=Mq962cQfqYH8kDyga6EGTMj55U76MPtnOU/ThHz5bdDwfASo1tD0VWHwEwmbjLvezP
         UCLM3fOOVRHkTbl0fmPb7sDRlhsT9pSA/7gI/7Jac5hdrtO0wek709rVYNT9z+SGRG05
         8pxOK5w1LpxRwwQn1ORpcVhWStutTvKa0dEdDC00fy4rjQbL4F1mpFPZgYX6KJD2Ntfu
         eDkhHI6bPc2lQdtNxxQEUxN1DRqRUPIa7jA6IxUF9waSI1aoMxdXleQD3VCK7Ii5JxNF
         bYEeVuXdEKfjmV9m5YrI1xLzBKYTOhD/glmQU9LFeyMun2ARaLbvZGjLVRJx3vdIWEtq
         5KuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=D+V1JOqHKw89xuQJyKyrQPxBPg1TKqg5mmM4KBGZiv0=;
        b=aAQazYBlsr89l99FasaYcvx4mGSn+vNmsNLQP66czI/ZSEr4QKZGgv/tYvFLPb/l46
         TnqStFw4TtEwrixNXv/axit1AO+Pps1T+U4/C/SdVX4qjsFU6FN1M1CIAuc+8FsulUW/
         vKWhgTW8U+0SDZXSPB8QdMOHzL0fy9ypUDsQgICcm0Eu6bMX2dJrPMqmbXmBcqzXlPQ/
         fU7YDtOLqIooK+Hl0dThEvqpww6iiX2RVUTIXw+5bihbEU08FddivtIV8XpkYBd1mJxG
         HeNGsnQhJa2Lz1rALjKs3Xw3EXzpnOVBuhbAhKNe3AymcQ/qIz7RxW0DG83GzWVZq8FS
         5xsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZjncIryv;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j2sor45873162pll.35.2019.07.21.21.30.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 21 Jul 2019 21:30:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZjncIryv;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=D+V1JOqHKw89xuQJyKyrQPxBPg1TKqg5mmM4KBGZiv0=;
        b=ZjncIryvRUENukVshJFmndluvLLU2arKIPK+YYicUChsIoVAk47zJe62/xRGnaP5sO
         2dIVuxokgzVnbQHvCzkTXpkUYAmteOI1byf9i0Eh4Nry32SQ9hACfIfRqzVmd9cJiRLV
         K9HwOtYgSWbkF9G0wSK5xDI2GGAAixptvpE4fTe363E9YhkxmADQ/Mu9XRx8bTc2aorh
         N1o7z9m3WHPe2EsrnhH9xUt6CS36Mz9r/OpIcDwkj8s1H6FUiNK+g6MeR3C2qRQdfIdw
         al2E1lXQJ0Y1vWlKKViZ99Kmj6ELgJUAJ+cq1tdYD2dh7ezt2sYlt89O5gvFrEpEQJG1
         ZAOA==
X-Google-Smtp-Source: APXvYqxl80v/klDkLGiV/45cokVowIxuUImE7kMceTFkzRgYtQ9KqbkKZkwGuHiecTAs8feNRgDMBA==
X-Received: by 2002:a17:902:6b86:: with SMTP id p6mr74936264plk.14.1563769818237;
        Sun, 21 Jul 2019 21:30:18 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id t96sm34285690pjb.1.2019.07.21.21.30.17
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 21 Jul 2019 21:30:17 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	=?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@intel.com>,
	Boaz Harrosh <boaz@plexistor.com>,
	Christoph Hellwig <hch@lst.de>,
	Daniel Vetter <daniel@ffwll.ch>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	David Airlie <airlied@linux.ie>,
	"David S . Miller" <davem@davemloft.net>,
	Ilya Dryomov <idryomov@gmail.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Jens Axboe <axboe@kernel.dk>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Magnus Karlsson <magnus.karlsson@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Ming Lei <ming.lei@redhat.com>,
	Sage Weil <sage@redhat.com>,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>,
	Yan Zheng <zyan@redhat.com>,
	netdev@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org,
	linux-rdma@vger.kernel.org,
	bpf@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>
Subject: [PATCH 2/3] net/xdp: convert put_page() to put_user_page*()
Date: Sun, 21 Jul 2019 21:30:11 -0700
Message-Id: <20190722043012.22945-3-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190722043012.22945-1-jhubbard@nvidia.com>
References: <20190722043012.22945-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page() or
release_pages().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

Cc: Björn Töpel <bjorn.topel@intel.com>
Cc: Magnus Karlsson <magnus.karlsson@intel.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 net/xdp/xdp_umem.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/xdp/xdp_umem.c b/net/xdp/xdp_umem.c
index 83de74ca729a..9cbbb96c2a32 100644
--- a/net/xdp/xdp_umem.c
+++ b/net/xdp/xdp_umem.c
@@ -171,8 +171,7 @@ static void xdp_umem_unpin_pages(struct xdp_umem *umem)
 	for (i = 0; i < umem->npgs; i++) {
 		struct page *page = umem->pgs[i];
 
-		set_page_dirty_lock(page);
-		put_page(page);
+		put_user_pages_dirty_lock(&page, 1);
 	}
 
 	kfree(umem->pgs);
-- 
2.22.0

