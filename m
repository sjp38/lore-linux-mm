Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7393E6B0008
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 22:21:58 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id r67so305235qkf.19
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 19:21:58 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id u53si2204712qtb.192.2018.03.09.19.21.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Mar 2018 19:21:57 -0800 (PST)
From: jglisse@redhat.com
Subject: [RFC PATCH 03/13] drm/nouveau/core: define engine for handling replayable faults
Date: Fri,  9 Mar 2018 22:21:31 -0500
Message-Id: <20180310032141.6096-4-jglisse@redhat.com>
In-Reply-To: <20180310032141.6096-1-jglisse@redhat.com>
References: <20180310032141.6096-1-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dri-devel@lists.freedesktop.org, nouveau@lists.freedesktop.org
Cc: Ben Skeggs <bskeggs@redhat.com>, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>

From: Ben Skeggs <bskeggs@redhat.com>

Signed-off-by: Ben Skeggs <bskeggs@redhat.com>
---
 drivers/gpu/drm/nouveau/include/nvkm/core/device.h  | 3 +++
 drivers/gpu/drm/nouveau/include/nvkm/engine/fault.h | 4 ++++
 drivers/gpu/drm/nouveau/nvkm/core/subdev.c          | 1 +
 drivers/gpu/drm/nouveau/nvkm/engine/Kbuild          | 1 +
 drivers/gpu/drm/nouveau/nvkm/engine/device/base.c   | 2 ++
 drivers/gpu/drm/nouveau/nvkm/engine/device/priv.h   | 1 +
 drivers/gpu/drm/nouveau/nvkm/engine/fault/Kbuild    | 0
 7 files changed, 12 insertions(+)
 create mode 100644 drivers/gpu/drm/nouveau/include/nvkm/engine/fault.h
 create mode 100644 drivers/gpu/drm/nouveau/nvkm/engine/fault/Kbuild

diff --git a/drivers/gpu/drm/nouveau/include/nvkm/core/device.h b/drivers/gpu/drm/nouveau/include/nvkm/core/device.h
index 560265b15ec2..de3d2566ee4d 100644
--- a/drivers/gpu/drm/nouveau/include/nvkm/core/device.h
+++ b/drivers/gpu/drm/nouveau/include/nvkm/core/device.h
@@ -42,6 +42,7 @@ enum nvkm_devidx {
 	NVKM_ENGINE_CIPHER,
 	NVKM_ENGINE_DISP,
 	NVKM_ENGINE_DMAOBJ,
+	NVKM_ENGINE_FAULT,
 	NVKM_ENGINE_FIFO,
 	NVKM_ENGINE_GR,
 	NVKM_ENGINE_IFB,
@@ -147,6 +148,7 @@ struct nvkm_device {
 	struct nvkm_engine *cipher;
 	struct nvkm_disp *disp;
 	struct nvkm_dma *dma;
+	struct nvkm_engine *fault;
 	struct nvkm_fifo *fifo;
 	struct nvkm_gr *gr;
 	struct nvkm_engine *ifb;
@@ -218,6 +220,7 @@ struct nvkm_device_chip {
 	int (*cipher  )(struct nvkm_device *, int idx, struct nvkm_engine **);
 	int (*disp    )(struct nvkm_device *, int idx, struct nvkm_disp **);
 	int (*dma     )(struct nvkm_device *, int idx, struct nvkm_dma **);
+	int (*fault   )(struct nvkm_device *, int idx, struct nvkm_engine **);
 	int (*fifo    )(struct nvkm_device *, int idx, struct nvkm_fifo **);
 	int (*gr      )(struct nvkm_device *, int idx, struct nvkm_gr **);
 	int (*ifb     )(struct nvkm_device *, int idx, struct nvkm_engine **);
diff --git a/drivers/gpu/drm/nouveau/include/nvkm/engine/fault.h b/drivers/gpu/drm/nouveau/include/nvkm/engine/fault.h
new file mode 100644
index 000000000000..398ca5a02eee
--- /dev/null
+++ b/drivers/gpu/drm/nouveau/include/nvkm/engine/fault.h
@@ -0,0 +1,4 @@
+#ifndef __NVKM_FAULT_H__
+#define __NVKM_FAULT_H__
+#include <core/engine.h>
+#endif
diff --git a/drivers/gpu/drm/nouveau/nvkm/core/subdev.c b/drivers/gpu/drm/nouveau/nvkm/core/subdev.c
index a134d225f958..0d50b2206da2 100644
--- a/drivers/gpu/drm/nouveau/nvkm/core/subdev.c
+++ b/drivers/gpu/drm/nouveau/nvkm/core/subdev.c
@@ -63,6 +63,7 @@ nvkm_subdev_name[NVKM_SUBDEV_NR] = {
 	[NVKM_ENGINE_CIPHER  ] = "cipher",
 	[NVKM_ENGINE_DISP    ] = "disp",
 	[NVKM_ENGINE_DMAOBJ  ] = "dma",
+	[NVKM_ENGINE_FAULT   ] = "fault",
 	[NVKM_ENGINE_FIFO    ] = "fifo",
 	[NVKM_ENGINE_GR      ] = "gr",
 	[NVKM_ENGINE_IFB     ] = "ifb",
diff --git a/drivers/gpu/drm/nouveau/nvkm/engine/Kbuild b/drivers/gpu/drm/nouveau/nvkm/engine/Kbuild
index 78571e8b01c5..3aa90a6d5392 100644
--- a/drivers/gpu/drm/nouveau/nvkm/engine/Kbuild
+++ b/drivers/gpu/drm/nouveau/nvkm/engine/Kbuild
@@ -7,6 +7,7 @@ include $(src)/nvkm/engine/cipher/Kbuild
 include $(src)/nvkm/engine/device/Kbuild
 include $(src)/nvkm/engine/disp/Kbuild
 include $(src)/nvkm/engine/dma/Kbuild
+include $(src)/nvkm/engine/fault/Kbuild
 include $(src)/nvkm/engine/fifo/Kbuild
 include $(src)/nvkm/engine/gr/Kbuild
 include $(src)/nvkm/engine/mpeg/Kbuild
diff --git a/drivers/gpu/drm/nouveau/nvkm/engine/device/base.c b/drivers/gpu/drm/nouveau/nvkm/engine/device/base.c
index 05cd674326a6..2fe862ac0d95 100644
--- a/drivers/gpu/drm/nouveau/nvkm/engine/device/base.c
+++ b/drivers/gpu/drm/nouveau/nvkm/engine/device/base.c
@@ -2466,6 +2466,7 @@ nvkm_device_engine(struct nvkm_device *device, int index)
 	_(CIPHER , device->cipher  ,  device->cipher);
 	_(DISP   , device->disp    , &device->disp->engine);
 	_(DMAOBJ , device->dma     , &device->dma->engine);
+	_(FAULT  , device->fault   ,  device->fault);
 	_(FIFO   , device->fifo    , &device->fifo->engine);
 	_(GR     , device->gr      , &device->gr->engine);
 	_(IFB    , device->ifb     ,  device->ifb);
@@ -2919,6 +2920,7 @@ nvkm_device_ctor(const struct nvkm_device_func *func,
 		_(NVKM_ENGINE_CIPHER  ,   cipher);
 		_(NVKM_ENGINE_DISP    ,     disp);
 		_(NVKM_ENGINE_DMAOBJ  ,      dma);
+		_(NVKM_ENGINE_FAULT   ,    fault);
 		_(NVKM_ENGINE_FIFO    ,     fifo);
 		_(NVKM_ENGINE_GR      ,       gr);
 		_(NVKM_ENGINE_IFB     ,      ifb);
diff --git a/drivers/gpu/drm/nouveau/nvkm/engine/device/priv.h b/drivers/gpu/drm/nouveau/nvkm/engine/device/priv.h
index 08d0bf605722..3be45ac6e58d 100644
--- a/drivers/gpu/drm/nouveau/nvkm/engine/device/priv.h
+++ b/drivers/gpu/drm/nouveau/nvkm/engine/device/priv.h
@@ -32,6 +32,7 @@
 #include <engine/cipher.h>
 #include <engine/disp.h>
 #include <engine/dma.h>
+#include <engine/fault.h>
 #include <engine/fifo.h>
 #include <engine/gr.h>
 #include <engine/mpeg.h>
diff --git a/drivers/gpu/drm/nouveau/nvkm/engine/fault/Kbuild b/drivers/gpu/drm/nouveau/nvkm/engine/fault/Kbuild
new file mode 100644
index 000000000000..e69de29bb2d1
-- 
2.14.3
