Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E3EEA6B01AD
	for <linux-mm@kvack.org>; Sat,  3 Jul 2010 01:38:54 -0400 (EDT)
From: Zach Pfeffer <zpfeffer@codeaurora.org>
Subject: [RFC 3/3 v3] mm: iommu: The Virtual Contiguous Memory Manager
Date: Fri,  2 Jul 2010 22:38:45 -0700
Message-Id: <1278135525-20327-1-git-send-email-zpfeffer@codeaurora.org>
Sender: owner-linux-mm@kvack.org
To: mel@csn.ul.ie
Cc: andi@firstfloor.org, dwalker@codeaurora.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Zach Pfeffer <zpfeffer@codeaurora.org>
List-ID: <linux-mm.kvack.org>

The Virtual Contiguous Memory Manager (VCMM) allows the CPU, IOMMU
devices and physically mapped devices to map the same physical memory
using a common API. It achieves this by abstracting mapping into graph
management.

Within the graph abstraction, the device end-points are CPUs with and
without MMUs and devices with and without IOMMUs. The mapped memory is
the other end-point. In the [IO]MMU case this is readily apparent. In
the non-[IO]MMU case, it is as apparent if you give each device a
"one-to-one" mapper. These mappings are wrapped up into "reservations"
represented by struct res's.

Also part of this graph is a mapping of a virtual space, struct vcm,
to a device. One virtual space may be associated with multiple devices
and multiple virtual-spaces may be associated with the same device. In
the case of a one-to-one device this virtual-space mirrors the
physical-space. A virtual-space is tied to a device using a
"association", a struct avcm. A device may be associated with a
virtual-space without being programed to translate based on that
virtual-space. Programming occurs using an activate call.

The physical side of the mapping (or intermediate address-space side
in virtualized environments) is represented by a struct physmem. Due to
the peculiar needs of various IOMMUs, the VCM contains a physical
allocation subsystem that manages blocks of different sizes from
different pools. This allows fine grained control of block and
physical placement, a feature many advanced IOMMU devices need.

Once a user has made a reservation on a VCM and allocated physical
memory, the two graph end-points are joined in a backing step. This
step allows multiple reservations to map the same physical location.

Many of the functions in the API take various attributes that provide
fine grained control of the objects they create. For instance,
reservations can map cachable memory and physical allocations can be
constrained to use a particular subset of block sizes.

Signed-off-by: Zach Pfeffer <zpfeffer@codeaurora.org>
---
 arch/arm/mm/vcm.c         | 1877 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/vcm.h       |  661 ++++++++++++++++
 include/linux/vcm_types.h |  338 ++++++++
 3 files changed, 2876 insertions(+), 0 deletions(-)
 create mode 100644 arch/arm/mm/vcm.c
 create mode 100644 include/linux/vcm.h
 create mode 100644 include/linux/vcm_types.h

diff --git a/arch/arm/mm/vcm.c b/arch/arm/mm/vcm.c
new file mode 100644
index 0000000..2c951c3
--- /dev/null
+++ b/arch/arm/mm/vcm.c
@@ -0,0 +1,1877 @@
+/* Copyright (c) 2010, Code Aurora Forum. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 and
+ * only version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA.
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/vcm_mm.h>
+#include <linux/vcm.h>
+#include <linux/vcm_types.h>
+#include <linux/errno.h>
+#include <linux/spinlock.h>
+
+#include <asm/page.h>
+#include <asm/sizes.h>
+
+#ifdef CONFIG_SMMU
+#include <mach/smmu_driver.h>
+#endif
+
+/* alloc_vm_area */
+#include <linux/pfn.h>
+#include <linux/mm.h>
+#include <linux/vmalloc.h>
+
+/* may be temporary */
+#include <linux/bootmem.h>
+
+#include <asm/cacheflush.h>
+#include <asm/mach/map.h>
+
+#define BOOTMEM_SZ	SZ_32M
+#define BOOTMEM_ALIGN	SZ_1M
+
+#define CONT_SZ		SZ_8M
+#define CONT_ALIGN	SZ_1M
+
+#define ONE_TO_ONE_CHK 1
+
+#define vcm_err(a, ...)							\
+	pr_err("ERROR %s %i " a, __func__, __LINE__, ##__VA_ARGS__)
+
+static void *bootmem;
+static void *bootmem_cont;
+static struct vcm *cont_vcm;
+static struct phys_chunk *cont_phys_chunk;
+
+DEFINE_SPINLOCK(vcmlock);
+
+static int vcm_no_res(struct vcm *vcm)
+{
+	if (!vcm) {
+		vcm_err("NULL vcm\n");
+		goto fail;
+	}
+
+	return list_empty(&vcm->res_head);
+fail:
+	return -EINVAL;
+}
+
+static int vcm_no_assoc(struct vcm *vcm)
+{
+	if (!vcm) {
+		vcm_err("NULL vcm\n");
+		goto fail;
+	}
+
+	return list_empty(&vcm->assoc_head);
+fail:
+	return -EINVAL;
+}
+
+static int vcm_all_activated(struct vcm *vcm)
+{
+	struct avcm *avcm;
+
+	if (!vcm) {
+		vcm_err("NULL vcm\n");
+		goto fail;
+	}
+
+	list_for_each_entry(avcm, &vcm->assoc_head, assoc_elm)
+		if (!avcm->is_active)
+			return 0;
+
+	return 1;
+fail:
+	return -1;
+}
+
+static void vcm_destroy_common(struct vcm *vcm)
+{
+	if (!vcm) {
+		vcm_err("NULL vcm\n");
+		return;
+	}
+
+	memset(vcm, 0, sizeof(*vcm));
+	kfree(vcm);
+}
+
+static struct vcm *vcm_create_common(void)
+{
+	struct vcm *vcm = 0;
+
+	vcm = kzalloc(sizeof(*vcm), GFP_KERNEL);
+	if (!vcm) {
+		vcm_err("kzalloc(%i, GFP_KERNEL) ret 0\n",
+			sizeof(*vcm));
+		goto fail;
+	}
+
+	INIT_LIST_HEAD(&vcm->res_head);
+	INIT_LIST_HEAD(&vcm->assoc_head);
+
+	return vcm;
+
+fail:
+	return NULL;
+}
+
+
+static int vcm_create_pool(struct vcm *vcm, size_t start_addr, size_t len)
+{
+	int ret = 0;
+
+	if (!vcm) {
+		vcm_err("NULL vcm\n");
+		goto fail;
+	}
+
+	vcm->start_addr = start_addr;
+	vcm->len = len;
+
+	vcm->pool = gen_pool_create(PAGE_SHIFT, -1);
+	if (!vcm->pool) {
+		vcm_err("gen_pool_create(%x, -1) ret 0\n", PAGE_SHIFT);
+		goto fail;
+	}
+
+	ret = gen_pool_add(vcm->pool, start_addr, len, -1);
+	if (ret) {
+		vcm_err("gen_pool_add(%p, %p, %i, -1) ret %i\n", vcm->pool,
+			(void *) start_addr, len, ret);
+		goto fail2;
+	}
+
+	return 0;
+
+fail2:
+	gen_pool_destroy(vcm->pool);
+fail:
+	return -1;
+}
+
+
+static struct vcm *vcm_create_flagged(int flag, size_t start_addr, size_t len)
+{
+	int ret = 0;
+	struct vcm *vcm = 0;
+
+	vcm = vcm_create_common();
+	if (!vcm) {
+		vcm_err("NULL vcm\n");
+		goto fail;
+	}
+
+	/* special one-to-one mapping case */
+	if ((flag & ONE_TO_ONE_CHK) &&
+	    bootmem_cont &&
+	    __pa(bootmem_cont) &&
+	    start_addr == __pa(bootmem_cont) &&
+	    len == CONT_SZ) {
+		vcm->type = VCM_ONE_TO_ONE;
+	} else {
+		ret = vcm_create_pool(vcm, start_addr, len);
+		vcm->type = VCM_DEVICE;
+	}
+
+	if (ret) {
+		vcm_err("vcm_create_pool(%p, %p, %i) ret %i\n", vcm,
+			(void *) start_addr, len, ret);
+		goto fail2;
+	}
+
+	return vcm;
+
+fail2:
+	vcm_destroy_common(vcm);
+fail:
+	return NULL;
+}
+
+struct vcm *vcm_create(unsigned long start_addr, size_t len)
+{
+	unsigned long flags;
+	struct vcm *vcm;
+
+	spin_lock_irqsave(&vcmlock, flags);
+	vcm = vcm_create_flagged(ONE_TO_ONE_CHK, start_addr, len);
+	spin_unlock_irqrestore(&vcmlock, flags);
+	return vcm;
+}
+
+
+static int ext_vcm_id_valid(size_t ext_vcm_id)
+{
+	return ((ext_vcm_id == VCM_PREBUILT_KERNEL) ||
+		(ext_vcm_id == VCM_PREBUILT_USER));
+}
+
+
+struct vcm *vcm_create_from_prebuilt(size_t ext_vcm_id)
+{
+	unsigned long flags;
+	struct vcm *vcm = 0;
+
+	spin_lock_irqsave(&vcmlock, flags);
+
+	if (!ext_vcm_id_valid(ext_vcm_id)) {
+		vcm_err("ext_vcm_id_valid(%i) ret 0\n", ext_vcm_id);
+		goto fail;
+	}
+
+	vcm = vcm_create_common();
+	if (!vcm) {
+		vcm_err("NULL vcm\n");
+		goto fail;
+	}
+
+	if (ext_vcm_id == VCM_PREBUILT_KERNEL)
+		vcm->type = VCM_EXT_KERNEL;
+	else if (ext_vcm_id == VCM_PREBUILT_USER)
+		vcm->type = VCM_EXT_USER;
+	else {
+		vcm_err("UNREACHABLE ext_vcm_id is illegal\n");
+		goto fail_free;
+	}
+
+	/* TODO: set kernel and userspace start_addr and len, if this
+	 * makes sense */
+
+	spin_unlock_irqrestore(&vcmlock, flags);
+	return vcm;
+
+fail_free:
+	vcm_destroy_common(vcm);
+fail:
+	spin_unlock_irqrestore(&vcmlock, flags);
+	return NULL;
+}
+
+
+struct vcm *vcm_clone(struct vcm *vcm)
+{
+	return 0;
+}
+
+
+/* No lock needed, vcm->start_addr is never updated after creation */
+size_t vcm_get_start_addr(struct vcm *vcm)
+{
+	if (!vcm) {
+		vcm_err("NULL vcm\n");
+		return 1;
+	}
+
+	return vcm->start_addr;
+}
+
+
+/* No lock needed, vcm->len is never updated after creation */
+size_t vcm_get_len(struct vcm *vcm)
+{
+	if (!vcm) {
+		vcm_err("NULL vcm\n");
+		return 0;
+	}
+
+	return vcm->len;
+}
+
+
+static int vcm_free_common_rule(struct vcm *vcm)
+{
+	int ret;
+
+	if (!vcm) {
+		vcm_err("NULL vcm\n");
+		goto fail;
+	}
+
+	ret = vcm_no_res(vcm);
+	if (!ret) {
+		vcm_err("vcm_no_res(%p) ret 0\n", vcm);
+		goto fail_busy;
+	}
+
+	if (ret == -EINVAL) {
+		vcm_err("vcm_no_res(%p) ret -EINVAL\n", vcm);
+		goto fail;
+	}
+
+	ret = vcm_no_assoc(vcm);
+	if (!ret) {
+		vcm_err("vcm_no_assoc(%p) ret 0\n", vcm);
+		goto fail_busy;
+	}
+
+	if (ret == -EINVAL) {
+		vcm_err("vcm_no_assoc(%p) ret -EINVAL\n", vcm);
+		goto fail;
+	}
+
+	return 0;
+
+fail_busy:
+	return -EBUSY;
+fail:
+	return -EINVAL;
+}
+
+
+static int vcm_free_pool_rule(struct vcm *vcm)
+{
+	if (!vcm) {
+		vcm_err("NULL vcm\n");
+		goto fail;
+	}
+
+	/* A vcm always has a valid pool, don't free the vcm because
+	   what we got is probably invalid.
+	*/
+	if (!vcm->pool) {
+		vcm_err("NULL vcm->pool\n");
+		goto fail;
+	}
+
+	return 0;
+
+fail:
+	return -EINVAL;
+}
+
+
+static void vcm_free_common(struct vcm *vcm)
+{
+	memset(vcm, 0, sizeof(*vcm));
+
+	kfree(vcm);
+}
+
+
+static int vcm_free_pool(struct vcm *vcm)
+{
+	if (!vcm) {
+		vcm_err("NULL vcm\n");
+		goto fail;
+	}
+
+	gen_pool_destroy(vcm->pool);
+
+	return 0;
+
+fail:
+	return -1;
+}
+
+
+static int __vcm_free(struct vcm *vcm)
+{
+	int ret;
+
+	if (!vcm) {
+		vcm_err("NULL vcm\n");
+		goto fail;
+	}
+
+	ret = vcm_free_common_rule(vcm);
+	if (ret != 0) {
+		vcm_err("vcm_free_common_rule(%p) ret %i\n", vcm, ret);
+		goto fail;
+	}
+
+	if (vcm->type == VCM_DEVICE) {
+		ret = vcm_free_pool_rule(vcm);
+		if (ret != 0) {
+			vcm_err("vcm_free_pool_rule(%p) ret %i\n",
+				(void *) vcm, ret);
+			goto fail;
+		}
+
+		ret = vcm_free_pool(vcm);
+		if (ret != 0) {
+			vcm_err("vcm_free_pool(%p) ret %i", (void *) vcm, ret);
+			goto fail;
+		}
+	}
+
+	vcm_free_common(vcm);
+
+	return 0;
+
+fail:
+	return -EINVAL;
+}
+
+int vcm_free(struct vcm *vcm)
+{
+	unsigned long flags;
+	int ret;
+
+	spin_lock_irqsave(&vcmlock, flags);
+	ret = __vcm_free(vcm);
+	spin_unlock_irqrestore(&vcmlock, flags);
+
+	return ret;
+}
+
+
+static struct res *__vcm_reserve(struct vcm *vcm, size_t len, u32 attr)
+{
+	struct res *res = NULL;
+
+	if (!vcm) {
+		vcm_err("NULL vcm\n");
+		goto fail;
+	}
+
+	if (len == 0) {
+		vcm_err("len is 0\n");
+		goto fail;
+	}
+
+	res = kzalloc(sizeof(*res), GFP_KERNEL);
+	if (!res) {
+		vcm_err("kzalloc(%i, GFP_KERNEL) ret 0", sizeof(*res));
+		goto fail;
+	}
+
+	INIT_LIST_HEAD(&res->res_elm);
+	res->vcm = vcm;
+	res->len = len;
+	res->attr = attr;
+
+	if (len/SZ_1M)
+		res->alignment_req = SZ_1M;
+	else if (len/SZ_64K)
+		res->alignment_req = SZ_64K;
+	else
+		res->alignment_req = SZ_4K;
+
+	res->aligned_len = res->alignment_req + len;
+
+	switch (vcm->type) {
+	case VCM_DEVICE:
+		/* should always be not zero */
+		if (!vcm->pool) {
+			vcm_err("NULL vcm->pool\n");
+			goto fail2;
+		}
+
+		res->ptr = gen_pool_alloc(vcm->pool, res->aligned_len);
+		if (!res->ptr) {
+			vcm_err("gen_pool_alloc(%p, %i) ret 0\n",
+				vcm->pool, res->aligned_len);
+			goto fail2;
+		}
+
+		/* Calculate alignment... this will all change anyway */
+		res->dev_addr = res->ptr +
+			(res->alignment_req -
+			 (res->ptr & (res->alignment_req - 1)));
+
+		break;
+	case VCM_EXT_KERNEL:
+		res->vm_area = alloc_vm_area(res->aligned_len);
+		res->mapped = 0; /* be explicit */
+		if (!res->vm_area) {
+			vcm_err("NULL res->vm_area\n");
+			goto fail2;
+		}
+
+		res->dev_addr = (size_t) res->vm_area->addr +
+			(res->alignment_req -
+			 ((size_t) res->vm_area->addr &
+			  (res->alignment_req - 1)));
+
+		break;
+	case VCM_ONE_TO_ONE:
+		break;
+	default:
+		vcm_err("%i is an invalid vcm->type\n", vcm->type);
+		goto fail2;
+	}
+
+	list_add_tail(&res->res_elm, &vcm->res_head);
+
+	return res;
+
+fail2:
+	kfree(res);
+fail:
+	return 0;
+}
+
+
+struct res *vcm_reserve(struct vcm *vcm, size_t len, u32 attr)
+{
+	unsigned long flags;
+	struct res *res;
+
+	spin_lock_irqsave(&vcmlock, flags);
+	res = __vcm_reserve(vcm, len, attr);
+	spin_unlock_irqrestore(&vcmlock, flags);
+
+	return res;
+}
+
+
+struct res *vcm_reserve_at(enum memtarget_t memtarget, struct vcm* vcm,
+		     size_t len, u32 attr)
+{
+	return 0;
+}
+
+
+/* No lock needed, res->vcm is never updated after creation */
+struct vcm *vcm_get_vcm_from_res(struct res *res)
+{
+	if (!res) {
+		vcm_err("NULL res\n");
+		return 0;
+	}
+
+	return res->vcm;
+}
+
+
+static int __vcm_unreserve(struct res *res)
+{
+	struct vcm *vcm;
+
+	if (!res) {
+		vcm_err("NULL res\n");
+		goto fail;
+	}
+
+	if (!res->vcm) {
+		vcm_err("NULL res->vcm\n");
+		goto fail;
+	}
+
+	vcm = res->vcm;
+	if (!vcm) {
+		vcm_err("NULL vcm\n");
+		goto fail;
+	}
+
+	switch (vcm->type) {
+	case VCM_DEVICE:
+		if (!res->vcm->pool) {
+			vcm_err("NULL (res->vcm))->pool\n");
+			goto fail;
+		}
+
+		/* res->ptr could be zero, this isn't an error */
+		gen_pool_free(res->vcm->pool, res->ptr,
+			      res->aligned_len);
+		break;
+	case VCM_EXT_KERNEL:
+		if (res->mapped) {
+			vcm_err("res->mapped is true\n");
+			goto fail;
+		}
+
+		/* This may take a little explaining.
+		 * In the kernel vunmap will free res->vm_area
+		 * so if we've called it then we shouldn't call
+		 * free_vm_area(). If we've called it we set
+		 * res->vm_area to 0.
+		 */
+		if (res->vm_area) {
+			free_vm_area(res->vm_area);
+			res->vm_area = 0;
+		}
+
+		break;
+	case VCM_ONE_TO_ONE:
+		break;
+	default:
+		vcm_err("%i is an invalid vcm->type\n", vcm->type);
+		goto fail;
+	}
+
+	list_del(&res->res_elm);
+
+	/* be extra careful by clearing the memory before freeing it */
+	memset(res, 0, sizeof(*res));
+
+	kfree(res);
+
+	return 0;
+
+fail:
+	return -EINVAL;
+}
+
+
+int vcm_unreserve(struct res *res)
+{
+	unsigned long flags;
+	int ret;
+
+	spin_lock_irqsave(&vcmlock, flags);
+	ret = __vcm_unreserve(res);
+	spin_unlock_irqrestore(&vcmlock, flags);
+
+	return ret;
+}
+
+
+/* No lock needed, res->len is never updated after creation */
+size_t vcm_get_res_len(struct res *res)
+{
+	if (!res) {
+		vcm_err("res is 0\n");
+		return 0;
+	}
+
+	return res->len;
+}
+
+
+int vcm_set_res_attr(struct res *res, u32 attr)
+{
+	return 0;
+}
+
+
+size_t vcm_get_num_res(struct vcm *vcm)
+{
+	return 0;
+}
+
+
+struct res *vcm_get_next_res(struct vcm *vcm, struct res *res)
+{
+	return 0;
+}
+
+
+size_t vcm_res_copy(struct res *to, size_t to_off, struct res *from,
+		    size_t from_off, size_t len)
+{
+	return 0;
+}
+
+
+size_t vcm_get_min_page_size(void)
+{
+	return PAGE_SIZE;
+}
+
+
+static int vcm_to_smmu_attr(u32 attr)
+{
+	int smmu_attr = 0;
+
+	switch (attr & VCM_CACHE_POLICY) {
+	case VCM_NOTCACHED:
+		smmu_attr = VCM_DEV_ATTR_NONCACHED;
+		break;
+	case VCM_WB_WA:
+		smmu_attr = VCM_DEV_ATTR_CACHED_WB_WA;
+		smmu_attr |= VCM_DEV_ATTR_SH;
+		break;
+	case VCM_WB_NWA:
+		smmu_attr = VCM_DEV_ATTR_CACHED_WB_NWA;
+		smmu_attr |= VCM_DEV_ATTR_SH;
+		break;
+	case VCM_WT:
+		smmu_attr = VCM_DEV_ATTR_CACHED_WT;
+		smmu_attr |= VCM_DEV_ATTR_SH;
+		break;
+	default:
+		return -1;
+	}
+
+	return smmu_attr;
+}
+
+
+/* TBD if you vcm_back again what happens? */
+int vcm_back(struct res *res, struct physmem *physmem)
+{
+	unsigned long flags;
+	struct vcm *vcm;
+	struct phys_chunk *chunk;
+	size_t va = 0;
+	int ret;
+	int attr;
+
+	spin_lock_irqsave(&vcmlock, flags);
+
+	if (!res) {
+		vcm_err("NULL res\n");
+		goto fail;
+	}
+
+	vcm = res->vcm;
+	if (!vcm) {
+		vcm_err("NULL vcm\n");
+		goto fail;
+	}
+
+	switch (vcm->type) {
+	case VCM_DEVICE:
+	case VCM_EXT_KERNEL: /* hack part 1 */
+		attr = vcm_to_smmu_attr(res->attr);
+		if (attr == -1) {
+			vcm_err("Bad SMMU attr\n");
+			goto fail;
+		}
+		break;
+	default:
+		attr = 0;
+		break;
+	}
+
+	if (!physmem) {
+		vcm_err("NULL physmem\n");
+		goto fail;
+	}
+
+	if (res->len == 0) {
+		vcm_err("res->len is 0\n");
+		goto fail;
+	}
+
+	if (physmem->len == 0) {
+		vcm_err("physmem->len is 0\n");
+		goto fail;
+	}
+
+	if (res->len != physmem->len) {
+		vcm_err("res->len (%i) != physmem->len (%i)\n",
+			res->len, physmem->len);
+		goto fail;
+	}
+
+	if (physmem->is_cont) {
+		if (physmem->res == 0) {
+			vcm_err("cont physmem->res is 0");
+			goto fail;
+		}
+	} else {
+		/* fail if no physmem */
+		if (list_empty(&physmem->alloc_head.allocated)) {
+			vcm_err("no allocated phys memory");
+			goto fail;
+		}
+	}
+
+	ret = vcm_no_assoc(res->vcm);
+	if (ret == 1) {
+		vcm_err("can't back un associated VCM\n");
+		goto fail;
+	}
+
+	if (ret == -1) {
+		vcm_err("vcm_no_assoc() ret -1\n");
+		goto fail;
+	}
+
+	ret = vcm_all_activated(res->vcm);
+	if (ret == 0) {
+		vcm_err("can't back, not all associations are activated\n");
+		goto fail_eagain;
+	}
+
+	if (ret == -1) {
+		vcm_err("vcm_all_activated() ret -1\n");
+		goto fail;
+	}
+
+	va = res->dev_addr;
+
+	list_for_each_entry(chunk, &physmem->alloc_head.allocated,
+			    allocated) {
+		struct vcm *vcm = res->vcm;
+		size_t chunk_size =  vcm_alloc_idx_to_size(chunk->size_idx);
+
+		switch (vcm->type) {
+		case VCM_DEVICE:
+		{
+#ifdef CONFIG_SMMU
+			struct avcm *avcm;
+			/* map all */
+			list_for_each_entry(avcm, &vcm->assoc_head,
+					    assoc_elm) {
+
+				ret = smmu_map(
+					(struct smmu_dev *) avcm->dev,
+					chunk->pa, va, chunk_size, attr);
+				if (ret != 0) {
+					vcm_err("smmu_map(%p, %p, %p, 0x%x,"
+						"0x%x)"
+						" ret %i",
+						(void *) avcm->dev,
+						(void *) chunk->pa,
+						(void *) va,
+						(int) chunk_size, attr, ret);
+					goto fail;
+					/* TODO handle weird inter-map case */
+				}
+			}
+			break;
+#else
+			vcm_err("No SMMU support - VCM_DEVICE not supported\n");
+			goto fail;
+#endif
+		}
+
+		case VCM_EXT_KERNEL:
+		{
+			unsigned int pages_in_chunk = chunk_size / PAGE_SIZE;
+			unsigned long loc_va = va;
+			unsigned long loc_pa = chunk->pa;
+
+			const struct mem_type *mtype;
+
+			/* TODO: get this based on MEMTYPE */
+			mtype = get_mem_type(MT_DEVICE);
+			if (!mtype) {
+				vcm_err("mtype is 0\n");
+				goto fail;
+			}
+
+			/* TODO: Map with the same chunk size */
+			while (pages_in_chunk--) {
+				ret = ioremap_page(loc_va,
+						   loc_pa,
+						   mtype);
+				if (ret != 0) {
+					vcm_err("ioremap_page(%p, %p, %p) ret"
+						" %i", (void *) loc_va,
+						(void *) loc_pa,
+						(void *) mtype, ret);
+					goto fail;
+					/* TODO handle weird
+					   inter-map case */
+				}
+
+				/* hack part 2 */
+				/* we're changing the PT entry behind
+				 * linux's back
+				 */
+				ret = cpu_set_attr(loc_va, PAGE_SIZE, attr);
+				if (ret != 0) {
+					vcm_err("cpu_set_attr(%p, %lu, %x)"
+						"ret %i\n",
+						(void *) loc_va, PAGE_SIZE,
+						attr, ret);
+					goto fail;
+					/* TODO handle weird
+					   inter-map case */
+				}
+
+				res->mapped = 1;
+
+				loc_va += PAGE_SIZE;
+				loc_pa += PAGE_SIZE;
+			}
+
+			flush_cache_vmap(va, loc_va);
+			break;
+		}
+		case VCM_ONE_TO_ONE:
+			va = chunk->pa;
+			break;
+		default:
+			/* this should never happen */
+			goto fail;
+		}
+
+		va += chunk_size;
+		/* also add res to the allocated chunk list of refs */
+	}
+
+	/* note the reservation */
+	res->physmem = physmem;
+
+	spin_unlock_irqrestore(&vcmlock, flags);
+	return 0;
+fail_eagain:
+	spin_unlock_irqrestore(&vcmlock, flags);
+	return -EAGAIN;
+fail:
+	spin_unlock_irqrestore(&vcmlock, flags);
+	return -EINVAL;
+}
+
+
+int vcm_unback(struct res *res)
+{
+	unsigned long flags;
+	struct vcm *vcm;
+	struct physmem *physmem;
+	int ret;
+
+	spin_lock_irqsave(&vcmlock, flags);
+
+	if (!res)
+		goto fail;
+
+	vcm = res->vcm;
+	if (!vcm) {
+		vcm_err("NULL vcm\n");
+		goto fail;
+	}
+
+	if (!res->physmem) {
+		vcm_err("can't unback a non-backed reservation\n");
+		goto fail;
+	}
+
+	physmem = res->physmem;
+	if (!physmem) {
+		vcm_err("physmem is NULL\n");
+		goto fail;
+	}
+
+	if (list_empty(&physmem->alloc_head.allocated)) {
+		vcm_err("physmem allocation is empty\n");
+		goto fail;
+	}
+
+	ret = vcm_no_assoc(res->vcm);
+	if (ret == 1) {
+		vcm_err("can't unback a unassociated reservation\n");
+		goto fail;
+	}
+
+	if (ret == -1) {
+		vcm_err("vcm_no_assoc(%p) ret -1\n", (void *) res->vcm);
+		goto fail;
+	}
+
+	ret = vcm_all_activated(res->vcm);
+	if (ret == 0) {
+		vcm_err("can't unback, not all associations are active\n");
+		goto fail_eagain;
+	}
+
+	if (ret == -1) {
+		vcm_err("vcm_all_activated(%p) ret -1\n", (void *) res->vcm);
+		goto fail;
+	}
+
+
+	switch (vcm->type) {
+	case VCM_EXT_KERNEL:
+		if (!res->mapped) {
+			vcm_err("can't unback an unmapped VCM_EXT_KERNEL"
+				" VCM\n");
+			goto fail;
+		}
+
+		/* vunmap free's vm_area */
+		vunmap(res->vm_area->addr);
+		res->vm_area = 0;
+
+		res->mapped = 0;
+		break;
+
+	case VCM_DEVICE:
+	{
+#ifdef CONFIG_SMMU
+		struct phys_chunk *chunk;
+		size_t va = res->dev_addr;
+
+		list_for_each_entry(chunk, &physmem->alloc_head.allocated,
+				    allocated) {
+			struct vcm *vcm = res->vcm;
+			size_t chunk_size =
+				vcm_alloc_idx_to_size(chunk->size_idx);
+			struct avcm *avcm;
+
+			/* un map all */
+			list_for_each_entry(avcm, &vcm->assoc_head, assoc_elm) {
+				ret = smmu_unmap(
+					(struct smmu_dev *) avcm->dev,
+					va, chunk_size);
+				if (ret != 0) {
+					vcm_err("smmu_unmap(%p, %p, 0x%x)"
+						" ret %i",
+						(void *) avcm->dev,
+						(void *) va,
+						(int) chunk_size, ret);
+					goto fail;
+					/* TODO handle weird inter-unmap state*/
+				}
+			}
+			va += chunk_size;
+			/* may to a light unback, depending on the requested
+			 * functionality
+			 */
+		}
+#else
+		vcm_err("No SMMU support - VCM_DEVICE memory not supported\n");
+		goto fail;
+#endif
+		break;
+	}
+
+	case VCM_ONE_TO_ONE:
+		break;
+	default:
+		/* this should never happen */
+		goto fail;
+	}
+
+	/* clear the reservation */
+	res->physmem = 0;
+
+	spin_unlock_irqrestore(&vcmlock, flags);
+	return 0;
+fail_eagain:
+	spin_unlock_irqrestore(&vcmlock, flags);
+	return -EAGAIN;
+fail:
+	spin_unlock_irqrestore(&vcmlock, flags);
+	return -EINVAL;
+}
+
+
+enum memtarget_t vcm_get_memtype_of_res(struct res *res)
+{
+	return VCM_INVALID;
+}
+
+static int vcm_free_max_munch_cont(struct phys_chunk *head)
+{
+	struct phys_chunk *chunk, *tmp;
+
+	if (!head)
+		return -1;
+
+	list_for_each_entry_safe(chunk, tmp, &head->allocated,
+				 allocated) {
+		list_del_init(&chunk->allocated);
+	}
+
+	return 0;
+}
+
+static int vcm_alloc_max_munch_cont(size_t start_addr, size_t len,
+				    struct phys_chunk *head)
+{
+	/* this function should always succeed, since it
+	   parallels a VCM */
+
+	int i, j;
+
+	if (!head) {
+		vcm_err("head is NULL in continuous map.\n");
+		goto fail;
+	}
+
+	if (start_addr < __pa(bootmem_cont)) {
+		vcm_err("phys start addr (%p) < base (%p)\n",
+			(void *) start_addr, (void *) __pa(bootmem_cont));
+		goto fail;
+	}
+
+	if ((start_addr + len) >= (__pa(bootmem_cont) + CONT_SZ)) {
+		vcm_err("requested region (%p + %i) > "
+			" available region (%p + %i)",
+			(void *) start_addr, (int) len,
+			(void *) __pa(bootmem_cont), CONT_SZ);
+		goto fail;
+	}
+
+	i = (start_addr - __pa(bootmem_cont))/SZ_4K;
+
+	for (j = 0; j < ARRAY_SIZE(chunk_sizes); ++j) {
+		while (len/chunk_sizes[j]) {
+			if (!list_empty(&cont_phys_chunk[i].allocated)) {
+				vcm_err("chunk %i ( addr %p) already mapped\n",
+					i, (void *) (start_addr +
+						     (i*chunk_sizes[j])));
+				goto fail_free;
+			}
+			list_add_tail(&cont_phys_chunk[i].allocated,
+				      &head->allocated);
+			cont_phys_chunk[i].size_idx = j;
+
+			len -= chunk_sizes[j];
+			i += chunk_sizes[j]/SZ_4K;
+		}
+	}
+
+	if (len % SZ_4K) {
+		if (!list_empty(&cont_phys_chunk[i].allocated)) {
+			vcm_err("chunk %i (addr %p) already mapped\n",
+				i, (void *) (start_addr + (i*SZ_4K)));
+			goto fail_free;
+		}
+		len -= SZ_4K;
+		list_add_tail(&cont_phys_chunk[i].allocated,
+			      &head->allocated);
+
+		i++;
+	}
+
+	return i;
+
+fail_free:
+	{
+		struct phys_chunk *chunk, *tmp;
+		/* just remove from list, if we're double alloc'ing
+		   we don't want to stamp on the other guy */
+		list_for_each_entry_safe(chunk, tmp, &head->allocated,
+					 allocated) {
+			list_del(&chunk->allocated);
+		}
+	}
+fail:
+	return 0;
+}
+
+struct physmem *vcm_phys_alloc(enum memtype_t memtype, size_t len,
+			       u32 attr)
+{
+	unsigned long flags;
+	int ret;
+	struct physmem *physmem = NULL;
+	int blocks_allocated;
+
+	spin_lock_irqsave(&vcmlock, flags);
+
+	physmem = kzalloc(sizeof(*physmem), GFP_KERNEL);
+	if (!physmem) {
+		vcm_err("physmem is NULL\n");
+		goto fail;
+	}
+
+	physmem->memtype = memtype;
+	physmem->len = len;
+	physmem->attr = attr;
+
+	INIT_LIST_HEAD(&physmem->alloc_head.allocated);
+
+	if (attr & VCM_PHYS_CONT) {
+		if (!cont_vcm) {
+			vcm_err("cont_vcm is NULL\n");
+			goto fail2;
+		}
+
+		physmem->is_cont = 1;
+
+		/* TODO: get attributes */
+		physmem->res = __vcm_reserve(cont_vcm, len, 0);
+		if (physmem->res == 0) {
+			vcm_err("contiguous space allocation failed\n");
+			goto fail2;
+		}
+
+		/* if we're here we know we have memory, create
+		   the shadow physmem links*/
+		blocks_allocated =
+			vcm_alloc_max_munch_cont(
+				physmem->res->dev_addr,
+				len,
+				&physmem->alloc_head);
+
+		if (blocks_allocated == 0) {
+			vcm_err("shadow physmem allocation failed\n");
+			goto fail3;
+		}
+	} else {
+		blocks_allocated = vcm_alloc_max_munch(len,
+						       &physmem->alloc_head);
+		if (blocks_allocated == 0) {
+			vcm_err("physical allocation failed:"
+				" vcm_alloc_max_munch(%i, %p) ret 0\n",
+				len, &physmem->alloc_head);
+			goto fail2;
+		}
+	}
+
+	spin_unlock_irqrestore(&vcmlock, flags);
+	return physmem;
+
+fail3:
+	ret = __vcm_unreserve(physmem->res);
+	if (ret != 0) {
+		vcm_err("vcm_unreserve(%p) ret %i during cleanup",
+			(void *) physmem->res, ret);
+		spin_unlock_irqrestore(&vcmlock, flags);
+		return 0;
+	}
+fail2:
+	kfree(physmem);
+fail:
+	spin_unlock_irqrestore(&vcmlock, flags);
+	return 0;
+}
+
+
+int vcm_phys_free(struct physmem *physmem)
+{
+	unsigned long flags;
+	int ret;
+
+	spin_lock_irqsave(&vcmlock, flags);
+
+	if (!physmem) {
+		vcm_err("physmem is NULL\n");
+		goto fail;
+	}
+
+	if (physmem->is_cont) {
+		if (physmem->res == 0) {
+			vcm_err("contiguous reservation is NULL\n");
+			goto fail;
+		}
+
+		ret = vcm_free_max_munch_cont(&physmem->alloc_head);
+		if (ret != 0) {
+			vcm_err("failed to free physical blocks:"
+				" vcm_free_max_munch_cont(%p) ret %i\n",
+				(void *) &physmem->alloc_head, ret);
+			goto fail;
+		}
+
+		ret = __vcm_unreserve(physmem->res);
+		if (ret != 0) {
+			vcm_err("failed to free virtual blocks:"
+				" vcm_unreserve(%p) ret %i\n",
+				(void *) physmem->res, ret);
+			goto fail;
+		}
+
+	} else {
+
+		ret = vcm_alloc_free_blocks(&physmem->alloc_head);
+		if (ret != 0) {
+			vcm_err("failed to free physical blocks:"
+				" vcm_alloc_free_blocks(%p) ret %i\n",
+				(void *) &physmem->alloc_head, ret);
+			goto fail;
+		}
+	}
+
+	memset(physmem, 0, sizeof(*physmem));
+
+	kfree(physmem);
+
+	spin_unlock_irqrestore(&vcmlock, flags);
+	return 0;
+
+fail:
+	spin_unlock_irqrestore(&vcmlock, flags);
+	return -EINVAL;
+}
+
+
+struct avcm *vcm_assoc(struct vcm *vcm, struct device *dev, u32 attr)
+{
+	unsigned long flags;
+	struct avcm *avcm = NULL;
+
+	spin_lock_irqsave(&vcmlock, flags);
+
+	if (!vcm) {
+		vcm_err("vcm is NULL\n");
+		goto fail;
+	}
+
+	if (!dev) {
+		vcm_err("dev is NULL\n");
+		goto fail;
+	}
+
+	if (vcm->type == VCM_EXT_KERNEL && !list_empty(&vcm->assoc_head)) {
+		vcm_err("only one device may be assocoated with a"
+			" VCM_EXT_KERNEL\n");
+		goto fail;
+	}
+
+	avcm = kzalloc(sizeof(*avcm), GFP_KERNEL);
+	if (!avcm) {
+		vcm_err("kzalloc(%i, GFP_KERNEL) ret NULL\n", sizeof(*avcm));
+		goto fail;
+	}
+
+	avcm->dev = dev;
+
+	avcm->vcm = vcm;
+	avcm->attr = attr;
+	avcm->is_active = 0;
+
+	INIT_LIST_HEAD(&avcm->assoc_elm);
+	list_add(&avcm->assoc_elm, &vcm->assoc_head);
+
+	spin_unlock_irqrestore(&vcmlock, flags);
+	return avcm;
+
+fail:
+	spin_unlock_irqrestore(&vcmlock, flags);
+	return 0;
+}
+
+
+int vcm_deassoc(struct avcm *avcm)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&vcmlock, flags);
+
+	if (!avcm) {
+		vcm_err("avcm is NULL\n");
+		goto fail;
+	}
+
+	if (list_empty(&avcm->assoc_elm)) {
+		vcm_err("nothing to deassociate\n");
+		goto fail;
+	}
+
+	if (avcm->is_active) {
+		vcm_err("association still activated\n");
+		goto fail_busy;
+	}
+
+	list_del(&avcm->assoc_elm);
+
+	memset(avcm, 0, sizeof(*avcm));
+
+	kfree(avcm);
+	spin_unlock_irqrestore(&vcmlock, flags);
+	return 0;
+fail_busy:
+	spin_unlock_irqrestore(&vcmlock, flags);
+	return -EBUSY;
+fail:
+	spin_unlock_irqrestore(&vcmlock, flags);
+	return -EINVAL;
+}
+
+
+int vcm_set_assoc_attr(struct avcm *avcm, u32 attr)
+{
+	return 0;
+}
+
+
+int vcm_activate(struct avcm *avcm)
+{
+	unsigned long flags;
+	struct vcm *vcm;
+
+	spin_lock_irqsave(&vcmlock, flags);
+
+	if (!avcm) {
+		vcm_err("avcm is NULL\n");
+		goto fail;
+	}
+
+	vcm = avcm->vcm;
+	if (!vcm) {
+		vcm_err("NULL vcm\n");
+		goto fail;
+	}
+
+	if (!avcm->dev) {
+		vcm_err("cannot activate without a device\n");
+		goto fail_nodev;
+	}
+
+	if (avcm->is_active) {
+		vcm_err("double activate\n");
+		goto fail_busy;
+	}
+
+	if (vcm->type == VCM_DEVICE) {
+#ifdef CONFIG_SMMU
+		int ret = smmu_is_active((struct smmu_dev *) avcm->dev);
+		if (ret == -1) {
+			vcm_err("smmu_is_active(%p) ret -1\n",
+				(void *) avcm->dev);
+			goto fail_dev;
+		}
+
+		if (ret == 1) {
+			vcm_err("SMMU is already active\n");
+			goto fail_busy;
+		}
+
+		/* TODO, pmem check */
+		ret = smmu_activate((struct smmu_dev *) avcm->dev);
+		if (ret != 0) {
+			vcm_err("smmu_activate(%p) ret %i"
+				" SMMU failed to activate\n",
+				(void *) avcm->dev, ret);
+			goto fail_dev;
+		}
+#else
+		vcm_err("No SMMU support - cannot activate/deactivate\n");
+		goto fail_nodev;
+#endif
+	}
+
+	avcm->is_active = 1;
+	spin_unlock_irqrestore(&vcmlock, flags);
+	return 0;
+
+#ifdef CONFIG_SMMU
+fail_dev:
+	spin_unlock_irqrestore(&vcmlock, flags);
+	return -1;
+#endif
+fail_busy:
+	spin_unlock_irqrestore(&vcmlock, flags);
+	return -EBUSY;
+fail_nodev:
+	spin_unlock_irqrestore(&vcmlock, flags);
+	return -ENODEV;
+fail:
+	spin_unlock_irqrestore(&vcmlock, flags);
+	return -EINVAL;
+}
+
+
+int vcm_deactivate(struct avcm *avcm)
+{
+	unsigned long flags;
+	struct vcm *vcm;
+
+	spin_lock_irqsave(&vcmlock, flags);
+
+	if (!avcm)
+		goto fail;
+
+	vcm = avcm->vcm;
+	if (!vcm) {
+		vcm_err("NULL vcm\n");
+		goto fail;
+	}
+
+	if (!avcm->dev) {
+		vcm_err("cannot deactivate without a device\n");
+		goto fail;
+	}
+
+	if (!avcm->is_active) {
+		vcm_err("double deactivate\n");
+		goto fail_nobusy;
+	}
+
+	if (vcm->type == VCM_DEVICE) {
+#ifdef CONFIG_SMMU
+		int ret = smmu_is_active((struct smmu_dev *) avcm->dev);
+		if (ret == -1) {
+			vcm_err("smmu_is_active(%p) ret %i\n",
+				(void *) avcm->dev, ret);
+			goto fail_dev;
+		}
+
+		if (ret == 0) {
+			vcm_err("double SMMU deactivation\n");
+			goto fail_nobusy;
+		}
+
+		/* TODO, pmem check */
+		ret = smmu_deactivate((struct smmu_dev *) avcm->dev);
+		if (ret != 0) {
+			vcm_err("smmu_deactivate(%p) ret %i\n",
+				(void *) avcm->dev, ret);
+			goto fail_dev;
+		}
+#else
+		vcm_err("No SMMU support - cannot activate/deactivate\n");
+		goto fail;
+#endif
+	}
+
+	avcm->is_active = 0;
+	spin_unlock_irqrestore(&vcmlock, flags);
+	return 0;
+#ifdef CONFIG_SMMU
+fail_dev:
+	spin_unlock_irqrestore(&vcmlock, flags);
+	return -1;
+#endif
+fail_nobusy:
+	spin_unlock_irqrestore(&vcmlock, flags);
+	return -ENOENT;
+fail:
+	spin_unlock_irqrestore(&vcmlock, flags);
+	return -EINVAL;
+}
+
+struct bound *vcm_create_bound(struct vcm *vcm, size_t len)
+{
+	return 0;
+}
+
+
+int vcm_free_bound(struct bound *bound)
+{
+	return -1;
+}
+
+
+struct res *vcm_reserve_from_bound(struct bound *bound, size_t len,
+				   u32 attr)
+{
+	return 0;
+}
+
+
+size_t vcm_get_bound_start_addr(struct bound *bound)
+{
+	return 0;
+}
+
+
+size_t vcm_get_bound_len(struct bound *bound)
+{
+	return 0;
+}
+
+
+struct physmem *vcm_map_phys_addr(size_t phys, size_t len)
+{
+	return 0;
+}
+
+
+size_t vcm_get_next_phys_addr(struct physmem *physmem, size_t phys, size_t *len)
+{
+	return 0;
+}
+
+struct res *vcm_get_res(unsigned long dev_addr, struct vcm *vcm)
+{
+	return 0;
+}
+
+
+size_t vcm_translate(size_t src_dev, struct vcm *src_vcm, struct vcm *dst_vcm)
+{
+	return 0;
+}
+
+
+size_t vcm_get_phys_num_res(size_t phys)
+{
+	return 0;
+}
+
+
+struct res *vcm_get_next_phys_res(size_t phys, struct res *res, size_t *len)
+{
+	return 0;
+}
+
+
+size_t vcm_get_pgtbl_pa(struct vcm *vcm)
+{
+	return 0;
+}
+
+
+/* No lock needed, smmu_translate has its own lock */
+size_t vcm_dev_addr_to_phys_addr(struct device *dev, unsigned long dev_addr)
+{
+#ifdef CONFIG_SMMU
+	int ret;
+	ret = smmu_translate((struct smmu_dev *) dev, dev_addr);
+	if (ret == -1)
+		vcm_err("smmu_translate(%p, %p) ret %i\n",
+			(void *) dev, (void *) dev_addr, ret);
+
+	return ret;
+#else
+	vcm_err("No support for SMMU - manual translation not supported\n");
+	return -1;
+#endif
+}
+
+
+/* No lock needed, bootmem_cont never changes after  */
+size_t vcm_get_cont_memtype_pa(enum memtype_t memtype)
+{
+	if (memtype != VCM_MEMTYPE_0) {
+		vcm_err("memtype != VCM_MEMTYPE_0\n");
+		goto fail;
+	}
+
+	if (!bootmem_cont) {
+		vcm_err("bootmem_cont 0\n");
+		goto fail;
+	}
+
+	return (size_t) __pa(bootmem_cont);
+fail:
+	return 0;
+}
+
+
+/* No lock needed, constant */
+size_t vcm_get_cont_memtype_len(enum memtype_t memtype)
+{
+	if (memtype != VCM_MEMTYPE_0) {
+		vcm_err("memtype != VCM_MEMTYPE_0\n");
+		return 0;
+	}
+
+	return CONT_SZ;
+}
+
+int vcm_hook(struct device *dev, vcm_handler handler, void *data)
+{
+#ifdef CONFIG_SMMU
+	int ret;
+
+	ret = smmu_hook_irpt((struct smmu_dev *) dev, handler, data);
+	if (ret != 0)
+		vcm_err("smmu_hook_irpt(%p, %p, %p) ret %i\n", (void *) dev,
+			(void *) handler, (void *) data, ret);
+
+	return ret;
+#else
+	vcm_err("No support for SMMU - interrupts not supported\n");
+	return -1;
+#endif
+}
+
+
+size_t vcm_hw_ver(struct device *dev)
+{
+	return 0;
+}
+
+
+static int vcm_cont_phys_chunk_init(void)
+{
+	int i;
+	int cont_pa;
+
+	if (!cont_phys_chunk) {
+		vcm_err("cont_phys_chunk 0\n");
+		goto fail;
+	}
+
+	if (!bootmem_cont) {
+		vcm_err("bootmem_cont 0\n");
+		goto fail;
+	}
+
+	cont_pa = (int) __pa(bootmem_cont);
+
+	for (i = 0; i < CONT_SZ/PAGE_SIZE; ++i) {
+		cont_phys_chunk[i].pa = (int) cont_pa; cont_pa += PAGE_SIZE;
+		cont_phys_chunk[i].size_idx = IDX_4K;
+		INIT_LIST_HEAD(&cont_phys_chunk[i].allocated);
+	}
+
+	return 0;
+
+fail:
+	return -1;
+}
+
+
+int vcm_sys_init(void)
+{
+	int ret;
+	printk(KERN_INFO "VCM Initialization\n");
+	if (!bootmem) {
+		vcm_err("bootmem is 0\n");
+		ret = -1;
+		goto fail;
+	}
+
+	if (!bootmem_cont) {
+		vcm_err("bootmem_cont is 0\n");
+		ret = -1;
+		goto fail;
+	}
+
+	ret = vcm_setup_tex_classes();
+	if (ret != 0) {
+		printk(KERN_INFO "Could not determine TEX attribute mapping\n");
+		ret = -1;
+		goto fail;
+	}
+
+
+	ret = vcm_alloc_init(__pa(bootmem));
+	if (ret != 0) {
+		vcm_err("vcm_alloc_init(%p) ret %i\n", (void *) __pa(bootmem),
+			ret);
+		ret = -1;
+		goto fail;
+	}
+
+	cont_phys_chunk = kzalloc(sizeof(*cont_phys_chunk)*(CONT_SZ/PAGE_SIZE),
+				  GFP_KERNEL);
+	if (!cont_phys_chunk) {
+		vcm_err("kzalloc(%lu, GFP_KERNEL) ret 0",
+			sizeof(*cont_phys_chunk)*(CONT_SZ/PAGE_SIZE));
+		goto fail_free;
+	}
+
+	/* the address and size will hit our special case unless we
+	   pass an override */
+	cont_vcm = vcm_create_flagged(0, __pa(bootmem_cont), CONT_SZ);
+	if (cont_vcm == 0) {
+		vcm_err("vcm_create_flagged(0, %p, %i) ret 0\n",
+			(void *) __pa(bootmem_cont), CONT_SZ);
+		ret = -1;
+		goto fail_free2;
+	}
+
+	ret = vcm_cont_phys_chunk_init();
+	if (ret != 0) {
+		vcm_err("vcm_cont_phys_chunk_init() ret %i\n", ret);
+		goto fail_free3;
+	}
+
+	printk(KERN_INFO "VCM Initialization OK\n");
+	return 0;
+
+fail_free3:
+	ret = __vcm_free(cont_vcm);
+	if (ret != 0) {
+		vcm_err("vcm_free(%p) ret %i during failure path\n",
+			(void *) cont_vcm, ret);
+		return -1;
+	}
+
+fail_free2:
+	kfree(cont_phys_chunk);
+	cont_phys_chunk = 0;
+
+fail_free:
+	ret = vcm_alloc_destroy();
+	if (ret != 0)
+		vcm_err("vcm_alloc_destroy() ret %i during failure path\n",
+			ret);
+
+	ret = -1;
+fail:
+	return ret;
+}
+
+
+int vcm_sys_destroy(void)
+{
+	int ret = 0;
+
+	if (!cont_phys_chunk) {
+		vcm_err("cont_phys_chunk is 0\n");
+		return -1;
+	}
+
+	if (!cont_vcm) {
+		vcm_err("cont_vcm is 0\n");
+		return -1;
+	}
+
+	ret = __vcm_free(cont_vcm);
+	if (ret != 0) {
+		vcm_err("vcm_free(%p) ret %i\n", (void *) cont_vcm, ret);
+		return -1;
+	}
+
+	cont_vcm = 0;
+
+	kfree(cont_phys_chunk);
+	cont_phys_chunk = 0;
+
+	ret = vcm_alloc_destroy();
+	if (ret != 0) {
+		vcm_err("vcm_alloc_destroy() ret %i\n", ret);
+		return -1;
+	}
+
+	return ret;
+}
+
+int vcm_init(void)
+{
+	int ret;
+
+	bootmem = __alloc_bootmem(BOOTMEM_SZ, BOOTMEM_ALIGN, 0);
+	if (!bootmem) {
+		vcm_err("segregated block pool alloc failed:"
+			" __alloc_bootmem(%i, %i, 0)\n",
+			BOOTMEM_SZ, BOOTMEM_ALIGN);
+		goto fail;
+	}
+
+	bootmem_cont = __alloc_bootmem(CONT_SZ, CONT_ALIGN, 0);
+	if (!bootmem_cont) {
+		vcm_err("contiguous pool alloc failed:"
+			" __alloc_bootmem(%i, %i, 0)\n",
+			CONT_SZ, CONT_ALIGN);
+		goto fail_free;
+	}
+
+	ret = vcm_sys_init();
+	if (ret != 0) {
+		vcm_err("vcm_sys_init() ret %i\n", ret);
+		goto fail_free2;
+	}
+
+	return 0;
+
+fail_free2:
+	free_bootmem(__pa(bootmem_cont), CONT_SZ);
+fail_free:
+	free_bootmem(__pa(bootmem), BOOTMEM_SZ);
+fail:
+	return -1;
+};
+
+/* Useful for testing, and if VCM is ever unloaded */
+void vcm_exit(void)
+{
+	int ret;
+
+	if (!bootmem_cont) {
+		vcm_err("bootmem_cont is 0\n");
+		goto fail;
+	}
+
+	if (!bootmem) {
+		vcm_err("bootmem is 0\n");
+		goto fail;
+	}
+
+	ret = vcm_sys_destroy();
+	if (ret != 0) {
+		vcm_err("vcm_sys_destroy() ret %i\n", ret);
+		goto fail;
+	}
+
+	free_bootmem(__pa(bootmem_cont), CONT_SZ);
+	free_bootmem(__pa(bootmem), BOOTMEM_SZ);
+fail:
+	return;
+}
+early_initcall(vcm_init);
+module_exit(vcm_exit);
+
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Zach Pfeffer <zpfeffer@codeaurora.org>");
diff --git a/include/linux/vcm.h b/include/linux/vcm.h
new file mode 100644
index 0000000..b95dab5
--- /dev/null
+++ b/include/linux/vcm.h
@@ -0,0 +1,661 @@
+/* Copyright (c) 2010, Code Aurora Forum. All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are
+ * met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above
+ *       copyright notice, this list of conditions and the following
+ *       disclaimer in the documentation and/or other materials provided
+ *       with the distribution.
+ *     * Neither the name of Code Aurora Forum, Inc. nor the names of its
+ *       contributors may be used to endorse or promote products derived
+ *       from this software without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
+ * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT
+ * ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
+ * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
+ * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
+ * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
+ * IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ */
+
+
+#ifndef _VCM_H_
+#define _VCM_H_
+
+
+/* All undefined types must be defined using platform specific headers */
+
+#include <linux/vcm_types.h>
+
+
+/*
+ * Virtual contiguous memory (VCM) region primitives.
+ *
+ * Current memory mapping software uses a CPU centric management
+ * model. This makes sense in general, average hardware only contains an
+ * CPU MMU and possibly a graphics MMU. If every device in the system
+ * has one or more MMUs a CPU centric MM programming model breaks down.
+ *
+ * Looking at mapping from a system-wide perspective reveals a general
+ * graph problem. Each node that talks to memory, either through an MMU
+ * or directly (via physical memory) can be thought of as the device end
+ * of a mapping edge. The other edge is the physical memory that is
+ * mapped.
+ *
+ * In the direct mapped case, it is useful to give the device an
+ * MMU. This one-to-one MMU allows direct mapped devices to
+ * participate in graph management, they simply see memory through a
+ * one-to-one mapping.
+ *
+ * The CPU nodes can also be brought under the same mapping
+ * abstraction with the use of a light overlay on the existing
+ * VMM. This light overlay brings the VMM's page table abstraction for
+ * each process and the kernel into the graph management API.
+ *
+ * Taken together this system wide approach provides a capability that
+ * is greater than the sum of its parts by allowing users to reason
+ * about system wide mapping issues without getting bogged down in CPU
+ * centric device page table management issues.
+ */
+
+
+/*
+ * Creating, freeing and managing VCMs.
+ *
+ * A VCM region is a virtual space that can be reserved from and
+ * associated with one or more devices. At creation the user can
+ * specify an offset to start addresses and a length of the entire VCM
+ * region. Reservations out of a VCM region are always contiguous.
+ */
+
+
+/**
+ * vcm_create() - Create a VCM region
+ * @start_addr:		The starting address of the VCM region.
+ * @len:        	The len of the VCM region. This must be at least
+ *			vcm_get_min_page_size() bytes.
+ *
+ * A VCM typically abstracts a page table.
+ *
+ * All functions in this API are passed and return opaque things
+ * because the underlying implementations will vary. The goal
+ * is really graph management. vcm_create() creates the "device end"
+ * of an edge in the mapping graph.
+ *
+ * The return value is non-zero if a VCM has successfully been
+ * created. It will return zero if a VCM region cannot be created or
+ * len is invalid.
+ */
+struct vcm *vcm_create(unsigned long start_addr, size_t len);
+
+
+/**
+ * vcm_create_from_prebuilt() - Create a VCM region from an existing region
+ * @ext_vcm_id: 	An external opaque value that allows the
+ *	        	implementation to reference an already built table.
+ *
+ * The ext_vcm_id will probably reference a page table that's been built
+ * by the VM.
+ *
+ * The platform specific implementation will provide this.
+ *
+ * The return value is non-zero if a VCM has successfully been created.
+ */
+struct vcm *vcm_create_from_prebuilt(size_t ext_vcm_id);
+
+
+/**
+ * vcm_clone() - Clone a VCM
+ * @vcm:		A VCM to clone from.
+ *
+ * Perform a VCM "deep copy." The resulting VCM will match the original at
+ * the point of cloning. Subsequent updates to either VCM will only be
+ * seen by that VCM.
+ *
+ * The return value is non-zero if a VCM has been successfully cloned.
+ */
+struct vcm *vcm_clone(struct vcm *vcm);
+
+
+/**
+ * vcm_get_start_addr() - Get the starting address of the VCM region.
+ * @vcm:		The VCM we're interested in getting the starting
+ * 			address of.
+ *
+ * The return value will be 1 if an error has occurred.
+ */
+size_t vcm_get_start_addr(struct vcm *vcm);
+
+
+/**
+ * vcm_get_len() - Get the length of the VCM region.
+ * @vcm:		The VCM we're interested in reading the length from.
+ *
+ * The return value will be non-zero for a valid VCM. VCM regions
+ * cannot have 0 len.
+ */
+size_t vcm_get_len(struct vcm *vcm);
+
+
+/**
+ * vcm_free() - Free a VCM.
+ * @vcm:		The VCM we're interested in freeing.
+ *
+ * The return value is 0 if the VCM has been freed or:
+ * -EBUSY		The VCM region contains reservations or has been
+ * 			associated (active or not) and cannot be freed.
+ * -EINVAL		The vcm argument is invalid.
+ */
+int vcm_free(struct vcm *vcm);
+
+
+/*
+ * Creating, freeing and managing reservations out of a VCM.
+ *
+ */
+
+/**
+ * vcm_reserve() - Create a reservation from a VCM region.
+ * @vcm:		The VCM region to reserve from.
+ * @len:   		The length of the reservation. Must be at least
+ * 			vcm_get_min_page_size() bytes.
+ * @attr:		See 'Reservation Attributes'.
+ *
+ * A reservation, res_t, is a contiguous range from a VCM region.
+ *
+ * The return value is non-zero if a reservation has been successfully
+ * created. It is 0 if any of the parameters are invalid.
+ */
+struct res *vcm_reserve(struct vcm *vcm, size_t len, u32 attr);
+
+
+/**
+ * vcm_reserve_at() - Make a reservation at a given logical location.
+ * @memtarget:		A logical location to start the reservation from.
+ * @vcm:		The VCM region to start the reservation from.
+ * @len:		The length of the reservation.
+ * @attr:		See 'Reservation Attributes'.
+ *
+ * The return value is non-zero if a reservation has been successfully
+ * created.
+ */
+struct res *vcm_reserve_at(enum memtarget_t memtarget, struct vcm *vcm,
+			   size_t len, u32 attr);
+
+
+/**
+ * vcm_get_vcm_from_res() - Return the VCM region of a reservation.
+ * @res:		The reservation to return the VCM region of.
+ *
+ * Te return value will be non-zero if the reservation is valid. A valid
+ * reservation is always associated with a VCM region; there is no such
+ * thing as an orphan reservation.
+ */
+struct vcm *vcm_get_vcm_from_res(struct res *res);
+
+
+/**
+ * vcm_unreserve() - Unreserve the reservation.
+ * @res: 		The reservation to unreserve.
+ *
+ * The return value will be 0 if the reservation was successfully
+ * unreserved and:
+ * -EBUSY		The reservation is still backed,
+ * -EINVAL		The vcm argument is invalid.
+ */
+int vcm_unreserve(struct res *res);
+
+
+/**
+ * vcm_set_res_attr() - Set attributes of an existing reservation.
+ * @res:		An existing reservation of interest.
+ * @attr:		See 'Reservation Attributes'.
+ *
+ * This function can only be used on an existing reservation; there
+ * are no orphan reservations. All attributes can be set on a existing
+ * reservation.
+ *
+ * The return value will be 0 for a success, otherwise it will be:
+ * -EINVAL		res or attr are invalid.
+ */
+int vcm_set_res_attr(struct res *res, u32 attr);
+
+
+/**
+ * vcm_get_num_res() - Return the number of reservations in a VCM region.
+ * @vcm:		The VCM region of interest.
+ */
+size_t vcm_get_num_res(struct vcm *vcm);
+
+
+/**
+ * vcm_get_next_res() - Read each reservation one at a time.
+ * @vcm:		The VCM region of interest.
+ * @res:		Contains the last reservation. Pass NULL on the
+ * 			first call.
+ *
+ * This function works like a foreach reservation in a VCM region.
+ *
+ * The return value will be non-zero for each reservation in a VCM. A
+ * zero indicates no further reservations.
+ */
+struct res *vcm_get_next_res(struct vcm *vcm, struct res *res);
+
+
+/**
+ * vcm_res_copy() - Copy len bytes from one reservation to another.
+ * @to:         	The reservation to copy to.
+ * @from:       	The reservation to copy from.
+ * @len:                The length of bytes to copy.
+ *
+ * The return value is the number of bytes copied.
+ */
+size_t vcm_res_copy(struct res *to, size_t to_off, struct res *from, size_t
+                   from_off, size_t len);
+
+
+/**
+ * vcm_get_min_page_size() - Return the minimum page size supported by
+ * 			     the architecture.
+ */
+size_t vcm_get_min_page_size(void);
+
+
+/**
+ * vcm_back() - Physically back a reservation.
+ * @res:		The reservation containing the virtual contiguous
+ * 			region to back.
+ * @physmem:		The physical memory that will back the virtual
+ * 			contiguous memory region.
+ *
+ * One VCM can be associated with multiple devices. When you vcm_back()
+ * each association must be active. This is not strictly necessary. It may
+ * be changed in the future.
+ *
+ * This function returns 0 on a successful physical backing. Otherwise
+ * it returns:
+ * -EINVAL		res or physmem is invalid or res's len
+ *			is different from physmem's len.
+ * -EAGAIN		Try again, one of the devices hasn't been activated.
+ */
+int vcm_back(struct res *res, struct physmem *physmem);
+
+
+/**
+ * vcm_unback() - Unback a reservation.
+ * @res:		The reservation to unback.
+ *
+ * One VCM can be associated with multiple devices. When you vcm_unback()
+ * each association must be active.
+ *
+ * This function returns 0 on a successful unbacking. Otherwise
+ * it returns:
+ * -EINVAL		res is invalid.
+ * -EAGAIN		Try again, one of the devices hasn't been activated.
+ */
+int vcm_unback(struct res *res);
+
+
+/**
+ * vcm_phys_alloc() - Allocate physical memory for the VCM region.
+ * @memtype:		The memory type to allocate.
+ * @len:		The length of the allocation.
+ * @attr:		See 'Physical Allocation Attributes'.
+ *
+ * This function will allocate chunks of memory according to the attr
+ * it is passed.
+ *
+ * The return value is non-zero if physical memory has been
+ * successfully allocated.
+ */
+struct physmem *vcm_phys_alloc(enum memtype_t memtype, size_t len,
+			       u32 attr);
+
+
+/**
+ * vcm_phys_free() - Free a physical allocation.
+ * @physmem:		The physical allocation to free.
+ *
+ * The return value is 0 if the physical allocation has been freed or:
+ * -EBUSY		Their are reservation mapping the physical memory.
+ * -EINVAL		The physmem argument is invalid.
+ */
+int vcm_phys_free(struct physmem *physmem);
+
+
+/**
+ * vcm_get_physmem_from_res() - Return a reservation's physmem
+ * @res:		An existing reservation of interest.
+ *
+ * The return value will be non-zero on success, otherwise it will be:
+ * -EINVAL		res is invalid
+ * -ENOMEM		res is unbacked
+ */
+struct physmem *vcm_get_physmem_from_res(struct res *res);
+
+
+/**
+ * vcm_get_memtype_of_physalloc() - Return the memtype of a reservation.
+ * @physmem:		The physical allocation of interest.
+ *
+ * This function returns the memtype of a reservation or VCM_INVALID
+ * if res is invalid.
+ */
+enum memtype_t vcm_get_memtype_of_physalloc(struct physmem *physmem);
+
+
+/*
+ * Associate a VCM with a device, activate that association and remove it.
+ *
+ */
+
+/**
+ * vcm_assoc() - Associate a VCM with a device.
+ * @vcm:		The VCM region of interest.
+ * @dev:		The device to associate the VCM with.
+ * @attr:		See 'Association Attributes'.
+ *
+ * This function returns non-zero if a association is made. It returns 0
+ * if any of its parameters are invalid or VCM_ATTR_VALID is not present.
+ */
+struct avcm *vcm_assoc(struct vcm *vcm, struct device *dev, u32 attr);
+
+
+/**
+ * vcm_deassoc() - Deassociate a VCM from a device.
+ * @avcm:		The association we want to break.
+ *
+ * The function returns 0 on success or:
+ * -EBUSY		The association is currently activated.
+ * -EINVAL		The avcm parameter is invalid.
+ */
+int vcm_deassoc(struct avcm *avcm);
+
+
+/**
+ * vcm_set_assoc_attr() - Set an AVCM's attributes.
+ * @avcm:		The AVCM of interest.
+ * @attr:		The new attr. See 'Association Attributes'.
+ *
+ * Every attribute can be set at runtime if an association isn't activated.
+ *
+ * This function returns 0 on success or:
+ * -EBUSY		The association is currently activated.
+ * -EINVAL		The avcm parameter is invalid.
+ */
+int vcm_set_assoc_attr(struct avcm *avcm, u32 attr);
+
+
+/**
+ * vcm_get_assoc_attr() - Return an AVCM's attributes.
+ * @avcm:		The AVCM of interest.
+ *
+ * This function returns 0 on error.
+ */
+u32 vcm_get_assoc_attr(struct avcm *avcm);
+
+
+/**
+ * vcm_activate() - Activate an AVCM.
+ * @avcm:		The AVCM to activate.
+ *
+ * You have to deactivate, before you activate.
+ *
+ * This function returns 0 on success or:
+ * -EINVAL   		avcm is invalid
+ * -ENODEV		no device
+ * -EBUSY		device is already active
+ * -1			hardware failure
+ */
+int vcm_activate(struct avcm *avcm);
+
+
+/**
+ * vcm_deactivate() - Deactivate an association.
+ * @avcm:		The AVCM to deactivate.
+ *
+ * This function returns 0 on success or:
+ * -ENOENT     		avcm is not activate
+ * -EINVAL		avcm is invalid
+ * -1			Hardware failure
+ */
+int vcm_deactivate(struct avcm *avcm);
+
+
+/**
+ * vcm_is_active() - Query if an AVCM is active.
+ * @avcm:    	The AVCM of interest.
+ *
+ * returns 0 for not active, 1 for active or -EINVAL for error.
+ *
+ */
+int vcm_is_active(struct avcm *avcm);
+
+
+/*
+ * Create, manage and remove a boundary in a VCM.
+ */
+
+/**
+ * vcm_create_bound() - Create a bound in a VCM.
+ * @vcm:     	The VCM that needs a bound.
+ * @len:                The len of the bound.
+ *
+ * The allocator picks the virtual addresses of the bound.
+ *
+ * This function returns non-zero if a bound was created.
+ */
+struct bound *vcm_create_bound(struct vcm *vcm, size_t len);
+
+
+/**
+ * vcm_free_bound() - Free a bound.
+ * @bound:   	The bound to remove.
+ *
+ * This function returns 0 if bound has been removed or:
+ * -EBUSY      		The bound contains reservations and cannot be]
+ * 			removed.
+ * -EINVAL     		The bound is invalid.
+ */
+int vcm_free_bound(struct bound *bound);
+
+
+/**
+ * vcm_reserve_from_bound() - Make a reservation from a bounded area.
+ * @bound:   	The bound to reserve from.
+ * @len:                The len of the reservation.
+ * @attr:       	See 'Reservation Attributes'.
+ *
+ * The return value is non-zero on success. It is 0 if any parameter
+ * is invalid.
+ */
+struct res *vcm_reserve_from_bound(struct bound *bound, size_t len,
+                                  u32 attr);
+
+
+/**
+ * vcm_get_bound_start_addr() - Return the starting device address of the bound
+ * @bound:   	The bound of interest.
+ *
+ * On success this function returns the starting addres of the bound. On error
+ * it returns:
+ * 1   			bound is invalid.
+ */
+size_t vcm_get_bound_start_addr(struct bound *bound);
+
+
+/*
+ * Perform low-level control over VCM regions and reservations.
+ */
+
+/**
+ * vcm_map_phys_addr() - Produce a physmem from a contiguous
+ *                       physical address
+ *
+ * @phys:		The physical address of the contiguous range.
+ * @len:		The len of the contiguous address range.
+ *
+ * Returns non-zero on success, 0 on failure.
+ */
+struct physmem *vcm_map_phys_addr(phys_addr_t phys, size_t len);
+
+
+/**
+ * vcm_get_next_phys_addr() - Get the next physical addr and len of a
+ * 			      physmem.
+ * @res:		The physmem of interest.
+ * @phys:		The current physical address. Set this to NULL to
+ * 			start the iteration.
+ * @len:		An output: the len of the next physical segment.
+ *
+ * physmem's may contain physically discontiguous sections. This
+ * function returns the next physical address and len. Pass NULL to
+ * phys to get the first physical address. The len of the physical
+ * segment is returned in *len.
+ *
+ * Returns 0 if there is no next physical address.
+ */
+size_t vcm_get_next_phys_addr(struct physmem *physmem, phys_addr_t phys,
+			      size_t *len);
+
+
+/**
+ * vcm_get_res() - Return the reservation from a device address and a VCM
+ * @dev_addr:		The device address of interest.
+ * @vcm:		The VCM that contains the reservation
+ *
+ * This function returns 0 if there is no reservation whose device
+ * address is dev_addr.
+ */
+struct res *vcm_get_res(unsigned long dev_addr, struct vcm *vcm);
+
+
+/**
+ * vcm_translate() - Translate from one device address to another.
+ * @src_dev:		The source device address.
+ * @src_vcm:		The source VCM region.
+ * @dst_vcm:		The destination VCM region.
+ *
+ * Derive the device address from a VCM region that maps the same physical
+ * memory as a device address from another VCM region.
+ *
+ * On success this function returns the device address of a translation. On
+ * error it returns:
+ * 1			res is invalid.
+ */
+size_t vcm_translate(size_t src_dev, struct vcm *src_vcm,
+		     struct vcm *dst_vcm);
+
+
+/**
+ * vcm_get_phys_num_res() - Return the number of reservations mapping a
+ *           		    physical address.
+ * @phys:		The physical address to read.
+ */
+size_t vcm_get_phys_num_res(size_t phys);
+
+
+/**
+ * vcm_get_next_phys_res() - Return the next reservation mapped to a physical
+ *			     address.
+ * @phys:		The physical address to map.
+ * @res:		The starting reservation. Set this to NULL for the first
+ *			reservation.
+ * @len:		The virtual length of the reservation
+ *
+ * This function returns 0 for the last reservation or no reservation.
+ */
+struct res *vcm_get_next_phys_res(size_t phys, struct res *res, size_t *len);
+
+
+/**
+ * vcm_get_pgtbl_pa() - Return the physcial address of a VCM's page table.
+ * @vcm:	The VCM region of interest.
+ *
+ * This function returns non-zero on success.
+ */
+size_t vcm_get_pgtbl_pa(struct vcm *vcm);
+
+
+/**
+ * vcm_get_cont_memtype_pa() - Return the phys base addr of a memtype's
+ * 			       first contiguous region.
+ * @memtype:		The memtype of interest.
+ *
+ * This function returns non-zero on success. A zero return indicates that
+ * the given memtype does not have a contiguous region or that the memtype
+ * is invalid.
+ */
+size_t vcm_get_cont_memtype_pa(enum memtype_t memtype);
+
+
+/**
+ * vcm_get_cont_memtype_len() - Return the len of a memtype's
+ * 			       	first contiguous region.
+ * @memtype:		The memtype of interest.
+ *
+ * This function returns non-zero on success. A zero return indicates that
+ * the given memtype does not have a contiguous region or that the memtype
+ * is invalid.
+ */
+size_t vcm_get_cont_memtype_len(enum memtype_t memtype);
+
+
+/**
+ * vcm_dev_addr_to_phys_addr() - Perform a device address page-table lookup.
+ * @dev:		The device that has the table.
+ * @dev_addr:		The device address to map.
+ *
+ * This function returns the pa of a va from a device's page-table. It will
+ * fault if the dev_addr is not mapped.
+ */
+size_t vcm_dev_addr_to_phys_addr(struct device *dev, unsigned long dev_addr);
+
+
+/*
+ * Fault Hooks
+ *
+ * vcm_hook()
+ */
+
+/**
+ * vcm_hook() - Add a fault handler.
+ * @dev:		The device.
+ * @handler:		The handler.
+ * @data:		A private piece of data that will get passed to the
+ * 			handler.
+ *
+ * This function returns 0 for a successful registration or:
+ * -EINVAL		The arguments are invalid.
+ */
+int vcm_hook(struct device *dev, vcm_handler handler, void *data);
+
+
+/*
+ * Low level, platform agnostic, HW control.
+ *
+ * vcm_hw_ver()
+ */
+
+/**
+ * vcm_hw_ver() - Return the hardware version of a device, if it has one.
+ * @dev:		The device.
+ */
+size_t vcm_hw_ver(struct device *dev);
+
+
+/* bring-up init, destroy */
+int vcm_sys_init(void);
+int vcm_sys_destroy(void);
+
+#endif /* _VCM_H_ */
+
diff --git a/include/linux/vcm_types.h b/include/linux/vcm_types.h
new file mode 100644
index 0000000..671e80f
--- /dev/null
+++ b/include/linux/vcm_types.h
@@ -0,0 +1,338 @@
+/* Copyright (c) 2010, Code Aurora Forum. All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are
+ * met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above
+ *       copyright notice, this list of conditions and the following
+ *       disclaimer in the documentation and/or other materials provided
+ *       with the distribution.
+ *     * Neither the name of Code Aurora Forum, Inc. nor the names of its
+ *       contributors may be used to endorse or promote products derived
+ *       from this software without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
+ * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT
+ * ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
+ * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
+ * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
+ * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
+ * IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ */
+
+#ifndef VCM_TYPES_H
+#define VCM_TYPES_H
+
+#include <linux/types.h>
+#include <linux/mutex.h>
+#include <linux/spinlock.h>
+#include <linux/genalloc.h>
+#include <linux/vcm_alloc.h>
+#include <linux/list.h>
+#include <linux/device.h>
+
+/*
+ * Reservation Attributes
+ *
+ * Used in vcm_reserve(), vcm_reserve_at(), vcm_set_res_attr() and
+ * vcm_reserve_bound().
+ *
+ *	VCM_READ	Specifies that the reservation can be read.
+ *	VCM_WRITE	Specifies that the reservation can be written.
+ *	VCM_EXECUTE	Specifies that the reservation can be executed.
+ *	VCM_USER	Specifies that this reservation is used for
+ *			userspace access.
+ *	VCM_SUPERVISOR	Specifies that this reservation is used for
+ *				supervisor access.
+ *	VCM_SECURE	Specifies that the target of the reservation is
+ *			secure. The usage of this setting is TBD.
+ *
+ *	Caching behavior as a 4 bit field:
+ *		VCM_NOTCACHED		The VCM region is not cached.
+ *		VCM_INNER_WB_WA		The VCM region is inner cached
+ *					and is write-back and write-allocate.
+ *		VCM_INNER_WT_NWA	The VCM region is inner cached and is
+ *					write-through and no-write-allocate.
+ *		VCM_INNER_WB_NWA	The VCM region is inner cached and is
+ *					write-back and no-write-allocate.
+ *		VCM_OUTER_WB_WA		The VCM region is outer cached and is
+ *					write-back and write-allocate.
+ *		VCM_OUTER_WT_NWA	The VCM region is outer cached and is
+ *					write-through and no-write-allocate.
+ *		VCM_OUTER_WB_NWA	The VCM region is outer cached and is
+ *					write-back and no-write-allocate.
+ *		VCM_WB_WA		The VCM region is cached and is write
+ *					-back and write-allocate.
+ *		VCM_WT_NWA		The VCM region is cached and is write
+ *					-through and no-write-allocate.
+ *		VCM_WB_NWA		The VCM region is cached and is write
+ *					-back and no-write-allocate.
+ */
+
+#define VCM_CACHE_POLICY	(0xF << 0)
+
+#define VCM_READ		(1UL << 9)
+#define VCM_WRITE		(1UL << 8)
+#define VCM_EXECUTE		(1UL << 7)
+#define VCM_USER		(1UL << 6)
+#define VCM_SUPERVISOR		(1UL << 5)
+#define VCM_SECURE		(1UL << 4)
+#define VCM_NOTCACHED		(0UL << 0)
+#define VCM_WB_WA		(1UL << 0)
+#define VCM_WB_NWA		(2UL << 0)
+#define VCM_WT			(3UL << 0)
+
+
+/*
+ * Physical Allocation Attributes
+ *
+ * Used in vcm_phys_alloc().
+ *
+ *	Alignment as a power of 2 starting at 4 KB. 5 bit field.
+ *	1 = 4KB, 2 = 8KB, etc.
+ *
+ *			Specifies that the reservation should have the
+ *			alignment specified.
+ *
+ *	VCM_4KB		Specifies that the reservation should use 4KB pages.
+ *	VCM_64KB	Specifies that the reservation should use 64KB pages.
+ *	VCM_1MB		specifies that the reservation should use 1MB pages.
+ *	VCM_ALL		Specifies that the reservation should use all
+ *			available page sizes.
+ *	VCM_PHYS_CONT	Specifies that a reservation should be backed with
+ *			physically contiguous memory.
+ *	VCM_COHERENT	Specifies that the reservation must be kept coherent
+ *			because it's shared.
+ */
+
+#define VCM_ALIGNMENT_MASK      (0x1FUL << 6) /* 5-bit field */
+#define VCM_4KB			(1UL << 5)
+#define VCM_64KB		(1UL << 4)
+#define VCM_1MB			(1UL << 3)
+#define VCM_ALL			(1UL << 2)
+#define VCM_PAGE_SEL_MASK       (0xFUL << 2)
+#define VCM_PHYS_CONT		(1UL << 1)
+#define VCM_COHERENT		(1UL << 0)
+
+
+#define SHIFT_4KB               (12)
+
+#define ALIGN_REQ_BYTES(attr) (1UL << (((attr & VCM_ALIGNMENT_MASK) >> 6) + 12))
+/* set the alignment in pow 2, 0 = 4KB */
+#define SET_ALIGN_REQ_BYTES(attr, align) \
+	((attr & ~VCM_ALIGNMENT_MASK) | ((align << 6) & VCM_ALIGNMENT_MASK))
+
+/*
+ * Association Attributes
+ *
+ * Used in vcm_assoc(), vcm_set_assoc_attr().
+ *
+ * 	VCM_USE_LOW_BASE	Use the low base register.
+ *	VCM_USE_HIGH_BASE	Use the high base register.
+ *
+ *	VCM_SPLIT		A 5 bit field that defines the
+ *				high/low split.  This value defines
+ *				the number of 0's left-filled into the
+ *				split register. Addresses that match
+ *				this will use VCM_USE_LOW_BASE
+ *				otherwise they'll use
+ *				VCM_USE_HIGH_BASE. An all 0's value
+ *				directs all translations to
+ *				VCM_USE_LOW_BASE.
+ */
+
+#define VCM_SPLIT		(1UL << 3)
+#define VCM_USE_LOW_BASE	(1UL << 2)
+#define VCM_USE_HIGH_BASE	(1UL << 1)
+
+/*
+ * External VCMs
+ *
+ * Used in vcm_create_from_prebuilt()
+ *
+ * Externally created VCM IDs for creating kernel and user space
+ * mappings to VCMs and kernel and user space buffers out of
+ * VCM_MEMTYPE_0,1,2, etc.
+ *
+ */
+#define VCM_PREBUILT_KERNEL		1
+#define VCM_PREBUILT_USER		2
+
+/**
+ * enum memtarget_t - A logical location in a VCM.
+ * @vcm_start: Indicates the start of a VCM_REGION.
+ */
+enum memtarget_t {
+	VCM_START
+};
+
+
+/**
+ * enum memtype_t - A logical location in a VCM.
+ * @vcm_memtype_0: 	Generic memory type 0
+ * @vcm_memtype_1: 	Generic memory type 1
+ * @vcm_memtype_2: 	Generic memory type 2
+ *
+ * A memtype encapsulates a platform specific memory arrangement. The
+ * memtype needn't refer to a single type of memory, it can refer to a
+ * set of memories that can back a reservation.
+ *
+ */
+enum memtype_t {
+	VCM_INVALID,
+	VCM_MEMTYPE_0,
+	VCM_MEMTYPE_1,
+	VCM_MEMTYPE_2,
+};
+
+
+/**
+ * vcm_handler - The signature of the fault hook.
+ * @dev:		The device id of the faulting device.
+ * @data:		The generic data pointer.
+ * @fault_data:		System specific common fault data.
+ *
+ * The handler should return 0 for success. This indicates that the
+ * fault was handled. A non-zero return value is an error and will be
+ * propagated up the stack.
+ */
+typedef int (*vcm_handler)(size_t dev, void *data, void *fault_data);
+
+
+/**
+ * enum vcm_type - The type of VCM.
+ * @vcm_memtype_0: 	Generic memory type 0
+ * @vcm_memtype_1: 	Generic memory type 1
+ * @vcm_memtype_2: 	Generic memory type 2
+ *
+ * A memtype encapsulates a platform specific memory arrangement. The
+ * memtype needn't refer to a single type of memory, it can refer to a
+ * set of memories that can back a reservation.
+ *
+ */
+enum vcm_type {
+	VCM_DEVICE,
+	VCM_EXT_KERNEL,
+	VCM_EXT_USER,
+	VCM_ONE_TO_ONE,
+};
+
+/**
+ * struct vcm - A Virtually Contiguous Memory region.
+ * @start_addr:		The starting address of the VCM region.
+ * @len: 		The len of the VCM region. This must be at least
+ *			vcm_min() bytes.
+ */
+struct vcm {
+	/* public */
+	unsigned long start_addr;
+	size_t len;
+
+
+	/* private */
+	enum vcm_type type;
+
+	struct device *dev; /* opaque device control */
+
+	/* allocator dependent */
+	struct gen_pool *pool;
+
+	struct list_head res_head;
+
+	/* this will be a very short list */
+	struct list_head assoc_head;
+};
+
+/**
+ * struct avcm - A VCM to device association
+ * @vcm:	The VCM region of interest.
+ * @dev:	The device to associate the VCM with.
+ * @attr:	See 'Association Attributes'.
+ */
+struct avcm {
+	/* public */
+	struct vcm *vcm;
+	struct device *dev;
+	u32 attr;
+
+	/* private */
+	struct list_head assoc_elm;
+
+	int is_active; /* is this particular association active */
+};
+
+
+/**
+ * struct bound - A boundary to reserve from in a VCM region.
+ * @vcm:	The VCM that needs a bound.
+ * @len:	The len of the bound.
+ */
+struct bound {
+       struct vcm *vcm;
+       size_t len;
+};
+
+
+/**
+ * struct physmem - A physical memory allocation.
+ * @memtype:	The memory type of the VCM region.
+ * @len:	The len of the physical memory allocation.
+ * @attr: 	See 'Physical Allocation Attributes'.
+ *
+ */
+struct physmem {
+	/* public */
+	enum memtype_t memtype;
+	size_t len;
+b	u32 attr;
+
+	/* private */
+	struct phys_chunk alloc_head;
+
+	/* if the physmem is cont then use the built in VCM */
+	int is_cont;
+	struct res *res;
+};
+
+
+/**
+ * struct res - A reservation in a VCM region.
+ * @vcm:	The VCM region to reserve from.
+ * @len:	The length of the reservation. Must be at least vcm_min()
+ *		bytes.
+ * @attr:	See 'Reservation Attributes'.
+ * @dev_addr:	The device-side address.
+ */
+struct res {
+	/* public */
+	struct vcm *vcm;
+	size_t len;
+	u32 attr;
+	unsigned long dev_addr;
+
+
+	/* private */
+	struct physmem *physmem;
+
+	/* allocator dependent */
+	size_t alignment_req;
+	size_t aligned_len;
+	unsigned long ptr;
+
+	struct list_head res_elm;
+
+	/* type VCM_EXT_KERNEL */
+	struct vm_struct *vm_area;
+	int mapped;
+};
+
+extern int chunk_sizes[NUM_CHUNK_SIZES];
+
+#endif /* VCM_TYPES_H */
-- 
1.7.0.2

--
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
