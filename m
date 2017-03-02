Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 416426B03BA
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 10:18:24 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id f138so42700372oib.6
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 07:18:24 -0800 (PST)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0041.outbound.protection.outlook.com. [104.47.38.41])
        by mx.google.com with ESMTPS id q103si3541006ota.251.2017.03.02.07.18.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 02 Mar 2017 07:18:23 -0800 (PST)
Subject: [RFC PATCH v2 29/32] kvm: svm: Add support for SEV DEBUG_DECRYPT
 command
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Thu, 2 Mar 2017 10:18:17 -0500
Message-ID: <148846789744.2349.167641684941925238.stgit@brijesh-build-machine>
In-Reply-To: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, brijesh.singh@amd.com, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

The command is used to decrypt guest memory region for debug purposes.

Signed-off-by: Brijesh Singh <brijesh.singh@amd.com>
---
 arch/x86/kvm/svm.c |   76 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 76 insertions(+)

diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
index 977aa22..ce8819a 100644
--- a/arch/x86/kvm/svm.c
+++ b/arch/x86/kvm/svm.c
@@ -5986,6 +5986,78 @@ static int sev_guest_status(struct kvm *kvm, struct kvm_sev_cmd *argp)
 	return ret;
 }
 
+static int __sev_dbg_decrypt_page(struct kvm *kvm, unsigned long src,
+		void *dst, int *error)
+{
+	int ret;
+	struct page **inpages;
+	struct sev_data_dbg *data;
+	unsigned long npages;
+
+	data = kzalloc(sizeof(*data), GFP_KERNEL);
+	if (!data)
+		return -ENOMEM;
+
+	inpages = sev_pin_memory(src, PAGE_SIZE, &npages);
+	if (!inpages) {
+		ret = -ENOMEM;
+		goto err_1;
+	}
+
+	data->handle = sev_get_handle(kvm);
+	data->dst_addr = __psp_pa(dst);
+	data->src_addr = __sev_page_pa(inpages[0]);
+	data->length = PAGE_SIZE;
+
+	ret = sev_issue_cmd(kvm, SEV_CMD_DBG_DECRYPT, data, error);
+	if (ret)
+		printk(KERN_ERR "SEV: DEBUG_DECRYPT %d (%#010x)\n",
+				ret, *error);
+	sev_unpin_memory(inpages, npages);
+err_1:
+	kfree(data);
+	return ret;
+}
+
+static int sev_dbg_decrypt(struct kvm *kvm, struct kvm_sev_cmd *argp)
+{
+	void *data;
+	int ret, offset, len;
+	struct kvm_sev_dbg debug;
+
+	if (!sev_guest(kvm))
+		return -ENOTTY;
+
+	if (copy_from_user(&debug, (void *)argp->data,
+				sizeof(struct kvm_sev_dbg)))
+		return -EFAULT;
+	/*
+	 * TODO: add support for decrypting length which crosses the
+	 * page boundary.
+	 */
+	offset = debug.src_addr & (PAGE_SIZE - 1);
+	if (offset + debug.length > PAGE_SIZE)
+		return -EINVAL;
+
+	data = (void *) get_zeroed_page(GFP_KERNEL);
+	if (!data)
+		return -ENOMEM;
+
+	/* decrypt full page */
+	ret = __sev_dbg_decrypt_page(kvm, debug.src_addr & PAGE_MASK,
+			data, &argp->error);
+	if (ret)
+		goto err_1;
+
+	/* we have decrypted full page but copy request length */
+	len = min_t(size_t, (PAGE_SIZE - offset), debug.length);
+	if (copy_to_user((uint8_t *)debug.dst_addr, data + offset, len))
+		ret = -EFAULT;
+err_1:
+	free_page((unsigned long)data);
+	return ret;
+}
+
 static int amd_memory_encryption_cmd(struct kvm *kvm, void __user *argp)
 {
 	int r = -ENOTTY;
@@ -6013,6 +6085,10 @@ static int amd_memory_encryption_cmd(struct kvm *kvm, void __user *argp)
 		r = sev_guest_status(kvm, &sev_cmd);
 		break;
 	}
+	case KVM_SEV_DBG_DECRYPT: {
+		r = sev_dbg_decrypt(kvm, &sev_cmd);
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
