Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7759C5B578
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 22:02:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 60B35218A3
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 22:02:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="QkYiGjbM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 60B35218A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ACD9C8E0028; Wed,  3 Jul 2019 18:02:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A56EC8E0021; Wed,  3 Jul 2019 18:02:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8D1C08E0028; Wed,  3 Jul 2019 18:02:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 339638E0021
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 18:02:22 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id x10so2271463pfa.23
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 15:02:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=TH7ilSpN+2j82AKqVSfBr/e3/+W2L5xJvYOO3yTY4Is=;
        b=lq1EQD1R+kqBXveL7zE+M6ml+G5QhPN4ZAdhqL+HRwJt4izxMXCWP2QSZ0qunCMIl1
         dtsvmBKlrj4rQ5HP5CvKmBukaKGbLbVRQ9rWKsgZflUH5hHK5RdngAOI4b1FUvN/thJQ
         p3qYsT1EDtM9p1bhFCCgBnEeme1XcLmFlRRP8hySTY44d5yVpNLQuKms8YquVE4u4wUa
         LfDe4uKkhkOa6NmhzG6MNBA2rx4tNsbGB/rU/xGncQ6TGJ78zSqwSVu4gMIW2UDiiPU/
         vbs2wRO5FR7YFB1KEz14tF4V5z0CR45ntTISTgR7ZNOPvALwnADuUipdL4DXzYAIpbJ5
         GpoQ==
X-Gm-Message-State: APjAAAXc+FmTNGrndjLZWVziYCAUvUA/v/Sq+zYaORjbjSjyspaK1P8f
	bCMVEipwoxwZ/oA0vtz0LxNtEKdxlcj34IdwV2b/pNMkRdUJpFsQqMM7uBNGaWl4bIDjdTIaVeT
	z19mrarX0W4EE2ydnCpMj8Im1fO5CaAAT7ix63wGXt6DtiE9j7Abe6taFtKviZeA=
X-Received: by 2002:a65:5b4b:: with SMTP id y11mr38563815pgr.244.1562191341752;
        Wed, 03 Jul 2019 15:02:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwKhvZlf7+sQa7s5LDZzgWkSGbPWK8dh3W0+a7S7lw20Z59rl40tOtzFAgJp2052ZqdVmv/
X-Received: by 2002:a65:5b4b:: with SMTP id y11mr38563766pgr.244.1562191340899;
        Wed, 03 Jul 2019 15:02:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562191340; cv=none;
        d=google.com; s=arc-20160816;
        b=tAkWOrnizNGJipP3FCe/t6mtTArO7Kan0za/ES7YsQJ1f18YAyqNhB9NLrejJSc4Qu
         PeMzkyBhTKTfdbctGrtAQ5lJi4u7nJVSLAYieUWk43B0jf6v9txK+ePvsz8EqdiXtbPx
         9hKd14UyHau8/4c7hcLCNx59K29VmXTX2TXPsg3zLeWuICivpB7oWXa30+QemTybBnD9
         6m6LUcSkiCPADGD6z/b6ATpYiGEmMGJECmvCqiEM8a2xbSFUxuYl3ZCoT13DjyXYjnhj
         PpfoNMlK0ViYH8kZPruhQSN9TryMKwpOdR852lzzm/awckPGJ+EdFxCdXfZQStISkLCl
         vr9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=TH7ilSpN+2j82AKqVSfBr/e3/+W2L5xJvYOO3yTY4Is=;
        b=I+JJ1NMXJMP1n50ui5ugUe6SiKl4hHY66pHatmTWytI7Ty4DiAgemBWk0HHm1By5zf
         +C4aLFdJc+atetWB+ahbiwKxSgr9qlb9nsCbFO3JxqgUXtgAkYHZCCLsfAzOT/TJ88Pr
         foclHR6Gx9De9kUmrYxXmb4ds+gReR/QIBcAfIkJaEFHYVa3/DEJ1d3+wYZscNb7W+FG
         PxxQqzGewPYzdindSXH1SEP31MqeP8mmWoI0UKuwGb36+n1NhB3sZRYU91KaH6aNLy8w
         PnfG65mBeo2dQni/o6wulFeHOLQ5SwD41m0SwkvKiK16pPJ6KQiGCiD3Ydv51uA3cO25
         K1wQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=QkYiGjbM;
       spf=pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h61si3286360plb.256.2019.07.03.15.02.20
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 03 Jul 2019 15:02:20 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=QkYiGjbM;
       spf=pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=TH7ilSpN+2j82AKqVSfBr/e3/+W2L5xJvYOO3yTY4Is=; b=QkYiGjbMBjTGLVROOh+GRbmRJb
	MyoPGFJE+6teMNn9c5SEVHNaLJh/dDNSFYCEY+IvBJKEGW9ohDBcsp6CVPN0VrZ0J7fDngCYsPSv4
	CTcFISy34r27v4v0H03+M4tT46hjxR7FS9ebz/zaYpADue3mFBLXKkQiySiYo0OXMfYuIEZSyIeYM
	BCuxayLeVqoTiSZtVLEC80SQUqJFqA/SAdaH6UO6w3Q1gsl//cwPUe6JlfqruSzJ+jjOQ7dz9kSgZ
	fn9KEBBzwR+rePovn050pvLCHNfewpmtkFC8H0ZPqp/ZOMDz4QtUvPdjcKRyVJo7D+Wq8Gx7oUV5c
	ydw5RV1w==;
Received: from rap-us.hgst.com ([199.255.44.250] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hinKS-0004Eh-Da; Wed, 03 Jul 2019 22:02:16 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 4/6] nouveau: unlock mmap_sem on all errors from nouveau_range_fault
Date: Wed,  3 Jul 2019 15:02:12 -0700
Message-Id: <20190703220214.28319-5-hch@lst.de>
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

Currently nouveau_svm_fault expects nouveau_range_fault to never unlock
mmap_sem, but the latter unlocks it for a random selection of error
codes. Fix this up by always unlocking mmap_sem for non-zero return
values in nouveau_range_fault, and only unlocking it in the caller
for successful returns.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/gpu/drm/nouveau/nouveau_svm.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouveau/nouveau_svm.c
index 9a9f71e4be29..d97d862e8b7d 100644
--- a/drivers/gpu/drm/nouveau/nouveau_svm.c
+++ b/drivers/gpu/drm/nouveau/nouveau_svm.c
@@ -501,8 +501,10 @@ nouveau_range_fault(struct hmm_mirror *mirror, struct hmm_range *range)
 	ret = hmm_range_register(range, mirror,
 				 range->start, range->end,
 				 PAGE_SHIFT);
-	if (ret)
+	if (ret) {
+		up_read(&range->vma->vm_mm->mmap_sem);
 		return (int)ret;
+	}
 
 	if (!hmm_range_wait_until_valid(range, NOUVEAU_RANGE_FAULT_TIMEOUT)) {
 		up_read(&range->vma->vm_mm->mmap_sem);
@@ -511,11 +513,9 @@ nouveau_range_fault(struct hmm_mirror *mirror, struct hmm_range *range)
 
 	ret = hmm_range_fault(range, true);
 	if (ret <= 0) {
-		if (ret == -EBUSY || !ret) {
-			up_read(&range->vma->vm_mm->mmap_sem);
-			ret = -EBUSY;
-		} else if (ret == -EAGAIN)
+		if (ret == 0)
 			ret = -EBUSY;
+		up_read(&range->vma->vm_mm->mmap_sem);
 		hmm_range_unregister(range);
 		return ret;
 	}
@@ -713,8 +713,8 @@ nouveau_svm_fault(struct nvif_notify *notify)
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

