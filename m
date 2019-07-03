Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD8F1C06514
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 18:45:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D9ED218A0
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 18:45:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="RuEQvC5S"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D9ED218A0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C49028E0018; Wed,  3 Jul 2019 14:45:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C247D8E0001; Wed,  3 Jul 2019 14:45:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A583F8E0018; Wed,  3 Jul 2019 14:45:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6E4448E0001
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 14:45:10 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 30so2087916pgk.16
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 11:45:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=pfzb7DKQGxSim4j5P5NViAehCYDnD7twhlehxZF4/mk=;
        b=QXG3HZ1dsa1DwM/a1lnfrcgAsmKr8bx2tQu+0ZbDX1gXuoDc8KBHRKUGOB9+KtZPY7
         Dp+hlzO3934vQ2SN5baSruPOLO6pFE4bRWC8V2dirBU6wGkkB26kZ9eBtjlmUchbvALT
         8cTABs7ZQ+/34t+UIQNkRsjyx1dBdUoyQAKzAVE55q8CSynapXkpHc4zxW1tAywC6Y5s
         EoUS7rzfgphEwH2dKfQMErk5vQj+uxfyPOHlp1iyak5DagW8T16X6CaXQ1AesM2EQS/L
         XFHENiz9OkBVe1o8WlFGHvAUAXUaESLLZpyfXw9vqEvJptJi4RrXSuFd/OhkGBOL5MJu
         BDZQ==
X-Gm-Message-State: APjAAAXyKJ89IjWasddKjhS44E9HIguE9JXcUQWbyTYFhUSW9PBmjj1f
	m8L8cYPaow5FNzCcA11uUuVmX5dIwI6xdtvI/K3olXVuQnOMgE427CayCWaWoOwIIEycz/dg7RV
	JUD/7ahDLbtomRmPUWnFYC3WfTpnsVLbZtxqGEZaYt6ehKJgfj8P6stP+Iie6sjQ=
X-Received: by 2002:a17:902:9688:: with SMTP id n8mr42997054plp.227.1562179510053;
        Wed, 03 Jul 2019 11:45:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzEXDua5pj5r65XFovEXKMT0o4UplP4G5gdRoHFy/l9kA2OvBTAe4Z5/jfYh4A5Xn++qiWs
X-Received: by 2002:a17:902:9688:: with SMTP id n8mr42996984plp.227.1562179509152;
        Wed, 03 Jul 2019 11:45:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562179509; cv=none;
        d=google.com; s=arc-20160816;
        b=Ih/RwlwPfjSRzDOx8CKpERdq0riIk2l3fJscA5jqM4HF4AFNT5o2A68jozrG4mKh+c
         IWcWt1uKVq6vPDJAuK4Yv6aaiHkb7TS/ey9d91U23xYgZE4Oej+WapSQGP2D6AX+OYtD
         sApZP5KpVSA3BqItApkde/ygVKUEnlP9iyWqLvyJFuEpQjVY3Gvea1R9bb9RlTNK7xD/
         qAUPB+Q1JvWivL/LutgRhx2IIrlcD+SbNTY7MtA2lBsby0bZPaWzQ0n+0MIPgC/JTzSm
         VvgFXFUoHv5lnm8F3BGh2L9YIvoSRdMGjfCtVpWF4hJDn3QO4XcgMOpe/vWwOTHcActr
         +A5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=pfzb7DKQGxSim4j5P5NViAehCYDnD7twhlehxZF4/mk=;
        b=HUiPvc8gK1wtXqAQSUl1wwGTnzwuScWXfmBaQFF2iVv191hcEX5uRQFTFR7/DaNaY9
         uyS903FdbJnArLexUQ3pWPBoHr3lI5TZb8hy7Ba9takzGtblZD3zZOa38X/79IdU3kxB
         E/wM9AOPPzYJhux14d4B844BJwAvnrsR92UXH1jyx6+YZflcRLB3hHKoDtcLPeGXm3de
         McFmvl/TaN9Dvw+EXHOBk953FeKIzpPEby6YnAdZLKsUm/NIV7Xn/iYDnWu4m4NEUW92
         HH/TSrGFtftaSRrAQqsj8dz9enUGUw5lYHpyqtBs5ugUKHFKIprzTmnUD1OcXJ44Prla
         z1fQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=RuEQvC5S;
       spf=pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b41si2878102pla.409.2019.07.03.11.45.06
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 03 Jul 2019 11:45:06 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=RuEQvC5S;
       spf=pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=pfzb7DKQGxSim4j5P5NViAehCYDnD7twhlehxZF4/mk=; b=RuEQvC5Szk3Lm7vVbLr+MfSSqa
	XBkXs0IYy8wwiP8zUJ+sptGQCbIJgaonwPKADc6EYKfe8cyLXuX6OJAXDLaSAqo00fEJgivMA8G9r
	Jp3rCAEIlz5o5MUoRMlgjCGuRlKGShwoKhkln491IBgIkVFD2jgvlsNTOIVjVI9KsBedL8bGACTAc
	Y6LiYyZQM8WHHYqbip9c8930hWAY1B3O4CF9CFWJhVXPoSCnctq2177N1Vc5lVbLit4yJeQh82Csg
	Uw0Xc8TeK5lNphU2JBlRLkMw4VS923+E5sYbHWFj/v3i0IpK3DbzoSl+Hs3Td3pWdzq4YCGK8hnn6
	B82DJdiA==;
Received: from rap-us.hgst.com ([199.255.44.250] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hikFb-0007Gl-TU; Wed, 03 Jul 2019 18:45:03 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 4/5] nouveau: unlock mmap_sem on all errors from nouveau_range_fault
Date: Wed,  3 Jul 2019 11:45:01 -0700
Message-Id: <20190703184502.16234-5-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190703184502.16234-1-hch@lst.de>
References: <20190703184502.16234-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently nouveau_svm_fault expects nouveau_range_fault to never unlock
mmap_sem, but the latter unlocks it for a random selection of error
codes. Fix this up by always unlocking mmap_sem for non-zero return
values in nouveau_range_fault, and only unlocking it in the caller
for successful returns.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/gpu/drm/nouveau/nouveau_svm.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouveau/nouveau_svm.c
index e831f4184a17..c0cf7aeaefb3 100644
--- a/drivers/gpu/drm/nouveau/nouveau_svm.c
+++ b/drivers/gpu/drm/nouveau/nouveau_svm.c
@@ -500,8 +500,10 @@ nouveau_range_fault(struct hmm_mirror *mirror, struct hmm_range *range,
 	ret = hmm_range_register(range, mirror,
 				 range->start, range->end,
 				 PAGE_SHIFT);
-	if (ret)
+	if (ret) {
+		up_read(&range->vma->vm_mm->mmap_sem);
 		return (int)ret;
+	}
 
 	if (!hmm_range_wait_until_valid(range, NOUVEAU_RANGE_FAULT_TIMEOUT)) {
 		/*
@@ -515,15 +517,14 @@ nouveau_range_fault(struct hmm_mirror *mirror, struct hmm_range *range,
 
 	ret = hmm_range_fault(range, block);
 	if (ret <= 0) {
-		if (ret == -EBUSY || !ret) {
-			/* Same as above, drop mmap_sem to match old API. */
-			up_read(&range->vma->vm_mm->mmap_sem);
-			ret = -EBUSY;
-		} else if (ret == -EAGAIN)
+		if (ret == 0)
 			ret = -EBUSY;
+		if (ret != -EAGAIN)
+			up_read(&range->vma->vm_mm->mmap_sem);
 		hmm_range_unregister(range);
 		return ret;
 	}
+
 	return 0;
 }
 
@@ -718,8 +719,8 @@ nouveau_svm_fault(struct nvif_notify *notify)
 						NULL);
 			svmm->vmm->vmm.object.client->super = false;
 			mutex_unlock(&svmm->mutex);
+			up_read(&svmm->mm->mmap_sem);
 		}
-		up_read(&svmm->mm->mmap_sem);
 
 		/* Cancel any faults in the window whose pages didn't manage
 		 * to keep their valid bit, or stay writeable when required.
-- 
2.20.1

