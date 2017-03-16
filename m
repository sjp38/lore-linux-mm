Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 64DD86B0388
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 07:04:11 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id u4so15586561qtc.4
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 04:04:11 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e16si3595382qkh.320.2017.03.16.04.04.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 04:04:10 -0700 (PDT)
Subject: Re: [RFC PATCH v2 30/32] kvm: svm: Add support for SEV DEBUG_ENCRYPT
 command
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
 <148846790758.2349.16768762953657853550.stgit@brijesh-build-machine>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <05dbd756-e8e9-9384-2759-898e230a6909@redhat.com>
Date: Thu, 16 Mar 2017 12:03:52 +0100
MIME-Version: 1.0
In-Reply-To: <148846790758.2349.16768762953657853550.stgit@brijesh-build-machine>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brijesh Singh <brijesh.singh@amd.com>, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, akpm@linux-foundation.org, davem@davemloft.net



On 02/03/2017 16:18, Brijesh Singh wrote:
> +	data = (void *) get_zeroed_page(GFP_KERNEL);

The page does not need to be zeroed, does it?

> +
> +	if ((len & 15) || (dst_addr & 15)) {
> +		/* if destination address and length are not 16-byte
> +		 * aligned then:
> +		 * a) decrypt destination page into temporary buffer
> +		 * b) copy source data into temporary buffer at correct offset
> +		 * c) encrypt temporary buffer
> +		 */
> +		ret = __sev_dbg_decrypt_page(kvm, dst_addr, data, &argp->error);

Ah, I see now you're using this function here for read-modify-write.
data is already pinned here, so even if you keep the function it makes
sense to push pinning out of __sev_dbg_decrypt_page and into
sev_dbg_decrypt.

> +		if (ret)
> +			goto err_3;
> +		d_off = dst_addr & (PAGE_SIZE - 1);
> +
> +		if (copy_from_user(data + d_off,
> +					(uint8_t *)debug.src_addr, len)) {
> +			ret = -EFAULT;
> +			goto err_3;
> +		}
> +
> +		encrypt->length = PAGE_SIZE;

Why decrypt/re-encrypt all the page instead of just the 16 byte area
around the [dst_addr, dst_addr+len) range?

> +		encrypt->src_addr = __psp_pa(data);
> +		encrypt->dst_addr =  __sev_page_pa(inpages[0]);
> +	} else {
> +		if (copy_from_user(data, (uint8_t *)debug.src_addr, len)) {
> +			ret = -EFAULT;
> +			goto err_3;
> +		}

Do you need copy_from_user, or can you just pin/unpin memory as for
DEBUG_DECRYPT?

Paolo

> +		d_off = dst_addr & (PAGE_SIZE - 1);
> +		encrypt->length = len;
> +		encrypt->src_addr = __psp_pa(data);
> +		encrypt->dst_addr = __sev_page_pa(inpages[0]);
> +		encrypt->dst_addr += d_off;
> +	}
> +
> +	encrypt->handle = sev_get_handle(kvm);
> +	ret = sev_issue_cmd(kvm, SEV_CMD_DBG_ENCRYPT, encrypt, &argp->error);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
