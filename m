Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19737C0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:52:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C8BE320679
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:52:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="P6NBNZSe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C8BE320679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 702688E0008; Tue, 30 Jul 2019 01:52:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B1B48E0002; Tue, 30 Jul 2019 01:52:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A1298E0008; Tue, 30 Jul 2019 01:52:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2664C8E0002
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 01:52:28 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id q10so16657805pgi.9
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 22:52:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=bXbV3qDGfzrx7WoIjFecJlqT5ZuyvFJhVzdpdqMjsLk=;
        b=nx8DrTsA/xwkeUUJ5F0ScQNTkWyeRrWuuiR9cnNWSij8B/Mbug7Eh4Rze67l8O1o9Q
         YjFDc/AUOzoVcahnmK9ohcI/r+nbi48aT5n5DcZbOkqoamk3Z6DMk96ouhrLheyMYNwS
         yD1RSNo8UF+qqMuKhQtB0ZvgEA7TQL6URIZvY8MqRsZ5rbP0at3WXA9abNH1H+fYSUBv
         glVlNK7CI0pWacc46I42uadA0FMSeYWaxzdr7usR3ZdQsQ4GwKBGpv3NUl7Whf/62gRj
         HJzlUjm4r+2XfyLoZ1o5K8iqq+KHWdbFgT6u2P5FeMPrRvoAb9QWtRjZzeco4HuYKzJH
         +m5w==
X-Gm-Message-State: APjAAAW9624C2kj6coCpa3PORwMDDenMJP34Eah4tuPGccA9OtrHZuMf
	sy0kFAvZEZdzASUucugLnGmGOnDMOEMlCUllOXVL3RqExB3tE/SwrZvLyjep+REEK9N22Omk+j2
	sNMBPr0ve4PUK9sFOvdkOs5NyuDNn4Y7Q9AyMv8nbffRF5ur0XlHKALnFSlwgtqU=
X-Received: by 2002:a17:90a:b883:: with SMTP id o3mr114321090pjr.50.1564465947831;
        Mon, 29 Jul 2019 22:52:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzmF6zSesJvAvv+ZJr+RzaaBHybMC8H5beN4oIA4v//0lzfZ1axmCT5uTJoRYXqZ2klkbG9
X-Received: by 2002:a17:90a:b883:: with SMTP id o3mr114321036pjr.50.1564465946830;
        Mon, 29 Jul 2019 22:52:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564465946; cv=none;
        d=google.com; s=arc-20160816;
        b=zVvzmJceRJ4RoLMZXc0XjzswBrUh2aCRmfvVpfjCHlPeIRi1FLnhYr8bDu7JTvCoRY
         k6+HbNfdj0faieYZ2eoiX9ZFC6jGRDb0Z+SLUOvBc2jta/jbSWKToTSRsp4p5bLP6W4r
         1vLKVFSXrP4jxBbsOYscrBBJFtlwN3ceg9PNpTPdZW56Y9AxQ68Z5Y/hEH/9/kWOuISM
         2DybESVypd8HxRJgmSChAEqJtnPacb9VX/3TL7Z+yq76RHidIrY40OFevucVfd7gxL8/
         USTHIR3wFctcWZpoGyYwZAQbH0CI7ZmbKXqNROBdiD5cQ5wDm8tKR19OtL6fMCoPKL6A
         nl1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=bXbV3qDGfzrx7WoIjFecJlqT5ZuyvFJhVzdpdqMjsLk=;
        b=RyOu8xgx0Z9Vor9e2eWdRaTjX/lSNCwKnGN16CZphwvrUmqOefziALtFnqeCj3gl/W
         XksREsB0644I7niAiZyMRea5RHRf1ogtUu5FUmyZNof7kPnbK1NO9KTeVgQ6456eM4Qa
         WzCJoLyoy96PBnAXbOTbwXWFh0CpJiTEPH6WPr4lFZcrFXMBLmMBE7sEw86aazNe6cdr
         4YLxvMTPX7QAL+D915Ye1NvrWVzicMuVjFImMMDWe7UPMkaeseMZDJ9nHyPVGaOFuhyc
         /BwajkFGqc/d827HTh/aQIxYOcn+pWt+pV5uvgfTxLnwXnqCPDmxpB9tkaVDSlAsTOjS
         mQvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=P6NBNZSe;
       spf=pass (google.com: best guess record for domain of batv+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m15si31980512pgt.495.2019.07.29.22.52.26
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 29 Jul 2019 22:52:26 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=P6NBNZSe;
       spf=pass (google.com: best guess record for domain of batv+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=bXbV3qDGfzrx7WoIjFecJlqT5ZuyvFJhVzdpdqMjsLk=; b=P6NBNZSercDK8PYpn8hH4MT1dI
	LpeRr03gX2BviYGoHk1vN9m29L2aP2JhMjHHKYLSgQm/itVvfO8okrbldueEpgHoKa86lEIRMpOb3
	Vadg+4NxBVvm9X02muhLuK9XEa07t1zyqX82xhH+XnZCyZUzTvEDSdfex9WY0BKYXunC85J5XmVjC
	h+fn0T7fEHa9Kh7H8LMhMwKH6XegmVI8DqDmLPtmEV4p+LQ9BAyqkcXhjbIGixsN6bXWtF7i7uc2Q
	6n/rnpFHFsp8rPWmIOvJj+RA9WpDkFQkiAYcd6WMzaNCgY+bK/6n3141sAZN02rOHPPE+SpY+MKVp
	HCEwdPvA==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hsL3f-00015T-Jl; Tue, 30 Jul 2019 05:52:24 +0000
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
Subject: [PATCH 03/13] nouveau: pass struct nouveau_svmm to nouveau_range_fault
Date: Tue, 30 Jul 2019 08:51:53 +0300
Message-Id: <20190730055203.28467-4-hch@lst.de>
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

This avoid having to abuse the vma field in struct hmm_range to unlock
the mmap_sem.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/gpu/drm/nouveau/nouveau_svm.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouveau/nouveau_svm.c
index a74530b5a523..b889d5ec4c7e 100644
--- a/drivers/gpu/drm/nouveau/nouveau_svm.c
+++ b/drivers/gpu/drm/nouveau/nouveau_svm.c
@@ -485,14 +485,14 @@ nouveau_range_done(struct hmm_range *range)
 }
 
 static int
-nouveau_range_fault(struct hmm_mirror *mirror, struct hmm_range *range)
+nouveau_range_fault(struct nouveau_svmm *svmm, struct hmm_range *range)
 {
 	long ret;
 
 	range->default_flags = 0;
 	range->pfn_flags_mask = -1UL;
 
-	ret = hmm_range_register(range, mirror,
+	ret = hmm_range_register(range, &svmm->mirror,
 				 range->start, range->end,
 				 PAGE_SHIFT);
 	if (ret) {
@@ -689,7 +689,7 @@ nouveau_svm_fault(struct nvif_notify *notify)
 		range.values = nouveau_svm_pfn_values;
 		range.pfn_shift = NVIF_VMM_PFNMAP_V0_ADDR_SHIFT;
 again:
-		ret = nouveau_range_fault(&svmm->mirror, &range);
+		ret = nouveau_range_fault(svmm, &range);
 		if (ret == 0) {
 			mutex_lock(&svmm->mutex);
 			if (!nouveau_range_done(&range)) {
-- 
2.20.1

