Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 533426B6F83
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 11:01:53 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id b186so6666640wmc.8
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 08:01:53 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id w18si13927737wru.362.2018.12.04.08.01.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 08:01:51 -0800 (PST)
Date: Tue, 4 Dec 2018 17:01:45 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC PATCH v6 04/26] x86/fpu/xstate: Introduce XSAVES system
 states
Message-ID: <20181204160144.GG11803@zn.tnic>
References: <20181119214809.6086-1-yu-cheng.yu@intel.com>
 <20181119214809.6086-5-yu-cheng.yu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20181119214809.6086-5-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Mon, Nov 19, 2018 at 01:47:47PM -0800, Yu-cheng Yu wrote:
> Control-flow Enforcement (CET) MSR contents are XSAVES system states.
> To support CET, introduce XSAVES system states first.
> 
> Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> ---
>  arch/x86/include/asm/fpu/internal.h |  3 +-
>  arch/x86/include/asm/fpu/xstate.h   |  4 +-
>  arch/x86/kernel/fpu/core.c          |  6 +-
>  arch/x86/kernel/fpu/init.c          | 10 ---
>  arch/x86/kernel/fpu/xstate.c        | 94 +++++++++++++++++++----------
>  5 files changed, 69 insertions(+), 48 deletions(-)

...

> @@ -704,6 +710,7 @@ static int init_xstate_size(void)
>   */
>  static void fpu__init_disable_system_xstate(void)
>  {
> +	xfeatures_mask_all = 0;
>  	xfeatures_mask_user = 0;
>  	cr4_clear_bits(X86_CR4_OSXSAVE);
>  	fpu__xstate_clear_all_cpu_caps();
> @@ -717,6 +724,8 @@ void __init fpu__init_system_xstate(void)
>  {
>  	unsigned int eax, ebx, ecx, edx;
>  	static int on_boot_cpu __initdata = 1;
> +	u64 cpu_system_xfeatures_mask;
> +	u64 cpu_user_xfeatures_mask;

So what I had in mind is to not have those local vars but use
xfeatures_mask_user and xfeatures_mask_system here directly...

>  	int err;
>  	int i;
>  
> @@ -739,10 +748,23 @@ void __init fpu__init_system_xstate(void)
>  		return;
>  	}
>  
> +	/*
> +	 * Find user states supported by the processor.
> +	 * Only these bits can be set in XCR0.
> +	 */
>  	cpuid_count(XSTATE_CPUID, 0, &eax, &ebx, &ecx, &edx);
> -	xfeatures_mask_user = eax + ((u64)edx << 32);
> +	cpu_user_xfeatures_mask = eax + ((u64)edx << 32);
>  
> -	if ((xfeatures_mask_user & XFEATURE_MASK_FPSSE) != XFEATURE_MASK_FPSSE) {
> +	/*
> +	 * Find system states supported by the processor.
> +	 * Only these bits can be set in IA32_XSS MSR.
> +	 */
> +	cpuid_count(XSTATE_CPUID, 1, &eax, &ebx, &ecx, &edx);
> +	cpu_system_xfeatures_mask = ecx + ((u64)edx << 32);
> +
> +	xfeatures_mask_all = cpu_user_xfeatures_mask | cpu_system_xfeatures_mask;

... and not introduce xfeatures_mask_all at all but everywhere you need
all features, to do:

	(xfeatures_mask_user | xfeatures_mask_system)

and work with that.

...

> @@ -1178,7 +1208,7 @@ int copy_kernel_to_xstate(struct xregs_state *xsave, const void *kbuf)
>  	 * The state that came in from userspace was user-state only.
>  	 * Mask all the user states out of 'xfeatures':
>  	 */
> -	xsave->header.xfeatures &= XFEATURE_MASK_SUPERVISOR;
> +	xsave->header.xfeatures &= (xfeatures_mask_all & ~xfeatures_mask_user);

... and this would be

	xsave->header.xfeatures &= xfeatures_mask_system;

>  
>  	/*
>  	 * Add back in the features that came in from userspace:
> @@ -1234,7 +1264,7 @@ int copy_user_to_xstate(struct xregs_state *xsave, const void __user *ubuf)
>  	 * The state that came in from userspace was user-state only.
>  	 * Mask all the user states out of 'xfeatures':
>  	 */
> -	xsave->header.xfeatures &= XFEATURE_MASK_SUPERVISOR;
> +	xsave->header.xfeatures &= (xfeatures_mask_all & ~xfeatures_mask_user);

Ditto here.

This way you have *two* mask variables and code queries them only.

Hmmm?

Or am I missing something?

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
