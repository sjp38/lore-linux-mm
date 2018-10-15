Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6D32F6B0005
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 13:03:36 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id l10-v6so14250556wrw.12
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 10:03:36 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id w9-v6si8555654wrt.38.2018.10.15.10.03.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 10:03:34 -0700 (PDT)
Date: Mon, 15 Oct 2018 19:03:20 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v5 02/27] x86/fpu/xstate: Change names to separate XSAVES
 system and user states
Message-ID: <20181015170320.GF11434@zn.tnic>
References: <20181011151523.27101-1-yu-cheng.yu@intel.com>
 <20181011151523.27101-3-yu-cheng.yu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20181011151523.27101-3-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Thu, Oct 11, 2018 at 08:14:58AM -0700, Yu-cheng Yu wrote:
> Control Flow Enforcement (CET) MSRs are XSAVES system/supervisor
> states.  To support CET, we introduce XSAVES system states first.
> 
> XSAVES is a "supervisor" instruction and, comparing to XSAVE, saves
> additional "supervisor" states that can be modified only from CPL 0.
> However, these states are per-task and not kernel's own.  Rename
> "supervisor" states to "system" states to clearly separate them from
> "user" states.
> 
> Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> ---
>  arch/x86/include/asm/fpu/internal.h |  4 +-
>  arch/x86/include/asm/fpu/xstate.h   | 20 +++----
>  arch/x86/kernel/fpu/core.c          |  4 +-
>  arch/x86/kernel/fpu/init.c          |  2 +-
>  arch/x86/kernel/fpu/signal.c        |  6 +--
>  arch/x86/kernel/fpu/xstate.c        | 82 ++++++++++++++---------------
>  6 files changed, 57 insertions(+), 61 deletions(-)

...

> diff --git a/arch/x86/kernel/fpu/xstate.c b/arch/x86/kernel/fpu/xstate.c
> index 87a57b7642d3..e7cbaed12ef1 100644
> --- a/arch/x86/kernel/fpu/xstate.c
> +++ b/arch/x86/kernel/fpu/xstate.c
> @@ -51,13 +51,14 @@ static short xsave_cpuid_features[] __initdata = {
>  };
>  
>  /*
> - * Mask of xstate features supported by the CPU and the kernel:
> + * Mask of supported 'user' xstate features derived from boot_cpu_has() and
> + * SUPPORTED_XFEATURES_MASK.

<--- This comment here looks like a good place to put some blurb about
user and system states, what they are, what the distinction is and so
on.

>   */
> -u64 xfeatures_mask __read_mostly;
> +u64 xfeatures_mask_user __read_mostly;
>  
>  static unsigned int xstate_offsets[XFEATURE_MAX] = { [ 0 ... XFEATURE_MAX - 1] = -1};
>  static unsigned int xstate_sizes[XFEATURE_MAX]   = { [ 0 ... XFEATURE_MAX - 1] = -1};
> -static unsigned int xstate_comp_offsets[sizeof(xfeatures_mask)*8];
> +static unsigned int xstate_comp_offsets[sizeof(xfeatures_mask_user)*8];
>  
>  /*
>   * The XSAVE area of kernel can be in standard or compacted format;
> @@ -82,7 +83,7 @@ void fpu__xstate_clear_all_cpu_caps(void)
>   */
>  int cpu_has_xfeatures(u64 xfeatures_needed, const char **feature_name)
>  {
> -	u64 xfeatures_missing = xfeatures_needed & ~xfeatures_mask;
> +	u64 xfeatures_missing = xfeatures_needed & ~xfeatures_mask_user;
>  
>  	if (unlikely(feature_name)) {
>  		long xfeature_idx, max_idx;
> @@ -113,14 +114,11 @@ int cpu_has_xfeatures(u64 xfeatures_needed, const char **feature_name)
>  }
>  EXPORT_SYMBOL_GPL(cpu_has_xfeatures);
>  
> -static int xfeature_is_supervisor(int xfeature_nr)
> +static int xfeature_is_system(int xfeature_nr)
>  {
>  	/*
> -	 * We currently do not support supervisor states, but if
> -	 * we did, we could find out like this.
> -	 *
>  	 * SDM says: If state component 'i' is a user state component,
> -	 * ECX[0] return 0; if state component i is a supervisor
> +	 * ECX[0] return 0; if state component i is a system

		  is 0

>  	 * state component, ECX[0] returns 1.

				   is 1.

>  	 */
>  	u32 eax, ebx, ecx, edx;

...

> @@ -242,7 +238,7 @@ void fpu__init_cpu_xstate(void)
>   */
>  static int xfeature_enabled(enum xfeature xfeature)
>  {
> -	return !!(xfeatures_mask & (1UL << xfeature));
> +	return !!(xfeatures_mask_user & BIT_ULL(xfeature));
>  }
>  
>  /*
> @@ -272,7 +268,7 @@ static void __init setup_xstate_features(void)
>  		cpuid_count(XSTATE_CPUID, i, &eax, &ebx, &ecx, &edx);
>  
>  		/*
> -		 * If an xfeature is supervisor state, the offset
> +		 * If an xfeature is system state, the offset

				is a system state, ...

>  		 * in EBX is invalid. We leave it to -1.
>  		 */
>  		if (xfeature_is_user(i))

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
