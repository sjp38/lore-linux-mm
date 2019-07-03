Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 835E8C0650E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 22:02:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3CC20218A0
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 22:02:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="OpDvh8ug"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3CC20218A0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AAA118E0024; Wed,  3 Jul 2019 18:02:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9E7C98E0028; Wed,  3 Jul 2019 18:02:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 611DD8E0024; Wed,  3 Jul 2019 18:02:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id EC9BE8E0024
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 18:02:20 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id y9so2057895plp.12
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 15:02:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=aR5JFpbAtZwK/e60Yd9Huxe2JebEBXUD/VqFe6j363c=;
        b=XZFa12Hx53ulJQdXoL0wPB0WxbhFHdy47XM/nSVbVeR+dmgzi718oixu4ea6DcVGi4
         zw6VA/ECnoRPGfUGG1EmmtVJDcnr8lCY/zEKYouMHy0TCGeFk991EEq2N4vOpg62Yr79
         0p7+7HJ5+WnGskaYUUiGGYlBfVJJ27v/bR24i7Qy7arE4sjjBZiopJosRUYpHPMoDq55
         o9gZuhJiptR5rxcaroUQkbRBh3OBZkA5IKFfKrpyyChEaZAGhAl3ZiCFf/rGvAV4uMIc
         gwwLVIeRhHV7y11Yt5IuxrzoUXKqu4nGBh0Lt0X9kckW+X/Qpd/nF9xkwmuZ6IfQCwfq
         j2xg==
X-Gm-Message-State: APjAAAVadZqyjxro2vamha98LmAYNDid3HpvxUn9yIjBBHKT2/eWXpxj
	URaw843IS3Z3e4z8hGMtsHYZRVkSUTybxUyQBhdx6c/TI4CWNROGjGa/Yh2EoTsae72spquaAeP
	NHj7A01mX75yTj0xhrfPGwVbzK00fgj58Tf7gbrzmbRnofH35YfAtUb/yvWoKbW4=
X-Received: by 2002:a17:90a:3210:: with SMTP id k16mr14845573pjb.13.1562191340581;
        Wed, 03 Jul 2019 15:02:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzjDAIjSlRPyV7WLErP4aHx1Y+tUi4eXw4ts1XlTlmu2LZoboXApLh/BB4/dUgyTX3CBzx5
X-Received: by 2002:a17:90a:3210:: with SMTP id k16mr14845487pjb.13.1562191339440;
        Wed, 03 Jul 2019 15:02:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562191339; cv=none;
        d=google.com; s=arc-20160816;
        b=SfKYfY+4U/Hg7Gy8XHw/YF0oQXhkVeEtbbUKQR6AXeF61+3CrL6sX16kdRry3lLOvD
         Ml69efVJfWo5qfWPxLAu2pH4uQ8YkUo6l7ySB3CqGXuGZjqLc9cjNqNZBqpHhEKLfljg
         YGn4OJsmM0dlZp6rjZYlOQ5n9EDSDUPAIKtngAbekBRt+5mVSp1IzD3cNACDCoP/80HG
         voM7sXtXwE1PCsz3eAy8IhaMG81/qisVdxIalDtw5jDnhym9YXTQL2vg8Sr3vzh1Ly3P
         p85SUS/GGzQfyDMtYa6yD7UnADTrOUMBOKO++rlIo1b0jSDvx4yiOdzbAXyLWhGlhQp/
         CF2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=aR5JFpbAtZwK/e60Yd9Huxe2JebEBXUD/VqFe6j363c=;
        b=FJhrlBuKhuHaxcN3HXkBK22y2axUD5zPQ9K2TuI55mOml9RTLjjZdmInWJ9YN3buyX
         iFw3dvvlNJKDIGbZ/WM0gL1kje32GOYhzVq/Fqm8k9KVvFj7jvMOnJggW3mtFADxGMpv
         zARgwSDFdP34xSAqkRRsy49z6MONzFrmIS5/dVL/1PP4ie5fVMSYBZOkldQbyKtVJJX9
         MQg4GRvSWXXRXef0j+kkA7cpbDsi4rVmcFw4ESMevTp5bYygBom0udkZ1jjjhQpgdsLH
         2Tu3SpV1Mlc5XnFbkWlnIQNFai3y5eidjYJnB8Hw3MO80/00cHk4mqxSL/RlMAXtvHEu
         KWPA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=OpDvh8ug;
       spf=pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s24si3376848pga.515.2019.07.03.15.02.19
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 03 Jul 2019 15:02:19 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=OpDvh8ug;
       spf=pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=aR5JFpbAtZwK/e60Yd9Huxe2JebEBXUD/VqFe6j363c=; b=OpDvh8ugx9CCqIn6z/3y1udmC9
	KVHOJ4bsImzFgtZfExFnufvlaVFq0giHc/vuAIxKY0IiLV8hawN4olAqJfcL1gDdEfW57uyU5nj5l
	x3GGSB43dDPINYm/NEWoe96PFuvG+2P/z1Fr7axSCD8q98G6fn0/H5jngAe4xoO/Hqe9fnlPDrQYK
	maGsjZPeEo6lxfX+g7EBD2wrEI05R7gGH9G0i/0CFtnM1uTTiOFnW1vZT+aE3Q3gNb/qwMOnPVVa+
	tpRen6TJqloiQxgbHEfAFv64GJOvH3Z05gcv5LDRyQ7BCWPwdBTu1oVT9mXca+ZqiZNiHRN1JiAaF
	aEarK4YQ==;
Received: from rap-us.hgst.com ([199.255.44.250] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hinKS-0004Ec-6y; Wed, 03 Jul 2019 22:02:16 +0000
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
Date: Wed,  3 Jul 2019 15:02:11 -0700
Message-Id: <20190703220214.28319-4-hch@lst.de>
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

The parameter is always false, so remove it as well as the -EAGAIN
handling that can only happen for the non-blocking case.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/gpu/drm/nouveau/nouveau_svm.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouveau/nouveau_svm.c
index 033a9241a14a..9a9f71e4be29 100644
--- a/drivers/gpu/drm/nouveau/nouveau_svm.c
+++ b/drivers/gpu/drm/nouveau/nouveau_svm.c
@@ -491,8 +491,7 @@ static inline bool nouveau_range_done(struct hmm_range *range)
 }
 
 static int
-nouveau_range_fault(struct hmm_mirror *mirror, struct hmm_range *range,
-		    bool block)
+nouveau_range_fault(struct hmm_mirror *mirror, struct hmm_range *range)
 {
 	long ret;
 
@@ -510,7 +509,7 @@ nouveau_range_fault(struct hmm_mirror *mirror, struct hmm_range *range,
 		return -EAGAIN;
 	}
 
-	ret = hmm_range_fault(range, block);
+	ret = hmm_range_fault(range, true);
 	if (ret <= 0) {
 		if (ret == -EBUSY || !ret) {
 			up_read(&range->vma->vm_mm->mmap_sem);
@@ -697,7 +696,7 @@ nouveau_svm_fault(struct nvif_notify *notify)
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

