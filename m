Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4FE726B6BB4
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 18:36:18 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id w19so15308734qto.13
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 15:36:18 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c185si5894447qkb.52.2018.12.03.15.36.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 15:36:16 -0800 (PST)
From: jglisse@redhat.com
Subject: [RFC PATCH 10/14] mm/hbind: add heterogeneous memory policy tracking infrastructure
Date: Mon,  3 Dec 2018 18:35:05 -0500
Message-Id: <20181203233509.20671-11-jglisse@redhat.com>
In-Reply-To: <20181203233509.20671-1-jglisse@redhat.com>
References: <20181203233509.20671-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, "Rafael J . Wysocki" <rafael@kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Haggai Eran <haggaie@mellanox.com>, Balbir Singh <balbirs@au1.ibm.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Felix Kuehling <felix.kuehling@amd.com>, Philip Yang <Philip.Yang@amd.com>, =?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Logan Gunthorpe <logang@deltatee.com>, John Hubbard <jhubbard@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Michal Hocko <mhocko@kernel.org>, Jonathan Cameron <jonathan.cameron@huawei.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Vivek Kini <vkini@nvidia.com>, Mel Gorman <mgorman@techsingularity.net>, Dave Airlie <airlied@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

From: Jérôme Glisse <jglisse@redhat.com>

This patch add infrastructure to track heterogeneous memory policy
within the kernel. Policy are defined over range of virtual address
of a process and attach to the correspond mm_struct.

User can reset to default policy for range of virtual address using
hbind() default commands for the range.

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: Rafael J. Wysocki <rafael@kernel.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Haggai Eran <haggaie@mellanox.com>
Cc: Balbir Singh <balbirs@au1.ibm.com>
Cc: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Felix Kuehling <felix.kuehling@amd.com>
Cc: Philip Yang <Philip.Yang@amd.com>
Cc: Christian König <christian.koenig@amd.com>
Cc: Paul Blinzer <Paul.Blinzer@amd.com>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Jonathan Cameron <jonathan.cameron@huawei.com>
Cc: Mark Hairgrove <mhairgrove@nvidia.com>
Cc: Vivek Kini <vkini@nvidia.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Dave Airlie <airlied@redhat.com>
Cc: Ben Skeggs <bskeggs@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/hms.h        |  46 ++++++
 include/linux/mm_types.h   |   6 +
 include/uapi/linux/hbind.h |   8 +
 kernel/fork.c              |   3 +
 mm/hms.c                   | 306 ++++++++++++++++++++++++++++++++++++-
 5 files changed, 368 insertions(+), 1 deletion(-)

diff --git a/include/linux/hms.h b/include/linux/hms.h
index 511b5363d8f2..f39c390b3afb 100644
--- a/include/linux/hms.h
+++ b/include/linux/hms.h
@@ -20,6 +20,8 @@
 
 #include <linux/device.h>
 #include <linux/types.h>
+#include <linux/mm_types.h>
+#include <linux/mmu_notifier.h>
 
 
 struct hms_target;
@@ -34,6 +36,10 @@ struct hms_target_hbind {
 #if IS_ENABLED(CONFIG_HMS)
 
 
+#include <linux/interval_tree.h>
+#include <linux/rwsem.h>
+
+
 #define to_hms_object(device) container_of(device, struct hms_object, device)
 
 enum hms_type {
@@ -133,6 +139,42 @@ void hms_bridge_register(struct hms_bridge **bridgep,
 void hms_bridge_unregister(struct hms_bridge **bridgep);
 
 
+struct hms_policy_targets {
+	struct hms_target **targets;
+	unsigned ntargets;
+	struct kref kref;
+};
+
+struct hms_policy_range {
+	struct hms_policy_targets *ptargets;
+	struct interval_tree_node node;
+	struct kref kref;
+};
+
+struct hms_policy {
+	struct rb_root_cached ranges;
+	struct rw_semaphore sem;
+	struct mmu_notifier mn;
+};
+
+static inline unsigned long hms_policy_range_start(struct hms_policy_range *r)
+{
+	return r->node.start;
+}
+
+static inline unsigned long hms_policy_range_end(struct hms_policy_range *r)
+{
+	return r->node.last + 1;
+}
+
+static inline void hms_policy_init(struct mm_struct *mm)
+{
+	mm->hpolicy = NULL;
+}
+
+void hms_policy_fini(struct mm_struct *mm);
+
+
 int hms_init(void);
 
 
@@ -163,6 +205,10 @@ int hms_init(void);
 #define hms_bridge_unregister(bridgep)
 
 
+#define hms_policy_init(mm)
+#define hms_policy_fini(mm)
+
+
 static inline int hms_init(void)
 {
 	return 0;
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 5ed8f6292a53..3da91767c689 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -26,6 +26,7 @@ typedef int vm_fault_t;
 
 struct address_space;
 struct mem_cgroup;
+struct hms_policy;
 struct hmm;
 
 /*
@@ -491,6 +492,11 @@ struct mm_struct {
 		/* HMM needs to track a few things per mm */
 		struct hmm *hmm;
 #endif
+
+#if IS_ENABLED(CONFIG_HMS)
+		/* Heterogeneous Memory System policy */
+		struct hms_policy *hpolicy;
+#endif
 	} __randomize_layout;
 
 	/*
diff --git a/include/uapi/linux/hbind.h b/include/uapi/linux/hbind.h
index a9aba17ab142..cc4687587f5a 100644
--- a/include/uapi/linux/hbind.h
+++ b/include/uapi/linux/hbind.h
@@ -39,6 +39,14 @@ struct hbind_params {
 #define HBIND_ATOM_GET_CMD(v) ((v) & 0xfffff)
 #define HBIND_ATOM_SET_CMD(v) ((v) & 0xfffff)
 
+/*
+ * HBIND_CMD_DEFAULT restore default policy ie undo any of the previous policy.
+ *
+ * Additional dwords:
+ *      NONE (DWORDS MUST BE 0 !)
+ */
+#define HBIND_CMD_DEFAULT 0
+
 
 #define HBIND_IOCTL		_IOWR('H', 0x00, struct hbind_params)
 
diff --git a/kernel/fork.c b/kernel/fork.c
index 07cddff89c7b..bc40edcadc69 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -38,6 +38,7 @@
 #include <linux/mman.h>
 #include <linux/mmu_notifier.h>
 #include <linux/hmm.h>
+#include <linux/hms.h>
 #include <linux/fs.h>
 #include <linux/mm.h>
 #include <linux/vmacache.h>
@@ -671,6 +672,7 @@ void __mmdrop(struct mm_struct *mm)
 	mm_free_pgd(mm);
 	destroy_context(mm);
 	hmm_mm_destroy(mm);
+	hms_policy_fini(mm);
 	mmu_notifier_mm_destroy(mm);
 	check_mm(mm);
 	put_user_ns(mm->user_ns);
@@ -989,6 +991,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
 	RCU_INIT_POINTER(mm->exe_file, NULL);
 	mmu_notifier_mm_init(mm);
 	hmm_mm_init(mm);
+	hms_policy_init(mm);
 	init_tlb_flush_pending(mm);
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
 	mm->pmd_huge_pte = NULL;
diff --git a/mm/hms.c b/mm/hms.c
index bf328bd577dc..be2c4e526f25 100644
--- a/mm/hms.c
+++ b/mm/hms.c
@@ -24,6 +24,7 @@
 #include <linux/slab.h>
 #include <linux/init.h>
 #include <linux/hms.h>
+#include <linux/mm.h>
 #include <linux/fs.h>
 
 #include <uapi/linux/hbind.h>
@@ -31,7 +32,6 @@
 
 #define HBIND_FIX_ARRAY 64
 
-
 static ssize_t hbind_read(struct file *file, char __user *buf,
 			size_t count, loff_t *ppos)
 {
@@ -44,6 +44,300 @@ static ssize_t hbind_write(struct file *file, const char __user *buf,
 	return -EINVAL;
 }
 
+
+static void hms_policy_targets_get(struct hms_policy_targets *ptargets)
+{
+	kref_get(&ptargets->kref);
+}
+
+static void hms_policy_targets_free(struct kref *kref)
+{
+	struct hms_policy_targets *ptargets;
+
+	ptargets = container_of(kref, struct hms_policy_targets, kref);
+	kfree(ptargets->targets);
+	kfree(ptargets);
+}
+
+static void hms_policy_targets_put(struct hms_policy_targets *ptargets)
+{
+	kref_put(&ptargets->kref, &hms_policy_targets_free);
+}
+
+static struct hms_policy_targets* hms_policy_targets_new(const uint32_t *targets,
+							 unsigned ntargets)
+{
+	struct hms_policy_targets *ptargets;
+	void *_targets;
+	unsigned i, c;
+
+	_targets = kzalloc(ntargets * sizeof(void *), GFP_KERNEL);
+	if (_targets == NULL)
+		return NULL;
+
+	ptargets = kmalloc(sizeof(*ptargets), GFP_KERNEL);
+	if (ptargets == NULL) {
+		kfree(_targets);
+		return NULL;
+	}
+
+	kref_init(&ptargets->kref);
+	ptargets->targets = _targets;
+	ptargets->ntargets = ntargets;
+
+	for (i = 0, c = 0; i < ntargets; ++i) {
+		ptargets->targets[c] = hms_target_find(targets[i]);
+		c += !!((long)ptargets->targets[i]);
+	}
+
+	/* Ignore NULL targets[i] */
+	ptargets->ntargets = c;
+
+	if (!c) {
+		/* No valid targets pointless to waste memory ... */
+		hms_policy_targets_put(ptargets);
+		return NULL;
+	}
+
+	return ptargets;
+}
+
+
+static void hms_policy_range_get(struct hms_policy_range *prange)
+{
+	kref_get(&prange->kref);
+}
+
+static void hms_policy_range_free(struct kref *kref)
+{
+	struct hms_policy_range *prange;
+
+	prange = container_of(kref, struct hms_policy_range, kref);
+	hms_policy_targets_put(prange->ptargets);
+	kfree(prange);
+}
+
+static void hms_policy_range_put(struct hms_policy_range *prange)
+{
+	kref_put(&prange->kref, &hms_policy_range_free);
+}
+
+static struct hms_policy_range *hms_policy_range_new(const uint32_t *targets,
+						     unsigned long start,
+						     unsigned long end,
+						     unsigned ntargets)
+{
+	struct hms_policy_targets *ptargets;
+	struct hms_policy_range *prange;
+
+	ptargets = hms_policy_targets_new(targets, ntargets);
+	if (ptargets == NULL)
+		return NULL;
+
+	prange = kmalloc(sizeof(*prange), GFP_KERNEL);
+	if (prange == NULL)
+		return NULL;
+
+	prange->node.start = start & PAGE_MASK;
+	prange->node.last = PAGE_ALIGN(end) - 1;
+	prange->ptargets = ptargets;
+	kref_init(&prange->kref);
+
+	return prange;
+}
+
+static struct hms_policy_range *
+hms_policy_range_dup(struct hms_policy_range *_prange)
+{
+	struct hms_policy_range *prange;
+
+	prange = kmalloc(sizeof(*prange), GFP_KERNEL);
+	if (prange == NULL)
+		return NULL;
+
+	hms_policy_targets_get(_prange->ptargets);
+	prange->node.start = _prange->node.start;
+	prange->node.last = _prange->node.last;
+	prange->ptargets = _prange->ptargets;
+	kref_init(&prange->kref);
+
+	return prange;
+}
+
+
+void hms_policy_fini(struct mm_struct *mm)
+{
+	struct hms_policy *hpolicy = READ_ONCE(mm->hpolicy);
+	struct interval_tree_node *node;
+
+	spin_lock(&mm->page_table_lock);
+	hpolicy = READ_ONCE(mm->hpolicy);
+	mm->hpolicy = NULL;
+	spin_unlock(&mm->page_table_lock);
+
+	/* No active heterogeneous policy structure so nothing to cleanup. */
+	if (hpolicy == NULL)
+		return;
+
+	mmu_notifier_unregister_no_release(&hpolicy->mn, mm);
+
+	down_write(&hpolicy->sem);
+	node = interval_tree_iter_first(&hpolicy->ranges, 0, -1UL);
+	while (node) {
+		struct hms_policy_range *prange;
+		struct interval_tree_node *next;
+
+		prange = container_of(node, struct hms_policy_range, node);
+		next = interval_tree_iter_next(node, 0, -1UL);
+		interval_tree_remove(node, &hpolicy->ranges);
+		hms_policy_range_put(prange);
+		node = next;
+	}
+	up_write(&hpolicy->sem);
+
+	kfree(hpolicy);
+}
+
+
+static int hbind_default_locked(struct hms_policy *hpolicy,
+				struct hbind_params *params)
+{
+	struct interval_tree_node *node;
+	unsigned long start, last;
+	int ret = 0;
+
+	start = params->start;
+	last = params->end - 1UL;
+
+	node = interval_tree_iter_first(&hpolicy->ranges, start, last);
+	while (node) {
+		struct hms_policy_range *prange;
+		struct interval_tree_node *next;
+
+		prange = container_of(node, struct hms_policy_range, node);
+		next = interval_tree_iter_next(node, start, last);
+		if (node->start < start && node->last > last) {
+			/* Node is split in 2 */
+			struct hms_policy_range *_prange;
+			_prange = hms_policy_range_dup(prange);
+			if (_prange == NULL) {
+				ret = -ENOMEM;
+				break;
+			}
+			prange->node.last = start - 1;
+			_prange->node.start = last + 1;
+			interval_tree_insert(&_prange->node, &hpolicy->ranges);
+			break;
+		} else if (node->start < start) {
+			prange->node.last = start - 1;
+		} else if (node->last > last) {
+			prange->node.start = last + 1;
+		} else {
+			/* Fully inside [start, last] */
+			interval_tree_remove(node, &hpolicy->ranges);
+		}
+
+		node = next;
+	}
+
+	return ret;
+}
+
+static int hbind_default(struct mm_struct *mm, struct hbind_params *params,
+			 const uint32_t *targets, uint32_t *atoms)
+{
+	struct hms_policy *hpolicy = READ_ONCE(mm->hpolicy);
+	int ret;
+
+	/* No active heterogeneous policy structure so no range to reset. */
+	if (hpolicy == NULL)
+		return 0;
+
+	down_write(&hpolicy->sem);
+	ret = hbind_default_locked(hpolicy, params);
+	up_write(&hpolicy->sem);
+
+	return ret;
+}
+
+
+static void hms_policy_notifier_release(struct mmu_notifier *mn,
+					struct mm_struct *mm)
+{
+	hms_policy_fini(mm);
+}
+
+static int hms_policy_notifier_invalidate_range_start(struct mmu_notifier *mn,
+				       const struct mmu_notifier_range *range)
+{
+	if (range->event == MMU_NOTIFY_UNMAP) {
+		struct hbind_params params;
+
+		if (!range->blockable)
+			return -EBUSY;
+
+		params.natoms = 0;
+		params.ntargets = 0;
+		params.end = range->end;
+		params.start = range->start;
+		hbind_default(range->mm, &params, NULL, NULL);
+	}
+
+	return 0;
+}
+
+static const struct mmu_notifier_ops hms_policy_notifier_ops = {
+	.release = hms_policy_notifier_release,
+	.invalidate_range_start = hms_policy_notifier_invalidate_range_start,
+};
+
+static struct hms_policy *hms_policy_get(struct mm_struct *mm)
+{
+	struct hms_policy *hpolicy = READ_ONCE(mm->hpolicy);
+	bool mmu_notifier = false;
+
+	/*
+	 * The hpolicy struct can only be freed once the mm_struct goes away,
+	 * hence only pre-allocate if none is attach yet.
+	 */
+	if (hpolicy)
+		return hpolicy;
+
+	hpolicy = kzalloc(sizeof(*hpolicy), GFP_KERNEL);
+	if (hpolicy == NULL)
+		return NULL;
+
+	init_rwsem(&hpolicy->sem);
+
+	spin_lock(&mm->page_table_lock);
+	if (!mm->hpolicy) {
+		mm->hpolicy = hpolicy;
+		mmu_notifier = true;
+		hpolicy = NULL;
+	}
+	spin_unlock(&mm->page_table_lock);
+
+	if (mmu_notifier) {
+		int ret;
+
+		hpolicy->mn.ops = &hms_policy_notifier_ops;
+		ret = mmu_notifier_register(&hpolicy->mn, mm);
+		if (ret) {
+			spin_lock(&mm->page_table_lock);
+			hpolicy = mm->hpolicy;
+			mm->hpolicy = NULL;
+			spin_unlock(&mm->page_table_lock);
+		}
+	}
+
+	if (hpolicy)
+		kfree(hpolicy);
+
+	/* At this point mm->hpolicy is valid */
+	return mm->hpolicy;
+}
+
+
 static long hbind_ioctl(struct file *file, unsigned cmd, unsigned long arg)
 {
 	uint32_t *targets, *_dtargets = NULL, _ftargets[HBIND_FIX_ARRAY];
@@ -114,6 +408,16 @@ static long hbind_ioctl(struct file *file, unsigned cmd, unsigned long arg)
 	for (i = 0, ndwords = 1; i < params.natoms; i += ndwords) {
 		ndwords = 1 + HBIND_ATOM_GET_DWORDS(atoms[i]);
 		switch (HBIND_ATOM_GET_CMD(atoms[i])) {
+		case HBIND_CMD_DEFAULT:
+			if (ndwords != 1) {
+				ret = -EINVAL;
+				goto out_mm;
+			}
+			ret = hbind_default(current->mm, &params,
+					    targets, atoms);
+			if (ret)
+				goto out_mm;
+			break;
 		default:
 			ret = -EINVAL;
 			goto out_mm;
-- 
2.17.2
