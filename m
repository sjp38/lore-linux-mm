Return-Path: <SRS0=DZuJ=WA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 533F3C19759
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:49:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0BD062086D
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:49:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QsDIsK9f"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0BD062086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E89696B000E; Sun,  4 Aug 2019 18:49:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D2E666B0010; Sun,  4 Aug 2019 18:49:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B77196B0266; Sun,  4 Aug 2019 18:49:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7F90C6B000E
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 18:49:33 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id o6so45038720plk.23
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 15:49:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=51+On65LrNSvXr2lp5EjmvkWwZiof+VzaE7I05DxrV4=;
        b=Q2Bq4ZssYh9/hBrEPsvLNyzRGKezQLq5u/OckaFh9xEfoR19HnkupKs7loP6Ogok75
         MX4yCyRYHmwfPOw/UMm4AKfRye6uKmwSCi/MKA1jXDSK9P4+gCOrn9WbrntDo6FJ71bC
         xbfgvfzpwIt6VpVftzjYPoKUyAhy4X1We4UfRvvkV6788TaW/IQf2pW34VqyVt6YSbDF
         oFSqMYA7Jbx5XQfKI9sNUkSEfyfWtIQ72MXJzhEWg8t7f+tbgtTXFwWiDTesrZan+o0Z
         W2AdJp6rVC/kx3GXj2WhFly8I8B/dv/kEoZ1oWqoSqG+0gJBa0XYheb+TelNxdZX+cbq
         RO1g==
X-Gm-Message-State: APjAAAUyvpFEeDinU3s31Gs9VUQLCkh7pkbmB9d0qsu4A74iQLLOZ9bz
	B6iSysvqiwE9E3Qd4GDuI5Z5qZOswOFUemAhlopOH0w4Jbr/zltlMK2uNmn7rN5I5iM7hQm6f3z
	ejcYX5k5V4TkoSxaazCs+S6QoYG+LUU4Y/a3NgCY8yvu9rUNVEWyRICPXd8BbMpazKQ==
X-Received: by 2002:a17:902:830c:: with SMTP id bd12mr144461318plb.237.1564958973212;
        Sun, 04 Aug 2019 15:49:33 -0700 (PDT)
X-Received: by 2002:a17:902:830c:: with SMTP id bd12mr144461279plb.237.1564958972103;
        Sun, 04 Aug 2019 15:49:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564958972; cv=none;
        d=google.com; s=arc-20160816;
        b=Tk7e5Jch81XEWSYf8swE5Xl4/Y5wzkgwxZ7Kd6kLHzleqLayCJt5/Hf3OJOryiltru
         oilnYifd502lVzi54upNCke5uu0iSQELgvIvxwJxRwRAKVa0hJEMeYFi25NkXpa2L3L1
         a0UqFrvt4Q9Ybugs7SwW2N2PbO1kugnZt7zIuGv/JACgn39EeiaTQ82QkzF9dmHZH1Lu
         XDemHoez9HsPaqzTQ68m2EmEAkuApzHbzbsaE0Cggc8niHXbJrja3h3wFTZ2qiQSe0ce
         iMwziY8pbqx9jbfwi6xdtRe36RzCxmKGnLGgc9xXqYyvZsKCNY2Rb28R/coPVlqcfSY2
         Yv4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=51+On65LrNSvXr2lp5EjmvkWwZiof+VzaE7I05DxrV4=;
        b=fj8G5UsWcS4+rRW3P4BMR1MoempPfR7X80mbegKXpzPSty97vVqWtM2Mh/jYBN8Nfp
         kq6hWjyOhvfzdgvMIoV8dpAFgjEi7o31dXd1x9fHsT/8FmBqNDJAWV0Hw78Zi9XiiXrT
         mrMPW8BW1woSMzCp2S24UXsKnNZa7sKPPq12sUONQCKOgK4M44rHVTJXLkmNS7AI1xY9
         xzcc7g+E+2VHFk8GTEDIhnQbnIpOiIyiV3efQepPu5OLIdEF4X/WFumDEQCdDecP3fui
         CtAuYGcJo6wW7n3xCBzUuwlx1J41orBnDNupjoAB++1mMCOLvUlYAaW+8oXI/3bfZr/+
         MCgw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QsDIsK9f;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a9sor18256071pjw.26.2019.08.04.15.49.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 15:49:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QsDIsK9f;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=51+On65LrNSvXr2lp5EjmvkWwZiof+VzaE7I05DxrV4=;
        b=QsDIsK9f5PFinVSypvUnfmtXaz3kPWnYRiMB+PRzxsxoVwE1/PGQPLzli5akhJljj8
         QOVfD3ESRzP4SmFLgRw8ezjrLknuphEkET2wTeMPtNXVFRvcIEp8+hl2krxX0FhUKmfA
         FRVi5e/1Sd4ss6uRAZ/WTu2/Fdxsq5+uVpAz9kYcpHza4AYNfJ0v5Fv4Qq1jCOLlPy1H
         nf4XWPgdgkGPokpib4Th3GTGYdM/mIIHrXhq16b9yHFMzXKgGdn6k4irDUbg4quFTiHg
         KhiWe4DxW1uTVha/j+uVAZq73ruzBvFGvmOtPz78/ybeCNmcmkWr/Nh3pU4xyYgYNctD
         P1LQ==
X-Google-Smtp-Source: APXvYqwvBDogXJUfkkciG6MhUnx/OJ8ZeMIFfpBlRE5wKf4uSOTmFfk+/5+dEgtOxTw0423kYep5pg==
X-Received: by 2002:a17:90a:384d:: with SMTP id l13mr15518641pjf.86.1564958971827;
        Sun, 04 Aug 2019 15:49:31 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id r6sm35946836pjb.22.2019.08.04.15.49.30
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 15:49:31 -0700 (PDT)
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
	Andy Walls <awalls@md.metrocast.net>,
	Mauro Carvalho Chehab <mchehab@kernel.org>
Subject: [PATCH v2 08/34] media/ivtv: convert put_page() to put_user_page*()
Date: Sun,  4 Aug 2019 15:48:49 -0700
Message-Id: <20190804224915.28669-9-jhubbard@nvidia.com>
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

Cc: Andy Walls <awalls@md.metrocast.net>
Cc: Mauro Carvalho Chehab <mchehab@kernel.org>
Cc: linux-media@vger.kernel.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/media/pci/ivtv/ivtv-udma.c | 14 ++++----------
 drivers/media/pci/ivtv/ivtv-yuv.c  | 11 +++--------
 2 files changed, 7 insertions(+), 18 deletions(-)

diff --git a/drivers/media/pci/ivtv/ivtv-udma.c b/drivers/media/pci/ivtv/ivtv-udma.c
index 5f8883031c9c..7c7f33c2412b 100644
--- a/drivers/media/pci/ivtv/ivtv-udma.c
+++ b/drivers/media/pci/ivtv/ivtv-udma.c
@@ -92,7 +92,7 @@ int ivtv_udma_setup(struct ivtv *itv, unsigned long ivtv_dest_addr,
 {
 	struct ivtv_dma_page_info user_dma;
 	struct ivtv_user_dma *dma = &itv->udma;
-	int i, err;
+	int err;
 
 	IVTV_DEBUG_DMA("ivtv_udma_setup, dst: 0x%08x\n", (unsigned int)ivtv_dest_addr);
 
@@ -119,8 +119,7 @@ int ivtv_udma_setup(struct ivtv *itv, unsigned long ivtv_dest_addr,
 		IVTV_DEBUG_WARN("failed to map user pages, returned %d instead of %d\n",
 			   err, user_dma.page_count);
 		if (err >= 0) {
-			for (i = 0; i < err; i++)
-				put_page(dma->map[i]);
+			put_user_pages(dma->map, err);
 			return -EINVAL;
 		}
 		return err;
@@ -130,9 +129,7 @@ int ivtv_udma_setup(struct ivtv *itv, unsigned long ivtv_dest_addr,
 
 	/* Fill SG List with new values */
 	if (ivtv_udma_fill_sg_list(dma, &user_dma, 0) < 0) {
-		for (i = 0; i < dma->page_count; i++) {
-			put_page(dma->map[i]);
-		}
+		put_user_pages(dma->map, dma->page_count);
 		dma->page_count = 0;
 		return -ENOMEM;
 	}
@@ -153,7 +150,6 @@ int ivtv_udma_setup(struct ivtv *itv, unsigned long ivtv_dest_addr,
 void ivtv_udma_unmap(struct ivtv *itv)
 {
 	struct ivtv_user_dma *dma = &itv->udma;
-	int i;
 
 	IVTV_DEBUG_INFO("ivtv_unmap_user_dma\n");
 
@@ -170,9 +166,7 @@ void ivtv_udma_unmap(struct ivtv *itv)
 	ivtv_udma_sync_for_cpu(itv);
 
 	/* Release User Pages */
-	for (i = 0; i < dma->page_count; i++) {
-		put_page(dma->map[i]);
-	}
+	put_user_pages(dma->map, dma->page_count);
 	dma->page_count = 0;
 }
 
diff --git a/drivers/media/pci/ivtv/ivtv-yuv.c b/drivers/media/pci/ivtv/ivtv-yuv.c
index cd2fe2d444c0..2c61a11d391d 100644
--- a/drivers/media/pci/ivtv/ivtv-yuv.c
+++ b/drivers/media/pci/ivtv/ivtv-yuv.c
@@ -30,7 +30,6 @@ static int ivtv_yuv_prep_user_dma(struct ivtv *itv, struct ivtv_user_dma *dma,
 	struct yuv_playback_info *yi = &itv->yuv_info;
 	u8 frame = yi->draw_frame;
 	struct yuv_frame_info *f = &yi->new_frame_info[frame];
-	int i;
 	int y_pages, uv_pages;
 	unsigned long y_buffer_offset, uv_buffer_offset;
 	int y_decode_height, uv_decode_height, y_size;
@@ -81,8 +80,7 @@ static int ivtv_yuv_prep_user_dma(struct ivtv *itv, struct ivtv_user_dma *dma,
 				 uv_pages, uv_dma.page_count);
 
 			if (uv_pages >= 0) {
-				for (i = 0; i < uv_pages; i++)
-					put_page(dma->map[y_pages + i]);
+				put_user_pages(&dma->map[y_pages], uv_pages);
 				rc = -EFAULT;
 			} else {
 				rc = uv_pages;
@@ -93,8 +91,7 @@ static int ivtv_yuv_prep_user_dma(struct ivtv *itv, struct ivtv_user_dma *dma,
 				 y_pages, y_dma.page_count);
 		}
 		if (y_pages >= 0) {
-			for (i = 0; i < y_pages; i++)
-				put_page(dma->map[i]);
+			put_user_pages(dma->map, y_pages);
 			/*
 			 * Inherit the -EFAULT from rc's
 			 * initialization, but allow it to be
@@ -112,9 +109,7 @@ static int ivtv_yuv_prep_user_dma(struct ivtv *itv, struct ivtv_user_dma *dma,
 	/* Fill & map SG List */
 	if (ivtv_udma_fill_sg_list (dma, &uv_dma, ivtv_udma_fill_sg_list (dma, &y_dma, 0)) < 0) {
 		IVTV_DEBUG_WARN("could not allocate bounce buffers for highmem userspace buffers\n");
-		for (i = 0; i < dma->page_count; i++) {
-			put_page(dma->map[i]);
-		}
+		put_user_pages(dma->map, dma->page_count);
 		dma->page_count = 0;
 		return -ENOMEM;
 	}
-- 
2.22.0

