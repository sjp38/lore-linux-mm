Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8292E6B0284
	for <linux-mm@kvack.org>; Sun,  7 Feb 2016 12:10:52 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id g62so106093356wme.0
        for <linux-mm@kvack.org>; Sun, 07 Feb 2016 09:10:52 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id s10si11652359wmf.41.2016.02.07.09.10.51
        for <linux-mm@kvack.org>;
        Sun, 07 Feb 2016 09:10:51 -0800 (PST)
Date: Sun, 7 Feb 2016 18:10:41 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v10 4/4] x86: Create a new synthetic cpu capability for
 machine check recovery
Message-ID: <20160207171041.GG5862@pd.tnic>
References: <cover.1454618190.git.tony.luck@intel.com>
 <97426a50c5667bb81a28340b820b371d7fadb6fa.1454618190.git.tony.luck@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <97426a50c5667bb81a28340b820b371d7fadb6fa.1454618190.git.tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, elliott@hpe.com, Brian Gerst <brgerst@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org

On Fri, Jan 29, 2016 at 04:00:19PM -0800, Tony Luck wrote:
> The Intel Software Developer Manual describes bit 24 in the MCG_CAP
> MSR:
>    MCG_SER_P (software error recovery support present) flag,
>    bit 24 a?? Indicates (when set) that the processor supports
>    software error recovery
> But only some models with this capability bit set will actually
> generate recoverable machine checks.
> 
> Check the model name and set a synthetic capability bit. Provide
> a command line option to set this bit anyway in case the kernel
> doesn't recognise the model name.
> 
> Signed-off-by: Tony Luck <tony.luck@intel.com>
> ---
>  Documentation/x86/x86_64/boot-options.txt |  4 ++++
>  arch/x86/include/asm/cpufeature.h         |  1 +
>  arch/x86/include/asm/mce.h                |  1 +
>  arch/x86/kernel/cpu/mcheck/mce.c          | 11 +++++++++++
>  4 files changed, 17 insertions(+)
> 
> diff --git a/Documentation/x86/x86_64/boot-options.txt b/Documentation/x86/x86_64/boot-options.txt
> index 68ed3114c363..8423c04ae7b3 100644
> --- a/Documentation/x86/x86_64/boot-options.txt
> +++ b/Documentation/x86/x86_64/boot-options.txt
> @@ -60,6 +60,10 @@ Machine check
>  		threshold to 1. Enabling this may make memory predictive failure
>  		analysis less effective if the bios sets thresholds for memory
>  		errors since we will not see details for all errors.
> +   mce=recovery
> +		Tell the kernel that this system can generate recoverable
> +		machine checks (useful when the kernel doesn't recognize
> +		the cpuid x86_model_id[])

I'd say		"Force-enable generation of recoverable MCEs."

and not mention implementation details in the description text.

>     nomce (for compatibility with i386): same as mce=off
>  
> diff --git a/arch/x86/include/asm/cpufeature.h b/arch/x86/include/asm/cpufeature.h
> index 7ad8c9464297..06c6c2d2fea0 100644
> --- a/arch/x86/include/asm/cpufeature.h
> +++ b/arch/x86/include/asm/cpufeature.h
> @@ -106,6 +106,7 @@
>  #define X86_FEATURE_APERFMPERF	( 3*32+28) /* APERFMPERF */
>  #define X86_FEATURE_EAGER_FPU	( 3*32+29) /* "eagerfpu" Non lazy FPU restore */
>  #define X86_FEATURE_NONSTOP_TSC_S3 ( 3*32+30) /* TSC doesn't stop in S3 state */
> +#define X86_FEATURE_MCE_RECOVERY ( 3*32+31) /* cpu has recoverable machine checks */
>  
>  /* Intel-defined CPU features, CPUID level 0x00000001 (ecx), word 4 */
>  #define X86_FEATURE_XMM3	( 4*32+ 0) /* "pni" SSE-3 */
> diff --git a/arch/x86/include/asm/mce.h b/arch/x86/include/asm/mce.h
> index 2ea4527e462f..18d2ba9c8e44 100644
> --- a/arch/x86/include/asm/mce.h
> +++ b/arch/x86/include/asm/mce.h
> @@ -113,6 +113,7 @@ struct mca_config {
>  	bool ignore_ce;
>  	bool disabled;
>  	bool ser;
> +	bool recovery;
>  	bool bios_cmci_threshold;
>  	u8 banks;
>  	s8 bootlog;
> diff --git a/arch/x86/kernel/cpu/mcheck/mce.c b/arch/x86/kernel/cpu/mcheck/mce.c
> index 905f3070f412..16a3d0e29f84 100644
> --- a/arch/x86/kernel/cpu/mcheck/mce.c
> +++ b/arch/x86/kernel/cpu/mcheck/mce.c
> @@ -1696,6 +1696,15 @@ void mcheck_cpu_init(struct cpuinfo_x86 *c)
>  		return;
>  	}
>  
> +	/*
> +	 * MCG_CAP.MCG_SER_P is necessary but not sufficient to know
> +	 * whether this processor will actually generate recoverable
> +	 * machine checks. Check to see if this is an E7 model Xeon.
> +	 */
> +	if (mca_cfg.recovery || (mca_cfg.ser &&
> +		!strncmp(c->x86_model_id, "Intel(R) Xeon(R) CPU E7-", 24)))

Eeww, a model string check :-(

Lemme guess: those E7s can't be represented by a range of
model/steppings, can they?

Similar to AMD_MODEL_RANGE() thing in cpu/amd.c, for example.

In any case, that chunk belongs in the Intel part of
__mcheck_cpu_apply_quirks().

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
