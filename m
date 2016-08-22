Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id B69C882F66
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 19:27:22 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id e63so1154372ith.1
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 16:27:22 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0078.outbound.protection.outlook.com. [104.47.41.78])
        by mx.google.com with ESMTPS id l8si159787oib.67.2016.08.22.16.27.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 22 Aug 2016 16:27:22 -0700 (PDT)
Subject: [RFC PATCH v1 17/28] KVM: SVM: Enable SEV by setting the SEV_ENABLE
 cpu feature
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Mon, 22 Aug 2016 19:27:07 -0400
Message-ID: <147190842748.9523.5605997278361096963.stgit@brijesh-build-machine>
In-Reply-To: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, brijesh.singh@amd.com, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, linux-crypto@vger.kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

From: Tom Lendacky <thomas.lendacky@amd.com>

Modify the SVM cpuid update function to indicate if Secure Encrypted
Virtualization (SEV) is active by setting the SEV KVM cpu features bit
if SEV is active.  SEV is active if Secure Memory Encryption is active
in the host and the SEV_ENABLE bit of the VMCB is set.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/kvm/cpuid.c |    4 +++-
 arch/x86/kvm/svm.c   |   18 ++++++++++++++++++
 2 files changed, 21 insertions(+), 1 deletion(-)

diff --git a/arch/x86/kvm/cpuid.c b/arch/x86/kvm/cpuid.c
index 3235e0f..d34faea 100644
--- a/arch/x86/kvm/cpuid.c
+++ b/arch/x86/kvm/cpuid.c
@@ -583,7 +583,7 @@ static inline int __do_cpuid_ent(struct kvm_cpuid_entry2 *entry, u32 function,
 		entry->edx = 0;
 		break;
 	case 0x80000000:
-		entry->eax = min(entry->eax, 0x8000001a);
+		entry->eax = min(entry->eax, 0x8000001f);
 		break;
 	case 0x80000001:
 		entry->edx &= kvm_cpuid_8000_0001_edx_x86_features;
@@ -616,6 +616,8 @@ static inline int __do_cpuid_ent(struct kvm_cpuid_entry2 *entry, u32 function,
 		break;
 	case 0x8000001d:
 		break;
+	case 0x8000001f:
+		break;
 	/*Add support for Centaur's CPUID instruction*/
 	case 0xC0000000:
 		/*Just support up to 0xC0000004 now*/
diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
index 9b59260..211be94 100644
--- a/arch/x86/kvm/svm.c
+++ b/arch/x86/kvm/svm.c
@@ -43,6 +43,7 @@
 #include <asm/kvm_para.h>
 
 #include <asm/virtext.h>
+#include <asm/mem_encrypt.h>
 #include "trace.h"
 
 #define __ex(x) __kvm_handle_fault_on_reboot(x)
@@ -4677,10 +4678,27 @@ static void svm_cpuid_update(struct kvm_vcpu *vcpu)
 {
 	struct vcpu_svm *svm = to_svm(vcpu);
 	struct kvm_cpuid_entry2 *entry;
+	struct vmcb_control_area *ca = &svm->vmcb->control;
+	struct kvm_cpuid_entry2 *features, *sev_info;
 
 	/* Update nrips enabled cache */
 	svm->nrips_enabled = !!guest_cpuid_has_nrips(&svm->vcpu);
 
+	/* Check for Secure Encrypted Virtualization support */
+	features = kvm_find_cpuid_entry(vcpu, KVM_CPUID_FEATURES, 0);
+	if (!features)
+		return;
+
+	sev_info = kvm_find_cpuid_entry(vcpu, 0x8000001f, 0);
+	if (!sev_info)
+		return;
+
+	if (ca->nested_ctl & SVM_NESTED_CTL_SEV_ENABLE) {
+		features->eax |= (1 << KVM_FEATURE_SEV);
+		cpuid(0x8000001f, &sev_info->eax, &sev_info->ebx,
+		      &sev_info->ecx, &sev_info->edx);
+	}
+
 	if (!kvm_vcpu_apicv_active(vcpu))
 		return;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
