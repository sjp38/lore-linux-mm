Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id E340B6B5FDA
	for <linux-mm@kvack.org>; Sat,  1 Sep 2018 22:21:11 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id g12-v6so8493322plo.1
        for <linux-mm@kvack.org>; Sat, 01 Sep 2018 19:21:11 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id d32-v6si13682201pla.93.2018.09.01.19.21.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Sep 2018 19:21:10 -0700 (PDT)
Message-Id: <20180901124811.591511876@intel.com>
Date: Sat, 01 Sep 2018 19:28:21 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [RFC][PATCH 3/5] [PATCH 3/5] kvm-ept-idle: HVA indexed EPT read
References: <20180901112818.126790961@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=0003-kvm-ept-idle-HVA-indexed-EPT-read.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Peng DongX <dongx.peng@intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Huang Ying <ying.huang@intel.com>, Brendan Gregg <bgregg@netflix.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

For virtual machines, "accessed" bits will be set in guest page tables
and EPT/NPT. So for qemu-kvm process, convert HVA to GFN to GPA, then do
EPT/NPT walks. Thanks to the in-memslot linear HVA-GPA mapping, the conversion
can be done efficiently, outside of the loops for page table walks.

In this manner, we provide uniform interface for both virtual machines and
normal processes.

The use scenario would be per task/VM working set tracking and migration.
Very convenient for applying task/vma and VM granularity policies.

Signed-off-by: Peng DongX <dongx.peng@intel.com>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 arch/x86/kvm/ept_idle.c | 118 ++++++++++++++++++++++++++++++++++++++++++++++++
 arch/x86/kvm/ept_idle.h |  24 ++++++++++
 2 files changed, 142 insertions(+)
 create mode 100644 arch/x86/kvm/ept_idle.c
 create mode 100644 arch/x86/kvm/ept_idle.h

diff --git a/arch/x86/kvm/ept_idle.c b/arch/x86/kvm/ept_idle.c
new file mode 100644
index 000000000000..5b97dd01011b
--- /dev/null
+++ b/arch/x86/kvm/ept_idle.c
@@ -0,0 +1,118 @@
+// SPDX-License-Identifier: GPL-2.0
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/proc_fs.h>
+#include <linux/uaccess.h>
+#include <linux/kvm.h>
+#include <linux/kvm_host.h>
+#include <linux/bitmap.h>
+
+#include "ept_idle.h"
+
+
+// mindless copy from kvm_handle_hva_range().
+// TODO: handle order and hole.
+static int ept_idle_walk_hva_range(struct ept_idle_ctrl *eic,
+				   unsigned long start,
+				   unsigned long end)
+{
+	struct kvm_memslots *slots;
+	struct kvm_memory_slot *memslot;
+	int ret = 0;
+
+	slots = kvm_memslots(eic->kvm);
+	kvm_for_each_memslot(memslot, slots) {
+		unsigned long hva_start, hva_end;
+		gfn_t gfn_start, gfn_end;
+
+		hva_start = max(start, memslot->userspace_addr);
+		hva_end = min(end, memslot->userspace_addr +
+			      (memslot->npages << PAGE_SHIFT));
+		if (hva_start >= hva_end)
+			continue;
+		/*
+		 * {gfn(page) | page intersects with [hva_start, hva_end)} =
+		 * {gfn_start, gfn_start+1, ..., gfn_end-1}.
+		 */
+		gfn_start = hva_to_gfn_memslot(hva_start, memslot);
+		gfn_end = hva_to_gfn_memslot(hva_end + PAGE_SIZE - 1, memslot);
+
+		ret = ept_idle_walk_gfn_range(eic, gfn_start, gfn_end);
+		if (ret)
+			return ret;
+	}
+
+	return ret;
+}
+
+static ssize_t ept_idle_read(struct file *file, char *buf,
+			     size_t count, loff_t *ppos)
+{
+	struct task_struct *task = file->private_data;
+	struct ept_idle_ctrl *eic;
+	unsigned long hva_start = *ppos << BITMAP_BYTE2PVA_SHIFT;
+	unsigned long hva_end = hva_start + (count << BITMAP_BYTE2PVA_SHIFT);
+	int ret;
+
+	if (*ppos % IDLE_BITMAP_CHUNK_SIZE ||
+	    count % IDLE_BITMAP_CHUNK_SIZE)
+		return -EINVAL;
+
+	eic = kzalloc(sizeof(*eic), GFP_KERNEL);
+	if (!eic)
+		return -EBUSY;
+
+	eic->buf = buf;
+	eic->buf_size = count;
+	eic->kvm = task_kvm(task);
+	if (!eic->kvm) {
+		ret = -EINVAL;
+		goto out_free;
+	}
+
+	ret = ept_idle_walk_hva_range(eic, hva_start, hva_end);
+	if (ret)
+		goto out_free;
+
+	ret = eic->bytes_copied;
+	*ppos += ret;
+out_free:
+	kfree(eic);
+
+	return ret;
+}
+
+static int ept_idle_open(struct inode *inode, struct file *file)
+{
+	if (!try_module_get(THIS_MODULE))
+		return -EBUSY;
+
+	return 0;
+}
+
+static int ept_idle_release(struct inode *inode, struct file *file)
+{
+	module_put(THIS_MODULE);
+	return 0;
+}
+
+extern struct file_operations proc_ept_idle_operations;
+
+static int ept_idle_entry(void)
+{
+	proc_ept_idle_operations.owner = THIS_MODULE;
+	proc_ept_idle_operations.read = ept_idle_read;
+	proc_ept_idle_operations.open = ept_idle_open;
+	proc_ept_idle_operations.release = ept_idle_release;
+
+	return 0;
+}
+
+static void ept_idle_exit(void)
+{
+	memset(&proc_ept_idle_operations, 0, sizeof(proc_ept_idle_operations));
+}
+
+MODULE_LICENSE("GPL");
+module_init(ept_idle_entry);
+module_exit(ept_idle_exit);
diff --git a/arch/x86/kvm/ept_idle.h b/arch/x86/kvm/ept_idle.h
new file mode 100644
index 000000000000..e0b9dcecf50b
--- /dev/null
+++ b/arch/x86/kvm/ept_idle.h
@@ -0,0 +1,24 @@
+#ifndef _EPT_IDLE_H
+#define _EPT_IDLE_H
+
+#define IDLE_BITMAP_CHUNK_SIZE	sizeof(u64)
+#define IDLE_BITMAP_CHUNK_BITS	(IDLE_BITMAP_CHUNK_SIZE * BITS_PER_BYTE)
+
+#define BITMAP_BYTE2PVA_SHIFT  (3 + PAGE_SHIFT)
+
+#define EPT_IDLE_KBUF_FULL 1
+#define EPT_IDLE_KBUF_BYTES 8000
+#define EPT_IDLE_KBUF_BITS  (EPT_IDLE_KBUF_BYTES * 8)
+
+struct ept_idle_ctrl {
+	struct kvm *kvm;
+
+	u64 kbuf[EPT_IDLE_KBUF_BITS / IDLE_BITMAP_CHUNK_BITS];
+	int bits_read;
+
+	void __user *buf;
+	int buf_size;
+	int bytes_copied;
+};
+
+#endif
-- 
2.15.0
