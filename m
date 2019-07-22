Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F5B8C76194
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 22:34:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3365D21985
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 22:34:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Pcs9/tR3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3365D21985
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A835C6B0007; Mon, 22 Jul 2019 18:34:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C12E6B0008; Mon, 22 Jul 2019 18:34:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 774D78E0001; Mon, 22 Jul 2019 18:34:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 403D76B0007
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 18:34:23 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 191so24766470pfy.20
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 15:34:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=H5rDEOeFRvjrpBGS4dvuQZ6SJfLiKadFXLHgUye++Ig=;
        b=bWPpOKDv/yCiXA+KkZ5RypTOylm4Kx+/gqfAiDJ0eZ5ZJeT4axezw5DTGj0QfbKiBH
         UJ2hgE8yUsJbh9G/RILpntmpDDA6aS4AThp+rmsmO2Y5Wu0dpOu/2uDLnV7l6cXWsm/x
         MMwNDI4CphyyiDNN/3OkDyaLsVT77jxU39pItc4yIk6bGX6MDNNn1CcXr8t+Q9bRFr44
         3LNsmkTj4r87luZ3mHL5+GQ5y7r7LUm+cIjdeES8943Y1BAVfNEiPTA8mOL5R8+YwGr9
         3hVU6DSNvOdrQKoy2OTN8CPVrk85wEcQ2MPPdmGPLGlKu5/K6n4ijQsAKpEXDNg1ucyp
         RBTA==
X-Gm-Message-State: APjAAAV15T4hfolonDmy5W2ra8JR6hOwqU0LqBTEo7dsDuvnIVKuGUSW
	evIsuw25hUL55dbSVIljkaGR+p4TyeJXAKWdrC6pknMuDGOGcvNliclvVJ4DNSh24y55Bn9BXu2
	zHzKMpjLFlTIDi5vTIFzVwuMeUTQilOreEMbH675p03cOXNOgz9ZDLukc/mCbrX7sdA==
X-Received: by 2002:a65:4b8b:: with SMTP id t11mr73297715pgq.130.1563834862893;
        Mon, 22 Jul 2019 15:34:22 -0700 (PDT)
X-Received: by 2002:a65:4b8b:: with SMTP id t11mr73297673pgq.130.1563834862138;
        Mon, 22 Jul 2019 15:34:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563834862; cv=none;
        d=google.com; s=arc-20160816;
        b=cEh1OGPZtubtY730Q273xRSRcFLiaRFMgqXnB6myjcgH3XKqGoyiqhs2bhAc5YaFO6
         /j96h2BTf6vP5I7MX/GpgnD5C1NuOFdF7FjgBirkh332MgiVBlF0tsB7qd5C74MApfeM
         QJyzvMrwOiz5vLbSOqWrzT2Y3DCeR5Qr/2DIcLSHFWOoRF8grwSppMJRTCEaTzJ6No/5
         tKMeFrfdJYnZVbau/hK8IpZ2mAjIcClAkexZcGYvb8Dch922A5WdMr181wg2Vj94wI0p
         IoOWHPUtixZXt4leUZyGJyyiqR2pCy4lHcaUghkesLhO2Ole0wTFDqFDHDFGIs5VvzVg
         P0+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=H5rDEOeFRvjrpBGS4dvuQZ6SJfLiKadFXLHgUye++Ig=;
        b=nao8QKVoxVoMvEeG/WzgWR6ITl0rtC4Y4WLfcfGLxa9/xHixdBCv/A/bpskezwtVmz
         Q9Tqt9EYpkuS/V4AcurFm6WWy/+Fk8GdXb0l609klUOLHRT4j/U8xgCX3iCqAfNEJFB0
         A+CarMRGB96Lwkb0EeG04/8CldXRP4/L220adjewWro5HUSdt3FRPrVBWwSOwgqfP0zL
         1KdsZV252OT7fBlQRoMbiTGRsISrAFFTssIiIDB/c2lsBvcKQJ7+KSLijfE2zHMivNC/
         vx2QlanMMaeSR0eDgBm/8kjn14gj1ZMNBmLLSG03FyQppvs8bXsWDLb62C8TO7OFuEmx
         yFVw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="Pcs9/tR3";
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h26sor22493458pfo.20.2019.07.22.15.34.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jul 2019 15:34:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="Pcs9/tR3";
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=H5rDEOeFRvjrpBGS4dvuQZ6SJfLiKadFXLHgUye++Ig=;
        b=Pcs9/tR3DaHZa4DyTRc+V1EBVautcG67Y8Rlu5OVhq9gKq6GUPJQe1wcWgSdEsQ2Kq
         Radfqy6wlFYNzaWH7qZJhs5OiX9krJynNgS9czJHFLw45UEGbEegviTKLi3BYeTqppE6
         wClCxR/cc9fseFTseNMdctyP1DsHiAKbtD3vrFPJ63NuNCU9kcF/wCkCf+3/B3Q0czjq
         ukVZJzmrau8htl9Bla/qPE0ArxviXBYhsjitL4/aZ7mWfpykEpu6jiXE0UB7wdf00smi
         8G8KNFJh7oVyyxUX3OS2FzQaqS9mTboIDnjdqYM5MTevgkbFpW/jwrfFQHv/btHh152l
         vo1Q==
X-Google-Smtp-Source: APXvYqy5ILwW5Vkz7E3PJko1LlOqyK0nYxF3IsZhHj5oXXw0vxfHVHN4Sbd1j+lEz3Chtbcoljrf1w==
X-Received: by 2002:aa7:8705:: with SMTP id b5mr2598762pfo.27.1563834861925;
        Mon, 22 Jul 2019 15:34:21 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id r18sm30597570pfg.77.2019.07.22.15.34.20
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 22 Jul 2019 15:34:21 -0700 (PDT)
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
Subject: [PATCH 2/3] drivers/gpu/drm/via: convert put_page() to put_user_page*()
Date: Mon, 22 Jul 2019 15:34:14 -0700
Message-Id: <20190722223415.13269-3-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190722223415.13269-1-jhubbard@nvidia.com>
References: <20190722223415.13269-1-jhubbard@nvidia.com>
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
 drivers/gpu/drm/via/via_dmablit.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/drivers/gpu/drm/via/via_dmablit.c b/drivers/gpu/drm/via/via_dmablit.c
index 062067438f1d..754f2bb97d61 100644
--- a/drivers/gpu/drm/via/via_dmablit.c
+++ b/drivers/gpu/drm/via/via_dmablit.c
@@ -171,7 +171,6 @@ via_map_blit_for_device(struct pci_dev *pdev,
 static void
 via_free_sg_info(struct pci_dev *pdev, drm_via_sg_info_t *vsg)
 {
-	struct page *page;
 	int i;
 
 	switch (vsg->state) {
@@ -186,13 +185,9 @@ via_free_sg_info(struct pci_dev *pdev, drm_via_sg_info_t *vsg)
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
+		__put_user_pages(vsg->pages, vsg->num_pages,
+				 (vsg->direction == DMA_FROM_DEVICE) ?
+				 PUP_FLAGS_DIRTY : PUP_FLAGS_CLEAN);
 		/* fall through */
 	case dr_via_pages_alloc:
 		vfree(vsg->pages);
-- 
2.22.0

