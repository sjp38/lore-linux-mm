Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82F06C31E58
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:28:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C9E9208E4
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:28:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="OFYLPou6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C9E9208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 363F58E000A; Mon, 17 Jun 2019 08:27:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 317F38E0001; Mon, 17 Jun 2019 08:27:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 16A818E000A; Mon, 17 Jun 2019 08:27:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id C13678E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:27:57 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id x3so7655945pgp.8
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 05:27:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=oE9zu8FnI80f0vIXdSsRJj3CowB8S40euLFZ8PS9IMM=;
        b=RRwLIXNKhj4OE4qI2BCy7MkUwEr9gepTZI48olMVQhPItv9MqYRkWyCQGWthV84HJG
         xyrjZc21zXRey2LY50fIi/DFxMjQOspQCUcWA2gZixBpuF+sy6kbfUl/4yihXMamE98k
         fUNpePxlnv0qdUxAXfGHUdPhpJlabgbXmL/k/sntF98pU40V1e6XZYk7f4zodD9SBRVE
         JlZ9qB9Tm4E/AMNyB/BDUUQPx1pdsuV53YfJAFrJr9ZQZGujDSwJS8RJ6SD9pLnM/Oq3
         GUn2I+t6RX+xynqz+qxK5oRkP7rFPx9N3S7h3lkb46t/dpS8Xk6QVo6aX/HMEEue5BV5
         Vf7A==
X-Gm-Message-State: APjAAAWLoY/VzRczUYRADYckY+KwTWhNasi/XSqzC+JrWlPriZbGxdCu
	3bLdQii6cluN3cUzKbHc7PaV92SNzGY9dRkh2hed4/YvP+64vdnwcfAYUSBZXG1DInvBf0/uhzK
	d1PD98rfIDqWurrHzYRAcYmoFXzQAdSWupy0ycbESUJ6TI6KjI0g8Uo2Ga2Xhjtc=
X-Received: by 2002:a63:2d0:: with SMTP id 199mr48413954pgc.188.1560774477395;
        Mon, 17 Jun 2019 05:27:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxBF3/ft/owsEcaxmCQiSNT9HqJto8MuTtiebnuxZ1z4ipXjFGWOF7pxQfonvxnkXkiv+i1
X-Received: by 2002:a63:2d0:: with SMTP id 199mr48413903pgc.188.1560774476660;
        Mon, 17 Jun 2019 05:27:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560774476; cv=none;
        d=google.com; s=arc-20160816;
        b=ajPdMDHAbdAsPctrN+AqQyymFm3f4OHA+bfoAB73GJ0IC87GTF4Kaq5xzEVLyJ+5M7
         1Q4SEGK8ymis2U+bElh6Bcqc43Sd4YT8GerNyZr5RNf5JT8IUMWpSs0UPwfLfEhCx1AR
         sfPUFzAHI0Y82n97Rx+VdyF+1K3X4ujrayyAqRxlkys3DSelLIYULJccPk1ISQ58yVAG
         7ISQCPcMGEWufys+Hr5S1xobBY9mz0y+kJoRGooYf7xMGbFshdB6y1f6WC6h6XnfuJaW
         MNPeM8wPPoMREHrTiTOZ0rOUshfDpVtxR2imBvDDF2aW+xjqcR2QAOJeLBjZwnyVgz9J
         vsmA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=oE9zu8FnI80f0vIXdSsRJj3CowB8S40euLFZ8PS9IMM=;
        b=ohx5Cl3hvi972co3eguZky3wuGmRSSv9rIXMvEBcoLleDoRXCEj1XQVFM1d32jUYZX
         C3oF0Jj16ebvsyVkjxT7H6av7y1Qz0cdOssjvZrYcZQb0JpK3whjx/GjuKHwScY+xGRx
         18AnIhHCJW3IaRecqh+iKz5xl2n1J/yJZM3ZC6FkcTG2PENP+BkknM3ky3Be/a9xg1t9
         HOhnUhm5J5LYgiM4AdEAxe9VF9KLNh6X4zYo8H+xBgiP2xf43wCFWhS7X25wgaGlGiBt
         yn5vw3Q1WHjQkF04zkKkLAd0FjEQn/KmpOZgerBPLVSKS7lPkrSfM6ccCrwg0qQR8jSu
         GKJw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=OFYLPou6;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 22si10146134pfi.161.2019.06.17.05.27.56
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 17 Jun 2019 05:27:56 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=OFYLPou6;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=oE9zu8FnI80f0vIXdSsRJj3CowB8S40euLFZ8PS9IMM=; b=OFYLPou6TnJdcozuPN11iH/XmD
	RXqmC2lmrDIc90Y8NVCjfx83nqCVoiH00luftBKkX1QDJ9uDCWGmyeDihR9euPlBZLFFLvJEN37Oo
	IIGmTTp9s0JMz7OdQZzjJL8bCIoH3QG3msxcqq8GDVUPyrKek3uGmO1P50zrhewkvIMSsilKB9HGc
	i4vW8MnTCxNbowvDwKJqKc0RrobmUyUT5HllZCeGgrgyTx/O9YaW+CGOhU3j1YYqPcXiTiC58Lsdi
	v5jaT4YEYq+jrlR8fw59fAbQne0n1H6nJnvoV8aVZnyedTnbxgGT+xJd2gzeJqPQ1tUfzHY9lv2CT
	M6eP8oLQ==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hcqjo-00006K-S6; Mon, 17 Jun 2019 12:27:53 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 07/25] memremap: validate the pagemap type passed to devm_memremap_pages
Date: Mon, 17 Jun 2019 14:27:15 +0200
Message-Id: <20190617122733.22432-8-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190617122733.22432-1-hch@lst.de>
References: <20190617122733.22432-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Most pgmap types are only supported when certain config options are
enabled.  Check for a type that is valid for the current configuration
before setting up the pagemap.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 kernel/memremap.c | 27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index 6e1970719dc2..6a2dd31a6250 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -157,6 +157,33 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 	pgprot_t pgprot = PAGE_KERNEL;
 	int error, nid, is_ram;
 
+	switch (pgmap->type) {
+	case MEMORY_DEVICE_PRIVATE:
+		if (!IS_ENABLED(CONFIG_DEVICE_PRIVATE)) {
+			WARN(1, "Device private memory not supported\n");
+			return ERR_PTR(-EINVAL);
+		}
+		break;
+	case MEMORY_DEVICE_PUBLIC:
+		if (!IS_ENABLED(CONFIG_DEVICE_PUBLIC)) {
+			WARN(1, "Device public memory not supported\n");
+			return ERR_PTR(-EINVAL);
+		}
+		break;
+	case MEMORY_DEVICE_FS_DAX:
+		if (!IS_ENABLED(CONFIG_ZONE_DEVICE) ||
+		    IS_ENABLED(CONFIG_FS_DAX_LIMITED)) {
+			WARN(1, "File system DAX not supported\n");
+			return ERR_PTR(-EINVAL);
+		}
+		break;
+	case MEMORY_DEVICE_PCI_P2PDMA:
+		break;
+	default:
+		WARN(1, "Invalid pgmap type %d\n", pgmap->type);
+		break;
+	}
+
 	if (!pgmap->ref || !pgmap->kill || !pgmap->cleanup) {
 		WARN(1, "Missing reference count teardown definition\n");
 		return ERR_PTR(-EINVAL);
-- 
2.20.1

