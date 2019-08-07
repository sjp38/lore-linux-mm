Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B193C31E40
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1544E21872
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tJ4avExM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1544E21872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A7EE6B026A; Tue,  6 Aug 2019 21:34:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 08C3A6B026B; Tue,  6 Aug 2019 21:34:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E00916B026C; Tue,  6 Aug 2019 21:34:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9BFF36B026A
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:34:03 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id y7so6923138pgq.3
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:34:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=5vxuyadJL7U7uLaLdbmi0wM48++CcjfxvCZKqh2vh4A=;
        b=CUwWlr32yLHbKm/RtgwL64OBDLPX00wx5B54hee+zd5xg8O8KDLHgIbEi1OdANOo2n
         EYjqKR20WjGnY6o5BL+3Z5Gbt+kCoxxdWX3zKo+HtDu0JY4VCnuTLi4d4DxCQ0k2j48P
         o56nlt1Z/g/tTt9wkqLVGgjC0Vq/kpksLDdzaAZHHVI7Q2EjXwhbDfEJGD/rDTMUrNsW
         0zciYY1CIIiKQU5E/WkAVEEAOv3/RI6+J8liIaokkNYrxa2TjY1jwibR81joNxLNfgkA
         7IbIEKcspdKjbFs9+CxKu/Vh14ZnoqVPJrZHTkDnE0k9Ck2OBM3zUmFNWGvv4qTbI2yM
         I+Hg==
X-Gm-Message-State: APjAAAUBfjfuGPQKoyb8nF9rFr8zhZv5b4llE3b9O0XT48JBiBfKuXBF
	ebi7pKobxEnGshAI1B52wDr5Ya5AQVddNFJRuwJ4gkclKO7wyF/hhZROzb5flEhKWlHu6ceBTFx
	gPMFFFngQYWYDDUqG1UDNAEHy60ndDLaM1T4q+lJeedRVbHGCL3Ey6qgvFxPKaNme6w==
X-Received: by 2002:a17:902:1aa:: with SMTP id b39mr5962183plb.333.1565141643314;
        Tue, 06 Aug 2019 18:34:03 -0700 (PDT)
X-Received: by 2002:a17:902:1aa:: with SMTP id b39mr5962130plb.333.1565141642308;
        Tue, 06 Aug 2019 18:34:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141642; cv=none;
        d=google.com; s=arc-20160816;
        b=qrjnjeN9un72p4GVHSB3zqB2Y7NPD7VoKKYw35cDzY45f7DbJ5oQOyuy4hdW7Q+NF1
         W47ojTzdGkcEZ79dBQ97+VCK5wsqmBPOv7yWf8bSGOqEu/5fikbQFspwKnABVdxVklJh
         QzdFNBBYo4SwsGg1E73LdcSy03R3+Czx3905/H6O0Wnc0kiBbE3YuxH9czaPAfsnRlqB
         d/ad4vSlNz/m64kRp3oz51g7eBDw7pqzL5R9Va67NiZSUF+O81RcmKW2RJ0uEXsEymn8
         NQybC7c1EBMI8M81E1Iacq47EGDIYa9c+fMPi12nkxu3tB+UiEbywoc5ZLzKW4L+HH4z
         8DCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=5vxuyadJL7U7uLaLdbmi0wM48++CcjfxvCZKqh2vh4A=;
        b=u5mofrVh9mlLFRtSWEm3KSPl0j1IIMjJAtpI/NXhK/gaKy4eyfQFd0+4Uk0gJiZ9UB
         j/DtyJaQq4ziYacGAgIAmEeZVunmhL86GJRypb2EVhWP9gyAPoXGLXuSivGuhPB3nbw1
         z14yQ01C21OY4GAxrYvC8hURR53J9QXibOrtQ4vRzznp8kUgfblH4aw+XStMcuaA/V4b
         hOa0b3EzXxFSgvkBf5+AWg2xdmc9zKr+m07S3g9JYompcR73IDyntwPXuZ3cTw14n8Dv
         jTLQilBOxW3VP/azql0gA+VLYvkOF2LujjNTvdvwvwEeyQYU+RSjVPCU3w/SvUhoI1LB
         2RHw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tJ4avExM;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y22sor18982020pgl.49.2019.08.06.18.34.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:34:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tJ4avExM;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=5vxuyadJL7U7uLaLdbmi0wM48++CcjfxvCZKqh2vh4A=;
        b=tJ4avExMGOslRL3KTWrhxlFpoBzlcAAoAY6nsujGir08N57EmfZrSbOMeRJcJde7Uj
         6p8KfFB2QlchOp80DqoDBBsPKN3gUIJOh4n7D6Yh9T3nSHLo+8OFWd8EJLXKFWC0xEFu
         BmWUmZQDsFc5eWFMiByCMGNsi+mAFSq87ACVXRceUieYWtrqNYA6DLXxvBADUzuXvcU6
         1ZXKcyzgzSqHuvc1l/kZ62Ao/hhcpehqRB7H988g3B52fcurQVWKcDzBWGtinssBwiFv
         8PQfq3+x8otin0I6bbeyX/WVus24QowHZw+Uv5/OsksPBR/5x/rAPJ/L+1xe6jkKCsU8
         nEag==
X-Google-Smtp-Source: APXvYqwZ5yA40o4DlM/E4D19FajcupEJefAyWq7AP8+bod/B2xp44JmZHMRv4wRgb1laJgr8Owsqyg==
X-Received: by 2002:a65:6256:: with SMTP id q22mr5552901pgv.408.1565141642021;
        Tue, 06 Aug 2019 18:34:02 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.34.00
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:34:01 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	amd-gfx@lists.freedesktop.org,
	ceph-devel@vger.kernel.org,
	devel@driverdev.osuosl.org,
	devel@lists.orangefs.org,
	dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org,
	kvm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-block@vger.kernel.org,
	linux-crypto@vger.kernel.org,
	linux-fbdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-media@vger.kernel.org,
	linux-mm@kvack.org,
	linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	linux-rpi-kernel@lists.infradead.org,
	linux-xfs@vger.kernel.org,
	netdev@vger.kernel.org,
	rds-devel@oss.oracle.com,
	sparclinux@vger.kernel.org,
	x86@kernel.org,
	xen-devel@lists.xenproject.org,
	John Hubbard <jhubbard@nvidia.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	Hans Verkuil <hans.verkuil@cisco.com>,
	Sakari Ailus <sakari.ailus@linux.intel.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH v3 11/41] media/v4l2-core/mm: convert put_page() to put_user_page*()
Date: Tue,  6 Aug 2019 18:33:10 -0700
Message-Id: <20190807013340.9706-12-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190807013340.9706-1-jhubbard@nvidia.com>
References: <20190807013340.9706-1-jhubbard@nvidia.com>
MIME-Version: 1.0
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

Cc: Mauro Carvalho Chehab <mchehab@kernel.org>
Cc: Kees Cook <keescook@chromium.org>
Cc: Hans Verkuil <hans.verkuil@cisco.com>
Cc: Sakari Ailus <sakari.ailus@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Robin Murphy <robin.murphy@arm.com>
Cc: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: linux-media@vger.kernel.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/media/v4l2-core/videobuf-dma-sg.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/media/v4l2-core/videobuf-dma-sg.c b/drivers/media/v4l2-core/videobuf-dma-sg.c
index 66a6c6c236a7..d6eeb437ec19 100644
--- a/drivers/media/v4l2-core/videobuf-dma-sg.c
+++ b/drivers/media/v4l2-core/videobuf-dma-sg.c
@@ -349,8 +349,7 @@ int videobuf_dma_free(struct videobuf_dmabuf *dma)
 	BUG_ON(dma->sglen);
 
 	if (dma->pages) {
-		for (i = 0; i < dma->nr_pages; i++)
-			put_page(dma->pages[i]);
+		put_user_pages(dma->pages, dma->nr_pages);
 		kfree(dma->pages);
 		dma->pages = NULL;
 	}
-- 
2.22.0

