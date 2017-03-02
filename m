Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 333BF6B03B7
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 10:18:15 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id f138so42697623oib.6
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 07:18:15 -0800 (PST)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0056.outbound.protection.outlook.com. [104.47.38.56])
        by mx.google.com with ESMTPS id 32si3544166otw.165.2017.03.02.07.18.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 02 Mar 2017 07:18:14 -0800 (PST)
Subject: [RFC PATCH v2 28/32] kvm: svm: Add support for SEV GUEST_STATUS
 command
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Thu, 2 Mar 2017 10:18:07 -0500
Message-ID: <148846788726.2349.3437191329307712811.stgit@brijesh-build-machine>
In-Reply-To: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, brijesh.singh@amd.com, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

The command is used for querying the SEV guest status.

Signed-off-by: Brijesh Singh <brijesh.singh@amd.com>
---
 arch/x86/kvm/svm.c |   37 +++++++++++++++++++++++++++++++++++++
 1 file changed, 37 insertions(+)

diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
index c108064..977aa22 100644
--- a/arch/x86/kvm/svm.c
+++ b/arch/x86/kvm/svm.c
@@ -5953,6 +5953,39 @@ static int sev_launch_finish(struct kvm *kvm, struct kvm_sev_cmd *argp)
 	return ret;
 }
 
+static int sev_guest_status(struct kvm *kvm, struct kvm_sev_cmd *argp)
+{
+	int ret;
+	struct kvm_sev_guest_status params;
+	struct sev_data_guest_status *data;
+
+	if (!sev_guest(kvm))
+		return -ENOTTY;
+
+	if (copy_from_user(&params, (void *) argp->data,
+				sizeof(struct kvm_sev_guest_status)))
+		return -EFAULT;
+
+	data = kzalloc(sizeof(*data), GFP_KERNEL);
+	if (!data)
+		return -ENOMEM;
+
+	data->handle = sev_get_handle(kvm);
+	ret = sev_issue_cmd(kvm, SEV_CMD_GUEST_STATUS, data, &argp->error);
+	if (ret)
+		goto err_1;
+
+	params.policy = data->policy;
+	params.state = data->state;
+
+	if (copy_to_user((void *) argp->data, &params,
+				sizeof(struct kvm_sev_guest_status)))
+		ret = -EFAULT;
+err_1:
+	kfree(data);
+	return ret;
+}
+
 static int amd_memory_encryption_cmd(struct kvm *kvm, void __user *argp)
 {
 	int r = -ENOTTY;
@@ -5976,6 +6009,10 @@ static int amd_memory_encryption_cmd(struct kvm *kvm, void __user *argp)
 		r = sev_launch_finish(kvm, &sev_cmd);
 		break;
 	}
+	case KVM_SEV_GUEST_STATUS: {
+		r = sev_guest_status(kvm, &sev_cmd);
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
