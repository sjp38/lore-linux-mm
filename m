Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 02CFE440843
	for <linux-mm@kvack.org>; Sat,  8 Jul 2017 08:50:35 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id 35so21776635uax.6
        for <linux-mm@kvack.org>; Sat, 08 Jul 2017 05:50:34 -0700 (PDT)
Received: from mail-vk0-x243.google.com (mail-vk0-x243.google.com. [2607:f8b0:400c:c05::243])
        by mx.google.com with ESMTPS id 42si2811816uad.15.2017.07.08.05.50.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 08 Jul 2017 05:50:34 -0700 (PDT)
Received: by mail-vk0-x243.google.com with SMTP id 82so3779782vki.0
        for <linux-mm@kvack.org>; Sat, 08 Jul 2017 05:50:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170707133850.29711.29549.stgit@tlendack-t1.amdoffice.net>
References: <20170707133804.29711.1616.stgit@tlendack-t1.amdoffice.net> <20170707133850.29711.29549.stgit@tlendack-t1.amdoffice.net>
From: Brian Gerst <brgerst@gmail.com>
Date: Sat, 8 Jul 2017 08:50:33 -0400
Message-ID: <CAMzpN2j-gXvx2wAp3EvQB70Mr_oz0MSUzG=c-mhu-bnRiQGaFQ@mail.gmail.com>
Subject: Re: [PATCH v9 04/38] x86/CPU/AMD: Add the Secure Memory Encryption
 CPU feature
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch <linux-arch@vger.kernel.org>, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, the arch/x86 maintainers <x86@kernel.org>, kexec@lists.infradead.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, Linux-MM <linux-mm@kvack.org>, iommu@lists.linux-foundation.org, Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

On Fri, Jul 7, 2017 at 9:38 AM, Tom Lendacky <thomas.lendacky@amd.com> wrote:
> Update the CPU features to include identifying and reporting on the
> Secure Memory Encryption (SME) feature.  SME is identified by CPUID
> 0x8000001f, but requires BIOS support to enable it (set bit 23 of
> MSR_K8_SYSCFG).  Only show the SME feature as available if reported by
> CPUID and enabled by BIOS.
>
> Reviewed-by: Borislav Petkov <bp@suse.de>
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/include/asm/cpufeatures.h |    1 +
>  arch/x86/include/asm/msr-index.h   |    2 ++
>  arch/x86/kernel/cpu/amd.c          |   13 +++++++++++++
>  arch/x86/kernel/cpu/scattered.c    |    1 +
>  4 files changed, 17 insertions(+)
>
> diff --git a/arch/x86/include/asm/cpufeatures.h b/arch/x86/include/asm/cpufeatures.h
> index 2701e5f..2b692df 100644
> --- a/arch/x86/include/asm/cpufeatures.h
> +++ b/arch/x86/include/asm/cpufeatures.h
> @@ -196,6 +196,7 @@
>
>  #define X86_FEATURE_HW_PSTATE  ( 7*32+ 8) /* AMD HW-PState */
>  #define X86_FEATURE_PROC_FEEDBACK ( 7*32+ 9) /* AMD ProcFeedbackInterface */
> +#define X86_FEATURE_SME                ( 7*32+10) /* AMD Secure Memory Encryption */

Given that this feature is available only in long mode, this should be
added to disabled-features.h as disabled for 32-bit builds.

>  #define X86_FEATURE_INTEL_PPIN ( 7*32+14) /* Intel Processor Inventory Number */
>  #define X86_FEATURE_INTEL_PT   ( 7*32+15) /* Intel Processor Trace */
> diff --git a/arch/x86/include/asm/msr-index.h b/arch/x86/include/asm/msr-index.h
> index 18b1623..460ac01 100644
> --- a/arch/x86/include/asm/msr-index.h
> +++ b/arch/x86/include/asm/msr-index.h
> @@ -352,6 +352,8 @@
>  #define MSR_K8_TOP_MEM1                        0xc001001a
>  #define MSR_K8_TOP_MEM2                        0xc001001d
>  #define MSR_K8_SYSCFG                  0xc0010010
> +#define MSR_K8_SYSCFG_MEM_ENCRYPT_BIT  23
> +#define MSR_K8_SYSCFG_MEM_ENCRYPT      BIT_ULL(MSR_K8_SYSCFG_MEM_ENCRYPT_BIT)
>  #define MSR_K8_INT_PENDING_MSG         0xc0010055
>  /* C1E active bits in int pending message */
>  #define K8_INTP_C1E_ACTIVE_MASK                0x18000000
> diff --git a/arch/x86/kernel/cpu/amd.c b/arch/x86/kernel/cpu/amd.c
> index bb5abe8..c47ceee 100644
> --- a/arch/x86/kernel/cpu/amd.c
> +++ b/arch/x86/kernel/cpu/amd.c
> @@ -611,6 +611,19 @@ static void early_init_amd(struct cpuinfo_x86 *c)
>          */
>         if (cpu_has_amd_erratum(c, amd_erratum_400))
>                 set_cpu_bug(c, X86_BUG_AMD_E400);
> +
> +       /*
> +        * BIOS support is required for SME. If BIOS has not enabled SME
> +        * then don't advertise the feature (set in scattered.c)
> +        */
> +       if (cpu_has(c, X86_FEATURE_SME)) {
> +               u64 msr;
> +
> +               /* Check if SME is enabled */
> +               rdmsrl(MSR_K8_SYSCFG, msr);
> +               if (!(msr & MSR_K8_SYSCFG_MEM_ENCRYPT))
> +                       clear_cpu_cap(c, X86_FEATURE_SME);
> +       }

This should be conditional on CONFIG_X86_64.

>  }
>
>  static void init_amd_k8(struct cpuinfo_x86 *c)
> diff --git a/arch/x86/kernel/cpu/scattered.c b/arch/x86/kernel/cpu/scattered.c
> index 23c2350..05459ad 100644
> --- a/arch/x86/kernel/cpu/scattered.c
> +++ b/arch/x86/kernel/cpu/scattered.c
> @@ -31,6 +31,7 @@ struct cpuid_bit {
>         { X86_FEATURE_HW_PSTATE,        CPUID_EDX,  7, 0x80000007, 0 },
>         { X86_FEATURE_CPB,              CPUID_EDX,  9, 0x80000007, 0 },
>         { X86_FEATURE_PROC_FEEDBACK,    CPUID_EDX, 11, 0x80000007, 0 },
> +       { X86_FEATURE_SME,              CPUID_EAX,  0, 0x8000001f, 0 },

This should also be conditional.  We don't want to set this feature on
32-bit, even if the processor has support.

>         { 0, 0, 0, 0, 0 }
>  };

--
Brian Gerst

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
