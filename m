Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8D5912808EA
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 11:13:49 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id j127so136582029qke.2
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 08:13:49 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s125si5975883qkf.19.2017.03.09.08.13.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Mar 2017 08:13:48 -0800 (PST)
Subject: Re: [RFC PATCH v2 12/32] x86: Add early boot support when running
 with SEV active
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
 <148846768878.2349.15757532025749214650.stgit@brijesh-build-machine>
 <20170309140748.tg67yo2jmc5ahck3@pd.tnic>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <5d62b16f-16ef-1bd7-1551-f0c4c43573f4@redhat.com>
Date: Thu, 9 Mar 2017 17:13:33 +0100
MIME-Version: 1.0
In-Reply-To: <20170309140748.tg67yo2jmc5ahck3@pd.tnic>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@suse.de>, Brijesh Singh <brijesh.singh@amd.com>
Cc: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, akpm@linux-foundation.org, davem@davemloft.net



On 09/03/2017 15:07, Borislav Petkov wrote:
> +	/* Check if running under a hypervisor */
> +	eax = 0x40000000;
> +	ecx = 0;
> +	native_cpuid(&eax, &ebx, &ecx, &edx);

This is not how you check if running under a hypervisor; you should
check the HYPERVISOR bit, i.e. bit 31 of cpuid(1).ecx.  This in turn
tells you if leaf 0x40000000 is valid.

That said, the main issue with this function is that it hardcodes the
behavior for KVM.  It is possible that another hypervisor defines its
0x40000001 leaf in such a way that KVM_FEATURE_SEV has a different meaning.

Instead, AMD should define a "well-known" bit in its own space (i.e.
0x800000xx) that is only used by hypervisors that support SEV.  This is
similar to how Intel defined one bit in leaf 1 to say "is leaf
0x40000000 valid".

Thanks,

Paolo

> +	if (eax > 0x40000000) {
> +		eax = 0x40000001;
> +		ecx = 0;
> +		native_cpuid(&eax, &ebx, &ecx, &edx);
> +		if (!(eax & BIT(KVM_FEATURE_SEV)))
> +			goto out;
> +
> +		eax = 0x8000001f;
> +		ecx = 0;
> +		native_cpuid(&eax, &ebx, &ecx, &edx);
> +		if (!(eax & 1))
> +			goto out;
> +
> +		sme_me_mask = 1UL << (ebx & 0x3f);
> +		sev_enabled = 1;
> +
> +		goto out;
> +	}
> +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
