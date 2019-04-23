Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA113C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 16:31:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 78844217D9
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 16:31:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="do1Mrgmo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78844217D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1DFEC6B0266; Tue, 23 Apr 2019 12:31:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B7D66B0269; Tue, 23 Apr 2019 12:31:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A3806B026A; Tue, 23 Apr 2019 12:31:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id C71FD6B0266
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 12:31:34 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id d20so604298pls.15
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 09:31:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=0RFKXT+769rKHtvqN8mP3Igw2OsH7+hhKlZxW0exa+0=;
        b=Ez1J27jxWtFwO2HyGGAk7Z7zpgXVTONwmV5KeZlEbAq3hkezGN0Q+LbrMHt9+o/JgM
         X6IXAZdjOr2MvxRO6xIA0I7RsE+t3TohdbrNI6f0iC13tsfg9/Xstp7i6RT9lOdiPj/8
         KirkVuP/39JegRnRzmIlpfjOCgQVuHkICxnieapG0qyYMUubqDS8q+ftkCuAmEYn+f27
         UBDJK0M80OjF+BzFMH5hIw4IZyCMPFW3zTDcTMBnQhf9NXQ7QpQD24j4mjgP02+DUGuH
         FUTLZ7vC8eLGqwFwdnXczsaZa7S2owrgYV+ispTSSu8E/nlzCNSYzz1bB9QwzXWhtoxv
         L6Xg==
X-Gm-Message-State: APjAAAUAGPp5ThwBx8NtQn/5fbgCHsFcZcNDefWoDMMXGSqwNOveZcUr
	WpRtBzhZ6znwujmhKkOJn2pqrZpyPPrqaCXp4KSrNkzgS7GgcGKQ1rTYI1ujdxCwkWu/whVsZhc
	gyeK8O8GAuCIQbS1HHeQdZnFN5Wd2lxTtsXCIePsHxh0Fh0cCtMYXbCg8GMF8YwY=
X-Received: by 2002:a62:4ec8:: with SMTP id c191mr28279933pfb.138.1556037094477;
        Tue, 23 Apr 2019 09:31:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzFlkucp1ODmtLg17vC064iEARZDC4NN3GVo5BOFBKC1ICUIelLeERhZHNFpF9JtE3FYANG
X-Received: by 2002:a62:4ec8:: with SMTP id c191mr28279350pfb.138.1556037088733;
        Tue, 23 Apr 2019 09:31:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556037088; cv=none;
        d=google.com; s=arc-20160816;
        b=su2ZFaCGUZq7BnoNO00Dp/PqPkuBzGZTf6WAUvoUDP2/Kq09hMnkPYZ/lGAh84PR0U
         6BsrPGUC7DAcjUnlull5mH3A1O2bKjoBXy1CKpuFbUX7cyVgPxAczvEhQpiRbVdGpYW2
         XieLWYHcQRcJSrMvU/Vot52m23+UWZ74tFDOJ+6n6PVdCzXTV9ZugOGWj68OMMIrziLs
         MXOq+id4utpc5TxgsN6FzTVuhdpdXZrNV8Aw4z91LrtDaUE0mtZszP3QWt1sg1P1xlAl
         GumT30G7ZmLWp28HUc1aKhWQG1sEZ7O7se75GhqHn41/3Jnvc0zZ1TKcsEA5E1yNLJE+
         0gtw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=0RFKXT+769rKHtvqN8mP3Igw2OsH7+hhKlZxW0exa+0=;
        b=akpRU8WXVNo9zqyZQZZks5mYB3c01H3HHLZ1rdtmelIAQZDNE/BTMmrxb0exRi9WdT
         iJfxCWFR79vEjJe+Knjq3ShGaAGwXq5Z8N0VnyGa/6IVeHbw2ORq5ZbEsNubM3UgTlU7
         26s35HSW9aNMMLR6bp+04RyLsces4c+4UginM0oqv8hGP1ptaP9bWeBfcEqMfYaRWukm
         tN7Ln59yamjuWVKgqLWXcGwHBqmvlbzUzmUnsXyY8uqyZc9UawsVjBOs/YgKAjUQzCyW
         iaEGxkYfRIVRsoOwJjsu5a4piCKv1mf1Cj7oPBrvrNronCPi6tyyDzmh74qxisnXKMVp
         IvwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=do1Mrgmo;
       spf=pass (google.com: best guess record for domain of batv+307e856acde472aa9de6+5721+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+307e856acde472aa9de6+5721+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u20si15378139pgi.431.2019.04.23.09.31.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Apr 2019 09:31:28 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+307e856acde472aa9de6+5721+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=do1Mrgmo;
       spf=pass (google.com: best guess record for domain of batv+307e856acde472aa9de6+5721+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+307e856acde472aa9de6+5721+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=0RFKXT+769rKHtvqN8mP3Igw2OsH7+hhKlZxW0exa+0=; b=do1MrgmothI00rTmttfcC5nqz8
	ce9dzfOZr+FRYZ0pywXANatw78c7kIjjC0iiz04EQ9Kf1b8de0FJAhuauuyyIPUgnGdk35qATk+zU
	NuwoFd9jsyGSUg7sVmmVXnTQDH6pg8UbW3K3yuU2XJ8l6aFR6K8tGPwZcPa7hY1sdGFUdwR7XiuI5
	K/MgyL8oaFWvkxmF2SaSdtwiImI8CtcTgLb1GqI5Nm7Q/qFQGyKHBj/eYjUPtff9t/qolPKJVTIKx
	ihjlJG66YS3Cs4dv5xQw6zikxBBIdQPQAFQNo1WPkayM7nYtBPo/Awb8o+0Nj9t4E1JHqAxGTKIiY
	YvPFqmEg==;
Received: from 213-225-37-80.nat.highway.a1.net ([213.225.37.80] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hIyKN-00042B-Sg; Tue, 23 Apr 2019 16:31:28 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Subject: [PATCH 1/2] mm: provide a print_vma_addr stub for !CONFIG_MMU
Date: Tue, 23 Apr 2019 18:30:58 +0200
Message-Id: <20190423163059.8820-2-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190423163059.8820-1-hch@lst.de>
References: <20190423163059.8820-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/mm.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6b10c21630f5..969185079ae4 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2676,7 +2676,13 @@ extern int randomize_va_space;
 #endif
 
 const char * arch_vma_name(struct vm_area_struct *vma);
+#ifdef CONFIG_MMU
 void print_vma_addr(char *prefix, unsigned long rip);
+#else
+static inline void print_vma_addr(char *prefix, unsigned long rip)
+{
+}
+#endif
 
 void *sparse_buffer_alloc(unsigned long size);
 struct page *sparse_mem_map_populate(unsigned long pnum, int nid,
-- 
2.20.1

