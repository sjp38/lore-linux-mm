Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B9CF36B0393
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 10:06:19 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id n11so11576128wma.5
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 07:06:19 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g80si4714578wrd.149.2017.03.08.07.06.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Mar 2017 07:06:18 -0800 (PST)
Date: Wed, 8 Mar 2017 16:06:03 +0100
From: Borislav Petkov <bp@suse.de>
Subject: Re: [RFC PATCH v2 02/32] x86: Secure Encrypted Virtualization (SEV)
 support
Message-ID: <20170308150603.5n4efpylat5i7rgb@pd.tnic>
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
 <148846754069.2349.4698319264278045964.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <148846754069.2349.4698319264278045964.stgit@brijesh-build-machine>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brijesh Singh <brijesh.singh@amd.com>
Cc: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

On Thu, Mar 02, 2017 at 10:12:20AM -0500, Brijesh Singh wrote:
> From: Tom Lendacky <thomas.lendacky@amd.com>
> 
> Provide support for Secure Encyrpted Virtualization (SEV). This initial
> support defines a flag that is used by the kernel to determine if it is
> running with SEV active.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/include/asm/mem_encrypt.h |   14 +++++++++++++-
>  arch/x86/mm/mem_encrypt.c          |    3 +++
>  include/linux/mem_encrypt.h        |    6 ++++++
>  3 files changed, 22 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
> index 1fd5426..9799835 100644
> --- a/arch/x86/include/asm/mem_encrypt.h
> +++ b/arch/x86/include/asm/mem_encrypt.h
> @@ -20,10 +20,16 @@
>  #ifdef CONFIG_AMD_MEM_ENCRYPT
>  
>  extern unsigned long sme_me_mask;
> +extern unsigned int sev_enabled;

So there's a function name sev_enabled() and an int sev_enabled too.

It looks to me like you want to call the function "sev_enable()" -
similar to sme_enable(), convert it to C code - i.e., I don't see what
would speak against it - and rename that sev_enc_bit to sev_enabled and
use it everywhere when testing SEV status.

>  static inline bool sme_active(void)
>  {
> -	return (sme_me_mask) ? true : false;
> +	return (sme_me_mask && !sev_enabled) ? true : false;
> +}
> +
> +static inline bool sev_active(void)
> +{
> +	return (sme_me_mask && sev_enabled) ? true : false;

Then, those read strange: like SME and SEV are mutually exclusive. Why?
I might have an idea but I'd like for you to confirm it :-)

Then, you're calling sev_enabled in startup_32() but we can enter
in arch/x86/boot/compressed/head_64.S::startup_64() too, when we're
loaded by a 64-bit bootloader, which would then theoretically bypass
sev_enabled().

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
