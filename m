Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15CD0C7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:53:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4096218DA
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:53:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="jAXuPct3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4096218DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3022A6B000D; Wed, 24 Jul 2019 02:53:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 23CB38E0002; Wed, 24 Jul 2019 02:53:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 102886B0010; Wed, 24 Jul 2019 02:53:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id CDCF16B000D
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 02:53:14 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id p29so19441642pgm.10
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 23:53:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=D+fP/F31jlLUpmTEYvyqj+ufxmWFwYqwn3YRw+jITpw=;
        b=mRmWvsJILnIWByTkN/IJnT1II/Ml8UTPaqUsCxCMYiPNAxCDoT8IDMsDs0N79seoov
         7MwsCdxAItheqSV7mvrXaQ3cqqYuyPWlsc6bBNR3ltUGGw6Z4ODMleGQ7l1a4vgN1wFp
         Qk52WBTfWqotlXDmn7q50A2EoMbUIzUFC5M8yc4EkMwn1S3smJbMjF3vSff0S/Bdrzit
         69FYYPK3JaYqd5ry9gNpM3zAGYLwXNXCyoUj5M0pHEPMA2Oc6Ej8eFdyXtnEG9wDDPJ0
         WjhCXhBChNGW+FgHBtZEU1vaCZFYFlmJUhJhK5FveRvmJ2FpCrPkoVmhpZD84Azi9fBC
         DU1Q==
X-Gm-Message-State: APjAAAXrTbYItqlgV5s76PGSdqj2Vr6w/OiRIzF7ZD5rLz80i1P6RlYL
	mbAPzsssqQxCtGi4fS5o5TKlAm0qZwISu7yQTZJ1s0xVxKFvZsMLvkymmr/a+7i9uPWPwWAfIV6
	QOMjGt/UtfSX/at5/mmIgqTYDFyRLabS+pzNtyfggXfCTArvKt6UU0O+gtilOfbA=
X-Received: by 2002:a17:902:8b88:: with SMTP id ay8mr81714055plb.139.1563951194348;
        Tue, 23 Jul 2019 23:53:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz8yTQOoN7mT1HyLM/VGz3ZzH1slzqlU4uIeFadQ0NB4n/DBWtoC8OpFaGWmwYGGthWCBvC
X-Received: by 2002:a17:902:8b88:: with SMTP id ay8mr81714017plb.139.1563951193714;
        Tue, 23 Jul 2019 23:53:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563951193; cv=none;
        d=google.com; s=arc-20160816;
        b=kXEnljG8Setz8PVfHqY0eQJWKR6BZJ6uuDixqAEJVhondCFyVimGtMszbKrqp6wG72
         Nz5zNiw+imagNhA6BlAgQjId/+tciT3kKWnwzl0abibs9zd7V9JylCIpJ9ubwirJ/CNL
         2F6IWaJrrlRsouEKfzWg7FLyQCawXFRnt7i6bKAgSy8gEpzVULG1sELIN5lSCkyKjQwJ
         joZpQMvox8WCFWsy2TO3xRMzWUVFGj6nix272MsjusNGUH9nlRgbL4QBBBUB6OdJa0hI
         SSzjLOQz42A5dSye4LdS734kjkT9JSHfXZIdDQXBZC/w16HtP3kKXZZVmXyqqAse6bp0
         s3rQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=D+fP/F31jlLUpmTEYvyqj+ufxmWFwYqwn3YRw+jITpw=;
        b=HuJPoVYPDfKUzrxto8rWUVGYJ83u1QMURAn2wp5MHjIQ2w9v8FzvBimonHp35z3GmK
         /mQb6j/AXUXjPUIUBbgu0TrGaB+Q65uKrgw6qlHBqzyquizlC0L8QGzZJEeR2+K4Ep+u
         KFK+5bhRVk+r9nVRVIRy193qHF/IUFF2Ef5ulvsQIaRrzxEWvxTIrnQSatsZqhkC9NRZ
         9SYJ6H/pLTXumFx+0PA7BXRwQGwl/OLPQe+t44z6GR8t0atTinGMU3G6u0T3h6450kIw
         boKlips2BqIe2ew9oJ/W/35MSiERG0QMZspHXIsvwoXrTPKiuAPHm+tlF3s1qJ6j7SkY
         A0ZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=jAXuPct3;
       spf=pass (google.com: best guess record for domain of batv+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g12si12313094pla.363.2019.07.23.23.53.13
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 23:53:13 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=jAXuPct3;
       spf=pass (google.com: best guess record for domain of batv+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+1e4efd27347a199fee4d+5813+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=D+fP/F31jlLUpmTEYvyqj+ufxmWFwYqwn3YRw+jITpw=; b=jAXuPct3oZWPyrvKK3RTq9yLMe
	P2SmrkMDBWs6EzLWrm9lZ9k9SfmUYWYPCzUjb0f4YJ5DEYdtHpJw2XFK00/7Es6CRRPhrKus/bt6c
	ER4cSvKLREXQtEc2scthDU97dFARRALlDnGlcVP8h/paihFvZ3vnN1u/ovubU485ouuzVtqwtDeHM
	q+w6iPsQcfcslsyLIsVOjOzhLjBg8m5p4lQB5sSF2bSlabyPXzWNGEKOZixnFNCj/2bdhtQLiIlHP
	3eODQlxrYKbSQ9cm/iar+AUA0hyO1Zrnswpv+8SLpPooWcr2s+GkE28X2/VeMCEw9pjvwKyYM8EaX
	F4rsi4WQ==;
Received: from 089144207240.atnat0016.highway.bob.at ([89.144.207.240] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hqB9C-0004Im-Vl; Wed, 24 Jul 2019 06:53:11 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 3/7] nouveau: remove the block parameter to nouveau_range_fault
Date: Wed, 24 Jul 2019 08:52:54 +0200
Message-Id: <20190724065258.16603-4-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190724065258.16603-1-hch@lst.de>
References: <20190724065258.16603-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The parameter is always false, so remove it as well as the -EAGAIN
handling that can only happen for the non-blocking case.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/gpu/drm/nouveau/nouveau_svm.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouveau/nouveau_svm.c
index 6c1b04de0db8..e3097492b4ad 100644
--- a/drivers/gpu/drm/nouveau/nouveau_svm.c
+++ b/drivers/gpu/drm/nouveau/nouveau_svm.c
@@ -485,8 +485,7 @@ nouveau_range_done(struct hmm_range *range)
 }
 
 static int
-nouveau_range_fault(struct hmm_mirror *mirror, struct hmm_range *range,
-		    bool block)
+nouveau_range_fault(struct hmm_mirror *mirror, struct hmm_range *range)
 {
 	long ret;
 
@@ -504,13 +503,12 @@ nouveau_range_fault(struct hmm_mirror *mirror, struct hmm_range *range,
 		return -EAGAIN;
 	}
 
-	ret = hmm_range_fault(range, block);
+	ret = hmm_range_fault(range, true);
 	if (ret <= 0) {
 		if (ret == -EBUSY || !ret) {
 			up_read(&range->vma->vm_mm->mmap_sem);
 			ret = -EBUSY;
-		} else if (ret == -EAGAIN)
-			ret = -EBUSY;
+		}
 		hmm_range_unregister(range);
 		return ret;
 	}
@@ -691,7 +689,7 @@ nouveau_svm_fault(struct nvif_notify *notify)
 		range.values = nouveau_svm_pfn_values;
 		range.pfn_shift = NVIF_VMM_PFNMAP_V0_ADDR_SHIFT;
 again:
-		ret = nouveau_range_fault(&svmm->mirror, &range, true);
+		ret = nouveau_range_fault(&svmm->mirror, &range);
 		if (ret == 0) {
 			mutex_lock(&svmm->mutex);
 			if (!nouveau_range_done(&range)) {
-- 
2.20.1

