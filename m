Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id CD8866B0037
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 05:11:18 -0400 (EDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 28 Jun 2013 14:36:33 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 13CCA394004E
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 14:41:12 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5S9BVsW30933114
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 14:41:31 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5S9BBth000703
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 19:11:11 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V2 3/4] powerpc: Contiguous memory allocator based RMA allocation
Date: Fri, 28 Jun 2013 14:41:01 +0530
Message-Id: <1372410662-3748-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1372410662-3748-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1372410662-3748-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, m.szyprowski@samsung.com, mina86@mina86.com
Cc: linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Use CMA for allocation of RMA region for guest. Also remove linear allocator
now that it is not used

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/kvm_book3s_64.h |   1 +
 arch/powerpc/include/asm/kvm_host.h      |  12 +--
 arch/powerpc/include/asm/kvm_ppc.h       |   8 +-
 arch/powerpc/kernel/setup_64.c           |   2 -
 arch/powerpc/kvm/book3s_hv.c             |  34 +++++--
 arch/powerpc/kvm/book3s_hv_builtin.c     | 160 +++++++------------------------
 6 files changed, 64 insertions(+), 153 deletions(-)

diff --git a/arch/powerpc/include/asm/kvm_book3s_64.h b/arch/powerpc/include/asm/kvm_book3s_64.h
index f8355a9..76ff0b5 100644
--- a/arch/powerpc/include/asm/kvm_book3s_64.h
+++ b/arch/powerpc/include/asm/kvm_book3s_64.h
@@ -37,6 +37,7 @@ static inline void svcpu_put(struct kvmppc_book3s_shadow_vcpu *svcpu)
 
 #ifdef CONFIG_KVM_BOOK3S_64_HV
 #define KVM_DEFAULT_HPT_ORDER	24	/* 16MB HPT by default */
+extern unsigned long kvm_rma_pages;
 #endif
 
 #define VRMA_VSID	0x1ffffffUL	/* 1TB VSID reserved for VRMA */
diff --git a/arch/powerpc/include/asm/kvm_host.h b/arch/powerpc/include/asm/kvm_host.h
index 0097dab..3328353 100644
--- a/arch/powerpc/include/asm/kvm_host.h
+++ b/arch/powerpc/include/asm/kvm_host.h
@@ -183,13 +183,9 @@ struct kvmppc_spapr_tce_table {
 	struct page *pages[0];
 };
 
-struct kvmppc_linear_info {
-	void		*base_virt;
-	unsigned long	 base_pfn;
-	unsigned long	 npages;
-	struct list_head list;
-	atomic_t	 use_count;
-	int		 type;
+struct kvm_rma_info {
+	atomic_t use_count;
+	unsigned long base_pfn;
 };
 
 /* XICS components, defined in book3s_xics.c */
@@ -246,7 +242,7 @@ struct kvm_arch {
 	int tlbie_lock;
 	unsigned long lpcr;
 	unsigned long rmor;
-	struct kvmppc_linear_info *rma;
+	struct kvm_rma_info *rma;
 	unsigned long vrma_slb_v;
 	int rma_setup_done;
 	int using_mmu_notifiers;
diff --git a/arch/powerpc/include/asm/kvm_ppc.h b/arch/powerpc/include/asm/kvm_ppc.h
index 058ac93..7a09cf5 100644
--- a/arch/powerpc/include/asm/kvm_ppc.h
+++ b/arch/powerpc/include/asm/kvm_ppc.h
@@ -137,8 +137,8 @@ extern long kvmppc_h_put_tce(struct kvm_vcpu *vcpu, unsigned long liobn,
 			     unsigned long ioba, unsigned long tce);
 extern long kvm_vm_ioctl_allocate_rma(struct kvm *kvm,
 				struct kvm_allocate_rma *rma);
-extern struct kvmppc_linear_info *kvm_alloc_rma(void);
-extern void kvm_release_rma(struct kvmppc_linear_info *ri);
+extern struct kvm_rma_info *kvm_alloc_rma(void);
+extern void kvm_release_rma(struct kvm_rma_info *ri);
 extern struct page *kvm_alloc_hpt(int nr_pages);
 extern void kvm_release_hpt(struct page *page, int nr_pages);
 extern int kvmppc_core_init_vm(struct kvm *kvm);
@@ -282,7 +282,6 @@ static inline void kvmppc_set_host_ipi(int cpu, u8 host_ipi)
 }
 
 extern void kvmppc_fast_vcpu_kick(struct kvm_vcpu *vcpu);
-extern void kvm_linear_init(void);
 
 #else
 static inline void __init kvm_cma_reserve(void)
@@ -291,9 +290,6 @@ static inline void __init kvm_cma_reserve(void)
 static inline void kvmppc_set_xics_phys(int cpu, unsigned long addr)
 {}
 
-static inline void kvm_linear_init(void)
-{}
-
 static inline u32 kvmppc_get_xics_latch(void)
 {
 	return 0;
diff --git a/arch/powerpc/kernel/setup_64.c b/arch/powerpc/kernel/setup_64.c
index ee28d1f..8a022f5 100644
--- a/arch/powerpc/kernel/setup_64.c
+++ b/arch/powerpc/kernel/setup_64.c
@@ -611,8 +611,6 @@ void __init setup_arch(char **cmdline_p)
 	/* Initialize the MMU context management stuff */
 	mmu_context_init();
 
-	kvm_linear_init();
-
 	/* Interrupt code needs to be 64K-aligned */
 	if ((unsigned long)_stext & 0xffff)
 		panic("Kernelbase not 64K-aligned (0x%lx)!\n",
diff --git a/arch/powerpc/kvm/book3s_hv.c b/arch/powerpc/kvm/book3s_hv.c
index 550f592..7c5edcb 100644
--- a/arch/powerpc/kvm/book3s_hv.c
+++ b/arch/powerpc/kvm/book3s_hv.c
@@ -1511,10 +1511,10 @@ static inline int lpcr_rmls(unsigned long rma_size)
 
 static int kvm_rma_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
-	struct kvmppc_linear_info *ri = vma->vm_file->private_data;
 	struct page *page;
+	struct kvm_rma_info *ri = vma->vm_file->private_data;
 
-	if (vmf->pgoff >= ri->npages)
+	if (vmf->pgoff >= kvm_rma_pages)
 		return VM_FAULT_SIGBUS;
 
 	page = pfn_to_page(ri->base_pfn + vmf->pgoff);
@@ -1536,7 +1536,7 @@ static int kvm_rma_mmap(struct file *file, struct vm_area_struct *vma)
 
 static int kvm_rma_release(struct inode *inode, struct file *filp)
 {
-	struct kvmppc_linear_info *ri = filp->private_data;
+	struct kvm_rma_info *ri = filp->private_data;
 
 	kvm_release_rma(ri);
 	return 0;
@@ -1549,8 +1549,24 @@ static const struct file_operations kvm_rma_fops = {
 
 long kvm_vm_ioctl_allocate_rma(struct kvm *kvm, struct kvm_allocate_rma *ret)
 {
-	struct kvmppc_linear_info *ri;
 	long fd;
+	struct kvm_rma_info *ri;
+	/*
+	 * Only do this on PPC970 in HV mode
+	 */
+	if (!cpu_has_feature(CPU_FTR_HVMODE) ||
+	    !cpu_has_feature(CPU_FTR_ARCH_201))
+		return -EINVAL;
+
+	if (!kvm_rma_pages)
+		return -EINVAL;
+	/*
+	 * Check that the requested size is one supported in hardware
+	 */
+	if (lpcr_rmls(kvm_rma_pages << PAGE_SHIFT) < 0) {
+		pr_err("RMA pages of %lu not supported\n", kvm_rma_pages);
+		return -EINVAL;
+	}
 
 	ri = kvm_alloc_rma();
 	if (!ri)
@@ -1560,7 +1576,7 @@ long kvm_vm_ioctl_allocate_rma(struct kvm *kvm, struct kvm_allocate_rma *ret)
 	if (fd < 0)
 		kvm_release_rma(ri);
 
-	ret->rma_size = ri->npages << PAGE_SHIFT;
+	ret->rma_size = kvm_rma_pages << PAGE_SHIFT;
 	return fd;
 }
 
@@ -1725,7 +1741,7 @@ static int kvmppc_hv_setup_htab_rma(struct kvm_vcpu *vcpu)
 {
 	int err = 0;
 	struct kvm *kvm = vcpu->kvm;
-	struct kvmppc_linear_info *ri = NULL;
+	struct kvm_rma_info *ri = NULL;
 	unsigned long hva;
 	struct kvm_memory_slot *memslot;
 	struct vm_area_struct *vma;
@@ -1803,7 +1819,7 @@ static int kvmppc_hv_setup_htab_rma(struct kvm_vcpu *vcpu)
 
 	} else {
 		/* Set up to use an RMO region */
-		rma_size = ri->npages;
+		rma_size = kvm_rma_pages;
 		if (rma_size > memslot->npages)
 			rma_size = memslot->npages;
 		rma_size <<= PAGE_SHIFT;
@@ -1831,14 +1847,14 @@ static int kvmppc_hv_setup_htab_rma(struct kvm_vcpu *vcpu)
 			/* POWER7 */
 			lpcr &= ~(LPCR_VPM0 | LPCR_VRMA_L);
 			lpcr |= rmls << LPCR_RMLS_SH;
-			kvm->arch.rmor = kvm->arch.rma->base_pfn << PAGE_SHIFT;
+			kvm->arch.rmor = ri->base_pfn << PAGE_SHIFT;
 		}
 		kvm->arch.lpcr = lpcr;
 		pr_info("KVM: Using RMO at %lx size %lx (LPCR = %lx)\n",
 			ri->base_pfn << PAGE_SHIFT, rma_size, lpcr);
 
 		/* Initialize phys addrs of pages in RMO */
-		npages = ri->npages;
+		npages = kvm_rma_pages;
 		porder = __ilog2(npages);
 		physp = memslot->arch.slot_phys;
 		if (physp) {
diff --git a/arch/powerpc/kvm/book3s_hv_builtin.c b/arch/powerpc/kvm/book3s_hv_builtin.c
index ee27a02..d9fceed 100644
--- a/arch/powerpc/kvm/book3s_hv_builtin.c
+++ b/arch/powerpc/kvm/book3s_hv_builtin.c
@@ -21,13 +21,6 @@
 #include <asm/kvm_book3s.h>
 
 #include "book3s_hv_cma.h"
-
-#define KVM_LINEAR_RMA		0
-#define KVM_LINEAR_HPT		1
-
-static void __init kvm_linear_init_one(ulong size, int count, int type);
-static struct kvmppc_linear_info *kvm_alloc_linear(int type);
-static void kvm_release_linear(struct kvmppc_linear_info *ri);
 /*
  * should be power of 2
  */
@@ -36,19 +29,17 @@ static unsigned long hpt_align_pages = (1 << 18) >> PAGE_SHIFT; /* 256k */
  * By default we reserve 5% of memory for hash pagetable allocation.
  */
 static unsigned long kvm_cma_resv_ratio = 5;
-
-/*************** RMA *************/
-
 /*
- * This maintains a list of RMAs (real mode areas) for KVM guests to use.
+ * We allocate RMAs (real mode areas) for KVM guests from the KVM CMA area.
  * Each RMA has to be physically contiguous and of a size that the
  * hardware supports.  PPC970 and POWER7 support 64MB, 128MB and 256MB,
  * and other larger sizes.  Since we are unlikely to be allocate that
  * much physically contiguous memory after the system is up and running,
- * we preallocate a set of RMAs in early boot for KVM to use.
+ * we preallocate a set of RMAs in early boot using CMA.
+ * should be power of 2.
  */
-static unsigned long kvm_rma_size = 64 << 20;	/* 64MB */
-static unsigned long kvm_rma_count;
+unsigned long kvm_rma_pages = (1 << 27) >> PAGE_SHIFT;	/* 128MB */
+EXPORT_SYMBOL_GPL(kvm_rma_pages);
 
 /* Work out RMLS (real mode limit selector) field value for a given RMA size.
    Assumes POWER7 or PPC970. */
@@ -78,35 +69,43 @@ static inline int lpcr_rmls(unsigned long rma_size)
 
 static int __init early_parse_rma_size(char *p)
 {
-	if (!p)
-		return 1;
+	unsigned long kvm_rma_size;
 
+	pr_debug("%s(%s)\n", __func__, p);
+	if (!p)
+		return -EINVAL;
 	kvm_rma_size = memparse(p, &p);
-
+	kvm_rma_pages = kvm_rma_size >> PAGE_SHIFT;
 	return 0;
 }
 early_param("kvm_rma_size", early_parse_rma_size);
 
-static int __init early_parse_rma_count(char *p)
-{
-	if (!p)
-		return 1;
-
-	kvm_rma_count = simple_strtoul(p, NULL, 0);
-
-	return 0;
-}
-early_param("kvm_rma_count", early_parse_rma_count);
-
-struct kvmppc_linear_info *kvm_alloc_rma(void)
+struct kvm_rma_info *kvm_alloc_rma()
 {
-	return kvm_alloc_linear(KVM_LINEAR_RMA);
+	struct page *page;
+	struct kvm_rma_info *ri;
+
+	ri = kmalloc(sizeof(struct kvm_rma_info), GFP_KERNEL);
+	if (!ri)
+		return NULL;
+	page = kvm_alloc_cma(kvm_rma_pages, kvm_rma_pages);
+	if (!page)
+		goto err_out;
+	atomic_set(&ri->use_count, 1);
+	ri->base_pfn = page_to_pfn(page);
+	return ri;
+err_out:
+	kfree(ri);
+	return NULL;
 }
 EXPORT_SYMBOL_GPL(kvm_alloc_rma);
 
-void kvm_release_rma(struct kvmppc_linear_info *ri)
+void kvm_release_rma(struct kvm_rma_info *ri)
 {
-	kvm_release_linear(ri);
+	if (atomic_dec_and_test(&ri->use_count)) {
+		kvm_release_cma(pfn_to_page(ri->base_pfn), kvm_rma_pages);
+		kfree(ri);
+	}
 }
 EXPORT_SYMBOL_GPL(kvm_release_rma);
 
@@ -136,101 +135,6 @@ void kvm_release_hpt(struct page *page, int nr_pages)
 }
 EXPORT_SYMBOL_GPL(kvm_release_hpt);
 
-/*************** generic *************/
-
-static LIST_HEAD(free_linears);
-static DEFINE_SPINLOCK(linear_lock);
-
-static void __init kvm_linear_init_one(ulong size, int count, int type)
-{
-	unsigned long i;
-	unsigned long j, npages;
-	void *linear;
-	struct page *pg;
-	const char *typestr;
-	struct kvmppc_linear_info *linear_info;
-
-	if (!count)
-		return;
-
-	typestr = (type == KVM_LINEAR_RMA) ? "RMA" : "HPT";
-
-	npages = size >> PAGE_SHIFT;
-	linear_info = alloc_bootmem(count * sizeof(struct kvmppc_linear_info));
-	for (i = 0; i < count; ++i) {
-		linear = alloc_bootmem_align(size, size);
-		pr_debug("Allocated KVM %s at %p (%ld MB)\n", typestr, linear,
-			 size >> 20);
-		linear_info[i].base_virt = linear;
-		linear_info[i].base_pfn = __pa(linear) >> PAGE_SHIFT;
-		linear_info[i].npages = npages;
-		linear_info[i].type = type;
-		list_add_tail(&linear_info[i].list, &free_linears);
-		atomic_set(&linear_info[i].use_count, 0);
-
-		pg = pfn_to_page(linear_info[i].base_pfn);
-		for (j = 0; j < npages; ++j) {
-			atomic_inc(&pg->_count);
-			++pg;
-		}
-	}
-}
-
-static struct kvmppc_linear_info *kvm_alloc_linear(int type)
-{
-	struct kvmppc_linear_info *ri, *ret;
-
-	ret = NULL;
-	spin_lock(&linear_lock);
-	list_for_each_entry(ri, &free_linears, list) {
-		if (ri->type != type)
-			continue;
-
-		list_del(&ri->list);
-		atomic_inc(&ri->use_count);
-		memset(ri->base_virt, 0, ri->npages << PAGE_SHIFT);
-		ret = ri;
-		break;
-	}
-	spin_unlock(&linear_lock);
-	return ret;
-}
-
-static void kvm_release_linear(struct kvmppc_linear_info *ri)
-{
-	if (atomic_dec_and_test(&ri->use_count)) {
-		spin_lock(&linear_lock);
-		list_add_tail(&ri->list, &free_linears);
-		spin_unlock(&linear_lock);
-
-	}
-}
-
-/*
- * Called at boot time while the bootmem allocator is active,
- * to allocate contiguous physical memory for the hash page
- * tables for guests.
- */
-void __init kvm_linear_init(void)
-{
-	/* RMA */
-	/* Only do this on PPC970 in HV mode */
-	if (!cpu_has_feature(CPU_FTR_HVMODE) ||
-	    !cpu_has_feature(CPU_FTR_ARCH_201))
-		return;
-
-	if (!kvm_rma_size || !kvm_rma_count)
-		return;
-
-	/* Check that the requested size is one supported in hardware */
-	if (lpcr_rmls(kvm_rma_size) < 0) {
-		pr_err("RMA size of 0x%lx not supported\n", kvm_rma_size);
-		return;
-	}
-
-	kvm_linear_init_one(kvm_rma_size, kvm_rma_count, KVM_LINEAR_RMA);
-}
-
 /**
  * kvm_cma_reserve() - reserve area for kvm hash pagetable
  *
@@ -256,7 +160,7 @@ void __init kvm_cma_reserve(void)
 	if (selected_size) {
 		pr_debug("%s: reserving %ld MiB for global area\n", __func__,
 			 (unsigned long)selected_size / SZ_1M);
-		align_size = hpt_align_pages << PAGE_SHIFT;
+		align_size = max(kvm_rma_pages, hpt_align_pages) << PAGE_SHIFT;
 		kvm_cma_declare_contiguous(selected_size, align_size);
 	}
 }
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
