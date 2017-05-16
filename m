Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id BA0F16B02F3
	for <linux-mm@kvack.org>; Tue, 16 May 2017 04:37:09 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w79so27868282wme.7
        for <linux-mm@kvack.org>; Tue, 16 May 2017 01:37:09 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id t15si1057715wrb.108.2017.05.16.01.37.08
        for <linux-mm@kvack.org>;
        Tue, 16 May 2017 01:37:08 -0700 (PDT)
Date: Tue, 16 May 2017 10:36:58 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v5 18/32] x86, mpparse: Use memremap to map the mpf and
 mpc data
Message-ID: <20170516083658.fq2h4ysmrbgn23cs@pd.tnic>
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418211930.10190.62640.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170418211930.10190.62640.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Tue, Apr 18, 2017 at 04:19:30PM -0500, Tom Lendacky wrote:
> The SMP MP-table is built by UEFI and placed in memory in a decrypted
> state. These tables are accessed using a mix of early_memremap(),
> early_memunmap(), phys_to_virt() and virt_to_phys(). Change all accesses
> to use early_memremap()/early_memunmap(). This allows for proper setting
> of the encryption mask so that the data can be successfully accessed when
> SME is active.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/kernel/mpparse.c |  102 +++++++++++++++++++++++++++++++--------------
>  1 file changed, 71 insertions(+), 31 deletions(-)
> 
> diff --git a/arch/x86/kernel/mpparse.c b/arch/x86/kernel/mpparse.c
> index fd37f39..afbda41d 100644
> --- a/arch/x86/kernel/mpparse.c
> +++ b/arch/x86/kernel/mpparse.c
> @@ -429,7 +429,21 @@ static inline void __init construct_default_ISA_mptable(int mpc_default_type)
>  	}
>  }
>  
> -static struct mpf_intel *mpf_found;
> +static unsigned long mpf_base;
> +
> +static void __init unmap_mpf(struct mpf_intel *mpf)
> +{
> +	early_memunmap(mpf, sizeof(*mpf));
> +}
> +
> +static struct mpf_intel * __init map_mpf(unsigned long paddr)
> +{
> +	struct mpf_intel *mpf;
> +
> +	mpf = early_memremap(paddr, sizeof(*mpf));
> +
> +	return mpf;

	return early_memremap(paddr, sizeof(*mpf));

...

> @@ -842,25 +873,26 @@ static int __init update_mp_table(void)
>  	if (!enable_update_mptable)
>  		return 0;
>  
> -	mpf = mpf_found;
> -	if (!mpf)
> +	if (!mpf_base)
>  		return 0;
>  
> +	mpf = map_mpf(mpf_base);
> +
>  	/*
>  	 * Now see if we need to go further.
>  	 */
>  	if (mpf->feature1 != 0)

You're kidding, right? map_mpf() *can* return NULL.

Also, simplify that test:

	if (mpf->feature1)
		...


> -		return 0;
> +		goto do_unmap_mpf;
>  
>  	if (!mpf->physptr)
> -		return 0;
> +		goto do_unmap_mpf;
>  
> -	mpc = phys_to_virt(mpf->physptr);
> +	mpc = map_mpc(mpf->physptr);

Again: error checking !!!

You have other calls to early_memremap()/map_mpf() in this patch. Please
add error checking everywhere.

>  
>  	if (!smp_check_mpc(mpc, oem, str))
> -		return 0;
> +		goto do_unmap_mpc;
>  
> -	pr_info("mpf: %llx\n", (u64)virt_to_phys(mpf));
> +	pr_info("mpf: %llx\n", (u64)mpf_base);
>  	pr_info("physptr: %x\n", mpf->physptr);
>  
>  	if (mpc_new_phys && mpc->length > mpc_new_length) {
> @@ -878,21 +910,23 @@ static int __init update_mp_table(void)
>  		new = mpf_checksum((unsigned char *)mpc, mpc->length);
>  		if (old == new) {
>  			pr_info("mpc is readonly, please try alloc_mptable instead\n");
> -			return 0;
> +			goto do_unmap_mpc;
>  		}
>  		pr_info("use in-position replacing\n");
>  	} else {
>  		mpf->physptr = mpc_new_phys;
> -		mpc_new = phys_to_virt(mpc_new_phys);
> +		mpc_new = map_mpc(mpc_new_phys);

Ditto.

>  		memcpy(mpc_new, mpc, mpc->length);
> +		unmap_mpc(mpc);
>  		mpc = mpc_new;
>  		/* check if we can modify that */
>  		if (mpc_new_phys - mpf->physptr) {
>  			struct mpf_intel *mpf_new;
>  			/* steal 16 bytes from [0, 1k) */
>  			pr_info("mpf new: %x\n", 0x400 - 16);
> -			mpf_new = phys_to_virt(0x400 - 16);
> +			mpf_new = map_mpf(0x400 - 16);

Ditto.

>  			memcpy(mpf_new, mpf, 16);
> +			unmap_mpf(mpf);
>  			mpf = mpf_new;
>  			mpf->physptr = mpc_new_phys;
>  		}

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
