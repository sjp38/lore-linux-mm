Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8A97382F66
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 19:29:33 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id m184so262894522qkb.2
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 16:29:33 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0088.outbound.protection.outlook.com. [104.47.33.88])
        by mx.google.com with ESMTPS id v190si398011qki.53.2016.08.22.16.29.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 22 Aug 2016 16:29:32 -0700 (PDT)
Subject: [RFC PATCH v1 26/28] KVM: SVM: add KVM_SEV_DEBUG_DECRYPT command
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Mon, 22 Aug 2016 19:29:24 -0400
Message-ID: <147190856410.9523.15450446725026208803.stgit@brijesh-build-machine>
In-Reply-To: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, brijesh.singh@amd.com, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, linux-crypto@vger.kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

The command decrypts a page of guest memory for debugging purposes.

For more information see [1], section 7.1

[1] http://support.amd.com/TechDocs/55766_SEV-KM%20API_Spec.pdf

Signed-off-by: Brijesh Singh <brijesh.singh@amd.com>
---
 arch/x86/kvm/svm.c |   83 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 83 insertions(+)

diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
index 63e7d15..b383bc7 100644
--- a/arch/x86/kvm/svm.c
+++ b/arch/x86/kvm/svm.c
@@ -5606,6 +5606,84 @@ err_1:
 	return ret;
 }
 
+static int __sev_dbg_decrypt_page(struct kvm *kvm, unsigned long src,
+				  void *dst, int *psp_ret)
+{
+	int ret, pinned;
+	struct page **inpages;
+	struct psp_data_dbg *decrypt;
+
+	decrypt = kzalloc(sizeof(*decrypt), GFP_KERNEL);
+	if (!decrypt)
+		return -ENOMEM;
+
+	ret = -ENOMEM;
+	inpages = kzalloc(1 * sizeof(struct page *), GFP_KERNEL);
+	if (!inpages)
+		goto err_1;
+
+	/* pin the user virtual address */
+	ret = -EFAULT;
+	down_read(&current->mm->mmap_sem);
+	pinned = get_user_pages(src, 1, 1, 0, inpages, NULL);
+	up_read(&current->mm->mmap_sem);
+	if (pinned < 0)
+		goto err_2;
+
+	decrypt->hdr.buffer_len = sizeof(*decrypt);
+	decrypt->handle = kvm_sev_handle();
+	decrypt->dst_addr = __pa(dst) | sme_me_mask;
+	decrypt->src_addr = __sev_page_pa(inpages[0]);
+	decrypt->length = PAGE_SIZE;
+
+	ret = psp_dbg_decrypt(decrypt, psp_ret);
+	if (ret)
+		printk(KERN_ERR "SEV: DEBUG_DECRYPT %d (%#010x)\n",
+				ret, *psp_ret);
+	release_pages(inpages, 1, 0);
+err_2:
+	kfree(inpages);
+err_1:
+	kfree(decrypt);
+	return ret;
+}
+
+static int sev_dbg_decrypt(struct kvm *kvm,
+			   struct kvm_sev_dbg_decrypt __user *argp,
+			   int *psp_ret)
+{
+	void *data;
+	int ret, offset, len;
+	struct kvm_sev_dbg_decrypt debug;
+
+	if (!kvm_sev_guest())
+		return -ENOTTY;
+
+	if (copy_from_user(&debug, argp, sizeof(*argp)))
+		return -EFAULT;
+
+	if (debug.length > PAGE_SIZE)
+		return -EINVAL;
+
+	data = (void *) get_zeroed_page(GFP_KERNEL);
+	if (!data)
+		return -ENOMEM;
+
+	/* decrypt one page */
+	ret = __sev_dbg_decrypt_page(kvm, debug.src_addr, data, psp_ret);
+	if (ret)
+		goto err_1;
+
+	/* we have decrypted full page but copy request length */
+	offset = debug.src_addr & (PAGE_SIZE - 1);
+	len = min_t(size_t, (PAGE_SIZE - offset), debug.length);
+	if (copy_to_user((uint8_t *)debug.dst_addr, data + offset, len))
+		ret = -EFAULT;
+err_1:
+	free_page((unsigned long)data);
+	return ret;
+}
+
 static int amd_sev_issue_cmd(struct kvm *kvm,
 			     struct kvm_sev_issue_cmd __user *user_data)
 {
@@ -5636,6 +5714,11 @@ static int amd_sev_issue_cmd(struct kvm *kvm,
 					&arg.ret_code);
 		break;
 	}
+	case KVM_SEV_DBG_DECRYPT: {
+		r = sev_dbg_decrypt(kvm, (void *)arg.opaque,
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
