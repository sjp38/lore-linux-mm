Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2D35C0650F
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 07:59:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 819C4208C2
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 07:59:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ij9LwdqH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 819C4208C2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 305BD6B000A; Wed, 14 Aug 2019 03:59:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 21BCD6B000C; Wed, 14 Aug 2019 03:59:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0DF426B000D; Wed, 14 Aug 2019 03:59:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0117.hostedemail.com [216.40.44.117])
	by kanga.kvack.org (Postfix) with ESMTP id E155D6B000A
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 03:59:49 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 944C0181AC9B6
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 07:59:49 +0000 (UTC)
X-FDA: 75820284498.16.laugh24_55bfa7a68a23e
X-HE-Tag: laugh24_55bfa7a68a23e
X-Filterd-Recvd-Size: 4323
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 07:59:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=13C43s4pw+qYxbSiHBqNJBxy3y8L+AabNOPsvifMBs4=; b=ij9LwdqHGLo4wrAxd8rG6Kb6yC
	fER/ySeZKiiT3l5Qqoxhu5pFNrhI1H/Txm7yGmYQe1PONZmTZgaNvzpVzv3eT1Qo94j2ISZL46tzZ
	+0Tr31Az6V5GVb5f5sO12tVJiYRYd7TYYW789M1i9bCww8eGuVQ6nlYYaNr/6LQIZxnSrAHY52dXp
	GqKtRq/VM09VRrnKsx8Ff6KFihMdQd+6wwRu4wfVdD/EgL++Myvvf6mVeE7fzE1yfIHtRBPpCbL5S
	nIGPkY4wGoR5fbhlKn3C6KcJTgQrniIWJ4gqUDyVLx05oULJ5uD85VZ3wf/zBY0IVv2d9pTqVTog5
	MOXeCnmA==;
Received: from [2001:4bb8:180:1ec3:c70:4a89:bc61:2] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hxoC8-00080x-Et; Wed, 14 Aug 2019 07:59:45 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 04/10] nouveau: factor out dmem fence completion
Date: Wed, 14 Aug 2019 09:59:22 +0200
Message-Id: <20190814075928.23766-5-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190814075928.23766-1-hch@lst.de>
References: <20190814075928.23766-1-hch@lst.de>
MIME-Version: 1.0
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Factor out the end of fencing logic from the two migration routines.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
---
 drivers/gpu/drm/nouveau/nouveau_dmem.c | 33 ++++++++++++--------------
 1 file changed, 15 insertions(+), 18 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_dmem.c b/drivers/gpu/drm/nou=
veau/nouveau_dmem.c
index d469bc334438..21052a4aaf69 100644
--- a/drivers/gpu/drm/nouveau/nouveau_dmem.c
+++ b/drivers/gpu/drm/nouveau/nouveau_dmem.c
@@ -133,6 +133,19 @@ static void nouveau_dmem_page_free(struct page *page=
)
 	spin_unlock(&chunk->lock);
 }
=20
+static void nouveau_dmem_fence_done(struct nouveau_fence **fence)
+{
+	if (fence) {
+		nouveau_fence_wait(*fence, true, false);
+		nouveau_fence_unref(fence);
+	} else {
+		/*
+		 * FIXME wait for channel to be IDLE before calling finalizing
+		 * the hmem object.
+		 */
+	}
+}
+
 static void
 nouveau_dmem_fault_alloc_and_copy(struct vm_area_struct *vma,
 				  const unsigned long *src_pfns,
@@ -236,15 +249,7 @@ nouveau_dmem_fault_finalize_and_map(struct nouveau_d=
mem_fault *fault)
 {
 	struct nouveau_drm *drm =3D fault->drm;
=20
-	if (fault->fence) {
-		nouveau_fence_wait(fault->fence, true, false);
-		nouveau_fence_unref(&fault->fence);
-	} else {
-		/*
-		 * FIXME wait for channel to be IDLE before calling finalizing
-		 * the hmem object below (nouveau_migrate_hmem_fini()).
-		 */
-	}
+	nouveau_dmem_fence_done(&fault->fence);
=20
 	while (fault->npages--) {
 		dma_unmap_page(drm->dev->dev, fault->dma[fault->npages],
@@ -748,15 +753,7 @@ nouveau_dmem_migrate_finalize_and_map(struct nouveau=
_migrate *migrate)
 {
 	struct nouveau_drm *drm =3D migrate->drm;
=20
-	if (migrate->fence) {
-		nouveau_fence_wait(migrate->fence, true, false);
-		nouveau_fence_unref(&migrate->fence);
-	} else {
-		/*
-		 * FIXME wait for channel to be IDLE before finalizing
-		 * the hmem object below (nouveau_migrate_hmem_fini()) ?
-		 */
-	}
+	nouveau_dmem_fence_done(&migrate->fence);
=20
 	while (migrate->dma_nr--) {
 		dma_unmap_page(drm->dev->dev, migrate->dma[migrate->dma_nr],
--=20
2.20.1


