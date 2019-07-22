Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA761C76196
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 09:44:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B356F2190F
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 09:44:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="fx0OUGva"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B356F2190F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F9A78E0006; Mon, 22 Jul 2019 05:44:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 681166B026A; Mon, 22 Jul 2019 05:44:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 547B58E0006; Mon, 22 Jul 2019 05:44:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 162276B0269
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 05:44:44 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id g2so2058483pgj.2
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 02:44:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=KU3XO7neiNJoCLlCx1kSbawFotPCDQuEmLUnpBRP3R8=;
        b=dpurYRhRUoHE8TGMDVKUvcJna8dMZ1aJSMJ5hcaPwXsno8WZmsUIy28CUj6ZIb5QPh
         Z6l/NfyoiJEmv0hgXp82HeRJR3PBMeGleaMbffJNByqDLmvn/2aqPFdREl5krAh92qzC
         ghoKpDQyUwbw43kRpND5xjRvOCeWlTrHroDEJZzMphUm6KUd7IHjdhPoAZwDT3tAH7kH
         GEIJEy7U92xWTi62XQbETJPq0ClMQW70/dD86YeLQf0MKg24f6xIyminnotxQfDe9Vos
         RWriWUtY+fVeHWfDEc+SZ8nkXKrTmdnf9ivELbor3Czn5h8RCq9M1HD2kDspBRKJo3sT
         9gcg==
X-Gm-Message-State: APjAAAW/Za+IGWYlYgIicEMRTaHG0dp4GUKSZuTDQNJpTiSPtXy0uz8h
	wRfWxcxXKk/vOO+Po9fINWQeZKVa/CejjNgZCQPuWt2G53aJFOFt9pplmX/hqPpyWDuN49KA+tQ
	GyMLe8rPX4INUKz+JxgteuOeUS8ItdEe2vAUwlQqtqafBdSTzBkIXajK9gyFGQcI=
X-Received: by 2002:a17:902:b70e:: with SMTP id d14mr73775860pls.309.1563788683790;
        Mon, 22 Jul 2019 02:44:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzShYUOfCSlQjrK9X4kmWK2wtiYenoWwQnHE4Gmx6FUw2ZNTgPnbjFFH25j+mN8Y08ENEng
X-Received: by 2002:a17:902:b70e:: with SMTP id d14mr73775813pls.309.1563788683236;
        Mon, 22 Jul 2019 02:44:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563788683; cv=none;
        d=google.com; s=arc-20160816;
        b=bKhuRpkF/NNK70xBvOKd1pT0pbkcP7QVuunyVzkruwZgHEoVYe02Ejp9MXhGVUgXHh
         C8Y7KOCerX148DHug1ggoIXIu9wf8B7nhbjXgCaP14yEQC3ptezxHtRizp5y+x9zfjqE
         TFh4nSS9nUA629/v1aLIvIiiM+SGGRQzIqVqur25XyZR1Yqwz8iLlBtitFLgSmgwSWpA
         srMDzbltUB5X3Xqojrj7mQVyFQdT8J/P0am434IktK8EhP0KLrH9XTUk0HadksoiwgH7
         8eW4GUuuZhtZihnTD5sotf2UBVenpQjVKC0QsDlqbTtgGHBuL/Z/SnIgc3fDPmUHbSig
         H6zw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=KU3XO7neiNJoCLlCx1kSbawFotPCDQuEmLUnpBRP3R8=;
        b=VPUJHeXteoSH/jd7ZFWykQfYtzMksLZPh81DkjpMQgXNx+ZzMuBeFLHABug9+xmDNL
         yqyLSLbxvH9RI7Twa/octuob2oly4tHR8BzhNkS8nS9lu7maKVda9GZJ9+N0lYlqx0ge
         Zu0l/6wDL4sMfKBGmarkFZepyJca6hGqWV6NqHiRcmXKwCyaccmJ7fmAYvbubIMjbwG8
         C7yV7NwK7WcOyxl/SMhR4ePDytGdKqR868+Lr67JXiw3CfeB2g9PjeIGtQg5+dgEQT5e
         wX6NWN8CkNMVaVpORQl9n0OijoiV88NfZwT21GmYlxIKq6epJkjfcRy65RkHReSmifWy
         HSxw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=fx0OUGva;
       spf=pass (google.com: best guess record for domain of batv+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i23si9379154pfa.196.2019.07.22.02.44.43
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 22 Jul 2019 02:44:43 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=fx0OUGva;
       spf=pass (google.com: best guess record for domain of batv+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=KU3XO7neiNJoCLlCx1kSbawFotPCDQuEmLUnpBRP3R8=; b=fx0OUGvargc7kZuDQBT1BVZvx6
	akZ3IxLvVFpwpTZ6mwxG/fDjJWbzOIsUrUpGAbXfOCDOTt/ZY9Og/OO6v1ZKX2WLk0UKeOuqaM5He
	JS3eKYYglPuo39ThJdRVk2HstA3K2/0b6YcWdNagG4gTFQf6qHKpgDxoFKvgUpg1SZ+OEMcU9hNeg
	nQTH/RbZzXAV6COOglFFC/UlRSXF47ADoLQbyXc03H9Kt31xN2rPHCxvirU8nLtJUgVejCURB9uha
	Iu8bHoVGJ3ZS4ucITXCip6qt9/Cmo1Y1s1eOcE8U5YqnKeJewWAL0DOk8cXwO2Rp1NvN/92mIq7KX
	5lcn/C2w==;
Received: from 089144207240.atnat0016.highway.bob.at ([89.144.207.240] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hpUs4-0001tJ-OZ; Mon, 22 Jul 2019 09:44:41 +0000
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
Date: Mon, 22 Jul 2019 11:44:25 +0200
Message-Id: <20190722094426.18563-6-hch@lst.de>
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

-EAGAIN has a magic meaning for non-blocking faults, so don't overload
it.  Given that the caller doesn't check for specific error codes this
change is purely cosmetic.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/gpu/drm/nouveau/nouveau_svm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouveau/nouveau_svm.c
index 5de2d54b9782..a9c5c58d425b 100644
--- a/drivers/gpu/drm/nouveau/nouveau_svm.c
+++ b/drivers/gpu/drm/nouveau/nouveau_svm.c
@@ -501,7 +501,7 @@ nouveau_range_fault(struct hmm_mirror *mirror, struct hmm_range *range)
 
 	if (!hmm_range_wait_until_valid(range, HMM_RANGE_DEFAULT_TIMEOUT)) {
 		up_read(&range->vma->vm_mm->mmap_sem);
-		return -EAGAIN;
+		return -EBUSY;
 	}
 
 	ret = hmm_range_fault(range, true);
-- 
2.20.1

