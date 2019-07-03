Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B300C5B578
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 22:02:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D68CB218A0
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 22:02:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="rntZ06uU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D68CB218A0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E02E58E002A; Wed,  3 Jul 2019 18:02:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D655C8E0021; Wed,  3 Jul 2019 18:02:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB6B18E002A; Wed,  3 Jul 2019 18:02:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 75BC78E0021
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 18:02:27 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id q14so2289970pff.8
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 15:02:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=GmIbzmtd8tOzuQLg/EqjNzFkCAF84w76eG2p5TWzhiU=;
        b=UONYVAJlHaAAHsQe8ebkKnBuvLhF7uHcQdZSouY6VWiGuCZp7DsQDPPBtNnyXvTt51
         wtCmG20lex1VH+9t4jeOOYbwgx2h/H4jHvSCvoPBWrY3JKibypJM8vbq4ivSPpn+YdYm
         n0Mb1Ql/ShP9MpZBgmpwhy7O9A5ktAHAwFF0+pbSpOCShfnmx8XbsKs65I19pFp0qAUJ
         ZzGfZYlQ0Eq1QJEHuYIa2JjZKdWYFwP0Y7GIoqH9gYKh2Pc8kauwP/N0KBTLw4oorutj
         G4xkcxYbLzPxAHVw+NKRmt8XXr01gANF4X+i4BrgoKLLHuF9R0FV85/nMGyYsG0vlWEJ
         KJ5A==
X-Gm-Message-State: APjAAAVBJwEcGsuBRSE5xQS0D2/CR9ufNDYIXXNIwHqtY6Y/H6ZBFltI
	6digvjzZyXKEy/uAzyHSxPfEOK1DS1KsPzEf32Shuv2MAJIM9ZkrJ8li+2fb1EaQ6ROyEnnzM/8
	x3+fV4jrQcb0PFVgc57fAjHXV5+g4rwE+dRd8SYe5eqPTZ4AhdLCHH5+Iy+RiPu8=
X-Received: by 2002:a17:90a:7d04:: with SMTP id g4mr15523698pjl.41.1562191346696;
        Wed, 03 Jul 2019 15:02:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxh5F8dQnlqos1N1PT5AQ7oHRQZT0ns5THkbTPBE/hvFz1cq+z0Nu8B+Pkt2JBVW4qFLdy9
X-Received: by 2002:a17:90a:7d04:: with SMTP id g4mr15523614pjl.41.1562191345505;
        Wed, 03 Jul 2019 15:02:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562191345; cv=none;
        d=google.com; s=arc-20160816;
        b=ee4GKI5lfi7610K6hUqGkf4ck4eUzUoIhLBNxPUyo+UO+bTJ39BO1q7BWzyBHkTc03
         p5mndZP11Tnm666Ifyc96uqqbeEIJglmV9+goaZ7L1emb7A6La7Zo+jyV3zzFNz5gVOa
         vZdMWCHwNluEc1K6t4FuYrFSN9+2H/YoY7KiHGKdSJpC+bfyogprldAnWptxgmlsLlKO
         sFjtoS4r0psGHwnQNdI/nlNnlFjM6t3ZcJnjFHR/RyPEU0ZspA4370x49VolJwi4+suw
         kB57dr49/5wYl07tE2YeFR/TG+rLhLANeYgUNwrOr3GsTbpZFnoNW8GopmX5XgyUfFQw
         dMQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=GmIbzmtd8tOzuQLg/EqjNzFkCAF84w76eG2p5TWzhiU=;
        b=DsJeySR+Q45ioCdKMQNsy41KPgqyV/lvwp/exFiVJyLYU8Yww3LZCR4ihlAur3Riq5
         18sxGxMJgACHD6CcGFnWELjg0Ut2oDGyNzqWxvAWvV/erhOc+ZJOHoJW6R4lEspcxjqc
         sHulgkk2CaQqab412Yqtjc7rvoI2kQLqcmzVNsZzUI7AmBrzcCCfqy50hdq3Lo4Q7MK4
         xZDGhLY6rDdah/xT2RZD+CrgerNUz7HdQWQ7TaQAVcNXtvIVfdVYt6I2WYAMmW2Uk1EK
         qqnpIJ9esm6H+MxYiY622kXUonrIvMxXNqv3/XQ9TsTdi+cCaIpqnRlQy/iLO/EBI7z0
         Zs5A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=rntZ06uU;
       spf=pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w18si3754812pgi.37.2019.07.03.15.02.25
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 03 Jul 2019 15:02:25 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=rntZ06uU;
       spf=pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=GmIbzmtd8tOzuQLg/EqjNzFkCAF84w76eG2p5TWzhiU=; b=rntZ06uUlfg/5V+8FahH4VKRve
	0MTWu0xf0b1aqm0wYAYPxxooNt2SSuQ4vvjpnEEOS5h9gKLJ3rgNyZ5EJcPK3FjtJHY4t0WVemkdA
	y3sGrURy8SD/wfZyHPlvdc4Y0rB7DCzAbOMjatokw8rBtMyajtZFa8eUdnBzSIFtpGf0TICahDuUb
	Ua5BOTAsjHhBLjVqtdRVsqi5KqQR1r9mDEVMh70w7Ycs+P/S+rHEY+JhB3PREIVP/hBdt+xg9WWli
	52ZJ6E8O3cpcXHKds0bFgglaJbptoQ5a1RVSGE8FFl75HsRneFOQTkbkPoPjNF808QquF6LjNNhKV
	Rj9RIUZw==;
Received: from rap-us.hgst.com ([199.255.44.250] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hinKS-0004Er-Pp; Wed, 03 Jul 2019 22:02:16 +0000
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
Date: Wed,  3 Jul 2019 15:02:14 -0700
Message-Id: <20190703220214.28319-7-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190703220214.28319-1-hch@lst.de>
References: <20190703220214.28319-1-hch@lst.de>
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
index 42c026010938..b9ced2e61667 100644
--- a/drivers/gpu/drm/nouveau/nouveau_dmem.c
+++ b/drivers/gpu/drm/nouveau/nouveau_dmem.c
@@ -844,7 +844,7 @@ nouveau_dmem_convert_pfn(struct nouveau_drm *drm,
 		struct page *page;
 		uint64_t addr;
 
-		page = hmm_pfn_to_page(range, range->pfns[i]);
+		page = hmm_device_entry_to_page(range, range->pfns[i]);
 		if (page == NULL)
 			continue;
 
diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index fa43a9f53833..bf641bbecc7e 100644
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

