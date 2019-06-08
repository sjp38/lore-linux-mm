Return-Path: <SRS0=+Baj=UH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D30FC2BCA1
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 00:15:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD22120868
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 00:15:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="SQ11Ml7m"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD22120868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 72DFF6B0279; Fri,  7 Jun 2019 20:15:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6DE1B6B027A; Fri,  7 Jun 2019 20:15:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5CDB86B027B; Fri,  7 Jun 2019 20:15:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3CCC66B0279
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 20:15:07 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id j68so3627623ywj.4
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 17:15:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding:dkim-signature;
        bh=jjTMN2tDk2DnfrJ4AiOM/WxsV6jt0FXZOA5qIWGi5Vo=;
        b=DBiub/ZjZEIxpZPFNsJ4uGblbzrw9plrR9nocQp8CY5cOLUF0YFCBuRyreyZawDzs6
         1zdjHu+pcGaKrGGHCok8T23Ij6UOTfD7V/X7ZQKWuH/jqIAC5uoc2w0RKkUyK+QqualT
         ox4BKrbh7du3ntv2C/v+SD8Aycrjlk3E4wZKDMHQYQb4Ek0yengiWJH4R154icn323PE
         wJ8oaoKQUPCatNM1U6szGyEjpXr2uCq225Nm7MQ8OmRiQwHeLxM7lEequyEA6/v59WPt
         OfwLiWRINrIvI/EteDAoZilaVVr9TpNfo0v5utLQA+030rdFpkaV2e+YXxcx5K/fN+Cd
         NTXA==
X-Gm-Message-State: APjAAAWlSWgmpjXkAey07oP2dbvPGu2WE7NWmAkB//n7c8ibUPn5wWDq
	XXz9JOKi7J79qrPxDtvKRzVfMTzwM0fmlOpP+RF5srwrd14zgl6Z0so0JrP6e2MLYRLSEDsOf2q
	X82CN14zmA5mlyXc4yAJBPOrSP+ZkwYayC/aHnTYmP3HWl3iGUUj9F9gGxCPWducXMw==
X-Received: by 2002:a81:4f91:: with SMTP id d139mr8476351ywb.146.1559952907001;
        Fri, 07 Jun 2019 17:15:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzaPz+DKZ8eJh6YmC65Z7rRA5Ri19ePoQnTrJwqkA3IgklHfjbK6vWraI5yiVpQU7ZXKd3T
X-Received: by 2002:a81:4f91:: with SMTP id d139mr8476320ywb.146.1559952906239;
        Fri, 07 Jun 2019 17:15:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559952906; cv=none;
        d=google.com; s=arc-20160816;
        b=0/G67NIQWnTBpyWtIr1hWdosGuQyTfdWbnpoePVZ/zdt698ubM/IDRIoQa6kW5cSJd
         ahdTXw5d7O5TvXLrZSFci/4jwuFKRVG4vSuHMQILbmZaDcRRXX8SLRXAs5CiYZDZ3Aza
         E/vux2JpQ3aF68HHb1YLlDsoJpe5/n1qAJClSLt7EmqYhVDVMRHd7W+ee26qxZwGneXX
         5aZwYK+20wbSnNQgBfroGx6U1w0jUFNfc8MsWvpez5edCfNGEGMmFqU6nhJT6m2e0T6u
         x50MZTTG2Kokr1S5lBDamNzUH2SfInHuGWFZgCBQRVqFlvgRe1EoCermkDhpgHDrh1II
         F4fg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:message-id
         :date:subject:cc:to:from;
        bh=jjTMN2tDk2DnfrJ4AiOM/WxsV6jt0FXZOA5qIWGi5Vo=;
        b=IeQ83czUpKb+GXF9ba5CfXyM041yeVjqeNYUYH8X1LIDJB109xc7WucUjJagPHJARQ
         dm2bs3FBQ2wdH4XFMD5FnJVhfpijaq0LgD1ri7EHUs2m3GfL/LaHyfLQZtp835JY4e9h
         TQDH18xtIgKEUU46lo5QVHEJgHDshCWh8BXfyTrzMWUubwNimBg2kxxUNP5ycyrePCLg
         pP1ue2wxGvI0jfAUGUqgvZBohYtzhexKNJJpDhqyTRiOe0TnSMdBGR8iq4XJkoZldLy4
         n9FNbBrvb13PtfioTTVPjlvxhRYQLn1y8njBIMAbFWatgVKYkp+/nlntHQj6k4gWQG9U
         Tn+w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=SQ11Ml7m;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id u18si1061773ywc.70.2019.06.07.17.15.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 17:15:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=SQ11Ml7m;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cfafe070000>; Fri, 07 Jun 2019 17:15:03 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 07 Jun 2019 17:15:05 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 07 Jun 2019 17:15:05 -0700
Received: from HQMAIL101.nvidia.com (172.20.187.10) by HQMAIL108.nvidia.com
 (172.18.146.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Sat, 8 Jun
 2019 00:14:59 +0000
Received: from hqnvemgw01.nvidia.com (172.20.150.20) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3 via Frontend
 Transport; Sat, 8 Jun 2019 00:14:59 +0000
Received: from rcampbell-dev.nvidia.com (Not Verified[10.110.48.66]) by hqnvemgw01.nvidia.com with Trustwave SEG (v7,5,8,10121)
	id <B5cfafe030001>; Fri, 07 Jun 2019 17:14:59 -0700
From: Ralph Campbell <rcampbell@nvidia.com>
To: Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>,
	<Felix.Kuehling@amd.com>, Jason Gunthorpe <jgg@mellanox.com>
CC: <linux-rdma@vger.kernel.org>, <linux-mm@kvack.org>, Andrea Arcangeli
	<aarcange@redhat.com>, <dri-devel@lists.freedesktop.org>,
	<amd-gfx@lists.freedesktop.org>, Ralph Campbell <rcampbell@nvidia.com>
Subject: [RFC] mm/hmm: pass mmu_notifier_range to sync_cpu_device_pagetables
Date: Fri, 7 Jun 2019 17:14:52 -0700
Message-ID: <20190608001452.7922-1-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559952903; bh=jjTMN2tDk2DnfrJ4AiOM/WxsV6jt0FXZOA5qIWGi5Vo=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:X-NVConfidentiality:Content-Transfer-Encoding:
	 Content-Type;
	b=SQ11Ml7mtU/VVPx6gJwSisurSRky6JAGtlAhDA3ya7KnsP+2Me9XdeQy0dl1/UoMN
	 xv+0zFG5tik4y8rSVn5cofTeuqlqujlwsB//FH0By1uUSUvO7ycUIG0wW3FapovgKa
	 0fgRjWS1C3zMfwBfxYIDpEYpQ75A8cZp3tc7J8DR0BHNMLA2r6uHj4FFGAjh7AxA7v
	 IWvDBx+zGF8diRe5AyZGqdAEsVBWyz3rszufqbSV5jqPmoYCAOc/vHJCe10E6K4ZkJ
	 rsy8vxbGy5RxTm7tuWyiuduAXKyz+pNxC80+VL4H5GF4RhQPhyKDFw8nr1yhTTckBa
	 DnZ96Pvym7CFw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

HMM defines its own struct hmm_update which is passed to the
sync_cpu_device_pagetables() callback function. This is
sufficient when the only action is to invalidate. However,
a device may want to know the reason for the invalidation and
be able to see the new permissions on a range, update device access
rights or range statistics. Since sync_cpu_device_pagetables()
can be called from try_to_unmap(), the mmap_sem may not be held
and find_vma() is not safe to be called.
Pass the struct mmu_notifier_range to sync_cpu_device_pagetables()
to allow the full invalidation information to be used.

Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
---

I'm sending this out now since we are updating many of the HMM APIs
and I think it will be useful.


 drivers/gpu/drm/nouveau/nouveau_svm.c |  4 ++--
 include/linux/hmm.h                   | 27 ++-------------------------
 mm/hmm.c                              | 13 ++++---------
 3 files changed, 8 insertions(+), 36 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouvea=
u/nouveau_svm.c
index 8c92374afcf2..c34b98fafe2f 100644
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
index 0fa8ea34ccef..07a2d38fde34 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -377,29 +377,6 @@ static inline uint64_t hmm_pfn_from_pfn(const struct h=
mm_range *range,
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
@@ -420,7 +397,7 @@ struct hmm_mirror_ops {
 	/* sync_cpu_device_pagetables() - synchronize page tables
 	 *
 	 * @mirror: pointer to struct hmm_mirror
-	 * @update: update information (see struct hmm_update)
+	 * @update: update information (see struct mmu_notifier_range)
 	 * Return: -EAGAIN if update.blockable false and callback need to
 	 *          block, 0 otherwise.
 	 *
@@ -434,7 +411,7 @@ struct hmm_mirror_ops {
 	 * synchronous call.
 	 */
 	int (*sync_cpu_device_pagetables)(struct hmm_mirror *mirror,
-					  const struct hmm_update *update);
+				const struct mmu_notifier_range *update);
 };
=20
 /*
diff --git a/mm/hmm.c b/mm/hmm.c
index 9aad3550f2bb..b49a43712554 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -164,7 +164,6 @@ static int hmm_invalidate_range_start(struct mmu_notifi=
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
+				    rc !=3D -EAGAIN))
 				continue;
 			ret =3D -EAGAIN;
 			break;
--=20
2.20.1

