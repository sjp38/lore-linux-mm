Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 575E2C5B578
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:21:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D3F5212F5
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:21:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="uEwsBCXo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D3F5212F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A1158E000B; Mon,  1 Jul 2019 02:20:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 202CA6B000C; Mon,  1 Jul 2019 02:20:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A62F8E000B; Mon,  1 Jul 2019 02:20:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f208.google.com (mail-pl1-f208.google.com [209.85.214.208])
	by kanga.kvack.org (Postfix) with ESMTP id B55806B0008
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 02:20:56 -0400 (EDT)
Received: by mail-pl1-f208.google.com with SMTP id x23so3812017plm.19
        for <linux-mm@kvack.org>; Sun, 30 Jun 2019 23:20:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=T9L9b2qHusEgYVnEV0zNHhUWzUZ4CrAFpQ1lfd/2V3Q=;
        b=R2CtMxN0iKk/P0+utSi2Fd3CG+ti3VKT/CXeUworAaUeqe6d0EQ6aYnbP+MInnyaTs
         oJlTibEcntEcAjCXxHQGdlxYNAzvmBqAsM0pPO7gdhgiTCRSDhU/ReNj4MUImq1DBxgP
         jiN28ErEA/4ijNz27iCPdVTf74h+93IW59SE6ezSG2oP/0fbGKOQdSfY1BfGfjhWW2vF
         7/JjDqCtKHCWnBPCi7Vq/LdMF7jZqu+KWPcyUjDc1OF4Q2CXD2t2WXiCeoE2or2cyDHx
         J+cQnmawO86BXKonBtEQAJyB5KkmYI+1dJHXB8hl9FIZbfsvMxRgUvK7AomwoeVeF4XC
         vWWA==
X-Gm-Message-State: APjAAAVL25vnbYBYIIm/MQe95IdXwyCmDGpD9zhJZes1DOcv0nN2cCuH
	1bk53OGLsjy+cFBVB/4UXX1WIgo/bO0rMhVxIfubTrbV0t3Uh/4Gtjbu3XavAbbjoUMg+s9Gi3+
	EG9HYlco4feVurXk7koTn/EUkkKH/sQCs/7FYF01dxEKtDMfbYOcOoGfxy4zVleI=
X-Received: by 2002:a65:5c0a:: with SMTP id u10mr22668608pgr.410.1561962056293;
        Sun, 30 Jun 2019 23:20:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyyYkl7tdBJ1VizhVKFUii14axtj7Y3/t7Fr76lfZULpscTHHGAAbo+hXo7hoc93/HTLREq
X-Received: by 2002:a65:5c0a:: with SMTP id u10mr22668551pgr.410.1561962055432;
        Sun, 30 Jun 2019 23:20:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561962055; cv=none;
        d=google.com; s=arc-20160816;
        b=uMWjLzR4/VI9Skh7gsRnXKgzzAKFI457OP9AmEx0++Z8tsHlqnil2pEZg5G5+n2gVq
         PLfY1uocqkC9RJqCIcOlDRYi4bq/NFvk6YIkd+PIdsEI3l75mxh4tu3/vktk3FFWagGC
         7XAZ7PhlRhqWPuRsKBk03+6Okp3ZJR2lK5p3PhT5QLThqvUYsX24KoQIw1Q9Lm1+41Cq
         oUn2Wiqs19465gsEVTvvuGhxkm3KAJtakpYM7iitdUFWbmgmpujqvm4cPX+ExTj2673n
         AlILsEfm8yM8TaemAXh7WaJPkTp5iZBzG90xS4elSIx0GTLvHTH9sj4R/TMhih053oSG
         AK7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=T9L9b2qHusEgYVnEV0zNHhUWzUZ4CrAFpQ1lfd/2V3Q=;
        b=gWFwThIv3SZwaRvBvlxZOqk28xu1S0fdmLrJOhVdfBtCQeI32b6k3R2Gf9+uDjh0jW
         +k1KnMnddVuk5jamODnAV0jbVOsBfRWpikgIY+WGPexhdGdPbvcqRhqO9nOmves5hrun
         wrhmlzuatIoZduAUrAjhP2SzSSm49wohn+6zxTRkYnCuzib3kd2ZZ5yCwUr3j5lyQGFZ
         rcujpI2Kir72MFzQrlHtnlnLGB4rS8Ya612y1Wd0ZHrSsH9i3Kjl7j3u2Vm3t3GyAaba
         B6ttVPu5pXIwQscAYahB7dpw46g91Zhm5g4UCgYrg3Hn8+QHDW57EF506GCCiOGPpGal
         KsTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=uEwsBCXo;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a64si9299919pla.432.2019.06.30.23.20.55
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 30 Jun 2019 23:20:55 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=uEwsBCXo;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:
	To:From:Sender:Reply-To:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=T9L9b2qHusEgYVnEV0zNHhUWzUZ4CrAFpQ1lfd/2V3Q=; b=uEwsBCXo4kNVg1cdlTcZ6OQwT
	V77aSF2koYFI6fO6vmNmbj1w3NL5OsxXP8Se91mN/ixPBJrvWQUc7JNf4j04wFaAqTbKyFXgGLWRf
	wPuUarztGE18wV59Arf6P/hupXGoCTIBqLpufaY8xaGdkdvx/Q8VMLVv0tnLHEQJVeopYpSBh052p
	5Q+aQ3mlTS3dldfsf+ivaqpsFy5r8m2ioQmXyGeCdmrlloPdTFiVHFGaXTy7FbYp2E6CesRB0KFie
	YdOBWrDVTPdo++UTICIQeUq8omxGj/sgWAsDoFZS8ib0Snh1C8z7FE5HiEOrigdW0jlsGYSDAMqZF
	uRNOJPWrA==;
Received: from [46.140.178.35] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hhpgK-00032M-0s; Mon, 01 Jul 2019 06:20:52 +0000
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
	John Hubbard <jhubbard@nvidia.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Philip Yang <Philip.Yang@amd.com>
Subject: [PATCH 13/22] mm/hmm: Use lockdep instead of comments
Date: Mon,  1 Jul 2019 08:20:11 +0200
Message-Id: <20190701062020.19239-14-hch@lst.de>
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

From: Jason Gunthorpe <jgg@mellanox.com>

So we can check locking at runtime.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Acked-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Tested-by: Philip Yang <Philip.Yang@amd.com>
---
 mm/hmm.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 1eddda45cefa..6f5dc6d568fe 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -246,11 +246,11 @@ static const struct mmu_notifier_ops hmm_mmu_notifier_ops = {
  *
  * To start mirroring a process address space, the device driver must register
  * an HMM mirror struct.
- *
- * THE mm->mmap_sem MUST BE HELD IN WRITE MODE !
  */
 int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm)
 {
+	lockdep_assert_held_exclusive(&mm->mmap_sem);
+
 	/* Sanity check */
 	if (!mm || !mirror || !mirror->ops)
 		return -EINVAL;
-- 
2.20.1

