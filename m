Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5EA946B0388
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 06:54:43 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id n21so31742738qta.3
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 03:54:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l45si3603956qtf.37.2017.03.16.03.54.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 03:54:42 -0700 (PDT)
Subject: Re: [RFC PATCH v2 29/32] kvm: svm: Add support for SEV DEBUG_DECRYPT
 command
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
 <148846789744.2349.167641684941925238.stgit@brijesh-build-machine>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <4579cfdd-1797-8b47-8e00-254e3f6eb73f@redhat.com>
Date: Thu, 16 Mar 2017 11:54:28 +0100
MIME-Version: 1.0
In-Reply-To: <148846789744.2349.167641684941925238.stgit@brijesh-build-machine>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brijesh Singh <brijesh.singh@amd.com>, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, akpm@linux-foundation.org, davem@davemloft.net



On 02/03/2017 16:18, Brijesh Singh wrote:
> +static int __sev_dbg_decrypt_page(struct kvm *kvm, unsigned long src,
> +		void *dst, int *error)
> +{
> +	inpages = sev_pin_memory(src, PAGE_SIZE, &npages);
> +	if (!inpages) {
> +		ret = -ENOMEM;
> +		goto err_1;
> +	}
> +
> +	data->handle = sev_get_handle(kvm);
> +	data->dst_addr = __psp_pa(dst);
> +	data->src_addr = __sev_page_pa(inpages[0]);
> +	data->length = PAGE_SIZE;
> +
> +	ret = sev_issue_cmd(kvm, SEV_CMD_DBG_DECRYPT, data, error);
> +	if (ret)
> +		printk(KERN_ERR "SEV: DEBUG_DECRYPT %d (%#010x)\n",
> +				ret, *error);
> +	sev_unpin_memory(inpages, npages);
> +err_1:
> +	kfree(data);
> +	return ret;
> +}
> +
> +static int sev_dbg_decrypt(struct kvm *kvm, struct kvm_sev_cmd *argp)
> +{
> +	void *data;
> +	int ret, offset, len;
> +	struct kvm_sev_dbg debug;
> +
> +	if (!sev_guest(kvm))
> +		return -ENOTTY;
> +
> +	if (copy_from_user(&debug, (void *)argp->data,
> +				sizeof(struct kvm_sev_dbg)))
> +		return -EFAULT;
> +	/*
> +	 * TODO: add support for decrypting length which crosses the
> +	 * page boundary.
> +	 */
> +	offset = debug.src_addr & (PAGE_SIZE - 1);
> +	if (offset + debug.length > PAGE_SIZE)
> +		return -EINVAL;
> +

Please do add it, it doesn't seem very different from what you're doing
in LAUNCH_UPDATE_DATA.  There's no need for a separate
__sev_dbg_decrypt_page function, you can just pin/unpin here and do a
per-page loop as in LAUNCH_UPDATE_DATA.

Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
