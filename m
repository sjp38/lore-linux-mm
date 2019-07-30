Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44423C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:52:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 03FA5208E4
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:52:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="nJyMAedu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03FA5208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3FAA48E000E; Tue, 30 Jul 2019 01:52:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 308DD8E0003; Tue, 30 Jul 2019 01:52:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D1448E000E; Tue, 30 Jul 2019 01:52:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id DBC828E0003
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 01:52:45 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id n3so29998198pgh.12
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 22:52:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=k3bbbqY8SIpE+YtEyLKkL7nQbVMolk+8sJNIxeAyNQs=;
        b=qfoNJLphMorAWQMHBCJ7nkMHJ2IMxS0rP+gakRDHj57FjWRHhLTQkoMqYER1mxQav/
         YW3XxSgRtHAK2z8ZpwuCMwVFV7g+pXAHc/2WTrVJ1tgfs5T8TNwlknW0qxEA3YreNQHJ
         dKk4iG70/YxYXV02oShcMN159c/qNSEpCbKKbzF4XdBfcglIBrQsxUn5hQ8VjA3SA9mR
         m3BMNRfX5QQ5GGqLWOIwwkzgNiKLuMgjUMICsWRKcKo2wFbJaROsZp+3bCGyWN8TTSSq
         ap84wmGyN/uBqOqWssSTsSjRAvU60/01KWAj22CSG2ePXD+NjH3wKbweyk4fT4DC8XyV
         O8Ng==
X-Gm-Message-State: APjAAAUU/ZECe60Px9BtcnQBVQ59gfmOuDu79BJFnqFIU2ibA05s8VjU
	J/FwbPT8uu1wtryEyg8+i0EOeQbOThckvBUDUMcbp8G39w+pJL0u+gtV0NX5pa6MtXSKa3c7UVa
	iroXqYk+6CJmeNiZvTXWEDAfr9XQDoXm0ALKLIco5vqkohlFwBZfZ6xqqh3nvVfA=
X-Received: by 2002:a17:90a:2430:: with SMTP id h45mr118355444pje.14.1564465965601;
        Mon, 29 Jul 2019 22:52:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwfPXblvsdY6b+BW3Q0ffvxge03p5+ZA+GACyhBLYhMZX+a1eMZ5EVyAnxA4Yr8wYFWn4kb
X-Received: by 2002:a17:90a:2430:: with SMTP id h45mr118355421pje.14.1564465964971;
        Mon, 29 Jul 2019 22:52:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564465964; cv=none;
        d=google.com; s=arc-20160816;
        b=0GJTBpJmy6E7/x7bmTe2Kgw0lEDHwipEnCaDL0RMHlkikWHlJJgFWWpUiA77CYqWDA
         sEDjk85OU7R9aU0LVQ2ILCDifdrUBEjvqBAJhyrbG2L+8HBmEoVenYNNx4CmCNn8nzvS
         Ndy9R4Ahvqs2+sUPXIWN1jmBn5FyAw+zA2ausvmxpDb5Lefg2UBfaJkLFxH0qSWS97IV
         hluAjPDibZHOmMT7hWl5r9iO0091KeGWIvE6bMrb9TDvkCoPqG583ts4g0m5rteJoiPw
         uAKda1vY5Dc32PqsINfivhlzo4rZ8BUdKqE+rTOSY6o/OtdxMDVXK4mMZXrWmUP+OlZZ
         g6JQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=k3bbbqY8SIpE+YtEyLKkL7nQbVMolk+8sJNIxeAyNQs=;
        b=t0u2FNzCEt+WYSogEMbADOngHO1kvEC5QQUEDmKUmeP7E+GNQaSjNFCRhz3vvoUhjN
         uLMeU7r0rb84sKumXeTG5MQqOWV5DGr2Nz9GRs6C0hDVxnLGBR5A09/mECIHuQozM+bH
         x/flVTUN+poyeUS5U92Uha4KRAelvG+0ctmrdViSeU+yd97NrRrnBLHTGfljd+AS8Eq4
         bnmgMh++wBrultBsTARYiSx9qGtv0gCXAmRsm2ygDjd9BgOqiXtUwSrYyiklY2qGBkFe
         NicYyyTTi7Mjno7LwlwOCu1oK8w0TeDsiHgN11jnzsMRJC+I4k49Qmi2rMgdgdS+991R
         BzvA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=nJyMAedu;
       spf=pass (google.com: best guess record for domain of batv+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u10si30443003pgj.588.2019.07.29.22.52.44
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 29 Jul 2019 22:52:44 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=nJyMAedu;
       spf=pass (google.com: best guess record for domain of batv+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=k3bbbqY8SIpE+YtEyLKkL7nQbVMolk+8sJNIxeAyNQs=; b=nJyMAeduK8LG66+Pj2WeaytZbG
	xzLQEs/Ur68eXNkEnLP/PeVHu4eh0yVic/AKDubVQKjRAHi/bYpCnoosOa8bcr6iZk0Sk54KJaba8
	9Uag79Xi/RoTto8fireq+1CALH/p/Mcwk5OXvuzuJsKdnQ8vZOR45bbIePA6BhSRgG8FxDuAz2xhk
	vKKvbCrM8UTrX50m92Y67YUdnwUyRM7yXTAHKJiht9FyXmpFAQOfDj50ghBWQ5wsSM0n8+vG8Evft
	Xfu9Iubcx164Z/0z9UN74qOt2mRGQsaQSRns7sQryNc8pM94Gb2EmcBrP92lmi1qOClFXzOyicOkL
	eu6L7UWg==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hsL3x-0001L0-0Z; Tue, 30 Jul 2019 05:52:41 +0000
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
Subject: [PATCH 09/13] mm: don't abuse pte_index() in hmm_vma_handle_pmd
Date: Tue, 30 Jul 2019 08:51:59 +0300
Message-Id: <20190730055203.28467-10-hch@lst.de>
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

pte_index is an internal arch helper in various architectures,
without consistent semantics.  Open code that calculation of a PMD
index based on the virtual address instead.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/hmm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 88b77a4a6a1e..e63ab7f11334 100644
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

