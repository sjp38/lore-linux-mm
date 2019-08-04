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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E17AC19759
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:49:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 288632089F
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:49:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="dlbSsRNX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 288632089F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D9A4E6B026B; Sun,  4 Aug 2019 18:49:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D4D686B026C; Sun,  4 Aug 2019 18:49:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA0586B026E; Sun,  4 Aug 2019 18:49:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 775466B026B
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 18:49:41 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id i26so52125495pfo.22
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 15:49:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=60C6UutqWDg70MnmR2wOYRHcozVv05mGJual4EWfkd0=;
        b=qy/Z3s/wvr313K7hQQnITUlviVoHtfWqwA2r+3D97NTRLj2jWg6c/lBer5wjBU37gh
         9PgbcFClVb68CZzPirq+bVFecCk4UTpzStAxoKUHqVTGTR97yJCBJWmMKBrTZViFCDac
         EDd6OcMC67TY61b/1VlAprloervYliyLeAPBOzWvZLnnV8kxWzI2J4x1za5L6BJBHAl7
         F0jokaVZi4cSHGwvURVN0yw4McR2r5hUDjFoG2y54+ZUVELxMAJU8N19rroLSPJM8h6J
         +WvM6GAPFsAXr6fEPx7cJfBtNtoETS2qKm8W98sJgl2YAyQEgOHpY8vyIBHiQDH3BR48
         cdbw==
X-Gm-Message-State: APjAAAWsy30tiwEEhas22RPJMDI9CRVX1qEumdAuPtrmB2PWRnlHMmHT
	vuXGsBtJMijNStkiYv82mnIiBFkvvm7TJi12VuIgWo/eB+PI5OtHAlwvokmx9CFCbIIRtnR4gu7
	Yo1WOpWcH/h95sMV6i2U/uHGm0VSbiZhFR0B9nTOemdOSE4Kv9T1bamyBxxL7l/bCnA==
X-Received: by 2002:a17:90a:c68c:: with SMTP id n12mr15493138pjt.29.1564958981119;
        Sun, 04 Aug 2019 15:49:41 -0700 (PDT)
X-Received: by 2002:a17:90a:c68c:: with SMTP id n12mr15493102pjt.29.1564958980127;
        Sun, 04 Aug 2019 15:49:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564958980; cv=none;
        d=google.com; s=arc-20160816;
        b=qxJv4V2G+3HUYMGZ++mzBMF5SvanLRxzT1vcJT2eEC8Rbdv8Be+8ixmHhFt5d27fnC
         4OKys6HLEEd39KvIX5zCcW9JZtVRhF97+FrrUQGyHlhl7VwwulxuPnsKJ4OA71pjV9o2
         4VA8tWFt2KelaZfR+uCXXjMDBbHjKtrFZyOrmXGaYFlsNyhpHAebZInEO4Ix3FLGbEuu
         4u1n9+bzXFMfrlv2gu0yKuzUK8xOOHKv+1+4jy0bjdi/v5i2pHrJ2t6e6zi0YJlOYXBP
         8W4QTCyewM/Z57LPQ7WkQQn4sjtgsDzXvQ7uSK9iKFlazTN9DKsNehusu9f5+YhIrb7m
         Jnjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=60C6UutqWDg70MnmR2wOYRHcozVv05mGJual4EWfkd0=;
        b=ajVWZ/e4ErcGDkbaHORkcJ3b5koAMOimEqBfLSCor/P8g1sAMpsV2QKczxhjACm0EH
         fErFYBjiVHBwaGsGcOINy1T3UlQ1yh8L96RkJWR7ujFlACG7zZVWi5Y6jAyno+NvGlGJ
         YDhwB8sIwFLgPonx8xMwwvGmvBG7WfFvcJYHQnRu1q4V1MwRDOfy4/gv8olExfuTGkMi
         lXXE2cL5bZgu4TCB27vBDq5Nn55AUasWyxgLwYX0D2jv+UI7gRP1WL+IjZi5jyAPaPBx
         DMV9ilY/AIn+c2xLt3klWIIbQy8/oLNFW7U6XC/nVKrJ46pGKnCPN91EEkY7mgnB7xIF
         hLOA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=dlbSsRNX;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v138sor62614616pfc.40.2019.08.04.15.49.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 15:49:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=dlbSsRNX;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=60C6UutqWDg70MnmR2wOYRHcozVv05mGJual4EWfkd0=;
        b=dlbSsRNX77Ei4qlHR7ScPLtFWbFA/wSFhYs9NQOll92MElLIHH0XM5uWEMJZOCpSZn
         fw6jxIpOESniygQ2CP+jqWxww/Yc9BpBnk334qu29zs2vzmgy87c6XuHVe23RKpRZPxO
         jThG9GtjK3Wnrebfh/rbMsq7112krYjWlIxKkWaUHxL2oFoS1RUMIQu8ytggftTKUFm3
         IZx5EXAb50Ed18W0N5uy/HOdcsYR51BeefJ+gL6tmEuCp3+fjY6YxhqUW4uaaLKgEtr0
         EwxJMkmMabXGRdUgV0PB/zPRqhRIlzaqolidM2g4cvymDIwFa+iZFzPQhAPl2KRAIsyu
         jBAw==
X-Google-Smtp-Source: APXvYqxgxAYQpO8e4Spo4W3ynw/PKZNsgndpQrQdEvTtqBpVU8mbg8ThNNd4XLW1NQVXChaVjFCWhA==
X-Received: by 2002:a05:6a00:4c:: with SMTP id i12mr70639006pfk.134.1564958979908;
        Sun, 04 Aug 2019 15:49:39 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id r6sm35946836pjb.22.2019.08.04.15.49.38
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 15:49:39 -0700 (PDT)
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
	Matt Porter <mporter@kernel.crashing.org>,
	Alexandre Bounine <alex.bou9@gmail.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Logan Gunthorpe <logang@deltatee.com>,
	Christophe JAILLET <christophe.jaillet@wanadoo.fr>,
	Ioan Nicu <ioan.nicu.ext@nokia.com>,
	Kees Cook <keescook@chromium.org>,
	Tvrtko Ursulin <tvrtko.ursulin@intel.com>
Subject: [PATCH v2 13/34] rapidio: convert put_page() to put_user_page*()
Date: Sun,  4 Aug 2019 15:48:54 -0700
Message-Id: <20190804224915.28669-14-jhubbard@nvidia.com>
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

Cc: Matt Porter <mporter@kernel.crashing.org>
Cc: Alexandre Bounine <alex.bou9@gmail.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Cc: Ioan Nicu <ioan.nicu.ext@nokia.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Tvrtko Ursulin <tvrtko.ursulin@intel.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/rapidio/devices/rio_mport_cdev.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/rapidio/devices/rio_mport_cdev.c b/drivers/rapidio/devices/rio_mport_cdev.c
index 8155f59ece38..0e8ea0e5a89e 100644
--- a/drivers/rapidio/devices/rio_mport_cdev.c
+++ b/drivers/rapidio/devices/rio_mport_cdev.c
@@ -572,14 +572,12 @@ static void dma_req_free(struct kref *ref)
 	struct mport_dma_req *req = container_of(ref, struct mport_dma_req,
 			refcount);
 	struct mport_cdev_priv *priv = req->priv;
-	unsigned int i;
 
 	dma_unmap_sg(req->dmach->device->dev,
 		     req->sgt.sgl, req->sgt.nents, req->dir);
 	sg_free_table(&req->sgt);
 	if (req->page_list) {
-		for (i = 0; i < req->nr_pages; i++)
-			put_page(req->page_list[i]);
+		put_user_pages(req->page_list, req->nr_pages);
 		kfree(req->page_list);
 	}
 
@@ -815,7 +813,7 @@ rio_dma_transfer(struct file *filp, u32 transfer_mode,
 	struct mport_dma_req *req;
 	struct mport_dev *md = priv->md;
 	struct dma_chan *chan;
-	int i, ret;
+	int ret;
 	int nents;
 
 	if (xfer->length == 0)
@@ -946,8 +944,7 @@ rio_dma_transfer(struct file *filp, u32 transfer_mode,
 
 err_pg:
 	if (!req->page_list) {
-		for (i = 0; i < nr_pages; i++)
-			put_page(page_list[i]);
+		put_user_pages(page_list, nr_pages);
 		kfree(page_list);
 	}
 err_req:
-- 
2.22.0

