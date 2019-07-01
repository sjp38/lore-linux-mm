Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5BC2C4646D
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:20:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AD85521743
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:20:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="McY+jahO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AD85521743
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 959566B0007; Mon,  1 Jul 2019 02:20:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8DF2A8E0003; Mon,  1 Jul 2019 02:20:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 783008E0002; Mon,  1 Jul 2019 02:20:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f205.google.com (mail-pf1-f205.google.com [209.85.210.205])
	by kanga.kvack.org (Postfix) with ESMTP id 379526B0007
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 02:20:36 -0400 (EDT)
Received: by mail-pf1-f205.google.com with SMTP id c17so8206001pfb.21
        for <linux-mm@kvack.org>; Sun, 30 Jun 2019 23:20:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ha0G2SIX3qJwQBHCJ94hXS+l70ON3HkLuGbICbqpRXk=;
        b=C/Zfw712SJPxGw3C9+NQJaZ129fYaIx6Aaa3NYgBrdMMAJGmy7N4V4yphqzujY+L9r
         6GzUrCTIdc43KRSHmXv3p402wWpJx+xTpc75YZjBLkWl8/oWVOQVo3hIksvHvX5NhcsS
         3DztNydVdqR4ISb3u7BD9Lhseuj28MhREzXNjJFaqZN2lWpl63q+KV6gffm2bferBw8m
         gqasimJnx1e2amqx95DLQkGwtcD5b5679ppIfOnf+PB7afCrVKfT/qY00zKL83v6WeVs
         2jClSx3WC5IHucUrDZ4V0nx2S42F1uELEs9QD6gcalUSoNGt6F3XR2Yyk/yKcOgIzEmA
         E8eg==
X-Gm-Message-State: APjAAAU0ACAlTW1SSF3o4ZMCt68Uib3iW9LEdgv54oc+bq4g6aIMA6yD
	6NO5sGr8NFyGGgfNE2n38aP5Hxh+MX9byRASB8nwJCMzaxqR6nnS1AlkzoZ8D/VEmcPYejtrpZ4
	xB3kL2c+Xqch7VuH7RsmE5H1/4LWO01sYUqDaiESj7L2uKTUdeIVCmrMcTMtakdo=
X-Received: by 2002:a63:fa0d:: with SMTP id y13mr22911186pgh.258.1561962035792;
        Sun, 30 Jun 2019 23:20:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx4xieiQ7b+966XVeIVefCw2wvYckf7+lWDhrjXnz1VDR7Kg/ig/g0dSYEHF2ByKwKAg9m4
X-Received: by 2002:a63:fa0d:: with SMTP id y13mr22911128pgh.258.1561962034947;
        Sun, 30 Jun 2019 23:20:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561962034; cv=none;
        d=google.com; s=arc-20160816;
        b=mbxRGua/NruqxaQeOjHhQnKNE5haIbPzMhER3HoErFHgxKiq/IOygeo23RowkX0dk+
         Z9aVaUooFFc246tdj2SCOnPFhZ44AcZGEWGj1TY/Mu1+T3Qdw8lMv9JBW+altKl/755x
         1IwJ50KtBPJc84NTC7xpUJ6i1EAZam/LvMAJ7wTN3m7i0JU/5ASYuB9quGcmZVgiETiW
         WkSdK9Z2idsdAXqGwp5o82cxeUBxW0NXMKK5vl3JeKE/bf7JbPirGa9Hqcg2YuqWd8bv
         0E5x+dZQ8z4LxlGJNPmgzNazpo+L8MCAnmTch/uknckLF92GNxA+p5ynQELYb8Eeqez9
         JsAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=ha0G2SIX3qJwQBHCJ94hXS+l70ON3HkLuGbICbqpRXk=;
        b=n0IY1cg51kf++pPlWOcMqaI/iJWPb2psEVtERI2JOehekO4vj1OAgvFKAtQup4Tuxq
         WHN4ZHl6okJTk2hIx4vIOpPmKIyDZkA+d4qwA9OyINLr/CxkIwLvYLjvpIdz8XVteHNw
         /Gwkycgk/rm7Wqttw4Qq9TzZfrYsYO2Jj+qo2jjbb6w/RKSi5IMJ01l9jK/DhKoJLiM4
         2MDv3a8PgWHqF4K+EO3EitIQSueOJxRi8EX//PYOAEc1UzS3QKxUHKdvNLQXekTJPzvj
         YimPBHPrAG98JarHUMa5Kn9BanoNqxiUJXNlimoHShI6BMyzaGPajORwvhMt5Np2cmaJ
         ra7g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=McY+jahO;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h6si9438514pgq.576.2019.06.30.23.20.34
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 30 Jun 2019 23:20:34 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=McY+jahO;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:
	To:From:Sender:Reply-To:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=ha0G2SIX3qJwQBHCJ94hXS+l70ON3HkLuGbICbqpRXk=; b=McY+jahORBX9m/je/bQ6Q38b0
	28WcXEPXZE6Hcjq+4+sHpTWSUUYsygvbEwNrGXLJDRekMZBBLHs2JA6d74Md5I104lXzbV968Av2Z
	J3DQ3Q8m0Co759Cpf29dQlJNwis3r3MTh0SnOtF3FTLzlzDD1UtJcPF1MrRi/lcAYx9uEtoYU6DI1
	zW2v8jIkosACsyQpdiePRz4xMw1/0Q20ytuHFjDVBFY4moXLnh+l4DZt9Ylgq8UV1BYJzXJjsmDli
	YQZuhtMWHmwqMewYBuiuiE9Re+8KsGcSZTxhoYiwxkwOqQWnvw8dyNpA8uGeK74XtpU4V04Cfy3z7
	hn4lvcOUg==;
Received: from [46.140.178.35] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hhpfz-0002ta-A6; Mon, 01 Jul 2019 06:20:31 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ira Weiny <ira.weiny@intel.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Philip Yang <Philip.Yang@amd.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>
Subject: [PATCH 04/22] mm/hmm: support automatic NUMA balancing
Date: Mon,  1 Jul 2019 08:20:02 +0200
Message-Id: <20190701062020.19239-5-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190701062020.19239-1-hch@lst.de>
References: <20190701062020.19239-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Philip Yang <Philip.Yang@amd.com>

While the page is migrating by NUMA balancing, HMM failed to detect this
condition and still return the old page. Application will use the new page
migrated, but driver pass the old page physical address to GPU, this crash
the application later.

Use pte_protnone(pte) to return this condition and then hmm_vma_do_fault
will allocate new page.

Signed-off-by: Philip Yang <Philip.Yang@amd.com>
Signed-off-by: Felix Kuehling <Felix.Kuehling@amd.com>
Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
---
 mm/hmm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 4db5dcf110ba..dce4e70e648a 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -548,7 +548,7 @@ static int hmm_vma_handle_pmd(struct mm_walk *walk,
 
 static inline uint64_t pte_to_hmm_pfn_flags(struct hmm_range *range, pte_t pte)
 {
-	if (pte_none(pte) || !pte_present(pte))
+	if (pte_none(pte) || !pte_present(pte) || pte_protnone(pte))
 		return 0;
 	return pte_write(pte) ? range->flags[HMM_PFN_VALID] |
 				range->flags[HMM_PFN_WRITE] :
-- 
2.20.1

