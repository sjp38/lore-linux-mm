Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0288DC31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:48:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B11A620866
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:48:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="R7oVdWdv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B11A620866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 86D446B0272; Fri, 14 Jun 2019 09:48:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E1F96B0275; Fri, 14 Jun 2019 09:48:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3E6236B0273; Fri, 14 Jun 2019 09:48:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id EE3CE6B0272
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 09:48:37 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id j26so1925776pgj.6
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 06:48:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=hVPCPj1LrefwU2xq/k4nx8MUt6z5g1ttpdf31GA4t7s=;
        b=dCzxG3DlILn4AXQSLrZDTc8T6+k/VmuqLFbXJT4Zkzpss1/Q469ac2qgFOI+YWG4Sn
         SYmwnRv/ZHgYlxZlEhf2xgWY996JC0ip4hjlov/JmS4K5fwto2So14cohHQ4QZGlm+uM
         fjQ5iyku1V6xF/6hqDJ4HJjmOVBQQtIDSMwcEvXGYvPqxie98OAUmPImv9tKawY2MBVl
         981zAc0hRVZk8B0QVxNWd67yjavfiRJwFjuap06cggLriI0Dv+HYcOp1o9ud7I2erNFe
         er9uPRgtLdnCmglw0ezK2qt+PwjnMOJVfhUltB+Qxf69u0QBEW6hXJ1zG/kF0fMLyBTw
         MP/w==
X-Gm-Message-State: APjAAAXx9q0OljAmYKSZbKrE6iZ8gUSm+ImWPbzPsieWd+smPel15YkR
	yE9uyvg52i61vrsJ4xuhU1QRCuZ63knrFG8zC+ot/x0BxKhb0S7RpsaJZze8C64WDrz/JXrcocL
	nHBNXaurp5Vf7WLKRRFHm7g2XMoGw+All3kys9TcU2T1BDBwA27zyzfNTgcipKs4=
X-Received: by 2002:a17:902:da4:: with SMTP id 33mr33489406plv.209.1560520117629;
        Fri, 14 Jun 2019 06:48:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzaybw6StxARE9dSOJjQ40gVnWqCsjtYFfFwNtTq6mrY3GUpD6m5DHzHW/5Eok7Y0J17jOy
X-Received: by 2002:a17:902:da4:: with SMTP id 33mr33489362plv.209.1560520116872;
        Fri, 14 Jun 2019 06:48:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560520116; cv=none;
        d=google.com; s=arc-20160816;
        b=t2iIjKhg+gKNISdOaZWvdmm1z4Rs15uM0qRPXIE5+EWV+aBEmme9f11o3XTYCNOZnr
         MpZjrlodeYCfZHsTbgUa4IFcJ0tO/lK5g6oDd+syESNk8ZRqVsuGp+sjXOya3st+j+Ua
         hivkpaVu8gl7+fOkysvL6HPT+BCJuLGDCmizsTLB06bq5e5fW7wpTLPjPLrkAswbsW64
         3R/J8IAOm9moFrucrwx87/PXbJmEQ/HcR2g3WN0pKSvIZwOvQe9oRxPollOp7cFK1M1a
         B5xPodlhp8A1BO2f7pk8Y+Izg7fwWw9hjvCFY/XPmolB/mBu8uOA9B7Fu7eWQt7h6k8U
         Odiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=hVPCPj1LrefwU2xq/k4nx8MUt6z5g1ttpdf31GA4t7s=;
        b=saBQ24gU2GD5RHaYmv/xHPxR1KB3g7G1/A7KsHKJSehFUFbpBVFU/p8KgjGsWrQ+KU
         kJ8mAnvpPd5oaXqGBEgmSK2jNAjDdttgnUaPSWrXEUbPxBmbzFj5Bl4rwg7o9i+U/Pvn
         Eiz8zbvcOQIjdUUGo/NV5O2kbjrgM+kIviJZhNA8MDOnO2Xkp9B40xSoMKbCby/EYHqz
         GpM0ywsMJ5ZlYlel3cj1i/cOXahDR1hZuEu8h1Pe/AIdkGUNwxPgLf39fFnJuc7dmWUJ
         hA42GoC/XVw5UdbIp90MnNF1kLkwQBiGcoy2t7JSb9UoTWCQJBXdeBNARDsWfeZipC6x
         T0+g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=R7oVdWdv;
       spf=pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d191si2589451pgc.460.2019.06.14.06.48.36
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 14 Jun 2019 06:48:36 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=R7oVdWdv;
       spf=pass (google.com: best guess record for domain of batv+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+3311e6b5ef18d39f8a57+5773+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=hVPCPj1LrefwU2xq/k4nx8MUt6z5g1ttpdf31GA4t7s=; b=R7oVdWdv/mZN0cFwPPhtVK4TMx
	UB/wqQzgkHyYoVXTIUGR/8fAw8BWFMkxfhjvQA8cZVsEfByOCf1n/fgHZGG1Ku2HbnOU7wlpCu6md
	kV7iFak0CwzMgcwf+1ko540TzfJZ7m8NhyKeNAafjIR+Eh02tznZJ/tUqmN1GKHmPpnm8D9T4ipEj
	VhsgOFo98A7OHLvTQLaE2S3jC8uxQMExeLN7wqYne/Oa8lDjeUuhj+sBM6/IpP/HI6hcndIgYuq/y
	Z6v4feaEGjGdbjf71aj7myD5cdjMs8C9wTELFpbzveIUWDepgbQiHeWiGh6p6pC5gwcbLSKzfWexb
	co9by/hQ==;
Received: from 213-225-9-13.nat.highway.a1.net ([213.225.9.13] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hbmYz-0005e1-FO; Fri, 14 Jun 2019 13:48:18 +0000
From: Christoph Hellwig <hch@lst.de>
To: Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	Maxime Ripard <maxime.ripard@bootlin.com>,
	Sean Paul <sean@poorly.run>,
	David Airlie <airlied@linux.ie>,
	Daniel Vetter <daniel@ffwll.ch>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Ian Abbott <abbotti@mev.co.uk>,
	H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: Intel Linux Wireless <linuxwifi@intel.com>,
	linux-arm-kernel@lists.infradead.org (moderated list:ARM PORT),
	dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org,
	linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	linux-s390@vger.kernel.org,
	devel@driverdev.osuosl.org,
	linux-mm@kvack.org,
	iommu@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 13/16] mm: rename alloc_pages_exact_nid to alloc_pages_exact_node
Date: Fri, 14 Jun 2019 15:47:23 +0200
Message-Id: <20190614134726.3827-14-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190614134726.3827-1-hch@lst.de>
References: <20190614134726.3827-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This fits in with the naming scheme used by alloc_pages_node.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/gfp.h | 2 +-
 mm/page_alloc.c     | 4 ++--
 mm/page_ext.c       | 2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index fb07b503dc45..4274ea6bc72b 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -532,7 +532,7 @@ extern unsigned long get_zeroed_page(gfp_t gfp_mask);
 
 void *alloc_pages_exact(size_t size, gfp_t gfp_mask);
 void free_pages_exact(void *virt, size_t size);
-void * __meminit alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask);
+void * __meminit alloc_pages_exact_node(int nid, size_t size, gfp_t gfp_mask);
 
 #define __get_free_page(gfp_mask) \
 		__get_free_pages((gfp_mask), 0)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d66bc8abe0af..dd2fed66b656 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4888,7 +4888,7 @@ void *alloc_pages_exact(size_t size, gfp_t gfp_mask)
 EXPORT_SYMBOL(alloc_pages_exact);
 
 /**
- * alloc_pages_exact_nid - allocate an exact number of physically-contiguous
+ * alloc_pages_exact_node - allocate an exact number of physically-contiguous
  *			   pages on a node.
  * @nid: the preferred node ID where memory should be allocated
  * @size: the number of bytes to allocate
@@ -4899,7 +4899,7 @@ EXPORT_SYMBOL(alloc_pages_exact);
  *
  * Return: pointer to the allocated area or %NULL in case of error.
  */
-void * __meminit alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask)
+void * __meminit alloc_pages_exact_node(int nid, size_t size, gfp_t gfp_mask)
 {
 	unsigned int order = get_order(size);
 	struct page *p;
diff --git a/mm/page_ext.c b/mm/page_ext.c
index d8f1aca4ad43..bca6bb316714 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -215,7 +215,7 @@ static void *__meminit alloc_page_ext(size_t size, int nid)
 	gfp_t flags = GFP_KERNEL | __GFP_ZERO | __GFP_NOWARN;
 	void *addr = NULL;
 
-	addr = alloc_pages_exact_nid(nid, size, flags);
+	addr = alloc_pages_exact_node(nid, size, flags);
 	if (addr) {
 		kmemleak_alloc(addr, size, 1, flags);
 		return addr;
-- 
2.20.1

