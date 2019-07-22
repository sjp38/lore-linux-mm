Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46D6EC76188
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 09:44:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 031F62190F
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 09:44:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="OwRuTA4R"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 031F62190F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 399F36B0269; Mon, 22 Jul 2019 05:44:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34C338E0007; Mon, 22 Jul 2019 05:44:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 23B456B026B; Mon, 22 Jul 2019 05:44:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id E4F256B0269
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 05:44:46 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id u1so23306118pgr.13
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 02:44:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=zG4UEa2GX1Fyu5Yh39Udr4tHubRwjggp9QMy5mzLZno=;
        b=PVhsIJxxNp/Hzo4td6X4x/Pa/vx9HDuQ/QFqjjMkoFOU+rn+QPavUeztWQFI8B/KBp
         A4gwBhBDYsH0LCCJ45slrxKEL2wHYcEVuL3pJnLp+CtDcInUSHb9014z6MJZ5gt6Vuo1
         z5XebXbOixvs8FsAzJYaC5CnqktYvy8/AYcIs9Wzj3cpx+VR8+dOCoUNhkVMYtJqlY5G
         4/cfarcKJ8O7IJaWwg8ZU0QiJNCw7m9MBBzgd7WI9V/B8dOcAX7zVFaaTdasH1wxcT7i
         78txuSbAKm8agBOlX/ZSA1K2XNcV6IQrvEP5iZnfTVGA0V9EomAYTpgdavzVIzzP9/hV
         QP4Q==
X-Gm-Message-State: APjAAAVKXbFcO0aQTgNv5AJda3e4WOlIFSyiDh371HUZJBZzFG1gPnjz
	w+Hr3CsyrANxh7RjG8P+UBfybydYIMwURtfwxd6JSZ+nO1/ggOn1GL26hU5g68whkVu3QKd6Fe1
	Tb1Y8a3WOrAA0us8dl2wcWIb5sMgl98ahlhMuXw6BsW0ILpsqqOSbzrUfUR3u7kM=
X-Received: by 2002:a17:90a:8a17:: with SMTP id w23mr74447828pjn.139.1563788686617;
        Mon, 22 Jul 2019 02:44:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwBEGa43NAkiQvKsiVYtXiEcSY+xVgnMVWR7UyCN2ZN1joSQS++xuksc9iLJfhRJqaMwSQk
X-Received: by 2002:a17:90a:8a17:: with SMTP id w23mr74447740pjn.139.1563788685554;
        Mon, 22 Jul 2019 02:44:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563788685; cv=none;
        d=google.com; s=arc-20160816;
        b=rtcpnUIc163wW7xKfdH25tvUZZYuushBLKsazFsSX2X5xw7J4PUeGAkFE1JsmSINJT
         RaM1Y8tfS1y0/WOafMY6K7GJenq12s46/u0GFKc6W62j+UGp5AwE62quyf35FgZpWcr1
         mLnl4kJEDO+im7h5bJYK0+ZgjhUGQBBj9Uzu6HnufypPkPn17SD2ZujHTRh2eyR9XUAU
         UdRMx+hfgYGN5FnH41W3hx7qPhesko4CQZw6rxiHkgu7CrNilPnjqHjcWWETXWaX+PmS
         sHsOCSDBTsmJkNE+zBBm3JMmNdvdK4CRSwFgAIbeLDJiJnkbRWaVcnnMr/vnYmWgm+VV
         8IIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=zG4UEa2GX1Fyu5Yh39Udr4tHubRwjggp9QMy5mzLZno=;
        b=xJRnQ9DSLbus3mAa30QDeqgBnR67hbICV8l3aF95DTdHHdhjDs7PhZ7WZyVI67dV9f
         1drhNESmcpX3UrQWVWQv0DSbrSUMY+C6Uiuyc5fBaZEBHIvp3VQ6jKQ/P32eemx4fEeU
         nZ0QW3MVKJmCX9wrLVClBaBujIQWHy078FtvGB+F/Fn+GPJwRfWxEuWmHuGVfKm2uQCC
         MpalVpu1LbPm85oVRqlXu9ikuqXyR5EckEAsIzSzrp8sSgfo7MPtqiuffIfBEGGLfs/A
         Bi4drhMqvVRG4WVADaUJeHJ/isOzNXuyXbB+ZNkiiL+h3wASplz0J8ElBe0Xy5vxcVG0
         0xeA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=OwRuTA4R;
       spf=pass (google.com: best guess record for domain of batv+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 31si7724417plz.290.2019.07.22.02.44.45
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 22 Jul 2019 02:44:45 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=OwRuTA4R;
       spf=pass (google.com: best guess record for domain of batv+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=zG4UEa2GX1Fyu5Yh39Udr4tHubRwjggp9QMy5mzLZno=; b=OwRuTA4RlvF4gAb5YmtLSO76ED
	89Iu896ldEIz7x9B3fofOlXRYLvK/KbENL3iRnLpc6FgSHQrILlMQ+Bd4vj71NodoTbij6wEL8L3f
	N9Q8TvE/UlLeZmbiEiLeb6/qf9mewdE0GAo+1S1Wim1YnTVzn3l52npmuiruxFbIruI8Mwrbx8djJ
	FKE7iVS/4VY/MHOQ5+opQCazrS6vN+c5dLrRsoJ983IIuLOD+dlzFfG3M4qKca1aV5PlJZub3GA+4
	cHwl9rkyjFQFF/5iUBKNyUvb5kmiobeSidn1Z9fg/bRz/FXFjA3f0u1sPQ4f3h7fDFjSEJvJTrHoW
	CbDAfRuw==;
Received: from 089144207240.atnat0016.highway.bob.at ([89.144.207.240] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hpUs7-0001uC-5L; Mon, 22 Jul 2019 09:44:43 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 6/6] mm: remove the legacy hmm_pfn_* APIs
Date: Mon, 22 Jul 2019 11:44:26 +0200
Message-Id: <20190722094426.18563-7-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190722094426.18563-1-hch@lst.de>
References: <20190722094426.18563-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Switch the one remaining user in nouveau over to its replacement,
and remove all the wrappers.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
---
 drivers/gpu/drm/nouveau/nouveau_dmem.c |  2 +-
 include/linux/hmm.h                    | 34 --------------------------
 2 files changed, 1 insertion(+), 35 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_dmem.c b/drivers/gpu/drm/nouveau/nouveau_dmem.c
index 1333220787a1..345c63cb752a 100644
--- a/drivers/gpu/drm/nouveau/nouveau_dmem.c
+++ b/drivers/gpu/drm/nouveau/nouveau_dmem.c
@@ -845,7 +845,7 @@ nouveau_dmem_convert_pfn(struct nouveau_drm *drm,
 		struct page *page;
 		uint64_t addr;
 
-		page = hmm_pfn_to_page(range, range->pfns[i]);
+		page = hmm_device_entry_to_page(range, range->pfns[i]);
 		if (page == NULL)
 			continue;
 
diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 7ef56dc18050..9f32586684c9 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -290,40 +290,6 @@ static inline uint64_t hmm_device_entry_from_pfn(const struct hmm_range *range,
 		range->flags[HMM_PFN_VALID];
 }
 
-/*
- * Old API:
- * hmm_pfn_to_page()
- * hmm_pfn_to_pfn()
- * hmm_pfn_from_page()
- * hmm_pfn_from_pfn()
- *
- * This are the OLD API please use new API, it is here to avoid cross-tree
- * merge painfullness ie we convert things to new API in stages.
- */
-static inline struct page *hmm_pfn_to_page(const struct hmm_range *range,
-					   uint64_t pfn)
-{
-	return hmm_device_entry_to_page(range, pfn);
-}
-
-static inline unsigned long hmm_pfn_to_pfn(const struct hmm_range *range,
-					   uint64_t pfn)
-{
-	return hmm_device_entry_to_pfn(range, pfn);
-}
-
-static inline uint64_t hmm_pfn_from_page(const struct hmm_range *range,
-					 struct page *page)
-{
-	return hmm_device_entry_from_page(range, page);
-}
-
-static inline uint64_t hmm_pfn_from_pfn(const struct hmm_range *range,
-					unsigned long pfn)
-{
-	return hmm_device_entry_from_pfn(range, pfn);
-}
-
 /*
  * Mirroring: how to synchronize device page table with CPU page table.
  *
-- 
2.20.1

