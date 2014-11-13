Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 4EA3E6B00DA
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 09:29:38 -0500 (EST)
Received: by mail-wi0-f182.google.com with SMTP id h11so398707wiw.3
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 06:29:37 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id ci8si32533217wib.29.2014.11.13.06.29.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 13 Nov 2014 06:29:37 -0800 (PST)
Date: Thu, 13 Nov 2014 15:29:26 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 09/11] x86, mpx: on-demand kernel allocation of bounds
 tables
In-Reply-To: <20141112170510.3D07BA53@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.11.1411131454130.3935@nanos>
References: <20141112170443.B4BD0899@viggo.jf.intel.com> <20141112170510.3D07BA53@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: hpa@zytor.com, mingo@redhat.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, qiaowei.ren@intel.com, dave.hansen@linux.intel.com

On Wed, 12 Nov 2014, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> Thomas, I know you're not a huge fan of using mm->mmap_sem for serializing
> this stuff.  But, now that we are not adding an additional lock a la
> mm->bd_sem, I can't quite justify adding another lock and trying to
> reconcile the interactions and ording with mmap_sem.
> 
> We are only adding two spots where we acquire mmap_sem and did not. All of
> the other "use" is in places where it is held already.  Those two points
> of new use are *tiny* and can easily be replaced in the future.

I'm fine with that as long as we dont have the "drop, reacquire, handle
races of all sorts" dance.


> +static inline void arch_bprm_mm_init(struct mm_struct *mm,
> +		struct vm_area_struct *vma)
> +{
> +#ifdef CONFIG_X86_INTEL_MPX
> +	mm->bd_addr = MPX_INVALID_BOUNDS_DIR;
> +#endif
> +}
> +

I'd rather have in mpx.h

static inline void mpx_mm_init(struct mm_struct *mm)
{
#ifdef CONFIG_X86_INTEL_MPX
 	mm->bd_addr = MPX_INVALID_BOUNDS_DIR;
#endif
}

and make this

static inline void arch_bprm_mm_init(struct mm_struct *mm,
       		   		     struct vm_area_struct *vma)
{
	mpx_mm_init(mm);
}

So this #ifdef can be replaced

> +++ b/arch/x86/kernel/setup.c	2014-11-12 08:49:26.494916477 -0800
> @@ -959,6 +959,13 @@ void __init setup_arch(char **cmdline_p)
>  	init_mm.end_code = (unsigned long) _etext;
>  	init_mm.end_data = (unsigned long) _edata;
>  	init_mm.brk = _brk_end;
> +#ifdef CONFIG_X86_INTEL_MPX
> +	/*
> +	 * NULL is theoretically a valid place to put the bounds
> +	 * directory, so point this at an invalid address.
> +	 */
> +	init_mm.bd_addr = MPX_INVALID_BOUNDS_DIR;
> +#endif

with

	mpx_mm_init(&init_mm);

> +dotraplinkage void do_bounds(struct pt_regs *regs, long error_code)
> +{
> +	enum ctx_state prev_state;
> +	struct bndcsr *bndcsr;
> +	struct xsave_struct *xsave_buf;
> +	struct task_struct *tsk = current;
> +	siginfo_t *info;
> +
> +	prev_state = exception_enter();
> +	if (notify_die(DIE_TRAP, "bounds", regs, error_code,
> +			X86_TRAP_BR, SIGSEGV) == NOTIFY_STOP)
> +		goto exit;
> +	conditional_sti(regs);
> +
> +	if (!user_mode(regs))
> +		die("bounds", regs, error_code);
> +
> +	if (!cpu_feature_enabled(X86_FEATURE_MPX)) {
> +		/* The exception is not from Intel MPX */
> +		goto exit_trap;
> +	}
> +
> +	fpu_save_init(&tsk->thread.fpu);

That lacks a comment why we need to do an xsave here.

> +	xsave_buf = &(tsk->thread.fpu.state->xsave);
> +	bndcsr = get_xsave_addr(xsave_buf, XSTATE_BNDCSR);
> +	if (!bndcsr)
> +		goto exit_trap;

...

> +exit:
> +	exception_exit(prev_state);

And this lacks a:

    	 return;

Otherwise you can avoid the whole exercise above and just jump to
exit_trap :)

> +exit_trap:
> +	/*
> +	 * This path out is for all the cases where we could not
> +	 * handle the exception in some way (like allocating a
> +	 * table or telling userspace about it.  We will also end
> +	 * up here if the kernel has MPX turned off at compile
> +	 * time..
> +	 */
> +	do_trap(X86_TRAP_BR, SIGSEGV, "bounds", regs, error_code, NULL);
> +	exception_exit(prev_state);
> +}

> +int mpx_handle_bd_fault(struct xsave_struct *xsave_buf)
> +{
> +	int ret = 0;
> +	/*
> +	 * Userspace never asked us to manage the bounds tables,
> +	 * so refuse to help.
> +	 */
> +	if (!kernel_managing_mpx_tables(current->mm)) {
> +		ret = -EINVAL;
> +		goto out;
> +	}
> +
> +	ret = do_mpx_bt_fault(xsave_buf);
> +	if (ret) {
> +		force_sig(SIGSEGV, current);
> +		/*
> +		 * The force_sig() is essentially "handling" this
> +		 * exception.  Return 0 so that the traps.c code
> +		 * does not take any further action.
> +		 */
> +		ret = 0;
> +	}
> +out:
> +	return ret;

Wee. That's convoluted.

	if (!kernel_managing_mpx_tables(current->mm))
		return -EINVAL;
	if (do_mpx_bt_fault(xsave_buf)) {
		/* Add comment */
		force_sig(SIGSEGV, current);
	}
	return 0;

Does the same thing in a readable form :)

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
