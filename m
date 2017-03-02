Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 57B626B03A1
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 10:15:12 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id w185so68363523ita.5
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 07:15:12 -0800 (PST)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0083.outbound.protection.outlook.com. [104.47.32.83])
        by mx.google.com with ESMTPS id 130si16890825itj.52.2017.03.02.07.15.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 02 Mar 2017 07:15:11 -0800 (PST)
Subject: [RFC PATCH v2 13/32] KVM: SVM: Enable SEV by setting the SEV_ENABLE
 CPU feature
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Thu, 2 Mar 2017 10:15:01 -0500
Message-ID: <148846770159.2349.16863375000963463500.stgit@brijesh-build-machine>
In-Reply-To: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, brijesh.singh@amd.com, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

From: Tom Lendacky <thomas.lendacky@amd.com>

Modify the SVM cpuid update function to indicate if Secure Encrypted
Virtualization (SEV) is active in the guest by setting the SEV KVM CPU
features bit. SEV is active if Secure Memory Encryption is enabled in
the host and the SEV_ENABLE bit of the VMCB is set.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/kvm/cpuid.c |    4 +++-
 arch/x86/kvm/svm.c   |   18 ++++++++++++++++++
 2 files changed, 21 insertions(+), 1 deletion(-)

diff --git a/arch/x86/kvm/cpuid.c b/arch/x86/kvm/cpuid.c
index 1639de8..e0c40a8 100644
--- a/arch/x86/kvm/cpuid.c
+++ b/arch/x86/kvm/cpuid.c
@@ -601,7 +601,7 @@ static inline int __do_cpuid_ent(struct kvm_cpuid_entry2 *entry, u32 function,
 		entry->edx = 0;
 		break;
 	case 0x80000000:
-		entry->eax = min(entry->eax, 0x8000001a);
+		entry->eax = min(entry->eax, 0x8000001f);
 		break;
 	case 0x80000001:
 		entry->edx &= kvm_cpuid_8000_0001_edx_x86_features;
@@ -634,6 +634,8 @@ static inline int __do_cpuid_ent(struct kvm_cpuid_entry2 *entry, u32 function,
 		break;
 	case 0x8000001d:
 		break;
+	case 0x8000001f:
+		break;
 	/*Add support for Centaur's CPUID instruction*/
 	case 0xC0000000:
 		/*Just support up to 0xC0000004 now*/
diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
index 75b0645..36d61ff 100644
--- a/arch/x86/kvm/svm.c
+++ b/arch/x86/kvm/svm.c
@@ -46,6 +46,7 @@
 #include <asm/irq_remapping.h>
 
 #include <asm/virtext.h>
+#include <asm/mem_encrypt.h>
 #include "trace.h"
 
 #define __ex(x) __kvm_handle_fault_on_reboot(x)
@@ -5005,10 +5006,27 @@ static void svm_cpuid_update(struct kvm_vcpu *vcpu)
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
