Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6701382F66
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 19:29:22 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id i144so32368935oib.0
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 16:29:22 -0700 (PDT)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0040.outbound.protection.outlook.com. [104.47.37.40])
        by mx.google.com with ESMTPS id 49si171560otz.29.2016.08.22.16.29.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 22 Aug 2016 16:29:21 -0700 (PDT)
Subject: [RFC PATCH v1 25/28] KVM: SVM: add KVM_SEV_GUEST_STATUS command
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Mon, 22 Aug 2016 19:29:09 -0400
Message-ID: <147190854977.9523.2458628974170220401.stgit@brijesh-build-machine>
In-Reply-To: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, brijesh.singh@amd.com, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, linux-crypto@vger.kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

The command is used to query the SEV guest status.

For more information see [1], section 6.10

[1] http://support.amd.com/TechDocs/55766_SEV-KM%20API_Spec.pdf

Signed-off-by: Brijesh Singh <brijesh.singh@amd.com>
---
 arch/x86/kvm/svm.c |   41 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)

diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
index 60cc0f7..63e7d15 100644
--- a/arch/x86/kvm/svm.c
+++ b/arch/x86/kvm/svm.c
@@ -5570,6 +5570,42 @@ err_1:
 	return ret;
 }
 
+static int sev_guest_status(struct kvm *kvm,
+			    struct kvm_sev_guest_status __user *argp,
+			    int *psp_ret)
+{
+	int ret;
+	struct kvm_sev_guest_status params;
+	struct psp_data_guest_status *status;
+
+	if (!kvm_sev_guest())
+		return -ENOTTY;
+
+	if (copy_from_user(&params, argp, sizeof(*argp)))
+		return -EFAULT;
+
+	status = kzalloc(sizeof(*status), GFP_KERNEL);
+	if (!status)
+		return -ENOMEM;
+
+	status->hdr.buffer_len = sizeof(*status);
+	status->handle = kvm_sev_handle();
+	ret = psp_guest_status(status, psp_ret);
+	if (ret) {
+		printk(KERN_ERR "SEV: GUEST_STATUS ret=%d (%#010x)\n",
+			ret, *psp_ret);
+		goto err_1;
+	}
+	params.policy = status->policy;
+	params.state = status->state;
+
+	if (copy_to_user(argp, &params, sizeof(*argp)))
+		ret = -EFAULT;
+err_1:
+	kfree(status);
+	return ret;
+}
+
 static int amd_sev_issue_cmd(struct kvm *kvm,
 			     struct kvm_sev_issue_cmd __user *user_data)
 {
@@ -5595,6 +5631,11 @@ static int amd_sev_issue_cmd(struct kvm *kvm,
 					&arg.ret_code);
 		break;
 	}
+	case KVM_SEV_GUEST_STATUS: {
+		r = sev_guest_status(kvm, (void *)arg.opaque,
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
