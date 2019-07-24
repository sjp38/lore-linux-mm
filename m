Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF2CCC41517
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 04:45:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 89849218D4
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 04:45:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iRuMVn01"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 89849218D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 841C26B0008; Wed, 24 Jul 2019 00:45:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F4B46B000A; Wed, 24 Jul 2019 00:45:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 644788E0003; Wed, 24 Jul 2019 00:45:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3140F6B0008
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 00:45:47 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id x10so27718955pfa.23
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 21:45:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=SsIRGkPWeq5HvTZzTxF/TGZYHjIKFiRIBMhKcsnvtic=;
        b=Sdy+v/tbaTvxFLSlcA0jGi/M+fqnM4mU0NlpFN8w/5GsPpRSMgVPQTZAzFWsLqk+d1
         aOwYJ879GFDcvFK8Isorw2A8BA7ag0qGvo8ZhQYEWPOciDld2NO0MFzsXud1mAwecjLU
         n/Fp4ZUvsclMs2kbxcvMxOlQL1ziTWF/xiumSWu4AecQozML8507v3mmDR4T99D7i/IY
         Q9B20cxc5/vEmOcaGaAj//T9xpo4ObmssGxyTYVMN1BQhxzzS5WanfuzXufo5P1cYIzd
         vM3VVWDYigtJ/59Na/3QGcd+RDLyp5GPlEXtQGuJ6JMPOTbV3Ejk9FPOVB5r+SYk1QvO
         CsHg==
X-Gm-Message-State: APjAAAXHPI80D8+yPjMoZ+pyREsBd0fxNLAoeubKMlzXfqWb3+sJwnGm
	yyXpmm1vevx5i+mNgczQxXKRb7W/6dYIOuBiDQ9cxsU+mP5Kaee+VlgpFKkpE0g25ud3LMoiFhd
	zEso1D1xLWTkBc0SEnkQcXkTxoyAJY6pZDOTdVSVC9K0zTanloDGKIG5zlft+bS7tCw==
X-Received: by 2002:a17:90a:ad41:: with SMTP id w1mr84676412pjv.52.1563943546893;
        Tue, 23 Jul 2019 21:45:46 -0700 (PDT)
X-Received: by 2002:a17:90a:ad41:: with SMTP id w1mr84676382pjv.52.1563943546218;
        Tue, 23 Jul 2019 21:45:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563943546; cv=none;
        d=google.com; s=arc-20160816;
        b=T0KACVPU/ZlQwIWTj9PisqWdJLGPz5zr8XdkR50rstf8jbZUOpcI67KZDh1FVS0kmS
         YZyyLxfIehY9lw+HSptTIRIgZeGOgHVG+dJGHlIAP40nXOFc1881vL+tw02YjivGT6PS
         sITgxs6T9pVQt2keA+NJ+sZFmkoZWdDFHKSOkJOPVLCzzGM8qYnfdfZmanlgePA90yKr
         Qcaa1EhUjHsVWeLqthpqOcaOkRaUYSq98t5Yk99WPEwBXjbygM8P/WwlftCQbN9Zb9OO
         a0cKRCK4FgFnIoqZDIE7z58YUZG9gsJFZL41NPhwsyiHfpXwefU2WDl/i3vedkEQKk4A
         y6FQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=SsIRGkPWeq5HvTZzTxF/TGZYHjIKFiRIBMhKcsnvtic=;
        b=vPUTY73Quw/tIFrijYX5N1XTqz/ZX8Tc4um1Y3CfU7/eGTgY2nE5O39Vi9NeWnLwOb
         AYfLmMVPGrLAcKUm1fUXhMw+E+JpyWCk5tRCAtb2CMUV+w3uv2X1EZ4hPWPo5Iw1duEs
         yoFAbWDBBcpw/9/0PQiYP6eBove5WiSruJuHTu9dMLwYlgZzn2ul/e+e+emu8Hb7C2JJ
         l8E7c3Zxab8tCGhlmaB0DXfV6JAQBxnxtztg2vDF4/Dumn7/gPQvOKORAj7z4lrwD/S8
         fHXJmr9xnvbVJZBgBBh8vowtaPigXeg7SSjN2xZshcrWwhpQBoSho/Cmq36Yxoe2GHqb
         xEgg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iRuMVn01;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b84sor26293626pfb.57.2019.07.23.21.45.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 21:45:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iRuMVn01;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=SsIRGkPWeq5HvTZzTxF/TGZYHjIKFiRIBMhKcsnvtic=;
        b=iRuMVn01zHeK0yiOSRK2Lr1EU7pc8CsdgSBtKjcFrXOm/+FFRVzrNNlrixeGJOHP8V
         iKetHK+5t9Ej+nI5uVMv4FAA+ES3uEQlIJ2baYiULutC43IaDSEvIuAPlCl0SkvBEe7z
         p5DawuDWDYqB6EvMkUh0m7OdFNUodM0kZKUBCZKxr8EDIZSemDwaSeWX7wTt5H/lcaHI
         UerhtDXokM+OXWJf65SFEnmVvk8moZsIkX+U07z7UpCTHRZuu0Trgg8Cc6r1Ng5el3Ex
         iN2WNf1PERhrfsMSIWn3T6NItLlHWkEtcgeAh3eh21j0v8PcRI9akyjAnn4iE7QkI1/G
         BN0w==
X-Google-Smtp-Source: APXvYqxwR8jHApJyEKZyasPi8IFXLYmSKaODUc/eHgbbUMsE1K6Stn97aM6QVrRMJVmUoANrLpXphg==
X-Received: by 2002:aa7:8804:: with SMTP id c4mr9226277pfo.65.1563943546014;
        Tue, 23 Jul 2019 21:45:46 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id b30sm65685861pfr.117.2019.07.23.21.45.44
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 21:45:45 -0700 (PDT)
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
Subject: [PATCH v3 2/3] drivers/gpu/drm/via: convert put_page() to put_user_page*()
Date: Tue, 23 Jul 2019 21:45:36 -0700
Message-Id: <20190724044537.10458-3-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190724044537.10458-1-jhubbard@nvidia.com>
References: <20190724044537.10458-1-jhubbard@nvidia.com>
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

Also reverse the order of a comparison, in order to placate
checkpatch.pl.

Cc: David Airlie <airlied@linux.ie>
Cc: Daniel Vetter <daniel@ffwll.ch>
Cc: dri-devel@lists.freedesktop.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/gpu/drm/via/via_dmablit.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/gpu/drm/via/via_dmablit.c b/drivers/gpu/drm/via/via_dmablit.c
index 062067438f1d..b5b5bf0ba65e 100644
--- a/drivers/gpu/drm/via/via_dmablit.c
+++ b/drivers/gpu/drm/via/via_dmablit.c
@@ -171,7 +171,6 @@ via_map_blit_for_device(struct pci_dev *pdev,
 static void
 via_free_sg_info(struct pci_dev *pdev, drm_via_sg_info_t *vsg)
 {
-	struct page *page;
 	int i;
 
 	switch (vsg->state) {
@@ -186,13 +185,8 @@ via_free_sg_info(struct pci_dev *pdev, drm_via_sg_info_t *vsg)
 		kfree(vsg->desc_pages);
 		/* fall through */
 	case dr_via_pages_locked:
-		for (i = 0; i < vsg->num_pages; ++i) {
-			if (NULL != (page = vsg->pages[i])) {
-				if (!PageReserved(page) && (DMA_FROM_DEVICE == vsg->direction))
-					SetPageDirty(page);
-				put_page(page);
-			}
-		}
+		put_user_pages_dirty_lock(vsg->pages, vsg->num_pages,
+					  (vsg->direction == DMA_FROM_DEVICE));
 		/* fall through */
 	case dr_via_pages_alloc:
 		vfree(vsg->pages);
-- 
2.22.0

