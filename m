Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D48DC32753
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 23:47:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CFB49206A3
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 23:47:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BGeE6sBP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CFB49206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 77EFD6B0006; Thu,  1 Aug 2019 19:47:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 646AB6B0003; Thu,  1 Aug 2019 19:47:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2BC386B000E; Thu,  1 Aug 2019 19:47:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id E85C06B0006
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 19:47:45 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id e33so4169436pgm.20
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 16:47:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=SsIRGkPWeq5HvTZzTxF/TGZYHjIKFiRIBMhKcsnvtic=;
        b=lqNEu4H9Ju0Hh8+PjD58DHGyqsPuRiGpOFKATr/Hob1oE1T19qxSsStPndQoDdjZkA
         XfKUmfAUbRNmylkv/SeB76JrW/b32WU7YHUtDv63HDC5uY8Pt4Vjy+j4RIFM6n3pAlYc
         tT2DoY/Wp6+Z9tRvxcy1MTeGy3m5MVdhZ7GZizx5zOOgmy8tskD0TJq1bYspBZtMYjKe
         E4g1CF2tfkly3UIvwkRMNKEmXKkrO/Tv5S70XeZKqN0arNAS/4s/bu1NRKIJ4ZBRiOur
         ZUG9DhXELm/uXEgRhjFOV1w6GgECi5mqprh5RVatad9slJvBd8GnPyojp395YxMoF8Gf
         s6VQ==
X-Gm-Message-State: APjAAAVTdaXGmRK0h48sMn0oHUhZgxMSGI8WA+HAq4FQnz7EBJiyL6xK
	5UZ/XHv3m8MGG86OVfSvvxUWobR3lXUYqTIIJa926APvPwYxM8bbaS8UK4t0eFi+EUYuCjSH4eE
	bcutVQtyVTB7ePLY/MGy/onOAvsLC7f/GXlAUjsI7x2XhD/FFEAclCdwy6t6jBh5H0g==
X-Received: by 2002:a63:6f81:: with SMTP id k123mr123863313pgc.12.1564703265464;
        Thu, 01 Aug 2019 16:47:45 -0700 (PDT)
X-Received: by 2002:a63:6f81:: with SMTP id k123mr123863191pgc.12.1564703262936;
        Thu, 01 Aug 2019 16:47:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564703262; cv=none;
        d=google.com; s=arc-20160816;
        b=EAX/VrhV5Ej9aCDFDEpgLHypH3t27Da8K6LNVIxQwiCS7MJ0gVnDf1KFBVDw4OwsBJ
         mFLNtNbzb5bWzYlbI4B8Gc9/ZOz5Edy+sw/G/4lSq2VeIdXTtZNXYONq8C9cEZptdS5v
         AQ304seNvlK6qIWcg8f4oBuhmOHF/R9lgCFvkhpgcYoLFy6a9TW//3TT8depyRG4d28f
         OTib7ocE7qgB0fK3lq8gw/AmV5pt2Z0Le+Ps/K9qAWtdBhIpbgJfjzcG27cj1Mqxo4eU
         H8CUOnoQGCC5ThEGSnDPTjaDzR2qcEqEztKPwvUfOS0ea6Kucghx4b2FfOPDZ2uD2e82
         0Dlg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=SsIRGkPWeq5HvTZzTxF/TGZYHjIKFiRIBMhKcsnvtic=;
        b=idBOwVtKUuT7kwKXUZQTRkX20tp1hGUEWG9zIVHEFLHXRsBZDzmGE3batM5D/wU6sb
         VrOm5XBjy+TOR3+s+dPNpeOvm/Q69DEBH1rqFz8w58yIFrjcYH0mZJLqyWeqiNwR+tSW
         tfeQdLSapCfN7IeSgDygOnT6F8A2vVbd23NWJInuqNi2FhUWUMOQn+JLHw4bbq4Ix1Qq
         2L0BWJ1sYrlm+hrd4/0ZyH3XzFye3qpj6gTN+FEscadTb43r8PIHJ8+0s43n0wTPPlzH
         FDKpG4UJI2T9Zg4K8a23rFhdQ6i4ZhwQaTQYk+Cai7TUD3XtlZNUj71CwCK+NXmVR+IQ
         w6CA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BGeE6sBP;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h6sor23331876pfe.41.2019.08.01.16.47.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 16:47:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BGeE6sBP;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=SsIRGkPWeq5HvTZzTxF/TGZYHjIKFiRIBMhKcsnvtic=;
        b=BGeE6sBPyOFa3wBesZ//yTnmIYiW2qdWshkClQ7aPWJjL7akX61KxZpR3Bc5xMlShv
         hSn2MfOI/RkCSfFPfN1GHpHW0mpAeEndeA1Bkn/hiOqupu2eVuK/0+WqRsoNrkoiam1u
         mAtMgD/4OhHWCVjWeannJUrXJT5cdnwC8V126zhAy+M9nCbcd2/YN0KObjLuWC1rZPXx
         0AL6HjVWassUOkoH+wgHm7bpYMsDJhceK5sYbcW/PCa0rFZh5o/+tIRNg9imoY9BXY1x
         WJfFtHbODuo2mf66BZtQp/j03TkrW+CfXNYDl9m8qoTc8N6pWgt7ajKCVU594c51EagE
         tvJQ==
X-Google-Smtp-Source: APXvYqxH8u29ZdpcjWLJrwgbMbyVAF40I2QUvMD98RL8LJpcLxolKyu7rs5+6caIWdcRdmo9vFlEcg==
X-Received: by 2002:aa7:82da:: with SMTP id f26mr56649423pfn.82.1564703262707;
        Thu, 01 Aug 2019 16:47:42 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id q7sm79090792pff.2.2019.08.01.16.47.41
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 16:47:42 -0700 (PDT)
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
Subject: [PATCH v5 2/3] drivers/gpu/drm/via: convert put_page() to put_user_page*()
Date: Thu,  1 Aug 2019 16:47:34 -0700
Message-Id: <20190801234735.2149-3-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190801234735.2149-1-jhubbard@nvidia.com>
References: <20190801234735.2149-1-jhubbard@nvidia.com>
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

