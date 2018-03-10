Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 67D656B000A
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 22:22:00 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id d128so3607273qkb.6
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 19:22:00 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 90si920010qkv.430.2018.03.09.19.21.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Mar 2018 19:21:58 -0800 (PST)
From: jglisse@redhat.com
Subject: [RFC PATCH 06/13] drm/nouveau/fault/gp100: initial implementation of MaxwellFaultBufferA
Date: Fri,  9 Mar 2018 22:21:34 -0500
Message-Id: <20180310032141.6096-7-jglisse@redhat.com>
In-Reply-To: <20180310032141.6096-1-jglisse@redhat.com>
References: <20180310032141.6096-1-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dri-devel@lists.freedesktop.org, nouveau@lists.freedesktop.org
Cc: Ben Skeggs <bskeggs@redhat.com>, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>

From: Ben Skeggs <bskeggs@redhat.com>

Signed-off-by: Ben Skeggs <bskeggs@redhat.com>
---
 drivers/gpu/drm/nouveau/include/nvif/class.h       |   2 +
 drivers/gpu/drm/nouveau/include/nvif/clb069.h      |   8 ++
 .../gpu/drm/nouveau/include/nvkm/engine/fault.h    |   1 +
 drivers/gpu/drm/nouveau/nvkm/engine/device/base.c  |   6 +
 drivers/gpu/drm/nouveau/nvkm/engine/device/user.c  |   1 +
 drivers/gpu/drm/nouveau/nvkm/engine/fault/Kbuild   |   4 +
 drivers/gpu/drm/nouveau/nvkm/engine/fault/base.c   | 116 ++++++++++++++++++
 drivers/gpu/drm/nouveau/nvkm/engine/fault/gp100.c  |  61 +++++++++
 drivers/gpu/drm/nouveau/nvkm/engine/fault/priv.h   |  29 +++++
 drivers/gpu/drm/nouveau/nvkm/engine/fault/user.c   | 136 +++++++++++++++++++++
 drivers/gpu/drm/nouveau/nvkm/engine/fault/user.h   |   7 ++
 11 files changed, 371 insertions(+)
 create mode 100644 drivers/gpu/drm/nouveau/include/nvif/clb069.h
 create mode 100644 drivers/gpu/drm/nouveau/nvkm/engine/fault/base.c
 create mode 100644 drivers/gpu/drm/nouveau/nvkm/engine/fault/gp100.c
 create mode 100644 drivers/gpu/drm/nouveau/nvkm/engine/fault/priv.h
 create mode 100644 drivers/gpu/drm/nouveau/nvkm/engine/fault/user.c
 create mode 100644 drivers/gpu/drm/nouveau/nvkm/engine/fault/user.h

diff --git a/drivers/gpu/drm/nouveau/include/nvif/class.h b/drivers/gpu/drm/nouveau/include/nvif/class.h
index a7c5bf572788..98ac250670b7 100644
--- a/drivers/gpu/drm/nouveau/include/nvif/class.h
+++ b/drivers/gpu/drm/nouveau/include/nvif/class.h
@@ -52,6 +52,8 @@
 
 #define NV04_DISP                                     /* cl0046.h */ 0x00000046
 
+#define MAXWELL_FAULT_BUFFER_A                        /* clb069.h */ 0x0000b069
+
 #define NV03_CHANNEL_DMA                              /* cl506b.h */ 0x0000006b
 #define NV10_CHANNEL_DMA                              /* cl506b.h */ 0x0000006e
 #define NV17_CHANNEL_DMA                              /* cl506b.h */ 0x0000176e
diff --git a/drivers/gpu/drm/nouveau/include/nvif/clb069.h b/drivers/gpu/drm/nouveau/include/nvif/clb069.h
new file mode 100644
index 000000000000..b0d509fd8631
--- /dev/null
+++ b/drivers/gpu/drm/nouveau/include/nvif/clb069.h
@@ -0,0 +1,8 @@
+#ifndef __NVIF_CLB069_H__
+#define __NVIF_CLB069_H__
+
+struct nvb069_vn {
+};
+
+#define NVB069_VN_NTFY_FAULT                                               0x00
+#endif
diff --git a/drivers/gpu/drm/nouveau/include/nvkm/engine/fault.h b/drivers/gpu/drm/nouveau/include/nvkm/engine/fault.h
index 398ca5a02eee..08893f13e2f9 100644
--- a/drivers/gpu/drm/nouveau/include/nvkm/engine/fault.h
+++ b/drivers/gpu/drm/nouveau/include/nvkm/engine/fault.h
@@ -1,4 +1,5 @@
 #ifndef __NVKM_FAULT_H__
 #define __NVKM_FAULT_H__
 #include <core/engine.h>
+int gp100_fault_new(struct nvkm_device *, int, struct nvkm_engine **);
 #endif
diff --git a/drivers/gpu/drm/nouveau/nvkm/engine/device/base.c b/drivers/gpu/drm/nouveau/nvkm/engine/device/base.c
index 2fe862ac0d95..ee67caf95a4e 100644
--- a/drivers/gpu/drm/nouveau/nvkm/engine/device/base.c
+++ b/drivers/gpu/drm/nouveau/nvkm/engine/device/base.c
@@ -2184,6 +2184,7 @@ nv130_chipset = {
 	.ce[5] = gp100_ce_new,
 	.dma = gf119_dma_new,
 	.disp = gp100_disp_new,
+	.fault = gp100_fault_new,
 	.fifo = gp100_fifo_new,
 	.gr = gp100_gr_new,
 	.sw = gf100_sw_new,
@@ -2217,6 +2218,7 @@ nv132_chipset = {
 	.ce[3] = gp102_ce_new,
 	.disp = gp102_disp_new,
 	.dma = gf119_dma_new,
+	.fault = gp100_fault_new,
 	.fifo = gp100_fifo_new,
 	.gr = gp102_gr_new,
 	.nvdec = gp102_nvdec_new,
@@ -2252,6 +2254,7 @@ nv134_chipset = {
 	.ce[3] = gp102_ce_new,
 	.disp = gp102_disp_new,
 	.dma = gf119_dma_new,
+	.fault = gp100_fault_new,
 	.fifo = gp100_fifo_new,
 	.gr = gp102_gr_new,
 	.nvdec = gp102_nvdec_new,
@@ -2287,6 +2290,7 @@ nv136_chipset = {
 	.ce[3] = gp102_ce_new,
 	.disp = gp102_disp_new,
 	.dma = gf119_dma_new,
+	.fault = gp100_fault_new,
 	.fifo = gp100_fifo_new,
 	.gr = gp102_gr_new,
 	.nvdec = gp102_nvdec_new,
@@ -2322,6 +2326,7 @@ nv137_chipset = {
 	.ce[3] = gp102_ce_new,
 	.disp = gp102_disp_new,
 	.dma = gf119_dma_new,
+	.fault = gp100_fault_new,
 	.fifo = gp100_fifo_new,
 	.gr = gp107_gr_new,
 	.nvdec = gp102_nvdec_new,
@@ -2382,6 +2387,7 @@ nv13b_chipset = {
 	.top = gk104_top_new,
 	.ce[2] = gp102_ce_new,
 	.dma = gf119_dma_new,
+	.fault = gp100_fault_new,
 	.fifo = gp10b_fifo_new,
 	.gr = gp10b_gr_new,
 	.sw = gf100_sw_new,
diff --git a/drivers/gpu/drm/nouveau/nvkm/engine/device/user.c b/drivers/gpu/drm/nouveau/nvkm/engine/device/user.c
index 17adcb4e8854..5eee439f615c 100644
--- a/drivers/gpu/drm/nouveau/nvkm/engine/device/user.c
+++ b/drivers/gpu/drm/nouveau/nvkm/engine/device/user.c
@@ -276,6 +276,7 @@ nvkm_udevice_child_get(struct nvkm_object *object, int index,
 	struct nvkm_device *device = udev->device;
 	struct nvkm_engine *engine;
 	u64 mask = (1ULL << NVKM_ENGINE_DMAOBJ) |
+		   (1ULL << NVKM_ENGINE_FAULT) |
 		   (1ULL << NVKM_ENGINE_FIFO) |
 		   (1ULL << NVKM_ENGINE_DISP) |
 		   (1ULL << NVKM_ENGINE_PM);
diff --git a/drivers/gpu/drm/nouveau/nvkm/engine/fault/Kbuild b/drivers/gpu/drm/nouveau/nvkm/engine/fault/Kbuild
index e69de29bb2d1..627d74eaba1d 100644
--- a/drivers/gpu/drm/nouveau/nvkm/engine/fault/Kbuild
+++ b/drivers/gpu/drm/nouveau/nvkm/engine/fault/Kbuild
@@ -0,0 +1,4 @@
+nvkm-y += nvkm/engine/fault/base.o
+nvkm-y += nvkm/engine/fault/gp100.o
+
+nvkm-y += nvkm/engine/fault/user.o
diff --git a/drivers/gpu/drm/nouveau/nvkm/engine/fault/base.c b/drivers/gpu/drm/nouveau/nvkm/engine/fault/base.c
new file mode 100644
index 000000000000..a970012e84c8
--- /dev/null
+++ b/drivers/gpu/drm/nouveau/nvkm/engine/fault/base.c
@@ -0,0 +1,116 @@
+/*
+ * Copyright 2017 Red Hat Inc.
+ *
+ * Permission is hereby granted, free of charge, to any person obtaining a
+ * copy of this software and associated documentation files (the "Software"),
+ * to deal in the Software without restriction, including without limitation
+ * the rights to use, copy, modify, merge, publish, distribute, sublicense,
+ * and/or sell copies of the Software, and to permit persons to whom the
+ * Software is furnished to do so, subject to the following conditions:
+ *
+ * The above copyright notice and this permission notice shall be included in
+ * all copies or substantial portions of the Software.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
+ * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
+ * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
+ * THE COPYRIGHT HOLDER(S) OR AUTHOR(S) BE LIABLE FOR ANY CLAIM, DAMAGES OR
+ * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
+ * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
+ * OTHER DEALINGS IN THE SOFTWARE.
+ */
+#include "priv.h"
+#include "user.h"
+
+#include <core/client.h>
+#include <core/notify.h>
+
+static int
+nvkm_fault_ntfy_ctor(struct nvkm_object *object, void *data, u32 size,
+		     struct nvkm_notify *notify)
+{
+	if (size == 0) {
+		notify->size  = 0;
+		notify->types = 1;
+		notify->index = 0;
+		return 0;
+	}
+	return -ENOSYS;
+}
+
+static const struct nvkm_event_func
+nvkm_fault_ntfy = {
+	.ctor = nvkm_fault_ntfy_ctor,
+};
+
+static int
+nvkm_fault_class_new(struct nvkm_device *device,
+		     const struct nvkm_oclass *oclass, void *data, u32 size,
+		     struct nvkm_object **pobject)
+{
+	struct nvkm_fault *fault = nvkm_fault(device->fault);
+	if (!oclass->client->super)
+		return -EACCES;
+	return nvkm_ufault_new(fault, oclass, data, size, pobject);
+}
+
+static const struct nvkm_device_oclass
+nvkm_fault_class = {
+	.ctor = nvkm_fault_class_new,
+};
+
+static int
+nvkm_fault_class_get(struct nvkm_oclass *oclass, int index,
+		     const struct nvkm_device_oclass **class)
+{
+	struct nvkm_fault *fault = nvkm_fault(oclass->engine);
+	if (index == 0) {
+		oclass->base.oclass = fault->func->oclass;
+		oclass->base.minver = -1;
+		oclass->base.maxver = -1;
+		*class = &nvkm_fault_class;
+	}
+	return 1;
+}
+
+static void
+nvkm_fault_intr(struct nvkm_engine *engine)
+{
+	struct nvkm_fault *fault = nvkm_fault(engine);
+	nvkm_event_send(&fault->event, 1, 0, NULL, 0);
+}
+
+static void *
+nvkm_fault_dtor(struct nvkm_engine *engine)
+{
+	struct nvkm_fault *fault = nvkm_fault(engine);
+	nvkm_event_fini(&fault->event);
+	return fault;
+}
+
+static const struct nvkm_engine_func
+nvkm_fault = {
+	.dtor = nvkm_fault_dtor,
+	.intr = nvkm_fault_intr,
+	.base.sclass = nvkm_fault_class_get,
+};
+
+int
+nvkm_fault_new_(const struct nvkm_fault_func *func, struct nvkm_device *device,
+		int index, struct nvkm_engine **pengine)
+{
+	struct nvkm_fault *fault;
+	int ret;
+
+	if (!(fault = kzalloc(sizeof(*fault), GFP_KERNEL)))
+		return -ENOMEM;
+	*pengine = &fault->engine;
+	fault->func = func;
+
+	ret = nvkm_engine_ctor(&nvkm_fault, device, index, true,
+			       &fault->engine);
+	if (ret)
+		return ret;
+
+	return nvkm_event_init(&nvkm_fault_ntfy, 1, 1, &fault->event);
+}
diff --git a/drivers/gpu/drm/nouveau/nvkm/engine/fault/gp100.c b/drivers/gpu/drm/nouveau/nvkm/engine/fault/gp100.c
new file mode 100644
index 000000000000..4120bc043a3d
--- /dev/null
+++ b/drivers/gpu/drm/nouveau/nvkm/engine/fault/gp100.c
@@ -0,0 +1,61 @@
+/*
+ * Copyright 2017 Red Hat Inc.
+ *
+ * Permission is hereby granted, free of charge, to any person obtaining a
+ * copy of this software and associated documentation files (the "Software"),
+ * to deal in the Software without restriction, including without limitation
+ * the rights to use, copy, modify, merge, publish, distribute, sublicense,
+ * and/or sell copies of the Software, and to permit persons to whom the
+ * Software is furnished to do so, subject to the following conditions:
+ *
+ * The above copyright notice and this permission notice shall be included in
+ * all copies or substantial portions of the Software.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
+ * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
+ * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
+ * THE COPYRIGHT HOLDER(S) OR AUTHOR(S) BE LIABLE FOR ANY CLAIM, DAMAGES OR
+ * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
+ * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
+ * OTHER DEALINGS IN THE SOFTWARE.
+ */
+#include "priv.h"
+
+#include <nvif/class.h>
+
+static void
+gp100_fault_fini(struct nvkm_fault *fault)
+{
+	struct nvkm_device *device = fault->engine.subdev.device;
+	nvkm_mask(device, 0x002a70, 0x00000001, 0x00000000);
+}
+
+static void
+gp100_fault_init(struct nvkm_fault *fault)
+{
+	struct nvkm_device *device = fault->engine.subdev.device;
+	nvkm_wr32(device, 0x002a74, upper_32_bits(fault->vma->addr));
+	nvkm_wr32(device, 0x002a70, lower_32_bits(fault->vma->addr));
+	nvkm_mask(device, 0x002a70, 0x00000001, 0x00000001);
+}
+
+static u32
+gp100_fault_size(struct nvkm_fault *fault)
+{
+	return nvkm_rd32(fault->engine.subdev.device, 0x002a78) * 32;
+}
+
+static const struct nvkm_fault_func
+gp100_fault = {
+	.size = gp100_fault_size,
+	.init = gp100_fault_init,
+	.fini = gp100_fault_fini,
+	.oclass = MAXWELL_FAULT_BUFFER_A,
+};
+
+int
+gp100_fault_new(struct nvkm_device *device, int index,
+		struct nvkm_engine **pengine)
+{
+	return nvkm_fault_new_(&gp100_fault, device, index, pengine);
+}
diff --git a/drivers/gpu/drm/nouveau/nvkm/engine/fault/priv.h b/drivers/gpu/drm/nouveau/nvkm/engine/fault/priv.h
new file mode 100644
index 000000000000..5e3e6366b0fb
--- /dev/null
+++ b/drivers/gpu/drm/nouveau/nvkm/engine/fault/priv.h
@@ -0,0 +1,29 @@
+#ifndef __NVKM_FAULT_PRIV_H__
+#define __NVKM_FAULT_PRIV_H__
+#define nvkm_fault(p) container_of((p), struct nvkm_fault, engine)
+#include <engine/fault.h>
+
+#include <core/event.h>
+#include <subdev/mmu.h>
+
+struct nvkm_fault {
+	const struct nvkm_fault_func *func;
+	struct nvkm_engine engine;
+
+	struct nvkm_event event;
+
+	struct nvkm_object *user;
+	struct nvkm_memory *mem;
+	struct nvkm_vma *vma;
+};
+
+struct nvkm_fault_func {
+	u32 (*size)(struct nvkm_fault *);
+	void (*init)(struct nvkm_fault *);
+	void (*fini)(struct nvkm_fault *);
+	s32 oclass;
+};
+
+int nvkm_fault_new_(const struct nvkm_fault_func *, struct nvkm_device *,
+		    int, struct nvkm_engine **);
+#endif
diff --git a/drivers/gpu/drm/nouveau/nvkm/engine/fault/user.c b/drivers/gpu/drm/nouveau/nvkm/engine/fault/user.c
new file mode 100644
index 000000000000..5cc1c4b989bb
--- /dev/null
+++ b/drivers/gpu/drm/nouveau/nvkm/engine/fault/user.c
@@ -0,0 +1,136 @@
+/*
+ * Copyright 2017 Red Hat Inc.
+ *
+ * Permission is hereby granted, free of charge, to any person obtaining a
+ * copy of this software and associated documentation files (the "Software"),
+ * to deal in the Software without restriction, including without limitation
+ * the rights to use, copy, modify, merge, publish, distribute, sublicense,
+ * and/or sell copies of the Software, and to permit persons to whom the
+ * Software is furnished to do so, subject to the following conditions:
+ *
+ * The above copyright notice and this permission notice shall be included in
+ * all copies or substantial portions of the Software.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
+ * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
+ * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
+ * THE COPYRIGHT HOLDER(S) OR AUTHOR(S) BE LIABLE FOR ANY CLAIM, DAMAGES OR
+ * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
+ * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
+ * OTHER DEALINGS IN THE SOFTWARE.
+ */
+#include "user.h"
+
+#include <core/object.h>
+#include <core/memory.h>
+#include <subdev/bar.h>
+
+#include <nvif/clb069.h>
+#include <nvif/unpack.h>
+
+static int
+nvkm_ufault_map(struct nvkm_object *object, void *argv, u32 argc,
+		enum nvkm_object_map *type, u64 *addr, u64 *size)
+{
+	struct nvkm_fault *fault = nvkm_fault(object->engine);
+	struct nvkm_device *device = fault->engine.subdev.device;
+	*type = NVKM_OBJECT_MAP_IO;
+	*addr = device->func->resource_addr(device, 3) + fault->vma->addr;
+	*size = nvkm_memory_size(fault->mem);
+	return 0;
+}
+
+static int
+nvkm_ufault_ntfy(struct nvkm_object *object, u32 type,
+		 struct nvkm_event **pevent)
+{
+	struct nvkm_fault *fault = nvkm_fault(object->engine);
+	if (type == NVB069_VN_NTFY_FAULT) {
+		*pevent = &fault->event;
+		return 0;
+	}
+	return -EINVAL;
+}
+
+static int
+nvkm_ufault_fini(struct nvkm_object *object, bool suspend)
+{
+	struct nvkm_fault *fault = nvkm_fault(object->engine);
+	fault->func->fini(fault);
+	return 0;
+}
+
+static int
+nvkm_ufault_init(struct nvkm_object *object)
+{
+	struct nvkm_fault *fault = nvkm_fault(object->engine);
+	fault->func->init(fault);
+	return 0;
+}
+
+static void *
+nvkm_ufault_dtor(struct nvkm_object *object)
+{
+	struct nvkm_fault *fault = nvkm_fault(object->engine);
+	struct nvkm_vmm *bar2 = nvkm_bar_bar2_vmm(fault->engine.subdev.device);
+
+	mutex_lock(&fault->engine.subdev.mutex);
+	if (fault->user == object)
+		fault->user = NULL;
+	mutex_unlock(&fault->engine.subdev.mutex);
+
+	nvkm_vmm_put(bar2, &fault->vma);
+	nvkm_memory_unref(&fault->mem);
+	return object;
+}
+
+static const struct nvkm_object_func
+nvkm_ufault = {
+	.dtor = nvkm_ufault_dtor,
+	.init = nvkm_ufault_init,
+	.fini = nvkm_ufault_fini,
+	.ntfy = nvkm_ufault_ntfy,
+	.map = nvkm_ufault_map,
+};
+
+int
+nvkm_ufault_new(struct nvkm_fault *fault, const struct nvkm_oclass *oclass,
+		void *argv, u32 argc, struct nvkm_object **pobject)
+{
+	union {
+		struct nvb069_vn vn;
+	} *args = argv;
+	struct nvkm_subdev *subdev = &fault->engine.subdev;
+	struct nvkm_device *device = subdev->device;
+	struct nvkm_vmm *bar2 = nvkm_bar_bar2_vmm(device);
+	u32 size = fault->func->size(fault);
+	int ret = -ENOSYS;
+
+	if ((ret = nvif_unvers(ret, &argv, &argc, args->vn)))
+		return ret;
+
+	ret = nvkm_object_new_(&nvkm_ufault, oclass, NULL, 0, pobject);
+	if (ret)
+		return ret;
+
+	ret = nvkm_memory_new(device, NVKM_MEM_TARGET_INST, size,
+			      0x1000, false, &fault->mem);
+	if (ret)
+		return ret;
+
+	ret = nvkm_vmm_get(bar2, 12, nvkm_memory_size(fault->mem), &fault->vma);
+	if (ret)
+		return ret;
+
+	ret = nvkm_memory_map(fault->mem, 0, bar2, fault->vma, NULL, 0);
+	if (ret)
+		return ret;
+
+	mutex_lock(&subdev->mutex);
+	if (!fault->user)
+		fault->user = *pobject;
+	else
+		ret = -EBUSY;
+	mutex_unlock(&subdev->mutex);
+	return 0;
+}
diff --git a/drivers/gpu/drm/nouveau/nvkm/engine/fault/user.h b/drivers/gpu/drm/nouveau/nvkm/engine/fault/user.h
new file mode 100644
index 000000000000..70c03bbbc0b2
--- /dev/null
+++ b/drivers/gpu/drm/nouveau/nvkm/engine/fault/user.h
@@ -0,0 +1,7 @@
+#ifndef __NVKM_FAULT_USER_H__
+#define __NVKM_FAULT_USER_H__
+#include "priv.h"
+
+int nvkm_ufault_new(struct nvkm_fault *, const struct nvkm_oclass *,
+		    void *, u32, struct nvkm_object **);
+#endif
-- 
2.14.3
