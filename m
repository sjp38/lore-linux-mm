Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 759BC6B0008
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 22:21:59 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id f143so3593249qke.12
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 19:21:59 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id g21si2191797qtc.342.2018.03.09.19.21.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Mar 2018 19:21:58 -0800 (PST)
From: jglisse@redhat.com
Subject: [RFC PATCH 05/13] drm/nouveau/mc/gp100-: handle replayable fault interrupt
Date: Fri,  9 Mar 2018 22:21:33 -0500
Message-Id: <20180310032141.6096-6-jglisse@redhat.com>
In-Reply-To: <20180310032141.6096-1-jglisse@redhat.com>
References: <20180310032141.6096-1-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dri-devel@lists.freedesktop.org, nouveau@lists.freedesktop.org
Cc: Ben Skeggs <bskeggs@redhat.com>, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>

From: Ben Skeggs <bskeggs@redhat.com>

Signed-off-by: Ben Skeggs <bskeggs@redhat.com>
---
 drivers/gpu/drm/nouveau/nvkm/subdev/mc/gp100.c | 20 +++++++++++++++++++-
 drivers/gpu/drm/nouveau/nvkm/subdev/mc/gp10b.c |  2 +-
 drivers/gpu/drm/nouveau/nvkm/subdev/mc/priv.h  |  2 ++
 3 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nvkm/subdev/mc/gp100.c b/drivers/gpu/drm/nouveau/nvkm/subdev/mc/gp100.c
index 7321ad3758c3..9ab5bfe1e588 100644
--- a/drivers/gpu/drm/nouveau/nvkm/subdev/mc/gp100.c
+++ b/drivers/gpu/drm/nouveau/nvkm/subdev/mc/gp100.c
@@ -75,10 +75,28 @@ gp100_mc_intr_mask(struct nvkm_mc *base, u32 mask, u32 intr)
 	spin_unlock_irqrestore(&mc->lock, flags);
 }
 
+const struct nvkm_mc_map
+gp100_mc_intr[] = {
+	{ 0x04000000, NVKM_ENGINE_DISP },
+	{ 0x00000100, NVKM_ENGINE_FIFO },
+	{ 0x00000200, NVKM_ENGINE_FAULT },
+	{ 0x40000000, NVKM_SUBDEV_IBUS },
+	{ 0x10000000, NVKM_SUBDEV_BUS },
+	{ 0x08000000, NVKM_SUBDEV_FB },
+	{ 0x02000000, NVKM_SUBDEV_LTC },
+	{ 0x01000000, NVKM_SUBDEV_PMU },
+	{ 0x00200000, NVKM_SUBDEV_GPIO },
+	{ 0x00200000, NVKM_SUBDEV_I2C },
+	{ 0x00100000, NVKM_SUBDEV_TIMER },
+	{ 0x00040000, NVKM_SUBDEV_THERM },
+	{ 0x00002000, NVKM_SUBDEV_FB },
+	{},
+};
+
 static const struct nvkm_mc_func
 gp100_mc = {
 	.init = nv50_mc_init,
-	.intr = gk104_mc_intr,
+	.intr = gp100_mc_intr,
 	.intr_unarm = gp100_mc_intr_unarm,
 	.intr_rearm = gp100_mc_intr_rearm,
 	.intr_mask = gp100_mc_intr_mask,
diff --git a/drivers/gpu/drm/nouveau/nvkm/subdev/mc/gp10b.c b/drivers/gpu/drm/nouveau/nvkm/subdev/mc/gp10b.c
index 2283e3b74277..ff8629de97d6 100644
--- a/drivers/gpu/drm/nouveau/nvkm/subdev/mc/gp10b.c
+++ b/drivers/gpu/drm/nouveau/nvkm/subdev/mc/gp10b.c
@@ -34,7 +34,7 @@ gp10b_mc_init(struct nvkm_mc *mc)
 static const struct nvkm_mc_func
 gp10b_mc = {
 	.init = gp10b_mc_init,
-	.intr = gk104_mc_intr,
+	.intr = gp100_mc_intr,
 	.intr_unarm = gp100_mc_intr_unarm,
 	.intr_rearm = gp100_mc_intr_rearm,
 	.intr_mask = gp100_mc_intr_mask,
diff --git a/drivers/gpu/drm/nouveau/nvkm/subdev/mc/priv.h b/drivers/gpu/drm/nouveau/nvkm/subdev/mc/priv.h
index 8869d79c2b59..d9e3691d45b7 100644
--- a/drivers/gpu/drm/nouveau/nvkm/subdev/mc/priv.h
+++ b/drivers/gpu/drm/nouveau/nvkm/subdev/mc/priv.h
@@ -57,4 +57,6 @@ int gp100_mc_new_(const struct nvkm_mc_func *, struct nvkm_device *, int,
 
 extern const struct nvkm_mc_map gk104_mc_intr[];
 extern const struct nvkm_mc_map gk104_mc_reset[];
+
+extern const struct nvkm_mc_map gp100_mc_intr[];
 #endif
-- 
2.14.3
