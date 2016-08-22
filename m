Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1116482F66
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 19:29:58 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id u191so36268971oie.3
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 16:29:58 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0077.outbound.protection.outlook.com. [104.47.38.77])
        by mx.google.com with ESMTPS id e101si156514ote.212.2016.08.22.16.29.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 22 Aug 2016 16:29:57 -0700 (PDT)
Subject: [RFC PATCH v1 27/28] KVM: SVM: add KVM_SEV_DEBUG_ENCRYPT command
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Mon, 22 Aug 2016 19:29:35 -0400
Message-ID: <147190857531.9523.10196506226671736370.stgit@brijesh-build-machine>
In-Reply-To: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, brijesh.singh@amd.com, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, linux-crypto@vger.kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

The command encrypts a region of guest memory for debugging purposes.

For more information see [1], section 7.2

[1] http://support.amd.com/TechDocs/55766_SEV-KM%20API_Spec.pdf

Signed-off-by: Brijesh Singh <brijesh.singh@amd.com>
---
 arch/x86/kvm/svm.c |  100 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 100 insertions(+)

diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
index b383bc7..4af195d 100644
--- a/arch/x86/kvm/svm.c
+++ b/arch/x86/kvm/svm.c
@@ -5684,6 +5684,101 @@ err_1:
 	return ret;
 }
 
+static int sev_dbg_encrypt(struct kvm *kvm,
+			   struct kvm_sev_dbg_encrypt __user *argp,
+			   int *psp_ret)
+{
+	void *data;
+	int len, ret, d_off;
+	struct page **inpages;
+	struct psp_data_dbg *encrypt;
+	struct kvm_sev_dbg_encrypt debug;
+	unsigned long src_addr, dst_addr;
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
+	len = debug.length;
+	src_addr = debug.src_addr;
+	dst_addr = debug.dst_addr;
+
+	inpages = kzalloc(1 * sizeof(struct page *), GFP_KERNEL);
+	if (!inpages)
+		return -ENOMEM;
+
+	/* pin the guest destination virtual address */
+	down_read(&current->mm->mmap_sem);
+	ret = get_user_pages(dst_addr, 1, 1, 0, inpages, NULL);
+	up_read(&current->mm->mmap_sem);
+	if (ret < 0)
+		goto err_1;
+
+	encrypt = kzalloc(sizeof(*encrypt), GFP_KERNEL);
+	if (!encrypt)
+		goto err_2;
+
+	data = (void *) get_zeroed_page(GFP_KERNEL);
+	if (!data)
+		goto err_3;
+
+	encrypt->hdr.buffer_len = sizeof(*encrypt);
+	encrypt->handle = kvm_sev_handle();
+
+	if ((len & 15) || (dst_addr & 15)) {
+		/* if destination address and length are not 16-byte
+		 * aligned then:
+		 * a) decrypt destination page into temporary buffer
+		 * b) copy source data into temporary buffer at correct offset
+		 * c) encrypt temporary buffer
+		 */
+		ret = __sev_dbg_decrypt_page(kvm, dst_addr, data, psp_ret);
+		if (ret)
+			goto err_4;
+
+		d_off = dst_addr & (PAGE_SIZE - 1);
+		ret = -EFAULT;
+		if (copy_from_user(data + d_off,
+					(uint8_t *)debug.src_addr, len))
+			goto err_4;
+
+		encrypt->length = PAGE_SIZE;
+		encrypt->src_addr = __pa(data) | sme_me_mask;
+		encrypt->dst_addr =  __sev_page_pa(inpages[0]);
+	} else {
+		if (copy_from_user(data, (uint8_t *)debug.src_addr, len))
+			goto err_4;
+
+		d_off = dst_addr & (PAGE_SIZE - 1);
+		encrypt->length = len;
+		encrypt->src_addr = __pa(data) | sme_me_mask;
+		encrypt->dst_addr = __sev_page_pa(inpages[0]);
+		encrypt->dst_addr += d_off;
+	}
+
+	ret = psp_dbg_encrypt(encrypt, psp_ret);
+	if (ret)
+		printk(KERN_ERR "SEV: DEBUG_ENCRYPT: [%#lx=>%#lx+%#x] "
+			"%d (%#010x)\n",src_addr, dst_addr, len,
+			ret, *psp_ret);
+
+err_4:
+	free_page((unsigned long)data);
+err_3:
+	kfree(encrypt);
+err_2:
+	release_pages(inpages, 1, 0);
+err_1:
+	kfree(inpages);
+
+	return ret;
+}
+
 static int amd_sev_issue_cmd(struct kvm *kvm,
 			     struct kvm_sev_issue_cmd __user *user_data)
 {
@@ -5719,6 +5814,11 @@ static int amd_sev_issue_cmd(struct kvm *kvm,
 					&arg.ret_code);
 		break;
 	}
+	case KVM_SEV_DBG_ENCRYPT: {
+		r = sev_dbg_encrypt(kvm, (void *)arg.opaque,
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
