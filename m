Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9695AC0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:20:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B0B9212F5
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:20:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="mMtjeXqR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B0B9212F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A8E7C6B0005; Mon,  1 Jul 2019 02:20:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A15C38E0003; Mon,  1 Jul 2019 02:20:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 86AD88E0002; Mon,  1 Jul 2019 02:20:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f205.google.com (mail-pg1-f205.google.com [209.85.215.205])
	by kanga.kvack.org (Postfix) with ESMTP id 504EF6B0005
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 02:20:31 -0400 (EDT)
Received: by mail-pg1-f205.google.com with SMTP id s195so7029629pgs.13
        for <linux-mm@kvack.org>; Sun, 30 Jun 2019 23:20:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=UlLC8XGw3CfveOE+CE9qUf9ABEe6OmzNIUUnRKazXzE=;
        b=a6zZAgdD5MSxgTyzTRG6Dv+8/RKbXKdxLd/EOIE89+EwIC+o8QaOTOO8h8vMF7dWWf
         O+BAK6DRC0nZ86fJaiH8BZddo6PnRadNDJDkIF+W5cpKnUi9oEUwihE1d3kbLRjeNMJd
         A/xzXKNME7HknhMPSV5X92JfuxA+Fj7P9PIMnDT+TttpESDxG3as9VjCsymSsH/1a5mb
         uweAZHl1r8vcz3LAe9OUjWPF/SgtLOxEyjXCZk00hQOV2uu9XcdLOCMJm+Gj1iDOR2Hw
         UQ6fepdsoXb74vvNPTEuuHZ27ZXm3CdxC3WpewtHax6R/nPT+gOib6frWYNNZ0Spbc8M
         g5Hg==
X-Gm-Message-State: APjAAAXPeADAKAb1WK6zoyiqtn6gpLYBseXwejPkfK2TkW7BS7A1v1NU
	o0MfzL/aJX0hurBXsVWcPFx6XMhA6egeOOndmVNrcs0TlU7QBQ0Fm9ryFKIAFffF3xIc8RYDEfm
	eHckYFVikQbSFUZqzbVZYHUL9rOY3NYUyy7ILkDd7E3jQM6XXHb5G4aFRietzG8A=
X-Received: by 2002:a63:1226:: with SMTP id h38mr22702277pgl.196.1561962030777;
        Sun, 30 Jun 2019 23:20:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwTS3ddx1OCw6k9+mOJ67GmDtMPP+wLRyGayZs1J9hXZjZ0aWa7sDpF61nbBJpD8zT0LENX
X-Received: by 2002:a63:1226:: with SMTP id h38mr22702218pgl.196.1561962029787;
        Sun, 30 Jun 2019 23:20:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561962029; cv=none;
        d=google.com; s=arc-20160816;
        b=gZAk+B+lIGAbIhm17WBkHsuxrftXfWYsSJo0r2ccQEa1LckK+lfr+yNeo4cHWwH8bY
         Y1IeyrQb1xjqLxFe1oNQOtayxF8XEEz+wWJ1J6dt2ot4Eb0d1MiF9ILtUyKsUCXYqUqI
         8ed0m9MBAKOb/FWLsxovITEl7DthwqGCqMpRDa39li6Uoa6QHfuiAMq1exDRjAAj/+tq
         PkQFJRtJESZRnzeWh8UglBvaavkMFTSJrkdNz0f1YQRi7CEJSzyhe9PP5oiTPFVA5eJ8
         fpwnwhNuKhYSCEUcJBKFbIvpOraGClkQ0RYNnev1reLVDPsKjEHkUv2yPE1Ol1mdxUCO
         P+8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=UlLC8XGw3CfveOE+CE9qUf9ABEe6OmzNIUUnRKazXzE=;
        b=CWF+vZaNypqLxVXdgS+cXTODMLVg6oR4ZqHtAQ+5LWM52uXd8vEMoSGaegiMVGheup
         q1L9KOD4brvMv3zvG2qySsZw7BDt8Q2OHPwsYDavV5OnnnqEDyNFT00P4lplxsVOIx2G
         ncNMMBkJwjtPS1F4B4cbxvXNhAXGwbICBUV8a/vw6+giahumzayHwfH3amX8gdzNbCSe
         yczHYYReVBi3rqutD53XMpbM0tDttP8rCn8eHBZDS2hwphsKneTEgw8XGMIlLAPYWWXw
         CnNdC2ENMp0S7PlaYO5SmzQ1IbpSdPJPQaFlYcSzj5mUhUWAgxpILiBRnR8M4ntDRHGR
         YlwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=mMtjeXqR;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s34si9633929pjc.2.2019.06.30.23.20.27
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 30 Jun 2019 23:20:27 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=mMtjeXqR;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=UlLC8XGw3CfveOE+CE9qUf9ABEe6OmzNIUUnRKazXzE=; b=mMtjeXqRDcDlmyLmrlKFtZtdRU
	1ZECHbYWTfCpkYG1u7NxycM68aGZsaYVHMGnG4IQzU0TAgr9BXvJmFLjN1uPnSkkanle0EQD+/cUS
	ysH15a0tARem1UDKd65mwKxipLWalrdQsGtNrZr4Ay04rG8pu2TsMymVBvSIJ23mdukOSrcE5tXS+
	BWHN4YZYUOMExmZHWnv83906SilXzAL2f2pgaif+KbkA2D1AQX1pNsvBi8cwWmL7Fz0f8pQe7JPnj
	XXI8WLRTzHBt3FMBIQfyW16QH39tSa/OW8ex+6Eu1UTsQsmyJMJobkLg5Jcwv6wJjHpb7mHbkiY/n
	MjKn053w==;
Received: from [46.140.178.35] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hhpfs-0002sg-H6; Mon, 01 Jul 2019 06:20:24 +0000
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
	Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH 01/22] mm/hmm.c: suppress compilation warnings when CONFIG_HUGETLB_PAGE is not set
Date: Mon,  1 Jul 2019 08:19:59 +0200
Message-Id: <20190701062020.19239-2-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190701062020.19239-1-hch@lst.de>
References: <20190701062020.19239-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jason Gunthorpe <jgg@mellanox.com>

gcc reports that several variables are defined but not used.

For the first hunk CONFIG_HUGETLB_PAGE the entire if block is already
protected by pud_huge() which is forced to 0.  None of the stuff under the
ifdef causes compilation problems as it is already stubbed out in the
header files.

For the second hunk the dummy huge_page_shift macro doesn't touch the
argument, so just inline the argument.

Link: http://lkml.kernel.org/r/20190522195151.GA23955@ziepe.ca
Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 mm/hmm.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index c5d840e34b28..c62ae414a3a2 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -788,7 +788,6 @@ static int hmm_vma_walk_pud(pud_t *pudp,
 			return hmm_vma_walk_hole_(addr, end, fault,
 						write_fault, walk);
 
-#ifdef CONFIG_HUGETLB_PAGE
 		pfn = pud_pfn(pud) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
 		for (i = 0; i < npages; ++i, ++pfn) {
 			hmm_vma_walk->pgmap = get_dev_pagemap(pfn,
@@ -804,9 +803,6 @@ static int hmm_vma_walk_pud(pud_t *pudp,
 		}
 		hmm_vma_walk->last = end;
 		return 0;
-#else
-		return -EINVAL;
-#endif
 	}
 
 	split_huge_pud(walk->vma, pudp, addr);
@@ -1015,9 +1011,8 @@ long hmm_range_snapshot(struct hmm_range *range)
 			return -EFAULT;
 
 		if (is_vm_hugetlb_page(vma)) {
-			struct hstate *h = hstate_vma(vma);
-
-			if (huge_page_shift(h) != range->page_shift &&
+			if (huge_page_shift(hstate_vma(vma)) !=
+				    range->page_shift &&
 			    range->page_shift != PAGE_SHIFT)
 				return -EINVAL;
 		} else {
-- 
2.20.1

