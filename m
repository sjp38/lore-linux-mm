Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 29AD36B0024
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 22:22:03 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id r33so3627705qkh.2
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 19:22:03 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id i58si2269142qtf.189.2018.03.09.19.22.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Mar 2018 19:22:02 -0800 (PST)
From: jglisse@redhat.com
Subject: [RFC PATCH 13/13] drm/nouveau: HACK FOR HMM AREA
Date: Fri,  9 Mar 2018 22:21:41 -0500
Message-Id: <20180310032141.6096-14-jglisse@redhat.com>
In-Reply-To: <20180310032141.6096-1-jglisse@redhat.com>
References: <20180310032141.6096-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dri-devel@lists.freedesktop.org, nouveau@lists.freedesktop.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Allow userspace to create a virtual address range hole for GEM
object.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 drivers/gpu/drm/nouveau/nouveau_ttm.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_ttm.c b/drivers/gpu/drm/nouveau/nouveau_ttm.c
index dff51a0ee028..eafde4c6b7d4 100644
--- a/drivers/gpu/drm/nouveau/nouveau_ttm.c
+++ b/drivers/gpu/drm/nouveau/nouveau_ttm.c
@@ -172,6 +172,13 @@ nouveau_ttm_mmap(struct file *filp, struct vm_area_struct *vma)
 	if (unlikely(vma->vm_pgoff < DRM_FILE_PAGE_OFFSET))
 		return drm_legacy_mmap(filp, vma);
 
+	/* Hack for HMM */
+	if (vma->vm_pgoff < (DRM_FILE_PAGE_OFFSET + (4UL << 30))) {
+		struct nouveau_cli *cli = file_priv->driver_priv;
+
+		return nouveau_vmm_hmm(cli, filp, vma);
+	}
+
 	return ttm_bo_mmap(filp, vma, &drm->ttm.bdev);
 }
 
@@ -305,7 +312,7 @@ nouveau_ttm_init(struct nouveau_drm *drm)
 				  drm->ttm.bo_global_ref.ref.object,
 				  &nouveau_bo_driver,
 				  dev->anon_inode->i_mapping,
-				  DRM_FILE_PAGE_OFFSET,
+				  DRM_FILE_PAGE_OFFSET + (4UL << 30),
 				  drm->client.mmu.dmabits <= 32 ? true : false);
 	if (ret) {
 		NV_ERROR(drm, "error initialising bo driver, %d\n", ret);
-- 
2.14.3
