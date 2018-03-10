Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id ADDFE6B0010
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 22:22:01 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id g13so8330815qtj.15
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 19:22:01 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id p54si2149653qtb.417.2018.03.09.19.22.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Mar 2018 19:22:00 -0800 (PST)
From: jglisse@redhat.com
Subject: [RFC PATCH 09/13] drm/nouveau: add SVM through HMM support to nouveau client
Date: Fri,  9 Mar 2018 22:21:37 -0500
Message-Id: <20180310032141.6096-10-jglisse@redhat.com>
In-Reply-To: <20180310032141.6096-1-jglisse@redhat.com>
References: <20180310032141.6096-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dri-devel@lists.freedesktop.org, nouveau@lists.freedesktop.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Ben Skeggs <bskeggs@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

SVM (Share Virtual Memory) through HMM (Heterogeneous Memory Management)
to nouveau client. SVM means that any valid pointer (private anonymous,
share memory or mmap of regular file) on the CPU is also valid on the
GPU. To achieve SVM with nouveau we use HMM kernel infrastructure.

There is one nouveau client object created each time the device file is
open by a process, this is best we can achieve. Idealy we would like an
object that exist for each process address space but there is no such
thing in the kernel.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Ben Skeggs <bskeggs@redhat.com>
---
 drivers/gpu/drm/nouveau/Kbuild        |   3 +
 drivers/gpu/drm/nouveau/nouveau_drm.c |   5 +
 drivers/gpu/drm/nouveau/nouveau_drv.h |   3 +
 drivers/gpu/drm/nouveau/nouveau_hmm.c | 339 ++++++++++++++++++++++++++++++++++
 drivers/gpu/drm/nouveau/nouveau_hmm.h |  63 +++++++
 5 files changed, 413 insertions(+)
 create mode 100644 drivers/gpu/drm/nouveau/nouveau_hmm.c
 create mode 100644 drivers/gpu/drm/nouveau/nouveau_hmm.h

diff --git a/drivers/gpu/drm/nouveau/Kbuild b/drivers/gpu/drm/nouveau/Kbuild
index 9c0c650655e9..8e61e118ccfe 100644
--- a/drivers/gpu/drm/nouveau/Kbuild
+++ b/drivers/gpu/drm/nouveau/Kbuild
@@ -35,6 +35,9 @@ nouveau-y += nouveau_prime.o
 nouveau-y += nouveau_sgdma.o
 nouveau-y += nouveau_ttm.o
 nouveau-y += nouveau_vmm.o
+ifdef CONFIG_HMM_MIRROR
+nouveau-$(CONFIG_DEVICE_PRIVATE) += nouveau_hmm.o
+endif
 
 # DRM - modesetting
 nouveau-$(CONFIG_DRM_NOUVEAU_BACKLIGHT) += nouveau_backlight.o
diff --git a/drivers/gpu/drm/nouveau/nouveau_drm.c b/drivers/gpu/drm/nouveau/nouveau_drm.c
index 3e293029e3a6..e67b08ba8b80 100644
--- a/drivers/gpu/drm/nouveau/nouveau_drm.c
+++ b/drivers/gpu/drm/nouveau/nouveau_drm.c
@@ -167,6 +167,7 @@ nouveau_cli_work(struct work_struct *w)
 static void
 nouveau_cli_fini(struct nouveau_cli *cli)
 {
+	nouveau_hmm_fini(cli);
 	nouveau_cli_work_flush(cli, true);
 	usif_client_fini(cli);
 	nouveau_vmm_fini(&cli->vmm);
@@ -965,6 +966,10 @@ nouveau_drm_open(struct drm_device *dev, struct drm_file *fpriv)
 	list_add(&cli->head, &drm->clients);
 	mutex_unlock(&drm->client.mutex);
 
+	ret = nouveau_hmm_init(cli);
+	if (ret)
+		return ret;
+
 done:
 	if (ret && cli) {
 		nouveau_cli_fini(cli);
diff --git a/drivers/gpu/drm/nouveau/nouveau_drv.h b/drivers/gpu/drm/nouveau/nouveau_drv.h
index 96f6bd8aee5d..75c741d5125c 100644
--- a/drivers/gpu/drm/nouveau/nouveau_drv.h
+++ b/drivers/gpu/drm/nouveau/nouveau_drv.h
@@ -65,6 +65,7 @@ struct platform_device;
 #include "nouveau_fence.h"
 #include "nouveau_bios.h"
 #include "nouveau_vmm.h"
+#include "nouveau_hmm.h"
 
 struct nouveau_drm_tile {
 	struct nouveau_fence *fence;
@@ -104,6 +105,8 @@ struct nouveau_cli {
 	struct list_head notifys;
 	char name[32];
 
+	struct nouveau_hmm hmm;
+
 	struct work_struct work;
 	struct list_head worker;
 	struct mutex lock;
diff --git a/drivers/gpu/drm/nouveau/nouveau_hmm.c b/drivers/gpu/drm/nouveau/nouveau_hmm.c
new file mode 100644
index 000000000000..a4c6f687f6a8
--- /dev/null
+++ b/drivers/gpu/drm/nouveau/nouveau_hmm.c
@@ -0,0 +1,339 @@
+/*
+ * Copyright (C) 2018 Red Hat All Rights Reserved.
+ *
+ * Permission is hereby granted, free of charge, to any person obtaining
+ * a copy of this software and associated documentation files (the
+ * "Software"), to deal in the Software without restriction, including
+ * without limitation the rights to use, copy, modify, merge, publish,
+ * distribute, sublicense, and/or sell copies of the Software, and to
+ * permit persons to whom the Software is furnished to do so, subject to
+ * the following conditions:
+ *
+ * The above copyright notice and this permission notice (including the
+ * next paragraph) shall be included in all copies or substantial
+ * portions of the Software.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
+ * IN NO EVENT SHALL THE COPYRIGHT OWNER(S) AND/OR ITS SUPPLIERS BE
+ * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
+ * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
+ * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
+ *
+ * Author: JA(C)rA'me Glisse, Ben Skeggs
+ */
+#include <nvif/class.h>
+#include <nvif/clb069.h>
+#include "nouveau_hmm.h"
+#include "nouveau_drv.h"
+#include "nouveau_bo.h"
+#include <nvkm/subdev/mmu.h>
+#include <linux/sched/mm.h>
+#include <linux/mm.h>
+
+struct fault_entry {
+	u32 instlo;
+	u32 insthi;
+	u32 addrlo;
+	u32 addrhi;
+	u32 timelo;
+	u32 timehi;
+	u32 rsvd;
+	u32 info;
+};
+
+#define NV_PFAULT_ACCESS_R 0 /* read */
+#define NV_PFAULT_ACCESS_W 1 /* write */
+#define NV_PFAULT_ACCESS_A 2 /* atomic */
+#define NV_PFAULT_ACCESS_P 3 /* prefetch */
+
+static inline u64
+fault_entry_addr(const struct fault_entry *fe)
+{
+	return ((u64)fe->addrhi << 32) | (fe->addrlo & PAGE_MASK);
+}
+
+static inline unsigned
+fault_entry_access(const struct fault_entry *fe)
+{
+	return ((u64)fe->info >> 16) & 7;
+}
+
+struct nouveau_vmf {
+	struct vm_area_struct *vma;
+	struct nouveau_cli *cli;
+	uint64_t *pages;;
+	u64 npages;
+	u64 start;
+};
+
+static void
+nouveau_hmm_fault_signal(struct nouveau_cli *cli,
+			 struct fault_entry *fe,
+			 bool success)
+{
+	u32 gpc, isgpc, client;
+
+	if (!(fe->info & 0x80000000))
+		return;
+
+	gpc    = (fe->info & 0x1f000000) >> 24;
+	isgpc  = (fe->info & 0x00100000) >> 20;
+	client = (fe->info & 0x00007f00) >> 8;
+	fe->info &= 0x7fffffff;
+
+	if (success) {
+		nvif_wr32(&cli->device.object, 0x100cbc, 0x80000000 |
+			  (1 << 3) | (client << 9) |
+			  (gpc << 15) | (isgpc << 20));
+	} else {
+		nvif_wr32(&cli->device.object, 0x100cbc, 0x80000000 |
+			  (4 << 3) | (client << 9) |
+			  (gpc << 15) | (isgpc << 20));
+	}
+}
+
+static const uint64_t hmm_pfn_flags[HMM_PFN_FLAG_MAX] = {
+	/* FIXME find a way to build time check order */
+	NV_HMM_PAGE_FLAG_V, /* HMM_PFN_FLAG_VALID */
+	NV_HMM_PAGE_FLAG_W, /* HMM_PFN_FLAG_WRITE */
+	NV_HMM_PAGE_FLAG_E, /* HMM_PFN_FLAG_ERROR */
+	NV_HMM_PAGE_FLAG_N, /* HMM_PFN_FLAG_NONE */
+	NV_HMM_PAGE_FLAG_S, /* HMM_PFN_FLAG_SPECIAL */
+	0, /* HMM_PFN_FLAG_DEVICE_UNADDRESSABLE */
+};
+
+static int
+nouveau_hmm_handle_fault(struct nouveau_vmf *vmf)
+{
+	struct nouveau_hmm *hmm = &vmf->cli->hmm;
+	struct hmm_range range;
+	int ret;
+
+	range.vma = vmf->vma;
+	range.start = vmf->start;
+	range.end = vmf->start + vmf->npages;
+	range.pfns = vmf->pages;
+	range.pfn_shift = NV_HMM_PAGE_PFN_SHIFT;
+	range.flags = hmm_pfn_flags;
+
+	ret = hmm_vma_fault(&range, true);
+	if (ret)
+		return ret;
+
+	mutex_lock(&hmm->mutex);
+	if (!hmm_vma_range_done(&range)) {
+		mutex_unlock(&hmm->mutex);
+		return -EAGAIN;
+	}
+
+	nvif_vmm_hmm_map(&vmf->cli->vmm.vmm, vmf->start,
+			 vmf->npages, (u64 *)vmf->pages);
+	mutex_unlock(&hmm->mutex);
+	return 0;
+}
+
+static int
+nouveau_hmm_rpfb_process(struct nvif_notify *ntfy)
+{
+	struct nouveau_hmm *hmm = container_of(ntfy, typeof(*hmm), pending);
+	struct nouveau_cli *cli = container_of(hmm, typeof(*cli), hmm);
+	u32 get = nvif_rd32(&cli->device.object, 0x002a7c);
+	u32 put = nvif_rd32(&cli->device.object, 0x002a80);
+	struct fault_entry *fe = (void *)hmm->rpfb.map.ptr;
+	u32 processed = 0, next = get;
+
+	for (; hmm->enabled && (get != put); get = next) {
+		/* FIXME something else than a 16 pages window ... */
+		const u64 max_pages = 16;
+		const u64 range_mask = (max_pages << PAGE_SHIFT) - 1;
+		u64 addr, start, end, i;
+		struct nouveau_vmf vmf;
+		u64 pages[16] = {0};
+		int ret;
+
+		if (!(fe[get].info & 0x80000000)) {
+			processed++; get++;
+			continue;
+		}
+
+		start = fault_entry_addr(&fe[get]) & (~range_mask);
+		end = start + range_mask + 1;
+
+		for (next = get; next < put; ++next) {
+			unsigned access;
+
+			if (!(fe[next].info & 0x80000000)) {
+				continue;
+			}
+
+			addr = fault_entry_addr(&fe[next]);
+			if (addr < start || addr >= end) {
+				break;
+			}
+
+			i = (addr - start) >> PAGE_SHIFT;
+			access = fault_entry_access(&fe[next]);
+			pages[i] = (access == NV_PFAULT_ACCESS_W) ?
+				NV_HMM_PAGE_FLAG_V |
+				NV_HMM_PAGE_FLAG_W :
+				NV_HMM_PAGE_FLAG_V;
+		}
+
+again:
+		down_read(&hmm->mm->mmap_sem);
+		vmf.vma = find_vma_intersection(hmm->mm, start, end);
+		if (vmf.vma == NULL) {
+			up_read(&hmm->mm->mmap_sem);
+			for (i = 0; i < max_pages; ++i) {
+				pages[i] = NV_HMM_PAGE_FLAG_E;
+			}
+			goto signal;
+		}
+
+		/* Mark error */
+		for (addr = start, i = 0; addr < vmf.vma->vm_start;
+		     addr += PAGE_SIZE, ++i) {
+			pages[i] = NV_HMM_PAGE_FLAG_E;
+		}
+		for (addr = end - PAGE_SIZE, i = max_pages - 1;
+		     addr >= vmf.vma->vm_end; addr -= PAGE_SIZE, --i) {
+			pages[i] = NV_HMM_PAGE_FLAG_E;
+		}
+		vmf.start = max_t(u64, start, vmf.vma->vm_start);
+		end = min_t(u64, end, vmf.vma->vm_end);
+
+		vmf.cli = cli;
+		vmf.pages = &pages[(vmf.start - start) >> PAGE_SHIFT];
+		vmf.npages = (end - vmf.start) >> PAGE_SHIFT;
+		ret = nouveau_hmm_handle_fault(&vmf);
+		switch (ret) {
+		case -EAGAIN:
+			up_read(&hmm->mm->mmap_sem);
+			/* fallthrough */
+		case -EBUSY:
+			/* Try again */
+			goto again;
+		default:
+			up_read(&hmm->mm->mmap_sem);
+			break;
+		}
+
+	signal:
+		for (; get < next; ++get) {
+			bool success;
+
+			if (!(fe[get].info & 0x80000000)) {
+				continue;
+			}
+
+			addr = fault_entry_addr(&fe[get]);
+			i = (addr - start) >> PAGE_SHIFT;
+			success = !(pages[i] & NV_HMM_PAGE_FLAG_E);
+			nouveau_hmm_fault_signal(cli, &fe[get], success);
+		}
+	}
+
+	nvif_wr32(&cli->device.object, 0x002a7c, get);
+	return hmm->enabled ? NVIF_NOTIFY_KEEP : NVIF_NOTIFY_DROP;
+}
+
+static void
+nouveau_vmm_sync_pagetables(struct hmm_mirror *mirror,
+			    enum hmm_update_type update,
+			    unsigned long start,
+			    unsigned long end)
+{
+}
+
+static const struct hmm_mirror_ops nouveau_hmm_mirror_ops = {
+	.sync_cpu_device_pagetables	= &nouveau_vmm_sync_pagetables,
+};
+
+void
+nouveau_hmm_fini(struct nouveau_cli *cli)
+{
+	if (!cli->hmm.enabled)
+		return;
+
+	cli->hmm.enabled = false;
+	nvif_notify_fini(&cli->hmm.pending);
+	nvif_object_fini(&cli->hmm.rpfb);
+
+	hmm_mirror_unregister(&cli->hmm.mirror);
+	nouveau_vmm_sync_pagetables(&cli->hmm.mirror, HMM_UPDATE_INVALIDATE,
+				    PAGE_SIZE, TASK_SIZE);
+}
+
+int
+nouveau_hmm_init(struct nouveau_cli *cli)
+{
+	struct mm_struct *mm = get_task_mm(current);
+	static const struct nvif_mclass rpfbs[] = {
+		{ MAXWELL_FAULT_BUFFER_A, -1 },
+		{}
+	};
+	bool super;
+	int ret;
+
+	if (cli->hmm.enabled)
+		return 0;
+
+	mutex_init(&cli->hmm.mutex);
+
+	down_write(&mm->mmap_sem);
+	mutex_lock(&cli->hmm.mutex);
+	cli->hmm.mirror.ops = &nouveau_hmm_mirror_ops;
+	ret = hmm_mirror_register(&cli->hmm.mirror, mm);
+	if (!ret)
+		cli->hmm.mm = mm;
+	mutex_unlock(&cli->hmm.mutex);
+	up_write(&mm->mmap_sem);
+	mmput(mm);
+	if (ret)
+		return ret;
+
+	/* Allocate replayable fault buffer. */
+	ret = nvif_mclass(&cli->device.object, rpfbs);
+	if (ret < 0) {
+		hmm_mirror_unregister(&cli->hmm.mirror);
+		return ret;
+	}
+
+	super = cli->base.super;
+	cli->base.super = true;
+	ret = nvif_object_init(&cli->device.object, 0,
+			       rpfbs[ret].oclass,
+			       NULL, 0, &cli->hmm.rpfb);
+	if (ret) {
+		hmm_mirror_unregister(&cli->hmm.mirror);
+		cli->base.super = super;
+		return ret;
+	}
+	nvif_object_map(&cli->hmm.rpfb, NULL, 0);
+
+	/* Request notification of pending replayable faults. */
+	ret = nvif_notify_init(&cli->hmm.rpfb, nouveau_hmm_rpfb_process,
+			       true, NVB069_VN_NTFY_FAULT, NULL, 0, 0,
+			       &cli->hmm.pending);
+	cli->base.super = super;
+	if (ret)
+		goto error_notify;
+
+	ret = nvif_notify_get(&cli->hmm.pending);
+	if (ret)
+		goto error_notify_get;
+
+	cli->hmm.mm = current->mm;
+	cli->hmm.task = current;
+	cli->hmm.enabled = true;
+	return 0;
+
+error_notify_get:
+	nvif_notify_fini(&cli->hmm.pending);
+error_notify:
+	nvif_object_fini(&cli->hmm.rpfb);
+	hmm_mirror_unregister(&cli->hmm.mirror);
+	return ret;
+}
diff --git a/drivers/gpu/drm/nouveau/nouveau_hmm.h b/drivers/gpu/drm/nouveau/nouveau_hmm.h
new file mode 100644
index 000000000000..47f31cf8ac56
--- /dev/null
+++ b/drivers/gpu/drm/nouveau/nouveau_hmm.h
@@ -0,0 +1,63 @@
+/*
+ * Copyright (C) 2018 Red Hat All Rights Reserved.
+ *
+ * Permission is hereby granted, free of charge, to any person obtaining
+ * a copy of this software and associated documentation files (the
+ * "Software"), to deal in the Software without restriction, including
+ * without limitation the rights to use, copy, modify, merge, publish,
+ * distribute, sublicense, and/or sell copies of the Software, and to
+ * permit persons to whom the Software is furnished to do so, subject to
+ * the following conditions:
+ *
+ * The above copyright notice and this permission notice (including the
+ * next paragraph) shall be included in all copies or substantial
+ * portions of the Software.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
+ * IN NO EVENT SHALL THE COPYRIGHT OWNER(S) AND/OR ITS SUPPLIERS BE
+ * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
+ * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
+ * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
+ *
+ * Author: JA(C)rA'me Glisse, Ben Skeggs
+ */
+#ifndef NOUVEAU_HMM_H
+#define NOUVEAU_HMM_H
+#include <nvif/object.h>
+#include <nvif/notify.h>
+#include <nouveau_vmm.h>
+#include <linux/hmm.h>
+
+#if defined(CONFIG_HMM_MIRROR) && defined(CONFIG_DEVICE_PRIVATE)
+
+struct nouveau_hmm {
+	struct nvif_object rpfb;
+	struct nvif_notify pending;
+	struct task_struct *task;
+	struct hmm_mirror mirror;
+	struct mm_struct *mm;
+	struct mutex mutex;
+	bool enabled;
+};
+
+void nouveau_hmm_fini(struct nouveau_cli *cli);
+int nouveau_hmm_init(struct nouveau_cli *cli);
+
+#else /* defined(CONFIG_HMM_MIRROR) && defined(CONFIG_DEVICE_PRIVATE) */
+
+struct nouveau_hmm {
+};
+
+static inline void nouveau_hmm_fini(struct nouveau_cli *cli)
+{
+}
+
+static inline void nouveau_hmm_init(struct nouveau_cli *cli)
+{
+	return -EINVAL;
+}
+
+#endif /* defined(CONFIG_HMM_MIRROR) && defined(CONFIG_DEVICE_PRIVATE) */
+#endif /* NOUVEAU_HMM_H */
-- 
2.14.3
