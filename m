Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F5AFC31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:06:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 20E7320679
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:06:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="IOHXbjZx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 20E7320679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A51336B026B; Tue,  6 Aug 2019 12:06:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DAE06B026C; Tue,  6 Aug 2019 12:06:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 82E0F6B026D; Tue,  6 Aug 2019 12:06:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 44D7D6B026B
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 12:06:31 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id h5so55209698pgq.23
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 09:06:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=YRRjZVhDBKVOH1jTuQF7A3O3z8BLVwvvxYuFPnL2EoU=;
        b=OV+SB4mL+2yS7O0CS6g+59OAxKqWZaj6loH2TDiTMHkvuKyviOM9r5pBIZimYNzaVr
         Ip/lzX41Aw3jH9NrDq1JJb1aKw8OIw5SrXkpmc9l6K7LF0dyyndcWufTfEo34IqfnB9a
         zPkFTn7bu+Ai4hOvb7d3pGsEOm92Zk8yXS5TWf1EcuDp8+WYDWMV3mtUTohR0OleRV+R
         6l9fKEuxXa8metAAHqkQQqEc3a2BbFowzVqF47LZjEFaPFlVPaPzHq51OjNOdLgfluXX
         qcpv3a3RV+XPzG6+O+v8R6LHrkPeM/PSuVZHn5abqkb7X5Z/IcFfqjIzmLamIhjkcXKm
         OYqA==
X-Gm-Message-State: APjAAAXl9VUiqPFSjCG/rCKa+lzR00qpu+vvOuq8xO/uoSEfuCS1Qd/p
	AeCawURcWDzpXPALZvUAtesr/9DaDqQ7p9ABsgFNrpiSIAwPSnETIL4yocAvtLCNyYvm3ipJO8X
	mRgCKE+f9WFjenriZqJ9vSn6nsIlPyBvN+dDqHzC0KbxCrleBErylA5LPSEVJ63o=
X-Received: by 2002:a17:902:7d86:: with SMTP id a6mr3875879plm.199.1565107590969;
        Tue, 06 Aug 2019 09:06:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyybXj0HhsebtVK7l7thd2FsQgcw5rE/FL8QZmEUyGbRDCa3XqxF4UHXoUjehGRISiXE4S0
X-Received: by 2002:a17:902:7d86:: with SMTP id a6mr3875811plm.199.1565107590122;
        Tue, 06 Aug 2019 09:06:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565107590; cv=none;
        d=google.com; s=arc-20160816;
        b=m0XWy9jc4O60lsZnMlVRGrtPXYYn/tLRmlvdngzp3sZ1vDvHQW26V2jHQwPuuiOLzF
         wXqWNOkgqL2SWtrutdPCGVWLzWLzrC64gLPcv09nGUc5hRYx3ZqmFb9x9RfrY4BHxIgz
         5FmDRNglvO6QQCk9Gnyz3UebnWF0MyEWa7DsvHtjPAY/fsIBBAZX25SOqP7WOvKSHWcT
         I3893t4seITrdIJU0KAxdWo5hihlZja9OrbpzjrKNBYVipgY+O6nKtFsOUfgn2rq7D1N
         tnCh3LvBpcQFYceR0hW+aekYOEW6Du0STjKLe2YD0unfj858uuwY7yzzERHtlCz1Fujo
         +U1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=YRRjZVhDBKVOH1jTuQF7A3O3z8BLVwvvxYuFPnL2EoU=;
        b=0Hs1naj2N74wLmme0CXywz4qPdD9jJ6wBW9OdSlAqP1w/ab0yoGh22fwhYktN7QW1G
         TypCHX+iRh3YXTtVEftUNBw13trenpHH5pb2TZtvWR0rtEV/5KK6u0HZ1TelA50PbcA4
         M3J7L9jB+65qEOkaGkyIBHqGyR2FzdyIawKv3BQ2Fe5EovstuxIlN3D6l5t4lUVGwsMB
         2jCJWKDM6Tm93XHAvbn4YOi2+3ogwePhOSGiW4o+D3mZMKO0zpMDLH/mJ1BFSYbVpw09
         jk4NemLoBawdFBuatqSlqHpoCLAlvMuIKd3RkGYnt2RSLOCiFUQRZq67ZCSnqRxKcHNN
         Ssdg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=IOHXbjZx;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 68si47208672pgb.104.2019.08.06.09.06.30
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 09:06:30 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=IOHXbjZx;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=YRRjZVhDBKVOH1jTuQF7A3O3z8BLVwvvxYuFPnL2EoU=; b=IOHXbjZxSo82prtQ4bNa7kyk3F
	ERoxF4OGQgr4Pywg2DaD0Fxz1thwKfufBvzCaB2SwknrAvMue4z8IwQDnfIS7C4dAIUE8D6MTBuSI
	TchmmS+U2xN96UVExRPZkKqdgBDJuV4HpexZYppF7x90Fp/azYAP4RG/FK+ihZw9+RcMPOc6lKJbb
	0918M0qgnb9VPmscGzQmtBWlAFXzEp561MFwTV/2Aldr8SoEMk4DlcqiqHrPlS2N7xv/WHPKtkInz
	9Zn5COJcEiL1EXqqFP+SaUI5SeOLPANFuORCxuyIops6El+WaLmnA1TRSJ4ubesVQF6Cwg5OX2of2
	4XBWzr8A==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hv1yl-0000cx-0P; Tue, 06 Aug 2019 16:06:27 +0000
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
Subject: [PATCH 12/15] mm: cleanup the hmm_vma_walk_hugetlb_entry stub
Date: Tue,  6 Aug 2019 19:05:50 +0300
Message-Id: <20190806160554.14046-13-hch@lst.de>
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

Stub out the whole function and assign NULL to the .hugetlb_entry method
if CONFIG_HUGETLB_PAGE is not set, as the method won't ever be called in
that case.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
---
 mm/hmm.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 4aa7135f1094..dee99d0cc856 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -767,11 +767,11 @@ static int hmm_vma_walk_pud(pud_t *pudp, unsigned long start, unsigned long end,
 #define hmm_vma_walk_pud	NULL
 #endif
 
+#ifdef CONFIG_HUGETLB_PAGE
 static int hmm_vma_walk_hugetlb_entry(pte_t *pte, unsigned long hmask,
 				      unsigned long start, unsigned long end,
 				      struct mm_walk *walk)
 {
-#ifdef CONFIG_HUGETLB_PAGE
 	unsigned long addr = start, i, pfn;
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
 	struct hmm_range *range = hmm_vma_walk->range;
@@ -810,10 +810,10 @@ static int hmm_vma_walk_hugetlb_entry(pte_t *pte, unsigned long hmask,
 		return hmm_vma_walk_hole_(addr, end, fault, write_fault, walk);
 
 	return ret;
-#else /* CONFIG_HUGETLB_PAGE */
-	return -EINVAL;
-#endif
 }
+#else
+#define hmm_vma_walk_hugetlb_entry NULL
+#endif /* CONFIG_HUGETLB_PAGE */
 
 static void hmm_pfns_clear(struct hmm_range *range,
 			   uint64_t *pfns,
-- 
2.20.1

