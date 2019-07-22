Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0C3DC76196
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 09:44:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C6EF2190F
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 09:44:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="o00qtjJL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C6EF2190F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 23B6C8E0003; Mon, 22 Jul 2019 05:44:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1A1226B026A; Mon, 22 Jul 2019 05:44:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EBF098E0003; Mon, 22 Jul 2019 05:44:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id AE3FA6B0269
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 05:44:38 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id j12so19527343pll.14
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 02:44:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=YLjcXCEMJf5xAF7DKuZC+yJ48qIL8uSBqOcNS6lxEPI=;
        b=RcmRwh+nZdgJhjobd+thukQdYWP38OtrpMt//IfUj7ruL7Fmd02zlD7DnUcB5IpI0R
         Mt2C0VOpAkXjcMM/TcFOgkPfMnScpVgFNqPZPRTTpZm2Oiafu53e97eb4FCbIWUySjzW
         gf+WKxYD3HrXiu7ZXqMiGhjMEhye1/3QVy6Y7ic4I6gya+tj9YH3edYojvpr57JUNoB+
         TOSXLx75N3d9rb3IoT+Uh8X5aBOtzYf+s0d9g6K7eBpbrSUxszJ5HZKIWwHwEm8IQqh8
         GdodbQRP9ww+Q5eo+ykZ9Ztk10dXZS32SyYvIiCAdV/vzzUOEJkh/6qW5yb/PnD8bDcp
         vRwg==
X-Gm-Message-State: APjAAAWhFrmuQHwmjPMXHVJxBfUttOztoPibXKuyOfLPgKQNS8Nzg4OL
	7Lu9sPmEv/SDLQAQSohXfmVXf2meNDQm8TRoSc/I2nhT2ilFpAzeeA27Uvp65QuCGQvOxYk8YS+
	xTcx5mXBypk9hFZ22++aNiMqqWRkbzI/9drtKfBRcv6ZQXKNYJMb/mT/Oe3YhkHU=
X-Received: by 2002:a17:902:2869:: with SMTP id e96mr71856606plb.203.1563788678406;
        Mon, 22 Jul 2019 02:44:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxRUGxrOs7xUVkDfHbaaAyzxiTyEidEsu2rvzc8jLbvaTyuR9PPILg61fn5KuJ/hfavKwl9
X-Received: by 2002:a17:902:2869:: with SMTP id e96mr71856556plb.203.1563788677817;
        Mon, 22 Jul 2019 02:44:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563788677; cv=none;
        d=google.com; s=arc-20160816;
        b=P2jT098xD1k+2ftNocN2CRVicgC37G34s6k2dWrIESw5/edaeaAjaXCJv8/iPzAC6L
         W2WlI92/RM/ayPyiSQOSKH8pI2FDC3HWHwuBWJ80wcMkMdmbj7P/Q3T7BrdJgFRQgHR4
         iIWkqf9+DNSwtAjrWgDiyhAM+VagsXbMI0DcLylUqw1LFInq8muvjzStipgyKgm7Rt5a
         BZ4vpuHVtaZg1DJS3CZYJ+sk6dLYrT4w+dheyaQ+5/xWgGUAm1fWEXZ4cDslN+clUZDM
         JITOOyfiAz2GjCcoZvgvHPShyAXpnXR5kCpKk4415CU3TcJOePW+L6UJ72bQuHZ4QQyh
         3K/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=YLjcXCEMJf5xAF7DKuZC+yJ48qIL8uSBqOcNS6lxEPI=;
        b=KrSElK/hhhqlSRI6uzrUieGM3Eqa2ZbEz03d0Nu8GIXWIm5d5/iv47UX5UJlfj8ctw
         TZ1mVbpAoODnZLWeuKqUmtVMw6ZruJbHhvycZm7lBSGUBNVvPZNaGiWvU0HSDwCjuNxm
         joBNFD7uaz2BD8wq2hvcYCvNujtxQQco7cN0GnvzdRqo2uBmJqew2CRHuWa3FV3Kyu+8
         tZmUP63CRz0pucY7NArio2jHeKAyAMcTix8Ps6+mJ02rOEPlvH6n0b5Ngtd0H68Afvug
         rRceDEiuUN35iSUtDzg06eYs6sGxQKHSqTXYdOQNz/DV9FvhVr4drVjM0ZDfMvwz4lGs
         oidw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=o00qtjJL;
       spf=pass (google.com: best guess record for domain of batv+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h186si10285387pge.110.2019.07.22.02.44.37
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 22 Jul 2019 02:44:37 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=o00qtjJL;
       spf=pass (google.com: best guess record for domain of batv+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=YLjcXCEMJf5xAF7DKuZC+yJ48qIL8uSBqOcNS6lxEPI=; b=o00qtjJLkuy9H2u+xS5JRsIFEN
	ocjpNR3PZxUm1M6MGmjzKD9EZjw6fTAP39WnD4xaKsJqXi26UYlI2UNgc3bXFJrXwQBEfHcf6foVq
	Dva6X9pnLleGD2QJ5qVXMWg70Sbsx8KlBGkTuhImkHN4/+x7XldgDUWZygTsWnEG8wj41+yeB+4A6
	dQAuv0iPGkUgGg7V8reOEDSKWvytYUS9nl1APlxiLWl4Q68PcIOPcqGPYItMFhwTG1fmYITlOEGHh
	LAjydc5V1PE1A8GEjGkB2YcyCuEhWzee1fBb3ng0KIrbY87SsDQOxQMchBjrNAeMX+ZaEZMX/89kI
	902bJNMA==;
Received: from 089144207240.atnat0016.highway.bob.at ([89.144.207.240] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hpUrz-0001sJ-OG; Mon, 22 Jul 2019 09:44:36 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 3/6] nouveau: remove the block parameter to nouveau_range_fault
Date: Mon, 22 Jul 2019 11:44:23 +0200
Message-Id: <20190722094426.18563-4-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190722094426.18563-1-hch@lst.de>
References: <20190722094426.18563-1-hch@lst.de>
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
 drivers/gpu/drm/nouveau/nouveau_svm.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouveau/nouveau_svm.c
index cde09003c06b..5dd83a46578f 100644
--- a/drivers/gpu/drm/nouveau/nouveau_svm.c
+++ b/drivers/gpu/drm/nouveau/nouveau_svm.c
@@ -484,8 +484,7 @@ static inline bool nouveau_range_done(struct hmm_range *range)
 }
 
 static int
-nouveau_range_fault(struct hmm_mirror *mirror, struct hmm_range *range,
-		    bool block)
+nouveau_range_fault(struct hmm_mirror *mirror, struct hmm_range *range)
 {
 	long ret;
 
@@ -503,7 +502,7 @@ nouveau_range_fault(struct hmm_mirror *mirror, struct hmm_range *range,
 		return -EAGAIN;
 	}
 
-	ret = hmm_range_fault(range, block);
+	ret = hmm_range_fault(range, true);
 	if (ret <= 0) {
 		if (ret == -EBUSY || !ret) {
 			up_read(&range->vma->vm_mm->mmap_sem);
@@ -690,7 +689,7 @@ nouveau_svm_fault(struct nvif_notify *notify)
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

