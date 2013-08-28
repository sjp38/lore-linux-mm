Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id D8D0B6B003D
	for <linux-mm@kvack.org>; Wed, 28 Aug 2013 04:38:43 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fb10so5993860pad.9
        for <linux-mm@kvack.org>; Wed, 28 Aug 2013 01:38:43 -0700 (PDT)
From: Alexey Kardashevskiy <aik@ozlabs.ru>
Subject: [PATCH v9 08/13] KVM: PPC: Add support for multiple-TCE hcalls
Date: Wed, 28 Aug 2013 18:37:45 +1000
Message-Id: <1377679070-3515-9-git-send-email-aik@ozlabs.ru>
In-Reply-To: <1377679070-3515-1-git-send-email-aik@ozlabs.ru>
References: <1377679070-3515-1-git-send-email-aik@ozlabs.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: Alexey Kardashevskiy <aik@ozlabs.ru>, David Gibson <david@gibson.dropbear.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Gleb Natapov <gleb@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Graf <agraf@suse.de>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org

This adds real mode handlers for the H_PUT_TCE_INDIRECT and
H_STUFF_TCE hypercalls for user space emulated devices such as IBMVIO
devices or emulated PCI.  These calls allow adding multiple entries
(up to 512) into the TCE table in one call which saves time on
transition to/from real mode.

This adds a tce_tmp cache to kvm_vcpu_arch to save valid TCEs
(copied from user and verified) before writing the whole list into
the TCE table. This cache will be utilized more in the upcoming
VFIO/IOMMU support to continue TCE list processing in the virtual
mode in the case if the real mode handler failed for some reason.

This adds a function to convert a guest physical address to a host
virtual address in order to parse a TCE list from H_PUT_TCE_INDIRECT.

This also implements the KVM_CAP_PPC_MULTITCE capability. When present,
the hypercalls mentioned above may or may not be processed successfully
in the kernel based fast path. If they can not be handled by the kernel,
they will get passed on to user space. So user space still has to have
an implementation for these despite the in kernel acceleration.

Signed-off-by: Paul Mackerras <paulus@samba.org>
Signed-off-by: Alexey Kardashevskiy <aik@ozlabs.ru>

---
Changelog:
v8:
* fixed warnings from check_patch.pl

2013/08/01 (v7):
* realmode_get_page/realmode_put_page use was replaced with
get_page_unless_zero/put_page_unless_one

2013/07/11:
* addressed many, many comments from maintainers

2013/07/06:
* fixed number of wrong get_page()/put_page() calls

2013/06/27:
* fixed clear of BUSY bit in kvmppc_lookup_pte()
* H_PUT_TCE_INDIRECT does realmode_get_page() now
* KVM_CAP_SPAPR_MULTITCE now depends on CONFIG_PPC_BOOK3S_64
* updated doc

2013/06/05:
* fixed mistype about IBMVIO in the commit message
* updated doc and moved it to another section
* changed capability number

2013/05/21:
* added kvm_vcpu_arch::tce_tmp
* removed cleanup if put_indirect failed, instead we do not even start
writing to TCE table if we cannot get TCEs from the user and they are
invalid
* kvmppc_emulated_h_put_tce is split to kvmppc_emulated_put_tce
and kvmppc_emulated_validate_tce (for the previous item)
* fixed bug with failthrough for H_IPI
* removed all get_user() from real mode handlers
* kvmppc_lookup_pte() added (instead of making lookup_linux_pte public)
---
 Documentation/virtual/kvm/api.txt       |  26 +++
 arch/powerpc/include/asm/kvm_host.h     |   9 ++
 arch/powerpc/include/asm/kvm_ppc.h      |  16 +-
 arch/powerpc/kvm/book3s_64_vio.c        | 132 +++++++++++++++-
 arch/powerpc/kvm/book3s_64_vio_hv.c     | 270 ++++++++++++++++++++++++++++----
 arch/powerpc/kvm/book3s_hv.c            |  41 ++++-
 arch/powerpc/kvm/book3s_hv_rmhandlers.S |   8 +-
 arch/powerpc/kvm/book3s_pr_papr.c       |  35 +++++
 arch/powerpc/kvm/powerpc.c              |   3 +
 9 files changed, 506 insertions(+), 34 deletions(-)

diff --git a/Documentation/virtual/kvm/api.txt b/Documentation/virtual/kvm/api.txt
index ef925ea..1c8942a 100644
--- a/Documentation/virtual/kvm/api.txt
+++ b/Documentation/virtual/kvm/api.txt
@@ -2382,6 +2382,32 @@ calls by the guest for that service will be passed to userspace to be
 handled.
 
 
+4.86 KVM_CAP_PPC_MULTITCE
+
+Capability: KVM_CAP_PPC_MULTITCE
+Architectures: ppc
+Type: vm
+
+This capability means the kernel is capable of handling hypercalls
+H_PUT_TCE_INDIRECT and H_STUFF_TCE without passing those into the user
+space. This significantly accelerates DMA operations for PPC KVM guests.
+User space should expect that its handlers for these hypercalls
+are not going to be called if user space previously registered LIOBN
+in KVM (via KVM_CREATE_SPAPR_TCE or similar calls).
+
+In order to enable H_PUT_TCE_INDIRECT and H_STUFF_TCE use in the guest,
+user space might have to advertise it for the guest. For example,
+IBM pSeries (sPAPR) guest starts using them if "hcall-multi-tce" is
+present in the "ibm,hypertas-functions" device-tree property.
+
+The hypercalls mentioned above may or may not be processed successfully
+in the kernel based fast path. If they can not be handled by the kernel,
+they will get passed on to user space. So user space still has to have
+an implementation for these despite the in kernel acceleration.
+
+This capability is always enabled.
+
+
 5. The kvm_run structure
 ------------------------
 
diff --git a/arch/powerpc/include/asm/kvm_host.h b/arch/powerpc/include/asm/kvm_host.h
index af326cd..a23f132 100644
--- a/arch/powerpc/include/asm/kvm_host.h
+++ b/arch/powerpc/include/asm/kvm_host.h
@@ -30,6 +30,7 @@
 #include <linux/kvm_para.h>
 #include <linux/list.h>
 #include <linux/atomic.h>
+#include <linux/tracepoint.h>
 #include <asm/kvm_asm.h>
 #include <asm/processor.h>
 #include <asm/page.h>
@@ -609,6 +610,14 @@ struct kvm_vcpu_arch {
 	spinlock_t tbacct_lock;
 	u64 busy_stolen;
 	u64 busy_preempt;
+
+	unsigned long *tce_tmp_hpas;	/* TCE cache for TCE_PUT_INDIRECT */
+	enum {
+		TCERM_NONE,
+		TCERM_GETPAGE,
+		TCERM_PUTTCE,
+		TCERM_PUTLIST,
+	} tce_rm_fail;			/* failed stage of request processing */
 #endif
 };
 
diff --git a/arch/powerpc/include/asm/kvm_ppc.h b/arch/powerpc/include/asm/kvm_ppc.h
index a5287fe..0ce4691 100644
--- a/arch/powerpc/include/asm/kvm_ppc.h
+++ b/arch/powerpc/include/asm/kvm_ppc.h
@@ -133,8 +133,20 @@ extern int kvmppc_pseries_do_hcall(struct kvm_vcpu *vcpu);
 
 extern long kvm_vm_ioctl_create_spapr_tce(struct kvm *kvm,
 				struct kvm_create_spapr_tce *args);
-extern long kvmppc_h_put_tce(struct kvm_vcpu *vcpu, unsigned long liobn,
-			     unsigned long ioba, unsigned long tce);
+extern struct kvmppc_spapr_tce_table *kvmppc_find_tce_table(
+		struct kvm_vcpu *vcpu, unsigned long liobn);
+extern long kvmppc_tce_validate(unsigned long tce);
+extern void kvmppc_tce_put(struct kvmppc_spapr_tce_table *tt,
+		unsigned long ioba, unsigned long tce);
+extern long kvmppc_h_put_tce(struct kvm_vcpu *vcpu,
+		unsigned long liobn, unsigned long ioba,
+		unsigned long tce);
+extern long kvmppc_h_put_tce_indirect(struct kvm_vcpu *vcpu,
+		unsigned long liobn, unsigned long ioba,
+		unsigned long tce_list, unsigned long npages);
+extern long kvmppc_h_stuff_tce(struct kvm_vcpu *vcpu,
+		unsigned long liobn, unsigned long ioba,
+		unsigned long tce_value, unsigned long npages);
 extern long kvm_vm_ioctl_allocate_rma(struct kvm *kvm,
 				struct kvm_allocate_rma *rma);
 extern struct kvmppc_linear_info *kvm_alloc_rma(void);
diff --git a/arch/powerpc/kvm/book3s_64_vio.c b/arch/powerpc/kvm/book3s_64_vio.c
index b2d3f3b..cae1099 100644
--- a/arch/powerpc/kvm/book3s_64_vio.c
+++ b/arch/powerpc/kvm/book3s_64_vio.c
@@ -14,6 +14,7 @@
  *
  * Copyright 2010 Paul Mackerras, IBM Corp. <paulus@au1.ibm.com>
  * Copyright 2011 David Gibson, IBM Corporation <dwg@au1.ibm.com>
+ * Copyright 2013 Alexey Kardashevskiy, IBM Corporation <aik@au1.ibm.com>
  */
 
 #include <linux/types.h>
@@ -36,8 +37,10 @@
 #include <asm/ppc-opcode.h>
 #include <asm/kvm_host.h>
 #include <asm/udbg.h>
+#include <asm/iommu.h>
+#include <asm/tce.h>
 
-#define TCES_PER_PAGE	(PAGE_SIZE / sizeof(u64))
+#define ERROR_ADDR      ((void *)~(unsigned long)0x0)
 
 static long kvmppc_stt_npages(unsigned long window_size)
 {
@@ -148,3 +151,130 @@ fail:
 	}
 	return ret;
 }
+
+/* Converts guest physical address to host virtual address */
+static void __user *kvmppc_gpa_to_hva_and_get(struct kvm_vcpu *vcpu,
+		unsigned long gpa, struct page **pg)
+{
+	unsigned long hva, gfn = gpa >> PAGE_SHIFT;
+	struct kvm_memory_slot *memslot;
+	const int is_write = 0;
+
+	memslot = search_memslots(kvm_memslots(vcpu->kvm), gfn);
+	if (!memslot)
+		return ERROR_ADDR;
+
+	hva = __gfn_to_hva_memslot(memslot, gfn) | (gpa & ~PAGE_MASK);
+
+	if (get_user_pages_fast(hva & PAGE_MASK, 1, is_write, pg) != 1)
+		return ERROR_ADDR;
+
+	return (void *) hva;
+}
+
+long kvmppc_h_put_tce(struct kvm_vcpu *vcpu,
+		unsigned long liobn, unsigned long ioba,
+		unsigned long tce)
+{
+	long ret;
+	struct kvmppc_spapr_tce_table *tt;
+
+	tt = kvmppc_find_tce_table(vcpu, liobn);
+	if (!tt)
+		return H_TOO_HARD;
+
+	if (ioba >= tt->window_size)
+		return H_PARAMETER;
+
+	ret = kvmppc_tce_validate(tce);
+	if (ret)
+		return ret;
+
+	kvmppc_tce_put(tt, ioba, tce);
+
+	return H_SUCCESS;
+}
+
+long kvmppc_h_put_tce_indirect(struct kvm_vcpu *vcpu,
+		unsigned long liobn, unsigned long ioba,
+		unsigned long tce_list, unsigned long npages)
+{
+	struct kvmppc_spapr_tce_table *tt;
+	long i, ret = H_SUCCESS;
+	unsigned long __user *tces;
+	struct page *pg = NULL;
+
+	tt = kvmppc_find_tce_table(vcpu, liobn);
+	if (!tt)
+		return H_TOO_HARD;
+
+	/*
+	 * The spec says that the maximum size of the list is 512 TCEs
+	 * so the whole table addressed resides in 4K page
+	 */
+	if (npages > 512)
+		return H_PARAMETER;
+
+	if (tce_list & ~IOMMU_PAGE_MASK)
+		return H_PARAMETER;
+
+	if ((ioba + (npages << IOMMU_PAGE_SHIFT)) > tt->window_size)
+		return H_PARAMETER;
+
+	tces = kvmppc_gpa_to_hva_and_get(vcpu, tce_list, &pg);
+	if (tces == ERROR_ADDR)
+		return H_TOO_HARD;
+
+	if (vcpu->arch.tce_rm_fail == TCERM_PUTLIST)
+		goto put_list_page_exit;
+
+	for (i = 0; i < npages; ++i) {
+		if (get_user(vcpu->arch.tce_tmp_hpas[i], tces + i)) {
+			ret = H_PARAMETER;
+			goto put_list_page_exit;
+		}
+
+		ret = kvmppc_tce_validate(vcpu->arch.tce_tmp_hpas[i]);
+		if (ret)
+			goto put_list_page_exit;
+	}
+
+	for (i = 0; i < npages; ++i)
+		kvmppc_tce_put(tt, ioba + (i << IOMMU_PAGE_SHIFT),
+				vcpu->arch.tce_tmp_hpas[i]);
+put_list_page_exit:
+	if (pg) {
+		put_page(pg);
+		if (vcpu->arch.tce_rm_fail != TCERM_NONE) {
+			vcpu->arch.tce_rm_fail = TCERM_NONE;
+			/* Finish pending put_page() from realmode */
+			put_page(pg);
+		}
+	}
+
+	return ret;
+}
+
+long kvmppc_h_stuff_tce(struct kvm_vcpu *vcpu,
+		unsigned long liobn, unsigned long ioba,
+		unsigned long tce_value, unsigned long npages)
+{
+	struct kvmppc_spapr_tce_table *tt;
+	long i, ret;
+
+	tt = kvmppc_find_tce_table(vcpu, liobn);
+	if (!tt)
+		return H_TOO_HARD;
+
+	if ((ioba + (npages << IOMMU_PAGE_SHIFT)) > tt->window_size)
+		return H_PARAMETER;
+
+	ret = kvmppc_tce_validate(tce_value);
+	if (ret || (tce_value & (TCE_PCI_WRITE | TCE_PCI_READ)))
+		return H_PARAMETER;
+
+	for (i = 0; i < npages; ++i, ioba += IOMMU_PAGE_SIZE)
+		kvmppc_tce_put(tt, ioba, tce_value);
+
+	return H_SUCCESS;
+}
diff --git a/arch/powerpc/kvm/book3s_64_vio_hv.c b/arch/powerpc/kvm/book3s_64_vio_hv.c
index 30c2f3b..2b2ce0a 100644
--- a/arch/powerpc/kvm/book3s_64_vio_hv.c
+++ b/arch/powerpc/kvm/book3s_64_vio_hv.c
@@ -14,6 +14,7 @@
  *
  * Copyright 2010 Paul Mackerras, IBM Corp. <paulus@au1.ibm.com>
  * Copyright 2011 David Gibson, IBM Corporation <dwg@au1.ibm.com>
+ * Copyright 2013 Alexey Kardashevskiy, IBM Corporation <aik@au1.ibm.com>
  */
 
 #include <linux/types.h>
@@ -35,42 +36,253 @@
 #include <asm/ppc-opcode.h>
 #include <asm/kvm_host.h>
 #include <asm/udbg.h>
+#include <asm/iommu.h>
+#include <asm/tce.h>
 
 #define TCES_PER_PAGE	(PAGE_SIZE / sizeof(u64))
+#define ERROR_ADDR      (~(unsigned long)0x0)
 
-/* WARNING: This will be called in real-mode on HV KVM and virtual
+/* Finds a TCE table descriptor by LIOBN.
+ *
+ * WARNING: This will be called in real or virtual mode on HV KVM and virtual
  *          mode on PR KVM
  */
-long kvmppc_h_put_tce(struct kvm_vcpu *vcpu, unsigned long liobn,
+struct kvmppc_spapr_tce_table *kvmppc_find_tce_table(struct kvm_vcpu *vcpu,
+		unsigned long liobn)
+{
+	struct kvmppc_spapr_tce_table *tt;
+
+	list_for_each_entry(tt, &vcpu->kvm->arch.spapr_tce_tables, list) {
+		if (tt->liobn == liobn)
+			return tt;
+	}
+
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(kvmppc_find_tce_table);
+
+/*
+ * Validates TCE address.
+ * At the moment only flags are validated.
+ * As the host kernel does not access those addresses (just puts them
+ * to the table and user space is supposed to process them), we can skip
+ * checking other things (such as TCE is a guest RAM address or the page
+ * was actually allocated).
+ *
+ * WARNING: This will be called in real-mode on HV KVM and virtual
+ *          mode on PR KVM
+ */
+long kvmppc_tce_validate(unsigned long tce)
+{
+	if (tce & ~(IOMMU_PAGE_MASK | TCE_PCI_WRITE | TCE_PCI_READ))
+		return H_PARAMETER;
+
+	return H_SUCCESS;
+}
+EXPORT_SYMBOL_GPL(kvmppc_tce_validate);
+
+/* Note on the use of page_address() in real mode,
+ *
+ * It is safe to use page_address() in real mode on ppc64 because
+ * page_address() is always defined as lowmem_page_address()
+ * which returns __va(PFN_PHYS(page_to_pfn(page))) which is arithmetial
+ * operation and does not access page struct.
+ *
+ * Theoretically page_address() could be defined different
+ * but either WANT_PAGE_VIRTUAL or HASHED_PAGE_VIRTUAL
+ * should be enabled.
+ * WANT_PAGE_VIRTUAL is never enabled on ppc32/ppc64,
+ * HASHED_PAGE_VIRTUAL could be enabled for ppc32 only and only
+ * if CONFIG_HIGHMEM is defined. As CONFIG_SPARSEMEM_VMEMMAP
+ * is not expected to be enabled on ppc32, page_address()
+ * is safe for ppc32 as well.
+ *
+ * WARNING: This will be called in real-mode on HV KVM and virtual
+ *          mode on PR KVM
+ */
+static u64 *kvmppc_page_address(struct page *page)
+{
+#if defined(HASHED_PAGE_VIRTUAL) || defined(WANT_PAGE_VIRTUAL)
+#error TODO: fix to avoid page_address() here
+#endif
+	return (u64 *) page_address(page);
+}
+
+/*
+ * Handles TCE requests for emulated devices.
+ * Puts guest TCE values to the table and expects user space to convert them.
+ * Called in both real and virtual modes.
+ * Cannot fail so kvmppc_tce_validate must be called before it.
+ *
+ * WARNING: This will be called in real-mode on HV KVM and virtual
+ *          mode on PR KVM
+ */
+void kvmppc_tce_put(struct kvmppc_spapr_tce_table *tt,
+		unsigned long ioba, unsigned long tce)
+{
+	unsigned long idx = ioba >> SPAPR_TCE_SHIFT;
+	struct page *page;
+	u64 *tbl;
+
+	page = tt->pages[idx / TCES_PER_PAGE];
+	tbl = kvmppc_page_address(page);
+
+	tbl[idx % TCES_PER_PAGE] = tce;
+}
+EXPORT_SYMBOL_GPL(kvmppc_tce_put);
+
+#ifdef CONFIG_KVM_BOOK3S_64_HV
+/*
+ * Converts guest physical address to host physical address.
+ * Tries to increase page counter via get_page_unless_zero() and
+ * returns ERROR_ADDR if failed.
+ */
+static unsigned long kvmppc_rm_gpa_to_hpa_and_get(struct kvm_vcpu *vcpu,
+		unsigned long gpa, struct page **pg)
+{
+	struct kvm_memory_slot *memslot;
+	pte_t *ptep, pte;
+	unsigned long hva, hpa = ERROR_ADDR;
+	unsigned long gfn = gpa >> PAGE_SHIFT;
+	unsigned shift = 0;
+
+	memslot = search_memslots(kvm_memslots(vcpu->kvm), gfn);
+	if (!memslot)
+		return ERROR_ADDR;
+
+	hva = __gfn_to_hva_memslot(memslot, gfn);
+
+	ptep = find_linux_pte_or_hugepte(vcpu->arch.pgdir, hva, &shift);
+	if (!ptep || !pte_present(*ptep))
+		return ERROR_ADDR;
+	pte = *ptep;
+
+	if (!shift)
+		shift = PAGE_SHIFT;
+
+	/* Avoid handling anything potentially complicated in realmode */
+	if (shift > PAGE_SHIFT)
+		return ERROR_ADDR;
+
+	if (((gpa & TCE_PCI_WRITE) || pte_write(pte)) && !pte_dirty(pte))
+		return ERROR_ADDR;
+
+	if (!pte_young(pte))
+		return ERROR_ADDR;
+
+	/* Increase page counter */
+	*pg = realmode_pfn_to_page(pte_pfn(pte));
+	if (!*pg || PageCompound(*pg) || !get_page_unless_zero(*pg))
+		return ERROR_ADDR;
+
+	hpa = (pte_pfn(pte) << PAGE_SHIFT) + (gpa & ((1 << shift) - 1));
+
+	/*
+	 * Page has gone since we got pte, safer to put
+	 * the request to virt mode
+	 */
+	if (unlikely(pte_val(pte) != pte_val(*ptep))) {
+		hpa = ERROR_ADDR;
+		/* Try drop the page, if failed, let virtmode do that */
+		if (put_page_unless_one(*pg))
+			*pg = NULL;
+	}
+
+	return hpa;
+}
+
+long kvmppc_rm_h_put_tce(struct kvm_vcpu *vcpu, unsigned long liobn,
 		      unsigned long ioba, unsigned long tce)
 {
-	struct kvm *kvm = vcpu->kvm;
-	struct kvmppc_spapr_tce_table *stt;
-
-	/* udbg_printf("H_PUT_TCE(): liobn=0x%lx ioba=0x%lx, tce=0x%lx\n", */
-	/* 	    liobn, ioba, tce); */
-
-	list_for_each_entry(stt, &kvm->arch.spapr_tce_tables, list) {
-		if (stt->liobn == liobn) {
-			unsigned long idx = ioba >> SPAPR_TCE_SHIFT;
-			struct page *page;
-			u64 *tbl;
-
-			/* udbg_printf("H_PUT_TCE: liobn 0x%lx => stt=%p  window_size=0x%x\n", */
-			/* 	    liobn, stt, stt->window_size); */
-			if (ioba >= stt->window_size)
-				return H_PARAMETER;
-
-			page = stt->pages[idx / TCES_PER_PAGE];
-			tbl = (u64 *)page_address(page);
-
-			/* FIXME: Need to validate the TCE itself */
-			/* udbg_printf("tce @ %p\n", &tbl[idx % TCES_PER_PAGE]); */
-			tbl[idx % TCES_PER_PAGE] = tce;
-			return H_SUCCESS;
-		}
+	long ret;
+	struct kvmppc_spapr_tce_table *tt;
+
+	tt = kvmppc_find_tce_table(vcpu, liobn);
+	if (!tt)
+		return H_TOO_HARD;
+
+	if (ioba >= tt->window_size)
+		return H_PARAMETER;
+
+	ret = kvmppc_tce_validate(tce);
+	if (!ret)
+		kvmppc_tce_put(tt, ioba, tce);
+
+	return ret;
+}
+
+long kvmppc_rm_h_put_tce_indirect(struct kvm_vcpu *vcpu,
+		unsigned long liobn, unsigned long ioba,
+		unsigned long tce_list,	unsigned long npages)
+{
+	struct kvmppc_spapr_tce_table *tt;
+	long i, ret = H_SUCCESS;
+	unsigned long tces;
+	struct page *pg = NULL;
+
+	tt = kvmppc_find_tce_table(vcpu, liobn);
+	if (!tt)
+		return H_TOO_HARD;
+
+	/*
+	 * The spec says that the maximum size of the list is 512 TCEs
+	 * so the whole table addressed resides in 4K page
+	 */
+	if (npages > 512)
+		return H_PARAMETER;
+
+	if (tce_list & ~IOMMU_PAGE_MASK)
+		return H_PARAMETER;
+
+	if ((ioba + (npages << IOMMU_PAGE_SHIFT)) > tt->window_size)
+		return H_PARAMETER;
+
+	tces = kvmppc_rm_gpa_to_hpa_and_get(vcpu, tce_list, &pg);
+	if (tces == ERROR_ADDR) {
+		ret = H_TOO_HARD;
+		goto put_unlock_exit;
 	}
 
-	/* Didn't find the liobn, punt it to userspace */
-	return H_TOO_HARD;
+	for (i = 0; i < npages; ++i) {
+		ret = kvmppc_tce_validate(((unsigned long *)tces)[i]);
+		if (ret)
+			goto put_unlock_exit;
+	}
+
+	for (i = 0; i < npages; ++i)
+		kvmppc_tce_put(tt, ioba + (i << IOMMU_PAGE_SHIFT),
+				((unsigned long *)tces)[i]);
+
+put_unlock_exit:
+	if (!ret && pg && !put_page_unless_one(pg)) {
+		vcpu->arch.tce_rm_fail = TCERM_PUTLIST;
+		ret = H_TOO_HARD;
+	}
+
+	return ret;
+}
+
+long kvmppc_rm_h_stuff_tce(struct kvm_vcpu *vcpu,
+		unsigned long liobn, unsigned long ioba,
+		unsigned long tce_value, unsigned long npages)
+{
+	struct kvmppc_spapr_tce_table *tt;
+	long i, ret;
+
+	tt = kvmppc_find_tce_table(vcpu, liobn);
+	if (!tt)
+		return H_TOO_HARD;
+
+	if ((ioba + (npages << IOMMU_PAGE_SHIFT)) > tt->window_size)
+		return H_PARAMETER;
+
+	ret = kvmppc_tce_validate(tce_value);
+	if (ret || (tce_value & (TCE_PCI_WRITE | TCE_PCI_READ)))
+		return H_PARAMETER;
+
+	for (i = 0; i < npages; ++i, ioba += IOMMU_PAGE_SIZE)
+		kvmppc_tce_put(tt, ioba, tce_value);
+
+	return H_SUCCESS;
 }
+#endif /* CONFIG_KVM_BOOK3S_64_HV */
diff --git a/arch/powerpc/kvm/book3s_hv.c b/arch/powerpc/kvm/book3s_hv.c
index 7629cd3..9e823ad 100644
--- a/arch/powerpc/kvm/book3s_hv.c
+++ b/arch/powerpc/kvm/book3s_hv.c
@@ -567,7 +567,31 @@ int kvmppc_pseries_do_hcall(struct kvm_vcpu *vcpu)
 		if (kvmppc_xics_enabled(vcpu)) {
 			ret = kvmppc_xics_hcall(vcpu, req);
 			break;
-		} /* fallthrough */
+		}
+		return RESUME_HOST;
+	case H_PUT_TCE:
+		ret = kvmppc_h_put_tce(vcpu, kvmppc_get_gpr(vcpu, 4),
+						kvmppc_get_gpr(vcpu, 5),
+						kvmppc_get_gpr(vcpu, 6));
+		if (ret == H_TOO_HARD)
+			return RESUME_HOST;
+		break;
+	case H_PUT_TCE_INDIRECT:
+		ret = kvmppc_h_put_tce_indirect(vcpu, kvmppc_get_gpr(vcpu, 4),
+						kvmppc_get_gpr(vcpu, 5),
+						kvmppc_get_gpr(vcpu, 6),
+						kvmppc_get_gpr(vcpu, 7));
+		if (ret == H_TOO_HARD)
+			return RESUME_HOST;
+		break;
+	case H_STUFF_TCE:
+		ret = kvmppc_h_stuff_tce(vcpu, kvmppc_get_gpr(vcpu, 4),
+						kvmppc_get_gpr(vcpu, 5),
+						kvmppc_get_gpr(vcpu, 6),
+						kvmppc_get_gpr(vcpu, 7));
+		if (ret == H_TOO_HARD)
+			return RESUME_HOST;
+		break;
 	default:
 		return RESUME_HOST;
 	}
@@ -958,6 +982,20 @@ struct kvm_vcpu *kvmppc_core_vcpu_create(struct kvm *kvm, unsigned int id)
 	vcpu->arch.cpu_type = KVM_CPU_3S_64;
 	kvmppc_sanity_check(vcpu);
 
+	/*
+	 * As we want to minimize the chance of having H_PUT_TCE_INDIRECT
+	 * half executed, we first read TCEs from the user, check them and
+	 * return error if something went wrong and only then put TCEs into
+	 * the TCE table.
+	 *
+	 * tce_tmp_hpas is a cache for TCEs to avoid stack allocation or
+	 * kmalloc as the whole TCE list can take up to 512 items 8 bytes
+	 * each (4096 bytes).
+	 */
+	vcpu->arch.tce_tmp_hpas = kmalloc(4096, GFP_KERNEL);
+	if (!vcpu->arch.tce_tmp_hpas)
+		goto free_vcpu;
+
 	return vcpu;
 
 free_vcpu:
@@ -980,6 +1018,7 @@ void kvmppc_core_vcpu_free(struct kvm_vcpu *vcpu)
 	unpin_vpa(vcpu->kvm, &vcpu->arch.slb_shadow);
 	unpin_vpa(vcpu->kvm, &vcpu->arch.vpa);
 	spin_unlock(&vcpu->arch.vpa_update_lock);
+	kfree(vcpu->arch.tce_tmp_hpas);
 	kvm_vcpu_uninit(vcpu);
 	kmem_cache_free(kvm_vcpu_cache, vcpu);
 }
diff --git a/arch/powerpc/kvm/book3s_hv_rmhandlers.S b/arch/powerpc/kvm/book3s_hv_rmhandlers.S
index b02f91e..15942bc 100644
--- a/arch/powerpc/kvm/book3s_hv_rmhandlers.S
+++ b/arch/powerpc/kvm/book3s_hv_rmhandlers.S
@@ -1416,7 +1416,7 @@ hcall_real_table:
 	.long	0		/* 0x14 - H_CLEAR_REF */
 	.long	.kvmppc_h_protect - hcall_real_table
 	.long	0		/* 0x1c - H_GET_TCE */
-	.long	.kvmppc_h_put_tce - hcall_real_table
+	.long	.kvmppc_rm_h_put_tce - hcall_real_table
 	.long	0		/* 0x24 - H_SET_SPRG0 */
 	.long	.kvmppc_h_set_dabr - hcall_real_table
 	.long	0		/* 0x2c */
@@ -1490,6 +1490,12 @@ hcall_real_table:
 	.long	0		/* 0x11c */
 	.long	0		/* 0x120 */
 	.long	.kvmppc_h_bulk_remove - hcall_real_table
+	.long	0		/* 0x128 */
+	.long	0		/* 0x12c */
+	.long	0		/* 0x130 */
+	.long	0		/* 0x134 */
+	.long	.kvmppc_rm_h_stuff_tce - hcall_real_table
+	.long	.kvmppc_rm_h_put_tce_indirect - hcall_real_table
 hcall_real_table_end:
 
 ignore_hdec:
diff --git a/arch/powerpc/kvm/book3s_pr_papr.c b/arch/powerpc/kvm/book3s_pr_papr.c
index da0e0bc..6bd0d4a 100644
--- a/arch/powerpc/kvm/book3s_pr_papr.c
+++ b/arch/powerpc/kvm/book3s_pr_papr.c
@@ -227,6 +227,37 @@ static int kvmppc_h_pr_put_tce(struct kvm_vcpu *vcpu)
 	return EMULATE_DONE;
 }
 
+static int kvmppc_h_pr_put_tce_indirect(struct kvm_vcpu *vcpu)
+{
+	unsigned long liobn = kvmppc_get_gpr(vcpu, 4);
+	unsigned long ioba = kvmppc_get_gpr(vcpu, 5);
+	unsigned long tce = kvmppc_get_gpr(vcpu, 6);
+	unsigned long npages = kvmppc_get_gpr(vcpu, 7);
+	long rc;
+
+	rc = kvmppc_h_put_tce_indirect(vcpu, liobn, ioba,
+			tce, npages);
+	if (rc == H_TOO_HARD)
+		return EMULATE_FAIL;
+	kvmppc_set_gpr(vcpu, 3, rc);
+	return EMULATE_DONE;
+}
+
+static int kvmppc_h_pr_stuff_tce(struct kvm_vcpu *vcpu)
+{
+	unsigned long liobn = kvmppc_get_gpr(vcpu, 4);
+	unsigned long ioba = kvmppc_get_gpr(vcpu, 5);
+	unsigned long tce_value = kvmppc_get_gpr(vcpu, 6);
+	unsigned long npages = kvmppc_get_gpr(vcpu, 7);
+	long rc;
+
+	rc = kvmppc_h_stuff_tce(vcpu, liobn, ioba, tce_value, npages);
+	if (rc == H_TOO_HARD)
+		return EMULATE_FAIL;
+	kvmppc_set_gpr(vcpu, 3, rc);
+	return EMULATE_DONE;
+}
+
 static int kvmppc_h_pr_xics_hcall(struct kvm_vcpu *vcpu, u32 cmd)
 {
 	long rc = kvmppc_xics_hcall(vcpu, cmd);
@@ -247,6 +278,10 @@ int kvmppc_h_pr(struct kvm_vcpu *vcpu, unsigned long cmd)
 		return kvmppc_h_pr_bulk_remove(vcpu);
 	case H_PUT_TCE:
 		return kvmppc_h_pr_put_tce(vcpu);
+	case H_PUT_TCE_INDIRECT:
+		return kvmppc_h_pr_put_tce_indirect(vcpu);
+	case H_STUFF_TCE:
+		return kvmppc_h_pr_stuff_tce(vcpu);
 	case H_CEDE:
 		vcpu->arch.shared->msr |= MSR_EE;
 		kvm_vcpu_block(vcpu);
diff --git a/arch/powerpc/kvm/powerpc.c b/arch/powerpc/kvm/powerpc.c
index 6316ee3..ccb578b 100644
--- a/arch/powerpc/kvm/powerpc.c
+++ b/arch/powerpc/kvm/powerpc.c
@@ -394,6 +394,9 @@ int kvm_dev_ioctl_check_extension(long ext)
 	case KVM_CAP_PPC_GET_SMMU_INFO:
 		r = 1;
 		break;
+	case KVM_CAP_SPAPR_MULTITCE:
+		r = 1;
+		break;
 #endif
 	default:
 		r = 0;
-- 
1.8.4.rc4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
