Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id DF39782F66
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 19:29:21 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id u13so267038871uau.2
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 16:29:21 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0083.outbound.protection.outlook.com. [104.47.38.83])
        by mx.google.com with ESMTPS id m20si332184qke.275.2016.08.22.16.29.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 22 Aug 2016 16:29:06 -0700 (PDT)
Subject: [RFC PATCH v1 24/28] KVM: SVM: add SEV_LAUNCH_FINISH command
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Mon, 22 Aug 2016 19:28:59 -0400
Message-ID: <147190853894.9523.16890031242057232592.stgit@brijesh-build-machine>
In-Reply-To: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, brijesh.singh@amd.com, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, linux-crypto@vger.kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

The command is used for finializing the guest launch into SEV mode.

For more information see [1], section 6.3

[1] http://support.amd.com/TechDocs/55766_SEV-KM%20API_Spec.pdf

Signed-off-by: Brijesh Singh <brijesh.singh@amd.com>
---
 arch/x86/kvm/svm.c |   78 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 78 insertions(+)

diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
index c78bdc6..60cc0f7 100644
--- a/arch/x86/kvm/svm.c
+++ b/arch/x86/kvm/svm.c
@@ -5497,6 +5497,79 @@ err_1:
 	return ret;
 }
  
+static int sev_launch_finish(struct kvm *kvm,
+			     struct kvm_sev_launch_finish __user *argp,
+			     int *psp_ret)
+{
+	int i, ret;
+	void *mask = NULL;
+	int buffer_len, len;
+	struct kvm_vcpu *vcpu;
+	struct psp_data_launch_finish *finish;
+	struct kvm_sev_launch_finish params;
+
+	if (!kvm_sev_guest())
+		return -EINVAL;
+
+	/* Get the parameters from the user */
+	if (copy_from_user(&params, argp, sizeof(*argp)))
+		return -EFAULT;
+
+	buffer_len = sizeof(*finish) + (sizeof(u64) * params.vcpu_count);
+	finish = kzalloc(buffer_len, GFP_KERNEL);
+	if (!finish)
+		return -ENOMEM;
+
+	/* copy the vcpu mask from user */
+	if (params.vcpu_mask_length && params.vcpu_mask_addr) {
+		ret = -ENOMEM;
+		mask = (void *) get_zeroed_page(GFP_KERNEL);
+		if (!mask)
+			goto err_1;
+
+		len = min_t(size_t, PAGE_SIZE, params.vcpu_mask_length);
+		ret = -EFAULT;
+		if (copy_from_user(mask, (uint8_t*)params.vcpu_mask_addr, len))
+			goto err_2;
+		finish->vcpus.state_mask_addr = __psp_pa(mask);
+	}
+
+	finish->handle = kvm_sev_handle();
+	finish->hdr.buffer_len = buffer_len;
+	finish->vcpus.state_count = params.vcpu_count;
+	finish->vcpus.state_length = params.vcpu_length;
+	kvm_for_each_vcpu(i, vcpu, kvm) {
+		finish->vcpus.state_addr[i] =
+					to_svm(vcpu)->vmcb_pa | sme_me_mask;
+		if (i == params.vcpu_count)
+			break;
+	}
+
+	/* launch finish */
+	ret = psp_guest_launch_finish(finish, psp_ret);
+	if (ret) {
+		printk(KERN_ERR "SEV: LAUNCH_FINISH ret=%d (%#010x)\n",
+			ret, *psp_ret);
+		goto err_2;
+	}
+
+	/* Iterate through each vcpus and set SEV KVM_SEV_FEATURE bit in
+	 * KVM_CPUID_FEATURE to indicate that SEV is enabled on this vcpu
+	 */
+	kvm_for_each_vcpu(i, vcpu, kvm)
+		svm_cpuid_update(vcpu);
+
+	/* copy the measurement for user */
+	if (copy_to_user(argp->measurement, finish->measurement, 32))
+		ret = -EFAULT;
+
+err_2:
+	free_page((unsigned long)mask);
+err_1:
+	kfree(finish);
+	return ret;
+}
+
 static int amd_sev_issue_cmd(struct kvm *kvm,
 			     struct kvm_sev_issue_cmd __user *user_data)
 {
@@ -5517,6 +5590,11 @@ static int amd_sev_issue_cmd(struct kvm *kvm,
 					&arg.ret_code);
 		break;
 	}
+	case KVM_SEV_LAUNCH_FINISH: {
+		r = sev_launch_finish(kvm, (void *)arg.opaque,
+					&arg.ret_code);
+		break;
+	}
 	default:
 		break;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
