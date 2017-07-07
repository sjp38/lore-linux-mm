Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0BF746B03BF
	for <linux-mm@kvack.org>; Fri,  7 Jul 2017 09:43:56 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id m84so50956307ita.15
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 06:43:56 -0700 (PDT)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0042.outbound.protection.outlook.com. [104.47.36.42])
        by mx.google.com with ESMTPS id h194si3376290ith.100.2017.07.07.06.43.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 07 Jul 2017 06:43:54 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v9 30/38] kvm: x86: svm: Support Secure Memory Encryption
 within KVM
Date: Fri, 07 Jul 2017 08:43:47 -0500
Message-ID: <20170707134346.29711.20203.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170707133804.29711.1616.stgit@tlendack-t1.amdoffice.net>
References: <20170707133804.29711.1616.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

Update the KVM support to work with SME. The VMCB has a number of fields
where physical addresses are used and these addresses must contain the
memory encryption mask in order to properly access the encrypted memory.
Also, use the memory encryption mask when creating and using the nested
page tables.

Reviewed-by: Borislav Petkov <bp@suse.de>
Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/kvm_host.h |    2 +-
 arch/x86/kvm/mmu.c              |   12 ++++++++----
 arch/x86/kvm/mmu.h              |    2 +-
 arch/x86/kvm/svm.c              |   35 ++++++++++++++++++-----------------
 arch/x86/kvm/vmx.c              |    3 ++-
 arch/x86/kvm/x86.c              |    3 ++-
 6 files changed, 32 insertions(+), 25 deletions(-)

diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index 695605e..6d1267f 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -1069,7 +1069,7 @@ struct kvm_arch_async_pf {
 void kvm_mmu_uninit_vm(struct kvm *kvm);
 void kvm_mmu_set_mask_ptes(u64 user_mask, u64 accessed_mask,
 		u64 dirty_mask, u64 nx_mask, u64 x_mask, u64 p_mask,
-		u64 acc_track_mask);
+		u64 acc_track_mask, u64 me_mask);
 
 void kvm_mmu_reset_context(struct kvm_vcpu *vcpu);
 void kvm_mmu_slot_remove_write_access(struct kvm *kvm,
diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index cb82259..e85888c 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -107,7 +107,7 @@ enum {
 	(((address) >> PT32_LEVEL_SHIFT(level)) & ((1 << PT32_LEVEL_BITS) - 1))
 
 
-#define PT64_BASE_ADDR_MASK (((1ULL << 52) - 1) & ~(u64)(PAGE_SIZE-1))
+#define PT64_BASE_ADDR_MASK __sme_clr((((1ULL << 52) - 1) & ~(u64)(PAGE_SIZE-1)))
 #define PT64_DIR_BASE_ADDR_MASK \
 	(PT64_BASE_ADDR_MASK & ~((1ULL << (PAGE_SHIFT + PT64_LEVEL_BITS)) - 1))
 #define PT64_LVL_ADDR_MASK(level) \
@@ -125,7 +125,7 @@ enum {
 					    * PT32_LEVEL_BITS))) - 1))
 
 #define PT64_PERM_MASK (PT_PRESENT_MASK | PT_WRITABLE_MASK | shadow_user_mask \
-			| shadow_x_mask | shadow_nx_mask)
+			| shadow_x_mask | shadow_nx_mask | shadow_me_mask)
 
 #define ACC_EXEC_MASK    1
 #define ACC_WRITE_MASK   PT_WRITABLE_MASK
@@ -184,6 +184,7 @@ struct kvm_shadow_walk_iterator {
 static u64 __read_mostly shadow_dirty_mask;
 static u64 __read_mostly shadow_mmio_mask;
 static u64 __read_mostly shadow_present_mask;
+static u64 __read_mostly shadow_me_mask;
 
 /*
  * The mask/value to distinguish a PTE that has been marked not-present for
@@ -317,7 +318,7 @@ static bool check_mmio_spte(struct kvm_vcpu *vcpu, u64 spte)
 
 void kvm_mmu_set_mask_ptes(u64 user_mask, u64 accessed_mask,
 		u64 dirty_mask, u64 nx_mask, u64 x_mask, u64 p_mask,
-		u64 acc_track_mask)
+		u64 acc_track_mask, u64 me_mask)
 {
 	if (acc_track_mask != 0)
 		acc_track_mask |= SPTE_SPECIAL_MASK;
@@ -330,6 +331,7 @@ void kvm_mmu_set_mask_ptes(u64 user_mask, u64 accessed_mask,
 	shadow_present_mask = p_mask;
 	shadow_acc_track_mask = acc_track_mask;
 	WARN_ON(shadow_accessed_mask != 0 && shadow_acc_track_mask != 0);
+	shadow_me_mask = me_mask;
 }
 EXPORT_SYMBOL_GPL(kvm_mmu_set_mask_ptes);
 
@@ -2398,7 +2400,8 @@ static void link_shadow_page(struct kvm_vcpu *vcpu, u64 *sptep,
 	BUILD_BUG_ON(VMX_EPT_WRITABLE_MASK != PT_WRITABLE_MASK);
 
 	spte = __pa(sp->spt) | shadow_present_mask | PT_WRITABLE_MASK |
-	       shadow_user_mask | shadow_x_mask | shadow_accessed_mask;
+	       shadow_user_mask | shadow_x_mask | shadow_accessed_mask |
+	       shadow_me_mask;
 
 	mmu_spte_set(sptep, spte);
 
@@ -2700,6 +2703,7 @@ static int set_spte(struct kvm_vcpu *vcpu, u64 *sptep,
 		pte_access &= ~ACC_WRITE_MASK;
 
 	spte |= (u64)pfn << PAGE_SHIFT;
+	spte |= shadow_me_mask;
 
 	if (pte_access & ACC_WRITE_MASK) {
 
diff --git a/arch/x86/kvm/mmu.h b/arch/x86/kvm/mmu.h
index 330bf3a..08b779d 100644
--- a/arch/x86/kvm/mmu.h
+++ b/arch/x86/kvm/mmu.h
@@ -48,7 +48,7 @@
 
 static inline u64 rsvd_bits(int s, int e)
 {
-	return ((1ULL << (e - s + 1)) - 1) << s;
+	return __sme_clr(((1ULL << (e - s + 1)) - 1) << s);
 }
 
 void kvm_mmu_set_mmio_spte_mask(u64 mmio_mask);
diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
index 33460fc..c2fcd31 100644
--- a/arch/x86/kvm/svm.c
+++ b/arch/x86/kvm/svm.c
@@ -1139,9 +1139,9 @@ static void avic_init_vmcb(struct vcpu_svm *svm)
 {
 	struct vmcb *vmcb = svm->vmcb;
 	struct kvm_arch *vm_data = &svm->vcpu.kvm->arch;
-	phys_addr_t bpa = page_to_phys(svm->avic_backing_page);
-	phys_addr_t lpa = page_to_phys(vm_data->avic_logical_id_table_page);
-	phys_addr_t ppa = page_to_phys(vm_data->avic_physical_id_table_page);
+	phys_addr_t bpa = __sme_set(page_to_phys(svm->avic_backing_page));
+	phys_addr_t lpa = __sme_set(page_to_phys(vm_data->avic_logical_id_table_page));
+	phys_addr_t ppa = __sme_set(page_to_phys(vm_data->avic_physical_id_table_page));
 
 	vmcb->control.avic_backing_page = bpa & AVIC_HPA_MASK;
 	vmcb->control.avic_logical_id = lpa & AVIC_HPA_MASK;
@@ -1204,8 +1204,8 @@ static void init_vmcb(struct vcpu_svm *svm)
 		set_intercept(svm, INTERCEPT_MWAIT);
 	}
 
-	control->iopm_base_pa = iopm_base;
-	control->msrpm_base_pa = __pa(svm->msrpm);
+	control->iopm_base_pa = __sme_set(iopm_base);
+	control->msrpm_base_pa = __sme_set(__pa(svm->msrpm));
 	control->int_ctl = V_INTR_MASKING_MASK;
 
 	init_seg(&save->es);
@@ -1339,9 +1339,9 @@ static int avic_init_backing_page(struct kvm_vcpu *vcpu)
 		return -EINVAL;
 
 	new_entry = READ_ONCE(*entry);
-	new_entry = (page_to_phys(svm->avic_backing_page) &
-		     AVIC_PHYSICAL_ID_ENTRY_BACKING_PAGE_MASK) |
-		     AVIC_PHYSICAL_ID_ENTRY_VALID_MASK;
+	new_entry = __sme_set((page_to_phys(svm->avic_backing_page) &
+			      AVIC_PHYSICAL_ID_ENTRY_BACKING_PAGE_MASK) |
+			      AVIC_PHYSICAL_ID_ENTRY_VALID_MASK);
 	WRITE_ONCE(*entry, new_entry);
 
 	svm->avic_physical_id_cache = entry;
@@ -1609,7 +1609,7 @@ static struct kvm_vcpu *svm_create_vcpu(struct kvm *kvm, unsigned int id)
 
 	svm->vmcb = page_address(page);
 	clear_page(svm->vmcb);
-	svm->vmcb_pa = page_to_pfn(page) << PAGE_SHIFT;
+	svm->vmcb_pa = __sme_set(page_to_pfn(page) << PAGE_SHIFT);
 	svm->asid_generation = 0;
 	init_vmcb(svm);
 
@@ -1637,7 +1637,7 @@ static void svm_free_vcpu(struct kvm_vcpu *vcpu)
 {
 	struct vcpu_svm *svm = to_svm(vcpu);
 
-	__free_page(pfn_to_page(svm->vmcb_pa >> PAGE_SHIFT));
+	__free_page(pfn_to_page(__sme_clr(svm->vmcb_pa) >> PAGE_SHIFT));
 	__free_pages(virt_to_page(svm->msrpm), MSRPM_ALLOC_ORDER);
 	__free_page(virt_to_page(svm->nested.hsave));
 	__free_pages(virt_to_page(svm->nested.msrpm), MSRPM_ALLOC_ORDER);
@@ -2304,7 +2304,7 @@ static u64 nested_svm_get_tdp_pdptr(struct kvm_vcpu *vcpu, int index)
 	u64 pdpte;
 	int ret;
 
-	ret = kvm_vcpu_read_guest_page(vcpu, gpa_to_gfn(cr3), &pdpte,
+	ret = kvm_vcpu_read_guest_page(vcpu, gpa_to_gfn(__sme_clr(cr3)), &pdpte,
 				       offset_in_page(cr3) + index * 8, 8);
 	if (ret)
 		return 0;
@@ -2316,7 +2316,7 @@ static void nested_svm_set_tdp_cr3(struct kvm_vcpu *vcpu,
 {
 	struct vcpu_svm *svm = to_svm(vcpu);
 
-	svm->vmcb->control.nested_cr3 = root;
+	svm->vmcb->control.nested_cr3 = __sme_set(root);
 	mark_dirty(svm->vmcb, VMCB_NPT);
 	svm_flush_tlb(vcpu);
 }
@@ -2804,7 +2804,7 @@ static bool nested_svm_vmrun_msrpm(struct vcpu_svm *svm)
 		svm->nested.msrpm[p] = svm->msrpm[p] | value;
 	}
 
-	svm->vmcb->control.msrpm_base_pa = __pa(svm->nested.msrpm);
+	svm->vmcb->control.msrpm_base_pa = __sme_set(__pa(svm->nested.msrpm));
 
 	return true;
 }
@@ -4436,7 +4436,7 @@ static int svm_ir_list_add(struct vcpu_svm *svm, struct amd_iommu_pi_data *pi)
 	pr_debug("SVM: %s: use GA mode for irq %u\n", __func__,
 		 irq.vector);
 	*svm = to_svm(vcpu);
-	vcpu_info->pi_desc_addr = page_to_phys((*svm)->avic_backing_page);
+	vcpu_info->pi_desc_addr = __sme_set(page_to_phys((*svm)->avic_backing_page));
 	vcpu_info->vector = irq.vector;
 
 	return 0;
@@ -4487,7 +4487,8 @@ static int svm_update_pi_irte(struct kvm *kvm, unsigned int host_irq,
 			struct amd_iommu_pi_data pi;
 
 			/* Try to enable guest_mode in IRTE */
-			pi.base = page_to_phys(svm->avic_backing_page) & AVIC_HPA_MASK;
+			pi.base = __sme_set(page_to_phys(svm->avic_backing_page) &
+					    AVIC_HPA_MASK);
 			pi.ga_tag = AVIC_GATAG(kvm->arch.avic_vm_id,
 						     svm->vcpu.vcpu_id);
 			pi.is_guest_mode = true;
@@ -4913,7 +4914,7 @@ static void svm_set_cr3(struct kvm_vcpu *vcpu, unsigned long root)
 {
 	struct vcpu_svm *svm = to_svm(vcpu);
 
-	svm->vmcb->save.cr3 = root;
+	svm->vmcb->save.cr3 = __sme_set(root);
 	mark_dirty(svm->vmcb, VMCB_CR);
 	svm_flush_tlb(vcpu);
 }
@@ -4922,7 +4923,7 @@ static void set_tdp_cr3(struct kvm_vcpu *vcpu, unsigned long root)
 {
 	struct vcpu_svm *svm = to_svm(vcpu);
 
-	svm->vmcb->control.nested_cr3 = root;
+	svm->vmcb->control.nested_cr3 = __sme_set(root);
 	mark_dirty(svm->vmcb, VMCB_NPT);
 
 	/* Also sync guest cr3 here in case we live migrate */
diff --git a/arch/x86/kvm/vmx.c b/arch/x86/kvm/vmx.c
index 6dcc487..a0db541 100644
--- a/arch/x86/kvm/vmx.c
+++ b/arch/x86/kvm/vmx.c
@@ -6453,7 +6453,8 @@ void vmx_enable_tdp(void)
 		enable_ept_ad_bits ? VMX_EPT_DIRTY_BIT : 0ull,
 		0ull, VMX_EPT_EXECUTABLE_MASK,
 		cpu_has_vmx_ept_execute_only() ? 0ull : VMX_EPT_READABLE_MASK,
-		enable_ept_ad_bits ? 0ull : VMX_EPT_RWX_MASK);
+		enable_ept_ad_bits ? 0ull : VMX_EPT_RWX_MASK,
+		0ull);
 
 	ept_set_mmio_spte_mask();
 	kvm_enable_tdp();
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 0e846f0..268fed5 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -54,6 +54,7 @@
 #include <linux/kvm_irqfd.h>
 #include <linux/irqbypass.h>
 #include <linux/sched/stat.h>
+#include <linux/mem_encrypt.h>
 
 #include <trace/events/kvm.h>
 
@@ -6097,7 +6098,7 @@ int kvm_arch_init(void *opaque)
 
 	kvm_mmu_set_mask_ptes(PT_USER_MASK, PT_ACCESSED_MASK,
 			PT_DIRTY_MASK, PT64_NX_MASK, 0,
-			PT_PRESENT_MASK, 0);
+			PT_PRESENT_MASK, 0, sme_me_mask);
 	kvm_timer_init();
 
 	perf_register_guest_info_callbacks(&kvm_guest_cbs);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
