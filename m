Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 24FA96B6BB7
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 18:36:25 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id b26so15290307qtq.14
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 15:36:25 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u24si3487126qtc.86.2018.12.03.15.36.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 15:36:24 -0800 (PST)
From: jglisse@redhat.com
Subject: [RFC PATCH 13/14] drm/nouveau: register GPU under heterogeneous memory system
Date: Mon,  3 Dec 2018 18:35:08 -0500
Message-Id: <20181203233509.20671-14-jglisse@redhat.com>
In-Reply-To: <20181203233509.20671-1-jglisse@redhat.com>
References: <20181203233509.20671-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: Jérôme Glisse <jglisse@redhat.com>

This register NVidia GPU under heterogeneous memory system so that one
can use the GPU memory with new syscall like hbind() for compute work
load.

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
---
 drivers/gpu/drm/nouveau/Kbuild        |  1 +
 drivers/gpu/drm/nouveau/nouveau_hms.c | 80 +++++++++++++++++++++++++++
 drivers/gpu/drm/nouveau/nouveau_hms.h | 46 +++++++++++++++
 drivers/gpu/drm/nouveau/nouveau_svm.c |  6 ++
 4 files changed, 133 insertions(+)
 create mode 100644 drivers/gpu/drm/nouveau/nouveau_hms.c
 create mode 100644 drivers/gpu/drm/nouveau/nouveau_hms.h

diff --git a/drivers/gpu/drm/nouveau/Kbuild b/drivers/gpu/drm/nouveau/Kbuild
index a826a4df440d..9c1114b4d8a3 100644
--- a/drivers/gpu/drm/nouveau/Kbuild
+++ b/drivers/gpu/drm/nouveau/Kbuild
@@ -37,6 +37,7 @@ nouveau-y += nouveau_prime.o
 nouveau-y += nouveau_sgdma.o
 nouveau-y += nouveau_ttm.o
 nouveau-y += nouveau_vmm.o
+nouveau-$(CONFIG_HMS) += nouveau_hms.o
 
 # DRM - modesetting
 nouveau-$(CONFIG_DRM_NOUVEAU_BACKLIGHT) += nouveau_backlight.o
diff --git a/drivers/gpu/drm/nouveau/nouveau_hms.c b/drivers/gpu/drm/nouveau/nouveau_hms.c
new file mode 100644
index 000000000000..52af9180e108
--- /dev/null
+++ b/drivers/gpu/drm/nouveau/nouveau_hms.c
@@ -0,0 +1,80 @@
+/*
+ * Copyright 2018 Red Hat Inc.
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
+#include "nouveau_dmem.h"
+#include "nouveau_drv.h"
+#include "nouveau_hms.h"
+
+#include <linux/hms.h>
+
+static int nouveau_hms_migrate(struct hms_target *target, struct mm_struct *mm,
+			       unsigned long start, unsigned long end,
+			       unsigned natoms, uint32_t *atoms)
+{
+	struct nouveau_hms *hms = target->private;
+	struct nouveau_drm *drm = hms->drm;
+	unsigned long addr;
+	int ret = 0;
+
+	down_read(&mm->mmap_sem);
+
+	for (addr = start; addr < end;) {
+		struct vm_area_struct *vma;
+		unsigned long next;
+
+		vma = find_vma_intersection(mm, addr, end);
+		if (!vma)
+			break;
+
+		next = min(vma->vm_end, end);
+		ret = nouveau_dmem_migrate_vma(drm, vma, addr, next);
+		// FIXME ponder more on what to do
+		addr = next;
+	}
+
+	up_read(&mm->mmap_sem);
+
+	return ret;
+}
+
+const static struct hms_target_hbind nouveau_hms_target_hbind = {
+	.migrate = nouveau_hms_migrate,
+};
+
+
+void nouveau_hms_init(struct nouveau_drm *drm, struct nouveau_hms *hms)
+{
+	unsigned long vram_size = drm->gem.vram_available;
+	struct device *parent;
+
+	hms->drm = drm;
+	parent = drm->dev->pdev ? &drm->dev->pdev->dev : drm->dev->dev;
+	hms_target_register(&hms->target, parent, drm->dev->dev->numa_node,
+			    &nouveau_hms_target_hbind, vram_size, 0);
+	if (hms->target) {
+		hms->target->private = hms;
+	}
+}
+
+void nouveau_hms_fini(struct nouveau_drm *drm, struct nouveau_hms *hms)
+{
+	hms_target_unregister(&hms->target);
+}
diff --git a/drivers/gpu/drm/nouveau/nouveau_hms.h b/drivers/gpu/drm/nouveau/nouveau_hms.h
new file mode 100644
index 000000000000..cda111d7044b
--- /dev/null
+++ b/drivers/gpu/drm/nouveau/nouveau_hms.h
@@ -0,0 +1,46 @@
+/*
+ * Copyright 2018 Red Hat Inc.
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
+#ifndef __NOUVEAU_HMS_H__
+#define __NOUVEAU_HMS_H__
+
+#if IS_ENABLED(CONFIG_HMS)
+
+#include <linux/hms.h>
+
+struct nouveau_hms {
+	struct hms_target *target;
+	struct nouveau_drm *drm;
+};
+
+void nouveau_hms_init(struct nouveau_drm *drm, struct nouveau_hms *hms);
+void nouveau_hms_fini(struct nouveau_drm *drm, struct nouveau_hms *hms);
+
+#else /* IS_ENABLED(CONFIG_HMS) */
+
+struct nouveau_hms {
+};
+
+#define nouveau_hms_init(drm, hms)
+#define nouveau_hms_fini(drm, hms)
+
+#endif /* IS_ENABLED(CONFIG_HMS) */
+#endif
diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouveau/nouveau_svm.c
index 23435ee27892..26daa6d50766 100644
--- a/drivers/gpu/drm/nouveau/nouveau_svm.c
+++ b/drivers/gpu/drm/nouveau/nouveau_svm.c
@@ -23,6 +23,7 @@
 #include "nouveau_drv.h"
 #include "nouveau_chan.h"
 #include "nouveau_dmem.h"
+#include "nouveau_hms.h"
 
 #include <nvif/notify.h>
 #include <nvif/object.h>
@@ -44,6 +45,8 @@ struct nouveau_svm {
 	int refs;
 	struct list_head inst;
 
+	struct nouveau_hms hms;
+
 	struct nouveau_svm_fault_buffer {
 		int id;
 		struct nvif_object object;
@@ -766,6 +769,7 @@ nouveau_svm_suspend(struct nouveau_drm *drm)
 void
 nouveau_svm_fini(struct nouveau_drm *drm)
 {
+	nouveau_hms_fini(drm, &drm->svm->hms);
 	kfree(drm->svm);
 }
 
@@ -776,6 +780,8 @@ nouveau_svm_init(struct nouveau_drm *drm)
 		drm->svm->drm = drm;
 		mutex_init(&drm->svm->mutex);
 		INIT_LIST_HEAD(&drm->svm->inst);
+
+		nouveau_hms_init(drm, &drm->svm->hms);
 	}
 }
 
-- 
2.17.2
