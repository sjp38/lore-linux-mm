Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4837C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:06:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66F2220818
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:06:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="tzhuPYOZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66F2220818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 795306B0010; Tue,  6 Aug 2019 12:06:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F2D06B0266; Tue,  6 Aug 2019 12:06:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C2C96B0269; Tue,  6 Aug 2019 12:06:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 18EB86B0010
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 12:06:21 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id g126so8667632pgc.22
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 09:06:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=CFSretyqs/RdirX2o42+13inYYFm9UN8GL7VmbVQVoQ=;
        b=OEVC72W/wPNJivIBWfl/q5FIUJlOggKTGRSnbDJfTRbLIWYa/5dJ/Df0r/H/EC0m4/
         82CBAdQcOGFZ57Vsshj3rCzqLtO6ZjB7BwjK7xIVHxoeIScOLaARW/A1F/GqHo0kCxeI
         5HetvPBwt9BVax0zceW7fHdj/gb1gVmuQGBw/z4kjmfRW1LaMe07ImOmWAJkM5Mrtfhi
         XehUULuPetkXF2zGsBUx8imbyfUVcXVl4ZM4uLByVVpvxIRJu2IoGkbhId9F8znixBnX
         +QPJpgXBKwmiiH8OJHtclhp/MNG1j2AXUR+QNoC6pEP78627+j7aNZj6M4y1AqckKSBM
         TbQQ==
X-Gm-Message-State: APjAAAUm2E9TbIMnpw4aKFL19LgOsLodKMQYjYIcj8HpFLxvlkGUAF5U
	eayiIzeVcG2Klz70c7ONGE5CASGpSu6hbDhKh541yhNmvj9a6/rFP3GdQ5Pun1q4XhPGl1cwoK/
	t5Xx+3i5opnlpHyEYeVat5As9YHkdMsqvo904OOvEr9Rr49g56PJ3Ozmod5h8/DM=
X-Received: by 2002:a17:90a:a116:: with SMTP id s22mr3928119pjp.47.1565107580757;
        Tue, 06 Aug 2019 09:06:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwV6wE0WRtrlet2OaHfJIHmB+UUj7K0ktPa9zlRBlvnBfAQD7eUPz4xU2Noahfo75IrUrX0
X-Received: by 2002:a17:90a:a116:: with SMTP id s22mr3928061pjp.47.1565107580004;
        Tue, 06 Aug 2019 09:06:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565107580; cv=none;
        d=google.com; s=arc-20160816;
        b=c1PPNqceBHUT2K0dHzM3bHhdVIJW/67GnQjoyJrwpaCvHSEpV6AHGxbK3E9BKQUGqR
         jBsPTBEwNmLp2T2aGM77utsjt56hTvm4O38PunFLRgvDj7yjFX098IRdm9PNW+6kI0T1
         VfMpzCdaknnAL+p7MTdyQfi+xC4FD8Uqb+bg6zDhEzUeQGObUeQnnvcyGKRP/I5BDyPs
         5MHsN4ken1dZ6PMPXcDk9doybTJqY9drOc2u8ww0NS9cZKDKFuA7EmAeD9HRj6jibN2+
         7mGG/4Xi9sz0iSWv5YVGE9UOuaF8vYjlHfXfjjcRmTd2vSx/B+rsHG58sYetzA1Ry0t/
         UAxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=CFSretyqs/RdirX2o42+13inYYFm9UN8GL7VmbVQVoQ=;
        b=MRepd75gEOlzTggA3b34GuO2tooh9YaEEAj5giNNLhuysmP+O42g0GsfYLFkg6aJWn
         kSxiOpcg9mHCp7dGUUwE8M7LgRHEJatD52hzqnHGENYiqL2qx//iW4wzC8mPlSA+4H3F
         5FdrrR8a2LiyA7dQwwJ3pBzbKGAb+HpTEAC7ssQeRiVPMCcvcxt2BBxmGcomrh/hWHNa
         y+7SqK88v/qillWp+WP2u2JD2shMH8Sp0Fc8IuaMRF9WL9iJRWKmlnUNIIDobvPk5fyF
         +hjStGogSlq+jcpbyjr+LNEQx4rgfSJVCr8Xwuopln7JJIoO75e6Yt867a+WjTH9PK4R
         FEDg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=tzhuPYOZ;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y3si15502587pjv.50.2019.08.06.09.06.19
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 09:06:19 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=tzhuPYOZ;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=CFSretyqs/RdirX2o42+13inYYFm9UN8GL7VmbVQVoQ=; b=tzhuPYOZCfgFbsA9DJibfh/0Jh
	woYpb6mEK7ChEy3EQSIGvnXDPse4koxKMp2IVNjgzLQ6T38WsL385CiPX1vHD2Jucbed+H/5Pu4lp
	H/90sdP/K9vSYZY7RNildl5jevquWCkAzhbCbvPIWLnT8ZyEjqMSz1km+VUCFKhynvVxvf7KPyJzg
	9mcmtQVc/phVgwX4EZ1FmOwnOHVrXcWWe9j1QCmpobC8EUhF4daYBvAmBpQimWumDoicwaVczgeco
	1Y8lm/34Pe/d56aQqfFjYbBd3j92PHqKQzIpa9qOWRMFQHFJdLuWEV9jOHRkdM2ZEkyYHq03VPBtC
	QFOhtlvA==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hv1ya-0000aD-R6; Tue, 06 Aug 2019 16:06:17 +0000
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
Subject: [PATCH 08/15] mm: remove the mask variable in hmm_vma_walk_hugetlb_entry
Date: Tue,  6 Aug 2019 19:05:46 +0300
Message-Id: <20190806160554.14046-9-hch@lst.de>
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

The pagewalk code already passes the value as the hmask parameter.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/hmm.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index f26d6abc4ed2..03d37e102e3b 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -771,19 +771,16 @@ static int hmm_vma_walk_hugetlb_entry(pte_t *pte, unsigned long hmask,
 				      struct mm_walk *walk)
 {
 #ifdef CONFIG_HUGETLB_PAGE
-	unsigned long addr = start, i, pfn, mask;
+	unsigned long addr = start, i, pfn;
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
 	struct hmm_range *range = hmm_vma_walk->range;
 	struct vm_area_struct *vma = walk->vma;
-	struct hstate *h = hstate_vma(vma);
 	uint64_t orig_pfn, cpu_flags;
 	bool fault, write_fault;
 	spinlock_t *ptl;
 	pte_t entry;
 	int ret = 0;
 
-	mask = huge_page_size(h) - 1;
-
 	ptl = huge_pte_lock(hstate_vma(vma), walk->mm, pte);
 	entry = huge_ptep_get(pte);
 
@@ -799,7 +796,7 @@ static int hmm_vma_walk_hugetlb_entry(pte_t *pte, unsigned long hmask,
 		goto unlock;
 	}
 
-	pfn = pte_pfn(entry) + ((start & mask) >> PAGE_SHIFT);
+	pfn = pte_pfn(entry) + ((start & ~hmask) >> PAGE_SHIFT);
 	for (; addr < end; addr += PAGE_SIZE, i++, pfn++)
 		range->pfns[i] = hmm_device_entry_from_pfn(range, pfn) |
 				 cpu_flags;
-- 
2.20.1

