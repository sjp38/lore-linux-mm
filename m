Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3D2BC0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 15:34:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA0DF2184E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 15:34:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ALaU7XjQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA0DF2184E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F85F6B0270; Thu,  8 Aug 2019 11:34:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 32DD26B0272; Thu,  8 Aug 2019 11:34:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 21F0E6B0273; Thu,  8 Aug 2019 11:34:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id D83796B0270
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 11:34:43 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id d6so55623065pls.17
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 08:34:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=vBk1LYfglvU9WhzFBd+HGPsCFZW0PolzMu2uE5RY+Ss=;
        b=eFE1AZJHfWZHd84Z6BKs+fZiYJjZezbtGUvyf/CqQ8oDq/zTQHfgbKA6UAekAtcPXG
         qZqKGtafkpYyPaxC6aaJ15cr262VkgR42r5k99fARre8I8+kB7xjPZXdFUYp7B1SfKLD
         D8z/GVH+zXF+ofwG6RatfFx1XAXiDBwBii0c5zKRHVHEW+OuhC2Iu9uIH21h16tx/Kct
         Uo3evCGPRoYCt6jG1YG8uazC6D7x5ORCcX0hwSm2Smd9Q9AhDBviIgefS+EmnzN52u9T
         EwpHdS0ZJvFzJw+shNMH/XhG51/Ox1aP+5lT7wBFO8Qzc0w6ehdri0z8ZK7MjqxPcYnc
         /gcA==
X-Gm-Message-State: APjAAAXdxNHybIno5SeWz6+nKhhj8ZDjCR+0roozXY+NtOb1mFLX002t
	+w9OuY2TK5ZLP9lyj66LpoXRkBGI1lW2zp+xq494BAlre/6h/BJjojNnWi2eoPTr5vErg/CmDWP
	XibMQNFCwNmiHi77XQG1DpMNLgyOH2HHMNr/nJN5/hPH/sla2Scur3xR7akPUkE0=
X-Received: by 2002:a17:90a:cb81:: with SMTP id a1mr4549229pju.81.1565278483565;
        Thu, 08 Aug 2019 08:34:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy06CAalBAyr9jZ+BAqj1YKmjwgYELVtpZBcul2nRI7iqj1D+/Z+TH6xy9Qkl1pi8KNTgdi
X-Received: by 2002:a17:90a:cb81:: with SMTP id a1mr4549173pju.81.1565278482871;
        Thu, 08 Aug 2019 08:34:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565278482; cv=none;
        d=google.com; s=arc-20160816;
        b=wr+Nj/oLrY7utUZjC3oVUXIJjYZZMcKInBirhfF4zgQRdEx+RM1xjLnwgf3IMLfuay
         cdDfU4RXd/zthi1A5c2xXEbM2fEQF4THccTGILFVGNaSutm93cvk7rleFV/f3rTyhNKF
         67p8YRDdQ6o92zAVgPYtkWUIpIXiGGBa854rKRajHd3CFv1eVwwwiCF2LpCYoyxTkmiD
         qQsHDOW0nWr44Ont8q4f2E4kB9MfJRWG8QcWRdJdjC2uGWYGcPnjTOvbvV6StYurX/2c
         g7bH4hv9bCMqNvBEzbtKr7jqYJLCIRC4OxjNZBWbWPxqThGRdWdF+kCgjFzWSj715+6P
         Ehqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=vBk1LYfglvU9WhzFBd+HGPsCFZW0PolzMu2uE5RY+Ss=;
        b=Mj3SpM4viLop+goywbz9tGGlIO6e00IrNDfIBojlVH4k5F7lH1vvmkiOXHcqNWWnO+
         csTFviNQ4mn06nQU4zS5IZd9xIJya1tKMWiwM6LKCLq3pO7HAzuFQ2S7ipBjQDyBEVhm
         RyAkis+k8fQnYQ4voV1YYB11HAX/eKTkz54KQmGjh9+gOj7LIiyTqlwcvgxdaNMA7+/a
         6QzUUM7v7u+Y5afzoGJ0rJ8fjcqBlk9ak4jxemCyuI+by6eNJha/4OY6bMIXl30ZMLSq
         YzulXeotoE2Oib8ZK5eejlm496RVj73smFR/pM+uWwpGLNowE+qAcAarVdzqnyfXsTHy
         1/wg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ALaU7XjQ;
       spf=pass (google.com: best guess record for domain of batv+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o70si50321534pgo.280.2019.08.08.08.34.42
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 08 Aug 2019 08:34:42 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ALaU7XjQ;
       spf=pass (google.com: best guess record for domain of batv+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+66be473deb0ef04076c4+5828+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=vBk1LYfglvU9WhzFBd+HGPsCFZW0PolzMu2uE5RY+Ss=; b=ALaU7XjQvOiCbkNXaRaSC/q2a7
	YA/kvuGOiHDbarhR1uxVROzs8tbk4HNjjdgHJED2eXqi3gDGWdTml1FzVVv/4I8SFoS3AcTsNm0CK
	VBltwGcpAbaKkRsnpxJ8vOtI1JoPive+lIC26aQzmcQDodaAwICsbxMznwoDbYpJFKCeKp4vKxPcm
	xSq5gyYQ/E0HwkUHmLtlxFYiXNfyB00nVrIy+xlQZJIWuv9bOuVtBurEeXODahFaDudExzS1isgHY
	JvyOQPy1qJ5+dKKHHWDmQxMBxU2xgG7NbSKgi+qE5OqrlkCcm/8FxPYK4jBuhaFf/pfqMvisNcVbm
	T8XQcxDw==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hvkR4-0005Rs-Rm; Thu, 08 Aug 2019 15:34:40 +0000
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
Subject: [PATCH 8/9] mm: remove the unused MIGRATE_PFN_ERROR flag
Date: Thu,  8 Aug 2019 18:33:45 +0300
Message-Id: <20190808153346.9061-9-hch@lst.de>
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

Now that we can rely errors in the normal control flow there is no
need for this flag, remove it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
---
 include/linux/migrate.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 18156d379ebf..1e67dcfd318f 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -167,7 +167,6 @@ static inline int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 #define MIGRATE_PFN_LOCKED	(1UL << 2)
 #define MIGRATE_PFN_WRITE	(1UL << 3)
 #define MIGRATE_PFN_DEVICE	(1UL << 4)
-#define MIGRATE_PFN_ERROR	(1UL << 5)
 #define MIGRATE_PFN_SHIFT	6
 
 static inline struct page *migrate_pfn_to_page(unsigned long mpfn)
-- 
2.20.1

