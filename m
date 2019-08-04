Return-Path: <SRS0=DZuJ=WA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D288C433FF
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:49:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5069B2089F
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:49:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SmLYPFHm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5069B2089F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 473C36B0010; Sun,  4 Aug 2019 18:49:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 424B66B0266; Sun,  4 Aug 2019 18:49:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 13F946B0269; Sun,  4 Aug 2019 18:49:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id D042A6B0010
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 18:49:34 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id k20so51397563pgg.15
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 15:49:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=5vxuyadJL7U7uLaLdbmi0wM48++CcjfxvCZKqh2vh4A=;
        b=YuoCUNnZTFr3/PdfI9AtpUEkRjnrCnQHlvgGT3Sg1wrIqtx8vHwHirPfr8BCys2pSV
         b16iGoVhcrzurrD5hBFG5XT2cXPI2UopDtCxe19PID6D+Dlp3Yx8KK2HCa6soI2rKZhS
         Rc9KzVBEv4gUusr2kig/3aFWuKDT9sV5W4NcwLB3XzazpoJOC+2w2BXQDkA/G1RiwDVV
         W2HRlMVjc41/QauQl6JifxTQ1UbSjHLMsgiP8q3PcMcfHzmQKn4wmimcDdMKIZ54LiJG
         zYyUv1OVNEa6N5dEVhSWPulNhf5e27ZhOcKzTLKtyQkpT2vUeJuzxu9kG85l6Q3hLM0L
         GaIg==
X-Gm-Message-State: APjAAAXAmk3F42/lQ0Z/XLoX08F+fFriA0ccCNMHyYrrFl+cLSey9rYI
	fOXuTGAd0wb1EZ2BgcgEJde40f7Qg+/NsCcLhWeLimcVhCmoovyukN+CKSXqWFmmt+srZyiW9fg
	eKnRYB6yq1hEM0HOddnwoiPax09L7+A+8vj0U7shXpDaqpMOXWQGmeDbbyoIFrEL+mw==
X-Received: by 2002:a62:1883:: with SMTP id 125mr70079535pfy.178.1564958974548;
        Sun, 04 Aug 2019 15:49:34 -0700 (PDT)
X-Received: by 2002:a62:1883:: with SMTP id 125mr70079512pfy.178.1564958973671;
        Sun, 04 Aug 2019 15:49:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564958973; cv=none;
        d=google.com; s=arc-20160816;
        b=xlSq75hFC726sPUOg+sBBBkrKAf/3AdS0L4md3zmeBCHRyFEVd9dlizkmx35dEJoE4
         kffzo9WuV0tZgsjE0/22pUFu2wgFpsJD9U+xYaLdjBAR0OjhufbAb0MTNKEyAJWGMXUh
         zIy9CQLLfJF2Lf71f7fj7utIFSe2RckEuZnnRxBzv7L8ZcTd8IAsEw6wbgBajc7P/ajG
         MQwZpQ1KXyVEbZtE/KbycFKp6AEKKnqy+hHcgQ8cNg3eiEl0Ogi22YQxO6LJhoavC80u
         yANtpVR6vmhcbMQWGnLfq4yWwi55Oi3J6avkDoQMxdpz+a9DDiP3E0Ijvld1B03Tkshv
         iRYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=5vxuyadJL7U7uLaLdbmi0wM48++CcjfxvCZKqh2vh4A=;
        b=lETFCUPqQixT1LJPJLO0rinuD3ErYk69bpyb9RqnW62IKdDSC5NASLohI8kpkrX2Zn
         mPtby0ABuuhYFmm1/QZ4yLE+dAnCqN4NV9123wTv8IA0PXGlgfMnb6MJXr8Gwo2+dYJY
         t3pzYbJ+U4rYBMmhpsENlZaZsiGlmbqawspA4GHoqf9NWRzqUJnFzVBcfM/rhy962xZg
         2l1JuFCr2JLMG/Eq5d2+xOu5EBKZ0hsFzXjB9bX9DZPcuv1DJawJU0vCgcKNsoEVglOL
         M+lJQvBVw3tqpAtWpsRkIJwiHTAvha6apuTUkVmvbfL1jjvVQxkTKpYNlcaOzuS9Bkzs
         Nkow==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=SmLYPFHm;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 125sor37422609pgi.63.2019.08.04.15.49.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 15:49:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=SmLYPFHm;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=5vxuyadJL7U7uLaLdbmi0wM48++CcjfxvCZKqh2vh4A=;
        b=SmLYPFHmKN1uE643ZHBnB9dNk1rkYQS38le9bhNsjkuijth7hTQM++IPMv3pLW0TEI
         7/x46VCEIatXmkV3w2KshE0imX/kUzrth+ucng6DZOKNE0opT13YpOAAUVZVUjGyDlRy
         PB2Ml2hj6K3sDNS5iK8QIe0u19usMs5R4F7ygDzoCAKAQPcQlfC/e9zMHKVg/PGP6KNH
         jH8S8rBi9/AhB/tXE8C3wWfrNrkZfmcdnxjHGl0d8mZOAczH5is/McK+cj5KFruHwe2c
         MlwNgBe4BfI2d4CuM85b0u6u4v6w/IVsnWdV3/DEzbLrJ3+c49m+Mf//mO5waQdOc/o0
         4mBA==
X-Google-Smtp-Source: APXvYqx8ZWVr6MlzhqOcGh2E3H/RsN7D9i6b3t0CUjOfGBvpDNUsLBn0LfDPCNpJqri3cJedM4xZQw==
X-Received: by 2002:a63:1b56:: with SMTP id b22mr16835931pgm.265.1564958973404;
        Sun, 04 Aug 2019 15:49:33 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id r6sm35946836pjb.22.2019.08.04.15.49.31
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 15:49:32 -0700 (PDT)
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
Subject: [PATCH v2 09/34] media/v4l2-core/mm: convert put_page() to put_user_page*()
Date: Sun,  4 Aug 2019 15:48:50 -0700
Message-Id: <20190804224915.28669-10-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190804224915.28669-1-jhubbard@nvidia.com>
References: <20190804224915.28669-1-jhubbard@nvidia.com>
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

