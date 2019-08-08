Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A08B6C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 15:34:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 475562184E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 15:34:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="JXmENGUr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 475562184E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E03A46B0272; Thu,  8 Aug 2019 11:34:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB4DB6B0274; Thu,  8 Aug 2019 11:34:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA4CA6B0275; Thu,  8 Aug 2019 11:34:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 938A96B0272
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 11:34:49 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id t2so55659331plo.10
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 08:34:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=v2zlW2TiTRHwHc1yYHq4FO4tl1SIGTw6xolj0rdYBaw=;
        b=HKkSfrw5TSae9tFN69dnFvJh9Eb7NT3Yj1CeGDm0O2NWR6zrmlQ0Wy691Pu3N6NDR2
         59DQbMFwnCbnkmvK+TXNrH0tYkjuj6xKkDV40HTq/DHFDuK9UIrZAp/2n0LbgzDV88fG
         LV7giMTxRykmcmJwLnvjVpMb+NLXPWEL1FOxG57bDpKrZyLdFl3sWfXj3oV8Yt0Je+8z
         bnGgbU9H74TfemnSDSrpPfBs7l1VKSysOKsVVJFWlxPiRfJbTsAkTUhtuVom98hkTrzh
         4JGhHAX0KbW7BbQzrYAKJRaFAg42PQPkGDe4Xu/hjBIvk1qX5jmhOpHzVy9wSpkFIHv9
         vzNw==
X-Gm-Message-State: APjAAAWav6XYG1oqKKMRtvc44NbSYrqKx8LlofPrrZPviHYHrmPzEivz
	XBgd507wN/tVdLog06XhNMGbL0si/tDON5qvJNa+U1nzk+BZRsolRBU5bO9p3ODviOhXA5j5yCk
	Cy+cXxndjgCkzulsPqgYrXVTkME/A0TqNKjKI2WlQD6Bez2Oid4cLa8XBUbaPCj4=
X-Received: by 2002:a62:1750:: with SMTP id 77mr16328103pfx.172.1565278489284;
        Thu, 08 Aug 2019 08:34:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzgrCRYEd90V87Vat+j7jPcGMlOfbQV3Gcw7Onhh6ugr8ecgGUR+yboFCZPAvwA3nkmhcR9
X-Received: by 2002:a62:1750:: with SMTP id 77mr16328044pfx.172.1565278488573;
        Thu, 08 Aug 2019 08:34:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565278488; cv=none;
        d=google.com; s=arc-20160816;
        b=zbBWFhBgCoo5I3OIXGNx10r1xhPs60yFlYjg/2mbU1cWLCfwmWh3ecmDrkI++TTk6H
         LP7F2u/gLayYOPT47l6D2UCcUif1zAPCarW5YhybOWhPVDjzhxKS0hguDyZyGRAVl1r3
         +UMhc8wVcRUHQlOgPJIIJAbIJK2sqN4QkBFT/Layxbdz6b9oEpd7E+viOTVkg2oG7Q1u
         NxlxrDd2TFAVmaA4AYzbO+44hPGAtHVqBczJBGZVHNEuDKeK+lA3BcpXXzOOqdv0c73h
         HkedHz02u0pqpj+L4i5KASyb8KSPE3MDzrCGY78RflpPHYNCPrI9LzWrgc3p0NwHIEho
         N9tg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=v2zlW2TiTRHwHc1yYHq4FO4tl1SIGTw6xolj0rdYBaw=;
        b=hinV7O3MWSI6P9M9AYqWGTLkzxJrvBueKjeUD13B4Kt0SvuOqI0ykWZW6Ck7tnDrRI
         LxI42huUXCG+PjtQl6hFU9PJr0GvwfNySq6BzSUJZzanPKoGLgLztdp0G68Q9TsX1Lig
         CDcvkayHBRz4Ti/wWTfFhAVDL3Qtzre6nmNHX01vprtEQ7LIYsXerN8VUIV02+2EHFSN
         LDQ2xJD6BuP2FZHo3iuCHa+0ipmNf61FIh9J9FYDhYF1mMkgn0uYmFGI6SjChd5cfC/+
         1k3uQFJR70Ju4o7pUVfPPJd1B8eaHB9Hm9t84v5jS0y7vq8efAyP0AiuIJXERit/ubud
         QGfA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=JXmENGUr;
       spf=pass (google.com: best guess record for domain of batv+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m32si50705328pld.438.2019.08.08.08.34.48
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 08 Aug 2019 08:34:48 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=JXmENGUr;
       spf=pass (google.com: best guess record for domain of batv+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=v2zlW2TiTRHwHc1yYHq4FO4tl1SIGTw6xolj0rdYBaw=; b=JXmENGUroLS1HvW6SqOdL/yinM
	YhhrtUMBsr8Pp2pdozCHtVifO3k7GMTDmpdKlncX2cr8/JZF4MId19cVBV3hRfqZX9U7dwI09fbf/
	hexxS1WO+lCCjUlb3s3FnCPFYhsUI3QKf5vMKJKuZfCrN0Bye2whoBDloM+y9jftT/rzgkBUHvoL7
	INJQ3PlxLsjyTixA/U353JAunFQ3zuvbkRhSLKZRo5tQIo2uT6sk+w2Bbh2VNQ745efaWvJlKnNcW
	4lWB4m6MECSZAgpf2+1UG8uLFd8+qz0HzLUXM8UdRHRkHEd6XuHB4ZkMLXOOv1+EFAMuMQiuxZp1D
	jcB06A1w==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hvkR8-0005SM-Q1; Thu, 08 Aug 2019 15:34:43 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 9/9] mm: remove the unused MIGRATE_PFN_DEVICE flag
Date: Thu,  8 Aug 2019 18:33:46 +0300
Message-Id: <20190808153346.9061-10-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190808153346.9061-1-hch@lst.de>
References: <20190808153346.9061-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

No one ever checks this flag, and we could easily get that information
from the page if needed.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
---
 drivers/gpu/drm/nouveau/nouveau_dmem.c | 3 +--
 include/linux/migrate.h                | 1 -
 mm/migrate.c                           | 4 ++--
 3 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_dmem.c b/drivers/gpu/drm/nouveau/nouveau_dmem.c
index e20432a58ddb..eca4160eb27b 100644
--- a/drivers/gpu/drm/nouveau/nouveau_dmem.c
+++ b/drivers/gpu/drm/nouveau/nouveau_dmem.c
@@ -582,8 +582,7 @@ static unsigned long nouveau_dmem_migrate_copy_one(struct nouveau_drm *drm,
 			*dma_addr))
 		goto out_dma_unmap;
 
-	return migrate_pfn(page_to_pfn(dpage)) |
-		MIGRATE_PFN_LOCKED | MIGRATE_PFN_DEVICE;
+	return migrate_pfn(page_to_pfn(dpage)) | MIGRATE_PFN_LOCKED;
 
 out_dma_unmap:
 	dma_unmap_page(dev, *dma_addr, PAGE_SIZE, DMA_BIDIRECTIONAL);
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 1e67dcfd318f..72120061b7d4 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -166,7 +166,6 @@ static inline int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 #define MIGRATE_PFN_MIGRATE	(1UL << 1)
 #define MIGRATE_PFN_LOCKED	(1UL << 2)
 #define MIGRATE_PFN_WRITE	(1UL << 3)
-#define MIGRATE_PFN_DEVICE	(1UL << 4)
 #define MIGRATE_PFN_SHIFT	6
 
 static inline struct page *migrate_pfn_to_page(unsigned long mpfn)
diff --git a/mm/migrate.c b/mm/migrate.c
index e2565374d330..33e063c28c1b 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2237,8 +2237,8 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 				goto next;
 
 			page = device_private_entry_to_page(entry);
-			mpfn = migrate_pfn(page_to_pfn(page))|
-				MIGRATE_PFN_DEVICE | MIGRATE_PFN_MIGRATE;
+			mpfn = migrate_pfn(page_to_pfn(page)) |
+					MIGRATE_PFN_MIGRATE;
 			if (is_write_device_private_entry(entry))
 				mpfn |= MIGRATE_PFN_WRITE;
 		} else {
-- 
2.20.1

