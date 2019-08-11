Return-Path: <SRS0=C2dt=WH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF581C433FF
	for <linux-mm@archiver.kernel.org>; Sun, 11 Aug 2019 08:13:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9218D208C2
	for <linux-mm@archiver.kernel.org>; Sun, 11 Aug 2019 08:13:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="bhgtFlj7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9218D208C2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 128EF6B000A; Sun, 11 Aug 2019 04:12:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 091AF6B000D; Sun, 11 Aug 2019 04:12:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DAA886B000C; Sun, 11 Aug 2019 04:12:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9C4B26B0008
	for <linux-mm@kvack.org>; Sun, 11 Aug 2019 04:12:58 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id s13so3919084plp.7
        for <linux-mm@kvack.org>; Sun, 11 Aug 2019 01:12:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=MRcXDHnvegEnPa14nfQi3BqEN+g8pBHoWHKAcBcbf9E=;
        b=l8F86XyLIC9IrpKSINBS1GVz9M/QujdUCJV/tkbpBVfgV7E6wat4150Dyn4NDbM/jM
         5PCtj/i52bGvrZdOVGvbsP24II0CBUcIP+PHBbdnbujck4DNOEIVFOIOMNYvfIsGJ5UI
         7ecsc3U2aOiJLzNKdRvGIoQyazYpevey8Kl+kSjzxAHBeiy31EpmC7jslgoDFTF+S7uh
         872EpSAmjQkbQ+qAXUk+EjJC4nS5Yln3BAO9R8UQViDiA3J6o1zq/30dDy7GGE3HpjZV
         S8+moYMQxw0sK8I0kcOS2M7JO8Cf6LLT54+MJfjTyD1S5ARbwbI29FAJRa5x1rNWfBV4
         4gcg==
X-Gm-Message-State: APjAAAW6lRv3hp/5hCTPwQ+WxhZK2sLB/C0gSPc/341b1IqzvBGXvWuC
	cN63oddULMWG+zLnZt9CTClWCu8IuWh65vtghhoG/njkb46t2ohYVu40kX+UWZEANoi1R2728Nz
	JbiuWazXWq+HRQYIBnACqN4SOHD5H225lFUKzRwUFR6TIipYvxGTVDx3mW22jkl8=
X-Received: by 2002:a17:90a:5887:: with SMTP id j7mr17791490pji.136.1565511178338;
        Sun, 11 Aug 2019 01:12:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwG4a4mM11m1S+YiRZ3iDeACkkOGHBo3MDnZRdrTXC/84F51COy545oitpX+UR0lRWmWlTj
X-Received: by 2002:a17:90a:5887:: with SMTP id j7mr17791463pji.136.1565511177644;
        Sun, 11 Aug 2019 01:12:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565511177; cv=none;
        d=google.com; s=arc-20160816;
        b=DpVrIOAIcYpwoeV3h79Z5kOvUK0FSYxqi/shIZjtmTFiIG/KKXHX5eQP0bIk5inNCk
         Dnp9pEHdgwFM3Fx2OgzNmOY0rpQAPkEuBvob1g3j340Dj3pDxPul+C2WK0abpkd/jKvv
         PZ9UkpMNBFqOxyRNEB+JkiSZuDSBenrnkjF16wWQkI2FyaiPEP5ZO2CP49SdH1Jb1dET
         ZwjFu2rOcyqhU2/XXp0u3xM7SLd6r4FCHJ42W9EyJZWp9BjFQ5mJ/jK30MnsE4/E3Qnv
         QoXOqbHuCYVGA33z3ukmX61p+mOdide4rxcXDjs+zpMqTE+efBCvX+35NYGMsAGL2oHz
         ZILA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=MRcXDHnvegEnPa14nfQi3BqEN+g8pBHoWHKAcBcbf9E=;
        b=FyfCeBf63dgSFxE2b7lTIqTaC6CzLRvyfCAlr1kxc13d5wVpjwJQxEOBxkjgj73egX
         OwsBvIkG5DPNsHggEatzchZxpASmxWoFyBBcv8cvX7aWoTMMgU8nn3Cj2i0o7sXZJUZY
         MNq37Dp32y5Cy19RYOJ03A9cIzvK3ZLLSbOGPED/NW/PBn43YnlXUqUeZVpP48S9lI+R
         WwSV3g69OLfFvi/diLHlyv7KljFCisjP/d2YbIqcfXLVP62JKagwfLgqHJZ0vaBgkMN7
         rbSuZuT5fD17ALqVJuqlo9Qy6h7EctZAuz0iu8g8sjfOdc1AlMzZ33VbyPYyui45Fds6
         U0ew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=bhgtFlj7;
       spf=pass (google.com: best guess record for domain of batv+ae155d32c5e98ef18dee+5831+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ae155d32c5e98ef18dee+5831+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q10si47091871pff.223.2019.08.11.01.12.57
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 11 Aug 2019 01:12:57 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ae155d32c5e98ef18dee+5831+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=bhgtFlj7;
       spf=pass (google.com: best guess record for domain of batv+ae155d32c5e98ef18dee+5831+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ae155d32c5e98ef18dee+5831+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=MRcXDHnvegEnPa14nfQi3BqEN+g8pBHoWHKAcBcbf9E=; b=bhgtFlj77SWSlCwSjYILq91ceo
	78PkXlraHml2oYRTR5Aj0jTSFviOVyqPHDDUnkcmKulGthcCrePG5BcGiGmgD/LDTEFbLvyt/4rMx
	F9i1oqG6lWV8fjRskKRWX8E8Az+mbfrzAuX+sPxz3sffgBLwEZab/+CfuUHtZfxgh1MxIdIyqqsqX
	IDgtMnbPis2tx5d2oflU1k3GlUhBYF2HmdBl18+u1jcwetya75loik3xMKD2nrkC+5BwuhWMM4DBH
	NrztwG5lvsVuKAtIQBHkFCgrusv8on3mHMP4SVFrhXvL1jJs1azM0fbcipVQUSUH5efpD3zTzGkiS
	vK/3xEtQ==;
Received: from [2001:4bb8:180:1ec3:c70:4a89:bc61:2] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hwiyF-0005Co-Hc; Sun, 11 Aug 2019 08:12:55 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	Jason Gunthorpe <jgg@mellanox.com>
Cc: Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org
Subject: [PATCH 2/5] resource: add a not device managed request_free_mem_region variant
Date: Sun, 11 Aug 2019 10:12:44 +0200
Message-Id: <20190811081247.22111-3-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190811081247.22111-1-hch@lst.de>
References: <20190811081247.22111-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Just add a simple macro that passes a NULL dev argument to
dev_request_free_mem_region, and call request_mem_region in the
function for that particular case.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/ioport.h | 2 ++
 kernel/resource.c      | 5 ++++-
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/include/linux/ioport.h b/include/linux/ioport.h
index 0dcc48cafa80..528ae6cbb1b4 100644
--- a/include/linux/ioport.h
+++ b/include/linux/ioport.h
@@ -297,6 +297,8 @@ static inline bool resource_overlaps(struct resource *r1, struct resource *r2)
 
 struct resource *devm_request_free_mem_region(struct device *dev,
 		struct resource *base, unsigned long size, const char *name);
+#define request_free_mem_region(base, size, name) \
+	devm_request_free_mem_region(NULL, base, size, name)
 
 #endif /* __ASSEMBLY__ */
 #endif	/* _LINUX_IOPORT_H */
diff --git a/kernel/resource.c b/kernel/resource.c
index 0ddc558586a7..3a826b3cc883 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -1671,7 +1671,10 @@ struct resource *devm_request_free_mem_region(struct device *dev,
 				REGION_DISJOINT)
 			continue;
 
-		res = devm_request_mem_region(dev, addr, size, name);
+		if (dev)
+			res = devm_request_mem_region(dev, addr, size, name);
+		else
+			res = request_mem_region(addr, size, name);
 		if (!res)
 			return ERR_PTR(-ENOMEM);
 		res->desc = IORES_DESC_DEVICE_PRIVATE_MEMORY;
-- 
2.20.1

