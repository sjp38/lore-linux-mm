Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E603C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:20:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC3032087E
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:20:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mO2EsXIn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC3032087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CAB846B0269; Thu,  1 Aug 2019 22:20:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C62B86B026A; Thu,  1 Aug 2019 22:20:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A8C746B026B; Thu,  1 Aug 2019 22:20:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6DA326B0269
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 22:20:25 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id m19so31964606pgv.7
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 19:20:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=qLhYs8BKsJD26dkkDQW7qDqDKRQ6ceEysj+E+zVe/Zg=;
        b=PRVbx2E1JV4vDP5vnBSCHXLkw1ErnQHtiFb+nj7FqMLvG9orYkCVSg6dZNbQqC1c8J
         dth9rjkNIPtTYMurKTVLqxMvtZe9I50VZRxdGcBCIR+SYk3oUwnLXK2BD+hOmGZyC/Yh
         apOD3mnDYb0ZLsE4MAHTSaLOVCB4dRPoG4xlah07jlUyFPLFqRyOGPdvOMOZNGKv30bH
         6+85CsEuHJaHCJfLLIl7XCE6B7B/R1K4nccPsyMTKmu7c6oeZ9Ttd0U5Otv6IfRW/Jk+
         DBzDOlFVQ4oo71ZDSEonl58y1hELEN3uGHkAsSTzqkXsmCGc0jyzH+YpRLezdRQYYCaa
         f4bw==
X-Gm-Message-State: APjAAAVecmAZ4PmuHoOAc6iPp7vZ8ItGgo4HEJWOzAAUxYpppSdGG9pz
	tPpUhAHC1wh6ocWbVKoetKWRetmtq1zEI3OOToMQNlcTl4FoRDJ526JzAK+CTcZdqS9Ze22iXxI
	JjP0ZJeUEL44ZnflJ6CSH5n8GahqVmLVUpsLv496BuXp9oDRzZ3EUjRw62o+ZaNQc5A==
X-Received: by 2002:a17:90a:8d09:: with SMTP id c9mr1873755pjo.131.1564712425105;
        Thu, 01 Aug 2019 19:20:25 -0700 (PDT)
X-Received: by 2002:a17:90a:8d09:: with SMTP id c9mr1873722pjo.131.1564712424447;
        Thu, 01 Aug 2019 19:20:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564712424; cv=none;
        d=google.com; s=arc-20160816;
        b=i8WnqB/qKVxcQpU+AUfqPyqeHwJej/qd29fFH9PY5XOhJsB+0269kjU9YRMVoWouXW
         ChxlwWb3dn7s3ikjaOS3qu5qF1xz2gQeljt0DJfkNEYEhhkUabTSYTiMPyca53oq+X3k
         0UbhevXIF2VAF/u2ejVk/QvmdLH2qslruai9Mywi19z0qaBPX7Z82LXgxgqFmTw4cmt4
         pO35AZBAFvlFB765MJUw4+TwEYkg410ST/aYns1kcJsu5JeltBYeK5GEbRY6S0ff+oLp
         uhrW02QvajYPWohlmju/8IdE4qASOVHLb5N6iuwoepRBqcqnJNHYK9OSbDMuJqIv6POR
         QP2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=qLhYs8BKsJD26dkkDQW7qDqDKRQ6ceEysj+E+zVe/Zg=;
        b=Amj6ci2Jas9yOtVQixghO/IBqsvW5MdsEOhnq1WvzfxlMysGrSu3+x5h5eenDN69HD
         tkD/vBBSfnU5XXRicB9eciIqxEM1BUB1P69HCmMqrVl8Xp9EIeyVIq/C0nGKtaEIrmxZ
         4DqnhvV2WoGgj4FNBqMztZKvD+GsQJ61jwERSmIH5FdXO4Xmf7lzFokL1EQu8UM7NHnF
         f9/+G9MSHiXyhBf/PdEO9LVHyJO6FtmnHqrK8Z4mdYfQV5AW3ufwPVCBevcqq4aGhcT9
         WdSy7K/xeX9a4emNlX4grwOiaRbWv+H6b90xGB9Be11fekFX35plgHE47e5UPbWlJAO2
         y+eg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mO2EsXIn;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a38sor88091962pla.0.2019.08.01.19.20.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 19:20:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mO2EsXIn;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=qLhYs8BKsJD26dkkDQW7qDqDKRQ6ceEysj+E+zVe/Zg=;
        b=mO2EsXInu3VlKA104JEnfgx6jDjnSEwvGouzsXnnB6AUhB4nvA/xUkFDDFSnp0kAVb
         uzJcZIfv98AAj+k04bO7VhQK6uHpuI27M0R+JJmNHqmsuBRinpXiyXzVO3vG2KOnwG10
         9wLLSCL2f4bGbhp3gn22p2RGwRVC/ywoZ78m+PYeQh5xx0q2EjBUJcL8fGu/7GpGYNTC
         uoBxihJiCgimiOEov856ivIQlm2ZtbCKKeyCad06O9lOqE5uy2qRmSTr2cNmPxvRt3hH
         pW5v3ngGfAjNbaRjAeL1vDJ+MdUfb90y74Jjb2kpsnBznTRKzfySI1iA5+bGvCblKYHE
         C88Q==
X-Google-Smtp-Source: APXvYqzyCRty8QPAc9XoTrRagrp/y/95vNaIlWT3LNdx/ZaWWXrbiDzYki+gcyf8LhQXoed6UV6NgQ==
X-Received: by 2002:a17:902:6b0c:: with SMTP id o12mr26388046plk.113.1564712424200;
        Thu, 01 Aug 2019 19:20:24 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u9sm38179744pgc.5.2019.08.01.19.20.22
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 19:20:23 -0700 (PDT)
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
Subject: [PATCH 08/34] media/ivtv: convert put_page() to put_user_page*()
Date: Thu,  1 Aug 2019 19:19:39 -0700
Message-Id: <20190802022005.5117-9-jhubbard@nvidia.com>
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

Cc: Andy Walls <awalls@md.metrocast.net>
Cc: Mauro Carvalho Chehab <mchehab@kernel.org>
Cc: linux-media@vger.kernel.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/media/pci/ivtv/ivtv-udma.c | 14 ++++----------
 drivers/media/pci/ivtv/ivtv-yuv.c  | 10 +++-------
 2 files changed, 7 insertions(+), 17 deletions(-)

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
index cd2fe2d444c0..9465a7d450b6 100644
--- a/drivers/media/pci/ivtv/ivtv-yuv.c
+++ b/drivers/media/pci/ivtv/ivtv-yuv.c
@@ -81,8 +81,7 @@ static int ivtv_yuv_prep_user_dma(struct ivtv *itv, struct ivtv_user_dma *dma,
 				 uv_pages, uv_dma.page_count);
 
 			if (uv_pages >= 0) {
-				for (i = 0; i < uv_pages; i++)
-					put_page(dma->map[y_pages + i]);
+				put_user_pages(&dma->map[y_pages], uv_pages);
 				rc = -EFAULT;
 			} else {
 				rc = uv_pages;
@@ -93,8 +92,7 @@ static int ivtv_yuv_prep_user_dma(struct ivtv *itv, struct ivtv_user_dma *dma,
 				 y_pages, y_dma.page_count);
 		}
 		if (y_pages >= 0) {
-			for (i = 0; i < y_pages; i++)
-				put_page(dma->map[i]);
+			put_user_pages(dma->map, y_pages);
 			/*
 			 * Inherit the -EFAULT from rc's
 			 * initialization, but allow it to be
@@ -112,9 +110,7 @@ static int ivtv_yuv_prep_user_dma(struct ivtv *itv, struct ivtv_user_dma *dma,
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

