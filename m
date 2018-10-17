Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id D918F6B0010
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 06:42:04 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id 110-v6so16976777wra.9
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 03:42:04 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id y6-v6si12890727wrh.91.2018.10.17.03.42.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 03:42:03 -0700 (PDT)
Date: Wed, 17 Oct 2018 12:41:37 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v5 03/27] x86/fpu/xstate: Introduce XSAVES system states
Message-ID: <20181017104137.GE22535@zn.tnic>
References: <20181011151523.27101-1-yu-cheng.yu@intel.com>
 <20181011151523.27101-4-yu-cheng.yu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20181011151523.27101-4-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Thu, Oct 11, 2018 at 08:14:59AM -0700, Yu-cheng Yu wrote:
> Control Flow Enforcement (CET) MSRs are XSAVES system states.

That sentence needs massaging. MSRs are system states?!?!

> To support CET, we introduce XSAVES system states first.

Pls drop the "we" in all commit messages and convert the tone to
impartial and passive.

Also, this commit message needs to explain *why* you're doing this - it
is too laconic.

> Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> ---
>  arch/x86/include/asm/fpu/internal.h |  3 +-
>  arch/x86/include/asm/fpu/xstate.h   |  4 +-
>  arch/x86/kernel/fpu/core.c          |  6 +-
>  arch/x86/kernel/fpu/init.c          | 10 ----
>  arch/x86/kernel/fpu/xstate.c        | 86 ++++++++++++++++++-----------
>  5 files changed, 62 insertions(+), 47 deletions(-)
> 
> diff --git a/arch/x86/include/asm/fpu/internal.h b/arch/x86/include/asm/fpu/internal.h
> index 02c4296478c8..9a5db5a63f60 100644
> --- a/arch/x86/include/asm/fpu/internal.h
> +++ b/arch/x86/include/asm/fpu/internal.h
> @@ -45,7 +45,6 @@ extern void fpu__init_cpu_xstate(void);
>  extern void fpu__init_system(struct cpuinfo_x86 *c);
>  extern void fpu__init_check_bugs(void);
>  extern void fpu__resume_cpu(void);
> -extern u64 fpu__get_supported_xfeatures_mask(void);
>  
>  /*
>   * Debugging facility:
> @@ -93,7 +92,7 @@ static inline void fpstate_init_xstate(struct xregs_state *xsave)
>  	 * XRSTORS requires these bits set in xcomp_bv, or it will
>  	 * trigger #GP:
>  	 */
> -	xsave->header.xcomp_bv = XCOMP_BV_COMPACTED_FORMAT | xfeatures_mask_user;
> +	xsave->header.xcomp_bv = XCOMP_BV_COMPACTED_FORMAT | xfeatures_mask_all;
>  }
>  
>  static inline void fpstate_init_fxstate(struct fxregs_state *fx)
> diff --git a/arch/x86/include/asm/fpu/xstate.h b/arch/x86/include/asm/fpu/xstate.h
> index 76f83d2ac10e..d8e2ec99f635 100644
> --- a/arch/x86/include/asm/fpu/xstate.h
> +++ b/arch/x86/include/asm/fpu/xstate.h
> @@ -19,9 +19,6 @@
>  #define XSAVE_YMM_SIZE	    256
>  #define XSAVE_YMM_OFFSET    (XSAVE_HDR_SIZE + XSAVE_HDR_OFFSET)
>  
> -/* Supervisor features */
> -#define XFEATURE_MASK_SUPERVISOR (XFEATURE_MASK_PT)
> -
>  /* All currently supported features */
>  #define SUPPORTED_XFEATURES_MASK (XFEATURE_MASK_FP | \
>  				  XFEATURE_MASK_SSE | \
> @@ -40,6 +37,7 @@
>  #endif
>  
>  extern u64 xfeatures_mask_user;
> +extern u64 xfeatures_mask_all;

You have a bunch of places where you generate the system mask by doing
~xfeatures_mask_user.

Why not define

	xfeatures_mask_system

instead and generate the _all mask at the places you need it by doing

	xfeatures_mask_user | xfeatures_mask_system

?

We are differentiating user and system states now so it is only logical
to have that mirrored in the variables, right?

You even do that in fpu__init_system_xstate().

...

> @@ -225,20 +230,19 @@ void fpu__init_cpu_xstate(void)
>  	 * set here.
>  	 */
>  
> -	xfeatures_mask_user &= ~XFEATURE_MASK_SUPERVISOR;
> -
>  	cr4_set_bits(X86_CR4_OSXSAVE);
>  	xsetbv(XCR_XFEATURE_ENABLED_MASK, xfeatures_mask_user);

<---- newline here.

> +	/*
> +	 * MSR_IA32_XSS sets which XSAVES system states to be managed by

Improve:

"MSR_IA32_XSS controls which system (not user) states are going to be
managed by XSAVES."

> @@ -702,6 +703,7 @@ static int init_xstate_size(void)
>   */
>  static void fpu__init_disable_system_xstate(void)
>  {
> +	xfeatures_mask_all = 0;
>  	xfeatures_mask_user = 0;
>  	cr4_clear_bits(X86_CR4_OSXSAVE);
>  	fpu__xstate_clear_all_cpu_caps();
> @@ -717,6 +719,8 @@ void __init fpu__init_system_xstate(void)
>  	static int on_boot_cpu __initdata = 1;
>  	int err;
>  	int i;
> +	u64 cpu_user_xfeatures_mask;
> +	u64 cpu_system_xfeatures_mask;

Please sort function local variables declaration in a reverse christmas
tree order:

	<type> longest_variable_name;
	<type> shorter_var_name;
	<type> even_shorter;
	<type> i;

>  
>  	WARN_ON_FPU(!on_boot_cpu);
>  	on_boot_cpu = 0;

...

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
