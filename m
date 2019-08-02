Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 851E8C19759
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:20:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3175A2080C
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:20:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IPnKJ+t+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3175A2080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 905A36B026A; Thu,  1 Aug 2019 22:20:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7EF956B026B; Thu,  1 Aug 2019 22:20:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 66B726B026C; Thu,  1 Aug 2019 22:20:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 340F76B026A
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 22:20:27 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id q10so23249852pgi.9
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 19:20:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=5vxuyadJL7U7uLaLdbmi0wM48++CcjfxvCZKqh2vh4A=;
        b=gI0vGplMX/LDdx3V5hpCJIMNUzFZ2c9clYCyCCfXvdhKGVrSvkG0YOCtfkx7mhPAtu
         0Jk9eeYln/M2jgp43PZC/Vxrdo32go23hed+NcDrgWVC9Ls2HXvUyjtv5OJW4PuSLmbF
         H/IF2bbT5b47SlbcMz3oCapSF4/0UrW5Qwg+kNB9y5FHWHcG1CL5v4SAuLDVzB0GCrmN
         E+k5Lcs7K8iL+ZhHxdCQL0v0mslP0kvGnaKZoDc4eLvUqwaP2lZplSNjrPYz3xdryIp0
         YyOrKikWfQ/sfnWp1TtBBKHi4GiB74vm6pcaJbTgeg7bXCuxnNYb5y+rc+uDv76aBNxO
         k+9g==
X-Gm-Message-State: APjAAAUGPPb/ZmdtnsFfpKWKGbcfUCA0bsKbfjuvgTv3OId0Qhbv5ylz
	Ht3Q465rXU3/U2phMTBDo9EH4z0ZAdTSFusRbBIgifJ20iCDEhXYm+xXqFUzkqRZ+wtq/wQyBHM
	Y20PcMx8QjbOSlf/wrNu7DNJlqZTy0KTEwJZ6ApE0Y1fKw9IczFonOab64cTyiyBfew==
X-Received: by 2002:a17:90a:bd8c:: with SMTP id z12mr1927171pjr.60.1564712426895;
        Thu, 01 Aug 2019 19:20:26 -0700 (PDT)
X-Received: by 2002:a17:90a:bd8c:: with SMTP id z12mr1927111pjr.60.1564712425978;
        Thu, 01 Aug 2019 19:20:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564712425; cv=none;
        d=google.com; s=arc-20160816;
        b=LpCI1oBailUewayBc0ZCvKJZhMIA2VFb/4vL9XBYA7cU0pQPEix6tz3OEdxyJjLJSY
         zM2VR+praKa1SQufb3PETvnzAN+RCi/ta9eELeCo2Pk6fn4wZWD3eRK8O6pTZCy2ZvLD
         ti2eZj2ig5fIiFwWS9a6UDDVZwTeyvyfkzvICpftp6uCMm5DqklF8OEQsMJM7A6pf2vR
         kh0vB/De4GEfB2lon48G3MoIq1mQyiqtacqA8qoOiT2pSgpSe1+seqziMZ91evBc5Qn0
         WKBYgPBzyykn7MoIPEWJfkMLRypSPQBTMQB1XRflkUXhiSyImPtKytGNLAisnCUQauNe
         lDQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=5vxuyadJL7U7uLaLdbmi0wM48++CcjfxvCZKqh2vh4A=;
        b=YRWj4qWNer/riFv3Pc9nRYitT6WAau26Mr9YeQujYQBiztqi8hhdqL8QyArUtc8ZEk
         /CwcCJaaoP+649ocvtypt2z8H33I6GPOYwypZr6e/E2yQAXG9rB8PoDAGzFLTj+vHZ6H
         3C1LNcz2lK/IJqzW8T6XM1F+yz7JrDd8UCARZuLCD3NkagDDVv0f/DVeivGnzuKBzdai
         dtdzFeeWZqE5el4o06ors9GdQCaU70432p3H2x5pUdS2+9va5Tnft3bzciUoYgBTMN6b
         Du8wuXAPLKhg1DjNLt5C4XC935WAvlG7YJLJwtneXLa8mdlrgmXSin2aaC8Lbz+qzy50
         l7ug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=IPnKJ+t+;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 73sor87844791plf.60.2019.08.01.19.20.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 19:20:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=IPnKJ+t+;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=5vxuyadJL7U7uLaLdbmi0wM48++CcjfxvCZKqh2vh4A=;
        b=IPnKJ+t+ZuscR+9jkZCr9SYsDod9H1pKxsH7GEiMUhOWm9vGlL+eTdFKhv7CAbJqfW
         uU/KQltFOReuOI2Tb15OkXQ52DWMqedLb39cjCQmyiEWLJR87wjugh79Hhbg0qc6zuHg
         MYJzaAbjIW3STqDPj5Lq2JXvJEE6XELaroV158AptkQMUJ7o1/IZqEXjs4JGgfMi9wWi
         x8L4AJBxrRgeZMqNQthxmzZvgld8OAsmXF7S7qthmuL3HABTVNmwDglQdeK4bcdDS+le
         GYNA0EDvk+skaAjBLW5tt19+LuDGuf6feAdMRYQaTc3LrWG+I4hPzx8Lwm1aQRwe4UW2
         hk+g==
X-Google-Smtp-Source: APXvYqx4n4e9g9/ly0KjHqDWX94uIzBzDxMQOC1nP9LzDlFTNiWIDkQ4j/aY6KUtiphGoFtrA+EDzw==
X-Received: by 2002:a17:902:f301:: with SMTP id gb1mr126844849plb.292.1564712425718;
        Thu, 01 Aug 2019 19:20:25 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u9sm38179744pgc.5.2019.08.01.19.20.24
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 19:20:25 -0700 (PDT)
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
Subject: [PATCH 09/34] media/v4l2-core/mm: convert put_page() to put_user_page*()
Date: Thu,  1 Aug 2019 19:19:40 -0700
Message-Id: <20190802022005.5117-10-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190802022005.5117-1-jhubbard@nvidia.com>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
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

