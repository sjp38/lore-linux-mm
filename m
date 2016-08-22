Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id DCE716B0268
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 19:23:51 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id e63so839068ith.1
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 16:23:51 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0063.outbound.protection.outlook.com. [104.47.38.63])
        by mx.google.com with ESMTPS id l28si142643otd.292.2016.08.22.16.23.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 22 Aug 2016 16:23:51 -0700 (PDT)
Subject: [RFC PATCH v1 01/28] kvm: svm: Add support for additional SVM NPF
 error codes
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Mon, 22 Aug 2016 19:23:44 -0400
Message-ID: <147190822443.9523.7814744422402462127.stgit@brijesh-build-machine>
In-Reply-To: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, brijesh.singh@amd.com, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, linux-crypto@vger.kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

From: Tom Lendacky <thomas.lendacky@amd.com>

AMD hardware adds two additional bits to aid in nested page fault handling.

Bit 32 - NPF occurred while translating the guest's final physical address
Bit 33 - NPF occurred while translating the guest page tables

The guest page tables fault indicator can be used as an aid for nested
virtualization. Using V0 for the host, V1 for the first level guest and
V2 for the second level guest, when both V1 and V2 are using nested paging
there are currently a number of unnecessary instruction emulations. When
V2 is launched shadow paging is used in V1 for the nested tables of V2. As
a result, KVM marks these pages as RO in the host nested page tables. When
V2 exits and we resume V1, these pages are still marked RO.

Every nested walk for a guest page table is treated as a user-level write
access and this causes a lot of NPFs because the V1 page tables are marked
RO in the V0 nested tables. While executing V1, when these NPFs occur KVM
sees a write to a read-only page, emulates the V1 instruction and unprotects
the page (marking it RW). This patch looks for cases where we get a NPF due
to a guest page table walk where the page was marked RO. It immediately
unprotects the page and resumes the guest, leading to far fewer instruction
emulations when nested virtualization is used.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/kvm_host.h |   11 ++++++++++-
 arch/x86/kvm/mmu.c              |   20 ++++++++++++++++++--
 arch/x86/kvm/svm.c              |    2 +-
 3 files changed, 29 insertions(+), 4 deletions(-)

diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index c51c1cb..3f05d36 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -191,6 +191,8 @@ enum {
 #define PFERR_RSVD_BIT 3
 #define PFERR_FETCH_BIT 4
 #define PFERR_PK_BIT 5
+#define PFERR_GUEST_FINAL_BIT 32
+#define PFERR_GUEST_PAGE_BIT 33
 
 #define PFERR_PRESENT_MASK (1U << PFERR_PRESENT_BIT)
 #define PFERR_WRITE_MASK (1U << PFERR_WRITE_BIT)
@@ -198,6 +200,13 @@ enum {
 #define PFERR_RSVD_MASK (1U << PFERR_RSVD_BIT)
 #define PFERR_FETCH_MASK (1U << PFERR_FETCH_BIT)
 #define PFERR_PK_MASK (1U << PFERR_PK_BIT)
+#define PFERR_GUEST_FINAL_MASK (1ULL << PFERR_GUEST_FINAL_BIT)
+#define PFERR_GUEST_PAGE_MASK (1ULL << PFERR_GUEST_PAGE_BIT)
+
+#define PFERR_NESTED_GUEST_PAGE (PFERR_GUEST_PAGE_MASK |	\
+				 PFERR_USER_MASK |		\
+				 PFERR_WRITE_MASK |		\
+				 PFERR_PRESENT_MASK)
 
 /* apic attention bits */
 #define KVM_APIC_CHECK_VAPIC	0
@@ -1203,7 +1212,7 @@ void kvm_vcpu_deactivate_apicv(struct kvm_vcpu *vcpu);
 
 int kvm_emulate_hypercall(struct kvm_vcpu *vcpu);
 
-int kvm_mmu_page_fault(struct kvm_vcpu *vcpu, gva_t gva, u32 error_code,
+int kvm_mmu_page_fault(struct kvm_vcpu *vcpu, gva_t gva, u64 error_code,
 		       void *insn, int insn_len);
 void kvm_mmu_invlpg(struct kvm_vcpu *vcpu, gva_t gva);
 void kvm_mmu_new_cr3(struct kvm_vcpu *vcpu);
diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index a7040f4..3b47a5d 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -4512,7 +4512,7 @@ static void make_mmu_pages_available(struct kvm_vcpu *vcpu)
 	kvm_mmu_commit_zap_page(vcpu->kvm, &invalid_list);
 }
 
-int kvm_mmu_page_fault(struct kvm_vcpu *vcpu, gva_t cr2, u32 error_code,
+int kvm_mmu_page_fault(struct kvm_vcpu *vcpu, gva_t cr2, u64 error_code,
 		       void *insn, int insn_len)
 {
 	int r, emulation_type = EMULTYPE_RETRY;
@@ -4531,12 +4531,28 @@ int kvm_mmu_page_fault(struct kvm_vcpu *vcpu, gva_t cr2, u32 error_code,
 			return r;
 	}
 
-	r = vcpu->arch.mmu.page_fault(vcpu, cr2, error_code, false);
+	r = vcpu->arch.mmu.page_fault(vcpu, cr2, lower_32_bits(error_code),
+				      false);
 	if (r < 0)
 		return r;
 	if (!r)
 		return 1;
 
+	/*
+	 * Before emulating the instruction, check if the error code
+	 * was due to a RO violation while translating the guest page.
+	 * This can occur when using nested virtualization with nested
+	 * paging in both guests. If true, we simply unprotect the page
+	 * and resume the guest.
+	 *
+	 * Note: AMD only (since it supports the PFERR_GUEST_PAGE_MASK used
+	 *       in PFERR_NEXT_GUEST_PAGE)
+	 */
+	if (error_code == PFERR_NESTED_GUEST_PAGE) {
+		kvm_mmu_unprotect_page(vcpu->kvm, gpa_to_gfn(cr2));
+		return 1;
+	}
+
 	if (mmio_info_in_cache(vcpu, cr2, direct))
 		emulation_type = 0;
 emulate:
diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
index 1e6b84b..d8b9c8c 100644
--- a/arch/x86/kvm/svm.c
+++ b/arch/x86/kvm/svm.c
@@ -1935,7 +1935,7 @@ static void svm_set_dr7(struct kvm_vcpu *vcpu, unsigned long value)
 static int pf_interception(struct vcpu_svm *svm)
 {
 	u64 fault_address = svm->vmcb->control.exit_info_2;
-	u32 error_code;
+	u64 error_code;
 	int r = 1;
 
 	switch (svm->apf_reason) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
