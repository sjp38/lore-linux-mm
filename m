Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C4FAC433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:06:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E77E20679
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:06:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="LJcJrwq5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E77E20679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9DE316B0266; Tue,  6 Aug 2019 12:06:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F0476B0269; Tue,  6 Aug 2019 12:06:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 797826B026A; Tue,  6 Aug 2019 12:06:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3CC9A6B0266
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 12:06:24 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id q9so55135507pgv.17
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 09:06:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=hA5e1EMCJqgYejGyHIpPpeJ8rKRPHls2nPKmf9TbEpQ=;
        b=U4pZU/9zf/RVavF8d9TDSZGIf4b754ZgqGxaqY3uQV6gd7olyEhA5/JeNRGW7VKW0z
         aJghBA/H+ReABzKb7gSg29t7wsi6cbKkro3plbOD3n8/Zj3ZUxidg5qdkgVRO7MVpp81
         NCDilobeD8VTsjZG0ebRxua36eV53DXtdNegFDunLsn9278wBIRnLR3YbLHZoLK1n+Iu
         vCPoC5rWZ3OJiVxjmI4ofm5pKIIYtcfnxR/fQNVWTsccQtCXDkG70QYTu2vq0MPVNZjn
         WZZOY/W3BzGlCGyNlbhocChbY/rUowAdWu/+YT+ptDGs8l2xknFKE6Qk6Jt7kM7HP/2a
         RHGg==
X-Gm-Message-State: APjAAAUXXzur4LBLUGlkvY4qvN2+lOWNX0/GtIKeq/WQ/4d75YUO3w4A
	F+YqovczbU6C/J8f/lpc71DlsHGECcOL8LArV1Gp2iL5/YaMiR52ptw2Wm6qk1iUPxNyXt9pTyL
	y4ZqnRhfcrq2LBs2C1esoBHjCsRtrieAL7+r1g6BaYp66ouGlIhqBrFsFxjpC31A=
X-Received: by 2002:a63:a35e:: with SMTP id v30mr3562779pgn.129.1565107583810;
        Tue, 06 Aug 2019 09:06:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzn1PDDeZCH7o29Jx4sn/7JxVZ/pRQqgQpdpbKeWJNv/hR/mdujyvK8e7FO69OawxCVGaCD
X-Received: by 2002:a63:a35e:: with SMTP id v30mr3562723pgn.129.1565107583048;
        Tue, 06 Aug 2019 09:06:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565107583; cv=none;
        d=google.com; s=arc-20160816;
        b=s6WpZGirVMOKRkYzfFk+wv9uSpHJPquEKeaPGgo2ebgJqrhvZmU4IletDvGOD4wFiM
         ljWFT0+XVYqZAMsBE6sIYKKd4D7v/GCNTgTAO64+atrfmhYNs/+l8P2pt60Lofe7k28q
         xw0CSPREYvOYjiOrkh1OMYFT+UxaEGqv4Vfv5Mme+55rbK6DoQJIZecBlzLwxHS8eS8k
         snEEtzFR4CG+r4w3aLy6lQZz8Nu+QeXbTW8TkcYikcWrapdB1GLvVfv7f0VmqIloacuQ
         yn1X41nXXaJtj6YtmTpxo/1dF8R+rZRnXuQ1pXtN594H0kdZ7FSX1HLrDJ5DLgefzT4r
         BROg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=hA5e1EMCJqgYejGyHIpPpeJ8rKRPHls2nPKmf9TbEpQ=;
        b=gmbnQgepiB3LATYaPEWiTmnhMWum2hN2KxYcsOJe1k4iFIBmHbFhMR7ppmHpDGvOL0
         135lP2jTBt7SuknkF9EMaloeba/BTrCbnhuOC/fRnJBcnIdCmeJGvtXxUopqsUtJa804
         2fjqYG+HLUPz2gA7CGYiWxwIqtR39f2TPYieMS+77N8aK/grjb5L7Iv/c/al1eZggO49
         f991sBiSCDIf0x503FbvvLZM5bmhmjB7fo7mHoHtUyFvMpNLmPu6j7Ei/HZnkXMGOyxS
         jhNv4S3U0SR+opctkw6eOauz621lhlF6hbsHySePrwHB2LfR5eDIuFWLOCESi2g+CCip
         x2hA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=LJcJrwq5;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 4si49368550pfo.266.2019.08.06.09.06.22
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 09:06:23 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=LJcJrwq5;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=hA5e1EMCJqgYejGyHIpPpeJ8rKRPHls2nPKmf9TbEpQ=; b=LJcJrwq5ZQewZswvYmY5mRyZpk
	1/AAsPIRIW9UA0cst7PGgdo7pRhh4ePjyxEFTqCdsjh7EUORxH2CndglB5DcSZf9X3N8Sn6sKAltb
	WWBPJiV/lfl2ul+hsqSrk3D/C5ivDdgjfKPGZTXQhSeNBkogGgnyFlzPfkD559I+eEh9rfGeY2c5w
	FXeB6uScMW1EUmmFK+YdXOfdvFKqwMpCyBF9uzdonrdefrto7s1GONe11pm+yR0lE/qvtGNXNdtUe
	37jSnqybZHehtfCReL3qhmxac2PdimKbmfpWhqJn7mnocY10bShkJ+bK3Y3BkCgnsn/hpbFZ7MPsn
	8usxetzw==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hv1yd-0000b0-BS; Tue, 06 Aug 2019 16:06:19 +0000
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
Subject: [PATCH 09/15] mm: don't abuse pte_index() in hmm_vma_handle_pmd
Date: Tue,  6 Aug 2019 19:05:47 +0300
Message-Id: <20190806160554.14046-10-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190806160554.14046-1-hch@lst.de>
References: <20190806160554.14046-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

pte_index is an internal arch helper in various architectures,
without consistent semantics.  Open code that calculation of a PMD
index based on the virtual address instead.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/hmm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 03d37e102e3b..2083e4db46f5 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -486,7 +486,7 @@ static int hmm_vma_handle_pmd(struct mm_walk *walk,
 	if (pmd_protnone(pmd) || fault || write_fault)
 		return hmm_vma_walk_hole_(addr, end, fault, write_fault, walk);
 
-	pfn = pmd_pfn(pmd) + pte_index(addr);
+	pfn = pmd_pfn(pmd) + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
 	for (i = 0; addr < end; addr += PAGE_SIZE, i++, pfn++) {
 		if (pmd_devmap(pmd)) {
 			pgmap = get_dev_pagemap(pfn, pgmap);
-- 
2.20.1

