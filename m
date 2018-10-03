Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 85C866B026B
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 10:35:52 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id l6-v6so4133043qtc.12
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 07:35:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k23-v6si272858qvg.219.2018.10.03.07.35.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 07:35:51 -0700 (PDT)
Date: Wed, 3 Oct 2018 16:36:10 +0200
From: Eugene Syromiatnikov <esyr@redhat.com>
Subject: Re: [RFC PATCH v4 20/27] x86/cet/shstk: Signal handling for shadow
 stack
Message-ID: <20181003143610.GC22724@asgard.redhat.com>
References: <20180921150351.20898-1-yu-cheng.yu@intel.com>
 <20180921150351.20898-21-yu-cheng.yu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180921150351.20898-21-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Fri, Sep 21, 2018 at 08:03:44AM -0700, Yu-cheng Yu wrote:
> When setting up a signal, the kernel creates a shadow stack
> restore token at the current SHSTK address and then stores the
> token's address in the signal frame, right after the FPU state.
> Before restoring a signal, the kernel verifies and then uses the
> restore token to set the SHSTK pointer.

> diff --git a/arch/x86/kernel/cet.c b/arch/x86/kernel/cet.c
> index ec256ae27a31..5cc4be6e0982 100644
> --- a/arch/x86/kernel/cet.c
> +++ b/arch/x86/kernel/cet.c

> @@ -46,6 +47,69 @@ static unsigned long get_shstk_addr(void)
>  	return ptr;
>  }
>  
> +/*
> + * Verify the restore token at the address of 'ssp' is
> + * valid and then set shadow stack pointer according to the
> + * token.
> + */
> +static int verify_rstor_token(bool ia32, unsigned long ssp,
> +			      unsigned long *new_ssp)
> +{
> +	unsigned long token;
> +
> +	*new_ssp = 0;
> +
> +	if (!IS_ALIGNED(ssp, 8))
> +		return -EINVAL;
> +
> +	if (get_user(token, (unsigned long __user *)ssp))
> +		return -EFAULT;
> +

> +	/* Is 64-bit mode flag correct? */
> +	if (ia32 && (token & 3) != 0)
> +		return -EINVAL;
> +	else if ((token & 3) != 1)
> +		return -EINVAL;

It is probably worth adding constant names for these flags, example,
there's Section 2.4 in the currently available description[1], and
it took some time before I decided to look into other patches
and find the patch with the documentation (or finally notice section 2.7).

[1] https://software.intel.com/sites/default/files/managed/4d/2a/control-flow-enforcement-technology-preview.pdf

> +	token &= ~(1UL);
> +
> +	if ((!ia32 && !IS_ALIGNED(token, 8)) || !IS_ALIGNED(token, 4))
> +		return -EINVAL;
> +
> +	if ((ALIGN_DOWN(token, 8) - 8) != ssp)
> +		return -EINVAL;
> +
> +	*new_ssp = token;
> +	return 0;
> +}
> +
> +/*
> + * Create a restore token on the shadow stack.
> + * A token is always 8-byte and aligned to 8.
> + */
> +static int create_rstor_token(bool ia32, unsigned long ssp,
> +			      unsigned long *new_ssp)
> +{
> +	unsigned long addr;
> +
> +	*new_ssp = 0;
> +
> +	if ((!ia32 && !IS_ALIGNED(ssp, 8)) || !IS_ALIGNED(ssp, 4))
> +		return -EINVAL;

Maybe refactor this check into a separate function/macro?

> +
> +	addr = ALIGN_DOWN(ssp, 8) - 8;
> +
> +	/* Is the token for 64-bit? */
> +	if (!ia32)
> +		ssp |= 1;

Again, usage of a named constant might document it better.

> +
> +	if (write_user_shstk_64(addr, ssp))

This function is defined in "[RFC PATCH v4 19/27] x86/cet/shstk:
Introduce WRUSS instruction"

> +		return -EFAULT;
> +
> +	*new_ssp = addr;
> +	return 0;
> +}
> +
>  int cet_setup_shstk(void)
>  {
>  	unsigned long addr, size;
> @@ -107,3 +171,54 @@ void cet_disable_free_shstk(struct task_struct *tsk)
>  
>  	tsk->thread.cet.shstk_enabled = 0;
>  }
> +
> +int cet_restore_signal(unsigned long ssp)
> +{
> +	unsigned long new_ssp;
> +	int err;
> +
> +	if (!current->thread.cet.shstk_enabled)
> +		return 0;
> +
> +	err = verify_rstor_token(in_ia32_syscall(), ssp, &new_ssp);
> +
> +	if (err)
> +		return err;
> +
> +	return set_shstk_ptr(new_ssp);
> +}
> +
> +/*
> + * Setup the shadow stack for the signal handler: first,
> + * create a restore token to keep track of the current ssp,
> + * and then the return address of the signal handler.
> + */
> +int cet_setup_signal(bool ia32, unsigned long rstor_addr,
> +		     unsigned long *new_ssp)
> +{
> +	unsigned long ssp;
> +	int err;
> +
> +	if (!current->thread.cet.shstk_enabled)
> +		return 0;
> +
> +	ssp = get_shstk_addr();
> +	err = create_rstor_token(ia32, ssp, new_ssp);
> +
> +	if (err)
> +		return err;
> +
> +	if (ia32) {
> +		ssp = *new_ssp - sizeof(u32);
> +		err = write_user_shstk_32(ssp, (unsigned int)rstor_addr);
> +	} else {
> +		ssp = *new_ssp - sizeof(u64);
> +		err = write_user_shstk_64(ssp, rstor_addr);
> +	}
> +
> +	if (err)
> +		return err;
> +
> +	set_shstk_ptr(ssp);
> +	return 0;
> +}
> diff --git a/arch/x86/kernel/signal.c b/arch/x86/kernel/signal.c
> index 92a3b312a53c..e9a85689143f 100644
> --- a/arch/x86/kernel/signal.c
> +++ b/arch/x86/kernel/signal.c
> @@ -46,6 +46,7 @@
>  
>  #include <asm/sigframe.h>
>  #include <asm/signal.h>
> +#include <asm/cet.h>
>  
>  #define COPY(x)			do {			\
>  	get_user_ex(regs->x, &sc->x);			\
> @@ -152,6 +153,10 @@ static int restore_sigcontext(struct pt_regs *regs,
>  
>  	err |= fpu__restore_sig(buf, IS_ENABLED(CONFIG_X86_32));
>  
> +#ifdef CONFIG_X86_64
> +	err |= restore_sigcontext_ext(buf);
> +#endif
> +
>  	force_iret();
>  
>  	return err;
> @@ -266,6 +271,11 @@ get_sigframe(struct k_sigaction *ka, struct pt_regs *regs, size_t frame_size,
>  	}
>  

>  	if (fpu->initialized) {
> +#ifdef CONFIG_X86_64
> +		/* sigcontext extension */
> +		if (boot_cpu_has(X86_FEATURE_SHSTK))
> +			sp -= sizeof(struct sc_ext) + 8;
> +#endif
>  		sp = fpu__alloc_mathframe(sp, IS_ENABLED(CONFIG_X86_32),
>  					  &buf_fx, &math_size);

That might be refactored in a separate function.

Also, it looks like that possible padding for 8-byte alignment
(copy_ext_{to,from}_user) is not accounted here.

>  		*fpstate = (void __user *)sp;
> @@ -493,6 +503,9 @@ static int __setup_rt_frame(int sig, struct ksignal *ksig,
>  	err |= setup_sigcontext(&frame->uc.uc_mcontext, fp, regs, set->sig[0]);
>  	err |= __copy_to_user(&frame->uc.uc_sigmask, set, sizeof(*set));
>  
> +	if (!err)
> +		err = setup_sigcontext_ext(ksig, fp);
> +

Why is this not in setup_sigcontext, for example?

>  	if (err)
>  		return -EFAULT;
>  
> @@ -576,6 +589,9 @@ static int x32_setup_rt_frame(struct ksignal *ksig,
>  				regs, set->sig[0]);
>  	err |= __copy_to_user(&frame->uc.uc_sigmask, set, sizeof(*set));
>  
> +	if (!err)
> +		err = setup_sigcontext_ext(ksig, fpstate);
> +
>  	if (err)
>  		return -EFAULT;
>  
> @@ -707,6 +723,86 @@ setup_rt_frame(struct ksignal *ksig, struct pt_regs *regs)
>  	}
>  }
>  
> +#ifdef CONFIG_X86_64
> +static int copy_ext_from_user(struct sc_ext *ext, void __user *fpu)
> +{
> +	void __user *p;
> +
> +	if (!fpu)
> +		return -EINVAL;
> +
> +	p = fpu + fpu_user_xstate_size + FP_XSTATE_MAGIC2_SIZE;
> +	p = (void __user *)ALIGN((unsigned long)p, 8);
> +
> +	if (!access_ok(VERIFY_READ, p, sizeof(*ext)))
> +		return -EFAULT;
> +
> +	if (__copy_from_user(ext, p, sizeof(*ext)))
> +		return -EFAULT;
> +
> +	if (ext->total_size != sizeof(*ext))
> +		return -EINVAL;
> +	return 0;
> +}
> +
> +static int copy_ext_to_user(void __user *fpu, struct sc_ext *ext)
> +{
> +	void __user *p;
> +
> +	if (!fpu)
> +		return -EINVAL;
> +
> +	if (ext->total_size != sizeof(*ext))
> +		return -EINVAL;
> +
> +	p = fpu + fpu_user_xstate_size + FP_XSTATE_MAGIC2_SIZE;
> +	p = (void __user *)ALIGN((unsigned long)p, 8);
> +
> +	if (!access_ok(VERIFY_WRITE, p, sizeof(*ext)))
> +		return -EFAULT;
> +
> +	if (__copy_to_user(p, ext, sizeof(*ext)))
> +		return -EFAULT;
> +
> +	return 0;
> +}
> +
> +int restore_sigcontext_ext(void __user *fp)
> +{
> +	int err = 0;
> +
> +	if (boot_cpu_has(X86_FEATURE_SHSTK) && fp) {
> +		struct sc_ext ext = {0, 0};
> +
> +		err = copy_ext_from_user(&ext, fp);
> +
> +		if (!err)
> +			err = cet_restore_signal(ext.ssp);
> +	}
> +
> +	return err;
> +}
> +
> +int setup_sigcontext_ext(struct ksignal *ksig, void __user *fp)
> +{
> +	int err = 0;
> +
> +	if (boot_cpu_has(X86_FEATURE_SHSTK) && fp) {
> +		struct sc_ext ext = {0, 0};
> +		unsigned long rstor;
> +
> +		rstor = (unsigned long)ksig->ka.sa.sa_restorer;
> +		err = cet_setup_signal(is_ia32_frame(ksig), rstor, &ext.ssp);
> +		if (!err) {
> +			ext.total_size = sizeof(ext);
> +			err = copy_ext_to_user(fp, &ext);
> +		}
> +	}
> +
> +	return err;
> +}
> +#endif
> +
>  static void
>  handle_signal(struct ksignal *ksig, struct pt_regs *regs)
>  {
> -- 
> 2.17.1
> 
