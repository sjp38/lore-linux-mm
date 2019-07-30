Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF97BC0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:52:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A9AF208E4
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:52:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="UQt+nBOC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A9AF208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 729618E0010; Tue, 30 Jul 2019 01:52:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D95C8E0003; Tue, 30 Jul 2019 01:52:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C8888E0010; Tue, 30 Jul 2019 01:52:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 217A18E0003
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 01:52:52 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 30so39806869pgk.16
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 22:52:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=WWqUlWBk9SeNDsTgchqiBvCPPdXQGby4eLwA4l1Wn/c=;
        b=tmGN93R7Gs4/gnGW18u5DMpzrruiKvYdE1oWzwKuxpJEJSLUPhffsj9PzYiUh7sUY6
         iWDhBYa07mc+BQLWc6n9PTAikJ9v45EHYiNQIQDHfKfCyVmmBeI1tJpKIwVJuA+rJIbr
         sKUnIH6MpXDeDhnQuypMDyWZXlz26n56HFrDoo9jANUftWkyOChlTgidHng1mKT0kiMd
         /QkXWUcrbz/P1ZJPTMbOBZTrNQpCMpq3XuAkegau3Hi/IutR3so7HGUd7iBR6Gjeu0A8
         e4WGpTq76N4hQ3oPkRfUlSzk4IIzileWTccF5OwOljtIQDheuBcAo3OiMaUedWW9/yHR
         ipKA==
X-Gm-Message-State: APjAAAUWohF2KQL8F+qEde9gjFV1tJW+6dR3sgGMm+/6HZLU6wVwwwve
	MctNIQG7Z5MmMKXtyPRCuT5du7rfW7C6l69ahDwm3qB2l+jL9CBy4zrT9P1r3BarQY3mmfbb8zR
	cOwOSxFvXR+ak/XsSd4WPu/NPn5417F5ydlJsVVtVQMU7SWAt0DFwCO2V2V5dLNc=
X-Received: by 2002:a63:f857:: with SMTP id v23mr82507143pgj.228.1564465971705;
        Mon, 29 Jul 2019 22:52:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzLsXT0imxLjdbopFm7Gk5RacpxeEjGbRctO4bwyrWNDb3hdzo+szmHbGPoS1rLyu8aAKMO
X-Received: by 2002:a63:f857:: with SMTP id v23mr82507113pgj.228.1564465970940;
        Mon, 29 Jul 2019 22:52:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564465970; cv=none;
        d=google.com; s=arc-20160816;
        b=jT/rWgXbIdP0p1mG5KvimW1BnPLYAteZHzESFP8NfUv7H4v9+MfWfrhQseSa2p9EdL
         5Te+e0Q6OHODbnVmE1pxRVOnZNvuHDdCnfzkwifh5rqdUL5M6Rjl8yk2FjaNGGN6qNVF
         k/Gtm4tBqWRybw6FxZLCudoBKTorOASzskK9BuqzYMFQjD9+Y+9buweuRW7qewfii5tc
         mw0Tdk1jiIT4FI9wYcRP3sRlcDG2SHWrHr5VkQqSkjSHe4BeVws2hb41PW0PMGdaKj6Z
         aSeJcnRISqLoyxtRXAugRAAqEsZq8ArM9rG7Rjlh6lXgEZV8OVbmf1tempifu7jyF3Il
         BeqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=WWqUlWBk9SeNDsTgchqiBvCPPdXQGby4eLwA4l1Wn/c=;
        b=lwKY6d2afkSSfW1E1PqR4Hcl4WCkMgmA3DAn9MVi/wCzRbPZSH7F+Z1aSRzmEGy6cQ
         BZKMABmYEtwmcKoLyfeuT0yf2nHmWtVBdB47Hz56qhJ7jquTxvjYsP4Zhz7F92h1A0or
         ma/HpMqdJApmCn/EqwuWEotISLtkmE+Jo3l8otTKB1pjUoHv4RImFuUQJ4yF1ygmlrGk
         Qn348NgDTm2jGlzn/ZBXIE7AR+yWY99nD2XgaLWVN7R94SW7HFaq2EslLLFyvEZ+fJKJ
         ov/UT4hwK4fZMQN2IevIpPHbVvN3v1YEPruSoRhwe/GtO69qSJDimsu6iY+9QGNkWLsT
         olfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=UQt+nBOC;
       spf=pass (google.com: best guess record for domain of batv+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p7si25694169plo.114.2019.07.29.22.52.50
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 29 Jul 2019 22:52:50 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=UQt+nBOC;
       spf=pass (google.com: best guess record for domain of batv+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=WWqUlWBk9SeNDsTgchqiBvCPPdXQGby4eLwA4l1Wn/c=; b=UQt+nBOCFLuTt9lR9m80f7mUgE
	lS9m/3kgkBnUgWm075wpjDvoWcfsvGjj6XNdiPu0xYJSsIR91F3EVZwqjOtGPHT3tWlZR1g4Z/KQV
	sMdXE4d3yo6a78yBkEuoY1UtuG8aYk83pTsB59Pqnw9yKDyyqlzcymrOVg3Ou7ovmKyZvBhF6NEzZ
	YLcfiBi183KQGYbKJQFVbR+/FEJmnM8Cf0NcQFhzluMjCVBfbn7EewshSuoqwtxhgBLdNx+a/2VgS
	05Skzq6tlpaW0rNMPwXleuGdfG+87MF1AAS0XJXPfCY9/nfdHzoMBWXoCqJG0YWhBv5LN55u8SyqL
	DNIqFunQ==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hsL43-0001QQ-Bt; Tue, 30 Jul 2019 05:52:47 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	amd-gfx@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 11/13] mm: cleanup the hmm_vma_handle_pmd stub
Date: Tue, 30 Jul 2019 08:52:01 +0300
Message-Id: <20190730055203.28467-12-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190730055203.28467-1-hch@lst.de>
References: <20190730055203.28467-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Stub out the whole function when CONFIG_TRANSPARENT_HUGEPAGE is not set
to make the function easier to read.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/hmm.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 4d3bd41b6522..f4e90ea5779f 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -455,13 +455,10 @@ static inline uint64_t pmd_to_hmm_pfn_flags(struct hmm_range *range, pmd_t pmd)
 				range->flags[HMM_PFN_VALID];
 }
 
-static int hmm_vma_handle_pmd(struct mm_walk *walk,
-			      unsigned long addr,
-			      unsigned long end,
-			      uint64_t *pfns,
-			      pmd_t pmd)
-{
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
+static int hmm_vma_handle_pmd(struct mm_walk *walk, unsigned long addr,
+		unsigned long end, uint64_t *pfns, pmd_t pmd)
+{
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
 	struct hmm_range *range = hmm_vma_walk->range;
 	struct dev_pagemap *pgmap = NULL;
@@ -490,11 +487,14 @@ static int hmm_vma_handle_pmd(struct mm_walk *walk,
 		put_dev_pagemap(pgmap);
 	hmm_vma_walk->last = end;
 	return 0;
-#else
-	/* If THP is not enabled then we should never reach this code ! */
+}
+#else /* CONFIG_TRANSPARENT_HUGEPAGE */
+static int hmm_vma_handle_pmd(struct mm_walk *walk, unsigned long addr,
+		unsigned long end, uint64_t *pfns, pmd_t pmd)
+{
 	return -EINVAL;
-#endif
 }
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 static inline uint64_t pte_to_hmm_pfn_flags(struct hmm_range *range, pte_t pte)
 {
-- 
2.20.1

