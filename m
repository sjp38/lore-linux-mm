Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E969CC76186
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 21:05:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F29E229ED
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 21:05:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="clAJYjoG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F29E229ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 220A46B000C; Tue, 23 Jul 2019 17:05:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D0F26B000D; Tue, 23 Jul 2019 17:05:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C0DB8E0002; Tue, 23 Jul 2019 17:05:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id E261B6B000C
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 17:05:20 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id x203so6387243ybg.9
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 14:05:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding:dkim-signature;
        bh=rjC23JCqCu60sr5rHPIEAf4LwcRnQlVgUeBq46RAZu0=;
        b=YBrEnnRxQBraydbt99y8of2wbm63PbcyzA3tXOcwfPL4FQ5iX7m5UA5iOn6mou8WNF
         OLpvVTZCRM/hCj80Iwk4UhpJeFqfKA3Z5tP2mYB7ipllYm4MY/NIcHiijtvqv+7KZzBd
         oqwD7S54Bb8jtqqrzXdYqXHE431xCw0TLmwYnf47dDA3ZC5Yn1oWsqIMvTu3TckWMtV8
         lFTXbdnKA69Znx+aCvpZKpu3xIVlUSUiq8lIzZVEbQtQPbM2shZIMqGnEbRUdwzLdWlM
         9D21odpdyml3/Z2adWzLmZ023ReDcDZb90M++7Jg2A06TY/DEHXpuSMWkX/ayWt7ojfG
         4tMQ==
X-Gm-Message-State: APjAAAXfBRJl+gy57xceRNhGq/c6SI7y/89zREIzZ+hBZPUi0RiIwr7w
	LnMxumKQkJsevOyk3TtHrL1CIgCnaZEjOvFTXqV5mPPE/7txC+wTG8W1NWvoLClXAaMIZnogUiG
	x02IClu+BKi3Ma9F+MXI0WRFVBiiLHS/D9s97K2WGL6qsbreHIIB6tfwrMAYs+3tWog==
X-Received: by 2002:a25:d9d3:: with SMTP id q202mr49597731ybg.496.1563915920616;
        Tue, 23 Jul 2019 14:05:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxATOF6EQPh4KaGRnsGQk4NC9dwG6rwBuLr4zz5ARiviQK8Ws1q+FFfBaM5jg8TMRGH0OYP
X-Received: by 2002:a25:d9d3:: with SMTP id q202mr49597696ybg.496.1563915920022;
        Tue, 23 Jul 2019 14:05:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563915920; cv=none;
        d=google.com; s=arc-20160816;
        b=OQKeWd3+SBpE9Ew5zDGLFidpOBuRtgJ/+oI8577Ur6YW5cobfmWiaYW6NM83lykmta
         vWjxc2v8XB9DJzNEktOjVlxZrFTDRPDF4J3pAWZ59PtphTY606pDJxZSV5T32F2CCaOQ
         yOS9bnQmrIAkjxH5OwzjWCx2dNiVLIFypjAV6wovUZmACzL/TE71iIkWFAUpHeFSUMNS
         IJxWDK/1ZzzCoCoerv3/pSIO8ShIXrhlfiw3AKdiewPwdLVW6UmMgpuKj8CEqbsyZqR3
         2QT5XhkkexfN0jX7eGNVhjjfVwqhlw3XJ2lj3CXpLtt4mz7vnhc7fjUzHkJOLzwzz4xs
         4oAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:message-id
         :date:subject:cc:to:from;
        bh=rjC23JCqCu60sr5rHPIEAf4LwcRnQlVgUeBq46RAZu0=;
        b=cvAdZCHJZUSBeCT6R8pZwLimO6DAvEa/iXJA+Ec4zyUnnl4sfF/rdh0AktllmEOrh2
         wg1JVgcwxk0J/4eOYgMfL+WXsVbZ3rViTQnIBsViuY4xlbdzvv7WkUvyxB1HaVQH0Wj3
         G7thTVY6GTy7VpHfpNHcrb/lnwiKpCTdvSSua98pYzzyqanf4/xXW2Rw8DDJSaGvL8Lo
         feVMdNE0UcNgPVCla6NjodL1b8x1IosaMqr0PtMmVBnkLl8d9HYLGOwEbGftaBn45N0X
         9usTTpi3tqW/xKbOYywJ2CKFct0ErIvqjVHjwJkHTvNN/XtYpMJ+bhzYjv3xZ5M4eQIM
         1sHA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=clAJYjoG;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id y11si5501421ybr.200.2019.07.23.14.05.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 14:05:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=clAJYjoG;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d3776960000>; Tue, 23 Jul 2019 14:05:26 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 23 Jul 2019 14:05:19 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 23 Jul 2019 14:05:19 -0700
Received: from HQMAIL107.nvidia.com (172.20.187.13) by HQMAIL108.nvidia.com
 (172.18.146.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 23 Jul
 2019 21:05:15 +0000
Received: from hqnvemgw01.nvidia.com (172.20.150.20) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3 via Frontend
 Transport; Tue, 23 Jul 2019 21:05:15 +0000
Received: from rcampbell-dev.nvidia.com (Not Verified[10.110.48.66]) by hqnvemgw01.nvidia.com with Trustwave SEG (v7,5,8,10121)
	id <B5d37768b0007>; Tue, 23 Jul 2019 14:05:15 -0700
From: Ralph Campbell <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, <nouveau@lists.freedesktop.org>,
	<dri-devel@lists.freedesktop.org>, Ralph Campbell <rcampbell@nvidia.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Jason Gunthorpe
	<jgg@mellanox.com>, Christoph Hellwig <hch@lst.de>, Ben Skeggs
	<bskeggs@redhat.com>
Subject: [PATCH] mm/hmm: replace hmm_update with mmu_notifier_range
Date: Tue, 23 Jul 2019 14:05:06 -0700
Message-ID: <20190723210506.25127-1-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563915926; bh=rjC23JCqCu60sr5rHPIEAf4LwcRnQlVgUeBq46RAZu0=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:X-NVConfidentiality:Content-Type:
	 Content-Transfer-Encoding;
	b=clAJYjoGcvm398sj1Wc6QXusiqBt2h19IERPM5F4BhNYeDY+Dl6DDwBYlRyMojqx+
	 c78VwtXD7Iv1yCqHRNgQfoil9L/CJeqNtFHc0X0XyG4GXjuYaz5gBl8CGO4s+5vG2n
	 CX4bMazKSJZNVT4zgw9o4KOsejlQxYkY51ka1c/w525wmDsg+GvZ+2iOtPZAAycHW2
	 PuiTQhdhxPI00ooFnzLrElgS9azGgL4fNNdFxjrfi/lWQQuJwmNmhB+gI8is6+btQD
	 GoBt7AUMqR++W4l1w/ceYVCZpevJIRWuq+JMZmaIj+nNc1TdjVpENd0m3IS25SlgiQ
	 WmQGHhmhtcnBQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The hmm_mirror_ops callback function sync_cpu_device_pagetables() passes
a struct hmm_update which is a simplified version of struct
mmu_notifier_range. This is unnecessary so replace hmm_update with
mmu_notifier_range directly.

Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Ben Skeggs <bskeggs@redhat.com>
---

This is based on 5.3.0-rc1 plus Christoph Hellwig's 6 patches
("hmm_range_fault related fixes and legacy API removal v2").
Jason, I believe this is the patch you were requesting.

 drivers/gpu/drm/nouveau/nouveau_svm.c |  4 ++--
 include/linux/hmm.h                   | 31 ++++-----------------------
 mm/hmm.c                              | 13 ++++-------
 3 files changed, 10 insertions(+), 38 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouvea=
u/nouveau_svm.c
index a9c5c58d425b..6298d2dadb55 100644
--- a/drivers/gpu/drm/nouveau/nouveau_svm.c
+++ b/drivers/gpu/drm/nouveau/nouveau_svm.c
@@ -252,13 +252,13 @@ nouveau_svmm_invalidate(struct nouveau_svmm *svmm, u6=
4 start, u64 limit)
=20
 static int
 nouveau_svmm_sync_cpu_device_pagetables(struct hmm_mirror *mirror,
-					const struct hmm_update *update)
+					const struct mmu_notifier_range *update)
 {
 	struct nouveau_svmm *svmm =3D container_of(mirror, typeof(*svmm), mirror)=
;
 	unsigned long start =3D update->start;
 	unsigned long limit =3D update->end;
=20
-	if (!update->blockable)
+	if (!mmu_notifier_range_blockable(update))
 		return -EAGAIN;
=20
 	SVMM_DBG(svmm, "invalidate %016lx-%016lx", start, limit);
diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 9f32586684c9..659e25a15700 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -340,29 +340,6 @@ static inline uint64_t hmm_device_entry_from_pfn(const=
 struct hmm_range *range,
=20
 struct hmm_mirror;
=20
-/*
- * enum hmm_update_event - type of update
- * @HMM_UPDATE_INVALIDATE: invalidate range (no indication as to why)
- */
-enum hmm_update_event {
-	HMM_UPDATE_INVALIDATE,
-};
-
-/*
- * struct hmm_update - HMM update information for callback
- *
- * @start: virtual start address of the range to update
- * @end: virtual end address of the range to update
- * @event: event triggering the update (what is happening)
- * @blockable: can the callback block/sleep ?
- */
-struct hmm_update {
-	unsigned long start;
-	unsigned long end;
-	enum hmm_update_event event;
-	bool blockable;
-};
-
 /*
  * struct hmm_mirror_ops - HMM mirror device operations callback
  *
@@ -383,9 +360,9 @@ struct hmm_mirror_ops {
 	/* sync_cpu_device_pagetables() - synchronize page tables
 	 *
 	 * @mirror: pointer to struct hmm_mirror
-	 * @update: update information (see struct hmm_update)
-	 * Return: -EAGAIN if update.blockable false and callback need to
-	 *          block, 0 otherwise.
+	 * @update: update information (see struct mmu_notifier_range)
+	 * Return: -EAGAIN if mmu_notifier_range_blockable(update) is false
+	 * and callback needs to block, 0 otherwise.
 	 *
 	 * This callback ultimately originates from mmu_notifiers when the CPU
 	 * page table is updated. The device driver must update its page table
@@ -397,7 +374,7 @@ struct hmm_mirror_ops {
 	 * synchronous call.
 	 */
 	int (*sync_cpu_device_pagetables)(struct hmm_mirror *mirror,
-					  const struct hmm_update *update);
+				const struct mmu_notifier_range *update);
 };
=20
 /*
diff --git a/mm/hmm.c b/mm/hmm.c
index 16b6731a34db..b810a4fa3de9 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -165,7 +165,6 @@ static int hmm_invalidate_range_start(struct mmu_notifi=
er *mn,
 {
 	struct hmm *hmm =3D container_of(mn, struct hmm, mmu_notifier);
 	struct hmm_mirror *mirror;
-	struct hmm_update update;
 	struct hmm_range *range;
 	unsigned long flags;
 	int ret =3D 0;
@@ -173,15 +172,10 @@ static int hmm_invalidate_range_start(struct mmu_noti=
fier *mn,
 	if (!kref_get_unless_zero(&hmm->kref))
 		return 0;
=20
-	update.start =3D nrange->start;
-	update.end =3D nrange->end;
-	update.event =3D HMM_UPDATE_INVALIDATE;
-	update.blockable =3D mmu_notifier_range_blockable(nrange);
-
 	spin_lock_irqsave(&hmm->ranges_lock, flags);
 	hmm->notifiers++;
 	list_for_each_entry(range, &hmm->ranges, list) {
-		if (update.end < range->start || update.start >=3D range->end)
+		if (nrange->end < range->start || nrange->start >=3D range->end)
 			continue;
=20
 		range->valid =3D false;
@@ -198,9 +192,10 @@ static int hmm_invalidate_range_start(struct mmu_notif=
ier *mn,
 	list_for_each_entry(mirror, &hmm->mirrors, list) {
 		int rc;
=20
-		rc =3D mirror->ops->sync_cpu_device_pagetables(mirror, &update);
+		rc =3D mirror->ops->sync_cpu_device_pagetables(mirror, nrange);
 		if (rc) {
-			if (WARN_ON(update.blockable || rc !=3D -EAGAIN))
+			if (WARN_ON(mmu_notifier_range_blockable(nrange) ||
+			    rc !=3D -EAGAIN))
 				continue;
 			ret =3D -EAGAIN;
 			break;
--=20
2.20.1

