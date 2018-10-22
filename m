Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 47B7B6B0008
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 01:19:00 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id y68-v6so27980561oie.21
        for <linux-mm@kvack.org>; Sun, 21 Oct 2018 22:19:00 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id k24si13301924otl.102.2018.10.21.22.18.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Oct 2018 22:18:58 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w9M59VfQ061159
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 01:18:57 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2n939dgc6f-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 01:18:56 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Mon, 22 Oct 2018 06:18:54 +0100
From: Bharata B Rao <bharata@linux.ibm.com>
Subject: [RFC PATCH v1 1/4] kvmppc: HMM backend driver to manage pages of secure guest
Date: Mon, 22 Oct 2018 10:48:34 +0530
In-Reply-To: <20181022051837.1165-1-bharata@linux.ibm.com>
References: <20181022051837.1165-1-bharata@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Message-Id: <20181022051837.1165-2-bharata@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com, benh@linux.ibm.com, aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com, linuxram@us.ibm.com, Bharata B Rao <bharata@linux.ibm.com>

HMM driver for KVM PPC to manage page transitions of
secure guest via H_SVM_PAGE_IN and H_SVM_PAGE_OUT hcalls.

H_SVM_PAGE_IN: Move the content of a normal page to secure page
H_SVM_PAGE_OUT: Move the content of a secure page to normal page

Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>
---
 arch/powerpc/include/asm/hvcall.h    |   7 +-
 arch/powerpc/include/asm/kvm_host.h  |  15 +
 arch/powerpc/include/asm/kvm_ppc.h   |  28 ++
 arch/powerpc/include/asm/ucall-api.h |  20 ++
 arch/powerpc/kvm/Makefile            |   3 +
 arch/powerpc/kvm/book3s_hv.c         |  38 ++
 arch/powerpc/kvm/book3s_hv_hmm.c     | 514 +++++++++++++++++++++++++++
 7 files changed, 624 insertions(+), 1 deletion(-)
 create mode 100644 arch/powerpc/include/asm/ucall-api.h
 create mode 100644 arch/powerpc/kvm/book3s_hv_hmm.c

diff --git a/arch/powerpc/include/asm/hvcall.h b/arch/powerpc/include/asm/hvcall.h
index a0b17f9f1ea4..89e6b70c1857 100644
--- a/arch/powerpc/include/asm/hvcall.h
+++ b/arch/powerpc/include/asm/hvcall.h
@@ -158,6 +158,9 @@
 /* Each control block has to be on a 4K boundary */
 #define H_CB_ALIGNMENT          4096
 
+/* Flags for H_SVM_PAGE_IN */
+#define H_PAGE_IN_SHARED	0x1
+
 /* pSeries hypervisor opcodes */
 #define H_REMOVE		0x04
 #define H_ENTER			0x08
@@ -295,7 +298,9 @@
 #define H_INT_ESB               0x3C8
 #define H_INT_SYNC              0x3CC
 #define H_INT_RESET             0x3D0
-#define MAX_HCALL_OPCODE	H_INT_RESET
+#define H_SVM_PAGE_IN		0x3D4
+#define H_SVM_PAGE_OUT		0x3D8
+#define MAX_HCALL_OPCODE	H_SVM_PAGE_OUT
 
 /* H_VIOCTL functions */
 #define H_GET_VIOA_DUMP_SIZE	0x01
diff --git a/arch/powerpc/include/asm/kvm_host.h b/arch/powerpc/include/asm/kvm_host.h
index 906bcbdfd2a1..194e6e0ff239 100644
--- a/arch/powerpc/include/asm/kvm_host.h
+++ b/arch/powerpc/include/asm/kvm_host.h
@@ -310,6 +310,9 @@ struct kvm_arch {
 	struct kvmppc_passthru_irqmap *pimap;
 #endif
 	struct kvmppc_ops *kvm_ops;
+#ifdef CONFIG_PPC_SVM
+	struct hlist_head *hmm_hash;
+#endif
 #ifdef CONFIG_KVM_BOOK3S_HV_POSSIBLE
 	/* This array can grow quite large, keep it at the end */
 	struct kvmppc_vcore *vcores[KVM_MAX_VCORES];
@@ -830,4 +833,16 @@ static inline void kvm_arch_vcpu_blocking(struct kvm_vcpu *vcpu) {}
 static inline void kvm_arch_vcpu_unblocking(struct kvm_vcpu *vcpu) {}
 static inline void kvm_arch_vcpu_block_finish(struct kvm_vcpu *vcpu) {}
 
+#ifdef CONFIG_PPC_SVM
+struct kvmppc_hmm_device {
+	struct hmm_device *device;
+	struct hmm_devmem *devmem;
+	unsigned long *pfn_bitmap;
+};
+
+extern int kvmppc_hmm_init(void);
+extern void kvmppc_hmm_free(void);
+extern int kvmppc_hmm_hash_create(struct kvm *kvm);
+extern void kvmppc_hmm_hash_destroy(struct kvm *kvm);
+#endif
 #endif /* __POWERPC_KVM_HOST_H__ */
diff --git a/arch/powerpc/include/asm/kvm_ppc.h b/arch/powerpc/include/asm/kvm_ppc.h
index e991821dd7fa..ba81a07e2bdf 100644
--- a/arch/powerpc/include/asm/kvm_ppc.h
+++ b/arch/powerpc/include/asm/kvm_ppc.h
@@ -906,4 +906,32 @@ static inline ulong kvmppc_get_ea_indexed(struct kvm_vcpu *vcpu, int ra, int rb)
 
 extern void xics_wake_cpu(int cpu);
 
+#ifdef CONFIG_PPC_SVM
+extern unsigned long kvmppc_h_svm_page_in(struct kvm *kvm,
+					  unsigned int lpid,
+					  unsigned long gra,
+					  unsigned long flags,
+					  unsigned long page_shift);
+extern unsigned long kvmppc_h_svm_page_out(struct kvm *kvm,
+					  unsigned int lpid,
+					  unsigned long gra,
+					  unsigned long flags,
+					  unsigned long page_shift);
+#else
+static inline unsigned long
+kvmppc_h_svm_page_in(struct kvm *kvm, unsigned int lpid,
+		     unsigned long gra, unsigned long flags,
+		     unsigned long page_shift)
+{
+	return H_UNSUPPORTED;
+}
+
+static inline unsigned long
+kvmppc_h_svm_page_out(struct kvm *kvm, unsigned int lpid,
+		      unsigned long gra, unsigned long flags,
+		      unsigned long page_shift)
+{
+	return H_UNSUPPORTED;
+}
+#endif
 #endif /* __POWERPC_KVM_PPC_H__ */
diff --git a/arch/powerpc/include/asm/ucall-api.h b/arch/powerpc/include/asm/ucall-api.h
new file mode 100644
index 000000000000..2c12f514f8ab
--- /dev/null
+++ b/arch/powerpc/include/asm/ucall-api.h
@@ -0,0 +1,20 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#ifndef _ASM_POWERPC_UCALL_API_H
+#define _ASM_POWERPC_UCALL_API_H
+
+#define U_SUCCESS 0
+
+/*
+ * TODO: Dummy uvcalls, will be replaced by real calls
+ */
+static inline int uv_page_in(u64 lpid, u64 dw0, u64 dw1, u64 dw2, u64 dw3)
+{
+	return U_SUCCESS;
+}
+
+static inline int uv_page_out(u64 lpid, u64 dw0, u64 dw1, u64 dw2, u64 dw3)
+{
+	return U_SUCCESS;
+}
+
+#endif	/* _ASM_POWERPC_UCALL_API_H */
diff --git a/arch/powerpc/kvm/Makefile b/arch/powerpc/kvm/Makefile
index f872c04bb5b1..6945ffc18679 100644
--- a/arch/powerpc/kvm/Makefile
+++ b/arch/powerpc/kvm/Makefile
@@ -77,6 +77,9 @@ kvm-hv-y += \
 	book3s_64_mmu_hv.o \
 	book3s_64_mmu_radix.o
 
+kvm-hv-$(CONFIG_PPC_SVM) += \
+	book3s_hv_hmm.o
+
 kvm-hv-$(CONFIG_PPC_TRANSACTIONAL_MEM) += \
 	book3s_hv_tm.o
 
diff --git a/arch/powerpc/kvm/book3s_hv.c b/arch/powerpc/kvm/book3s_hv.c
index 3e3a71594e63..05084eb8aadd 100644
--- a/arch/powerpc/kvm/book3s_hv.c
+++ b/arch/powerpc/kvm/book3s_hv.c
@@ -73,6 +73,7 @@
 #include <asm/opal.h>
 #include <asm/xics.h>
 #include <asm/xive.h>
+#include <asm/kvm_host.h>
 
 #include "book3s.h"
 
@@ -935,6 +936,20 @@ int kvmppc_pseries_do_hcall(struct kvm_vcpu *vcpu)
 		if (ret == H_TOO_HARD)
 			return RESUME_HOST;
 		break;
+	case H_SVM_PAGE_IN:
+		ret = kvmppc_h_svm_page_in(vcpu->kvm,
+					   kvmppc_get_gpr(vcpu, 4),
+					   kvmppc_get_gpr(vcpu, 5),
+					   kvmppc_get_gpr(vcpu, 6),
+					   kvmppc_get_gpr(vcpu, 7));
+		break;
+	case H_SVM_PAGE_OUT:
+		ret = kvmppc_h_svm_page_out(vcpu->kvm,
+					    kvmppc_get_gpr(vcpu, 4),
+					    kvmppc_get_gpr(vcpu, 5),
+					    kvmppc_get_gpr(vcpu, 6),
+					    kvmppc_get_gpr(vcpu, 7));
+		break;
 	default:
 		return RESUME_HOST;
 	}
@@ -961,6 +976,8 @@ static int kvmppc_hcall_impl_hv(unsigned long cmd)
 	case H_IPOLL:
 	case H_XIRR_X:
 #endif
+	case H_SVM_PAGE_IN:
+	case H_SVM_PAGE_OUT:
 		return 1;
 	}
 
@@ -3938,6 +3955,13 @@ static int kvmppc_core_init_vm_hv(struct kvm *kvm)
 		return -ENOMEM;
 	kvm->arch.lpid = lpid;
 
+#ifdef CONFIG_PPC_SVM
+	ret = kvmppc_hmm_hash_create(kvm);
+	if (ret) {
+		kvmppc_free_lpid(kvm->arch.lpid);
+		return ret;
+	}
+#endif
 	kvmppc_alloc_host_rm_ops();
 
 	/*
@@ -4073,6 +4097,9 @@ static void kvmppc_core_destroy_vm_hv(struct kvm *kvm)
 
 	kvmppc_free_vcores(kvm);
 
+#ifdef CONFIG_PPC_SVM
+	kvmppc_hmm_hash_destroy(kvm);
+#endif
 	kvmppc_free_lpid(kvm->arch.lpid);
 
 	if (kvm_is_radix(kvm))
@@ -4384,6 +4411,8 @@ static unsigned int default_hcall_list[] = {
 	H_XIRR,
 	H_XIRR_X,
 #endif
+	H_SVM_PAGE_IN,
+	H_SVM_PAGE_OUT,
 	0
 };
 
@@ -4596,11 +4625,20 @@ static int kvmppc_book3s_init_hv(void)
 			no_mixing_hpt_and_radix = true;
 	}
 
+#ifdef CONFIG_PPC_SVM
+	r = kvmppc_hmm_init();
+	if (r < 0)
+		pr_err("KVM-HV: kvmppc_hmm_init failed %d\n", r);
+#endif
+
 	return r;
 }
 
 static void kvmppc_book3s_exit_hv(void)
 {
+#ifdef CONFIG_PPC_SVM
+	kvmppc_hmm_free();
+#endif
 	kvmppc_free_host_rm_ops();
 	if (kvmppc_radix_possible())
 		kvmppc_radix_exit();
diff --git a/arch/powerpc/kvm/book3s_hv_hmm.c b/arch/powerpc/kvm/book3s_hv_hmm.c
new file mode 100644
index 000000000000..a2ee3163a312
--- /dev/null
+++ b/arch/powerpc/kvm/book3s_hv_hmm.c
@@ -0,0 +1,514 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * HMM driver to manage page migration between normal and secure
+ * memory.
+ *
+ * Based on JA(C)rA'me Glisse's HMM dummy driver.
+ *
+ * Copyright 2018 Bharata B Rao, IBM Corp. <bharata@linux.ibm.com>
+ */
+
+/*
+ * A pseries guest can be run as a secure guest on Ultravisor-enabled
+ * POWER platforms. On such platforms, this driver will be used to manage
+ * the movement of guest pages between the normal memory managed by
+ * hypervisor (HV) and secure memory managed by Ultravisor (UV).
+ *
+ * Private ZONE_DEVICE memory equal to the amount of secure memory
+ * available in the platform for running secure guests is created
+ * via a HMM device. The movement of pages between normal and secure
+ * memory is done by ->alloc_and_copy() callback routine of migrate_vma().
+ *
+ * The page-in or page-out requests from UV will come to HV as hcalls and
+ * HV will call back into UV via uvcalls to satisfy these page requests.
+ *
+ * For each page that gets moved into secure memory, a HMM PFN is used
+ * on the HV side and HMM migration PTE corresponding to that PFN would be
+ * populated in the QEMU page tables. A per-guest hash table is created to
+ * manage the pool of HMM PFNs. Guest real address is used as key to index
+ * into the hash table and choose a free HMM PFN.
+ */
+
+#include <linux/hmm.h>
+#include <linux/kvm_host.h>
+#include <linux/sched/mm.h>
+#include <asm/ucall-api.h>
+
+static struct kvmppc_hmm_device *kvmppc_hmm;
+spinlock_t kvmppc_hmm_lock;
+
+#define KVMPPC_HMM_HASH_BITS    10
+#define KVMPPC_HMM_HASH_SIZE   (1 << KVMPPC_HMM_HASH_BITS)
+
+struct kvmppc_hmm_pfn_entry {
+	struct hlist_node hlist;
+	unsigned long addr;
+	unsigned long hmm_pfn;
+};
+
+struct kvmppc_hmm_page_pvt {
+	struct hlist_head *hmm_hash;
+	unsigned int lpid;
+	unsigned long gpa;
+};
+
+struct kvmppc_hmm_migrate_args {
+	struct hlist_head *hmm_hash;
+	unsigned int lpid;
+	unsigned long gpa;
+	unsigned long page_shift;
+};
+
+int kvmppc_hmm_hash_create(struct kvm *kvm)
+{
+	int i;
+
+	kvm->arch.hmm_hash = kzalloc(KVMPPC_HMM_HASH_SIZE *
+				     sizeof(struct hlist_head), GFP_KERNEL);
+	if (!kvm->arch.hmm_hash)
+		return -ENOMEM;
+
+	for (i = 0; i < KVMPPC_HMM_HASH_SIZE; i++)
+		INIT_HLIST_HEAD(&kvm->arch.hmm_hash[i]);
+	return 0;
+}
+
+/*
+ * Cleanup the HMM pages hash table when guest terminates
+ *
+ * Iterate over all the HMM pages hash list entries and release
+ * reference on them. The actual freeing of the entry happens
+ * via hmm_devmem_ops.free path.
+ */
+void kvmppc_hmm_hash_destroy(struct kvm *kvm)
+{
+	int i;
+	struct kvmppc_hmm_pfn_entry *p;
+	struct page *hmm_page;
+
+	for (i = 0; i < KVMPPC_HMM_HASH_SIZE; i++) {
+		while (!hlist_empty(&kvm->arch.hmm_hash[i])) {
+			p = hlist_entry(kvm->arch.hmm_hash[i].first,
+					struct kvmppc_hmm_pfn_entry,
+					hlist);
+			hmm_page = pfn_to_page(p->hmm_pfn);
+			put_page(hmm_page);
+		}
+	}
+	kfree(kvm->arch.hmm_hash);
+}
+
+static u64 kvmppc_hmm_pfn_hash_fn(u64 addr)
+{
+	return hash_64(addr, KVMPPC_HMM_HASH_BITS);
+}
+
+static void
+kvmppc_hmm_hash_free_pfn(struct hlist_head *hmm_hash, unsigned long gpa)
+{
+	struct kvmppc_hmm_pfn_entry *p;
+	struct hlist_head *list;
+
+	list = &hmm_hash[kvmppc_hmm_pfn_hash_fn(gpa)];
+	hlist_for_each_entry(p, list, hlist) {
+		if (p->addr == gpa) {
+			hlist_del(&p->hlist);
+			kfree(p);
+			return;
+		}
+	}
+}
+
+/*
+ * Get a free HMM PFN from the pool
+ *
+ * Called when a normal page is moved to secure memory (UV_PAGE_IN). HMM
+ * PFN will be used to keep track of the secure page on HV side.
+ */
+static struct page *kvmppc_hmm_get_page(struct hlist_head *hmm_hash,
+					unsigned long gpa, unsigned int lpid)
+{
+	struct page *dpage = NULL;
+	unsigned long bit;
+	unsigned long nr_pfns = kvmppc_hmm->devmem->pfn_last -
+				kvmppc_hmm->devmem->pfn_first;
+	struct hlist_head *list;
+	struct kvmppc_hmm_pfn_entry *p;
+	bool found = false;
+	unsigned long flags;
+	struct kvmppc_hmm_page_pvt *pvt;
+
+	spin_lock_irqsave(&kvmppc_hmm_lock, flags);
+	list = &hmm_hash[kvmppc_hmm_pfn_hash_fn(gpa)];
+	hlist_for_each_entry(p, list, hlist) {
+		if (p->addr == gpa) {
+			found = true;
+			break;
+		}
+	}
+	if (!found) {
+		p = kzalloc(sizeof(struct kvmppc_hmm_pfn_entry), GFP_ATOMIC);
+		if (!p) {
+			spin_unlock_irqrestore(&kvmppc_hmm_lock, flags);
+			return NULL;
+		}
+		p->addr = gpa;
+		bit = find_first_zero_bit(kvmppc_hmm->pfn_bitmap, nr_pfns);
+		if (bit >= nr_pfns) {
+			kfree(p);
+			spin_unlock_irqrestore(&kvmppc_hmm_lock, flags);
+			return NULL;
+		}
+		bitmap_set(kvmppc_hmm->pfn_bitmap, bit, 1);
+		p->hmm_pfn = bit + kvmppc_hmm->devmem->pfn_first;
+		INIT_HLIST_NODE(&p->hlist);
+		hlist_add_head(&p->hlist, list);
+	} else {
+		spin_unlock_irqrestore(&kvmppc_hmm_lock, flags);
+		return NULL;
+	}
+	dpage = pfn_to_page(p->hmm_pfn);
+
+	if (!trylock_page(dpage)) {
+		bitmap_clear(kvmppc_hmm->pfn_bitmap,
+			     p->hmm_pfn - kvmppc_hmm->devmem->pfn_first, 1);
+		hlist_del(&p->hlist);
+		kfree(p);
+		spin_unlock_irqrestore(&kvmppc_hmm_lock, flags);
+		return NULL;
+	}
+	spin_unlock_irqrestore(&kvmppc_hmm_lock, flags);
+
+	pvt = kzalloc(sizeof(*pvt), GFP_ATOMIC);
+	pvt->hmm_hash = hmm_hash;
+	pvt->gpa = gpa;
+	pvt->lpid = lpid;
+	hmm_devmem_page_set_drvdata(dpage, (unsigned long)pvt);
+
+	get_page(dpage);
+	return dpage;
+}
+
+/*
+ * Release the HMM PFN back to the pool
+ *
+ * Called when secure page becomes a normal page during UV_PAGE_OUT.
+ */
+static void kvmppc_hmm_put_page(struct page *page)
+{
+	unsigned long pfn = page_to_pfn(page);
+	unsigned long flags;
+	struct kvmppc_hmm_page_pvt *pvt;
+
+	pvt = (struct kvmppc_hmm_page_pvt *)hmm_devmem_page_get_drvdata(page);
+	hmm_devmem_page_set_drvdata(page, 0);
+
+	spin_lock_irqsave(&kvmppc_hmm_lock, flags);
+	bitmap_clear(kvmppc_hmm->pfn_bitmap,
+		     pfn - kvmppc_hmm->devmem->pfn_first, 1);
+	kvmppc_hmm_hash_free_pfn(pvt->hmm_hash, pvt->gpa);
+	spin_unlock_irqrestore(&kvmppc_hmm_lock, flags);
+	kfree(pvt);
+}
+
+static void
+kvmppc_hmm_migrate_alloc_and_copy(struct vm_area_struct *vma,
+				  const unsigned long *src_pfns,
+				  unsigned long *dst_pfns,
+				  unsigned long start,
+				  unsigned long end,
+				  void *private)
+{
+	unsigned long addr;
+	struct kvmppc_hmm_migrate_args *args = private;
+	unsigned long page_size = 1UL << args->page_shift;
+
+	for (addr = start; addr < end;
+		addr += page_size, src_pfns++, dst_pfns++) {
+		struct page *spage = migrate_pfn_to_page(*src_pfns);
+		struct page *dpage;
+		unsigned long pfn = *src_pfns >> MIGRATE_PFN_SHIFT;
+
+		*dst_pfns = 0;
+		if (!spage && !(*src_pfns & MIGRATE_PFN_MIGRATE))
+			continue;
+
+		if (spage && !(*src_pfns & MIGRATE_PFN_MIGRATE))
+			continue;
+
+		dpage = kvmppc_hmm_get_page(args->hmm_hash, args->gpa,
+					    args->lpid);
+		if (!dpage)
+			continue;
+
+		if (spage)
+			uv_page_in(args->lpid, pfn << args->page_shift,
+				   args->gpa, 0, args->page_shift);
+
+		*dst_pfns = migrate_pfn(page_to_pfn(dpage)) |
+			    MIGRATE_PFN_DEVICE | MIGRATE_PFN_LOCKED;
+	}
+}
+
+static void
+kvmppc_hmm_migrate_finalize_and_map(struct vm_area_struct *vma,
+				    const unsigned long *src_pfns,
+				    const unsigned long *dst_pfns,
+				    unsigned long start,
+				    unsigned long end,
+				    void *private)
+{
+}
+
+static const struct migrate_vma_ops kvmppc_hmm_migrate_ops = {
+	.alloc_and_copy = kvmppc_hmm_migrate_alloc_and_copy,
+	.finalize_and_map = kvmppc_hmm_migrate_finalize_and_map,
+};
+
+static unsigned long kvmppc_gpa_to_hva(struct kvm *kvm, unsigned long gpa,
+				       unsigned long page_shift)
+{
+	unsigned long gfn, hva;
+	struct kvm_memory_slot *memslot;
+
+	gfn = gpa >> page_shift;
+	memslot = gfn_to_memslot(kvm, gfn);
+	hva = gfn_to_hva_memslot(memslot, gfn);
+
+	return hva;
+}
+
+/*
+ * Move page from normal memory to secure memory.
+ */
+unsigned long
+kvmppc_h_svm_page_in(struct kvm *kvm, unsigned long gpa,
+		     unsigned long flags, unsigned long page_shift)
+{
+	unsigned long addr, end;
+	unsigned long src_pfn, dst_pfn;
+	struct kvmppc_hmm_migrate_args args;
+	struct mm_struct *mm = get_task_mm(current);
+	struct vm_area_struct *vma;
+	int ret = H_SUCCESS;
+
+	if (page_shift != PAGE_SHIFT)
+		return H_P3;
+
+	addr = kvmppc_gpa_to_hva(kvm, gpa, page_shift);
+	if (!addr)
+		return H_PARAMETER;
+	end = addr + (1UL << page_shift);
+
+	if (flags)
+		return H_P2;
+
+	args.hmm_hash = kvm->arch.hmm_hash;
+	args.lpid = kvm->arch.lpid;
+	args.gpa = gpa;
+	args.page_shift = page_shift;
+
+	down_read(&mm->mmap_sem);
+	vma = find_vma_intersection(mm, addr, end);
+	if (!vma || vma->vm_start > addr || vma->vm_end < end) {
+		ret = H_PARAMETER;
+		goto out;
+	}
+	ret = migrate_vma(&kvmppc_hmm_migrate_ops, vma, addr, end,
+			  &src_pfn, &dst_pfn, &args);
+	if (ret < 0)
+		ret = H_PARAMETER;
+out:
+	up_read(&mm->mmap_sem);
+	return ret;
+}
+
+static void
+kvmppc_hmm_fault_migrate_alloc_and_copy(struct vm_area_struct *vma,
+					const unsigned long *src_pfn,
+					unsigned long *dst_pfn,
+					unsigned long start,
+					unsigned long end,
+					void *private)
+{
+	struct page *dpage, *spage;
+	struct kvmppc_hmm_page_pvt *pvt;
+	unsigned long pfn;
+	int ret = U_SUCCESS;
+
+	*dst_pfn = MIGRATE_PFN_ERROR;
+	spage = migrate_pfn_to_page(*src_pfn);
+	if (!spage || !(*src_pfn & MIGRATE_PFN_MIGRATE))
+		return;
+	if (!is_zone_device_page(spage))
+		return;
+	dpage = hmm_vma_alloc_locked_page(vma, start);
+	if (!dpage)
+		return;
+	pvt = (struct kvmppc_hmm_page_pvt *)
+	       hmm_devmem_page_get_drvdata(spage);
+
+	pfn = page_to_pfn(dpage);
+	ret = uv_page_out(pvt->lpid, pfn << PAGE_SHIFT,
+			  pvt->gpa, 0, PAGE_SHIFT);
+	if (ret == U_SUCCESS)
+		*dst_pfn = migrate_pfn(pfn) | MIGRATE_PFN_LOCKED;
+}
+
+static void
+kvmppc_hmm_fault_migrate_finalize_and_map(struct vm_area_struct *vma,
+					  const unsigned long *src_pfns,
+					  const unsigned long *dst_pfns,
+					  unsigned long start,
+					  unsigned long end,
+					  void *private)
+{
+}
+
+static const struct migrate_vma_ops kvmppc_hmm_fault_migrate_ops = {
+	.alloc_and_copy = kvmppc_hmm_fault_migrate_alloc_and_copy,
+	.finalize_and_map = kvmppc_hmm_fault_migrate_finalize_and_map,
+};
+
+/*
+ * Fault handler callback when HV touches any page that has been
+ * moved to secure memory, we ask UV to give back the page by
+ * issuing a UV_PAGE_OUT uvcall.
+ */
+static int kvmppc_hmm_devmem_fault(struct hmm_devmem *devmem,
+				   struct vm_area_struct *vma,
+				   unsigned long addr,
+				   const struct page *page,
+				   unsigned int flags,
+				   pmd_t *pmdp)
+{
+	unsigned long end = addr + PAGE_SIZE;
+	unsigned long src_pfn, dst_pfn = 0;
+
+	if (migrate_vma(&kvmppc_hmm_fault_migrate_ops, vma, addr, end,
+			&src_pfn, &dst_pfn, NULL))
+		return VM_FAULT_SIGBUS;
+	if (dst_pfn == MIGRATE_PFN_ERROR)
+		return VM_FAULT_SIGBUS;
+	return 0;
+}
+
+static void kvmppc_hmm_devmem_free(struct hmm_devmem *devmem,
+				   struct page *page)
+{
+	kvmppc_hmm_put_page(page);
+}
+
+static const struct hmm_devmem_ops kvmppc_hmm_devmem_ops = {
+	.free = kvmppc_hmm_devmem_free,
+	.fault = kvmppc_hmm_devmem_fault,
+};
+
+/*
+ * Move page from secure memory to normal memory.
+ */
+unsigned long
+kvmppc_h_svm_page_out(struct kvm *kvm, unsigned long gpa,
+		      unsigned long flags, unsigned long page_shift)
+{
+	unsigned long addr, end;
+	struct mm_struct *mm = get_task_mm(current);
+	struct vm_area_struct *vma;
+	unsigned long src_pfn, dst_pfn = 0;
+	int ret = H_SUCCESS;
+
+	if (page_shift != PAGE_SHIFT)
+		return H_P4;
+
+	addr = kvmppc_gpa_to_hva(kvm, gpa, page_shift);
+	if (!addr)
+		return H_P2;
+	end = addr + (1UL << page_shift);
+
+	down_read(&mm->mmap_sem);
+	vma = find_vma_intersection(mm, addr, end);
+	if (!vma || vma->vm_start > addr || vma->vm_end < end) {
+		ret = H_PARAMETER;
+		goto out;
+	}
+	ret = migrate_vma(&kvmppc_hmm_fault_migrate_ops, vma, addr, end,
+			  &src_pfn, &dst_pfn, NULL);
+	if (ret < 0)
+		ret = H_PARAMETER;
+out:
+	up_read(&mm->mmap_sem);
+	return ret;
+}
+
+/*
+ * TODO: Number of secure pages and the page size order would probably come
+ * via DT or via some uvcall. Return 8G for now.
+ */
+static unsigned long kvmppc_get_secmem_size(void)
+{
+	return (1UL << 33);
+}
+
+static int kvmppc_hmm_pages_init(void)
+{
+	unsigned long nr_pfns = kvmppc_hmm->devmem->pfn_last -
+				kvmppc_hmm->devmem->pfn_first;
+
+	kvmppc_hmm->pfn_bitmap = kcalloc(BITS_TO_LONGS(nr_pfns),
+					 sizeof(unsigned long), GFP_KERNEL);
+	if (!kvmppc_hmm->pfn_bitmap)
+		return -ENOMEM;
+
+	spin_lock_init(&kvmppc_hmm_lock);
+
+	return 0;
+}
+
+int kvmppc_hmm_init(void)
+{
+	int ret = 0;
+	unsigned long size = kvmppc_get_secmem_size();
+
+	kvmppc_hmm = kzalloc(sizeof(*kvmppc_hmm), GFP_KERNEL);
+	if (!kvmppc_hmm) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	kvmppc_hmm->device = hmm_device_new(NULL);
+	if (IS_ERR(kvmppc_hmm->device)) {
+		ret = PTR_ERR(kvmppc_hmm->device);
+		goto out_free;
+	}
+
+	kvmppc_hmm->devmem = hmm_devmem_add(&kvmppc_hmm_devmem_ops,
+					    &kvmppc_hmm->device->device, size);
+	if (IS_ERR(kvmppc_hmm->devmem)) {
+		ret = PTR_ERR(kvmppc_hmm->devmem);
+		goto out_device;
+	}
+	ret = kvmppc_hmm_pages_init();
+	if (ret < 0)
+		goto out_devmem;
+
+	return ret;
+
+out_devmem:
+	hmm_devmem_remove(kvmppc_hmm->devmem);
+out_device:
+	hmm_device_put(kvmppc_hmm->device);
+out_free:
+	kfree(kvmppc_hmm);
+	kvmppc_hmm = NULL;
+out:
+	return ret;
+}
+
+void kvmppc_hmm_free(void)
+{
+	kfree(kvmppc_hmm->pfn_bitmap);
+	hmm_devmem_remove(kvmppc_hmm->devmem);
+	hmm_device_put(kvmppc_hmm->device);
+	kfree(kvmppc_hmm);
+	kvmppc_hmm = NULL;
+}
-- 
2.17.1
