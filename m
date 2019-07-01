Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF9FFC0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:21:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA0D2212F5
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:21:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="lwamREa5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA0D2212F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2C5268E000C; Mon,  1 Jul 2019 02:20:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 22C106B000C; Mon,  1 Jul 2019 02:20:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A0DE8E000C; Mon,  1 Jul 2019 02:20:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f206.google.com (mail-pf1-f206.google.com [209.85.210.206])
	by kanga.kvack.org (Postfix) with ESMTP id C19B06B0008
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 02:20:58 -0400 (EDT)
Received: by mail-pf1-f206.google.com with SMTP id u21so8210323pfn.15
        for <linux-mm@kvack.org>; Sun, 30 Jun 2019 23:20:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=icobwArBtoR8ReDHxdM0OSV/BylGVPj9OXDCrOjLCSM=;
        b=HaLt7YHy+kNwyWYyo7mmijvXFP8GaisviMfUZzvjouOs14saiVwLbIBCM+iWK0F/D1
         Hu6S5Bi3/nG+wd1hUFJRsqzIeF+EzUK6slfFdSq2zsBQr0Q2sWpophHoUI5zrgZ48LVW
         RZBXqihN7pUsrfFq1AEAa0bhgcEjZjzAypMf8mpphP57V+T5kfiGLv4kXoaVTyuVT+Ho
         ZRc+5lQQCuA6sKWbEIy9PQ5a/CXwZOrVkNoM58pK0KC4E0uEsNe5Ag9CiAql4X4VLGV1
         1PMtA9G2gEkXW/VygfW3HQ9zxa1wHD5UTR4xOw2cMuzIw1+7aCH8Nz+3XAc674Yc5VRw
         gpfw==
X-Gm-Message-State: APjAAAWE0Eb2+KTWnS2JowBwbUBI2aPKuAv88pEIkLNkDjyStliHtAyJ
	otPmcsUIJkf3UhLZknFUpkdWRiW5GOxb0CRoKWlTmgTqjn4B6kfDCRKBY+hSojZU/RjmBGzrKVl
	IsS6HEgmZrq6wZttX1SCqL7MtR6ywqag/5bDkrP9kHtFH1uMKpoF5p82UVj0D5Og=
X-Received: by 2002:a63:2606:: with SMTP id m6mr10978102pgm.436.1561962058391;
        Sun, 30 Jun 2019 23:20:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzqIFyfBu7TrJQgk14jpwIUul48UZScbYOeiiaUoSrLbZ8ernK3R/tGEBxZLQGVI7TpvELH
X-Received: by 2002:a63:2606:: with SMTP id m6mr10978049pgm.436.1561962057662;
        Sun, 30 Jun 2019 23:20:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561962057; cv=none;
        d=google.com; s=arc-20160816;
        b=Dqb/3MoV8Op4u6KT+IBKl6Qe0sOoSsSevgCO6yh7Vz4VUtny9o8rw2kIeucy4/hXdI
         93amticBT/SBE4WW+WBTu6UEUqnHaosPDb1aRslVkG3eNjG1PJfnKE4BkgheeKvjXjKj
         MfFw65aMVc/vsWHR46PR+o5Nf7Gkfa7Sp5oF6haayU4MupGp/eu7xW+Ysr5bECLnUQTv
         nGwL4Q8BsSwUVMej7WaSqZjBmKY03fUTvj6jlzhH/tKhtEeO1erbzIT4uSPFNZDh4WVT
         zpm5ssd1axEbcBjT5sny+iAnGRpb2LN3SjnOfDBdCz8XQG0b5HOixh9S8sQLxocu1Cff
         LlUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=icobwArBtoR8ReDHxdM0OSV/BylGVPj9OXDCrOjLCSM=;
        b=hsMyN3/y+X3wZvqYXt3BSBC6v0GzYjhFv77i8Ke1mhEcQ2Xz+xQdxDMOlKQi1HU15O
         xw6bcMbcO05T6EoIOVFSxelJFVuUiEg9Rg4UqHqoKKltgboesflY1bk4QyAvV0xsy10E
         42seFYKSvd5z8OH+bfHl+cRCpJZgOXLIXpHYmzwet7CowGSu2YEp+KLeKczrZvD7nQOJ
         2MGBDAgdwMw9hVxyPzLBp2WU+j2NOSpLz1waTmh/UDbE1mPloXEcoKUkMbSKNoXZ90vM
         tFbb2fVMkS+4I/cu5H0euMLlghvJsSp6mX24vvIdCuZ2+xjEYKkAi+bmN2xpUKIHNbzu
         Ti6w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=lwamREa5;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 95si9916798ple.51.2019.06.30.23.20.57
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 30 Jun 2019 23:20:57 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=lwamREa5;
       spf=pass (google.com: best guess record for domain of batv+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+bb02ddf78a79a38d855c+5790+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:
	To:From:Sender:Reply-To:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=icobwArBtoR8ReDHxdM0OSV/BylGVPj9OXDCrOjLCSM=; b=lwamREa5NpF4Qy4jd8BtxYQJa
	nM99VD+71jHSg4TsNOy4V5G/VKSIbY7ElfpDGBN9sHF8BUifq4wO1dXZmE6pBZ4vL7wLR7K8dZ/gx
	6SulrBoI6nnYyGZydRsfQjI68/LqnectAYeHOE8Xn2orshZkeo9o8NZPwuHmQlHIEeAeqX00o+USL
	R4PXEYmlglHfipdXdcexTu/a3rT0JHtQiFUQO7u19oa9teCY4agjpix8VB7C1Umr4kK5eQIt5Pxsf
	rXLjXGbbtyfO/TWua4uZNeT4G8Lrq7IN8aXw4oJyDXtZLqX1hx9G3HmFSRTa30Cy96bwJq41j1Hry
	Xbg6lO60A==;
Received: from [46.140.178.35] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hhpgM-00033L-98; Mon, 01 Jul 2019 06:20:54 +0000
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
	Philip Yang <Philip.Yang@amd.com>
Subject: [PATCH 14/22] mm/hmm: Remove racy protection against double-unregistration
Date: Mon,  1 Jul 2019 08:20:12 +0200
Message-Id: <20190701062020.19239-15-hch@lst.de>
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

No other register/unregister kernel API attempts to provide this kind of
protection as it is inherently racy, so just drop it.

Callers should provide their own protection, and it appears nouveau
already does.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Tested-by: Philip Yang <Philip.Yang@amd.com>
---
 mm/hmm.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 6f5dc6d568fe..2ef14b2b5505 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -276,17 +276,11 @@ EXPORT_SYMBOL(hmm_mirror_register);
  */
 void hmm_mirror_unregister(struct hmm_mirror *mirror)
 {
-	struct hmm *hmm = READ_ONCE(mirror->hmm);
-
-	if (hmm == NULL)
-		return;
+	struct hmm *hmm = mirror->hmm;
 
 	down_write(&hmm->mirrors_sem);
 	list_del_init(&mirror->list);
-	/* To protect us against double unregister ... */
-	mirror->hmm = NULL;
 	up_write(&hmm->mirrors_sem);
-
 	hmm_put(hmm);
 }
 EXPORT_SYMBOL(hmm_mirror_unregister);
-- 
2.20.1

