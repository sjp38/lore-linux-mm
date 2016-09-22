Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 673F4280255
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 10:35:57 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l138so73251713wmg.3
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 07:35:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h129si2740295wmf.71.2016.09.22.07.35.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Sep 2016 07:35:55 -0700 (PDT)
Date: Thu, 22 Sep 2016 16:35:45 +0200
From: Borislav Petkov <bp@suse.de>
Subject: Re: [RFC PATCH v1 09/28] x86/efi: Access EFI data as encrypted when
 SEV is active
Message-ID: <20160922143545.3kl7khff6vqk7b2t@pd.tnic>
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
 <147190832511.9523.10850626471583956499.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <147190832511.9523.10850626471583956499.stgit@brijesh-build-machine>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brijesh Singh <brijesh.singh@amd.com>, thomas.lendacky@amd.com
Cc: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, linux-crypto@vger.kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

On Mon, Aug 22, 2016 at 07:25:25PM -0400, Brijesh Singh wrote:
> From: Tom Lendacky <thomas.lendacky@amd.com>
> 
> EFI data is encrypted when the kernel is run under SEV. Update the
> page table references to be sure the EFI memory areas are accessed
> encrypted.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/platform/efi/efi_64.c |   14 ++++++++++++--
>  1 file changed, 12 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/x86/platform/efi/efi_64.c b/arch/x86/platform/efi/efi_64.c
> index 0871ea4..98363f3 100644
> --- a/arch/x86/platform/efi/efi_64.c
> +++ b/arch/x86/platform/efi/efi_64.c
> @@ -213,7 +213,7 @@ void efi_sync_low_kernel_mappings(void)
>  
>  int __init efi_setup_page_tables(unsigned long pa_memmap, unsigned num_pages)
>  {
> -	unsigned long pfn, text;
> +	unsigned long pfn, text, flags;
>  	efi_memory_desc_t *md;
>  	struct page *page;
>  	unsigned npages;
> @@ -230,6 +230,10 @@ int __init efi_setup_page_tables(unsigned long pa_memmap, unsigned num_pages)
>  	efi_scratch.efi_pgt = (pgd_t *)__sme_pa(efi_pgd);
>  	pgd = efi_pgd;
>  
> +	flags = _PAGE_NX | _PAGE_RW;
> +	if (sev_active)
> +		flags |= _PAGE_ENC;

So this is confusing me. There's this patch which says EFI data is
accessed in the clear:

https://lkml.kernel.org/r/20160822223738.29880.6909.stgit@tlendack-t1.amdoffice.net

but now here it is encrypted when SEV is enabled.

Do you mean, it is encrypted here because we're in the guest kernel?

Thanks.

-- 
Regards/Gruss,
    Boris.

SUSE Linux GmbH, GF: Felix ImendA?rffer, Jane Smithard, Graham Norton, HRB 21284 (AG NA 1/4 rnberg)
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
