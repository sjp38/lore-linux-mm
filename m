Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7DCD72806EA
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 13:07:04 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id c55so6224169wrc.22
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 10:07:04 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id n89si3085802wmi.41.2017.04.20.10.07.02
        for <linux-mm@kvack.org>;
        Thu, 20 Apr 2017 10:07:03 -0700 (PDT)
Date: Thu, 20 Apr 2017 18:59:22 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v5 05/32] x86/CPU/AMD: Handle SME reduction in physical
 address size
Message-ID: <20170420165922.j2inlwbchrs6senw@pd.tnic>
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418211711.10190.30861.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170418211711.10190.30861.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Tue, Apr 18, 2017 at 04:17:11PM -0500, Tom Lendacky wrote:
> When System Memory Encryption (SME) is enabled, the physical address
> space is reduced. Adjust the x86_phys_bits value to reflect this
> reduction.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/kernel/cpu/amd.c |   14 +++++++++++---
>  1 file changed, 11 insertions(+), 3 deletions(-)

...

> @@ -622,8 +624,14 @@ static void early_init_amd(struct cpuinfo_x86 *c)
>  
>  			/* Check if SME is enabled */
>  			rdmsrl(MSR_K8_SYSCFG, msr);
> -			if (!(msr & MSR_K8_SYSCFG_MEM_ENCRYPT))
> +			if (msr & MSR_K8_SYSCFG_MEM_ENCRYPT) {
> +				unsigned int ebx;
> +
> +				ebx = cpuid_ebx(0x8000001f);
> +				c->x86_phys_bits -= (ebx >> 6) & 0x3f;
> +			} else {
>  				clear_cpu_cap(c, X86_FEATURE_SME);
> +			}

Lemme do some simplifying to save an indent level, get rid of local var
ebx and kill some { }-brackets for a bit better readability:

        if (c->extended_cpuid_level >= 0x8000001f) {
                u64 msr;

                if (!cpu_has(c, X86_FEATURE_SME))
                        return;

                /* Check if SME is enabled */
                rdmsrl(MSR_K8_SYSCFG, msr);
                if (msr & MSR_K8_SYSCFG_MEM_ENCRYPT)
                        c->x86_phys_bits -= (cpuid_ebx(0x8000001f) >> 6) & 0x3f;
                else
                        clear_cpu_cap(c, X86_FEATURE_SME);
        }

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
