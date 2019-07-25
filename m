Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3B1BC76191
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 12:44:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9243122C7C
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 12:44:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="M/Voi5Ad"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9243122C7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 031458E0070; Thu, 25 Jul 2019 08:44:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F22B58E0059; Thu, 25 Jul 2019 08:44:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E12398E0070; Thu, 25 Jul 2019 08:44:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id ACE1F8E0059
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 08:44:33 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id j12so26189668pll.14
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 05:44:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=YtTD1zW4DFFiIXNHW0lcZtx2P/QwbKs4fO50xTY7/Rw=;
        b=VV0DCwLol2bP/Ik/LlJqt4huzkfsrYika1rbkQspI8APWY5z2n/BAII+uIoInrON5S
         wEIS+A/skwTDblPxlo310kmjknYg903QDl1Ntm054keh/CwlOT/F4StkldMKH582k2iV
         qPn8Wp9e5RrtqlEyQ7VQu0MqCYTORZVxOQwTSdmOG7MVkXL0/q24XELhU2UdO0HyUIYL
         HUJ/PCfZn+sZRbNeGpoC1AorDzKZv+wL9FzgoCJWIFCMAh3y/viHQ/Sshh5shdLt+N/0
         4ggmkoXFcXGy6Y9ZIK+QgaSzstU5r2A2Mmx89XSh0u/0pszYfQUfCvFH7S1Os92HM4xp
         gxpA==
X-Gm-Message-State: APjAAAXCQc3q6EIzpbrf3qIjq6PX+n9q9fRV7JyNSH3Dj2oJ90ndBp56
	qukrp92rT6YNhLvOEkiNjhXNwhVhcqs3pblKJiVVcMWXBwPqNt+EwWz2tm+VzCsOHHRnGaKnZRV
	moxg3dDRAfUcn51iMwX9QCLIMTPZESHztfrrO5cY0uVhZp31YSh19iQkBdZzuV3orMA==
X-Received: by 2002:a63:2807:: with SMTP id o7mr56598774pgo.131.1564058673122;
        Thu, 25 Jul 2019 05:44:33 -0700 (PDT)
X-Received: by 2002:a63:2807:: with SMTP id o7mr56598717pgo.131.1564058672038;
        Thu, 25 Jul 2019 05:44:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564058672; cv=none;
        d=google.com; s=arc-20160816;
        b=O2BrZx1cGHwxtbKib1wmclI8QTXBSeTlqdSR2wZ/okwwknS9mxRmbu3iWU24rZIZC0
         2yPcv63TzFfzPtrIomntmYJGBkWz/RuOCbN3KpHXSZ/aczC6wBg+1zL5MsYEh0VsPlU5
         ZM5mqzJUeVJIwh4v8dvqOEBQv8GxaNyOOYMQSTXxlhXtzcZHbPW6q5XqCw/1qLP8nfMQ
         KWZ9BsMQ/62FrVzcSVi3LQyASV5LGBsGvEjvv9sNGedaGzAY0Z/7Wqm8WFm1/MZ7GWq9
         0dtafmIZ1zOAI1svNouDzX4AcR5O1AtzFnh7W+/k+/qFKu48N81Ub4LvhmKWL7PT2KMK
         3BBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=YtTD1zW4DFFiIXNHW0lcZtx2P/QwbKs4fO50xTY7/Rw=;
        b=IUO7Eloa4JODtPpjiQZ1F27IN8IUKuXCTDDwjpGwJ0MOxGqRJ9v/mBvv8S5Zll/bvR
         yUNjyCXF1m3IW7HMzzGeVa7J3CsRwJFvy/rUjcIqDAqV9Ssxm0YzXrA+DhN2tH8xuipz
         h3JhfRSYRZhCFgJN1ngpErtvnewR6c/iScFAGdCpp7ZKEmg+rRcZQkbbJvsgTcooMeZH
         8Eyi5FXN8kFa/nrRLsiVw1aMX4m5Lm63U67bRMsIojU5AiLk0o9uaD8RYdz5mjLK9xhf
         FtDWFHNy6cFkr0m8LN/51SO9WIUiX1ArOId9Ys1Ssta4i9kGdQzNiNXHZpm9MyRvJatI
         4jfA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="M/Voi5Ad";
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e63sor30310811pfa.50.2019.07.25.05.44.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 05:44:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="M/Voi5Ad";
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=YtTD1zW4DFFiIXNHW0lcZtx2P/QwbKs4fO50xTY7/Rw=;
        b=M/Voi5AdNRJuu0f0xVFvWhBGojmOjd9MpiuUS35IZonb5vauyAmAVyzUK52ayLrBN3
         SgiKz3juyYSfNnGjkkTgz45hx6I04HFDTNBTt5UcmCB10eN9SXlRz8/eDLc4EkW0+xea
         qo1zB+JSSfmtRWicQU+daV9QinrXpqhhLHr+xUIW8CaIOt43tAjHH7qysSd5oYOW6T9T
         2yf1t8gNceqUK0rD0LtilyNSrWzlAtQOEy8VPDKVPXoW7btTLsu5WKhZLl21/LpxSyWd
         7/BEc0333JvmoowXxOmujyOVAzCT4EcfNujLbgdwtJxCnHFPG6L1VN/dvmBYNBtSVDVa
         BKGA==
X-Google-Smtp-Source: APXvYqw8t1BcANx6QWJK3Ufj5nZnJSHUkXSuUFta0coSy0Mzsvx9vA+JC+8xkN6Rom4g6ZLvZYhrkg==
X-Received: by 2002:aa7:8b11:: with SMTP id f17mr16520924pfd.19.1564058671500;
        Thu, 25 Jul 2019 05:44:31 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.34])
        by smtp.gmail.com with ESMTPSA id 195sm86924983pfu.75.2019.07.25.05.44.30
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 25 Jul 2019 05:44:30 -0700 (PDT)
From: Bharath Vedartham <linux.bhar@gmail.com>
To: gregkh@linuxfoundation.org,
	Matt.Sickler@daktronics.com
Cc: Bharath Vedartham <linux.bhar@gmail.com>,
	Ira Weiny <ira.weiny@intel.com>,
	John Hubbard <jhubbard@nvidia.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	devel@driverdev.osuosl.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH v4] staging: kpc2000: Convert put_page() to put_user_page*()
Date: Thu, 25 Jul 2019 18:14:18 +0530
Message-Id: <1564058658-3551-1-git-send-email-linux.bhar@gmail.com>
X-Mailer: git-send-email 2.7.4
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

Cc: Ira Weiny <ira.weiny@intel.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Matt Sickler <Matt.Sickler@daktronics.com>
Cc: devel@driverdev.osuosl.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
---
Changes since v1
        - Improved changelog by John's suggestion.
        - Moved logic to dirty pages below sg_dma_unmap
         and removed PageReserved check.
Changes since v2
        - Added back PageResevered check as
        suggested by John Hubbard.
Changes since v3
        - Changed the changelog as suggested by John.
        - Added John's Reviewed-By tag.
Changes since v4
        - Rebased the patch on the staging tree.
        - Improved commit log by fixing a line wrap.
---
 drivers/staging/kpc2000/kpc_dma/fileops.c | 17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/kpc2000/kpc_dma/fileops.c b/drivers/staging/kpc2000/kpc_dma/fileops.c
index 48ca88b..f15e292 100644
--- a/drivers/staging/kpc2000/kpc_dma/fileops.c
+++ b/drivers/staging/kpc2000/kpc_dma/fileops.c
@@ -190,9 +190,7 @@ static int kpc_dma_transfer(struct dev_private_data *priv,
 	sg_free_table(&acd->sgt);
  err_dma_map_sg:
  err_alloc_sg_table:
-	for (i = 0 ; i < acd->page_count ; i++) {
-		put_page(acd->user_pages[i]);
-	}
+	put_user_pages(acd->user_pages, acd->page_count);
  err_get_user_pages:
 	kfree(acd->user_pages);
  err_alloc_userpages:
@@ -211,16 +209,13 @@ void  transfer_complete_cb(struct aio_cb_data *acd, size_t xfr_count, u32 flags)
 	BUG_ON(acd->ldev == NULL);
 	BUG_ON(acd->ldev->pldev == NULL);
 
-	for (i = 0 ; i < acd->page_count ; i++) {
-		if (!PageReserved(acd->user_pages[i])) {
-			set_page_dirty(acd->user_pages[i]);
-		}
-	}
-
 	dma_unmap_sg(&acd->ldev->pldev->dev, acd->sgt.sgl, acd->sgt.nents, acd->ldev->dir);
 
-	for (i = 0 ; i < acd->page_count ; i++) {
-		put_page(acd->user_pages[i]);
+	for (i = 0; i < acd->page_count; i++) {
+		if (!PageReserved(acd->user_pages[i]))
+			put_user_pages_dirty(&acd->user_pages[i], 1);
+		else
+			put_user_page(acd->user_pages[i]);
 	}
 
 	sg_free_table(&acd->sgt);
-- 
2.7.4

