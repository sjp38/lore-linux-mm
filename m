Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 091DEC5B578
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 22:02:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BFBCD218A0
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 22:02:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="efDzZwBe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BFBCD218A0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F8A48E0029; Wed,  3 Jul 2019 18:02:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 108CE8E0027; Wed,  3 Jul 2019 18:02:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D43F18E0029; Wed,  3 Jul 2019 18:02:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6AD888E0021
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 18:02:21 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id o16so2343128pgk.18
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 15:02:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=DUoOwqjnTji0F9t1TBg521OpvLvqwX3Vlrvz0Ntypso=;
        b=C01Tw5L1EGmiomRPoxEMqnZkIkKqlLQsY2e+z/M7xclpaq57fjXTBpNIoM2fCVUW2n
         MwVaktymaEk6FgFyX7CoF2tAA7ZR9LZdQgR3ssW9craVfX/OOMVLExGhATj21k71EnPH
         VOEbZ7WyD9Fk/TmBte0cuS242PmBRgtonJrGf0UZl76yFBm6mVuMROjRfuNi5mDpoGe4
         2FvXWiUU2v7X1IDFtjkciLDGln2nBz2cCRaA8YE1IomuVL3dBINyFAl9UpbQ4vQuzu0d
         EYA/v89iqIGRpu/Kj78ef2ua/hLb4D7tEJg6jPOyXYS0spBDr+h/6TBtTC1KFIMoZsRA
         JWlg==
X-Gm-Message-State: APjAAAWdhsJkRkW8aEh5dkJtOsqXxbZRuHI4fwq/i4jgntjMPjtP4ZRy
	t4M69PupB1IYPHXatTNV9KCVB408WWShZk9DD9U+FIJFLU8gpLSsr+/zA+iQS579U0TO/bTWUYp
	svTsA/zeI6WeTA12JFimeRbIWKfwuXuPWMmLIxE/T9d7cXNU5Mr5n7CKi80AsYJ0=
X-Received: by 2002:a63:1b5c:: with SMTP id b28mr8663501pgm.101.1562191341016;
        Wed, 03 Jul 2019 15:02:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzMknNJ9nP9uwIDlhXkYUnLfhH55upTS5TygGODhHDqfz3Ll+nm7filoJgVVSxY7mJdohEi
X-Received: by 2002:a63:1b5c:: with SMTP id b28mr8663414pgm.101.1562191339916;
        Wed, 03 Jul 2019 15:02:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562191339; cv=none;
        d=google.com; s=arc-20160816;
        b=R7bcqjM0RvTFg3RtGVOqC/PQnEegBcGSkQ5M86nZIaD7Oh8jUdVUjm1tiboRilOYFf
         ROqyQMH/JThZY71gCbJ9LH2CCXbGDn1jD/AujYR3gb9r7ez4y1gdRHhfx2ia9jrbi7E2
         I/N4FXNMDZzfJA6swxQGvEQ9c99W275BB+uAdpALeLJcIB5QLhpHzMThR6gd5SiOcWpM
         DJLA4QzitGtODMP5mELiQs8Pmvq6/D2wgO9QeRO+GJ1DagCKFA2pJKZ0uzY/DTFGFqBa
         9XQ9065BSszW+GaVztO5XIKKSM8Mfu4WyovOiaB7ELB0iP3TLTOo0tcnLZpT/A35h1Sy
         kMLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=DUoOwqjnTji0F9t1TBg521OpvLvqwX3Vlrvz0Ntypso=;
        b=mvbYPiMthl96Jkx7xqkS+rfabjTBJtai6pKXe1nLxewDLHbm+OUSwfgNJSGRJFOkRk
         RhUJ9WTu9EfppFKOl0shwavEZQywUNhcBXSmEyd8M5SNeE/sK43Kxlp4ZKRejHYdVbiI
         k9H4IxmnBM8G1nB2xLw5YTF7sgykAksqREHL6HHmX3iWTXenbEMEebkOuT+KlN1+Pfse
         Es1vShF0WDl16UQFrj/6vZ8fxuPERPslfn20f8uFxN7lv8LA/JlCoc/QvELu2kX7y1+t
         m/ouSAB6DcJ1fWT4u2aiVNttFFzOIzN9WKd6SdrhGgS6FPk9CK1tn1GLlxBvb0Y92K/i
         871Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=efDzZwBe;
       spf=pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u38si3370371pgn.79.2019.07.03.15.02.19
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 03 Jul 2019 15:02:19 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=efDzZwBe;
       spf=pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=DUoOwqjnTji0F9t1TBg521OpvLvqwX3Vlrvz0Ntypso=; b=efDzZwBeFkuXGAumAQiTxGRxkt
	7D+YalkdI4VpAhWfDiCr5acuRvXk3B2P6XcIKBXGzEPBierDhh0ydQYTRtK5O3oYNgb0CXsCluMgO
	z+4eQkFrCU1ogAFWQxXUO2itnHdgd5PstKF1fjC/mYhkALtlWktGH2LwfMkR3X+J+Iw2eeduXoBiZ
	TEUf3el0yJeHxkqoV3zcOygMbjfNtIkcYb7c/dNlmPWjVJG+bE00JuSW1bMeOcQZS+bZRWiWATVGf
	UdIM1NJZPbkyv3mt3mrXrTmNhpRloE/IABs8wxj3gLRGIvAGR1uw8u+PcvwC2w+8wtER9Birgc/wh
	KZgk5nNw==;
Received: from rap-us.hgst.com ([199.255.44.250] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hinKS-0004Ek-JE; Wed, 03 Jul 2019 22:02:16 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 5/6] nouveau: return -EBUSY when hmm_range_wait_until_valid fails
Date: Wed,  3 Jul 2019 15:02:13 -0700
Message-Id: <20190703220214.28319-6-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190703220214.28319-1-hch@lst.de>
References: <20190703220214.28319-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

-EAGAIN has a magic meaning for non-blocking faults, so don't overload
it.  Given that the caller doesn't check for specific error codes this
change is purely cosmetic.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/gpu/drm/nouveau/nouveau_svm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouveau/nouveau_svm.c
index d97d862e8b7d..26853f59b0f4 100644
--- a/drivers/gpu/drm/nouveau/nouveau_svm.c
+++ b/drivers/gpu/drm/nouveau/nouveau_svm.c
@@ -508,7 +508,7 @@ nouveau_range_fault(struct hmm_mirror *mirror, struct hmm_range *range)
 
 	if (!hmm_range_wait_until_valid(range, NOUVEAU_RANGE_FAULT_TIMEOUT)) {
 		up_read(&range->vma->vm_mm->mmap_sem);
-		return -EAGAIN;
+		return -EBUSY;
 	}
 
 	ret = hmm_range_fault(range, true);
-- 
2.20.1

